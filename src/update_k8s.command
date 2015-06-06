#!/bin/bash

#  update_k8s.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

#
cd ~/coreos-k8s-solo/tmp

# get latest k8s version
function get_latest_version_number {
local -r latest_url="https://storage.googleapis.com/kubernetes-release/release/latest.txt"
if [[ $(which wget) ]]; then
wget -qO- ${latest_url}
elif [[ $(which curl) ]]; then
curl -Ss ${latest_url}
fi
}

K8S_VERSION=$(get_latest_version_number)

# download latest version of kubectl for OS X
cd ~/coreos-k8s-solo/tmp
echo "Downloading kubectl $K8S_VERSION for OS X"
~/coreos-k8s-solo/bin/wget -N -P ~/coreos-k8s-solo/bin https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/darwin/amd64/kubectl
chmod 755 ~/coreos-k8s-solo/bin/kubectl
echo "kubectl was copied to ~/coreos-k8s-solo/bin"
echo " "

# clean up tmp folder
rm -rf ~/coreos-k8s-solo/tmp/*

# download latest version of k8s for CoreOS
echo "Downloading latest version of Kubernetes"
~/coreos-k8s-solo/bin/wget -N -P ~/coreos-k8s-solo/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-apiserver
~/coreos-k8s-solo/bin/wget -N -P ~/coreos-k8s-solo/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-kubeler-manager
~/coreos-k8s-solo/bin/wget -N -P ~/coreos-k8s-solo/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-scheduler
~/coreos-k8s-solo/bin/wget -N -P ~/coreos-k8s-solo/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet
~/coreos-k8s-solo/bin/wget -N -P ~/coreos-k8s-solo/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy
~/coreos-k8s-solo/bin/wget -N -P ~/coreos-k8s-solo/tmp https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
#
LKR=$(curl 'https://api.github.com/repos/kelseyhightower/kube-register/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' "' | cut -c 2-)
~/coreos-k8s-solo/bin/wget -N -O ~/coreos-k8s-solo/tmp/kube-register https://github.com/kelseyhightower/kube-register/releases/download/v$LKR/kube-register-$LKR-linux-amd64
tar czvf kube.tgz *
cp -f kube.tgz ~/coreos-k8s-solo/kube/
# clean up tmp folder
rm -rf ~/coreos-k8s-solo/tmp/*
echo " "

# install k8s files
echo "Installing latest version of Kubernetes ..."
cd ~/coreos-k8s-solo/kube
vagrant scp kube.tgz /home/core/
vagrant ssh k8solo-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/kube.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* "
echo "Done with k8solo-01 "
echo " "

# restart fleet units
echo "Restarting fleet units:"
# set fleetctl tunnel
export FLEETCTL_ENDPOINT=http://172.19.17.99:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
cd ~/coreos-k8s-solo/fleet
~/coreos-k8s-solo/bin/fleetctl stop *.service
sleep 5
~/coreos-k8s-solo/bin/fleetctl start *.service
#
sleep 8
echo " "
echo "fleetctl list-units:"
~/coreos-k8s-solo/bin/fleetctl list-units
echo " "

# set kubernetes master
export KUBERNETES_MASTER=http://172.19.17.99:8080
echo Waiting for Kubernetes cluster to be ready. This can take a few minutes...
spin='-\|/'
i=1
until ~/coreos-k8s-solo/bin/kubectl version | grep 'Server Version' >/dev/null 2>&1; do printf "\b${spin:i++%${#sp}:1}"; sleep .1; done
i=0
until ~/coreos-k8s-solo/bin/kubectl get nodes | grep 172.19.17.99 >/dev/null 2>&1; do i=$(( (i+1) %4 )); printf "\r${spin:$i:1}"; sleep .1; done
echo " "
#
echo " "
echo "k8s nodes list:"
~/coreos-k8s-solo/bin/kubectl get nodes
echo " "


echo "Kubernetes update has finished !!!"
pause 'Press [Enter] key to continue...'

