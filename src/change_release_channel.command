#!/bin/bash

#  change_release_channel.command
#  CoreOS Kubernetes Solo for OS X
#
#  Created by Rimantas on 03/06/2015.
#  Copyright (c) 2014 Rimantas Mocevicius. All rights reserved.

# get App's Resources folder
res_folder=$(cat ~/coreos-k8s-solo/.env/resouces_path)

### Set release channel
LOOP=1
while [ $LOOP -gt 0 ]
do
    VALID_MAIN=0
    echo " "
    echo "Set CoreOS Release Channel:"
    echo " 1)  Alpha "
    echo " 2)  Beta "
    echo " 3)  Stable "
    echo " "
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

function pause(){
read -p "$*"
}

#
echo "The 'config.rb' file was updated to $channel channel !!!"
echo "You need to run 'Destroy k8s Solo (vagrant destroy)' and then"
echo "on next 'Up' new cluster will be created !!!"
pause 'Press [Enter] key to continue...'

