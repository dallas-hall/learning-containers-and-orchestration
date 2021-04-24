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
- [3) Monitoring & Logging](#3-monitoring--logging)
  - [3.1) Monitoring](#31-monitoring)
  - [3.2) Logging](#32-logging)
- [4) Application Lifecycle Management](#4-application-lifecycle-management)
  - [4.1) Rolling Updates & Rollbacks](#41-rolling-updates--rollbacks)
  - [4.2) Commands & Arguments](#42-commands--arguments)
  - [4.3) Environment Variables](#43-environment-variables)
  - [4.4) Secrets](#44-secrets)
  - [4.5) Scaling Applications](#45-scaling-applications)
  - [4.6) Multi-container Pods](#46-multi-container-pods)
    - [4.6.2) Monolithic vs Microservices](#462-monolithic-vs-microservices)
    - [4.6.1) Design Patterns](#461-design-patterns)
  - [4.7) initContainers](#47-initcontainers)
  - [4.8) Self Healing Applications](#48-self-healing-applications)
- [5) Cluster Maintenance](#5-cluster-maintenance)
  - [5.1) O/S Upgrades](#51-os-upgrades)
  - [5.2) Software Versions](#52-software-versions)
  - [5.2) Cluster Upgrades](#52-cluster-upgrades)
    - [5.2.1) Master Upgrade](#521-master-upgrade)
    - [5.2.1) Worker Upgrade](#521-worker-upgrade)
  - [5.2) Backup & Restore Methods](#52-backup--restore-methods)
- [6) Security](#6-security)
  - [6.1) Primitives](#61-primitives)
  - [6.1) Authentication](#61-authentication)
  - [6.2) TLS Encryption](#62-tls-encryption)
    - [6.2.1 ) TLS Basics](#621--tls-basics)
    - [6.2.2) TLS In k8s](#622-tls-in-k8s)
    - [6.2.2.1) Creating Digital Certificates For k8s](#6221-creating-digital-certificates-for-k8s)
    - [6.2.2.2) Certificates API](#6222-certificates-api)
    - [6.2.2.3) Kube Config](#6223-kube-config)
  - [6.3) API Groups](#63-api-groups)
  - [6.4) Authorisation](#64-authorisation)
    - [6.4.1) RBAC](#641-rbac)
    - [6.4.2) Namespaced vs Cluster Scoped](#642-namespaced-vs-cluster-scoped)
  - [6.5) Security](#65-security)
    - [6.5.1) Image Security](#651-image-security)
  - [6.5) Network Policies](#65-network-policies)
- [7) Storage](#7-storage)
  - [7.1) Docker Storage](#71-docker-storage)
    - [7.1.1) Storage Drivers](#711-storage-drivers)
    - [7.1.2) Volume Drivers](#712-volume-drivers)
    - [7.1.3) Container Storage Interface](#713-container-storage-interface)
  - [7.2) k8s Storage](#72-k8s-storage)
    - [7.2.1) Volumes](#721-volumes)
    - [7.2.2) Persistent Volumes](#722-persistent-volumes)
    - [7.2.3) Persistent Volume Claims](#723-persistent-volume-claims)
    - [7.2.4) Storage Classes](#724-storage-classes)
- [8) Networking](#8-networking)
- [9) Installation, Configuration, & Validation](#9-installation-configuration--validation)
- [10) Troubleshooting](#10-troubleshooting)

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

The details for this can be found in in the developer's course under the section [Resources](../02.applications-developer/README.md#25-resources)

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

* You can create your custom scheduling algorithm and deploy it into the cluster. k8s allows for multiple schedulers running at the same time.
* When installing the `kube-scheduler` for the first time, if you don't give it a name it will automatically be called `default-scheduler`. You can supply whatever name you like.

![custom-scheduler-v1.png](custom-scheduler-v1.png)

Note: This example is using the same scheduler in the example.

* kubeadm deploys the scheduler as a Pod. You can find its Static Pod defintion at `/etc/kubernetes/manifests/` or the path you configured yourself.
  * The `/spec/containers/[i]/command` array has all the command options. The `--leader-elect=true` option is used when there are multiple copies of the scheduler running on multiple Master Nodes in a HA setup. Only one scheduler can be active at a time, this option chooses the active scheduler.
  * The `/spec/containers/[i]/command` array has all the command options. The `--leader-elect=false` option is used when there are multiple copies of the scheduler running on one Master Node. Only one scheduler can be active at a time, this option chooses the active scheduler.

![custom-scheduler-v2.png](custom-scheduler-v2.png)

* A Pod can manually choose its scheduler by using the `/spec/schedulerName/` option. If the custom scheduler isn't working properly, the Pod will be in a PENDING state.

![custom-scheduler-v3.png](custom-scheduler-v3.png)

* Use `kubectl get events` to find scheduler events which will tell you which scheduler was used for a Pod.

![custom-scheduler-v4.png](custom-scheduler-v4.png)

```bash
# View k8s related events, useful for troubleshooting
kubectl get events

# View the scheduler logs
kubectl -n kube-system logs $SCHEDULER_POD_NAME
```

# 3) Monitoring & Logging

## 3.1) Monitoring

Details previously covered in the developer's course under the section [Monitoring](../02.applications-developer/README.md#35-monitoring)

## 3.2) Logging

Details previously covered in the developer's course under the section [Logging](../02.applications-developer/README.md#34-logging)

# 4) Application Lifecycle Management

## 4.1) Rolling Updates & Rollbacks

Details previously covered in the developer's course under the section [Deployment Updates and Rollbacks](../02.applications-developer/README.md#161-deployment-updates-and-rollbackss) and [Deployment Updates & Rollbacks](../02.applications-developer/README.md#42-deployment-updates--rollbacks)

## 4.2) Commands & Arguments

**Note:** This is not on CKA exam but good to understand.

Details previously covered in the developer's course under the section [Commands & Arguments](../02.applications-developer/README.md#21-commands--arguments)

## 4.3) Environment Variables

Details previously covered in the developer's course under the section [Enviroinment Variables](../02.applications-developer/README.md#22-enviroinment-variables)

**Note:** These should match POSIX environment variable naming conventions so they are created properly within the container and are viewable with `printenv`.

## 4.4) Secrets

Details previously covered in the developer's course under the section [Secrets](../02.applications-developer/README.md#secrets)

## 4.5) Scaling Applications

Details previously covered in the developer's course under the section [k8s Deployments Recap](../02.applications-developer/README.md#16-k8s-deployments-recap)

## 4.6) Multi-container Pods

### 4.6.2) Monolithic vs Microservices

Details previously covered in the developer's course under the section [Multi-Container Pods](../02.applications-developer/README.md#3-multi-container-pods)

### 4.6.1) Design Patterns

Details previously covered in the developer's course under the section [k8s Implementation](../02.applications-developer/README.md#32-k8s-implementation)

**Note:** CKA only uses sidecar containers. The other 2 patterns are for CKAD.

## 4.7) initContainers

https://kubernetes.io/docs/concepts/workloads/pods/init-containers/

**initContainer**s are containers that are run before the app containers are started. They always run to completion, if they dont complete successfully the Pod will be restarted. The restart policy of never can change this. Also, you can have multiple initContainers too, each initContainer is run one at a time in sequential order. Each initContainer must complete successfully before the next one starts. When all initContainers have completed successfully, the main application container will start. They are typically used for set up tasks.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: myapp-initcontainer
    image: busybox
    command: ['sh']
    args: ['-c', 'git clone $REPO; done']
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp-pod
  labels:
    app: myapp
spec:
  containers:
  - name: myapp-container
    image: busybox:1.28
    command: ['sh', '-c', 'echo The app is running! && sleep 3600']
  initContainers:
  - name: init-myservice
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup myservice.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
  - name: init-mydb
    image: busybox:1.28
    command: ['sh', '-c', "until nslookup mydb.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for mydb; sleep 2; done"]
```

## 4.8) Self Healing Applications

Note: Not covered in CKA, covered in CKAD. This using ReplicaSets and Liveness, Readiness, and Startup probes.

# 5) Cluster Maintenance

## 5.1) O/S Upgrades

* When a Node goes offline, by default the Master Node waits 5 minutes for an offline Worker Node to come back online before pronouncing it dead. This time limit is known as the pod evicition timeout and it set on the `kube-controller-manager` process when its starting.
  * If it is pronounced dead after the pod eviction timelimt, eligible Pods (i.e. inside of a Deployment) will be placed onto other Worker Nodes. Ineligible Pods won't be recreated anywhere.
  * If it comes back online before the pod eviction timelimit, the Pods will be recreated on that Node.
* When you manually bring down a Worker Node, you can force the Pods on that Node to be recreated on other Nodes by using `kubectl drain $NODE`. A drained Node cannot be used by the Scheduler as it is cordoned off from other Nodes. When you bring the Node back online, you will need to manually uncordon it with `kubectl uncordon $NODE`. This doesn't mean Pods will be recreated back there, it just means the Node is available for scheduling again.
* You can manually cordon off a node with `kubectl cordon $NODE` which will make the Node unavailable to the Scheduler but it doesn't evict all Pods from the Node.

```bash
# ignore daemonset pods when draining
kubectl drain $NODE --ignore-daemonsets 

# remove pods that won't automatically be rescheduled
kubectl drain $NODE --force

# stop pods being scheduled onto a node but don't evict any pods
kubectl cordon $NODE

# allow pods to be scheduled onto the node again, needed after a drain or cordon
kubectl uncordon $NODE
```

## 5.2) Software Versions

* Kubernetes follows [Semantic Versioning](https://semver.org/) which has `MAJOR.MINOR.PATCH` version numbers.
  1. MAJOR version when you make incompatible API changes,
  2. MINOR version when you add functionality in a backwards compatible manner, and
  3. PATCH version when you make backwards compatible bug fixes.

**Note:** Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.

![semantic-versioning-v1.png](semantic-versioning-v1.png)
![semantic-versioning-v2.png](semantic-versioning-v2.png)

* `kubectl get nodes -o wide` or `kubectl version --short` shows the k8s semantic version of `kubelet`.
* The [k8s github repo release page](https://github.com/kubernetes/kubernetes/releases) has all the released versions of k8s. You can download the file which contains all the control plane components within it. All of the k8s supplied control plane components will have the same semantic version, but the third party supplied control plane components will have different semantic version numbers.

![semantic-versioning-v3.png](semantic-versioning-v3.png)

## 5.2) Cluster Upgrades

* Searching for 'upgrading kubeadm' in the k8s documentation page brings up [upgrading kubeadm clusters](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/) which has all the steps you need to upgrade via kubeadm.
* The Kube API Server is the primary component in the control plane, no other core k8s control plane components can have a higher version than it. But they can be at lower versions, the rules are:
  * The Controllers and Scheduler can be the same version or 1 behind.
  * Kubelet and Kube Proxy can be the same version or up to 2 versions behind.
  * `kubectl` can be the same version, 1 version behind, or 1 version ahead.

![upgrading-cluster-v1.png](upgrading-cluster-v1.png)

* This version differencing allows upgrading, component by component if desired. k8s only supports the 3 latest minor versions. You must upgrade 1 minor release version at a time, you cannot jump minor versions unless you completely reinstall.

![upgrading-cluster-v2.png](upgrading-cluster-v2.png)

* There are 3 high level steps to the `kubeadm` cluster upgrade process:
  1. Upgrade a primary control plane node.
  2. Upgrade additional control plane nodes.
  3. Upgrade worker nodes.
* The Master Node must be taken offline when upgrading it. This means the cluster has no management features avaiable, but Worker Node Pods will continue to run. But if one does there is no ReplicationController to bring the Pod back up.

![upgrading-cluster-v3.png](upgrading-cluster-v3.png)

* There are 3 strategies to use when upgrading Worker Nodes.
  1. You can upgrade all Worker Nodes at once. But that has an outage for users.
  2. You can upgrade the Worker Nodes one at a time. This has no outage for users.
  3. You can add new Worker Nodes to the cluster that already have the desired k8s version and then remove old Worker Nodes from the cluster. This has no outage for users and is easily done in cloud environments.

### 5.2.1) Master Upgrade

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/#upgrading-control-plane-nodes

```bash
# Plan the upgrade
kubeadm upgrade plan

# Upgrade kubeadm - https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/#determine-which-version-to-upgrade-to
# Find the version
yum list --showduplicates kubeadm --disableexcludes=kubernetes

# Upgrade, replace n with the version from above
yum install -y kubeadm-1.21.n --disableexcludes=kubernetes

# Verify the upgrade
kubeadm version

# Upgrade the rest of the control plane
sudo kubeadm upgrade apply v1.21.n

# Drain before upgrading kubelet & kubectl
kubectl drain $MASTER_NODE --ignore-daemonsets

# Upgrade kubelet & kubectl as kubeadm doesn't upgrade this
yum install -y kubelet-1.21.n kubectl-1.21.n--disableexcludes=kubernetes

# Restart kubelet service
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Allow scheduling again
kubectl uncordon $MASTER_NODE
```

### 5.2.1) Worker Upgrade

**Note:** When upgrading the cluster, all `kubectl` commands must be run on the Master Node. e.g. `kubectl drain $WORKER_NODE` must be run on the Master Node.

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/#upgrade-worker-nodes

```bash
# Upgrade, replace n with the version from above
yum install -y kubeadm-1.21.n --disableexcludes=kubernetes

# Upgrade worker node
sudo kubeadm upgrade node

# Drain before upgrading kubelet & kubectl - RUN THIS FROM THE MASTER
kubectl drain $WORKER_NODE

# Upgrade kubelet & kubectl as kubeadm doesn't upgrade this
yum install -y kubelet-1.21.n kubectl-1.21.n--disableexcludes=kubernetes

# Restart kubelet service
sudo systemctl daemon-reload
sudo systemctl restart kubelet

# Allow scheduling again - RUN THIS FROM THE MASTER
kubectl uncordon $WORKER_NODE
```

## 5.2) Backup & Restore Methods

* There are 2 things to consider when backing up:
  1. k8s objects
     * These can be backed up via their YAML defintion files. The YAML defintion files should be stored in a code repo. They can be recreated at any time.
     * You can also back up all of the resource manually by dumping their YAML defintions file. Tools like Velero can do this.
     * You can also back up this via backing up ETCD.  The `--data-dir` is what you need to back up, or just use the inbuilt ETCD back up tools.
  1. Persistent storage, the Pods` data needs to be backed up. There are third party tools for this, like Velero.

```bash
# k8s ETCD shiz
# Only one API version can be used at a time, and some commands only exist in 1 API version
export ETCDCTL_API=2
export ETCDCTL_API=3

# If ETCD database is TLS-Enabled, the following options are mandatory
# --cacert # vertify TLS certificates using CA bundle
# --cert # identify secure client using TLS cert
# --endpoints=[127.0.0.1:2379] # default ETCD bind address and port
# --key # the TLS key

# Save a backup (only works with API 3): etcdctl snapshot save -h
etcdctl snapshot save /opt/snapshot-pre-boot.db \
--cert=/etc/kubernetes/pki/etcd/server.crt \
--cacert=/etc/kubernetes/pki/etcd/ca.crt \
--key=/etc/kubernetes/pki/etcd/server.key

# Check the backup
etcdctl snapshot status /opt/snapshot-pre-boot.db

# If running as a service, stop the kube-apiserver service as you need to restart the ETCD service
systemctl stop kube-apiserver

# Restore from backup (only works with API 3), don't need keys as it is on the local filesystem: etcdctl snapshot restore -h
etcdctl snapshot restore /opt/snapshot-pre-boot.db \
--data-dir /var/lib/etcd-from-backup 

# Update the ETCD static Pod data path
cp /etc/kubernetes/manifests/etcd.yaml ~/etcd.yaml.old

# Update the /volume/[i]/hostPath/ for ETCD so the new host path containing the backup is used inside the container
sed -i -r 's|path: /var/lib/etcd|path: /var/lib/etcd-from-backup|g' /etc/kubernetes/manifests/etcd.yaml

# If running as a service, restart the service daemon, ETCD service, and kube-apiserver service.
systemctl daemon-reload
systemctl restart etcd
systemctl restart kube-apiserver

# Check ETCD is back up
docker ps -a | grep etcd
docker logs $CONTAINER_ID -f

kubectl -n kube-system get pods
kubectl -n kube-system logs $ETCD_POD -f
```

`--listen-client-urls` connect from current node (port 2379)
`--listen-peer-urls` connect from other nodes (port 2380)
`/etc/kubernetes/pki/etcd/` contains TLS files.

# 6) Security

## 6.1) Primitives

* The hosts running k8s must be hardened. Things like:
  * `ssh` hardening such as disabling root access, disabling passwords, using keys for authentication, etc.
* From a k8s perspective, the `kube-apiserver` is the most important thing to defind. This is because all interactions within the cluster go through it.

## 6.1) Authentication

* **Authentication** confirms that users are who they say they are. There are 2 types of users, humans and computers. Details previously covered in the developer's course under the section [Service Accounts](../02.applications-developer/README.md#service-accounts)
* All requests to the cluster go through the `kube-apiserver` and the user making the request is authenicated before the request is fulfilled.
* There are 4 authentication mechanisms to access the cluster via the `kube-apiserver`:
  1. Basic authentication with passwords which are stored in a text file with 4 columns. Password,username,user id, and group. The username and password would be supplied with `curl -u $USER:$PASSWORD`
     * **Note:** deprecated in v1.19
  2. Basic authenticaiton with tokens which are stored in a text file with 4 columns. Token,username,user id, and group. The token would be supplied with `curl --header Authorization: Bearer $TOKEN`
     * **Note:** deprecated in v1.19
  3. Certificates.
  4. Third party identity services, e.g. LDAP or Kerberos.

**Note:** Service Accounts are not in the CKA exam, they are in CKAD. They are mentioned here for information only.

## 6.2) TLS Encryption

* All communication between the components in the cluster is secured using TLS encryption. TLS certificates can also be used for user authentication.

### 6.2.1 ) TLS Basics

* A **digital certificate (X.509)** provides a trusted link between a public key and an entity (e.g. a business, domain name, etc). This is a trusted link because it has been verified (i.e. signed) by a trusted third party (i.e. a Certificate Authority).

![certificates-v1.png](certificates-v1.png)

* A digital certificate needs to be signed by a Certificate Authority for it to be considered trusted and valid. Self signed certificates cannot be trusted as anyone can create them. This signing and validation request is known as a **Certificate Signing Request (CSR).**
* A **Certificate Authority (CA)** is a public, well known, and trusted organisation that will validate the information within CSR's and sign certificates. They sign certificates with their private key. Their public key is built into the browser and O/S and is used to validate a CA signed certificate. There are 2 types of CA certificates:
  1. A **root certificate** is used by CAs to issue other certificates called intermediates.
  2. An **intermediate certificate** is by CAs to issue end user certificates for servers and clients.
* You can host your own private CA so you can validate internal websites. You must bundle your private CA's public key into the browser and O/S so your private CA signed certificates can be validated.

![certificates-v2.png](certificates-v2.png)

* There are 4 steps to an CSR:
  1. The server generates an OpenSSL public/private key pair.
  2. The server creates a Certificate Signing Request (CSR) based on its public key.
  3. The Certificate Authority (CA) validates the information within the CSR and signs the certificate with its private key. The signed certificate is sent back to the server.
  4. The server uses the signed certificate to establish HTTPS connections with others. It does this by sending sending the signed certificate to others for use in symetric key exchange.
* A certificate contains important information about who owns the domain and the server's public key. Both are used to verify the server's identity. A CA will verify this information before signing it.
  * e.g. the certificate's Subject and Subject Alternative Name defines what domains and IP addresses that the certificate is valid for.
* SSL/TLS uses assyemtric encryption for secure symetric encryption key exchange. Symeteric encryption and the exchange key is used to create sessioned based encryption. There are 5 steps to establishing HTTPS:
  1. **Client Hello** - The client sends a list of supported cipher suites.
  2. **Server Hello** - The server chooses the best cipher it can support from the client's cipher suites. It replies with the cipher choice and its signed certificate.
  3. **Client Key Exchange** - The client validates the server's certificate with a CA certificate bundled in its O/S or browser, and extracts the server's public key from the certificate. The client generates a pre-master key, encrypts that with the server's public key, and sends it back to the server.
  4. **Change Cipher Suite** - The server decrypts the pre-master key with its private key, and uses the pre-master key to create a symmetric key. The symmetric key is used to encrypt a message sent back to the client.
  5. **Establish Secure Connection** - The client uses the pre-master key to create the same symmetric key as the server did. It decrypts the message from the server and an encrypted session has been established between the client and server with the same symmetric key that both the client and server created from the pre-master key.

![certificates-v3.png](certificates-v3.png)

* Certificate naming conventions are typically:
  * A public key file has is named `*.crt` or `*.pem`, i.e. the public key doesn't have the word key in its name or extension.
  * A private key file has is named `*.key` or `*-key.pem`, i.e. the private key has the word key in its name or extension.

![certificates-v4.png](certificates-v4.png)

### 6.2.2) TLS In k8s

* From a k8s perspective, there are 3 types of certificates:
  1. **Root certificates** which are installed on the CA server and also on the server and client. k8s supports mulitiple CAs, so you can have one CA for client certificates and one CA for server certificates. 
  2. **Server certificates** which are installed on the k8s cluster and used by cluster components. These are verified by the cluster.
  3. **Client certificates** which are installed onto the clients and use when connecting to the cluster. These are verified by the cluster.
* The following control plane components require their own server certificates:
  * The Kube API Server
  * The ETCD Server
  * The Kubelet agents
* The following clients require their own client certificates:
  * Human Administrators
  * The Kube Scheduler
  * The Kube Controller Manager
  * The Kube Proxy
  * Kube API Server to Kubelet agent (optional, can reuse server certificate)
  * Kube API Server to ETCD Server (optional, can reuse server certificate)

![certificates-v5.png](certificates-v5.png)

![certificates-v6.png](certificates-v6.png)

**Note:** In the diagrams above there have been new public/private key pairs created (e.g. Kube API server talking to ETCD server), but you can share the same one as well.

### 6.2.2.1) Creating Digital Certificates For k8s

**Note:** Using `kubeadm` will configure all the certificates for you. The certificates will be deployed inside of Static Pods, so you can view the YAML definition files in `/etc/manifests/kubernetes`. If the control plane components are configured as services, you can view the SystemD service files in `/etc/systemd/system`. You can also log into each Node and look in `/etc/kubernetes/pki`.

```bash
# Create an RSA public and private key pair for ssh
ssh-keygen
id_rsa
id_rsa.pub

# Create an RSA public and private key pair for SSL/TLS
openssl genrsa -out my-private.key 2048
openssl rsa -in my-private.key -pubout > my-public-key.pem
```

```bash
# Create a CA private key
openssl genrsa -out $CA_PRIVATE_KEY 2048

# Create a CA public key, optional as we can extract this from the certificate later
openssl rsa -in $CA_PRIVATE_KEY -pubout > $CA_PUBLIC_KEY

# Create a certificate signing request
openssl req -new -key $CA_PRIVATE_KEY -out $CA_CSR -subj "CN=KUBERNETES-CA"

# Self sign the CA certificate
openssl x509 -req -in $CA_CSR -signkey $CA_PRIVATE_KEY -out $CA_CERTIFICATE

# Display the contents of the CA certificate
openssl x509 -in $CA_CERTIFICATE -text -noout
```

**Note:** This CA certificate needs to be used when generating all client and server certificates.

```bash
# Create an administrator privay key
openssl genrsa -out $ADMIN_PRIVATE_KEY 2048

# Create a certificate signing request, the CN can be anything but the O must have the admin group in it.
openssl req -new -key $ADMIN_PRIVATE_KEY -out $ADMIN_CSR -subj "CN=kube-admin/O=system:masters"

# Self sign the CA certificate
openssl x509 -req -in $ADMIN_PRIVATE_KEY -CA $CA_CERTIFICATE -CAkey $CA_PRIVATE_KEY -out $ADMIN_CERTIFICATE

# Display the contents of the CA certificate
openssl x509 -in $ADMIN_CERTIFICATE -text -noout
```

![certificates-v7.png](certificates-v7.png)

**Note:** The user certificates can be moved into `KUBECONFIG` which is used to connect and authenticate with the server.

![certificates-v8.png](certificates-v8.png)

**Note:** All system components must have 'system' as the prefix in their certificate CN field, e.g. system:kube-controller-manager.

![certificates-v9.png](certificates-v9.png)

![certificates-v10.png](certificates-v10.png)

**Note:** The Kube API Server must have Alternative Names present the certificate.

![certificates-v11.png](certificates-v11.png)

**Note:** There needs to be a certificate for Kubelet on each Node in the cluster. The certificates are named after the Node.

![certificates-v12.png](certificates-v12.png)

**Note:** Each Node also needs to have client certificates for Kubelet so they can talk to the Kube API Server. Since they are system components they need to have the name `system:node:$NODE_NAME`. These certificates go into the KUBECONFIG file and allow Kubectl to work.

![certificates-v13.png](certificates-v13.png)

**Note:** When viewing the certificate's contents with `openssl x509 -in $CA_CERTIFICATE -text -noout` you need to pay attention to `Issuer`, `Validity`, `Subject`, and the `Subject Alternative Names`.

**Note:** When troubleshooting certificates, you need to look at the logs. This will either be `journalctl -u $CONTROL_PLANE_SERVICE -l` or `kubectl -n kube-system logs $CONTROL_PLANE_POD`. If that isn't work, trying Docker with `docker logs $CONTAINER_ID -f`.

### 6.2.2.2) Certificates API

* The CA server can be any server, since it is just hosting the public/private key pair. `kubeadm` makes the Master Nodes the CA servers.
* Instead of manually signing certificates through the command line, you can use the Certificates API and the CSR object.

https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/

```bash
# Generate OpenSSL private key
openssl genrsa -out $PRIVATE_KEY 2048

# Create CSR for new Admin, or use a CSR object
openssl req -new -key $PRIVATE_KEY -subj "/CN=$USER/O=system:masters" -out $CSR
```

**Note:** The user's public key must be base64 encoded. Do this with `cat $PUBLIC_KEY |base64 | tr -d '\n' && echo`. We are using `tr` to delete all newlines as the CSR YAML definition file doesn't accept them. Use the script at https://kubernetes.io/docs/reference/access-authn-authz/certificate-signing-requests/#create-certificatesigningrequest and add `/metadata/name/$USERNAME`, `/spec/request/$BASE64_PUBLIC_KEY`, and the correct `/spec/groups/[i]/$USER_PERMISSION`.

![csr-v1.png](csr-v1.png)

```bash
# View certificate signing requests
kubectl get csr

# Deny CSR requests
kubectl certificate deny $USER

# Approve the CSR and k8s will create new certificate for the user using the CA certificate.
kubectl certificate approve $USER

# Get the certificate to share to the user
kubectl get csr $USER -o yaml
```

![csr-v2.png](csr-v2.png)

**Note:** The Controller Manager is responsible for all certificate related operations.

### 6.2.2.3) Kube Config

* The **Kube Config file** is used instead of supplying the certificates with every `curl` or `kubectl` command.

![kubeconfig-v1.png](kubeconfig-v1.png)

* The default Kube Config file is located at `~/.kube/config` but can be named whatever you like. You can set this in the environment variable `KUBECONFIG` or `kubectl --config $FILE`.
* The Kube Config file has 3 sections:
  1. `/clusters/[i]` contains all the k8s clusters you can access. The server CA certificate and connectiong details goes here.
  2. `/contexts/[i]` define which user account will be used to access which cluster. This uses the existing users and clusters within the
  3. `/users/[i]` are the accounts that you use to access the clusters. The username, certificate, and key goes here.

![kubeconfig-v2.png](kubeconfig-v2.png)
![kubeconfig-v3.png](kubeconfig-v3.png)

* The `/current-context` specifies which is the default context to use from the Kube Config file.
* The `/contexts/[i]/context/namespace` specifies which is the default namespace to use for the context from the Kube Config file.

```bash
# There are a variety of Kube Config related commands with kubectl
kubectl config $ARGS

# View the default ~/.kube/config file
kubectl config view

# View a custom default ~/.kube/my-config file
kubectl config view --kubeconfig=~/.kube/my-config\

# Change the current context being used within the Kube Config
kubectl config use-context $CONTEXT_NAME
```

**Note:** All `kubectl config` commands change the Kube Config file.

* There are 2 ways to specify the certificates to use within a Kube Config file:
  1. Using a relative or absolute path to the certificate file.
  2. Using the base64 encoded string of the certificate file contents.

![kubeconfig-v4.png](kubeconfig-v4.png)

## 6.3) API Groups

* All k8s objects are grouped into different API Groups. Here are some groups from the k8s API:
  1. `/api` is the core group, and provides core cluster functionality through API versions.
  2. `/apis` is the named group, and provides core cluster functionality but through names instead of API versions.
  3. `/logs` used to integrate with third party logging solutions (e.g. prometheus).
  4. `/healthz` used to monitor the health of the cluster.
  5. `/metrics` used to get metric data about the cluster.
  6. `/version` views the version of the cluster.

![api-group-v1.png](api-group-v1.png)

* `/apis` has **API Groups** which provide a variety of functionality that relates to that particular group.
* `/apis` API Groups has **API Resources** which provides the specific implementation for the k8s object within it.
* `/apis` API Groups has API Resources which has **Verbs** (i.e actions) which provides the k8s object actions. Users need access to these Verbs to be able to perform actions in the cluster.

![api-group-v2.png](api-group-v2.png)

* The [k8s API Reference page](https://kubernetes.io/docs/reference/) shows all the API Groups and the objects within them.
* You can view your cluster's API Groups using `curl -k http://$ADDRESS:6443` and you can view your cluster's API Resources using `curl -k http://$ADDRESS:6443/api | grep name`

**Note:** You still need to authenticate with the API, you can do this by passing your certificates via `curl --key $KEY --$CERT --cacert $CA_CERT` or using your KUBECONFIG via `kubectl proxy`.

* `kubectl proxy` launches a local client on `127.0.0.1:8001` can uses your Kube Config File to access the cluster. You just need to replace port 6443 with 8001 when using curl.

![api-group-v3.png](api-group-v3.png)

## 6.4) Authorisation

* **Authorization** gives authenticated users permission to access a resource.
* There are 6 types of authorisation in k8s:
  1. **Node authorisation** is a special mode that authorises API requests made my kubelet agents.
  ![authorisation-v1.png](authorisation-v1.png)
  2. **Attribute Based Access Control (ABAC)** grants access rights to users.
  ![authorisation-v2.png](authorisation-v2.png)
  3. **Role Based Access Control (RBAC**) grants access rights to roles, and roles are assigned to users. This is a common approach for authorisation.
  ![authorisation-v3.png](authorisation-v3.png)
  4. **Webhook** is a HTTP callback, i.e. an event notification using HTTP POST. k8s will query an external REST service when determining user privileges.
  ![authorisation-v4.png](authorisation-v4.png)
  5. **AlwaysAllow** allows all requests in the cluster. This is the default is nothing is set.
  6. **AlwaysDeny** denys all requests in the cluster.
* The authorisation modes are set with the `kube-apiserver --authorization-mode=$ACCESS_MODE1,$ACCESS_MODE2`. When multiple authorisation modes are configured, the access request is checked by going to each mode sequentially until access is granted or all nodes have been visited and no access is granted.
![authorisation-v5.png](authorisation-v5.png)

### 6.4.1) RBAC

* RBAC is commonly used for authentication in many applications. Because it is easy to maintain a single role for many users, than maintaining ABAC for many users.
* When using RBAC, you need to either create a Role and RoleBinding. The **Role** provides the authorised access details and the **RoleBinding** links a user to a Role. This can be created with YAML definition files or imperative commands.

![authorisation-v6.png](authorisation-v6.png)

```bash
# Create a Role
kubectl create role developer --verb=$API_GROUP_VERB1,$API_GROUP_VERB2 --resource=$K8S_OBJECT -n $NAMESPACE

# Create a RoleBinding
kubectl create rolebinding $NAME --role=$ROLE_NAME --user=$USERNAME

# View access permissions for a Role
kubectl describe role $NAME

# View what users can use a Role
kubectl describe rolebinding $NAME

# Check what a user can do
kubectl auth can-i $API_GROUP_VERB $K8S_OBJECT --as $USER
```

* RBAC can cover namespaces and specific objects within a namespace. Use the `/roles/[i]/resourceNames` array to specific which objects.

![authorisation-v7.png](authorisation-v7.png)

### 6.4.2) Namespaced vs Cluster Scoped

* There are 2 scopes within k8s
  1. Namespaced, i.e. the scope is a namespace.
  2. Cluster scoped, i.e. the scope is the entire cluster.
* Roles and RoleBindings are created within namespaces. If you don't specificy a namespace they will be created in `default`.
* ClusterRoles and ClusterRoleBindings are created within the cluster, i.e. they cover all namespaces within the cluster.
* A ClusterRole can be used to grant access to all resources in all namespaces.

![scope-v1.png](scope-v1.png)

```bash
# View all namespaced scoped objects
kubectl api-resources --namespaced=true

# View all cluster scoped objects
kubectl api-resources --namespaced=false

# Create a ClusterRole
kubectl create clusterrole developer --verb=$API_GROUP_VERB1,$API_GROUP_VERB2 --resource=$K8S_OBJECT

# Create a ClusterRoleBinding
kubectl create clusterrolebinding $NAME --clusterrole=$CLUSTER_ROLE_NAME --user=$USERNAME

# View access permissions for a ClusterRole
kubectl describe clusterrole $NAME

# View what users can use a ClusterRole
kubectl describe clusterrolebinding $NAME

# Check what a user can do
kubectl auth can-i $API_GROUP_VERB $K8S_OBJECT --as $USER
```

## 6.5) Security

The details for this can be found in in the developer's course under the section [Security](../02.applications-developer/README.md#24-security)

### 6.5.1) Image Security

* The `/spec/containers/[i]/image: image-name` value has some rules from Docker:
  * The name of the image is assumed to be the name of the Docker account supplying the image and this account gets implicitly added. e.g. `image: nginx` expands into `image: nginx/nginx` which is `image: docker-hub-username:image-name`
  * The registry used to pull images is assumed to be https://docker.io and this is added implicitly. e.g. `image: nginx` becomes `image: docker.io/nginx/nginx`
  * You can add whatever image registry you like, you just need to specify it like `image: $REPO_URL/$REPO_USERNAME/$IMAGE_NAME`.

![image-security-v1.png](image-security-v1.png)

* To access a private image repository in Docker you need to:
  1. Log in with `docker login $REPO_URL` with a username and password.
  2. Run the app with `docker run $REPO_URL/$USERNAME/$IMAGE_NAME`

![image-security-v2.png](image-security-v2.png)

* To access a private image repository in k8s you need to:
  1. Create a Docker Registry Secret for the docker credentials. `kubectl create secret docker-registry $NAME --docker-server=$URL --docker-username=$USER --docker-password=$PASSWORD --docker-email=$EMAIL`
  2. Supply the `/spec/imagePullSecrets/[i]/name` with the Docker Registry Secret.
  3. Supply the `/spec/containers/[i]/image: $REPO_URL/$USERNAME/$IMAGE_NAME` in the YAML definition file.

![image-security-v3.png](image-security-v3.png)

## 6.5) Network Policies

The details for this can be found in in the developer's course under the section [Network Policy](../02.applications-developer/README.md#53-network-policy)

**Note:** Sometimes you need to add a Network Policy to allow DNS resolution.

# 7) Storage

## 7.1) Docker Storage

### 7.1.1) Storage Drivers

### 7.1.2) Volume Drivers

### 7.1.3) Container Storage Interface

## 7.2) k8s Storage

### 7.2.1) Volumes

The details for this can be found in in the developer's course under the section [Volumes](../02.applications-developer/README.md#61-volumes)

### 7.2.2) Persistent Volumes

The details for this can be found in in the developer's course under the section [Persistent Volumes](../02.applications-developer/README.md#62-persistent-volumes)

### 7.2.3) Persistent Volume Claims

The details for this can be found in in the developer's course under the section [Persistent Volume Claims](../02.applications-developer/README.md#persistent-volume-claims)

### 7.2.4) Storage Classes

The details for this can be found in in the developer's course under the section [Storage Classes](../02.applications-developer/README.md#71-storage-classes)

# 8) Networking

# 9) Installation, Configuration, & Validation

# 10) Troubleshooting

---

**Note:** Editing in memory Pods is restricted compared to editing in memory Pod templates from a Deployment.

**Note:** In the exam you can quickly check object syntax by doing `kubectl explain $K8S_OBJECT --recursive | less` and then search for the syntax you are looking for.
