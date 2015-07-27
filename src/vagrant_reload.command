#!/bin/bash -x

#  vagrant_up.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

export PATH=/usr/local/bin

#
function pause(){
read -p "$*"
}

cd ~/coreos-k8s-solo/kube
machine_status=$(vagrant status | grep -o -m 1 'poweroff\|not created')

if [ "$machine_status" = "poweroff" ]
then
    echo " "
    echo "CoreOS Kubernetes Solo VM is not running !!!"
    pause 'Press [Enter] key to continue...'
elif [ "$machine_status" = "not created" ]
then
    echo " "
    echo "CoreOS Kubernetes Solo VM is not created !!!"
    pause 'Press [Enter] key to continue...'
else
    cd ~/coreos-k8s-solo/kube
    vagrant reload

    # path to the bin folder where we store our binary files
    export PATH=${HOME}/coreos-k8s-solo/bin:$PATH

    # set etcd endpoint
    export ETCDCTL_PEERS=http://172.19.17.99:2379
    echo "etcd cluster:"
    etcdctl --no-sync ls /
    echo " "

    # set fleetctl endpoint
    export FLEETCTL_ENDPOINT=http://172.19.17.99:2379
    export FLEETCTL_DRIVER=etcd
    export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
    echo "fleetctl list-machines:"
    fleetctl list-machines
    echo " "
    echo "fleetctl list-units:"
    fleetctl list-units
    echo " "

    # set kubernetes master
    export KUBERNETES_MASTER=http://172.19.17.99:8080
    echo "kubectl get nodes:"
    kubectl get nodes
    echo " "

    echo " "
    echo "CoreOS Kubernetes Solo was reloaded !!!"
    echo " "
    pause 'Press [Enter] key to continue...'

fi
