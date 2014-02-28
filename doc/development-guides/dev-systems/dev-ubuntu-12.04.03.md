# Configuration Guide - Ubuntu 12.04.03

Engineers value documentation that explains how to get a development workstation configured quickly. It is human nature to customize and change things - we do this frequently, but sometimes we need to get back to first base.  This document will help to get you there.

##Installation and Configuration Information

> Note to reader, many of these steps are generic and should be moved to a higher level document. 

> An attempt has been made to pre-stage downloads so several steps can be done in parallel

###Base OS Installed
  1. VirtualBox, TWO network interfaces
    1. bridge external (assumed to be on eth0)
    1. host-only on 192.168.124.x (assumed to be on eth1)
  1. Setup an .ssh keypair using `rssh-keygen`
  1. Optional Items that we find handy if you are developing on Windows using VMs behind corporate firewalls
    1. CNTLM proxy: `sudo apt-get install cntlm`
       1. make sure that you allow NON local hosts to use the proxy (in =/etc/cntlm.conf= set `gateway yes`)!  Containers are not "local" and require your CNTLM proxy to act as a gateway.
    1. SAMBA share: `sudo apt-get install samba`
    1. Passwordless sudo: `sudo sed -ie "s/%sudo\tALL=(ALL:ALL) ALL/%sudo ALL=(ALL) NOPASSWD: ALL/g" /etc/sudoers`
  1. Prep for Docker 
    1. Review [http://docs.docker.io/en/latest/installation/ubuntulinux/]
        * Using the recommended curl script is the easiest way to install docker
        * DO NOT TEST docker until you follow the steps below! 
    1. `apt-get install git`
    1. allow docker without sudo: `sudo usermod -a -G docker crowbar`
    1. we recommend changing from AUFS to Device Mapper for storage (slower but more native)
       1. `sudo vi /etc/default/docker`
       1. add `DOCKER_OPTS="-s devicemapper"`
       1. while you are here, you may want to set your proxy server (the #default is for CNTLM)
    1. you'll need to reboot for this setting to take effect
    1. time saving tip: 
      1. preload the with `docker pull opencrowbar/centos:6.5-4`
      1. test docker, use `docker run -i -t centos /bin/bash`
  1. prep for sledgehammer requirements: `sudo apt-get install rpm rpm2cpio`

###Position Boot Assets, see [[docker/Docker-TLDR]]
    1. Copy the ISOs that you want for nodes to `$HOME/.cache/opencrowbar/tftpboot/isos`

###Checkout Code 
  1. get git: `sudo apt-get install git`
  1. get the code: `git clone https://github.com/opencrowbar/core`
    1. if you want to commit, please review [[..contributing.md]]

###Build Sledgehammer (do 1 time, but takes a while)
  1. from core, `tools/build_sledgehammer.sh`

###Setup Docker Admin Node
  1. Enter the OpenCrowbar repo `cd core`
  1. For Workload creation: `tools/docker-admin.sh centos ./production.sh admin.opencrowbar.com`
    1. the first time will be SLOW because Crowbar creates PXE boot images; however, they are saved outside the container for next time.
  1. To monitor the logs inside the container, use `tail -f /var/log/crowbar/production.log`
  1. You'll need to put the Admin container on a network the VMs can access
    1. `brctl addif docker0 eth1`
    1. You'll need to create some nodes in VMs (or Containers) ...
    1. Boot the nodes so Crowbar can discover and manage them
  1. Helpful Docker Items
     1. `docker ps` to see if you are running a container
     1. `docker inspect [foo]` to get the IP address of the container so you can =ssh root@foo= into it
     1. `docker kill [foo]` if you want to force stop the container from outside (=exit= works otherwise)
     1. `docker tag [foo]` if you want to save the container for later use (experts only)

###Testing your code
  1. Dev/Simulator allows you to play with the UI and BDD tests which is good for developers working on the UI/API and Annealer logic
    1. Start with `tools/docker-admin centos ./development.sh`
    1. Dev mode creates a special user `developer/Cr0wbar!`
    1. To monitor the logs inside the container, use `tail -f /var/log/crowbar/development.log`
    1. Run the BDD system [see BDD test pages]
       1. `sudo apt-get install erlang`
       1. compile the BDD code
       1. update the config file (copy example.config to default.config and update)
       1. `erl` then `bdd:test()`
    1. Rails console in container: ''
