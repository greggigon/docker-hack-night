Debugging

# Inspect a running container

The following will give you the complete config of the running container:

`$ docker inspect name|id`

# Run a command within a container

`$ docker exec -it name|id command`

Where command could be bash, for example, in which case you have a shell inside the container.

> *NOTE*: command has to already exist within the container, if not use nsenter

# Logs

Anythin written to stdout or stderr is captured by the docker daemon.  Use `docker logs name|id` to view logs.

> *NOTE*: if the container is removed so are the logs!

Best practice would be to store logs in a volume which persists across restarts.

Logs from the docker daemon itself are available by running (assuming a modern RedHat version):

`$ sudo journalctl -f -u docker`

# nsenter

Use nsenter to enter the namespace of the container from the host.  This can be useful if the container doesn't have the required tools to debug issues.

First you need to get the Process ID of the running container:

```
$ PID=$(docker inspect --format {{.State.Pid}} 16f7cdc86823)
```

Then enter the container:

```
nsenter --target $PID --mount --uts --ipc --net --pid
```

This will enter the 5 different namespaces the kernel wraps the contained process in.

See https://blog.docker.com/tag/nsenter
