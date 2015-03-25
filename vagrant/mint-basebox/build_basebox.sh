#!/bin/bash

echo "Building the VM first ..."
vagrant up

echo "Stopping the box now ..."
vagrant halt

echo "Packaging box ..."
vagrant package --base LinuxMint\ Basebox --output linux_mint_with_docker_base.box

echo "Moving things around ..."
mkdir -p ../docker-registry-file-server/files/
rm -rf ../docker-registry-file-server/files/linux_mint_with_docker_base.box
mv linux_mint_with_docker_base.box ../docker-registry-file-server/files/