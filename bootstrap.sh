#!/bin/bash
set -e
# Figure out what we are running on.
if [[ -f /etc/system-release ]]; then
    read DISTRIB_ID _t DISTRIB_RELEASE rest < /etc/system-release
elif [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRIB_ID="$ID"
    DISTRIB_RELEASE="$VERSION_ID"
elif [[ -f /etc/lsb-release ]]; then
    . /etc/lsb-release
else
    echo "Cannot figure out what we are running on!"
fi
DISTRIB_ID="${DISTRIB_ID,,}"
OS_TOKEN="$DISTRIB_ID-$DISTRIB_RELEASE"
export OS_TOKEN DISTRIB_ID DISTRIB_RELEASE

if [[ -f bootstrap/${OS_TOKEN}.lib.sh ]]; then
    . "bootstrap/${OS_TOKEN}.lib.sh"
elif [[ -f bootstrap/${DISTRIB_ID}.lib.sh ]]; then
    . "bootstrap/${DISTRIB_ID}.lib.sh"
else
    echo "Cannot source a bootstrap library for $OS_TOKEN!"
    exit 1
fi

which ruby >&/dev/null || \
    install_ruby
which chef-solo &>/dev/null || \
    curl -L https://www.opscode.com/chef/install.sh | bash
chef-solo -c /opt/opencrowbar/core/bootstrap/chef-solo.rb -o 'recipe[crowbar-bootstrap]' && exit 0
echo "Chef-solo bootstrap run failed"
exit 1
