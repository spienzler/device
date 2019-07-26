#!/bin/bash

# 1. add ansible
echo 'deb http://ppa.launchpad.net/ansible/ansible/ubuntu trusty main' > /etc/apt/sources.list.d/ansible

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367

# 2. install pkgs
apt update
apt install ansible git -y

# 3. clone rpcw source
git clone https://github.com/psunix/rpcw.git /opt/rpcw
