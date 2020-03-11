#!/bin/bash

export TF_DATA_DIR=/data/terraform
export TF_INPUT=0
export TF_IN_AUTOMATION=1

if [ ! -e /data/config.sh ]; then
  cp /data.skel/config.sh /data/config.sh
fi

mkdir -p /data/ansible
if [ ! -e /data/ansible/inventory ]; then
    touch /data/ansible/inventory
fi

if [ ! -d /data/terraform ]; then
  terraform init tf
fi

/bin/bash
