#!/bin/bash
install_ruby() (
    [[ -f /etc/sysconfig/i18n ]] || echo "LANG=$LANG" >/etc/sysconfig/i18n
    if [[ ! -x /usr/bin/ruby ]]; then
        yum -y upgrade
        yum -y install http://mirrors.servercentral.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm || :
        yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel \
            libyaml-devel libffi-devel openssl-devel make which \
            install bzip2 autoconf automake libtool bison iconv-devel curl
        yum -y install ruby ruby-devel rubygems
    fi
    [[ -L /dev/fd ]] || ln -sf /proc/self/fd /dev/fd
    if [[ ! -d /home/crowbar/.rvm ]]; then
        su -l -c 'curl -L get.rvm.io | bash -s stable' crowbar
        su -l -c 'rvm install 2.0.0' crowbar
        su -l -c 'rvm use 2.0.0 --default' crowbar
    fi
)
