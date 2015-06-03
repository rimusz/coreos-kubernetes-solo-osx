#!/bin/bash

#  coreos-vagrant.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.


# pass first argument - up, halt ...
cd ~/coreos-k8s-solo/kube
vagrant $1

cd ~/coreos-k8s-solo/workers
vagrant $1
