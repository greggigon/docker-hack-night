Automating Container Builds
========================

So far we covered how to manually deal with creating and building Containers. In this section we will:

 - Learn how to automate container building
 - How to share your images

### Basics of Dockerfile

Dockerfile is a recipe for building a Docker container. We are going to create a docker file for building the Simple HTTP Server we've previously created.

Let's start with the basics. 

 1. Create empty folder and empty **Dockerfile** somewhere
 2. Add the **index.html** to that folder (put some interesting text in the index.html file).

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

	docker build -t yourname/simple-http-server .

### Dockerfile commands explained


| Command        | Example           | Explenation  |
| ------------- |:-------------|:-----|
| FROM      | FROM ubuntu:14.10 | Which image to use as a base image |
| MAINTAINER     | MAINTAINER "Greg Ster my@email.com"|Who is the creator info|
| RUN | RUN mkdir -p /tmp/foo |Execute command inside container|
| | RUN ["mkdir -p /tmp/foo", "ls -l /tmp/foo"]||
|CMD | CMD ["mkdir", "-p", "/foo/bar"]|There can only be 1 command in the Dockerfile. It should be used to provide default for executin container.|
|EXPOSE|EXPOSE 8000| Marks container as exposing port 8000. Doesn't do the mapping. Used when Linking containers.|
|ENV| ENV http_proxy "http://localhost:8008"| Sets environment variables in the container|
|ADD|ADD my-file.txt /root/| Copy files and directories from source which can also be a URL to destination|
|COPY| COPY user-directory/ /home/| Copy files and folders from source to destination|
|ENTRYPOINT| ENTRYPOINT /bin/bash| Marks default executable when Container is starting|
|VOLUME|VOLUME  /opt| Creates mounting point for Volumes|
|USER|USER daemon|Sets which user inside container should be used when running the image|
|WORKDIR| WORKDIR /root| Sets the working directory for RUN, CMD and ENTRYPOINT commands|

More detailed description of each [Dockerfile Commands in here](Dockerfile-DockerDocumentation.html).

### Sharing the container

You can share container as a file by **exporting/importing** it with command:

	docker export simple-http-server > simple-http-server.tar

Or you can push it to Docker registry by tagging it first with a registry address and pushing it (this will only work if network is available):

	docker tag simple-http-server ${REGISTRY_IP_ADDRESS}:5000/greg/simple-http-server
	docker push ${REGISTRY_IP_ADDRESS}:5000/greg/simple-http-server


----------

You now know how to auto-build containers, run them, link, expose on network and persist the data. Now it's time for [Clustering](../6.%20clustering/) the containers.