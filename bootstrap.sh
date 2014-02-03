#!/bin/bash
set -e
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
