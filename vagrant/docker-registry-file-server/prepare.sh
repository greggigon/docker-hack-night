#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install wget

echo "Installing Docker now ..."

sudo wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker vagrant

echo "Fetching and setting Up Registry stuff ..."

sudo docker pull registry:latest
sudo docker pull konradkleine/docker-registry-frontend:latest

sudo mkdir -p /var/registry-storage
sudo chown vagrant.vagrant /var/registry-storage

echo "Fetching and setting up File server ..."
sudo docker pull nginx:latest

sudo mkdir -p /var/file-storage
sudo chown vagrant.vagrant /var/file-storage

chmod +x /home/vagrant/bin/file-server
chmod +x /home/vagrant/bin/registry


