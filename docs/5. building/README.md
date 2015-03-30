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


### Sharing the container

You can share container as a file by **exporting/importing** it with command:

	docker export simple-http-server > simple-http-server.tar

Or you can push it to Docker registry by tagging it first with a registry address and pushing it (this will only work if network is available):

	docker tag simple-http-server ${REGISTRY_IP_ADDRESS}:5000/greg/simple-http-server
	docker push ${REGISTRY_IP_ADDRESS}:5000/greg/simple-http-server


----------
You now know how to auto-build containers, run them, link, expose on network and persist the data. Now it's time for [Clustering](../6.%20clustering/) the containers.