Basic Docker Usage
===================

We are going to learn the following stuff:

* How to run docker commands and get help?
* How to obtain docker Image, what are they and how they work?
* How to run an image and look inside?
* How to stop container, remove container? How to remove image?
* How to commit a container so it becomes an image?


To see details about Docker installation type:

	docker info
	docker version


Docker uses Git for versioning of Container layers and Go as a runtime and programming language.

--------

To get help on any docker commands run:

	docker *command* -h

--------

To search for containers in the Docker registry use:

	docker search *<name-of-container>*

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
	

	docker rmi *<image-name>*


--------

To start a container in interactive mode use:

	docker run -i -t busybox




