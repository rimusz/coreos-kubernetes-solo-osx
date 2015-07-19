#!/bin/bash

#  first-init.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# get App's Resources folder
res_folder=$(cat ~/coreos-k8s-solo/.env/resouces_path)

echo " "
echo Installing Kubernetes Solo ...
echo " "
# install vagrant scp plugin
vagrant plugin install vagrant-scp

### getting files from github and setting them up
echo ""
echo "Downloading latest coreos-vagrant files from github to tmp folder: "
git clone https://github.com/coreos/coreos-vagrant.git ~/coreos-k8s-solo/tmp
echo "Done downloading from github !!!"
echo ""

# copy Vagrantfile
cp ~/coreos-k8s-solo/tmp/Vagrantfile ~/coreos-k8s-solo/kube/Vagrantfile

# change k8solo-01 IP to static
sed -i "" 's/172.17.8.#{i+100}/172.19.17.99/g' ~/coreos-k8s-solo/kube/Vagrantfile

# config.rb files
# kube
cp ~/coreos-k8s-solo/tmp/config.rb.sample ~/coreos-k8s-solo/kube/config.rb
sed -i "" 's/#$instance_name_prefix="core"/$instance_name_prefix="k8solo"/' ~/coreos-k8s-solo/kube/config.rb
sed -i "" 's/#$vm_memory = 1024/$vm_memory = 1536/' ~/coreos-k8s-solo/kube/config.rb
###

### Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo "Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo "Select an option:"

    read RESPONSE
    XX=${RESPONSE:=Y}

    if [ $RESPONSE = 1 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-solo/kube/config.rb
        sed -i "" "s/channel='stable'/channel='alpha'/" ~/coreos-k8s-solo/kube/config.rb
        sed -i "" "s/channel='beta'/channel='alpha'/" ~/coreos-k8s-solo/kube/config.rb
        channel="Alpha"
        LOOP=0
    fi

    if [ $RESPONSE = 2 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-solo/kube/config.rb
        sed -i "" "s/channel='alpha'/channel='beta'/" ~/coreos-k8s-solo/kube/config.rb
        sed -i "" "s/channel='stable'/channel='beta'/" ~/coreos-k8s-solo/kube/config.rb
        channel="Beta"
        LOOP=0
    fi

    if [ $RESPONSE = 3 ]
    then
        VALID_MAIN=1
        sed -i "" 's/#$update_channel/$update_channel/' ~/coreos-k8s-solo/kube/config.rb
        sed -i "" "s/channel='alpha'/channel='stable'/" ~/coreos-k8s-solo/kube/config.rb
        sed -i "" "s/channel='beta'/channel='stable'/" ~/coreos-k8s-solo/kube/config.rb
        channel="Stable"
        LOOP=0
    fi

    if [ $VALID_MAIN != 1 ]
    then
        continue
    fi
done
### Set release channel

#
function pause(){
read -p "$*"
}

# first up to initialise VMs
echo " "
echo "Setting up Vagrant VM for CoreOS Kubernetes Solo on OS X"
cd ~/coreos-k8s-solo/kube
vagrant box update
vagrant up --provider virtualbox

# Add vagrant ssh key to ssh-agent
ssh-add ~/.vagrant.d/insecure_private_key >/dev/null 2>&1

echo " "
echo " Installing k8s files to k8solo-01:"
cd ~/coreos-k8s-solo/kube
vagrant scp kube.tgz /home/core/
vagrant ssh k8solo-01 -c "sudo /usr/bin/mkdir -p /opt/bin && sudo tar xzf /home/core/kube.tgz -C /opt/bin && sudo chmod 755 /opt/bin/* " >/dev/null 2>&1
echo "Done installing ... "
echo " "

# download etcdctl and fleetctl
#
cd ~/coreos-k8s-solo/kube
LATEST_RELEASE=$(vagrant ssh k8solo-01 -c "etcdctl --version" | cut -d " " -f 3- | tr -d '\r' )
cd ~/coreos-k8s-solo/bin
echo "Downloading etcdctl $LATEST_RELEASE for OS X"
curl -k -L -o etcd.zip "https://github.com/coreos/etcd/releases/download/v$LATEST_RELEASE/etcd-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "etcd.zip" "etcd-v$LATEST_RELEASE-darwin-amd64/etcdctl" >/dev/null 2>&1
rm -f etcd.zip
echo " "

#
cd ~/coreos-k8s-solo/kube
LATEST_RELEASE=$(vagrant ssh k8solo-01 -c 'fleetctl version' | cut -d " " -f 3- | tr -d '\r')
cd ~/coreos-k8s-solo/bin
echo "Downloading fleetctl v$LATEST_RELEASE for OS X"
curl -k -L -o fleet.zip "https://github.com/coreos/fleet/releases/download/v$LATEST_RELEASE/fleet-v$LATEST_RELEASE-darwin-amd64.zip"
unzip -j -o "fleet.zip" "fleet-v$LATEST_RELEASE-darwin-amd64/fleetctl" >/dev/null 2>&1
rm -f fleet.zip
echo " "

# set etcd endpoint
export ETCDCTL_PEERS=http://172.19.17.99:2379
echo "etcd cluster:"
~/coreos-k8s-solo/bin/etcdctl ls /
echo " "

# set fleetctl tunnel
export FLEETCTL_ENDPOINT=http://172.19.17.99:2379
export FLEETCTL_DRIVER=etcd
export FLEETCTL_STRICT_HOST_KEY_CHECKING=false
echo "fleetctl list-machines:"
~/coreos-k8s-solo/bin/fleetctl list-machines
echo " "
#
echo "Installing fleet units from '~/coreos-k8s-solo/fleet' folder:"
cd ~/coreos-k8s-solo/fleet
~/coreos-k8s-solo/bin/fleetctl submit *.service
~/coreos-k8s-solo/bin/fleetctl start *.service
echo "Finished installing fleet units"
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
# attach label to the node
~/coreos-k8s-solo/bin/kubectl label nodes 172.19.17.99 node=worker1
#
echo " "
echo "Installing SkyDNS ..."
~/coreos-k8s-solo/bin/kubectl create -f ~/coreos-k8s-solo/kubernetes/skydns-rc.yaml
~/coreos-k8s-solo/bin/kubectl create -f ~/coreos-k8s-solo/kubernetes/skydns-svc.yaml
# clean up kubernetes folder
rm -f ~/coreos-k8s-solo/kubernetes/skydns-rc.yaml
rm -f ~/coreos-k8s-solo/kubernetes/skydns-svc.yaml
#
echo " "
echo "Installing Kubernetes UI ..."
~/coreos-k8s-solo/bin/kubectl create -f ~/coreos-k8s-solo/kubernetes/kube-ui-rc.yaml
~/coreos-k8s-solo/bin/kubectl create -f ~/coreos-k8s-solo/kubernetes/kube-ui-svc.yaml
# clean up kubernetes folder
rm -f ~/coreos-k8s-solo/kubernetes/kube-ui-rc.yaml
rm -f ~/coreos-k8s-solo/kubernetes/kube-ui-svc.yaml

#
echo " "
echo "kubectl get nodes:"
~/coreos-k8s-solo/bin/kubectl get nodes
echo " "

#
echo " "
echo "Installation has finished, CoreOS VM and Kubernetes are up and running !!!"
echo "Enjoy Kubernetes Solo on your Mac !!!"
echo " "
echo "Run from menu 'OS Shell' to open a terninal window with fleetctl, etcdctl and kubectl preset to master's IP!!!"
echo " "
pause 'Press [Enter] key to continue...'
