# k8s Administrator (CKA) Notes <!-- omit in toc -->

* Third course in a series [[beginner](../02.applications-developer/README.md#1-core-concepts), [developer](../02.applications-developer/README.md#2-configuration), administrator, security]
* Can do the exam if you want.

## Tables Of Contents <!-- omit in toc -->
- [1) Core Concepts](#1-core-concepts)
  - [1.1) ETCD](#11-etcd)
  - [1.2) Kube-API Server](#12-kube-api-server)
  - [1.3) Kube Controller Manager](#13-kube-controller-manager)
  - [1.4) Kube Scheduler](#14-kube-scheduler)
  - [1.4) Kubelet](#14-kubelet)
  - [1.5) Kube Proxy](#15-kube-proxy)
  - [1.6) Imperative vs Declarative](#16-imperative-vs-declarative)
  - [1.7) Kubectl Apply Command](#17-kubectl-apply-command)
- [2) Scheduling](#2-scheduling)
  - [2.1) Manual Scheduling](#21-manual-scheduling)
  - [2.2) Automatic Scheduling](#22-automatic-scheduling)
  - [2.3) Resource Requests & Limits](#23-resource-requests--limits)
  - [2.4) Daemon Sets](#24-daemon-sets)
  - [2.5) Static Pods](#25-static-pods)
  - [2.6) Multiple Schedulers](#26-multiple-schedulers)
  - [2.7) Configuring The Scheduler](#27-configuring-the-scheduler)

# 1) Core Concepts

* This is the entire [beginners course](../02.applications-developer/README.md#1-core-concepts) recapped, with some of the [developers course](../02.applications-developer/README.md#2-configuration) recapped, and a couple of new sections of new topics or additional details of existing topics.

**Note:** For simplicity I have merged everything from the beginners course into [developers course](../02.applications-developer/README.md#1-core-concepts)

* Master - manage, plan, schedule, and monitor nodes
  * Every component together is called the control plane.
* Workers - host applications as containers

* Container runtime engine (CRE) must be installed on all Nodes in the Cluster. By default this is Docker, it can be others though like containerd or rkt.
  * Some control plane components can be run as containers instead of system binaries. For example DNS and networking solutions. This is why the CRE must be installed onto the master nodes.

![cluster-architecture.png](cluster-architecture.png)

## 1.1) ETCD

* A distributed database that stores data in a key/value format, e.g. a map.
* It is used to quickly store and retrieve small chunks of data.
* The ETCD service listens on port 2379 by default.
* In k8s ETCD stores information about things like:
  * Nodes
  * Pods
  * Configs
  * Secrets
  * Accounts
  * Roles
  * Bindings
  * etc
* All information from `kubectl get $K8S_OBJECT` is from the ETCD server.
* All changes to the cluster are applied in the ETCD server, and only when the change is applied ETCD is the change considered complete.
* Practice test uses the KubeADM tool. We will also do it from scratch in this course.
  * kubeadm deploys ETCD as Pod in the kube-system namespace.
  * When installing from scratch, download the binary and install it onto the master node and start up the ETCD service.
* k8s stores data in ETCD using `/registry/K8s_OBJECTS/`
* In a high availablity environment, there will be multiple master nodes with multiple ETCD services running on them. They all need to know about each other so data replication works correctly.

* There are 2 versions of ETCD commands, version 2 and version 3. Version 2 is the default. Use `export ETCDCTL_API=3` to use version 3. The commands from different versions do not work with the other version.

```bash
# The ETCD control client CLI
etcdctl set key1 value
etcdctl get key1

# When starting ETCD on a master you need to provide the certificates.
kubectl exec etcd-master -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt  --key /etc/kubernetes/pki/etcd/server.key" 

```

## 1.2) Kube-API Server

* This is the primary management component of k8s. It is responsible for orchestrating all operations within the cluster. The API is used by users and cluster components to communicate with the server. There are 4 stages of this process:
1. Authenticate the user sending the request
2. Validate the request
3. Retrieve or update the data from ETCD
4. Send a response
* The Kube API server periodically requests status reports from the kubelet agents so it can monitor the status of Nodes and their resources.
* The Kube API server is the only component in the cluster that interacts with the ETCD data store.
* This is running either as an O/S service or a Pod in the kube-system namespace.

## 1.3) Kube Controller Manager

https://kubernetes.io/docs/concepts/architecture/controller/

* A **Controller** is a non-terminating loop that regulates the state of the system. i.e. they watch the state of the k8s cluster and make or request changes to move the current state of the cluster closer to the desired state.
* There are various Controllers in the cluster, such as:
  * Controller Manager
  * Node Controler takes care of nodes, new and existing.
  * Replication Controller ensures the desired number of Pods are running at all times.
  * There are many Controllers in the cluster, whatever intelligence that you see by k8s objects (e.g. deployments, jobs, etc) this is implemented by their respective Controller.
* All Controllers in the cluster are installed via the Kube-Controller-Manager bundle. This is running either as an O/S service or a Pod in the kube-system namespace.

## 1.4) Kube Scheduler

* Identifies the right Node to place the Pod on, based on the Pod's resource requirements and contraints, and the Node's available resources and contraints. The constraints are things like Taints, Tolerations, and NodeAffinity.
* This does not place Pods onto Nodes, it just identifies the Node for placement. The kubelet actually places the Pod onto the Node.
* This is running either as an O/S service or a Pod in the kube-system namespace.

## 1.4) Kubelet

* It listens for instructions from the Kube-API server and performs those instructions when received. This could be deploying new resources, destroying existing resources, or giving information updates about existing resources.
* Responsible for placing a Pod onto a Node after the Kube Scheduler identifies the correct Node to place it on.
* You must always manually install this on your Worker Nodes, even if you install your Cluster via Kubeadm. This will be running as an O/S level service.

## 1.5) Kube Proxy

* This is a process running on each Node that enables communication between every Pod on every Worker Node.
* It can use IP Tables rules on each Node in the cluster to create forwarding traffic rules. This is how ClusterIP Services work.
* This is running either as an O/S service or a Pod in the kube-system namespace. It is deployed as a Daemon Set so there always 1 Pod running on each Node in the cluster.

## 1.6) Imperative vs Declarative

* When trying to achieve a goal, **the imperative approach** specifies exactly what steps to do and how to do them to achieve the goal.
* When trying to achieve a goal, **the declarative approach** only specifies what the goal is. The details of how the goal is reached are abstracted away.

![imperative-v-declartive-v1.png](imperative-v-declartive-v1.png)

* The declarative approach is used in infrastructure as code (IAS). Tools like Ansible ingest YAML files that declare what the final state needs to be and Ansible works out how to do it. Ansible does this in an idempotent way, i.e. running the declarative process one or many times will always produce the same result.

![imperative-v-declartive-v2.png](imperative-v-declartive-v2.png)

* In k8s the majority of `kubectl` commands are the imperative approach. This is great for the exam since you can get things done quickly.
* In k8s the `kubectl apply` command uses YAML files to work out what needs to be done to get the desired state. This is the declarative approach in k8s.

![imperative-v-declartive-v3.png](imperative-v-declartive-v3.png)

## 1.7) Kubectl Apply Command

https://kubernetes.io/docs/tasks/manage-kubernetes-objects/declarative-config/

* The `kubectl apply` command looks at the current configuration and figures out what changes need to be made to reach the desired state. This may be creating, updating, or delete objects.
* The `kubectl apply` command uses 3 sets of data points to determine what it needs to do. These are:
1. The local YAML definition file
2. The live (i.e. in memory) k8s object definition
3. The last applied configuration within the live k8s object. This is the local YAML definition file converted to JSON and stored inside the live k8s object.

![kubectl-apply-v1.png](kubectl-apply-v1.png)

* The last applied configuration is stored inside of `/metadata/annotations/kubectl.kubernetes.io/last-applied-configuration/` as a JSON string.

![kubectl-apply-v2.png](kubectl-apply-v2.png)

# 2) Scheduling


```bash
# check for a scheduler running as a pod
kubectl get pods --namespace kube-system | fgrep scheduler
# check for a scheduler running as a service
ps aux | fgrep 'scheduler'

# Using multiple labels
kubectl get $K8s_OBJECT --selector='key1=value1,key2=value2,key3=value3'
```

## 2.1) Manual Scheduling

`/spec/nodeName/$NODE_NAME` can be used to manually schedule a Pod to a Node. This is the simplest form of Pod assignment is rarely used. If this field isn't empty, the scheduler will try to place the Pod onto the specified Node only. This has 3 limitations:

1. If the `nodeName` used doesn't exist then the Pod will never run.
2. If the `nodeName` used doesn't have the required resources that the Pod needs then the Pod will never run.
3. The `nodeName` in a cloud environment isn't stable and will change at some point in time.

## 2.2) Automatic Scheduling

The topics Labels & Selectors, Taints & Tolerants, and Node Selector and Node Affinity are covered in the developer's course under the section [Assigning Pods To Nodes](../02.applications-developer/README.md#26-assigning-pods-to-nodes)

![nodename-v1.png](nodename-v1.png)

## 2.3) Resource Requests & Limits

The details for this can be found in in the developer's course under the section [Resources](../02.applications-developer/README.md##25-resources)

## 2.4) Daemon Sets

https://kubernetes.io/docs/concepts/workloads/controllers/daemonset/

* A **Daemon Set** ensure that all Nodes in the cluster run a copy of a Pod. As new Nodes are added to the cluster, the Daemon Set runs the desired Pod on the new Node. It does using the default scheduler and node affinity rules. Obviously when Nodes are removed from the cluster the Daemon Set Pod will be removed too. Daemon sets are ignored by the Kube Scheduler.

![daemon-set-v1.png](daemon-set-v1.png)

* Some typical use cases are:
  * Running a cluster management Pods (e.g. kube-proxy Pod in the kube-system namespace) on every node.
  * Running log collection daemon on every node.
  * Running node monitoring daemon on every node.

![daemon-set-v2.png](daemon-set-v2.png)
![daemon-set-v3.png](daemon-set-v3.png)

* The DaemonSet YAML definition file is almost identical to a Deployment YAML definition file.

![daemon-set-v4.png](daemon-set-v4.png)

```bash
kubectl get daemonsets
kubectl get ds
kubectl describe ds $NAME
# Create a deployment and then edit the YAML and change it to a DaemonSet
# Need to remove replicas, strategy, and any extra fields.
kubectl create deployment $NAME --image=$NAME --dry-run -o yaml > $YAML_FILE
```

## 2.5) Static Pods

https://kubernetes.io/docs/tasks/configure-pod-container/static-pod/

* **Static Pods** are automatically created by the kubelet daemon using a filesystem based or web hosted based YAML definition file, rather than one supplied via the kube-apiserver. The Static Pod is only created for the Node that the YAML defintion file is associated with. The Statics Pods are created outside of control plane management tools, and are available as read only objects within the cluster. To delete the Static Pod, just delete the YAML defintion file. Static Pods are completely ignored by the Kube Scheduler.

![static-pods-v1.png](static-pods-v1.png)

* The location of the filesystem or web hosted based YAML defintion file is passed in to the kubelet daemon through its O/S service file. The `--pod-manifest-path=$PATH` or `--pod-manifest-path=$CONFIG_FILE` option is used for filesystem YAML defintion files and `--manifest-url=$URL` is used for web hosted YAML definition files.
  * In older versions it can be found at `--config=$PATH` or `--config=$CONFIG_FILE`


![static-pods-v4.png](static-pods-v2.png)
![static-pods-v2.png](static-pods-v3.png)

* Static Pods will typically have a Node name in their name as a suffix, something like `$POD_NAME-$NODE_NAME`. So you can use the `kubectl get po -A | grep '$NODE_NAME'` to look for Static Pods.
* A typical use case for using Static Pods is to deploy the control plane componenets on each Node. This is how kubeadm sets up control plane components in the cluster.

![static-pods-v3.png](static-pods-v4.png)

* If you want to view the running containers of a Static Pod before the other cluster components are avaiable, you need to use `docker ps` to see them.

```bash
# Find the path or config file that has the path to where static pod YAML definition files are stored
ps aux | grep kubelet | grep config
```

```
# Output
root      4871  0.0  0.1 4151324 107740 ?      Ssl  07:56   1:07 /usr/bin/kubelet --bootstrap-kubeconfig=/etc/kubernetes/bootstrap-kubelet.conf --kubeconfig=/etc/kubernetes/kubelet.conf --config=/var/lib/kubelet/config.yaml --network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2
```

```bash
# --config=/var/lib/kubelet/config.yaml
grep static /var/lib/kubelet/config.yaml
```

```
# Output
staticPodPath: /etc/kubernetes/manifests
```
## 2.6) Multiple Schedulers

## 2.7) Configuring The Scheduler



Editing in memory Pods is restricted compared to editing in memory Pod templates from a Deployment. 