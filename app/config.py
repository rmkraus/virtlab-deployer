#!/usr/bin/env python
import sys
import os
import json
from PyInquirer import Token, prompt, Separator


CONFIG_PATH = '/data/config.sh'
CONFIG_FOOTER = """
############################################################################
###### DO NOT CHANGE ANYTHING BELOW THIS LINE ##############################
############################################################################

# Setup Tarraform
export TF_DATA_DIR=/data/terraform
export TF_INPUT=0
export TF_IN_AUTOMATION=1
export TF_LOG_PATH=/data/terraform.${DEMO_PREFIX}.log
export TF_VAR_ami_id_win='ami-0133f7a3fff75df0d'  # Windows Server 2016
export TF_VAR_ami_id_console='ami-0c322300a1dd5dc79'  # RHEL 8
export TF_VAR_app_instance_type="t2.large"
export TF_VAR_win_node_count=$(expr ${WIN_NODE_COUNT} + 1)
export TF_VAR_aws_availability_zone=${AWS_AVAILABILITY_ZONE}
export TF_VAR_aws_r53_zone_id=${AWS_R53_ZONE_ID}
export TF_VAR_lab_prefix="${LAB_PREFIX}"
export TF_VAR_admin_password="${ADMIN_PASSWORD}"
"""


def password_repr(password):
    return '*********'

class Parameter(object):

    def __init__(self, name, prompt, value_reprfun=str):
        self._name = name
        self._value = os.environ.get(self._name, '')
        self._prompt = prompt
        self._value_reprfun = value_reprfun

    @property
    def name(self):
        return self._name

    @property
    def value(self):
        return self._value

    @value.setter
    def value(self, value):
        self._value = value

    @property
    def prompt(self):
        return self._prompt

    def update(self):
        question = [
            {
                'type': 'input',
                'name': 'newval',
                'message': param.prompt,
                'default': param.value,
            }
        ]
        answer = prompt(question)
        self.value = answer['newval']

    def __repr__(self):
        return '{}: {}'.format(self.prompt, self._value_reprfun(self.value))

    def to_bash(self):
        return "export {}='{}'".format(self.name, self.value)


class ListDictParameter(Parameter):

    def __init__(self, name, prompt, keys):
        self._name = name
        self._value = json.loads(os.environ.get(self._name, '[]'))
        self._prompt = prompt
        self._keys = keys
        self._primary_key = keys[0][0]

    def _value_reprfun(self, value):
        return '{} items'.format(len(self.value))

    def update(self):
        # expand - remove add edit done
        # remove:edit -> list -> 3xinput
        # add -> 3xinput
        done = False

        while not done:
            question = [
                {
                    'type': 'expand',
                    'message': 'What would you like to do?',
                    'name': 'action',
                    'default': 'a',
                    'choices': [
                        {
                            'key': 'a',
                            'name': 'Add Entry',
                            'value': 'a'
                        },
                        {
                            'key': 'e',
                            'name': 'Edit Entry',
                            'value': 'e'
                        },
                        {
                            'key': 'r',
                            'name': 'Remove Entry',
                            'value': 'r'
                        },
                        {
                            'key': 'd',
                            'name': 'Done',
                            'value': 'd'
                        }
                    ]
                }
            ]
            answer = prompt(question)

            if answer['action'] == 'd':
                done = True
            elif answer['action'] in 'er':
                self._update_edit(answer['action'])
            elif answer['action'] == 'a':
                self._value.append(self._mkentry({}))

    def _update_edit(self, action_code):
        if action_code == 'r':
            action = 'remove'
        else:
            action = 'edit'

        question = [
            {
                'type': 'list',
                'name': 'index',
                'message': 'Which item would you like to {}?'.format(action),
                'choices': [{'name': item[self._primary_key],
                             'value': index} for (index, item) in enumerate(self.value)]
            }
        ]
        answer = prompt(question)

        if action_code == 'r':
            self.value.pop(answer['index'])
        else:
            self.value[answer['index']] = self._mkentry(self.value[answer['index']])

    def _mkentry(self, defaults):
        questions = [ {'type': 'input',
                       'message': item[1],
                       'name': item[0],
                       'default': defaults.get(item[0], '')}
                     for item in self._keys]
        return prompt(questions)

    def to_bash(self):
        return "export {}='{}'".format(self.name, json.dumps(self.value))


class ParameterCollection(list):

    def __init__(self, name, prompt, values):
        super().__init__(values)
        self._name = name
        self._prompt = prompt

    def to_choices(self):
        return [Separator(self._prompt)] + \
            [{'name': repr(item),
              'description': str(item.value),
              'value': '{}|{}'.format(self._name, item.name)} for item in self]

    def to_bash(self):
        return ['# {}'.format(self._prompt.upper())] + [item.to_bash() for item in self]

    def get_param(self, pname):

        def filter_fun(val):
            return val.name == pname

        return list(filter(filter_fun, self))[0]


class configurator(object):

    def __init__(self, path, footer):
        self._path = path
        self._footer = footer
        self.lab = ParameterCollection('lab', 'Lab Configuration', [
            Parameter('LAB_PREFIX', 'Lab Prefix'),
            Parameter('ADMIN_PASSWORD', 'Adminstrator Password', password_repr),
            Parameter('USER_PASSWORD', 'User Password', password_repr),
            Parameter('WIN_NODE_COUNT', 'Number of Windows Workstations'),
            Parameter('ADMIN_EMAIL', 'Lab Administrator Email')])
        self.aws = ParameterCollection('aws', 'AWS Configuration', [
            Parameter('AWS_ACCESS_KEY_ID', 'Access Key ID'),
            Parameter('AWS_SECRET_ACCESS_KEY', 'Secret Access Key', password_repr),
            Parameter('AWS_DEFAULT_REGION', 'Region'),
            Parameter('AWS_AVAILABILITY_ZONE', 'Availability Zone'),
            Parameter('AWS_R53_ZONE_ID', 'Route53 Zone ID'),
            Parameter('AWS_R53_DOMAIN', 'Route53 Domain Name')])
        self.customize = ParameterCollection('customize', 'Lab Customizations', [
            ListDictParameter('SSH_SHORTCUTS', 'Desktop SSH Shortcuts', [('name', 'Shortcut Name'), ('user', 'SSH User'), ('host', 'SSH Host'), ('password', 'SSH Password')]),
            ListDictParameter('WWW_SHORTCUTS', 'Desktop Web Shortcuts', [('name', 'Shortcut Name'), ('desc', 'Shortcut Description'), ('url', 'Full URL (include https)')])])

    def _main_menu(self):
        question = [
            {
                'type': 'checkbox',
                'message': 'Which items would you like to change?',
                'name': 'parameters',
                'choices': self.lab.to_choices() + \
                        self.aws.to_choices() +  \
                        self.customize.to_choices()
            }
        ]
        return prompt(question)

    def _update_param(self, raw_param):
        (collection, param_name) = raw_param.split('|')
        if collection == 'lab':
            self.lab.get_param(param_name).update()
        elif collection == 'aws':
            self.aws.get_param(param_name).update()
        elif collection == 'customize':
            self.customize.get_param(param_name).update()
        else:
            raise ValueError('{} not a valid collection'.format(collection))

    def dump(self):
        with open(self._path, 'w') as outfile:
            for line in self.lab.to_bash() + \
                    self.aws.to_bash() + \
                    self.customize.to_bash():
                outfile.write(line + '\n')
            outfile.write(self._footer)

    def configurate(self):
        loop = True

        while loop:
            to_update = self._main_menu()
            print('')

            for parameter in to_update['parameters']:
                self._update_param(parameter)
            print('')

            loop = bool(to_update['parameters'])

        self.dump()


def main():
    print('VirtLab Configurator 9000\n')
    return configurator(CONFIG_PATH, CONFIG_FOOTER).configurate()


if __name__ == "__main__":
    sys.exit(main())


