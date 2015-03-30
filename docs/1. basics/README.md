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


## Running your first container

We are going to use **Ubuntu** base image as our base container running a simple command.

```
$ docker run ubuntu:14.10 /bin/echo "Hello World"
Hello World
```

What just happened?  The Docker client told the Docker daemon to create a container using the ubuntu:14.10 image and to run the command /bin/echo with the arguments "Hello World" within that container.

## An interactive container

You can create a container that you can interact with:
```
$ docker run -i -t busybox
```

The arguments `-i` keeps STDIN open to the container, `-t` assigns a psuedo-tty so we can creaet an interactive shell.

Once you've started the container you can explore:

```
# hostname
f18854e5bc76
# ps aux
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.4  0.3  18184  3260 ?        Ss   09:41   0:00 /bin/bash
```

Docker has set the hostname to the ID of the container and there is only one process running, /bin/bash, which has PID 1.

Press Ctrl-D to exit the container.

## A daemonised container

More useful than the interactive container is a container that we can use for running applications and services.  For this we need to run the container as a daemon.   Try the following:

```
$ docker run -d ubuntu:14.10 /bin/sh -c "while true; do echo Hello World; sleep 10; done"
56a2aadc7eac192e1ebd88c8c089b6d4ee52f9b791a89733b6cf3fc9e03fd141
```

Adding the `-d` argument tells Docker to run the container as a daemon.  Once it's started Docker returns the (long) container ID.

Use `docker ps` to show the running containers:

```
$ docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED              STATUS              PORTS                    NAMES
56a2aadc7eac        ubuntu:14.10                       "/bin/sh -c 'while t   About a minute ago   Up About a minute                            serene_shockley
```

> *NOTE*: Add `-a` to `docker ps` to list all containers, running and stopped

Here you can see the container ID, the image used, the command, any ports that have been exposed and the current status.  Docker also assigns a random name to each container, *serene_shockley*, which can be used instead of the container ID.  We'll see later how to assign our own names.

```
$ docker logs serene_shockley
Hello World
Hello World
Hello World
Hello World
```

> *NOTE*: Add -t as an argument to logs to prefix the output with a timestamp.

Before we stop our container lets look for the process on the host:

```
$ ps aux 
...
root      3490  0.0  0.1   4444  1480 ?        Ss   10:46   0:00 /bin/sh -c while true; do echo Hello World; sleep 10; done
...
```

That's the process that's running within our container. So, from inside the container we can only see our own process.  From the host running the container we can see all processes that are running within containers.

Now we can stop our daemonised container:

```
$ docker stop serene_shockley
```


## Creating our own container

Now we are going to put some useful stuff in that container:

	$ docker run -it ubuntu:14.10 /bin/bash
	# echo 'Hello YOURNAME!' > index.html

Use `Ctrl-D` to exit.

You can now commit the changes you made to your container.  First get the ID of the last container that exited:

```
$ docker ps -al
```

Next, commit the image, the syntax is:

	$ docker commit name|id [REPOSITORY:TAG]
	
```
$ docker commit f18854e5bc76 greggigon/helloworld:latest
```

Now, we can run our image, this time we're telling python to run a web server to serve the file we created.:

`$ docker run -d -p 8000:8000 greggigon/helloworld python3 -m http.server`

Test it:

```
$ curl http://localhost:8000
Hello YOURNAME!
```

You've created your first container!   Run `docker images` and you should see it.  We'll see later a better way to build containers.  For now, it's worth noting that on disk our container is only another (very small) layer on top of the existing Ubuntu image which makes Docker very space efficient.

This should conclude basic usage and we can navigate to [2. Networking](../2.%20networking/)