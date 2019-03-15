#!/bin/bash
set -e

apt-get install -y apt-transport-https ca-certificates sudo 

if ! [ -x "$(command -v apt-add-repository)" ]; then 
    sudo apt-get --assume-yes update 
    sudo apt-get install --assume-yes software-properties-common
fi

if ! [ -x "$(command -v ansible)" ]; then
    sudo apt-add-repository -y ppa:ansible/ansible
    sudo apt-add-repository -y ppa:git-core/ppa
    sudo apt-get update
    sudo apt-get --assume-yes upgrade
    sudo apt-get --assume-yes install ansible
    sudo apt-get --assume-yes install git
fi

ansible-playbook ubuntu.yml -i hosts -vvv