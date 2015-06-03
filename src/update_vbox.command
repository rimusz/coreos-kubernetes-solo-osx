#!/bin/bash

#  update_vbox.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

#
cd ~/coreos-k8s-solo/kube
vagrant box update
#
cd ~/coreos-k8s-solo/workers
vagrant box update

#
echo "Update has finished !!!"
pause 'Press [Enter] key to continue...'
