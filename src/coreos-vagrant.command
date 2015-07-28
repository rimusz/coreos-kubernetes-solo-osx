#!/bin/bash

#  coreos-vagrant.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

export PATH=/usr/local/bin

# pass first argument - up, halt ...
cd ~/coreos-k8s-solo/kube
vagrant $1
