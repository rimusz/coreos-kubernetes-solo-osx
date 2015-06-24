#!/bin/bash

#  coreos-vagrant.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# overwrite for OS X 10.11
vagrant=/usr/local/bin/vagrant

# pass first argument - up, halt ...
cd ~/coreos-k8s-solo/kube
$vagrant $1
