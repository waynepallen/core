#!/bin/bash
install_ruby() {
    yum -y upgrade
    yum -y install ruby ruby-devel curl
}
