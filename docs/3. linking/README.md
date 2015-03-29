Container Linking
=======================

In the previous section we saw how you can connect to container across the network.  Linking is another way to connect dependant containers.  When containers are linked information about the source container is sent to the destination where it can used.

In the previous section you ran MySQL like this:

`$ docker run -p 3306:3306 --name mysqldb -e MYSQL_ROOT_PASSWORD=password -d mysql`

If it's not running go back and repeat the previous section.

Now, let's create another container which will use the database container.  Start Wordpress, linking to MySQL:

`$ docker run --name web --link mysqldb:mysql -p 8000:80 -d wordpress`

Where the link argument is `--link <id or name>:alias`.

So, the *web* container can now access information about the *mysqldb* container.  How?

Docker creates a secure tunnel directly between the two containers.  The connection information is exposed in two ways:
- Environment variables
- /etc/hosts

Which are discussed in more detail below.

> *NOTE*: we exposed a port when starting our mysqldb container, we could remove that now as the linked containers can talk directly without exposing ports to other, unlinked, containers.

Hit http://localhost:8000 to see your Wordpress container.    If you install wordpress, then check MySQL, you'll find the information you submitted:

```
$ echo "SELECT * FROM wordpress.wp_users" | mysql -h 127.0.0.1 -P 3306 -u root -ppassword
ID	user_login	user_pass	user_nicename	user_email	user_url	user_registered	user_activation_key	user_status	display_name
1	foo	$P$BIQOAWQjZ6zFqobsAVf0xP94LtsHRY/	foo	bar@example.com		2015-03-28 16:16:29		0	foo
```

## Environment Variables

Docker injects environment variables into the container that is being linked.  Exec the env command (or use `docker inspect`) to see the environment variables:

```
$ docker exec -it web env
...
HOSTNAME=126f3354b725
MYSQL_PORT=tcp://172.17.0.2:3306
MYSQL_PORT_3306_TCP=tcp://172.17.0.2:3306
MYSQL_PORT_3306_TCP_ADDR=172.17.0.2
MYSQL_PORT_3306_TCP_PORT=3306
MYSQL_PORT_3306_TCP_PROTO=tcp
MYSQL_NAME=/web/mysql
MYSQL_ENV_MYSQL_ROOT_PASSWORD=password
MYSQL_ENV_MYSQL_MAJOR=5.6
MYSQL_ENV_MYSQL_VERSION=5.6.23
...
```

An *<alias_NAME>* environment variable exists for each linked container. The Wordpress container is configured to use these environment variables to connect to MySQL.

Notice that the container being linked also inherits any environment variables (MYSQL_ROOT_PASSWORD) that are set in the source.

> *WARNING*: There are serious security implications to this!

> *WARNING*: Environment variables are not automatically updated if the source container is restarted. 

## /etc/hosts

Docker also adds an entry to /etc/hosts for each linked container which can be used to connect to the container.  /etc/hosts is updated if the source container restarts.

```
$ docker exec -it web cat /etc/hosts
172.17.0.3	126f3354b725
172.17.0.2	mysql
```

---

There's one major problem with the MySQL container we're using. All of it's data is stored within the container.  Once the container exits it's lost forever.  We need to store the data outside of the container, enter [Volumes](../4.%20volumes)