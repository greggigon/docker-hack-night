Automating Container Builds
========================

So far we covered how to manually deal with creating and building Containers. In this section we will:

 - Learn how to automate container building?
 - How to share your images?

### Basics of Dockerfile

Dockerfile is a recipe for building a Docker container. We are going to create a docker file for building the Simple HTTP Server we've previously created.

Let's start with the basics. 

 1. Create empty folder and empty **Dockerfile** somewhere
 2. Add the **simple_http_server.py** to that folder.
 3. Add the **run-simple-http-server** file to that folder.


----------
Content of the Dockerfile should look like this:

    FROM ubuntu:14:10
    MAINTAINER "Greg Gigon <greg.gigon@somemail.com>"
	
	ADD simple_http_server.py /tmp
	ADD run-simple-http-serve /tmp
	RUN mkdir -p /opt/simple-http-server && mv /tmp/run-simple-http-server && \
		 chmod +x /bin/run-simple-http-server && \
		 mv /tmp/simple_http_server.py /opt/simple-http-server
	ENTRYPOINT /bin/simple-http-server
	EXPOSE 8000


----------
We can now build the container from the command line with command:

	docker build -t simple-http-container .


### Sharing the container

You can share container as a file by **exporting/importing** it with command:

	docker export simple-http-container > simple-http-container.tar

Or you can push it to Docker registry by tagging it first with a registry address and pushing it:

	docker tag simple-http-container 192.168.0.X:5000/greg/simple-http-container
	docker push 192.168.0.X:5000/greg/simple-http-container


----------
You know how to auto-build the containers, run them, link, expose on network and persist the data. Now it's time for [Clustering](../6.%20clustering/) the containers.