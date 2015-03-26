Data Volumes
=======
Data Volumes provide a mechanism for importing and exporting data from a container beyond the lifetime of that container.  A Data Volume can be either a directory within a container that bypasses the Union File System or a directory on the container host.

# Host Directory

Remember our MySQL container?  We previously started it like this:

`$ docker run --name mysqldb -e MYSQL_ROOT_PASSWORD=qwerty -d mysql`

Any data that's stored in that container will be lost when it stops.

Lets fix that.  If it's still running, stop the old container first

`$ docker stop db`

Create a local directory:

`$ mkdir -p var/lib/mysql`

Before you can use the directory you have to change the SELinux context so that the container can write to a local directory:
`$ sudo chcon -Rt svirt_sandbox_file_t var`

Mount the created directory into the container using the `-v` argument:

```
$ docker run --name mysqldb -v $PWD/var/lib/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=qwerty -d mysql
```

> *NOTE*: If the mount path already exists within the container the contents of the directory will be overwritten by the mount point.

Once the MySQL container has started you can check the contents of the var/lib/mysql directory.  Now that MySQL is storing data here we can restart it without any loss.


# Data Volume Container

As well as mounting directories from the host file system you can also mount volumes that are exposed by other containers.  This provides a mechanism for multiple containers to share the same volumes.

`$ sudo docker create -v /var/lib/mysql --name dbdata mysql`

> *NOTE*: We could have used *any* image here, the implementation is irrelevant.

Now, we can start multiple containers which share the same volumes.  Out database uses the volume as normal:

`$ sudo docker run -d --volume-from dbdata --name mysqldb mysql`

But a second process can also mount the data to perform, for example, a backup:

`$ sudo docker run -d --volume-from dbdata --name backup example/backup`

> *NOTE*: Data Volume containers must be explicitly removed by calling `$ sudo docker rm -v <name_or_id>` against the *last* volume using the mount