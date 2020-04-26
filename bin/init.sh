#!/bin/bash

# 1. add ansible
echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' > /etc/apt/sources.list.d/ansible

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

# 2. install pkgs
apt update
apt install ansible git -y

# 3. clone rpcw source
git clone https://github.com/spienzler/device.git /opt/spienzler

# 4. execute ansible
ANSIBLE_DIR=/opt/spienzler/ansible
cp -n $ANSIBLE_DIR/mypi.yml.template $ANSIBLE_DIR/mypi.yml
ansible-playbook /opt/spienzler/ansible/spienzler.yml --extra-vars "@$ANSIBLE_DIR/mypi.yml"
