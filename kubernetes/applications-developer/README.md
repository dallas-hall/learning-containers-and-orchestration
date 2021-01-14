# k8s Application Developer Notes <!-- omit in toc -->

* Second course in a series [beginner, developer, administrator]
* Can do the exam if you want

## Tables Of Contents <!-- omit in toc -->
- [1) Core Concepts](#1-core-concepts)
  - [1.1) Containers](#11-containers)
  - [1.2) Container Orchestration](#12-container-orchestration)
  - [1.3) k8s Architecture Recap](#13-k8s-architecture-recap)
  - [1.4) k8s Pod Recap](#14-k8s-pod-recap)
  - [1.5) k8s Controller Recap](#15-k8s-controller-recap)
    - [Replication Controller](#replication-controller)
    - [ReplicaSet](#replicaset)
  - [1.6) k8s Deployments Recap](#16-k8s-deployments-recap)
    - [1.6.1) Deployment Updates and Rollbacks](#161-deployment-updates-and-rollbacks)
  - [1.7) k8s Namespaces](#17-k8s-namespaces)
  - [1.8) k8s Networking Recap](#18-k8s-networking-recap)
    - [k8s Services](#k8s-services)
      - [NodePort](#nodeport)
      - [ClusterIP](#clusterip)
      - [LoadBalancer](#loadbalancer)
  - [1.9) Imperative Commands](#19-imperative-commands)
- [2) Configuration](#2-configuration)
  - [2.1) Commands & Arguments](#21-commands--arguments)
    - [Docker](#docker)
    - [k8s](#k8s)
  - [2.2) Enviroinment Variables](#22-enviroinment-variables)
    - [Docker](#docker-1)
    - [k8s](#k8s-1)
  - [2.3) ConfigMaps and Secrets](#23-configmaps-and-secrets)
    - [ConfigMaps](#configmaps)
      - [Creation](#creation)
      - [Injection](#injection)
    - [Secrets](#secrets)
      - [Creation](#creation-1)
      - [Injection](#injection-1)
  - [2.4) Security](#24-security)
    - [Docker Security](#docker-security)
      - [Process Isolation](#process-isolation)
      - [Users](#users)
    - [Security Contexts](#security-contexts)
    - [Service Accounts](#service-accounts)
  - [2.5) Resources](#25-resources)
    - [Scheduler](#scheduler)
      - [CPU](#cpu)
      - [RAM](#ram)
  - [2.6) Assigning Pods To Nodes](#26-assigning-pods-to-nodes)
    - [Taints & Tolerations](#taints--tolerations)
      - [Taints](#taints)
      - [Tolerants](#tolerants)
    - [Node Labels](#node-labels)
    - [Node Selectors](#node-selectors)
    - [Node Affinity](#node-affinity)
    - [Combining Taints, Tolerants, & Node Affinity](#combining-taints-tolerants--node-affinity)
      - [Example](#example)
- [3) Multi-Container Pods](#3-multi-container-pods)
  - [3.1) Applicaiton Types](#31-applicaiton-types)
    - [Monolithic Applications](#monolithic-applications)
    - [Microservices](#microservices)
  - [3.2) k8s Implementation](#32-k8s-implementation)
  - [3.3) Observability](#33-observability)
    - [Pod Lifecycle](#pod-lifecycle)
      - [Pod Statuses](#pod-statuses)
      - [Pod Conditions](#pod-conditions)
    - [Readiness Probes](#readiness-probes)
    - [Liveness Probes](#liveness-probes)
  - [3.4) Logging](#34-logging)
  - [3.5) Monitoring](#35-monitoring)
- [4) Pod Design](#4-pod-design)
  - [4.1) Labels & Selectors](#41-labels--selectors)
    - [Labels](#labels)
    - [Selectors](#selectors)
  - [4.2) Deployment Updates & Rollbacks](#42-deployment-updates--rollbacks)
    - [Additional Information](#additional-information)
  - [4.2) Jobs & CronJobs](#42-jobs--cronjobs)
    - [Adhoc Workloads](#adhoc-workloads)
      - [Docker](#docker-2)
      - [k8s](#k8s-2)
    - [Jobs](#jobs)
    - [CronJobs](#cronjobs)
- [5) Services & Networking](#5-services--networking)
  - [5.1) Services](#51-services)
  - [5.2) Ingress](#52-ingress)
    - [Example Website](#example-website)
      - [Initial Setup](#initial-setup)
      - [Scaling The App](#scaling-the-app)
      - [URL:port Instead Of IP:port](#urlport-instead-of-ipport)
      - [Website URL Only](#website-url-only)
      - [Google Cloud Provider](#google-cloud-provider)
      - [Adding Another App And SSL](#adding-another-app-and-ssl)
      - [Replacing With Ingress](#replacing-with-ingress)
    - [How Does Ingress Work](#how-does-ingress-work)
    - [Ingress Controller](#ingress-controller)
      - [Creating An Ingress Controller](#creating-an-ingress-controller)
    - [Ingress Resources](#ingress-resources)
    - [Forward All Traffic To Single Application](#forward-all-traffic-to-single-application)
    - [Route Traffic Based On URL](#route-traffic-based-on-url)
    - [Route Traffic Based On Domain](#route-traffic-based-on-domain)
    - [Useful Commands](#useful-commands)
  - [5.3) Network Policy](#53-network-policy)
    - [Network Traffic Example](#network-traffic-example)
    - [Ingress vs Egress Network Traffic](#ingress-vs-egress-network-traffic)
    - [k8s Network Security](#k8s-network-security)
- [6) State Persistence](#6-state-persistence)

# 1) Core Concepts

* This is the entire Beginner's Course recapped.

## 1.1) Containers

* **Containers** are an isolated environment with its own resources (e.g. processes, network interfaces, storage etc) within an operating system but all containers within the same O/S share the same kernel.

![container example](container-example.png)

* Containers are used to isolate applications from each other. Each container has its own O/S that supports the application and its dependencies.

![container example](container-example-detailed.png)

* A container can only run on the same O/S kernel that it has. So if Docker is running on a Linux kernel, any Linux distribution can run on it. Running a Linux Docker container on Windows actually spins up a Linux VM.

![kernel sharing](kernel-sharing.png)

* Containers are not new but Docker is a high level tool that has made them very popular.
* Docker uses LXC containers.
* Containers are more resource friendly than VMs. They are typically 10s or 100s of MB in size whereas VMs are typically GBs in size.  It is common to run containers within VMs.

![container v vm](container-vs-vm.png)

* A **Docker Image** is a template used to create a **Docker Container**. Thus like in OOP, the Docker Image is the blueprint and the Docker Container is the running instance.

![image v container](image-v-container.png)

* A **Dockerfile** is a file has the necessary steps to build a Docker Image and subsequent Containers.

![Dockerfile](Dockerfile.png)

* Traditionally a developer would hand over the operations team the compiled application and a list of instructions on how to deploy it. This would change with each environment and become complicated quickly. Now a developer just hads the operations team the Dockerfile and they are able to build the Docker Container the same way in each environment.

## 1.2) Container Orchestration

![Container orchestration](container-orchestration.png)

* The process of automatically deploying and managing containers is called **Container Orchestration**. This can provide:
  * Fault tolerance by using multiple compute nodes.
  * Simple application scaling as demand changes.
  * Simple cluster scaling as demand changes.
* **Kubernetes** (aka k8s) is a container orchestration technology from Google, but others exist like Docker Swarm and Mesos for Apache.
  * **Docker Swarm** is easy to set up but lacks features
  * **Apache Mesos** is hard to set up
* k8s supports cloud platforms like Google Cloud Platform (GCP), Amazon Web Services (AWS), and Microsoft Azure.

![Container orchestration](container-orchestration-technologies.png)

## 1.3) k8s Architecture Recap

![cluster](cluster.png)

* A **Node** is physical or virtual machine where k8s is installed. A Node is used as a k8s worker. Also known as a Minion in the past. This is where applications and their containers run. It has:
  * kubelet
  * container runtime
* A **Cluster** is a set of Nodes grouped together. Which provides the ability to deploy applications across multiple Nodes and provide high availability and load balancing.
* The **Master** is another Node in the Cluster. The Master monitors and controls the worker Nodes. It has:
  * kube-apiserver
  * kubelet
  * etcd
  * controller
  * scheduler
  * kubectl

![k8s components](k8s-components.png)

* k8s cluster components
  * **api server** - allows interaction with the k8s cluster. kube-apiserver
  * **etcd** - a distributed key value store which has data to manage the cluster
  * **container runtime** - the software (e.g docker) used to run containers
  * **controller** - make the decisions whether to bring up new containers
  * **scheduler** - distributes work or containers across the nodes
  * **kubelet** - an agent that runs on each Node in the cluster. The worker Nodes commmunication to the Master's kube-apiserver through the kubelet agent.
  * **kubectl** - the command line tool used to deploy and manage clusters
* **Minikube** is a way to quickly install a single node k8s cluster.
* **kubeadm** is a way to quickly install a multi-node k8s cluster.
  1. Need multiple machines or VMs available.
  1. Install a container runtime environment (CRE) like Docker
  1. Install kubeadm onto all of the nodes.
  1. Initialise a master node and worker node(s).
  1. Install networking layer between master and worker(s).
  1. Add worker(s) to the master.

![kubeadm](kubeadm-steps.png)

```bash
# Deploy an application
kubectl run myapp

# Get k8s Cluster information
kubectl cluster-info

# List all Nodes in the Cluster
kubcetl get nodes
```

* The ultimate aim is to deploy an application in the form of containers on a set of machines configured as a k8s Cluster.

## 1.4) k8s Pod Recap

![pods](pods.png)

* A **Pod**
  * Is a single instance of an application. But multiple instances can be run by creating additional Pods.
  * Is the smallest object that can be created in k8s. This object is where containers are run.
  * Can have one or multiple containers. If running multiple containers, the containers are unique applications that are all related (e.g. main container and helper containers). These are created and destroyed together.
  * Multiple containers within a Pod can refer to each other via `localhost` as they share the same network space, they also share the same storage.
  * Are created by YAML files.
* To create Pods, we need access to container images (e.g. a Docker Registry like Docker Hub) and a working k8s Cluster.
* Pods can run in a single Node or Cluster (i.e. multiple Nodes) k8s environment.
* k8s doesn't deploy containers directly onto Nodes, they are deployed into Pods.
* k8s objects are created by YAML files. Each YAML file must contain 4 parts
  * apiVersion = controls what objects you can create. Versions support different types of objects.
  * kind = the type of k8s object you are creating
  * metadata = data about the object, in the form of a dictionary.
  * spec = the objects we are going to run, as a list of dictionaries

```yaml
apiVersion: # What k8s objects can be created
kind: # The tyoe of k8s object being created
metadata: # Data about the k8s object
  ...
spec: # The stuff the k8s object will be doing
  ...
```

![pods](pods2.png)

```yaml
# https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/#pod-templates
# There is always 4 root elements
# The version depends on what you are doing
apiVersion: v1

# The type of object, dictates the type of version
kind: Pod

# Must have name and labels inside of it, the name is the pod name
metadata:
  name: my-nginx-pod
  # Can have any key/value pair here
  labels:
    app: my-nginx-app
    type: front-end

# Which container(s) will be running
spec:
  # Can have multiple containers, but usually 1 container per pod.
  containers:
    - name: nginx-container
      image: nginx

    - name: postgres
      image: postgres
      env:
        - name: POSTGRES_PASSWORD
          value: abc123
```

```bash
# Run a Pod from CLI
kubectl run --generator=run-pod/v1 $POD_NAME --image=$IMAGE_NAME -l $LABEL_KEY=$LABEL_VALUE

# Create a Pod
kubectl create -f pod-definition.yml

# Delete Pod
kubectl delete pod $POD_NAME

# Get Pods information
kubectl get pods
kubectl get pods -o wide
kubectl get all
kubectl describe pods

# Get Pod specific information
kubectl get pod $POD_NAME

# Update Existing Pod With File - remember to delete the existing Pods for the changes to apply
kubectl replace -f mypod-definition.yml

# Update Existing Pod Without File - remember to delete the existing Pods for the changes to apply
kubectl edit pod $POD_NAME

# Extract Pod Definition From Running Pod
kubectl get pod $POD_NAME -o yaml > pod-definition.yaml
kubectl run $POD_NAME--image $IMAGE_NAME --generator=run-pod/v1 --dry-run -o yaml

# Run a pod, expose a port and create a service for it.
kubectl run httpd --image=httpd:alpine --port=80 --expose
```

## 1.5) k8s Controller Recap

* These are the brains behind k8s.
* **Controllers** are processes that monitor k8s objects and respond to accordingly to events.

### Replication Controller

![Replicaiton controller](replication-controller.png)

* A **ReplicationContoller** helps us run multiple instances of a single pod in a Cluster.
* It provides high availability by ensuring that the specified number of Pods is running at all times.
* It provides load balancing and scaling, by creating Pods across Nodes in the Cluster and spans across mutiple Nodes in a Cluster.
* But it is an older technology being replaced by Replica Set

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: my-apps-rc
  labels:
    app: my-app
    type: front-end
spec:
  replicas: 3 # How many Pods to run
  template:
  # Everything from pod-definition file goes here, but exclude apiVersion: and kind:
    metadata:
      name: my-apps-pod
      labels:
        app: my-app
        type: front-end
    spec:
      containers:
        - name: some-container
          image: some-container-image
        - name: some-container-2
          image: some-container-image-2
```

### ReplicaSet

![Labels and Selectors](labels-and-selectors.png)

* Very similar to ReplicationController but it is not the same. The **ReplicaSet** is the modern and recommended replacement.
* The concepts of ReplicationController's apply to ReplicaSets, with the Selector being the major differnece between them.
* The ReplicaSet is in a different apiVersion to the ReplicationController.
* The ReplicaSet is a process that knows which Pods to monitor by the Labels provided during Pod creation.
* The Selector tells the RepliceSet what labels to watch. If any of the Pods matching the watched labels fail, the ReplicaSet will create new ones.
* The Selector tells the ReplicaSet what Pods it can control, even if they weren't created by the ReplicaSet. Thus the ReplicaSet can create its own Pods to monitor or monitor existing Pods.
* You may scale a ReplicaSet by updating the YAML file or update via command line with kubectl, second approach doesn't update the file.
* Labels and Selectors are used in many other places in k8s.

```yaml
# basically same as ReplicationController but the object is now ReplicaSet and has selector property.
# https://kubernetes.io/docs/concepts/workloads/controllers/replicaset/#example### 1.3.1)
apiVersion: apps/v1

# ReplicaSet is the new technology, compared to ReplicationController
kind: ReplicaSet

# All Kubernetes yml files need metadata, and they must have name and label.
metadata:
  name: my-app-replica-set
  # Provide your own key/value pairs here.
  # This should match the nested metadata. Helps the Selector manage P ods.
  labels:
    app: my-app
    type: front-end

spec:
  # How many pods must be running at once
  replicas: 3
  # Required by ReplicaSet, not ReplicationController. Explains what pods fall under it, as you can add other pods that weren't created here.
  selector:
    matchLabels:
      type: front-end
  # This is used to tell Kubernetes how to create new Pods. It is basically like pod-definition.yml without apiVersion and kind.
  template:
    metadata:
      name: my-app-pod
      # This should match the parent metadata. Helps the Selector manage Pods.
      labels:
        app: my-app
        type: front-end
    spec:
      # Which container(s) to run
      containers:
        - name: nginx
          image: nginx
```

```bash
# Create a ReplicaSet -> Pods
kubectl create -f replicaset-definition.yml

# Delete ReplicaSet and its Pods
kubectl delete rs|replicaset $REPLICA_SET_NAME

# Get Specific ReplicaSet information
kubectl get rs|replicaset [$REPLICA_SET_NAME]
kubectl get pod [$POD_NAME]

# Get ReplicaSet information
kubectl get all
kubectl describe rs|replicaset
kubectl get rs|replicaset -o wide

# Update Existing ReplicaSet With File - remember to delete the existing ReplicaSet or Pods for the changes to apply
kubectl replace -f replicaset-definition.yml

# Update Existing ReplicaSet Without File - remember to delete the existing ReplicaSet or Pods for the changes to apply
kubectl edit rs|replicaset $REPLICA_SET_NAME

# Extract ReplicaSet Definition From Running Pod
kubectl get rs|replicaset $REPLICA_SET_NAME -o yaml > replicaset-definition.yaml

# Scale Up/Down Replica Without File Updates
kubectl scale --replicas=6 -f replicaset-definition.yml
kubectl scale --replicas=6 replicaset $REPLICA_SET_NAME
```

## 1.6) k8s Deployments Recap

![Deployements](deployment.png)

* Applications and their dependencies need to be deployed (i.e installed) into environments. Each environment might have differnet installation requirements. Environment upgrades can be difficult as well. k8s can handle this with the Deployment object
* A **Deployment** object will create a ReplicaSet, and the ReplicaSet will create the Pods.
  * The ReplicaSet and Pods created by a Deployment will have the Deployment's name in their name.

![deployment-creating-replicaset-and-pods.png](deployment-creating-replicaset-and-pods.png)

* The Deployment object provides a way to do updates and rollbacks to Pod application versions.

```yaml
# This is a typical production way. Deployment -> ReplicaSet -> Pods. All from this file.
apiVersion: apps/v1

# Provides a way for rolling updates (1 by 1) and rolling back updates. Or pause, update, and reusume.
kind: Deployment
# All Kubernetes yml files need metadata, and they must have name and label.

metadata:
  name: my-app-deployment
  # Provide your own key/value pairs here.
  # This should match the nested metadata. Helps the Selector manage P ods.
  labels:
    app: my-app
    type: front-end

spec:
  # How many pods must be running at once
  replicas: 3
  # Required by ReplicaSet, not ReplicationController. Explains what pods fall under it, as you can add other pods that weren't created here.
  selector:
    matchLabels:
      type: front-end
  # This is used to tell Kubernetes how to create new Pods. It is basically like pod-definition.yml without apiVersion and kind.
  template:
    metadata:
      name: my-app-pod
      # This should match the parent metadata. Helps the Selector manage Pods.
      labels:
        app: my-app
        type: front-end
    spec:
      # Which container(s) to run
      containers:
        - name: nginx
          image: nginx # Updating the image is how you can trigger a new Deployment.
```

```bash
# NOTE: For a deployment to work, we still need a service.

# Create a Deployment -> ReplicaSet -> Pods With File
kubectl create -f deployment-definition.yml
# Use a file and save the history changes
kubectl create -f deployment-definition.yml --record
# Using an image
kubectl create deployment $DEPLOYMENT_NAME --image=$IMAGE_NAME

# Delete Deployment, ReplicaSet, and its Pods
kubectl delete deployments/$DEPLOYMENT_NAME

# Get Deployment information
kubectl get deployment [$DEPLOYMENT_NAME]
kubectl get rs|replicaset [$REPLICA_SET_NAME]
kubectl get pod [$POD_NAME]
kubectl get all
kubectl describe deployments

# Update Deployments Using File - remember to delete the existing Deployment or ReplicaSet or Pods for the changes to apply
kubectl apply -f deployment-definition.yml

# Update Deployments Without a File -  remember to delete the existing Deployment or ReplicaSet or Pods for the changes to apply
kubectl set image deployement/$DEPLOYMENT_NAME nginx=ngninx:1.9.1

# Scale deployment without file
kubectl scale $DEPLOYMENT_NAME --replicas=$REPLICA_AMOUNT

# Get Deployment Status
kubectl rollout status deployment/$DEPLOYMENT_NAME
kubectl rollout history deployment/$DEPLOYMENT_NAME

# Save revision change history
kubectl ... --record

# View revisions
kubectl rollout history deployment/$DEPLOYMENT_NAME --revision=$REVISION_NUMBER

# Rollback An Update
kubectl rollout undo deployment/$DEPLOYMENT_NAME

# Create a YAML file
kubectl create deployment --image=$IMAGE_NAME $DEPLOYMENT_NAME --replicas=$AMOUNT --dry-run -o yaml > deployment.yaml
```

* `kubectl [command] [TYPE][NAME] -o $OUTPUT_FORMAT` has 4 types
  1. `-o json` - which prints out JSON
  1. `-o name` - which prints out the resource name only.
  1. `-o wide` - which prints out additional information.
  1. `-o yaml` - which prints out YAML.
* https://kubernetes.io/docs/reference/kubectl/overview/
* https://kubernetes.io/docs/reference/kubectl/cheatsheet/

### 1.6.1) Deployment Updates and Rollbacks

![Rollouts and Versioning](rollout-and-versioning.png)

![Deploy strategy](deployment-strategy.png)

* Each time a Deployment is run, a **Rollout** is triggered. A version (i.e. **Revision**) of the Rollout is kept, which can be used later to rollback to.
* There are 2 types of Deployment strategies
  * **Recreate strategy** will delete all at once and create all at once, this means there will be an outage
  * **Rolling Update** will delete old Pods and replace with new Pods 1 by 1, this means no outage. This is the default.

![recreate-v-rolling-update.png](recreate-v-rolling-update.png)

* Updates to version numbers are applied in the Deployment YAML file, by specifying the image tag version.
  * If you do it from the command line, the running Deployment is updated but this doesn't update the YAML file.
* A new ReplicaSet is created when upgrades are performed. Pods from the original ReplicaSet are destroyed and Pods in the new RepliceSet are created
* A **Rollback** is when you undo a Deployment and go back to a previous Rollout version.
  * When rolling back, the original revision number that was rolled back to is moved to the lastest revision number. e.g. we have revision 1 and revision 2. We roll back to revision 1, revision 1 is renamed revision 3 and we will only see revisions 2 and 3.

![rollback-revisions.png](rollback-revisions.png)

![Upgrades](upgrades.png)

![Rollback](rollback.png)

![deployment-rollout-status.png](deployment-rollout-status.png)

## 1.7) k8s Namespaces

* **Namespaces** are named containers that are used to group objects together and provide each object within the group a unique name to all other objects outside the group. Namespace objects will be unique even if they have the same name as objects from another Namespace. For example, in Java there is `java.util.Date` and `java.sql.Date`. Thus Namespaces are a method of providing isolation (i.e. variable scope) to objects.
  * An analogy with people works. Each person in a family will typically have a unique name combination. But people from other familes may have the same name combination. To differeniate the people with the exact same name, we will use other identifying qualties like address, date of birth, etcetera. The combination of properties that uniquely identifies related people is the namespace. This will typically be their fullname and address.

![Namespace DNS](namespace.png)

* All objects within k8s are created within a namespace.
* 3 namespaces are automatically created by k8s
  1. **Default** - all user created objects will go here by default unless another namespace is created and used.
  1. **kube-system** - a namespace used by k8s for system level objects (e.g. networking).
  1. **kube-public** - a namespace that can be used for objects that will be available to all users.
* Namespaces can have policies which will define who can do what. Such as compute resource allocation.

![Namespace resource allocation](namespace-resource-limits.png)

* All resources within a Namespace can refer to each simply by their names. This is because a DNS entry is added into each host.
  * To access resource within another namespace, you must use `resource-name.namespace-name.svc.cluster.local`

![Namespace DNS](namespace-dns.png)
![Namespace DNS](namespace-dns-2.png)

* By default all commands use the default Namespace, you can use the `--namespace` option to look at other namespaces.
  * You can change this permanently by using `kubectl config set-context $(kubectl config current-context) --namespace=$NAMESPACE`

```yaml
# https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/
# https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
# There is always 4 root elements
# The version depends on what you are doing
apiVersion: v1

# The type of object, dictates the type of version
kind: Namespace

# Must have name and labels inside of it, the name is the pod name
metadata:
  name: my-namespace
```

```yaml
# https://kubernetes.io/docs/concepts/workloads/pods/pod-overview/#pod-templates
# There is always 4 root elements
# The version depends on what you are doing
apiVersion: v1

# The type of object, dictates the type of version
kind: Pod

# Must have name and labels inside of it, the name is the pod name
metadata:
  name: my-nginx-pod
  # Always create in this namespace
  namespace: my-namespace
  # Can have any key/value pair here
  labels:
    app: my-nginx-app
    type: front-end

# Which container(s) will be running
spec:
  # Can have multiple containers, but usually 1 container per pod.
  containers:
    - name: nginx-container
```

```bash
# List all Pods from a specific Namespace
kubectl get pods --namespace=$NAMESPACE

# List all Pods from all Namespaces
kubectl get pods --all-namespaces

# Create a Pod
kubectl create -f pod-definition.yml --namespace=$NAMESPACE

# Create a Namespace
kubectl create -f namespace.yml
kubectl create namespace $NAMESPACE
```

## 1.8) k8s Networking Recap

https://kubernetes.io/docs/concepts/cluster-administration/networking/

* Each Node has it own IP address. This can be used to `ssh` into the Node.
* Each Pod is has its own dynamic IP address as well. This address changes and should never be used for accessing a Pod as the IP address will change when Pods are recreated.
* All Pods get the IP addresses from the same internal private k8s network. This private internal network is created when the k8s cluster is configured.

![Single Node Cluster](single-pod-on-single-node-networking.png)

![Multiple Node Cluster](multiple-pods-on-single-node-networking.png)

* In multiple Node clusters there will be IP address clashes by default. This is because by default each private internal network within each Node has the same IP address range. Nodes and Pods will have IP address conflicts.

![IP address clash](ip-address-clash.png)

* k8s does not natively supply any networking tools to handle the networking conflicts. When installing k8s, you must choose an external application (e.g. Calico) to handle the networking within the k8s cluster.
* The custom network manager creates a virtual network where all Pods and Nodes are assigned a unique IP address. It also manages the routing within this network.

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#pod-network

![Custom network layer](networking-layer.png)

* Some rules of k8s networking which are implemented by the external networking solution..
  * All Containers / Pods can communicate with one another without NAT.
  * All Nodes can communicate with all Containers / Pods without NAT.
  * All Containers / Pods can communicate with all Nodes without NAT.

### k8s Services

* k8s **Services** is a k8s object that enable communications between various cluster components. They help us connect applications/users together by loosely coupling them together.

![Services overview](services-overview.png)

#### NodePort

* A **NodePort Service** makes an internal Pod accessible to external users by mapping a port on the Node to a port on the Pod.
* How do external users access a k8s application externally through a browser? They will connect to the external Node IP and the listening **NodePort Service** will forward the request to a Node's internal IP address by mapping a port on the Node to a port on a Pod. There are 3 ports involved here, from the perspective of the NodePort Service
  1. the port running on the Pod, called the TargetPort
  1. the port running on the Service, called the Port
  1. the port running on the Node, called the NodePort, 30000-32767 default range

![NodePort](nodeport-1.png)
![NodePort](nodeport-2.png)
![NodePort](nodeport-3.png)

* The Pod label is used by Service Selector to find all Pods to apply the NodePort to. The Service uses a a random algorithm to select which Pod to send traffic to from all the Pods matched by the label.

![NodePort](nodeport-label-and-selector.png)

* For multiple Nodes, the Service is created across all the Nodes which will provide access to each Node via its own IP and the same port.

![NodePort](nodeport-multinodes.png)

* Thus the Service is always created exactly the same no matter how many Pods or Nodes are involved. The Service is automatically updated if Pods and Nodes are removed.


```yaml
# https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service
# The version depends on what you are doing
apiVersion: v1

# The type of object, dictates the type of version
kind: Service

metadata:
  name: my-app-service

# The networking configuration of the Service
spec:
  # 3 types available here, NodePort, ClusterIP, LoadBalancer
  type: NodePort
  ports:
      # The Pod port(s), where we want to go
    - targetPort: 80
      # The Service object port
      port: 80
      # The Node port exposed externally. Use 30000-32767
      # If we leave this blank Kubernetes will provide it for us automatically.
      nodePort: 30008
  # Add the labels here of the Pods you want to link to the Service
  selector:
    # These are from pod|replicaset|deployment-definition.yml -> metadata: labels: and must match exactly.
    app: my-app
```

```bash
# Create a Service
kubectl create -f service-definition.yml
kubectl expose pod redis --port=6379 --name redis-service

 # Delete Service
kubectl delete service $SERVICE_NAME

# Get Service information
kubectl get services
kubectl get service $SERVICE_NAME
kubectl get all
kubectl describe service
```

#### ClusterIP

* The **ClusterIP Service** creates a virtual IP within the cluster and that is used for network communications. This can used when you have multiple Pods.
* A fullstack application typically has a multiple set of Pods running different tiers of the application (e.g, frontend web app, backend databases, messaging services, etc).
  * The ClusterIP Service helps up group Pods together and provides a single interface to access the different tiers of Pods.
  * Each ClusterIP Service gets a name and IP address and that is what is used to access the Pods grouped with the Service. The ClusterIP also handles scaling.

![ClusterIP](clusterip.png)

```yaml
# https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service
# The version depends on what you are doing
apiVersion: v1

# The type of object, dictates the type of version
kind: Service

metadata:
  name: backend

# The networking configuration of the Service
spec:
  # 3 types available here, NodePort, ClusterIP, LoadBalancer
  type: ClusterIP
  ports:
      # The Pod port(s), where we want to go
    - targetPort: 80
      # The Service object port
      port: 80
  # Add the labels here of the Pods you want to link to the Service
  selector:
    # These are from pod|replicaset|deployment-definition.yml -> metadata: labels: and must match exactly.
    app: my-app
    type: backend
```

```bash
# Create a Service
kubectl create -f service-definition.yml
kubectl expose pod redis --port=6379 --name redis-service

 # Delete Service
kubectl delete service $SERVICE_NAME

# Get Service information
kubectl get services
kubectl get service $SERVICE_NAME
kubectl get all
kubectl describe service
```

#### LoadBalancer

* The **LoadBalancer Service** delegates control to a cloud provider's (e.g. Google/AWS) load balancing agent. It can only be used when you are within a cloud envrionemnt that has this capability.

![Cloud LoadBalancer](loadbalancer.png)

## 1.9) Imperative Commands

When doing the exam certification it is a good idea to use one time imperative commands rather than the declarative style of creating a YAML file.

```bash
# Create and run a Pod
kubectl run nginx-pod --image=nginx:alpine

# Create and run a Pod with a label
kubectl run redis --image=redis:alpine --labels='tier=db'

# Create a Service that exposes a port on an existing Pod
kubectl expose pod redis --port=6379 --name redis-service

# Create a deployment and scale it
kubectl create deployment webapp --image=kodekloud/webapp-color
kubectl scale --replicas=3 deployment webapp

# Create a Pod with a custom port
kubectl run custom-nginx --image=nginx --port=8080

# Create a Namespace
kubectl create namespace dev-ns

# Create a Deployment in a custom Namespace and scale it
kubectl create deployment redis-deploy --image=redis --namespace=dev-ns
kubectl scale deployment redis-deploy --replicas=2 --namespace=dev-ns

# Create a Pod with a custom port and a Service that exposes that port
kubectl run httpd --image=httpd:alpine --port=80 --expose

kubectl run httpd --image=httpd:alpine --port=80
kubectl expose pod httpd --port=80 --name=httpd

# Dump Pod YAML template to file
kubectl run nginx --image=nginx  --dry-run=client -o yaml > pod.yml

# Dump Deployment YAML template to file
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml > deployment.yaml

# Dump ClusterIP Service YAML template to file, you will need to manually add the Node Port in the YAML
kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml > clusterip.yml

# Dump NodePort Service YAML template to file, you will need to manually add the Node Port in the YAML
kubectl expose pod nginx --port=80 --name nginx-service --type=NodePort --dry-run=client -o yaml > nodeport.yml
```
# 2) Configuration

## 2.1) Commands & Arguments

### Docker

* Why do some Docker containers exit immediately? They are meant to run applications and not O/S. So an O/S image will exit immediately as nothing is running. The container lives only as long as the process it is running inside of it is alive.
* The `CMD` part of the Dockerfile determines what is running inside the container. The Ubuntu image has `CMD ["bash"]` which runs the bash shell. Bash will listen for a terminal and if none is found, it will exit. Docker doesn't attach a termianal by default.

```bash
# Run an Ubuntu container, which will exit immediately.
docker run ubuntu

# Show only running containers
docker ps

# Show all containers, included the stopped on
docker ps -a

# Run the Ubuntu container and attach a terminal so bash won't exit
# -i to allow an interactive terminal and -t to attach the terminal
docker -it run ubuntu

# Run the Ubuntu container with a custom command
docker run ubuntu sleep 5
```

* Can create your own Dockerfile to update an existing image for custom commands. Use `docker build -t $MY_IMAGE_NAME $DOCKERFILE_PATH` to build it.
* Hard coding the command `CMD` to be run using JSON array format. The first argument must be the command to run.

```dockerfile
# Image to create a new layer from.
FROM ubuntu
# Command to run
CMD ["sleep", "5"]
```

* Hard coding the command `CMD` to be run using shell syntax.

```dockerfile
# Image to create a new layer from.
FROM ubuntu
# Command to run
CMD sleep 5
```

* Passing in a value from the command line, which will be appended to the `ENTRYPOINT` command. But a value must be passed in or an error will occur.

```dockerfile
# Image to create a new layer from.
FROM ubuntu
# Command to run
ENTRYPOINT ["sleep"]
```

* Passing in a value from the command line, which will be appended to the `ENTRYPOINT` command. A value is optional as a default value is hard coded into `CMD` to fall back onto when nothing is passed in.

```dockerfile
# Image to create a new layer from.
FROM ubuntu
# Command to run
ENTRYPOINT ["sleep"]
# Default value
CMD ["5"]
```

* You can use `docker run --entrypoint $NEW_COMMAND $IMAGE_NAME` to override the `ENTRYPOINT` command in a Dockerfile.

### k8s

* You can pass aurgments into Docker via k8s.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: ubuntu-sleeper
spec:
  containers:
    - name: ubuntu-sleeper
      image: ubuntu-sleeper
      command: ["sleep2.0"] # The new entry point command passed in to Docker, overriding ENTRYPOINT
      args: ["10"] # The argument passed in to Docker, overriding CMD
```

* Run this with `kubectl create -f pod.yml`

## 2.2) Enviroinment Variables

### Docker

* You can pass in environment variables to Docker with `docker run -e $ENV_NAME=$ENV_VALUE $IMAGE_NAME`

### k8s

* You can pass in environment variables to k8s and Docker with

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - name:  webapp-color
      image: webapp-color
      ports:
        - containerPort: 8080
      env:
        - name: APP_COLOR
          value: green
```
* You can also use ConfigMaps and Secrets to pass in environment variables.

## 2.3) ConfigMaps and Secrets

### ConfigMaps

* ConfigMaps are used to help manage lots of environment variables. Instead of storing them in lots of Pod definition files, you can store them centrally into a ConfigMap object. You then inject the values from the ConfigMap into the Pod definition files.
* There are 2 steps when working with ConfigMaps.
  1. Create the ConfigMap
  1. Inject it into a Pod

#### Creation

* Like all k8s objects, you can create ConfigMaps imperatively or declaratively. The imperative way : `kubectl create configmap --from-literal='APP_COLOR=green' --from-literal='APP_ENV=prod'` or `kubectl create configmap --from-file=$PATH_TO_FILE`

```yaml
# File contents, key: value
APP_COLOR: blue
APP_MODE: prod
```

* The declarative way: `kubectl create configmap --from-file=$PATH_TO_FILE`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  # Give a meaningful name so its easier to undertand and use them later
  name: webapp-color-configmap
# Key: value paits of the ConfigMap
data:
  APP_COLOR: blue
  APP_ENV: prod
```

* Here are some common `kubectl` options for ConfigMaps.

```bash
# View all ConfigMaps
kubectl get configmaps

# Get detailed information about all ConfigMaps, such as key: value pairs
kubeclt describe configmaps

# View a specific ConfigMap
kubectl get configmaps $CONFIG_MAP_NAME

# Get detailed information about a ConfigMap, such as key: value pairs
kubeclt describe configmaps $CONFIG_MAP_NAME
```

#### Injection

* Injecting  a single environment variable.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - image: webapp-color
      ports:
        - containerPort: 8080
      # A list where each item is a ConfigMap item.
      env:
        - name: APP_COLOR
          valueFrom:
          configMapKeyRef:
            # The name of the ConfigMap
            name: webapp-color-configmap
            # The key inside the ConfigMap
            key: APP_COLOR
```

* Injecting multiple environment variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - image: webapp-color
      ports:
        - containerPort: 8080
      # A list where each item is a ConfigMap item.
      envFrom:
        - configMapRef:
            # The name of the ConfigMap
            name: webapp-color-configmap
```

```yaml
# Using a volume
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - image: webapp-color
      ports:
        - containerPort: 8080
      # A list where each item is a ConfigMap item.
      volumes:
        # The name of the volume
        - name: webapp-color-volume
          # The name of the ConfigMap
          configMap: webapp-color-configmap
```

### Secrets

* Secrets are used to help manage lots of environment variables that need obfuscating. Instead of storing them in plain text in lots of Pod definition files, you can store them centrally in base64 into a Secret object. You then inject the values from the Secret into the Pod definition files.
* There are 2 steps when working with Secret.
  1. Create the ConfigMap
  1. Inject it into a Pod
* **Secrets are NOT encrypted. They are encoded as base64 only. For better security you need to use something else.**

#### Creation

* Like all k8s objects, you can create Secrets imperatively or declaratively. The imperative way : `kubectl create secret generic --from-literal='APP_COLOR=green' --from-literal='APP_ENV=prod'` or `kubectl create secret generic --from-file=$PATH_TO_FILE`
  * The values provided here in plain text will automatically be encoded as base64. The file format is.

```yaml
# File contents, key: value
APP_COLOR: blue
APP_MODE: prod
```

* The declarative way: `kubectl create configmap --from-file=$PATH_TO_FILE`

```yaml
apiVersion: v1
kind: Secret
metadata:
  # Give a meaningful name so its easier to undertand and use them later
  name: webapp-color-secret
# Key: value paits of the Secret
data:
  # These are in base64, therefore plain text.
  APP_COLOR: Ymx1ZQo=
  APP_ENV: cHJvZAo=
```

* Linux has a command called `base64` which can be used to encode and decode data.

```bash
# Get the base64 encoding
echo 'blue' | base64
Ymx1ZQo=
# Decode the base64 encoded string
echo 'Ymx1ZQo=' | base64 --decode
blue
echo 'prod' | base64
cHJvZAo=
echo 'cHJvZAo=' | base64 --decode
prod
```

* Here are some common `kubectl` options for Secrets.

```bash
# View all Secrets
kubectl get secrets

# Get detailed information about all Secrets, such as key: value pairs
kubeclt describe secrets

# View a specific Secrets with no values
kubectl get secrets $SECRET_NAME

# View a specific Secrets with values
kubectl get secrets $SECRET_NAME -o yaml

# Get detailed information about a Secrets, such as key: value pairs
kubeclt describe secrets $SECRET_NAME
```

#### Injection

* Injecting  a single environment variable.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - image: webapp-color
      ports:
        - containerPort: 8080
      env:
        - name: APP_COLOR
          valueFrom:
            secretKeyRef:
              name: webapp-color-secret
              key: APP_COLOR
```

* Injecting multiple environment variables

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - image: webapp-color
      ports:
        - containerPort: 8080
      # A list where each item is a Secret item.
      envFrom:
        - secretRef:
          # Read all key value pairs from this Secret
          name: webapp-color-secret
```

```yaml
# Using a volume
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - image: webapp-color
      ports:
        - containerPort: 8080
      # A list where each item is a Secret item.
      volumes:
        # The name of the volume
        - name: webapp-color-secret-volume
          # The name of the Secret
          configMap: webapp-color-secret
```

* When using volumes, every key in the Secret has a file created with the key as the filename and the value as the file contents.

## 2.4) Security

### Docker Security

#### Process Isolation

* The host that has the Docker daemon installed on it has a variety of its own processes, including the Docker daemon. These are running in a variety of namespaces.
* The host and the Docker container share the same Linux kernel and use namespaces to separate each other.

![Namespaces](host-v-container-namespace.png)

* Whenever a Docker container is running, it is running inside of its own namespace. The Docker container can only see processes within its container namespace. These processes will have their own process IDs, starting with PID 1. This PID is only relative to the container and the PID 1 inside a Docker container is not the PID 1 (initial process) of the host.

![Container PID](container-PID.png)

* The host will be able to see the processes running within the Docker container but will have a different process ID. This PID is only relative to the host. This is the 'real' PID as the Docker container is running within the host.

![Host PID](host-PID.png)

#### Users

* By default Docker runs its processes as the root user. This can be seen inside and outside the container.
* Docker uses Linux Capabilities to restrict what the root user can do inside and outside the Docker container.
  * The full list of Linux Capabilities can be seen at `/usr/include/linux/capability.h`
* You can adjust Linux Capabilities at run time via:
  * Add a Linux capability with `docker run --cap-add $CAPABILITY $IMAGE`
  * Remove a Linux capability with `docker run --cap-drop $CAPABILITY $IMAGE`
  * Use all Linux Capabilities with `docker run --privileged $IMAGE`
* You can change the runtime user that Docker uses from root to any other user. This can be done in the Docker Image or at runtime.
  * `docker run --user=$USER_ID $IMAGE`

![Users](host-v-container-PID.png)

### Security Contexts

* **Security Contexts** are the k8s way of implementing some Docker security features. Such as which use will run the process inside the container, and what Linux capabilities it has.

![Docker / k8s security mapping](docker-to-k8s-security-mapping.png)

* Security Contexts can be configured at the Pod level or the container level.
  * If configured at the Pod level, all containers within the Pod will inherit these security settings.
  * If configured at the containter level, only those containers will have the security settings applied to them. This will override the settings on the Pod. Linux capabilities can only be set at the container level.

![pod-v-container-level-security.png](pod-v-container-level-security.png)

* Security Contexts are defined inside the Pod definition file.
* Pod level Security Context is inside the `spec:` section.
* Container level Security Context is inside the `containers:` section. Linux capabilities can only be set at the container level.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-pod
spec:
  securityContext: # Pod level
    runAsUser: 1001
  containers:
  -  image: ubuntu # This container will have 1002
     name: web
     command: ["sleep", "5000"]
     securityContext: # Container level
      runAsUser: 1002

  -  image: ubuntu # This container will have user 1001
     name: sidecar
     command: ["sleep", "5000"]
```

```bash
# Which user is running the command in the pod
kubectl exec ubuntu-sleeper -- whoami # root

# Get Pod YAML, edit it and replace it
kubectl get pod ubuntu-sleeper -o yaml > my-pod.yml
vi my-pod.yml
```

```bash
# Check which user is currently being used inside the container to launch processes
kubectl exec ubuntu-sleeper -- whoami
```

```
# Example update of Linux capability
master $ kubectl exec ubuntu-sleeper -- date -s '19 APR 2012 11:14:00'
date: cannot set date: Operation not permitted
Thu Apr 19 11:14:00 UTC 2012
command terminated with exit code 1
```

```yaml
spec:
  securityContext:
    runAsUser: 0 # Needed to change this to be root, uid 0 is root.
  ...
  containers:
  ...
    securityContext:
      capabilities: # Can only be set at the container level, must be run as root user
        add: ["SYS_TIME"]
```

```bash
master $ kubectl exec ubuntu-sleeper -- date -s '19 APR 2012 11:14:00'
Thu Apr 19 11:14:00 UTC 2012
```

* **When recreating a Pod from the `-o yaml` output, remember that everything exists in the file in alphabetical order. When I was trying to set a Security Context it was being overriden further down the file.**

### Service Accounts

* This concept is linked to other k8s security concepts, but they are covered in the CKA course and are out of scope here.
* There are 2 types of accounts in k8s:
  1. **User Accounts** are used by people - e.g. an admin / developer logging in to the k8s cluster.
  1. **Service Accounts** are used by an application to interact with the k8s cluster. - e.g. the monitoring application Prometheus uses a Service Account to query the k8s metrics API. Jenkins uses a Service Account to deploy applications to the cluster.

![2-types-of-accounts.png](2-types-of-accounts.png)

* When a Service Account is created an access token is automatically created and associated with it. This is used by internal and external cluster applications to authenticate with the k8s API.

![token-authentication.png](token-authentication.png)

* The token is stored as a k8s Secret object.

![service-account-token-link.png](service-account-token-link.png)

* The token can be supplied as an authentication bearer token in `curl` when an external application is communicating with the k8s API. `curl $URL --header "Authorization: Bearer "$TOKEN`
* When using Service Account tokens with applications inside the k8s cluster, the token secret is mounted inside the Pod.
* For every namespace in k8s a Service Account named default is automatically created.
  * k8s automatically mounts the default Service Account if you don't specify a custom Service Account. The default Service Account can only do basic k8s API queries.
  * You can disable this by setting `automountServiceAccountToken: false` inside `containers:` in the POD definition file.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  labels:
    app: my-nginx-app
    type: front-end
spec:
  containers:
    - name: nginx-container
      image: nginx
  automountServiceAccountToken: false # Don't mount the default Service Account automatically.
```

* You cannot edit a Service Account of an existing Pod, you must delete and recreate the Pod. Remember that Deployments will do this automatically for you.

```yaml
# Use a custom Service Account within the Pod definition file.
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  labels:
    app: my-nginx-app
    type: front-end
spec:
  containers:
    - name: nginx-container
      image: nginx
  serviceAccount: nginx-service-account # Specify custom Service Account
```

```bash
# Create a Service Account and an access Token
kubectl create serviceaccount $SERVICE_ACCOUNT_NAME

# View all Service Accounts
kubectl get serviceaccount

# View details about a Service Account
kubectl describe serviceaccount $SERVICE_ACCOUNT_NAME

# View the Service Account token
kubectl describe secret $SERVICE_ACCOUNT_TOKEN_NAME

# View the Pod's Service Account token details
kubectl describe pod $POD_NAME

# Look inside the container's filesystem to see the Service Account Token files
kubectl exec -it $POD_NAME ls /var/run/secrets/kubernetes.io/serviceaccount
ca.crt namespace token

# Display the container's Service Account Token
kubectl exec -it $POD_NAME cat /var/run/secrets/kubernetes.io/serviceaccount/token
```

## 2.5) Resources

* All Nodes have CPU, memory, and disk available. Whenever a Pod is placed on a Node it consumes some or all of these resources.

![pod-resource-usage.png](pod-resource-usage.png)

### Scheduler

* The k8s Scheduler decides which Node a Pod will run on.
* It takes into consideration how much Node resources are available and how much resource the Pod needs.

![pod-to-node-placement.png](pod-to-node-placement.png)

* If a Pod's resource needs exceed the available resource of a Node, the schedular will try to place it eleswhere.
* If it cannot find a Node with enough resources available, the Pod will not be run and it will be in a Pending state.

![scheduler-blocking-pod.png](scheduler-blocking-pod.png)

* You can specifiy how much CPU your Pod needs.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  labels:
    app: my-nginx-app
    type: front-end
spec:
  containers:
    - name: nginx-container
      image: nginx
      ports:
        - containerPort: 8080
      resources:
        requests:
          cpu: 1 # 1 hyperthread
          memory: 512Mi # binary, base 1024
```

#### CPU

* The lowest decimal number is 0.1 and the maximum number is the available CPU threads.
* 100m is equal to 0.1, the lowest number is 1m.
* 1 CPU is equivalent to:
  * 1 AWS vCPU
  * 1 GCP Core
  * 1 Azure Core
  * 1 hyperthread
* When a running Pod tries to exceed the CPU limit it will be throttled.
* You can set the default CPU limit with a LimitRange

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: cpu-limit-range
spec:
  limits:
  - default:
      cpu: 1 # 1 hyperthread
    defaultRequest:
      cpu: 0.5
    type: Container
```

#### RAM

* Memory can be specified in decimal (base 1000), binary (base 1024), or plain old bytes.
* In decimal:
  * 8 bits = 1 byte (B)
  * 1000 B = 1 kilobyte (kB)
  * 1000 kB = 1 megabyte (MB)
  * 1000 MB = 1 gigabyte (GB)
  * 1000 GB = 1 terabyte (TB)
  * etcetera
* In binary:
  * 8 bits = 1 byte (B)
  * 1024 bytes = 1 kibibyte (KiB)
  * 1024 KiB = 1 mebibyte (MiB)
  * 1024 MiB = 1 gibibyte (GiB)
  * 1024 GiB = 1 tebibyte (TiB)
  * etcetera
* When a running Pod tries to exceed the RAM limit it will be terminated, but only if it continually tries to exceed RAM usage.
* You can set the default RAM limit with a LimitRange

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: mem-limit-range
spec:
  limits:
  - default:
      memory: 512Mi # binary, base 1024
    defaultRequest:
      memory: 256Mi
    type: Container
```

## 2.6) Assigning Pods To Nodes

### Taints & Tolerations

* Taints and Tolerations are used to set restrictions on what Pods can be scheduled on a Node.
* This does not guarentee that the Pod will be placed into the Tainted Node.

#### Taints

* **Taints** are set on Nodes. These stop Pods from being scheduled here, unless they are manually set as Tolerant to the Taint.
* 3 Taint effects.
  1. **NoSchedule** - Pods will not be scheduled on the Node.
  2. **PreferNoSchedule** - Scheduler will try to avoid placing a Pod on a Tainted Node, but it may get placed there.
  3. **NoExecute** - New Pods will not be placed onto the Node and any existing Pods will be evicted from the Node if they do not tolerate the Taint.
* A Taint is automatically set on the Master Node when k8s is intiailly set up. This is what stops the Master from accepting Pods. `kubectl describe node kubemaster | grep Taint` will show this taint.

![tainted-master.png](tainted-master.png)

```bash
# https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/
# Add a Taint
kubectl taint nodes $NODE_NAME $KEY=$VALUE:$TAINT_EFFECT
kubectl taint nodes node1 app=blue:NoSchedule

# Remove a Taint
kubectl taint nodes $NODE_NAME $KEY:$TAINT_EFFECT-
kubectl taint nodes node1 app:NoSchedule-
```

#### Tolerants

* **Tolerants** are set on Pods. By deffault Pods have no Tolerants, these must be created manually in the Pod definition file.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  labels:
    app: my-nginx-app
    type: front-end
spec:
  containers:
    - name: nginx-container
      image: nginx
      ports:
        - containerPort: 8080
  # Add Tolerations to the Pod, must be double quoted. This matches previously created Taint.
  tolerations:
    - key: "app" # Taint key to tolerate
      operator: "Equal" # Taint matching criteria, default is Equal
      value: "blue" # Taint value to tolerate
      effect: "NoSchedule" # Taint effect
```

### Node Labels

* **Node Labels** are just Labels attached to Nodes that can be used by the Selector to identify which Nodes to use.

![node-label.png](node-label.png)

```bash
# https://kubernetes.io/docs/tasks/configure-pod-container/assign-pods-nodes/#add-a-label-to-a-node
# Show all labels
kubectl get nodes --show-labels

# Add a Node Label
kubectl label nodes $NODE_NAME $KEY=$VALUE
kubectl taint nodes node1 size=Large

# Remove a Node Label
kubectl label nodes $NODE_NAME $KEY=$VALUE-
kubectl label nodes node1 size=Large-
```

* These are used by Node Selectors and Node Affinity, which are detailed below.

### Node Selectors

* **Node Selectors** are a basic way to select which Node a Pod will be assigned to. It uses Labels and Selectors.
* A Node Selector must be created before a Pod can use it.

```yaml
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  labels:
    app: my-nginx-app
    type: front-end
spec:
  containers:
    - name: nginx-container
      image: nginx
      ports:
        - containerPort: 8080
  nodeSelector:
    size: Large # Matches the key/value pair from the create Node Label
```

### Node Affinity

* The primary feature of **Node Affinity** is to ensure Pods are hosted on particular Nodes.
* It provides advanced capaibilities for limiting Pod placement, but this increases complexity. This is provided by the `operator`, which can have:
  * In - use any Node(s) that matches the key/values.
  * NotIn - use any Node(s) that doesn't match the key/values.
  * Exists - use any Node(s) that have labels.
  * DoesNotExist - use any Node(s) that don't have labels.
  * Gt
  * Lt

```yaml
# https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity
apiVersion: v1
kind: Pod
metadata:
  name: my-nginx-pod
  labels:
    app: my-nginx-app
    type: front-end
spec:
  containers:
    - name: nginx-container
      image: nginx
      ports:
        - containerPort: 8080
  affinity:
    nodeAffinity:
      # There are 2 different things you can use here. required/preferred
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: size # Match key from Node Label
            operator: In
            values:
            - Large # Match value from Node Label
            - Medium # Multiple items equals OR
```

* There are 2 types of Node Affinity.
  1. `requiredDuringSchedulingIgnoredDuringExecution` - rules must be met during scheduling, otherwise don't place the Pod. Do nothing if the label changes during execution.
  2. `preferredDuringSchedulingIgnoredDuringExecution` - rules may be met during scheduling, if not place the Pod anywhere it can. Do nothing if the label changes during execution.
* There is a new one coming but it hasn't been released yet.

![node-affinity-types.png](node-affinity-types.png)

* Can be used on Deployments too.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: blue
spec:
  replicas: 6
  selector:
    matchLabels:
      run: nginx
  template:
    metadata:
      labels:
        run: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: color
                operator: In
                values:
                - blue
```

### Combining Taints, Tolerants, & Node Affinity

* Taints and Tolerants don't gaurentee a Pod being placed onto the Tainted Node.
* Node Affinity doesn't gaurentee that unlabelled Pods won't be placed onto a labelled Node.
* Combining these 2 concepts together can gaurentee Pod placement.

#### Example

* We have 5 Nodes, we want 3 to be blue, red, and green, and others default.
* We only want coloured Pods to run on their matching coloured Node. All uncoloured Pods must run on uncoloured Nodes.

![combine-taints-tolerants-and-node-affinity-1.png](combine-taints-tolerants-and-node-affinity-1.png)

* To do this, do these 3 steps:
  1. Use Node Tainting to ensure the Node only accepts the correct Tolerant Pod.
  2. Use Pod Tolerants to ensure the Pod can be accepted by the correct Tainted Node.
  3. Use Node Affinity to Label the Nodes and Node Selectors on the Pods to ensure the Pods go to the desired Nodes.

![combine-taints-tolerants-and-node-affinity-2.png](combine-taints-tolerants-and-node-affinity-2.png)

# 3) Multi-Container Pods

## 3.1) Applicaiton Types

### Monolithic Applications

* **Monolithic application** describes a software application where everything is bundled together into a single application.

![monolithic-app.png](monolithic-app.png)

### Microservices

* **Microservices** is the concept of decoupling a single monolithic application into separate independent smaller services. This architecture makes it easier to manage, deploy, and scale.

![microservices-app-1.png](microservices-app-1.png)

* When using microservices you will often need to use multiple services together, for example, a webserver and a logging server. These services need to be started and stopped together. This is where multiple container Pods comes into play.

![microservices-app-1.png](microservices-app-2.png)
![multi-container-pod-1.png](multi-container-pod-1.png)

## 3.2) k8s Implementation

* The `containers` section inside a Pod definition file is an array. By adding multiple items to the array you are adding multiple containers to the Pod.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: webapp-color
spec:
  containers:
    - name: webapp-color
      image: webapp-color
      ports:
        - containerPort: 8080

    - name: log-agent
      image: log-agent
```

* Multi-container Pods:
  * Have the same lifecycle, they are created and destroyed together.
  * Share the same network space, they can refer to each other via `localhost`
  * Have access to the same storage volumes.

![multi-container-pod-2.png](multi-container-pod-2.png)

* 3 different patterns can be used to assign multiple containers to a single Pod. The YAML file is always the same though.
  1. **Sidecar** - the container's main app is extended by a helper app. ![sidecar.png](sidecar.png)
  2. **Ambassador** - proxy a local connection to the world. ![ambassador.png](ambassador.png)
  3. **Adaptor** - standardise and normalise output. ![adaptor.png](adaptor.png)
* All 3 can be combined. For example, we might have 3 different apps using sidecar with a logging agent. They all produce different log output foramts. An Adaptor can parse and translate them into a single format. An Ambassador can proxy the localhost connection to an external centralised logging server.

## 3.3) Observability

### Pod Lifecycle

#### Pod Statuses

![pod-running-status.png](pod-running-status.png)

* There are only 3 Pod statuses that tell us where abouts in the lifecycle the Pod is. Use the `kubectl get pods` command to see the Pod's status.
1. **Pending** is when the Pod is first created. The Schedulor is trying to find a Node to place the Pod onto. If it can't, the Pod will remain in this state. Run `kubectl describe $POD_NAME` to find out why a Pod is stuck in a pending state.
2. **ContainerCreating** is when the Pod has been scheduled and the container images needed to run the Pod are being pulled and created.
3. **Running** is when all the container images for the Pod have been pulled and created and they are now running.

#### Pod Conditions

![pod-ready-condition.png](pod-ready-condition.png)

* Pod Conditions provide additional information to Pod Statues. There are 4 Pod Conditions that have a boolean value. Use the `kubectl describe pods` command to view the Conditions of Pods.
1. **PodScheduled** is set to true when the Pod is scheduled onto a Node.
2. **Initialized** is set to true when a Pod is initialised
3. **ContainersReady** is set to true when all the containers in the Pod are ready.
4. **Ready** is set to true when everything else is set to true. You can see this with `kubectl get pods`
* The problem with the Ready condition is it just means the containers are running, this doesn't mean that the applications within the containers are actually running yet.
* For example, a webserver may a few minutes to start up after the container is started. The status would be Ready but the application is still offline until the webserver has finished starting up.

![pod-ready-but-app-is-not.png](pod-ready-but-app-is-not.png)

* Once a Pod is in the Ready state, a Service will start routing traffic to it. If the application ins't online yet, users will get errors. This can be solved with Readiness and Liveness Probes.

![pod-ready-but-app-is-not2.png](pod-ready-but-app-is-not2.png)

### Readiness Probes

* The developer of the application will know what it means for the application to be ready to use. The developer then ties the containers ready state to the application ready state, so that k8s knows when the application is alive.
* There are 3 Readiness Probes.
1. **HTTP test** will test a HTTP service on a specifc port. Useful whne testing if an API server is up and running.
2. **TCP test** will test a TCP service on a specifrc port. Useful when testing if a database is up and running.
3. **Command test** will run a command within the container that has its own success and failure logic.

![readiness-probe-yaml.png](readiness-probe-yaml.png)

* The `initialDelaySeconds` tells the Readiness Probe to wait this amount of time before proding the Pod.
* The `periodSeconds` tells the Readiness Probe how often to probe the Pod.
* The `failureThreshold` tells the Readiness Probe how often to probe the Pod unsuccessfully before giving up. The default is 3.

![readiness-probe-yaml-all-3.png](readiness-probe-yaml-all-3.png)

* The k8s Service will not direct any traffic to the Pod until its Readiness Probe has passed successfully. This will stop users experiencing a service outage because the container is ready but the application isn't.

![multi-pod-without-readiness-probe.png](multi-pod-without-readiness-probe.png)

### Liveness Probes

* When a Pod crashes k8s will try to restart the Pod. You can see the restart count in `kubeclt get pods`
* But k8s won't restart the Pod if the Pod hasn't crashed and the application isn't working. Use Liveness Probes to cater for this scenario.
* A Liveness Probe will periodically test the application within a Pod to see if it is healthy. If it isn't healthy, the Pod is destroyed and recreated. The application developer defines what it means for the application to be healthy.
* There are 3 Liveness Probes.
1. **HTTP test** will test a HTTP service on a specifc port. Useful whne testing if an API server is up and running.
2. **TCP test** will test a TCP service on a specifrc port. Useful when testing if a database is up and running.
3. **Command test** will run a command within the container that has its own success and failure logic.

![readiness-probe-yaml.png](readiness-probe-yaml.png)

* The `initialDelaySeconds` tells the Readiness Probe to wait this amount of time before proding the Pod.
* The `periodSeconds` tells the Readiness Probe how often to probe the Pod.
* The `failureThreshold` tells the Readiness Probe how often to probe the Pod unsuccessfully before giving up. The default is 3.

![liveness-probe-yaml-all-3.png](liveness-probe-yaml-all-3.png)

## 3.4) Logging

* In Docker you can view logs with `docker logs -f $CONTAINER_ID`

![docker-logs.png](docker-logs.png)

* In k8s you can view the logs for a single container Pod with `kubectl logs -f $POD_NAME`
* But what about a Pod with multiple containers? You must specify with container logs you want to view. Use `kubectl logs -f $POD_NAME $IMAGE_NAME`

![k8s-multiple-container-logs.png](k8s-multiple-container-logs.png)

## 3.5) Monitoring

* You can use third party tools to monitor a k8s Cluster. You can monitor things like:
  * Node level metrics, such as current state of all Nodes and the CPU and memory performance of all Nodes.
  * Pod level metrics, such as current state of all Pods and the CPU and memory performance of all Pods.

![cluster-metrics.png](cluster-metrics.png)

* There is a variety of monitoring tools, such as:
  * **Metrics Server**, based off the original and now deprecated Heapster.
  * **Prometheus**, covered in CKA.
  * **Elastic Stack**, covered in CKA.
  * **Data Dog** (paid), covered in CKA.
  * **Dyantrace** (paid), covered in CKA.

![k8s-monitoring-tools.png](k8s-monitoring-tools.png)

* You can have one Metrics Server per k8s Cluster. It gathers information from Nodes and Pods and stores that data in memory. It provides no historical data.
* The Kubelet Agent running on each Nodes is responsible for running Pods on the Nodes and receiving instructions from the master kube-apiserver.
  * A component of Kubelet called c**Advisor (Container Advistor)** is what is used to gather metrics and exposing them through the Kubelet API for the Metrics Server.
* You can install Metrics Server with
  * For Minikube only - `minikube addons enable metrics-server`
  * For everything else

```bash
# Clone repo
git clone https://github.com/kubernetes-incubator/metrics-server.git

# Build the app
cd metrics-server/
kubectl create -f .
```

* The Metrics Server needs sometime to collect and process the data. You can view this data with:
  * Nodes - `kubectl top node`
  * Pods - `kubectl top pod`

![metrics-server-stats.png](metrics-server-stats.png)

# 4) Pod Design

## 4.1) Labels & Selectors

### Labels

![label-and-selectors.png](label-and-selectors.png)

* in k8s **Labels** are key/value pairs that are attached to objects. In general, labels are are a standard way of grouping things together. We can use single or multiple labels to filter items.
* Labels are created by YAML files.

![label-yml.png](label-yml.png)

### Selectors

* **Selectors** use Labels to perform object selection and filtering.
* Can filter objects by type.

![k8s-objects-unfiltered.png](k8s-objects-unfiltered.png)

![k8s-objects-filtered-by-object-type.png](k8s-objects-filtered-by-object-type.png)

* Can filter objects by application.

![k8s-objects-filtered-by-app.png](k8s-objects-filtered-by-app.png)
* Can filter objects by any type of Label.

```bash
# Use one Label in a Selector
kubectl get $OBJECT --selector $KEY=$VALUE

# Use multiple Labels in a Selector
kubectl get $OBJECT --selector $KEY1=$VALUE1,$KEY2=$VALUE2
```

![selector-command.png](selector-command.png)

* k8s internally uses Labels and Selectors to group objects together, such as a ReplicaSet and Pods. In this example there are 2 labels in the YAML defintion file, the ReplicaSet Label and the Pod Label.

![replicaset-labels.png](replicaset-labels.png)

## 4.2) Deployment Updates & Rollbacks

See [1.6) k8s Deployments Recap](#16-k8s-deployments-recap)

### Additional Information

* A deployment update is any change to the current Deployment. For example, a container image version has changed.
* You can use `kubectl describe deployment $DEPLOYMENT` to see the differences between the update strategies.
* Rollout error troubleshooting steps.

```bash
# Update the Rollout
kubectl apply -f deployment-definition.yml

# Rollout doesn't finish, see why.
kubectl get deployment

# Our desired, current, up-to-date, and available pods aren't matching. This is a clue to why the Rollout failed.
kubectl get pods

# Old versions are still working, the new ones have failed. Stop the Rollout.
kubectl rollout undo deployment/$DEPLOYMENT_NAME
```

## 4.2) Jobs & CronJobs


### Adhoc Workloads

#### Docker

* In docker an adhoc workload would run inside a container and the container will exit once its finished.

![docker-adhoc-job.png](docker-adhoc-job.png)

#### k8s

* In k8s an adhoc workload would run inside a Pod and when the Pod has finished, k8s will try to restart it. This will happen until a threshold is reached. This behaviour is undesirable for this type of workload. You can see this in the below screenshot by looking at RESTARTS.

![k8s-adhoc-job.png](k8s-adhoc-job.png)

* This is because `restartPolicy: Always` is set by default for a container. Other options are `Never` and `Failure`.

![restart-policy.png](restart-policy.png)

### Jobs

* https://kubernetes.io/docs/concepts/workloads/controllers/job/
* **Jobs** create one or more Pods and ensure that a specified number of them complete successfully.
* Jobs are used for workloads that aren't expect to run continually forever like a web server, and they are run at adhoc times.

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: adder-job
spec:
  # How many Pods must complete successfully.
  completions: 3
  # How many Pods to run concurrently.
  parallelism: 3
  template:
    # Move everything from the Pod definition spec section here.
    spec:
      containers:
      - name: adder
        image: ubuntu
        command: ["expr", "3", "+", "5"]
      restartPolicy: Never
```

* By default:
  * A Jobs output is stored in the Pods standard output. That can be redirected elsewhere.
  * Jobs don't run in parallel.
  * Jobs will run until a single completion.

![jobs-commands.png](jobs-commands.png)

* Be careful of Jobs with a high completion rate, high failure rate, and no parallelism. These Jobs may take a long time to reach their goal. Solve this by using parallelism.

![job-completion-changed.png](job-completion-changed.png)

```bash
# Create a Job
kubectl create -f job-definition.yml

# View the Pods created by a Job
kubectl get pods

# View Pod log to view Job stdout
kubectl logs $POD_NAME

# Delete Job
kubectl delete job $JOB_NAME

# Get Jobs information
kubectl get jobs
kubectl get jobs -o wide
kubectl get all
kubectl describe jobs

# Get Job specific information
kubectl get job $JOB_NAME

# Update Existing Job With File - remember to delete the existing Jobs for the changes to apply
kubectl replace -f job-definition.yml

# Update Existing Job Without File - remember to delete the existing Jobs for the changes to apply
kubectl edit job $JOB_NAME

# Extract Job Definition From Running Job
kubectl get job $JOB_NAME -o yaml > job-definition.yaml
```

### CronJobs

* https://kubernetes.io/docs/concepts/workloads/controllers/cron-jobs/
* **CronJobs** are Jobs but can be repeated via schedules. The use the `crontab` syntax.

```bash
# ┌───────────── minute (0 - 59)
# │ ┌───────────── hour (0 - 23)
# │ │ ┌───────────── day of the month (1 - 31)
# │ │ │ ┌───────────── month (1 - 12)
# │ │ │ │ ┌───────────── day of the week (0 - 6) (Sunday to Saturday;
# │ │ │ │ │                                   7 is also Sunday on some systems)
# │ │ │ │ │
# │ │ │ │ │
# * * * * * <command to execute>
```

* https://crontab.guru/ useful site for crontab scheduling.

```yaml
apiVersion: batch/v1beta
kind: CronJob
metadata:
  name: adder-cronjob
# CronJob spec
spec:
  # crontab entry for every minute
  schedule: "*/1 * * * *"
  jobTemplate:
    # Job spec
    # Move everything from the Job definition spec section here.
    spec:
      # How many Pods must complete successfully.
      completions: 3
      # How many Pods to run concurrently.
      parallelism: 3
      template:
        # Pod spec
        # Move everything from the Pod definition spec section here.
        spec:
          containers:
          - name: adder
            image: ubuntu
            command: ["expr", "3", "+", "5"]
          restartPolicy: Never
```

```bash
# Create a CronJob
kubectl create -f cronjob-definition.yml

# View the Pods created by a CronJob
kubectl get pods

# View Pod log to view CronJob stdout
kubectl logs $POD_NAME

# Delete Job
kubectl delete cronjob $JOB_NAME

# Get CronJob information
kubectl get cronjob
kubectl get cronjob -o wide
kubectl get all
kubectl describe cronjob

# Get CronJob specific information
kubectl get cronjob $JOB_NAME

# Update Existing CronJob With File - remember to delete the existing CronJob for the changes to apply
kubectl replace -f cronjob-definition.yml

# Update Existing CronJob Without File - remember to delete the existing CronJob for the changes to apply
kubectl edit cronjob $JOB_NAME

# Extract CronJob Definition From Running CronJob
kubectl get cronjob $JOB_NAME -o yaml > job-definition.yaml
```

# 5) Services & Networking

## 5.1) Services

See [1.8) k8s Networking Recap](#18-k8s-networking-recap)

## 5.2) Ingress

* https://kubernetes.io/docs/concepts/services-networking/ingress/
* Ingress exposes HTTP and HTTPS routes from outside the cluster to services within the cluster. Think of it as a layer 7 load balancer within k8s that can be configured to handle SSL, load balancing, authentication, and URL based routing. The Ingress needs to be exposed,

### Example Website

Why do we need an Ingress? Lets look at an example.

#### Initial Setup

* We have a simple web app running in a Deployment with one Pod on one Node.
* There is a database running in a Pod on a Node.
* There is a ClusterIP Service between the app and database.
* There is a NodePort exposing the Node to the internet.
* Users can connect to this directly to the Nodes via the Node IP address and NodePort port.

![app-setup-1.png](app-setup-1.png)

#### Scaling The App

* We scale the app by increasing the Deployments Replica amount which will increase the amount of Pods. The NodePort Service handles load balancing between the Pods.

![app-setup-2.png](app-setup-2.png)

#### URL:port Instead Of IP:port

* We don't want users to have to type an IP address. So the Website domain DNS is now mapped to the IP addresses of the Nodes.

![app-setup-3.png](app-setup-3.png)

#### Website URL Only

* We don't want users to have to type a port either. So the website domain DNS points to a proxy address listening on port 80. The proxy server will forward requests to the Nodes on the NodePort.

![app-setup-4.png](app-setup-4.png)

#### Google Cloud Provider

* For a web application hosted on a cloud provider, you can replace the NodePort with a LoadBalancer. This will automatically configure a proxy to route traffice to your LoadBalancer. The website domain DNS now points to the IP address of the Google Cloud proxy load balancer.

![app-setup-5.png](app-setup-5.png)

#### Adding Another App And SSL

* An additional application can easily be added by using Deployments, a new LoadBalancer, and a new Google Cloud proxy load balancer. SSL Can be added by yet another proxy.

![app-setup-6.png](app-setup-6.png)

#### Replacing With Ingress

**Ingress can replace:**
* SSL Proxy
* Proxy and proxy load balancers
* NortPort or GCP LoadBalancer

![without-ingress.png](without-ingress.png)

becomes

![with-ingress.png](with-ingress.png)

Notice that the ingress is exposed as well.

### How Does Ingress Work

A k8s Ingress needs 2 things to work:
1. An **Ingress Controller**
2. And **Ingress resource(s)**

### Ingress Controller

* https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/
* https://kubernetes.github.io/ingress-nginx/deploy/
* In order for the Ingress resource to work, the cluster must have an ingress controller running.
* This is not installed by default with k8s, you need to install it manually.
* It is either and Nginx proxy that is specially configured for k8s, or it is a GCP LoadBalancer.
* These special proxys monintor the cluster for new Ingress Resources and automatically configure themselves for them.

#### Creating An Ingress Controller

* You need multiple components to create an Ingress Controller.
1. A blank ConfigMap that can be confingured later for log location, SSL, etc. This will be added into the Deployment so the nginx configruation details are decoupled from the Deployment file.
1. A Deployment ising the image `ngnix-ingress-controller`. The Deployment must have:
  * 2 arguments:
    1. An argument `nginx-ingress-controller` to start the special version of k8s Nginx.
    1. The ConfigMap object contains all the nginx configuration data. A blank ConfigMap can be used but it must exist for the Ingress Controller to work.
 * 2 environment variables
    1. The Pod's name
    1. The namespace to be deployed into.
  * The ports used by the Ingress Controller, which are standard http port 80 and https 443.
3. A Service of type NodePort is needed to expose the Ingress Controller to the world.
4. A Service Account with the correct roles and bindings is needed. The Ingress Controller uses this when it detects Ingress Resources changes and updates the nginx configuration.

![ingress-controller-components.png](ingress-controller-components.png)

### Ingress Resources

* Traffic routing is controlled by rules defined on the Ingress resource. These are created with k8 YAML object files and are applied to the Ingress Controller.
* The traffic is routed to Services which then handles traffic routing to Pods.
* Traffic routing can be done a number of different ways:
  1. Forward all traffic to a single application.
  2. Route traffic to different applications based on URL.
  3. Route traffic to different applications based on the domain name.

![ingress-resource-routing.png](ingress-resource-routing.png)

* There are rules at the top for each domain and then rules for paths within the domain.

![ingress-resource-rules.png](ingress-resource-rules.png)

### Forward All Traffic To Single Application

![ingress-service-routing-rule.png](ingress-service-routing-rule.png)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: service-routing-ingress
spec:
  backend:
    serviceName: service-to-route-to
    servicePort: 80
```

### Route Traffic Based On URL

![ingress-path-routing-rule.png](ingress-path-routing-rule.png)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: url-routing-ingress
spec:
  rules:
  - http:
      paths:
      - path: /path-1
          backend:
            serviceName: path-1- service-to-route-to
            servicePort: 80
      - path: /path-2
          backend:
            serviceName: path-2- service-to-route-to
            servicePort: 80
```

**Note:** We didn't specifiy `host:` here so it is defaulted to a *, i.e. all traffic is routed here.

### Route Traffic Based On Domain

![ingress-domain-routing-rule.png](ingress-domain-routing-rule.png)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: domain-routing-ingress
spec:
  rules:
  - host: sub-domain-1.my-domain.com
    http:
      paths:
        backend:
          serviceName: sub-domain-1- service-to-route-to
          servicePort: 80
  - host: sub-domain-2.my-domain.com
    http:
      paths:
        backend:
          serviceName: sub-domain-2- service-to-route-to
          servicePort: 80
```

**Note:** We didn't specifiy `path:` here so all traffic is routed to the service. We could use additional path routing rules here if we wanted to.

### Useful Commands

```bash
# View all ingress objects
kubectl get ingress --all-namespaces

# Get specific ingress object
kubectl -n $NAMESPACE get ingress $INGRESS_NAME

# Get ingress controller pod
kubectl -n $NAMESPACE get pods
kubectl -n $NAMESPACE describe deployments.apps nginx-ingress-controller

# View ingress resource yaml
kubectl -n $NAMESPACEget ingress $INGRESS_NAME -o yaml
```

## 5.3) Network Policy

### Network Traffic Example

This simple application accepts user data via a web server on port 80. An API request is sent on port 5000. The API server sends a request to the database on port 3306. The data is sent back to the user.

![network-traffic-example-1.png](network-traffic-example-1.png)

In k8s this would be implemented with pods and services possibly spanning across multiple nodes.

![network-traffic-example-2.png](network-traffic-example-2.png)

### Ingress vs Egress Network Traffic

**Ingress network traffic** is external traffic coming into the destination pod.

**Egress network traffic** is internal traffic going out of the source pod.

![network-traffic-example-3.png](network-traffic-example-3.png)

The above diagram shows ingress and egress traffic from the perspective of different services. This would require multiple k8s ingress and egress network policies on multiple pods.

![network-traffic-example-4.png](network-traffic-example-4.png)

### k8s Network Security

https://kubernetes.io/docs/concepts/services-networking/network-policies/

By default, if no policies exist in a namespace then all traffic is allowed between all pods in that namespace. They are implemented by the networking solution on the cluster and not all networking solutions support them.

https://kubernetes.io/docs/concepts/services-networking/network-policies/#default-policies

![all-allow.png](all-allow.png)

**Network policies** are k8s objects are used to allow or deny traffic to the pod they are applied to. Labels and selectors are used to link a network policy to a pod.

![network-policy-1.png](network-policy-1.png)

![network-policy-2.png](network-policy-2.png)

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: test-network-policy
  namespace: default
spec:
  podSelector:
    matchLabels:
      role: db
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - ipBlock:
        cidr: 172.17.0.0/16 # Cluster external IP
        except:
        - 172.17.1.0/24
    - namespaceSelector:
        matchLabels:
          project: myproject
    - podSelector:
        matchLabels:
          role: frontend
    ports:
    - protocol: TCP
      port: 6379
  egress:
  - to:
    - ipBlock:
        cidr: 10.0.0.0/24
    ports:
    - protocol: TCP
      port: 5978
```

```bash
kubectl create -f $MY_NETWORK_POLICY

kubectl get networkpolicies.networking.k8s.io --all-namespaces

kubectl -n default describe networkpolicies.networking.k8s.io payroll-policy
```

# 6) State Persistence

