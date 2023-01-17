#!/bin/bash
sudo snap install nmap
sudo apt update
sudo apt install ansible -y 

cd /vagrant
ansible-playbook -i inventory.yml scripts/ansible/project/main.yml