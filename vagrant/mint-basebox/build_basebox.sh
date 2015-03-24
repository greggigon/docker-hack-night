#!/bin/bash

echo "Building the VM first ..."
vagrant up

echo "Stopping the box now ..."
vagrant halt

echo "Packaging box ..."
vagrant package --base LinuxMint\ Basebox --output linux_mint_with_docker_base.box

