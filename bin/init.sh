#!/bin/bash

SPIENZLER_DIR=/opt/spienzler

if [ -d "$SPIENZLER_DIR" ]; then
  echo "spienzler seems to be initialized already."
  echo "run 'spienzler update' to update to most recent version"
  exit 1
fi

# add ansible
echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' > /etc/apt/sources.list.d/ansible
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
apt update
apt install ansible git -y

# clone spienzler devise source
git clone https://github.com/spienzler/device.git $SPIENZLER_DIR

# execute ansible
ansible-playbook /opt/spienzler/ansible/spienzler.yml
