
Clustering Containers
=====================

Containers provide a lightweight way to package and run applications but how do we manage them?

> NOTE: Kubernetes and OpenShift v3 are both currently **beta!**

# Kubernetes

Google has open-sourced their internal container management system which they use to deploy, monitor and scale their applications.  It is designed to be:

- **lean**: lightweight, accesible, simple
- **portable**: public, private, hybrid
- **extensible**: modular, pluggable, hookable, composable
- **self-healing**: auto-placement, auto-restart, auto-replication

Concepts:

- **Clusters**: Kubernetes (or k8s) builds clusters of resources on to which containers can be deployed
- **Pods**: Co-located groups of Docker containers with shared volumes.  The smallest deployable unit.  Ephemeral.  Pods are individually routable within a Kubernetes cluster, default Docker containers are not.  Each Pod has its own IP address within the cluster, this also means that each pod has it's own range of ports (ie. every pod can bind to port 8000).  See [Pods](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md) for more.
- **Replication Controller**: manage the lifecycle of pods.  They ensure that the required number of pods are always running.  See [Replication Controllers](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/replication-controllers.md) for more.
- **Services**: provide the mechanism by which different groups of Pods (with transient IPs) or external services can communicate with a set of Pods.  Provides a single stable IP and port.  Acts as a basic load-balancer.  Implemented using iptables rules on each host.
- **Labels*: Labels are arbitrary key/value pairs which can be attached to objects (Pods, Services, etc) Example:
`release: "1.2.4", environment: "dev", tier: "frontend", datacenter: "london"`
- **Selectors**: Used for selecting a group of objects based on their label.  For example Service 'ProductionFrontend' will can select all Pods with labels tier='frontend' and environment='production' and route traffic to them.

# OpenShift

[OpenShift](https://github.com/openshift/origin) is RedHat's Platform as a Service product.  Version 3 is a complete re-write using Docker for packaging and Kubernetes for Cluster Management while adding multi-tenancy, application build and deployment automation.

We're using it here as it's nicely packaged into a single container.  OpenShift should already be running (in a container!) in your VM, for example:

```
$ sudo docker ps
CONTAINER ID        IMAGE                     COMMAND                CREATED             STATUS              PORTS                    NAMES          
a1abced25cba        openshift/origin:v0.4.1   "/usr/bin/openshift    22 minutes ago      Up 22 minutes                                openshift-master.service
```

The main command for interacting with openshift is `osc`

```
$ osc get minions
NAME                LABELS              STATUS
master              <none>              Ready
```

OpenShift logs are available by running:
`$ sudo journalctl -f -u openshift-master`

# Hello World

This example demonstrates the basic principles of running an application with OpenShift/Kubernetes.

Before you create anything you can login to the OpenShift management website at https://10.245.2.2:8444/, username: admin, password: admin.  The console will update as you create resources in OpenShift.

## Create a pod

The first step is to create a Pod.  Read [hello-pod.json](hello-pod,json), it defines the container to run, the ports it should use and the labels that should be applied.  

If you already have a container you can replace the image with one of your own.

Create the pod:
```
$ cat hello-pod.json | osc create -f -
hello-openshift
```

OpenShift returns the id of the object that has been created.

Check the pods:
```
$ osc get pods
POD                 IP                  CONTAINER(S)        IMAGE(S)                    HOST                LABELS                 STATUS
hello-openshift                         hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
```

You can connect directly to the pod:
```
$ curl localhost:6061
Hello OpenShift!
```

Use docker commands to see the container running on the local host:
```
$ sudo docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS              PORTS                    NAMES
e878a999274c        openshift/hello-openshift:latest   "/hello-openshift"     2 minutes ago       Up 2 minutes                                 k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_36ea7203
```

## Create a service

Services provide a stable entrypoint to ephemeral Pods.  [hello-service.json](hello-service.json) defines a port and a selector which is used to select the Pods the service should route traffic to.  Create the Service as follows:

```
$ cat hello-service.json | osc create -f -
hello-openshift
```

Check the service has been created:

```
$ osc get service
NAME                LABELS                                    SELECTOR               IP                  PORT
hello-openshift     <none>                                    name=hello-openshift   172.30.17.186       27017
```

Kubernetes has created a stable IP address (using iptables rules) which combined with the port you defined can be used to connect to your Pods.

```
$ curl 172.30.17.186:27017
Hello OpenShift!
```



## Scale the service

Create a replication controller which defines a pod template and the number of pods to create. [hello-controller.json](hello-controller.json) defines the number of replicas for a particular selector and a template for creating pods to maintain the correct number of replicas.  Create your Replica Contoller:

```
$ cat hello-controller.json | osc create -f -
hello-controller
```

Check it was created:

```
$ osc get rc
CONTROLLER          CONTAINER(S)        IMAGE(S)                    SELECTOR               REPLICAS
hello-controller    hello-openshift     openshift/hello-openshift   name=hello-openshift   1
```

So, we have a Replication Contoller 'hello-controller' managaging 1 replica of the image openshift/hello-openshift.  Lets scale up!

```
$ openshift kube resize --replicas=3 rc hello-controller
resized
```

Check the controller again:

```
$ osc get rc
CONTROLLER          CONTAINER(S)        IMAGE(S)                    SELECTOR               REPLICAS
hello-controller    hello-openshift     openshift/hello-openshift   name=hello-openshift   3
```

And check the running pods:

```
$ osc get pods
POD                      IP                  CONTAINER(S)        IMAGE(S)                    HOST                LABELS                 STATUS
hello-openshift-1t5q3   172.17.0.5          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
hello-openshift-snhqv   172.17.0.4          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
hello-openshift         172.17.0.3          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
```

And the containers on the host:

```
$ sudo docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS              PORTS                    NAMES
cf8091f8693b        openshift/hello-openshift:latest   "/hello-openshift"     3 minutes ago       Up 3 minutes                                 k8s_hello-openshift.346dfbe7_hello-openshift-1t5q3.default.api_267aac3f-d24d-11e4-be9b-080027f89fba_0272caf7   
feb5e2c8952c        openshift/origin-pod:v0.4.1        "/pod"                 3 minutes ago       Up 3 minutes                                 k8s_POD.7d6e9ca_hello-openshift-1t5q3.default.api_267aac3f-d24d-11e4-be9b-080027f89fba_f21e5a33                
c720dbe6d3bc        openshift/hello-openshift:latest   "/hello-openshift"     6 minutes ago       Up 6 minutes                                 k8s_hello-openshift.346dfbe7_hello-openshift-snhqv.default.api_ca40b09f-d24c-11e4-be9b-080027f89fba_0711a9b9   
1053a0857038        openshift/origin-pod:v0.4.1        "/pod"                 6 minutes ago       Up 6 minutes                                 k8s_POD.7d6e9ca_hello-openshift-snhqv.default.api_ca40b09f-d24c-11e4-be9b-080027f89fba_297d6167                
880bf49b5d86        openshift/hello-openshift:latest   "/hello-openshift"     18 minutes ago      Up 18 minutes                                k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_6020ced9          
02b03ab31175        openshift/origin-pod:v0.4.1        "/pod"                 22 minutes ago      Up 22 minutes       0.0.0.0:6061->8080/tcp   k8s_POD.e3b5ea67_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_f76dceca
```

> *NOTE*: Above we first created a standalone Pod without a Replication Contoller, it would be better to create a Replication Contoller with a replica of 1.

Now, try stopping one of the containers using the container ID from the command above:
`$ sudo docker stop cf8091f8693b`

Wait a few seconds and check again:

```
$ sudo docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS                  PORTS                    NAMES
880bf49b5d86        openshift/hello-openshift:latest   "/hello-openshift"     2 seconds ago       Up Less than a second                            k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_6020ced9
```

The Replication Controller has detected the failure and has restarted the pod!

## Load balancing

Kill 1 or 2 of the containers, the service will redirect to the remaining pods

```
$ sudo docker kill 880bf49b5d86
880bf49b5d86
```

Remember the service is available at 172.30.17.186:27017

```
$ curl 172.30.17.186:27017
Hello OpenShift!
```

This will do the same:
```
$ curl `osc get services hello-openshift --template="{{ .portalIP}}:{{ .port}}"`
Hello OpenShift!
```

The service will transparently redirect traffic to the remaining Pods while the Replication Controller restarts the required Pods.

# More Examples

See https://github.com/openshift/origin/tree/master/examples and https://github.com/GoogleCloudPlatform/kubernetes/tree/master/examples for more examples
