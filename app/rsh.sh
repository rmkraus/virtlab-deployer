#!/bin/bash

HOST=$1

ANSIBLE_HOST=$(ansible-inventory --host $HOST |
                grep ansible_host |
                awk -F':' '{print $2}' |
                awk -F',' '{print $1}' |
                tr -d '[:space:]' |
                awk -F'"' '{print $2}')
ANSIBLE_USER=$(ansible-inventory --host $HOST |
                grep ansible_user |
                awk -F':' '{print $2}' |
                awk -F',' '{print $1}' |
                tr -d '[:space:]' |
                awk -F'"' '{print $2}')
ANSIBLE_KEY=$(ansible-inventory --host $HOST |
                grep ansible_ssh_private_key_file |
                awk -F':' '{print $2}' |
                awk -F',' '{print $1}' |
                tr -d '[:space:]' |
                awk -F'"' '{print $2}')

ssh -i "$ANSIBLE_KEY" $ANSIBLE_USER@$ANSIBLE_HOST
