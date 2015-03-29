
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
- **Labels**: Labels are arbitrary key/value pairs which can be attached to objects (Pods, Services, etc) Example:
`release: "1.2.4", environment: "dev", tier: "frontend", datacenter: "london"`
- **Selectors**: Used for selecting a group of objects based on their label.  For example Service 'ProductionFrontend' will can select all Pods with labels tier='frontend' and environment='production' and route traffic to them.

# OpenShift

[OpenShift](https://github.com/openshift/origin) is RedHat's Platform as a Service product.  Version 3 is a complete re-write using Docker for packaging and Kubernetes for Cluster Management while adding multi-tenancy, application build and deployment automation.

We're using it here as it's nicely packaged into a single container.  OpenShift should already be running (in a container!) in your VM, for example:

```
$ docker ps
CONTAINER ID        IMAGE                     COMMAND                CREATED             STATUS              PORTS                    NAMES          
a1abced25cba        openshift/origin:v0.4.1   "/usr/bin/openshift    22 minutes ago      Up 22 minutes                                openshift-master.service
```
If it's not running, run `sudo sytemctl start openshift-master`

The main command for interacting with openshift is `osc`.  The following show's how many members, 'minions', we have in our cluster:

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

## First create a project

Projects can include multiple services, pods, builds, etc.  Quotas and permissions can also be applied to projects.   Lets create one first, type the following as written (ie.  don't change anypassword):

`$ openshift ex new-project hack --display-name="Hack Night" --description="The Hack Night Demo Project" --admin=anypassword:admin`

Refresh the management website and you should see the empty project.

Subsequent `osc` commands will include the argument `-n hack` to refer to the project we just created.

## Create a pod

The next step is to create a Pod.  Remembder, Pods are groups of associated containers.  Containers in a Pod share a public IP address and volumes, think 'linked containers'.  Put things in a Pod that need to be deployed and scaled together.

Read [hello-pod.json](hello-pod,json), it defines the container to run, the ports it should use and the labels that should be applied.  

> *NOTE*: If you already built a container you can replace the image with one of your own.

Create the pod:
```
$ cat hello-pod.json | osc create -n hack -f -
hello-openshift
```

> *NOTE*: there's an '/home/vagrant/openshift' directory in each of the VMs that contains all of the json required for the examples.

OpenShift returns the id of the object that has been created.

Check the pods:
```
$ osc get -n hack pods
POD                 IP                  CONTAINER(S)        IMAGE(S)                    HOST                LABELS                 STATUS
hello-openshift     172.17.0.3          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
```

Kubernetes has started our container openshift/hello-openshift on a host with the labels 'name=hello-openshift' and assigned the IP address 172.17.0.3 to the Pod.

You can connect directly to the pod:
```
$ curl 172.17.0.3:8080
Hello OpenShift!
```

You can still use the underlying docker commands to see the container running on the local host:
```
$ docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS              PORTS                    NAMES
e878a999274c        openshift/hello-openshift:latest   "/hello-openshift"     2 minutes ago       Up 2 minutes                                 k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_36ea7203
```

If you refresh the management website you'll see your Pod.

## Create a service

Pods are ephemeral, they may come and go and will be assigned a different IP address every time.  How do we manage this?

Services provide a stable entrypoint to ephemeral Pods.  [hello-service.json](hello-service.json) defines a port and a selector (in this case name=hello-openshift, see label of Pod above) which is used to select the Pods the service should route traffic to.  Create the Service as follows:

```
$ cat hello-service.json | osc create -n hack -f -
hello-openshift
```

Check the service has been created:

```
$ osc get -n hack service
NAME                LABELS                                    SELECTOR               IP                  PORT
hello-openshift     <none>                                    name=hello-openshift   172.30.17.186       27017
```

Kubernetes has created a stable IP address (using iptables rules) which combined with the port you defined can be used to connect to your Pods.

```
$ curl 172.30.17.186:27017
Hello OpenShift!
```
> *NOTE*: Kubernetes is currently working on a DNS Service for the cluster which will allow applications to use DNS names instead of the service IP address.


## Scale the service

Create a replication controller which defines a pod template and the number of pods to create. [hello-controller.json](hello-controller.json) defines the number of replicas for a particular selector and a template for creating pods to maintain the correct number of replicas.  Create your Replica Contoller:

```
$ cat hello-controller.json | osc create -n hack -f -
hello-controller
```

Check it was created:

```
$ osc get -n hack rc
CONTROLLER          CONTAINER(S)        IMAGE(S)                    SELECTOR               REPLICAS
hello-controller    hello-openshift     openshift/hello-openshift   name=hello-openshift   1
```

So, we have a Replication Contoller 'hello-controller' managaging 1 replica of the image openshift/hello-openshift that was already running.  Lets scale up!

Edit [hello-controller.json](hello-controller.json), change the number of replicas to 3

And update the controller:

```
$ cat hello-controller.json | osc update -n hack -f -
hello-openshift
```

Check the controller again:

```
$ osc get -n hack rc
CONTROLLER          CONTAINER(S)        IMAGE(S)                    SELECTOR               REPLICAS
hello-controller    hello-openshift     openshift/hello-openshift   name=hello-openshift   3
```

And check the running pods:

```
$ osc get -n hack pods
POD                      IP                  CONTAINER(S)        IMAGE(S)                    HOST                LABELS                 STATUS
hello-openshift-1t5q3   172.17.0.5          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
hello-openshift-snhqv   172.17.0.4          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
hello-openshift         172.17.0.3          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
```

> *NOTE*: Each of these Pods has a distinct IP even though they're all running on the same host (in this case).  That means they can all bind to the same port, Kubernetes and docker will take care of the mapping and we don't have to worry about managing ports or collisions.

And the containers on the host:

```
$ docker ps
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
`$ docker stop cf8091f8693b`

Wait a few seconds and check again:

```
$ docker ps -l
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS                  PORTS                    NAMES
880bf49b5d86        openshift/hello-openshift:latest   "/hello-openshift"     2 seconds ago       Up Less than a second                            k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_6020ced9
```

The Replication Controller has detected the failure and has restarted the pod!

## Load balancing

Kill 1 or 2 of the containers, the service will redirect to the remaining pods

```
$ docker kill 880bf49b5d86
880bf49b5d86
```

Remember the service is available at 172.30.17.186:27017

```
$ curl 172.30.17.186:27017
Hello OpenShift!
```

This will do the same:
```
$ curl `osc get -n hack services  hello-openshift --template="{{ .portalIP}}:{{ .port}}"`
Hello OpenShift!
```

The service will transparently redirect traffic to the remaining Pods while the Replication Controller restarts the required Pods.

# Discovery

How do Pods discover the address of the Services they can use?  Kubernetes adds a set of environment variables ({SVCNAME}_SERVICE_HOST and {SVCNAME}_SERVICE_PORT, ie. compatible with Docker Links) to each Pod for each active Service.

Use Docker inspect to have a look:

```
     "Env": [
            "KUBERNETES_PORT_443_TCP=tcp://172.30.17.2:443",
            "KUBERNETES_RO_SERVICE_PORT=80",
            "KUBERNETES_RO_PORT=tcp://172.30.17.1:80",
            "KUBERNETES_RO_PORT_80_TCP_PROTO=tcp",
            "HELLO_OPENSHIFT_PORT_27017_TCP_PROTO=tcp",
            "HELLO_OPENSHIFT_PORT_27017_TCP_PORT=27017",
            "HELLO_OPENSHIFT_PORT_27017_TCP_ADDR=172.30.17.66",
            "KUBERNETES_PORT_443_TCP_PROTO=tcp",
            "KUBERNETES_RO_SERVICE_HOST=172.30.17.1",
            "KUBERNETES_RO_PORT_80_TCP=tcp://172.30.17.1:80",
            "KUBERNETES_RO_PORT_80_TCP_PORT=80",
            "KUBERNETES_RO_PORT_80_TCP_ADDR=172.30.17.1",
            "HELLO_OPENSHIFT_PORT_27017_TCP=tcp://172.30.17.66:27017",
            "KUBERNETES_SERVICE_PORT=443",
            "KUBERNETES_PORT=tcp://172.30.17.2:443",
            "KUBERNETES_PORT_443_TCP_PORT=443",
            "KUBERNETES_PORT_443_TCP_ADDR=172.30.17.2",
            "HELLO_OPENSHIFT_SERVICE_HOST=172.30.17.66",
            "HELLO_OPENSHIFT_PORT=tcp://172.30.17.66:27017",
            "KUBERNETES_SERVICE_HOST=172.30.17.2",
            "HELLO_OPENSHIFT_SERVICE_PORT=27017"
        ],
```

# Conclusion

Docker gives us a system for packaging our applications and restricting resource usage.  Kubernetes and OpenShift allow us to use those containers to build applications, described in code, that can scale and failover transparently while increasing host utilisation.

# More Examples

See https://github.com/openshift/origin/tree/master/examples and https://github.com/GoogleCloudPlatform/kubernetes/tree/master/examples for more examples
