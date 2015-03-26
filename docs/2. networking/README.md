Docker Networking
==================

We are going to learn the following stuff:

* How does docker networking work?
* How to expose what is happening inside container to the outside world?

## Running Simple HTTP Server
We need to expose port that is running inside container to the outside world.

	$ docker run -d -p 8000:8001 --name simple-http-server simple-http-server /bin/run-simple-server

This means that the port **8000** inside container, will be mapped to port **8001** of our host.


----------

We can also expose all the range of the ports in the Container at random with **-P** option:

	$ docker run -d -P --name simple-http-server simple-http-server /bin/run-simple-server
	
We can also directly use Host Network interfaces when we are troubleshooting with **--net=host**:

	$ docker run -d --net=host --name simple-http-server simple-http-server /bin/run-simple-server

## Running MySQL database

We will be using Database in the later examples, that is why we need to get it from registry.

	$ docker pull registry_ip:port/hack/mysql

Now, let's start the MySQL Database:
	
	$ docker run -p 3306:3306 --name mysqldb -e MYSQL_ROOT_PASSWORD=password -d mysql

> *NOTE*: the `-e` argument allows you to inject environment variables.  It can be repeated multiple times.

So we can connect to the Database:
	
	$ mysql -h"192.168.0.x" -P"3306" -uroot -p"password"

> Make sure to check your IP and replace the **x** with appropriate value.


----------
Before we move on to the next section lets create a Database for our next application.

	mysql> create tabase wordpress;
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
	
We can now move to next section, which is [3. Container Linking](../3.%20linking/).