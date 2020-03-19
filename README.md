# VirtLab Deployer

This code creates virtual computer lab environments on AWS for the purposes of
running remote workshops.

## Installing the Deployer

1) Install podman. Docker can probably be used in a pinch, but it is not
tested.
2) Configure your system such that your current user can run podman. You can
run the deployer commands as root, but it is not preferred.
3) Run the following command to install the virtlab cli.

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/rmkraus/virtlab-deployer/master/bin/virtlab-install.sh)"
```

## VirtLab Prerequisites

1) An AWS account with permissions to create new EC2 instances, keys, security
groups, VPCs, etc.
2) A configured Route53 domain.

## Deploying a new Virtual Lab


### Create a new context
Create a new virtlab context to work in:

```bash
virtlab context ryanlab
```

### Configure the new context
Launch the interactive configuration tool:

```bash
virtlab config
```

Use the arrow keys and spacebar to select the values you'd like to change.
You can select all menu items by using the 'a' key.
Press Enter when you are done.
The first time you are configuring a new context, you'll likely want to edit
all of the items.


You will then be prompted for all of the configuration values.
The Administrator Password must be sufficiently complext or the deployment will
fail. I highly recomend using a random password generator. Environemnt
numberings start at 0, but 0 is reserved for administrative use. Student number
0 will never be given to a student. For this reason, you'll always want to
create one additional Windows Workstation.


When creating SSH Shortcuts and Web Shortcuts, you can use the variable
*student_number* in any of the fields to reference the workspace's student
number. Jinja variable syntax is used. That would look like this:

```
? Desktop SSH Shortcuts: What would you like to do?  a
? Shortcut Name  Control Node
? SSH User  user
? SSH Host  student{{ student_number }}.db82.rhdemo.io
? SSH Password  asdfasdf
? Desktop SSH Shortcuts: What would you like to do?  d
```

If you prefer to configure the environment manually without using the
interactive tool, you can directly edit the file at:

```bash
$(virtlab dir)/config.sh
```

### Deploy the Context
To deploy your virtual lab:

```bash
virtlab deploy
```

## Destroying a Virtual Lab

When you are done with your lab, it is best to tear it down to save money.

```bash
virtlab context  # verify your active context
virtlab destroy
```

This will remove the lab from AWS, but keep the configuration saved locally.
If you would also like to remove the configuration and context:

```bash
virtlab forget ryanlab
```
