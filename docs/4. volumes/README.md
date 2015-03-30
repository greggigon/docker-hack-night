Data Volumes
============

Data Volumes provide a mechanism for importing and exporting data from a container beyond the lifetime of that container.  A Data Volume can be either a directory within a container that bypasses the Union File System or a directory on the container host.

# Host Directory

Remember our MySQL container?  We previously started it like this:

`$ docker run -d --name mysqldb -e MYSQL_ROOT_PASSWORD=password mysql`

Any data that's stored in that container will be lost when it stops.

Lets fix that.  If it's still running, stop the old container first

`$ docker stop mysqldb`

Create a local directory:

`$ mkdir -p /home/vagrant/var/lib/mysql`

Before you can use the directory you have to change the SELinux context so that the container can write to a local directory:
`$ sudo chcon -Rt svirt_sandbox_file_t /home/vagrant/var`

Mount the created directory into the container using the `-v` argument.  This maps a directory on the host, to a directory inside the container.

```
$ docker run -d --name mysqldb -v /home/vagrant/var/lib/mysql:/var/lib/mysql -e MYSQL_ROOT_PASSWORD=password mysql
```

> *NOTE*: Docker will complain that the name 'mysqldb' is already in use.  Either use a new name or run `docker rm mysqldb` to remove the container we just stopped.  You can add `--rm` to the run command to automatically remove containers once they've exited.
> *NOTE*: If the mount path already exists within the container the contents of the directory will be overwritten by the mount point.

Once the MySQL container has started you can check the contents of the /home/vagrant/var/lib/mysql directory and the /var/lib/mysql inside the directory using exec.  Now that MySQL is storing data here we can restart it without any loss.


# Data Volume Container

As well as mounting directories from the host file system you can also mount volumes that are exposed by other containers.  This provides a mechanism for multiple containers to share the same volumes.

`$ docker create -v /var/lib/mysql --name dbdata busybox`

> *NOTE*: This *creates* a container from the busybox image with an internal volume but doesn't start it.  We could have used *any* image here, the implementation is irrelevant.  We're just using a container to hold a reference to the volume.

Now, we can start multiple containers which share the same volumes.  Out database uses the volume as normal:

`$ docker run -d --name mysqldb -e MYSQL_ROOT_PASSWORD=password --volumes-from dbdata mysql`

But a second process can also mount the data to perform, for example, a backup:

`$ docker run -d --volumes-from dbdata --name backup example/backup`

> *NOTE*: Data Volume containers must be explicitly removed by calling `$ docker rm -v <name_or_id>` against the *last* volume using the mount