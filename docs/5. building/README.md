Automating Container Builds
========================

So far we covered how to manually deal with creating and building Containers. In this section we will:

 - Learn how to automate container building
 - How to share your images

### Basics of Dockerfile

Dockerfile is a recipe for building a Docker container. We are going to create a docker file for building the Simple HTTP Server we've previously created.

Let's start with the basics. 

 1. Create empty folder and a file, called **Dockerfile** somewhere
 2. Add a file,  **index.html**, to that folder (put some interesting text in the index.html file).

----------

Content of the Dockerfile should look like this:

    FROM ubuntu:14.10
    MAINTAINER "Greg Gigon <greg.gigon@somemail.com>"
    
    ADD index.html /
    RUN chmod 644 /index.html 
    ENTRYPOINT python3 -m http.server
    EXPOSE 8000


----------

We can now build the container from the command line with command:

```
$ docker build -t greggigon/simple-http-server .
Sending build context to Docker daemon 3.072 kB
Sending build context to Docker daemon 
Step 0 : FROM ubuntu:14.10
 ---> 59a878f244f6
Step 1 : MAINTAINER "Greg Gigon <greg.gigon@somemail.com>"
 ---> Using cache
 ---> 764d41e3169b
Step 2 : ADD index.html /
 ---> c1d3fa7e2bb2
Removing intermediate container 893a6cc71286
Step 3 : RUN chmod 644 /index.html
 ---> Running in 7a1722bb9282
 ---> a90d795214b1
Removing intermediate container 7a1722bb9282
Step 4 : ENTRYPOINT python3 -m http.server
 ---> Running in 726bec769d3c
 ---> 5fb87c127661
Removing intermediate container 726bec769d3c
Step 5 : EXPOSE 8000
 ---> Running in 3976ed6ee97f
 ---> e6574dac3fbc
Removing intermediate container 3976ed6ee97f
Successfully built e6574dac3fbc
```

Run `docker images` now and you should see your container.   Now, see if you can run it!

Instructions in the Dockerfile are executed from the top down.  Each instruction is executed in a new layer run in a new container.  If, for whatever reason, compilation fails you can run a container from the last successful instruction and run the next step manually to debug.  

As each instruction is committed as an image Docker can use previous layers as a cache.  This means that the order of instructions in the Dockerfile is important.  If all of your images share the same base set of instructions they can share the same layers.  Specific changes to each image should be made at the end of the Dockerfile.

### Dockerfile commands explained

| Command        | Example           | Explanation  |
| ------------- |:-------------|:-----|
| FROM      | FROM ubuntu:14.10 | Which image to use as a base image |
| MAINTAINER     | MAINTAINER "Greg Ster my@email.com"|Who is the creator info|
| RUN | RUN mkdir -p /tmp/foo |Execute command inside container|
| | RUN ["mkdir -p /tmp/foo", "ls -l /tmp/foo"]||
|CMD | CMD ["mkdir", "-p", "/foo/bar"]|There can only be 1 command in the Dockerfile. It should be used to provide default command to execute for the container.|
|EXPOSE|EXPOSE 8000| Marks container as exposing port 8000. Doesn't do the mapping. Used when Linking containers.|
|ENV| ENV http_proxy "http://localhost:8008"| Sets environment variables in the container|
|ADD|ADD my-file.txt /root/| Copy files and directories from source which can also be a URL to destination|
|COPY| COPY user-directory/ /home/| Copy files and folders from source to destination|
|ENTRYPOINT| ENTRYPOINT /bin/bash| Marks default executable when Container is starting|
|VOLUME|VOLUME  /opt| Creates mounting point for Volumes|
|USER|USER daemon|Sets which user inside container should be used when running the image|
|WORKDIR| WORKDIR /root| Sets the working directory for RUN, CMD and ENTRYPOINT commands|

More detailed description of each [Dockerfile Commands in here](Dockerfile-DockerDocumentation.html).

#### CMD vs ENTRYPOINT

The *CMD* instruction can be overridden on the docker run command line while *ENTRYPOINT* can not.   Image authors may choose to use ENTRYPOINT to ensure their containers behave in a certain way.  CMD can still be used in conjunction with ENTRYPOINT to provide default arguments.

### Sharing the container

You can share container as a file by **exporting/importing** it with command:

	$ docker export simple-http-server > simple-http-server.tar

> *NOTE*: You export *containers* not images.

Or you can push it to Docker registry by tagging it first with a registry address and pushing it (this will only work if network is available):

	$ docker tag simple-http-server ${REGISTRY_IP_ADDRESS}:5000/greg/simple-http-server
	$ docker push ${REGISTRY_IP_ADDRESS}:5000/greg/simple-http-server


----------

You now know how to auto-build containers, run them, link, expose on network and persist the data. Now it's time for [Clustering](../6.%20clustering/) the containers.