#!/bin/bash
./bootstrap.sh && \
    chef-solo -c /opt/opencrowbar/core/bootstrap/chef-solo.rb -o 'recipe[crowbar-bootstrap::cleanup]' && exit 0
echo "Failed to create a cleaned Docker image"
exit 1
