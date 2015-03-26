Basic Docker Usage
===================

We are going to learn the following stuff:

* How to run docker commands and get help?
* How to obtain docker Image, what are they and how they work?
* How to run an image and look inside?
* How to stop container, remove container? How to remove image?
* How to commit a container so it becomes an image?

### Very basic stuff

To see details about Docker installation type:

	$ docker info
	$ docker version


Docker uses Git for versioning of Container layers and Go as a runtime and programming language.

--------

To get help on any docker commands run:

	$ docker <command> -h

### Getting images

To search for containers in the Docker registry use:

	$ docker search <name-of-container>

--------

To get a container from Docker registry use:

	$ docker pull container-name


If you are about to use unofficial and non-public Docker repository, you'll need to specify the container name in the form of:

	$ docker pull hostname:port/repository/container:version


> Let's pull BusyBox as a base container and use that one for some testing


	$ docker pull @:busybox


To see what Images are downloaded use:

	$ docker images


To remove images:
	

	$ docker rmi <image-name>


### Running/Stopping container

To start a container in interactive mode use:

	$ docker run -i -t busybox

To see what containers are running use:

	$ docker ps [-a]

where `-a` lists all containers, running and stopped

--------
To run container detached from terminal:

	$ docker run -d --name my-name busybox

To stop container:

	$ docker stop my-name|container-id

you can use container ID or a generated name. 

You can find that buy listing containers with `docker ps`.

--------

To remove a container use:

	$ docker rm name|id

Container will not be removed if it is still running. Docker will tell you about that.

### Persisting containers

To commit container use:

	$ docker commit name|id [REPOSITORY:TAG]
	$ docker commit my-name greg/container:latest

You can also TAG a container if you need to (useful with multiple versions).


## Creating our own container

We are going to use **Ubuntu** base image as our base container.
Pull the Ubuntu image from the registry first. *(If you don't remember how to do it, look up :) )*

Now we are going to put some useful stuff in that container:

	$ docker run -it ubuntu:14.10 /bin/bash

----------

Let's get that simple HTTP Implementation somewhere:

    $ mkdir -p /opt/simple-http-server
    $ wget http://FILE-SERVER:PORT/1. basics/simple_http_server.py -O /opt/simple-http-server/simple_http_server.py
	
	$ cat << EOF > /opt/simple-http-server/index.html
	<html><body><h1>Hello world!</h1></body></html>
	EOF
	
And we also need a script that will start this server for us in the container:

	$ cat << EOF > /bin/run-simple-server
	#!/bin/bash
	python /opt/simple-http-server/simple_http_server.py
	EOF
	$ chmod +x /bin/run-simple-server

You can also simply edit/create those files in the container with nano or vim.


----------

Once you are happy with the container, exit, commit and start it by running:

	$ docker run -d simple-http-server /bin/run-simple-server


----------

This should conclude basic usage and we can navigate to [2. Networking](../2.%20networking/)

