#!/bin/bash

#  vagrant_up.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 01/12/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# Add vagrant ssh key to ssh-agent
ssh-add ~/.vagrant.d/insecure_private_key >/dev/null 2>&1

# get App's Resources folder
res_folder=$(cat ~/coreos-k8s-solo/.env/resouces_path)

# path to the bin folder where we store our binary files
export PATH=${HOME}/coreos-k8s-solo/bin:$PATH

# set etcd endpoint
export ETCDCTL_PEERS=http://172.19.17.99:4001

# set fleetctl endpoint
export FLEETCTL_ENDPOINT=http://172.19.17.99:4001
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
#

# set kubernetes master
export KUBERNETES_MASTER=http://172.19.17.99:8080
#

cd ~/coreos-k8s-solo/kube
machine_status=$(vagrant status | grep -o -m 1 'not created')

if [ "$machine_status" = "not created" ]
then
    # copy files needed for the App
    # copy gsed to ~/coreos-k8s-solo/bin
    cp -f "${res_folder}"/gsed ~/coreos-k8s-solo/bin
    chmod 755 ~/coreos-k8s-solo/bin/gsed
    # copy wget with https support to ~/coreos-k8s-solo/bin
    cp -f "${res_folder}"/wget ~/coreos-k8s-solo/bin
    chmod 755 ~/coreos-k8s-solo/bin/wget
    # copy fleet units
    cp -Rf "${res_folder}"/fleet/ ~/coreos-k8s-solo/fleet

    #
    vagrant box update
    vagrant up --provider virtualbox
    #
    cd ~/coreos-k8s-solo/workers
    vagrant box update
    vagrant up --provider virtualbox

    # install k8s files on master
    echo " "
    echo "Installing k8s files to master and nodes:"
    cd ~/coreos-k8s-solo/kube
    vagrant scp master.tgz /home/core/
    vagrant ssh k8solo-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/master.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* && ls -alh /opt/bin " >/dev/null 2>&1

    # install k8s files on nodes
    cd ~/coreos-k8s-solo/workers
    vagrant scp nodes.tgz /home/core/
    #
    vagrant ssh k8snode-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* && ls -alh /opt/bin " >/dev/null 2>&1
    vagrant ssh k8snode-02 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/nodes.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* && ls -alh /opt/bin " >/dev/null 2>&1
    echo "Done installing ... "

    # install fleet units
    echo " "
    echo "Installing fleet units:"
    # copy fleet units
    rm -f ~/coreos-k8s-solo/fleet/*
    cp -fR "$res_folder"/fleet/ ~/coreos-k8s-solo/fleet
    cd ~/coreos-k8s-solo/fleet
    fleetctl start *.service
    echo " "
    #
    echo Waiting for Kubernetes cluster to be ready. This can take a few minutes...
    spin='-\|/'
    i=0
    until ~/coreos-k8s-solo/bin/kubectl version | grep 'Server Version' >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
    i=0
    until ~/coreos-k8s-solo/bin/kubectl get nodes | grep 172.17.15.102 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
    i=0
    until ~/coreos-k8s-solo/bin/kubectl get nodes | grep 172.17.15.103 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
    echo " "
    # attach label to the nodes
    ~/coreos-k8s-solo/bin/kubectl label nodes 172.17.15.102 node=worker1
    ~/coreos-k8s-solo/bin/kubectl label nodes 172.17.15.103 node=worker2
    echo " "
else
    # start kube
    vagrant up
    #
    ~/coreos-k8s-solo/bin/fleetctl stop ~/coreos-k8s-solo/fleet/kubernetes-ui.service
    ~/coreos-k8s-solo/bin/fleetctl destroy ~/coreos-k8s-solo/fleet/kubernetes-ui.service
    rm -f ~/coreos-k8s-solo/fleet/kubernetes-ui.service
    # start nodes 
    cd ~/coreos-k8s-solo/workers
    vagrant up
fi


#
echo "etcd cluster:"
etcdctl --no-sync ls /
echo ""
#
echo "fleetctl list-machines:"
fleetctl list-machines
echo " "
#
echo "fleetctl list-units:"
fleetctl list-units
echo " "
#
echo "kubectl get nodes:"
kubectl get nodes
echo " "

cd ~/coreos-k8s-solo/kubernetes

# open bash shell
/bin/bash
