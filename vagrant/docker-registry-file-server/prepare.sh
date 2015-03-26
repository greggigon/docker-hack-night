#!/bin/bash

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install wget

echo "Installing Docker now ..."

sudo wget -qO- https://get.docker.com/ | sh
sudo usermod -aG docker vagrant

echo "Fetching and setting Up Registry stuff ..."

docker pull registry:latest
docker pull konradkleine/docker-registry-frontend:latest

sudo mkdir -p /var/registry-storage
sudo chown vagrant.vagrant /var/registry-storage

echo "Fetching and setting up File server ..."
docker pull nginx:latest

sudo mkdir -p /var/file-storage
sudo chown vagrant.vagrant /var/file-storage

chmod +x /home/vagrant/bin/file-server
chmod +x /home/vagrant/bin/registry


docker pull google/cadvisor:latest
docker run \
		  --volume=/:/rootfs:ro \
		  --volume=/var/run:/var/run:rw \
		  --volume=/sys:/sys:ro \
		  --volume=/var/lib/docker/:/var/lib/docker:ro \
		  --publish=8085:8080 \
		  --detach=true \
		  --name=cadvisor \
		  --restart=always \
		  google/cadvisor:latest

source /home/vagrant/bin/registry
source /home/vagrant/bin/file-server

echo "Done ..."



