#!/bin/bash

if ! which puppet; then
    if [[ -f /etc/redhat-release || -f /etc/centos-release ]]; then
        # comment-out following line if you want the 2.7 puppet, otherwise we get 3.4.3
        rpm -ivh https://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
        yum -y makecache
        yum install -y puppet
        /etc/init.d/puppet start

    elif [[ -d /etc/apt ]]; then
        # enable repository for ubuntu precise
        # comment-out following 3 lines if you want the 2.7 puppet, otherwise we get 3.4.3
        wget https://apt.puppetlabs.com/puppetlabs-release-precise.deb
        dpkg -i puppetlabs-release-precise.deb
        apt-get -y update
        apt-get -y --force-yes install puppet
        /etc/init.d/puppet start

    elif [[ -f /etc/SuSE-release ]]; then
        zypper install -y -l puppet
    else
        die "Staged on to unknown OS media!"
    fi
fi

puppetmaster=$(read_attribute "crowbar/puppet-master/name")
node_name=$(read_attribute "crowbar/puppet-agent/name")
echo "Puppetmaster node: $puppetmaster"
echo "Puppet node: $node_name"
cat > "/etc/puppet/puppet.conf" <<EOF
[main]
server= $puppetmaster
certname = $node_name
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=$vardir/lib/facter
templatedir=$confdir/templates

[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY
EOF