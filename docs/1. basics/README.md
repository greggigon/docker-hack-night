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

However, we are probably not going to use anything out of the Publis Registry at the moment and Internet connectivity is a must.

--------

To list the images use:

	$ docker images

You should see something like this bellow:

	vagrant@master ~ $ docker images
	REPOSITORY                  TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
	openshift/hello-openshift   latest              888ef8844e41        38 hours ago        5.62 MB
	openshift/origin-pod        latest              6729bd19d4b7        38 hours ago        957.9 kB
	wordpress                   latest              b66a24c3ebca        8 days ago          451.4 MB
	ubuntu                      14.10               59a878f244f6        9 days ago          194.4 MB
	ubuntu                      utopic              59a878f244f6        9 days ago          194.4 MB
	ubuntu                      utopic-20150319     59a878f244f6        9 days ago          194.4 MB
	mysql                       latest              e93afb6a83e9        9 days ago          282.8 MB
	openshift/origin            v0.4.1              72d0794e4db3        2 weeks ago         496.3 MB
	google/cadvisor             0.10.1              6a46ed29e869        4 weeks ago         18.03 MB
	google/cadvisor             latest              6a46ed29e869        4 weeks ago         18.03 MB
	busybox                     latest              4986bf8c1536        12 weeks ago        2.433 MB


--------


To remove images (but don't do it, we'll need them in the Hacks):
	

	$ docker rmi <image-name>


### Running/Stopping container

To start a container in interactive mode use:

	$ docker run -i -t busybox

Press `Ctrl-D` to exit

To see what containers are running use:

	$ docker ps

Add `-a` to list all containers, running and stopped

--------
To run container detached from terminal:

	$ docker run -d --name my-name busybox sleep 300

Docker will return an ID that you can use to refer to the running container. 

To stop the container:

	$ docker stop my-name|container-id

you can use container ID or the generated or assigned name.  You can always find the ID or name using `docker ps`.

--------

To remove a container use:

	$ docker rm name|id

Container will not be removed if it is still running. Docker will tell you about that.

### Persisting containers

To commit container use:

	$ docker commit name|id [REPOSITORY:TAG]
	$ docker commit my-name greg/container:latest

You can also TAG a container if you need to (useful with multiple versions).


## Running your first container

We are going to use **Ubuntu** base image as our base container running a simple command.

```
$ docker run ubuntu:14.10 /bin/echo "Hello World"
Hello World
```

What just happened?  The Docker client told the Docker daemon to create a container using the ubuntu:14.10 image and to run the command /bin/echo with the arguments "Hello World" within that container.

## Creating our own container

Now we are going to put some useful stuff in that container:

	$ docker run -it ubuntu:14.10 /bin/bash
	# echo 'Hello YOURNAME!' > index.html

Use `Ctrl-D` to exit.

You can now commit the changes you made to your container.  First get the ID of the last container that exited:

`$ docker ps -al`

Next, commit the image:

`$ docker commit id yourname/helloworld`

Now, we can run our image, this time we're telling python to run a web server to serve the file we created.:

`$ docker run -d -p 8000:8000 yourname/helloworld python3 -m http.server`

Test it:

```
$ curl http://localhost:8000
Hello YOURNAME!
```

You've created your first container!   Run `docker images` and you should see it.  We'll see later a better way to build containers.  For now, it's worth noting that on disk our container is only another (very small) layer on top of the existing Ubuntu image which makes Docker very space efficient.

This should conclude basic usage and we can navigate to [2. Networking](../2.%20networking/)