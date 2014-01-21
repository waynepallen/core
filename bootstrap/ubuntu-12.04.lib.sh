#!/bin/bash
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8
install_ruby() {
    apt-get -y --force-yes update
    apt-get -y --force-yes dist-upgrade
    apt-get -y --force-yes install ruby1.9.1 ruby1.9.1-dev build-essential curl
}
