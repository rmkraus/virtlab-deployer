# LAB CONFIGURATION
export LAB_PREFIX="virtlab"
export ADMIN_PASSWORD='Admin$123'
export USER_PASSWORD='Student$123'
export WIN_NODE_COUNT=1
export ADMIN_EMAIL=dev@null.com

# AWS CONFIGURATION
export AWS_ACCESS_KEY_ID="ABCDEFG"
export AWS_SECRET_ACCESS_KEY="ABCDEFG1234567HIJKLMNOP"
export AWS_DEFAULT_REGION="us-east-1"
export AWS_AVAILABILITY_ZONE="us-east-1a"
export AWS_R53_ZONE_ID="ABCDEFG12345"
export AWS_R53_DOMAIN="example.com"

# LAB CUSTOMIZATION
export SSH_SHORTCUTS='[{"name": "Your Server", "user": "student{{ student_number }}", "host": "student{{ student_number }}.example.com", "password": "NotAPassword"}]'
export WWW_SHORTCUTS='[{"name": "Google", "desc": "Advertising company that makes a search engine", "url": "https://www.google.com"}]'

###############################################################################
###### DO NOT CHANGE ANYTHING BELOW THIS LINE #################################
###############################################################################

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
