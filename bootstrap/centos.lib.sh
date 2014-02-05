#!/bin/bash
install_ruby() (

TMPDIR=/tmp/work
RPMBUILD=$HOME/rpmbuild
RUBYVER=ruby-2.0.0
PKGTGT=$HOME/Ruby

die () {
    echo $1
    exit -1
}

    [[ -f /etc/sysconfig/i18n ]] || echo "LANG=$LANG" >/etc/sysconfig/i18n
    if [[ ! -x /usr/bin/ruby ]]; then
        yum -y upgrade
        yum -y install http://mirrors.servercentral.net/fedora/epel/6/i386/epel-release-6-8.noarch.rpm || :
        yum -y install gcc-c++ patch readline readline-devel zlib zlib-devel \
            libyaml-devel libffi-devel openssl-devel make which \
            install bzip2 autoconf automake libtool bison iconv-devel curl
        yum -y install ruby ruby-devel rubygems
    fi
    [[ -L /dev/fd ]] || ln -sf /proc/self/fd /dev/fd

    # Make sure we have needed ruby source files handy
    if [[ -f "bootstrap/centos-ruby-src-files.sh" ]]; then
        STUFF="bootstrap/centos-ruby-src-files.sh"
    elif [[ -f "centos-ruby-src-files.sh" ]]; then
        STUFF="centos-ruby-src-files.sh"
    else
        die "Can't find src files needed to build ruby-2.0.0 RPMs"
    fi

    # Identify present location so we can return to it, create temp directory
    PWD=`pwd` && mkdir -p $TMPDIR

    # Prep destinfo, pull down ruby sources, create clean tarball
    cd $TMPDIR && git clone https://github.com/ruby/ruby
    cd ruby && git checkout origin/ruby_2_0_0
    RUBYPL=`grep "^#define RUBY_PATCHLEVEL " version.h | awk '{print $3}'`
    cd .. && mv ruby $RUBYVER-p$RUBYPL

    # Now create the pristine tarball
    tar cjf $RUBYVER-p$RUBYPL.tar.bz2 $RUBYVER-p$RUBYPL

    # Create build tree, move ruby tarball into it, clean up mess
    [[ -d $RPMBUILD ]] || mkdir -p $RPMBUILD/{SPECS,SOURCES} 
    [[ -d $RPMBUILD/noarch ]] && rm -rf $RPMBUILD/noarch
    [[ -d $RPMBUILD/x86_64 ]] && rm -rf $RPMBUILD/x86_64
    mv $RUBYVER-p$RUBYPL.tar.bz2 $RPMBUILD/SOURCES/
    cd $PWD && rm -rf $TMPDIR

    . $STUFF

    # Now check we are ready to go, then build the ruby packages and clean up
    cd ../SPECS
    grep $RUBYPL ruby.spec
    [[ $? ]] || die "Ruby patchlevel substitution did not validate."
    rpmbuild -ba --clean ruby.spec
    [[ $? ]] || die "Ruby RPM Build failed"
    CHKFILE=`ls $RPMBUILD/RPMS/x86_64/ruby-2.0.0*`
    [[ $CHKFILE ]] || die "Can't find ruby-2.0.0 RPM - something went wrong!"

    # Now move the built packages into the $PKGTGT directory, then clean up.
    [[ -d $PKGTGT ]] || mkdir -p $PKGTGT
    cd $RPMBUILD/RPMS
    ( cd noarch; mv * $PKGTGT/ ) && ( cd x86_64; mv * $PKGTGT/ )
    rm -rf $RPMBUILD
    cd $PKGTGT
    
    # Remove installed ruby RPMS
    yum -y delete ruby ruby-devel rubygems
    # Install freshly built ruby-2.0.0 RPMS
    yum install ruby ruby-devel rubygem-bigdecimal rubygem-io-console rubygem-json \
        rubygem-psych ruby-libs 

exit 0

)
