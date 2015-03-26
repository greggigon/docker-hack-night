Container Linking
=======================

If you haven't already pull the latest wordpress and mysql images.

`$ docker pull wordpress:latest mysql:latest`

In the previous section you ran MySQL like this, if the mysqldb container isn't running start it again:

`$ docker run -p 3306:3306 --name mysqldb -e MYSQL_ROOT_PASSWORD=password -d mysql`

Start Wordpress, linking to MySQL:

`$ docker run --name web --link mysqldb:mysql -p 8000:80 -d wordpress`

Where the link argument is `--link <id or name>:alias`.

So, the *web* container can now access information about the *mysqldb* container.  How?

Docker creates a secure tunnel directly between the two containers.  Notice that no ports were exposed to allow connectivity between the containers.  The connection information is exposed in two ways:
- Environment variables
- /etc/hosts

> *NOTE*: we exposed a port when starting our mysqldb container, we could remove that now as the linked containers can talk directly without exposing ports to other, unlinked, containers.

Hit http://localhost:8000 to see your Wordpress container.


## Environment Variables

Docker injects environment variables into the container that is being linked.

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

An *<alias_NAME>* environment variable exists for each linked container.

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

There's one major problem with the MySQL container we're using. All of it's data is stored within the container.  Once the container exits it's lost forever.  We need to store the data outside of the container, enter [Volumes]()


