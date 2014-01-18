#!/bin/bash
install_ruby() {
    yum -y update
    yum -y install ruby ruby-devel rubygems curl
}
