#!/bin/bash
set -x

REPO="https://github.com/rmkraus/virtlab-deployer"

wget -o /tmp/virtlab ${REPO}/master/bin/virtlab
sudo install -g root -o root -m 755 /tmp/virtlab /usr/bin/virtlab
rm /tmp/virtlab

