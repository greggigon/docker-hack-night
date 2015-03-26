#!/bin/bash

IP=$(ifconfig eth1 | awk '/inet addr/{print substr($2,6)}')

echo "Pull the base containers that people would be using ..."
 
if ! grep -q 0.0.0.0 "/etc/default/docker" ; then
   	sudo service docker stop
	sudo sh -c "echo 'DOCKER_OPTS=\"--insecure-registry 0.0.0.0/0\"' > /etc/default/docker"
	sudo service docker start
	sleep 5
else
	echo "Docker settings already modified ... MOVING ON!"
fi

echo "-> Getting Busybox base container ..."
docker pull busybox:latest
docker tag busybox:latest $IP:5000/hack/busybox:latest
docker push $IP:5000/hack/busybox:latest
docker rmi $IP:5000/hack/busybox:latest

echo "-> Getting Ubuntu base container ..."
docker pull ubuntu:14.10
rm -rf ~/tmp/ubuntu-image
mkdir -p ~/tmp/ubuntu-image
cp /vagrant/ubuntu-image/Dockerfile ~/tmp/ubuntu-image
cd ~/tmp/ubuntu-image
docker build -t $IP:5000/hack/ubuntu:14.10 .

docker push $IP:5000/hack/ubuntu:14.10
docker rmi $IP:5000/hack/ubuntu:14.10

echo "-> Getting Wordpress base container ..."
docker pull wordpress:latest
docker tag wordpress:latest $IP:5000/hack/wordpress:latest
docker push $IP:5000/hack/wordpress:latest
docker rmi $IP:5000/hack/wordpress:latest

echo "-> Getting MySQL container ..."
docker pull mysql:latest
docker tag mysql:latest $IP:5000/hack/mysql:latest
docker push $IP:5000/hack/mysql:latest
docker rmi $IP:5000/hack/mysql:latest

echo "Now copying the files ..."

rm -rf /var/file-storage/*
cp -R /vagrant/files/ /var/file-storage/
chown -R vagrant.vagrant /var/file-storage/