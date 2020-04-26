# \<o> Spienzler
raspberry pi cam and weather station

## Install

### Preparation

1. Install Raspbian Buster Lite: [RaspberryPi Raspian Doc](https://www.raspberrypi.org/documentation/installation/installing-images/)
1. For a headless installation, place an empty file 'ssh' on the boot partition: 
  `touch /path/to/mounted/sd-card/boot/ssh`
1. Make sure you can access your Raspy by console/ssh.

### Spienzler

login as root and execute: `source <(curl -s https://raw.githubusercontent.com/spienzler/device/master/bin/init.sh)`
