#!/bin/bash

#  download_k8s.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
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

K8S_VERSION=v0.19.0
#$(get_latest_version_number)

# download latest version of kubectl for OS X
echo "Downloading kubectl $K8S_VERSION for OS X"
curl -L https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/darwin/amd64/kubectl > kubectl
chmod a+x kubectl

# download latest version of k8s binaries for CoreOS
bins=( kubectl kubelet kube-proxy kube-apiserver kube-scheduler kube-controller-manager )
for b in "${bins[@]}"; do
    curl -L https://storage.googleapis.com/kubernetes-release/release/$K8S_VERSION/bin/linux/amd64/$b > kube/$b
done

#
LKR=$(curl 'https://api.github.com/repos/kelseyhightower/kube-register/releases' 2>/dev/null|grep -o -m 1 -e "\"tag_name\":[[:space:]]*\"[a-z0-9.]*\""|head -1|cut -d: -f2|tr -d ' "' | cut -c 2-)
curl -L https://github.com/kelseyhightower/kube-register/releases/download/v$LKR/kube-register-$LKR-linux-amd64 > kube/kube-register
chmod a+x kube/*
tar czvf kube.tgz -C kube .
rm -f kube/*

#
echo "Download has finished !!!"
pause 'Press [Enter] key to continue...'
