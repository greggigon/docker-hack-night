#!/bin/bash

mkdir -p ~/tmp
cd ~/tmp

sudo apt-get -y purge docker.io
sudo wget -qO- https://get.docker.com/ | sh

sudo usermod -aG docker vagrant

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