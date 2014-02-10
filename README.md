# OpenCrowbar Documentation README

_This is not the documentation you are looking for_. it is a pointer to the real documentation in the [documentation](/doc/README.md) directory

## Looking for Crowbar Resources?

[The Crowbar website](http://crowbar.github.io) has links to all information and is our recommended starting place.

## Specific Crowbar Documentation 

We track Crowbar documentation with the code so that we can track versions of documentation with the code.  It is located in the /doc directory.

## Background
Crowbar documentation is distributed into multiple places under the /doc directory of each Crowbar module (aka "barclamps").  When the modules are installed, Crowbar combines all the [/doc directories](/doc/README.md) into a master documentation set.  These directories are structured into subdirectories for general topics.  This structure is common across all barclamps in the [Crowbar project](https://github.com/crowbar/)

> Please, do NOT add documentation in locations besides =/doc=!  If necessary, expand this README to include pointers to important /doc information.

## Short Term notes for OpenCrowbar Development Environment

1. Prep Environment
  1. Install Docker (do once)
  1. sudo chmod 666 /var/run/docker.sock (to run docker without sudo)
  1. sudo usermod -a -G docker <your-user> (to permanently run Docker
  without sudo)
2. To build Sledgehammer:
  1. tools/build_sledgehammer.sh
2. To run in development mode:
  1. tools/docker-admin centos ./development.sh
3. To run in production mode:
  1. tools/docker-admin centos ./production.sh admin.cluster.fqdn
  1. tools/kvm-slave (to launch a KVM-based compute node)

Once Crowbar is bootstrapped (or if anything goes wrong), you will get a shell running inside the container.  Exiting the shell will kill Docker.
