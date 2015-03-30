Docker Networking
==================

We are going to learn the following stuff:

* How does docker networking work?
* How to expose what is happening inside container to the outside world?

## Running Simple HTTP Server

Previously we ran the following container, which should still be running:

	$ docker run -d -p 9000:8000 greggigon/helloworld python3 -m http.server

This means that the port **8000** inside container, will be mapped to port **9000** of our host.

## Running MySQL database

Let's start the MySQL Database:
	
	$ docker run -p 3306:3306 --name mysqldb -e MYSQL_ROOT_PASSWORD=password -d mysql

> *NOTE*: the `-e` argument allows you to inject environment variables.  It can be repeated multiple times to add multiple variables. `--name` is naming the container. You can see when you list the containers `docker ps -a` that those have randomly generated names. `--name` will use the name that you provide. The name has to be unique.

Now, we should have MySQL running in a container (you can check with `docker ps`).  Now we should be able to connect to the Database:
	
	$ mysql -h 127.0.0.1 -P 3306 -u root -ppassword

> *NOTE*: don't put a space between -p and password

----------
Before we move on to the next section lets create a Database for our next application.

	mysql> create database wordpress;
	mysql> show databases;
	+--------------------+
	| Database           |
	+--------------------+
	| information_schema |
	| mysql              |
	| performance_schema |
	| wordpress          |
	+--------------------+
	4 rows in set (0.00 sec)
    mysql> exit

> *WARNING*: If you restart the database container all changes will be lost! We'll be looking at [Volumes](../4.%20volumes/) later to avoid this.

We can now move to next section, which is [3. Container Linking](../3.%20linking/).