#!/bin/bash

#  download_k8s.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 01/04/2014.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

function pause(){
read -p "$*"
}

rm -f kubectl
rm -f *.tgz

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
echo "Downloading kubectl $K8S_VERSION for OS X"
../wget https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/darwin/amd64/kubectl
chmod 755 kubectl

# download latest version of k8s binaries for CoreOS
# kube
../wget -N -P ./kube https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-apiserver
../wget -N -P ./kube https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-controller-manager
../wget -N -P ./kube https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-scheduler
../wget -N -P ./kube https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubelet
../wget -N -P ./kube https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kube-proxy
../wget -N -P ./kube https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/kubectl
#
LKR=$(curl 'https://api.github.com/repos/kelseyhightower/kube-register/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' "' | cut -c 2-)
../wget -N -O ./kube/kube-register https://github.com/kelseyhightower/kube-register/releases/download/v$LKR/kube-register-$LKR-linux-amd64
tar czvf kube.tgz -C kube .
rm -f ./kube/*

#
echo "Download has finished !!!"
pause 'Press [Enter] key to continue...'
