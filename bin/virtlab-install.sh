#!/bin/bash
set -x

REPO="https://raw.githubusercontent.com/rmkraus/virtlab-deployer"

curl ${REPO}/master/bin/virtlab > /tmp/virtlab
sudo install -g root -o root -m 755 /tmp/virtlab /usr/bin/virtlab
rm /tmp/virtlab

