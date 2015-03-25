# Hello World

This example demonstrates the basic principles of running an application with OpenShift/Kubernetes.

## Create a pod

The first step is to create a Pod.  Read [hello-pod.json], it defines the container to run, the ports it should use and the labels that should be applied.

Create the pod:
`cat hello-pod.json | osc create -f -
hello-openshift`

OpenShift returns the id of the object that has been created.

Check the pods:
`$ osc get pods
POD                 IP                  CONTAINER(S)        IMAGE(S)                    HOST                LABELS                 STATUS
hello-openshift                         hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running`

You can connect directly to the pod:
`$ curl localhost:6061
Hello OpenShift!`

Use docker commands to see the container running on the local host:
`$ sudo docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS              PORTS                    NAMES
e878a999274c        openshift/hello-openshift:latest   "/hello-openshift"     2 minutes ago       Up 2 minutes                                 k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_36ea7203`

Now, try stopping the container using the container ID from the command above:
`$ sudo docker stop e878a999274c`

Wait a few seconds and check again:

`$ sudo docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS                  PORTS                    NAMES
880bf49b5d86        openshift/hello-openshift:latest   "/hello-openshift"     2 seconds ago       Up Less than a second                            k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_6020ced9`

Kubernetes has restarted the pod!

## Create a service

Services provide a stable entrypoint to ephemeral Pods.  [hello-service.json] defines a port and a selector which is used to select the Pods the service should route traffic to.  Create the Service as follows:

`$ cat hello-service.json | osc create -f -
hello-openshift
`

Check the service has been created:

`$ osc get service
NAME                LABELS                                    SELECTOR               IP                  PORT
hello-openshift     <none>                                    name=hello-openshift   172.30.17.186       27017`

Kubernetes has created a stable IP address (using iptables rules) which combined with the port you defined can be used to connect to your Pods.

`$ curl 172.30.17.186:27017
Hello OpenShift!`



## Scale the service

Create a replication controller which defines a pod template and the number of pods to create. [hello-controller.json] defines the number of replicas for a particular selector and a template for creating pods to maintain the correct number of replicas.  Create your Replica Contoller:

`$ cat hello-controller.json | osc create -f -
hello-controller`

Check it was created:

`$ osc get rc
CONTROLLER          CONTAINER(S)        IMAGE(S)                    SELECTOR               REPLICAS
hello-controller    hello-openshift     openshift/hello-openshift   name=hello-openshift   1`

So, we have a Replication Contoller 'hello-controller' managaging 1 replica of the image openshift/hello-openshift.  Lets scale up!

`$ openshift kube resize --replicas=3 rc hello-controller
resized`

Check the controller again:

`$ osc get rc
CONTROLLER          CONTAINER(S)        IMAGE(S)                    SELECTOR               REPLICAS
hello-controller    hello-openshift     openshift/hello-openshift   name=hello-openshift   3`

And check the running pods:

`$ osc get pods
POD                      IP                  CONTAINER(S)        IMAGE(S)                    HOST                LABELS                 STATUS
hello-openshift-1t5q3   172.17.0.5          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
hello-openshift-snhqv   172.17.0.4          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running
hello-openshift         172.17.0.3          hello-openshift     openshift/hello-openshift   master/127.0.0.1    name=hello-openshift   Running`

And the containers on the host:

`$ sudo docker ps
CONTAINER ID        IMAGE                              COMMAND                CREATED             STATUS              PORTS                    NAMES
cf8091f8693b        openshift/hello-openshift:latest   "/hello-openshift"     3 minutes ago       Up 3 minutes                                 k8s_hello-openshift.346dfbe7_hello-openshift-1t5q3.default.api_267aac3f-d24d-11e4-be9b-080027f89fba_0272caf7   
feb5e2c8952c        openshift/origin-pod:v0.4.1        "/pod"                 3 minutes ago       Up 3 minutes                                 k8s_POD.7d6e9ca_hello-openshift-1t5q3.default.api_267aac3f-d24d-11e4-be9b-080027f89fba_f21e5a33                
c720dbe6d3bc        openshift/hello-openshift:latest   "/hello-openshift"     6 minutes ago       Up 6 minutes                                 k8s_hello-openshift.346dfbe7_hello-openshift-snhqv.default.api_ca40b09f-d24c-11e4-be9b-080027f89fba_0711a9b9   
1053a0857038        openshift/origin-pod:v0.4.1        "/pod"                 6 minutes ago       Up 6 minutes                                 k8s_POD.7d6e9ca_hello-openshift-snhqv.default.api_ca40b09f-d24c-11e4-be9b-080027f89fba_297d6167                
880bf49b5d86        openshift/hello-openshift:latest   "/hello-openshift"     18 minutes ago      Up 18 minutes                                k8s_hello-openshift.34edfc84_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_6020ced9          
02b03ab31175        openshift/origin-pod:v0.4.1        "/pod"                 22 minutes ago      Up 22 minutes       0.0.0.0:6061->8080/tcp   k8s_POD.e3b5ea67_hello-openshift.default.api_61f07084-d24a-11e4-be9b-080027f89fba_f76dceca `

NOTE: Above we first created a standalone Pod without a Replication Contoller, it would be better to create a Replication Contoller with a replica of 1.

## Load balancing

Kill 1 or 2 of the containers, the service will redirect to the remaining pods

`$ sudo docker kill 880bf49b5d86
880bf49b5d86`

`$ curl 172.30.17.186:27017
Hello OpenShift!`

This will do the same:
`$ curl `osc get services hello-openshift --template="{{ .portalIP}}:{{ .port}}"`
Hello OpenShift!`