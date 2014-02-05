# OpenCrowbar Developers' Guide

Welcome to the amazing fuzziness of Crowbar!  This guide is targeted at people who want to contribute and extend OpenCrowbar

## Introduction


## Prerequisites

Before you start developing a barclamp, we recommend that you do the following:

*	Learn how to use Crowbar
*	Write down the manual steps needed to install your software
*	Create Chef Cookbooks to deploy your software

## Getting started

The following steps are focused on Ubuntu 12.04.03.  Please extend for other platforms

1. Base OS Installed

   1. TWO network interfaces
      1. bridge external
      1. host-only on 192.168.124.x
   1. setup an .ssh keypair
   1. Prep for docker (may not be needed in future) following http://docs.docker.io/en/latest/installation/ubuntulinux/
   1. 'apt-get install git docker-lxc'
   1. Optional items (used for specialized environments)
      1. 'apt-get install cntlm'
1. Checkout Code (assumes that you plan to commit changes back)
   1. create a personal fork of the 'https://github.com/opencrowbar/core'
   1. 'git clone https://github.com/opencrowbar/core'
   1. add a personal remote: 'git remote add personal https://github.com/[yourgitnamehere]/core'
1. Setup Docker Admin Node
  1. 'cd core'
  1. 
  1. ./in_docker.sh centos ./development.sh 
  1. ./in_docker.sh centos ./production.sh admin.opencrowbar.com

1. To create a pull request
  1. make your change and commit it: 'git commit -a -m "helpful info"'
  1. get the latest code from origin: 'git fetch'
  1. sync your code into the trunk: 'git rebase'
  1. push your change to your personal repo in a branch: 'git push personal master:[my-pull-request-branch]'
  1. from your Github fork UI, create a pull request from my-pull-request-branch
