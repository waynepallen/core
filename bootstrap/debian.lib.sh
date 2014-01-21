#!/bin/bash
install_ruby() {
    apt-get -y --force-yes update
    apt-get -y --force-yes upgrade
    apt-get -y --force-yes install ruby2.0 ruby2.0-dev curl
}
