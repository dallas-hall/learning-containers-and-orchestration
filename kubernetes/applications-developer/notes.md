# k8s Application Developer Notes

* Second course in a series [beginner, developer, administrator]
* Can do the exam if you want

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
* Containers are more resource friendly than VMs. They are typically 100s of MB in size whereas VMs are typically GBs in size.  It is common to run containers within VMs.

![container v vm](container-vs-vm.png)

* A **Docker Image** is a template used to create a **Docker Container**. Thus like in OOP, the Docker Image is the blueprint and the Docker Container is the running instance.

![image v container](image-v-container.png)

* A **Dockerfile** is a file has the necessary steps to build a Docker Image and subsequent Containers.

![Dockerfile](Dockerfile.png)

* Traditionally a developer would hand over the operations team the compiled application and a list of instructions on how to deploy it. This would change with each environment and become complicated quickly. Now a developer just hads the operations team the Dockerfile and they are able to build the Docker Container the same way in each environment.

## 1.2) Container Orchestration

![Container orchestration](container-orchestration.png)

* The process of automatically deploying and managing containers is called Container Orchestration. This can provide:
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
```

## 1.5) k8s Controller Recap

* These are the brains behind k8s.
* **Controllers** are processes that monitor k8s objects and respond to accordingly to events.

### 1.5.1) Replication Controller

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

### 1.5.2) ReplicaSet

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

* Applications and their dependencies need to be deployed (i.e installed) into environments. Each environment might have differnet installationrequirements. Environment upgrades can be difficult as well. k8s can handle this with the Deployment object
* A **Deployment** object will create a ReplicaSet, and the ReplicaSet will create the Pods.
  * The ReplicaSet and Pods created by a Deployment will have the Deployment's name in their name.
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

# Rollback An Update
kubectl rollout undo deployment/$DEPLOYMENT_NAME

# Create a YAML file
kubectl create deployment --image=image-name $DEPLOYMENT_NAME --replicas=n --dry-run -o yaml > deployment.yaml
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
  * Recreate strategy = delete all at once and create all at once, this means there will be an outage
  * Rolling Update = delete old Pods and replace with new Pods 1 by 1, this means no outage. DEFAULT
* Updates to version numbers are applied in the Deployment YAML file, by specifying the image tag version.
  * If you do it from the command line, the running Deployment is updated but this doesn't update the YAML file.
* A new ReplicaSet is created when upgrades are performed. Pods from the original ReplicaSet are destroyed and Pods in the new RepliceSet are created
* A **Rollback** is when you undo a Deployment and go back to a previous Rollout version.

![Upgrades](upgrades.png)

![Rollback](rollback.png)

## 1.7) k8s Namespaces

* **Namespaces** are names that are used to group objects together and provides each object within the group a unique name to all other objects outside the group, even if they have the same name. These are method of providing isolation (i.e. variable scope) to objects.
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

* All commands by default use the default Namespace, you can use the `--namespace` option to look at other namespaces.
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

![IP address clash](ip-address-clash.png)

![Custom network layer](networking-layer.png)

each Node has an IP address (e.g. for ssh etc)
each Pod has its own internal dynamic IP address, but for multiple Node clusters each Node/Pod gets the same IP address and this will cause networking conflicts. 
k8s does not setup any networking to handle networking conflicts, you must do that yourself with an external application (e.g calico) this network manager will manage networking within the cluster and assign different IP addresses to each node and thus each Pod

### 1.8.1) k8s Services

![Services overview](services-overview.png)

enable communications between various cluster components.
helps us connect applications/users together by loosely coupling them together

#### NodePort

![NodePort](nodeport-1.png)
![NodePort](nodeport-2.png)
![NodePort](nodeport-3.png)


how do external users access a k8s application externally through a browser? connect to the external Node IP and a Service (NodePort) will forward the request to a Node's internal IP address by mapping a port on the Node to a port on a Pod
3 ports involved here
* the port running on the Pod, called the TargetPort
* the port running on the Service, called the Port
* the port running on the Node, called the NodePort, 30000-32767 default range
the Pod label is used by Service selector to find all pods to apply the NodePort to and when Pods are on multipe Nodes in the cluster, the Service automatically spans across the Nodes.

![NodePort](nodeport-label-and-selector.png)

for multiple nodes, the service will provides access to each node via its own IP and the same port.
![NodePort](nodeport-multinodes.png)


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

# Create a Service
# kubectl create -f service-definition.yml
kubectl expose pod redis --port=6379 --name redis-service

 # Delete Service
# kubectl delete service my-service

# Get Service information
# kubectl get services
# kubectl get service my-service
# kubectl get all
# kubectl describe service

# Update Existing Pod
# Using this file= kubectl replace -f mypod-definition.yml
# Update this file= kubectl edit pod $POD_NAME
```

#### ClusterIP

![ClusterIP](clusterip.png)

the Service creates a virtual IP within the cluster and that is used for network communications
this can used when you have multiple Pods.
a fullstack application typically has a multiple set of Pods running different tiers of the application (e.g, frontend web app, backend databases, messaging services, etc) - the ClusterIP Service helps up group Pods together and provides a single interface to access the different tiers of Pods
each Service gets a name and IP address and that is what is used to access the Pods grouped with the Service.

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

# Create a Service
# kubectl create -f service-definition.yml

 # Delete Service
# kubectl delete service my-service

# Get Service information
# kubectl get services
# kubectl get service my-service
# kubectl get all
# kubectl describe service

# Update Existing Pod
# Using this file= kubectl replace -f mypod-definition.yml
# Update this file= kubectl edit pod $POD_NAME
```

#### LoadBalancer

![Cloud LoadBalancer](loadbalancer.png)

Delegates control to a cloud provider's (e.g. Google/AWS) load balancing agent
