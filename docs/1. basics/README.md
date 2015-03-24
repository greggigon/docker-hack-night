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

	docker info
	docker version


Docker uses Git for versioning of Container layers and Go as a runtime and programming language.

--------

To get help on any docker commands run:

	docker *command* -h

### Getting images

To search for containers in the Docker registry use:

	docker search <name-of-container>

--------

To get a container from Docker registry use:

	docker pull container-name


If you are about to use unoficial and non-public Docker repository, you'll need to specify the container name in the for of:

	docker pull hostname:port/repository/container:version


''' Let's pull BusyBox as a base container and use that one for some testing'''

	docker pull busybox


To see what Images are downloaded use:

	docker images


To remove images:
	

	docker rmi <image-name>


### Running/Stopping container

To start a container in interactive mode use:

	docker run -i -t busybox

To see what containers are running use:

	docker ps [-a] - where -a lists all containers, running and stopped

--------
To run container detached from terminal:

	docker run -d --name my-name busybox

To stop container:

	docker stop my-name [container-id] - you can use container ID or a generated name. 

You can find that bu listing containers with *docker ps*.

--------

To remove a container use:

	docker rm <name or id>

Container will not be removed if it is still running. Docker will tell you about that.

### Persisting containers

To commit container use:

	docker commit <name or id> [REPOSITORY:TAG]
	docker commit my-name greg/container:latest

You can also TAG a container if you need to (useful with multiple versions).



