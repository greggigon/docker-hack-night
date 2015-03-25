Clustering Containers
=====================

Containers provide a lightweight way to package and run applications but how do we manage them?

# Kubernetes

Google has open-sourced their internal container management system which they use to deploy, monitor and scale their applications.  It is designed to be:

- *lean*: lightweight, accesible, simple
- *portable*: public, private, hybrid
- *extensible*: modular, pluggable, hookable, composable
- *self-healing*: auto-placement, auto-restart, auto-replication

Concepts:

- *Clusters*: Kubernetes (or k8s) builds clusters of resources on to which containers can be deployed
- *Pods*: Co-located groups of Docker containers with shared volumes.  The smallest deployable unit.  Ephemeral.  Pods are individually routable within a Kubernetes cluster, default Docker containers are not.  Each Pod has its own IP address within the cluster, this also means that each pod has it's own range of ports (ie. every pod can bind to port 8000).  See [Pods](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/pods.md) for more.
- *Replication Controller*: manage the lifecycle of pods.  They ensure that the required number of pods are always running.  See [Replication Controllers](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/replication-controllers.md) for more.
- *Services*: provide the mechanism by which different groups of Pods (with transient IPs) or external services can communicate with a set of Pods.  Provides a single stable IP and port.  Acts as a basic load-balancer.  Implemented using iptables rules on each host.
- *Labels*: Labels are arbitrary key/value pairs which can be attached to objects (Pods, Services, etc) Example:
`release: "1.2.4", environment: "dev", tier: "frontend", datacenter: "london"`
- *Selectors*: Used for selecting a group of objects based on their label.  For example Service 'Foo' will select all Pods with label 'Bar' and route traffic to them.

# OpenShift

[OpenShift](https://github.com/openshift/origin) is RedHat's Platform as a Service product.  Version 3 is a complete re-write using Docker for packaging and Kubernetes for Cluster Management while adding multi-tenancy, application build and deployment automation.

We're using it here as it's nicely packaged into a single container.  OpenShift should already be running (in a container!) in your VM, for example:

`$ sudo docker ps
CONTAINER ID        IMAGE                     COMMAND                CREATED             STATUS              PORTS                    NAMES          
a1abced25cba        openshift/origin:v0.4.1   "/usr/bin/openshift    22 minutes ago      Up 22 minutes                                openshift-master.service`

`$ openshift`
`$ osc`

`$ osc get minions
NAME                LABELS              STATUS
master              <none>              Ready`

`$ sudo journalctl -f -u openshift-master`

# Examples

See https://github.com/openshift/origin/tree/master/examples and https://github.com/GoogleCloudPlatform/kubernetes/tree/master/examples/guestbook for source of examples

- [hello]
- [advanced]