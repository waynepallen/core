#!/bin/bash
export RAILS_ENV=production
./bootstrap.sh && \
    ./setup/01-crowbar-rake-tasks.install && \
    ./setup/02-make-machine-key.install
