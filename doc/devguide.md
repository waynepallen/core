# OpenCrowbar Developers' Guide

Welcome to the amazing fuzziness of Crowbar!  

This guide is targeted at people who want to _contribute and extend_ OpenCrowbar.  You should review the architectural and operator instructions as part of the learning process.

## Dev Environment

Our development environments include a _working_ administrative server for testing.  It is very important in our process that developers are able to run deployments in their environment as part of the testing cycle.  

While we have invested in BDD and system tests to catch core logic errors, most changes require performing a deployment to test correctness!

The following steps are focused on Ubuntu 12.04.03.  Please extend for other platforms

1. Base OS Installed

  1. TWO network interfaces
    1. bridge external
    1. host-only on 192.168.124.x
  1. setup an .ssh keypair
  1. Prep for docker (may not be needed in future) following [[http://docs.docker.io/en/latest/installation/ubuntulinux/]]
    1. if you are using Docker behind a proxy then make sure the Docker service (running as root) can reach the outside too!
  1. 'apt-get install git docker-lxc'
    1. allow docker without sudo: =sudo usermod -a -G docker crowbar=
    1. you'll need to reboot for this setting to take effect
  1. prep for sledgehammer requirements: =sudo apt-get install rpm rpm2cpio=
1. Checkout Code 
  1. create a personal fork of the =https://github.com/opencrowbar/core=
1. Fork the Code if you want to be able to submit changes
  1. =git clone https://github.com/opencrowbar/core=
  1. setup your git identity (one time only)
    1. =git config --global user.name "user.name"=
    1. =git config --global user.email "email.address"=
  1. add a personal remote: =git remote add personal =https://github.com/[yourgitnamehere]/core=

1. Setup Docker Admin Node
  1. =cd core=
  1. For UI simulator & testing: =./tools/docker_admin.sh centos ./development.sh=
  1. For Workload creation: =./tools/docker_admin.sh centos ./production.sh admin.opencrowbar.com=

1. Testing your code
  1. Dev/Simulator allows you to play with the UI and BDD tests which is good for developers working on the UI/API and Annealer logic
    1. Dev mode creates a special user =developer/Cr0wbar!=
    1. Run the BDD system [see BDD test pages]
  1. Production on VMs allows you to create workloads and jigs that can only be tested by 
    1. You'll need to put the Admin container on a network the VMs can access
    1. You'll need to create some nodes in VMs (or Containers) ...
    1. Boot the nodes so Crowbar can discover and manage them

1. To create a pull request
  1. make your change and commit it: =git commit -a -m "helpful info"=
  1. get the latest code from origin: =git fetch=
  1. sync your code into the trunk: =git rebase=
  1. push your change to your personal repo in a branch: =git push personal master:[my-pull-request-branch]=
  1. from your Github fork UI, create a pull request from my-pull-request-branch

1. other items that we find handy if you are developing on VMs behind corporate firewalls
  1. CNTLM proxy: =sudo apt-get install cntlm=
     1. make sure that you allow NON local hosts to use the proxy (in =/etc/cntlm.conf= set =gateway yes=)!  Containers are not "local" and require your CNTLM proxy to act as a gateway.
  1. SAMBA share: =sudo apt-get install samba=
  1. Passwordless sudo: =sudo sed -ie "s/%sudo\tALL=(ALL:ALL) ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers=

