#!/bin/bash

if ! which puppet; then
    if [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
        # comment-out following line if you want the 2.7 puppet, otherwise we get 3.4.3
        rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
        yum -y makecache
        yum install -y puppet
        # rm control script - we don't have access to the stand-alone install...
        /etc/init.d/puppet stop
        rm -f /etc/init.d/puppet

    elif [[ -d /etc/apt ]]; then
        # enable repository for ubuntu precise
        # comment-out following 3 lines if you want the 2.7 puppet, otherwise we get 3.4.3
        wget https://apt.puppetlabs.com/puppetlabs-release-precise.deb
        dpkg -i puppetlabs-release-precise.deb
        apt-get -y update
        apt-get -y --force-yes install puppet
        # rm control script - we don't have access to the stand-alone install...
        /etc/init.d/puppet stop
        rm -f /etc/init.d/puppet

    elif [[ -f /etc/SuSE-release ]]; then
        zypper install -y -l puppet-common
    else
        die "Staged on to unknown OS media!"
    fi
fi

node_name=$(read_attribute "crowbar/puppet-agent-sa/name")
echo "Puppet node: $node_name"
cat > "/etc/puppet/puppet.conf" <<EOF
[main]
certname = $node_name
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=\$vardir/lib/facter
templatedir=\$confdir/templates
EOF