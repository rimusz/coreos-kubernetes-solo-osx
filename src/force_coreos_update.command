#!/bin/bash

#  force_coreos_update.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

cd ~/coreos-k8s-solo/kube
vagrant up
vagrant ssh k8solo-01 -c "sudo update_engine_client -update"
echo "Done with k8solo-01 "
echo " "

echo "Update has finished !!!"
echo "You need to reboot a machine if CoreOS update was successful"
echo "Just use 'Reload' from the App menu"
pause 'Press [Enter] key to continue...'
