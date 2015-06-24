#!/bin/bash

#  coreos-vagrant-install.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# create symbolic link for vagrant to work on OS X 10.11
ln -s /opt/vagrant/bin/vagrant /usr/local/bin/vagrant >/dev/null 2>&1

# create in "coreos-k8s-solo" all required folders and files at user's home folder where all the data will be stored
    mkdir ~/coreos-k8s-solo/tmp
    mkdir ~/coreos-k8s-solo/bin
    mkdir ~/coreos-k8s-solo/fleet
    mkdir ~/coreos-k8s-solo/kubernetes
    mkdir -p ~/coreos-k8s-solo/kube

    # cd to App's Resources folder
    cd "$1"

    # copy gsed to ~/coreos-k8s-solo/bin
    cp "$1"/gsed ~/coreos-k8s-solo/bin
    chmod 755 ~/coreos-k8s-solo/bin/gsed

    # copy wget with https support to ~/coreos-k8s-solo/bin
    cp "$1"/wget ~/coreos-k8s-solo/bin
    chmod 755 ~/coreos-k8s-solo/bin/wget

    # copy other files
    # user-data files
    cp "$1"/Vagrantfiles/user-data ~/coreos-k8s-solo/kube/user-data

    # copy k8s files
    cp "$1"/k8s/kubectl ~/coreos-k8s-solo/bin
    chmod 755 ~/coreos-k8s-solo/bin/kubectl

    # linux binaries
    cp "$1"/k8s/kube.tgz ~/coreos-k8s-solo/kube

    # copy fleet units
    cp -R "$1"/fleet/ ~/coreos-k8s-solo/fleet

    # initial init
    open -a iTerm.app "$1"/first-init.command
