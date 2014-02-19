# Deploy OpenCrowbar via RPM files on CentOS 6.5

## Objectives
Create a OpenCrowbar admin node on a VM or physical machine to begin the process of configuring or managing deployment of a cluster (openstack, hadoop, ceph, etc.).

The following steps will be completed:
* Prepare a Virtual or Physical machine
* Installation of CentOS 6.5 x86_64
* Install OpenCrowbar
* Start OpenCrowbar webUI
* Connect to the webUI using a browser

An outline is provided as a foundation for QA validation requirements for OpenCrowbar RPM packages.

Known limitations of the installation process, its sensitivities to updates and to upgrades is summarized.

## Installation process

Before commencing installation and configuration processing ensure that everything needed is available and that all remove resources that must be accessed are capable of being reached.

### Pre-Requisites
1. CentOS 6.5 x86_64 - download site:  
2. You will need to know how to access the internet from your VM/Physical environment.  
  1. Proxy Services
    1. Windows - Fiddler 2 is a good one
    2. Linux - potential proxy services include: cntlm and squid.
  2. Direct Connection - Ensure you have appropriate security setup per security guidelines in effect within your organization.

### Machine preparation
Machine requirements are
1. Memory: Min 4GB
2. CPU Cores: 2 or more
3. Network Interface Controllers: 2 preferred, 1 minimum (can use virtio if using a VM)
  1. Note: It is possible to use a single NIC. In that case the default network address will be 192.168.124.0/24, the admin node IP address will be 192.168.124.10
  2. Where a single NIC is used, the private admin network (192.168.124.0/24) must be capable of download of files from the internet or from a local caching server
4. Storage: A disk capacity of at least 10 GB is preferred.
5. Ensure that all physical network transports are correctly configured and are operational - at least check/verify that:
  1. All network cabling is in place
  2. Network switches are turned on and configured correctly (ask network admin if necessary)
  3. Keyboard,Video, and Mouse (if required) devices are connected and ready for use.
6. If using a virtual machine (VM), where VM motion (ability to migrated VMs across Hypervisor platforms) is required ensure that secure VM access is correctly configured and is operational.
7. Where network-managed power switches are in use, ensure that network access is secure from unwanted access.


## CentOS 6.5 installation
1. Boot CentOS 6.5 x86_64 from pristine ISO media
2. At the boot screen select "Install or upgrade an existing system", hit Enter
3. Screen: "Welcome to CentOS for x86_64", select [Skip], hit Enter
4. At the first graphical screen, "CentOS 6 Community ENTerprise Operating System", Click [Next]
5. Screen: "What language would you like to use ...", Select "English (English)", Click [Next]
6. Screen: "Select the appropriate keyboard ...", Select "U.S. English", Click [Next]
7. Screen: "What type of devices will your installation involve\?", Select "Basic Storage Devices", Click [Next]
8. Pop-up: "Storage Device Warning", Click [Yes, discard any data]
9. Screen: "Please name this computer. The hostname ...", In the Hostname field enter: "admin.mytest.lcl"
  1. Click [Configure Network]
    Network configuration requirements depend on how many NICs are available, and on available network topology
    1. Single NIC configuration:
      1. Select "System eth0" (first NIC - on public network), Click [Edit]
        1. Check "Connect automatically"
        2. Click [IPV4 Settings]
        3. Select Method "Manual"
        4. Click [Add]
           1. Enter IP address: 192.168.124.10
           2. Click on blank field below "Netmask". Enter: 24, or 255.255.255.0
        5. Click [Apply]
    2. Dual NIC configuration:
      1. Select "System eth0" (first NIC - on public network), Click [Edit]
        1. Check "Connect automatically"
        2. Click [IPV4 Settings]
        3. Select Method "Automatic (DHCP)" if appropriate, else configure network settings. Click [Apply]
      2. Select "System eth1" (second NIC - on private admin network), Click [Edit]
        1. Check "Connect automatically"
        2. Click on [IPV4 Settings]
        3. Select Method "Manual"
        4. Click [Add]
          1. Enter IP address: 192.168.124.10
          2. Click on blank field below "Netmask". Enter: 24, or 255.255.255.0
          3. Click [Apply]
      3. Clock [Close]
10. Screen: "Please select the nearest city in your time zone:", Select your time zone, Click [Next]
11. Screen: "The root account is used for administering the system. ...", Enter Root password "crowbar", Confirm: "crowbar", Click [Next]
12. Popup: "Weak Password", Click [Use Anyway]
13. Screen: "Which type of installation would you like?", Select "Use All Space", Click [Next]
14. Popup: "Writing storage configuration to disk", Click [Write changes to disk]
15. Screen: "The default installation of CentOS is a minimum install ...", Select "Basic Server", Click [Next]
16. The system will now install. When finished, Click [Reboot]
17. Configure internet proxy access (where required) by setting:

     'echo "export http_proxy=http://10.208.64.95:3128" &gt;&gt; ~/.bash_profile'
     'echo "export https_proxy=http://10.208.64.95:3128" &gt;&gt; ~/.bash_profile'
     'echo "export ftp_proxy=http://10.208.64.95:3128" &gt;&gt; ~/.bash_profile'
     'echo "export HTTP_PROXY=http://10.208.64.95:3128" &gt>&gt; ~/.bash_profile'
     'echo "export HTTP_PROXY=http://10.208.64.95:3128" &gt;&gt; ~/.bash_profile' 
     '. ~/.bash_profile' 

Verify proxy operation before proceeding.  An example of how this validation may be completed is shown here:

     #> yum clean all
     #> yum makecache 

### Proxy alternative for YUM only
You can setup Yum to use a proxy and not have to add the proxy information to your bashrc script.  The benefit is that you will not have to unset the proxy when you doing local operations, but Gem will still require the above proxy information!

Follow the instructions at  https://www.centos.org/docs/5/html/yum/sn-yum-proxy-server.html

     # The proxy server - proxy server:port number
     proxy=http://mycache.mydomain.com:3128
     # The account details for yum connections 
     proxy_username=yum-user
     proxy_password=qwerty 

**Do NOT attempt to update the system by executing "yum update" at this time - that will be done during installation of OpenCrowbar.**

**Background information**
The operating system just installed is without the ruby package.  This is by design since CentOS 6.5 ships with ruby-1.8.7 which can not be used with OpenCrowbar.  OpenCrowbar requires ruby-1.9.x or later. This requirement will be met wit locally built RPM packages that will be installed before OpenCrowbar is installed.
Following system reboot, verify that there are two network interfaces, one on a network from which internet access is possible, the other which is private (may route to the internet, but is broadcast isolated from any up-stream network).

## OpenCrowbar installation

**NOTE: This is preliminary information.**  The specific steps outlined here will change soon and will need to be updated.
At this time the needed files may be downloaded from a CentOS 6.5 Development system. The ruby-2.0.0 and OpenCrowbar RPM packages, together with a helpful install script can be made available from such development platform. It is assumed that these RPM packages will be automatically built and made available from this system.

Log into the CentOS 6.5 Admin node that was installed above, log in as the root user.

Execute the following:#> cd /root

     #> rsync -ave ssh crowbar@10.208.64.30:~crowbar/ocb .
     (NOTE: Password is crowbar) 

Change directory:

     #> cd ocb
     #> ./script/install.sh 

**Note:** The contents of the ocb-install.sh file are:

     #!/bin/bash
     cp -f .bash_profile /root/.bash_profile 
     source .bash_profile
     
     chkconfig iptables off
     service iptables stop
     
     cp .bash_profile /root/.bash_profile
     yum -y install http://yum.postgresql.org/9.3/redhat/rhel-6-x86_64/pgdg-centos93-9.3-1.noarch.rpm
     yum -y install http://mirrors.servercentral.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
     yum clean all
     yum makecache
     yum update -y
     
     yum install -y ruby-doc-2.0.0.433-1.el6.noarch.rpm rubygem-rdoc-4.0.0-1.el6.noarch.rpm \
        rubygem-bigdecimal-1.2.0-1.el6.x86_64.rpm rubygems-2.0.2-1.el6.noarch.rpm \
        rubygem-io-console-0.4.2-1.el6.x86_64.rpm rubygems-devel-2.0.2-1.el6.noarch.rpm \
        rubygem-json-1.7.7-1.el6.x86_64.rpm ruby-irb-2.0.0.433-1.el6.noarch.rpm \
        rubygem-minitest-4.3.2-1.el6.noarch.rpm ruby-libs-2.0.0.433-1.el6.x86_64.rpm \
        rubygem-psych-2.0.0-1.el6.x86_64.rpm ruby-tcltk-2.0.0.433-1.el6.x86_64.rpm \
        ruby-2.0.0.433-1.el6.x86_64.rpm rubygem-rake-0.9.6-1.el6.noarch.rpm ruby-devel-2.0.0.433-1.el6.x86_64.rpm

     yum install -y opencrowbar-core-2.0-1.noarch.rpm opencrowbar-hadoop-2.0-1.noarch.rpm opencrowbar-openstack-2.0-1.noarch.rpm
     
     exit 0

The above script will install OpenCrowbar and all its RPM dependencies up to the point of readiness to actually initialize the Postgresql OpenCrowbar database, and starting up of the OpenCrowbar web server.

## Enable WebUI / Connect via browser

Execute the following command to install the ruby gem bundler:

     #> gem install bundler

Execute the following commands to ready the system for execution of the OpenCrowbar webUI:

     #> cd /opt/opencrowbar/core/rails
     #> bundle install --verbose 

Execute the following for a DEVELOPMENT invocation of OpenCrowbar:

     #> cd /opt/opencrowbar/core
     #> ./development.sh

When ready to deploy a production invocation of OpenCrowbar, execute:

     #> cd /opt/opencrowbar/core
     #> ./production.sh 

Connect to the IP address of the Admin node on port 3000 using a browser of choice (Google Chrome, or Internet Explorer) URL:http://10.208.64.85:3000
     Log in as user: crowbar
     Password: crowbar


## QA Valdiation Requirements:
Ok. So if the above was followed sequentually it is safe to assume that OpenCrowbar was found to be operational.  So what next?

The OpenCrowbar RPM packages are designed to be capable of:

### Removal and Re-installation

There exist RPM packages for OpenCrowbar for the following components:  core (essential), hardware, hadoop, openstack, and later on ceph.

The OpenCrowbar RPMS have dependencies built in.  This means that when they are installed using the yum tool, all pre-requesite RPM packages will automatically be installed before the opencrowbar-core  RPM is installed.

Additionally, the opencrowbar-openstack, opencrowbar-hadoop, and opencrowbar-hardware RPM packages depend on opencrownbar-core. When the opencrowbar-core RPM is removed using the yum tool, the packages that depend on it will also be removed.

Removal and installation dependencies need to be validated.  During the build process the triggers that drive the correct behavior can get disrupted. When that happens it is important that the cause be identified and corrected.

#### Suggested validation steps:

  1. Remove freshly installed RPMS:

     #> yum erase -y opencrowbar-core

     All opencrowbar RPMs should be autoamtically removed.

  2. Re-install the RPMS:

     #> yum install opencrowbar-openstack-2.0-1.noarch.rpm

     The opencrowbar-core and the opencrowbar-openstack RPMS should BOTH be automatically installed.

  3. Operate the webUI, then remove all RPMS:

     Operate the webUI following installation of the RPMS, then remove then as follows:

     #> rpm -e opencrowbar-core

     The RPM tools should complain that other RPM packages depend on this package.  Removal should be refused.

     #> rpm e opencrowbar-openstack

     This should remove only the opencrowbar-openstack RPM package.

     #> yum erase -y opencrowbar-core

     This should succeed, together with removal of all opencrowbar component RPM packages.


#### Updating (not Upgrading)

    The procedure to test this will be developed when the first versioned RPMs become available.

### Known Limitations:

Please document all limitations that are discovered into this document.

RPM package installation/removal/update/upgrade processes confer many known limitations on third-party application-layer services such as OpenCrowbar, OpenStack, Hadoop. Here are a few issues that need to be defined and addressed:

  1. There is a latent need to document update and upgrade requirements and dependencies so that packaging methods can fully accommodate the scope of these so far as possible.

  2. The impact of RPM package updates on service continuity must be clearly defined. User-oriented documentation should set appropriate expectations for RPM update application.
Risks to continuity of service, potential for loss of critical operational data needs to be identifies and documented.

  3. Testing, validation and QA requirements for OpenCrowbar itself need to be documented separately and links to these documents should be inserted into this document.
