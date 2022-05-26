# Docker For Beginners

- [Docker For Beginners](#docker-for-beginners)
  - [1) Why Docker?](#1-why-docker)
    - [1.1) What Are Containers?](#11-what-are-containers)
    - [1.2) Docker Versions](#12-docker-versions)
  - [2) Basic Docker Commands](#2-basic-docker-commands)
    - [2.1) docker run](#21-docker-run)
    - [2.2) docker attach](#22-docker-attach)
    - [2.3) docker ps](#23-docker-ps)
    - [2.4) docker stop](#24-docker-stop)
    - [2.5) docker rm](#25-docker-rm)
    - [2.6) docker exec](#26-docker-exec)
    - [2.7) docker images](#27-docker-images)
    - [2.8) docker rmi](#28-docker-rmi)
    - [2.9) docker pull](#29-docker-pull)
    - [2.10) docker inspect](#210-docker-inspect)
    - [2.11) docker logs](#211-docker-logs)
    - [2.11) docker build](#211-docker-build)
      - [2.11.1) Dockerfile](#2111-dockerfile)
      - [2.11.1.2) CMD vs ENTRYPOINT](#21112-cmd-vs-entrypoint)
    - [2.12) docker push](#212-docker-push)
    - [2.13) docker history](#213-docker-history)
  - [3) Docker Compose](#3-docker-compose)
  - [4) Docker Registry](#4-docker-registry)
  - [5) Docker Engine](#5-docker-engine)
  - [6) Docker Storage](#6-docker-storage)
    - [Filesystems](#filesystems)
    - [Volumes](#volumes)
    - [Storage Drivers](#storage-drivers)
  - [7) Docker Networking](#7-docker-networking)
    - [7.1) Network Types](#71-network-types)
    - [7.2) docker inspect](#72-docker-inspect)
    - [7.3) Docker DNS](#73-docker-dns)
  - [8) Container Orchestration](#8-container-orchestration)

## 1) Why Docker?

Mumshad's reasons for using Docker
* He was working on a project with a web server (NodeJS), database (MongoDB), messaging service (Redis), and an orchestrator (Ansible). It was a struggle to:
  * Get these services to work together on one O/S. As they all have different dependencies and supporting library requirements. Sometimes these are conflicting and cannot be resolved easily.
  * Get new developers to set up their own replica of this environment. A lot of time was wasted in trying to solve all the issues encountered above.

![images/matrix-from-hell.png](images/matrix-from-hell.png)

Docker solves this by
* Allowing each service to run in its own O/S inside its own container. This means that each service and its dependencies and required libraries were all separated from each other.
* Each developer could easily replicate the enivronment with some simple Docker commands.

![images/docker-solving-matrix-from-hell.png](images/docker-solving-matrix-from-hell.png)

### 1.1) What Are Containers?

* **Containers** are an isolated environment with its own resources (e.g. processes, network interfaces, storage etc) within an operating system but all containers within the same O/S share the same kernel.

![images/container-example.png](images/container-example.png)

* Containers are used to isolate applications from each other. Each container has its own O/S that supports the application and its dependencies.

![images/container-example-detailed.png](images/container-example-detailed.png)

* A container can only run on the same O/S kernel that it has. So if Docker is running on a Linux kernel, any Linux distribution can run on it. Running a Linux Docker container on Windows actually spins up a Linux VM.

![images/kernel-sharing.png](images/kernel-sharing.png)

* Containers are not new but Docker is a high level tool that has made them very popular.
* Docker uses LXC containers.
* Containers are more resource friendly than VMs. They are typically 100s of MB in size whereas VMs are typically GBs in size.  It is common to run containers within VMs.

![images/container-vs-vm.png](images/container-vs-vm.png)

* It is common to run containers inside of VMs. VMs are easy to provision in cloud environments and on premesis installations.

![images/containers-and-vms.png](images/containers-and-vms.png)

* A **Docker Image** is a template used to create a **Docker Container**. Thus like in OOP, the Docker Image is the blueprint and the Docker Container is the running instance.

![images/image-v-container.png](images/image-v-container.png)

* A **Dockerfile** is a file has the necessary steps to build a Docker Image and subsequent Containers.

![images/Dockerfile.png](images/Dockerfile.png)

* Traditionally a developer would hand over the operations team the compiled application and a list of instructions on how to deploy it. This would change with each environment and become complicated quickly. Now a developer just hads the operations team the Dockerfile and they are able to build the Docker Container the same way in each environment.

* Docker Images are publically available from Docker Hub. There are many images available for many types of O/S and applications.

* Docker contributes to DevOps by making it easier for operations teams to install applications that they received from development teams. The development team provies the Dockerfile and the operations team use this to deploy the application.

### 1.2) Docker Versions

* Docker has 2 versions:
1. **Community edition (CE)** is the set of free Docker products.
2. **Enterprise edition (EE)** comes with additional features that you need to pay for.

## 2) Basic Docker Commands

**NOTE:** All Docker IDs only require enough characters in them to uniquely identify the object. You don't need to user the entire ID.

### 2.1) docker run

**NOTE:** The container will only run while an application inside of them is running. This does not include shells like bash. So O/S images will exit immediately if they are only running a shell.

**NOTE:** You can use `$IMAGE_NAME` or `$IMAGE_ID` on the commands below.

* `docker run $IMAGE_NAME` will run the specified image on the current host as a container. If the current host doesn't have the image locally it will go to Docker Hub and download it. If the current host does have the image locally it will just use that image.

![images/docker-run.png](images/docker-run.png)

* By default `docker run $IMAGE_NAME` will run in attached mode, i.e. your terminal will be attached to stdout of the container. Use `docker run -d $IMAGE_NAME` to run in detached mode.

![images/docker-run-detached.png](images/docker-run-detached.png)

* By default Docker does not listen to stdin from the CRE host to the container. You need to use `docker run -i $IMAGE_NAME` to enable interactive mode and map the CRE host's stdin to the container's stdin.
* Use `docker run -t $IMAGE_NAME` to attach to the container's terminal.
* Often you will use `docker run -it $IMAGE_NAME` to attach to the container's terminal in interactive mode.

![images/docker-run-iteractive-terminal.png](images/docker-run-iteractive-terminal.png)

* When using `docker run $IMAGE_NAME` the tag `:latest` is automatically appended to the name. This will automatically use the Docker image that is associated with the latest tag which is typically the latest version.
* You can use `docker run $IMAGE_NAME:$TAG_NAME` to manually specfiy with image version (i.e. tag) to use.

![images/docker-tags.png](images/docker-tags.png)

* Use `docker run $IMAGE_NAME -p $CRE_PORT:$CONTAINER_PORT` to map an available CRE host port to an available container port.
  * In this example all traffic on `$CRE_HOST_IP:$CRE_PORT` is routed to the container via `$CONTAINER_PORT`

![images/docker-run-port-mapping.png](images/docker-run-port-mapping.png)

* Use `docker run $IMAGE_NAME -v $CRE_PATH:$CONTAINER_PATH` to map a CRE filesystem path to a container filesystem path. This decouples the data lifecycle from the container lifecycle. When the container is destroyed the volume and data will remain.

![images/docker-run-volume-mapping.png](images/docker-run-volume-mapping.png)

* Use `docker run -e $KEY=$VALUE $IMAGE_NAME` to inject an environment variable into the container.

![images/docker-run-environment-variables.png](images/docker-run-environment-variables.png)

* Use `docker run $IMAGE_NAME $CMD` to specify which command to run inside the container.
* Use `docker run $IMAGE_NAME $CMD $ARGS` to specify which command to run inside the container and what arguments it takes.

**NOTE:** You can use `$CONTAINER_NAME` or `$CONTAINER_ID` on the `--link` option below.

* Use `docker run --link $CONTAINER_NAME $IMAGE_NAME $CMD` to specify which container to link to this container.

### 2.2) docker attach

**NOTE:** You can use `$CONTAINER_NAME` or `$CONTAINER_ID` on the commands below.

* Use `docker attach $CONTAINER_NAME` to attach to a detached container.

### 2.3) docker ps

**NOTE:** Each container automatically gets a random UID and name created for it.

* `docker ps` lists all the running containers and some basic information about them.
* `docker ps -a` lists all running containers and stopped containers and some basic information about them.

![images/docker-ps.png](images/docker-ps.png)

### 2.4) docker stop

**NOTE:** You can use `$CONTAINER_NAME` or `$CONTAINER_ID` on the commands below.

* `docker stop $CONTAINER_NAME` will stop a running container. These can still be viewed and take up space.

![images/docker-stop.png](images/docker-stop.png)

### 2.5) docker rm

**NOTE:** You can use `$CONTAINER_NAME` or `$CONTAINER_ID` on the commands below.

* `docker rm $CONTAINER_NAME` will delete a stopped container.

![images/docker-rm.png](images/docker-rm.png)

### 2.6) docker exec

**NOTE:** The container will only run while an application inside of them is running. This does not include shells like bash. So O/S images will exit immediately if they are only running a shell.

**NOTE:** You can use `$IMAGE_NAME`, `$IMAGE_ID`, `$CONTAINER_NAME`, or `$CONTAINER_ID` with the commands below.

* `docker exec $CONTAINER_NAME $CMD` executes a command on a running container.
* Using `docker exec -it $CONTAINER_ID bash` will connect to the container in interactive mode (i.e. you can type) and load a shell.

![images/docker-exec.png](images/docker-exec.png)

### 2.7) docker images

* `docker images` lists all local images on the system.

### 2.8) docker rmi

**NOTE:** You can use `$IMAGE_NAME` or `$IMAGE_ID` on the commands below.

* `docker rmi $IMAGE_NAME`  will delete all local images. All dependent containers must be stopped before deleting an image.
* This is a shortcut for `docker iamge rm $IMAGE_NAME`

![images/docker-rmi.png](images/docker-rmi.png)

### 2.9) docker pull

* `docker pull $IMAGE_NAME` will download the specified image but not run it.

![images/docker-pull.png](images/docker-pull.png)

### 2.10) docker inspect

**NOTE:** You can use `$CONTAINER_NAME` or `$CONTAINER_ID` on the commands below.

* Use `docker inspect $CONTAINER_NAME` to view verbose information about a container. This is returned in a JSON format and it contains all information about a container.

![images/docker-inspect.png](images/docker-inspect.png)

### 2.11) docker logs

**NOTE:** You can use `$CONTAINER_NAME` or `$CONTAINER_ID` on the commands below.

* Use `docker logs $CONTAINER_NAME` to view the logs of a container.
* Use `docker logs -f $CONTAINER_NAME` to view the logs of a container in real time.

![images/docker-logs.png](images/docker-logs.png)

### 2.11) docker build

* The first step is to write down the steps you would do to manually deploy the application.

![images/image-creation-v1.png](images/image-creation-v1.png)

* The second step is to convert these to a Dockerfile.

```Dockerfile
FROM Ubuntu
RUN apt-get update
RUN apt-get install python
RUN pip install flask
RUN pip install flask-mysql
COPY . /opt/source-code
ENTRYPOINT FLASK_APP=/opt/source-code/app.py flask run
```

* Use `docker build $PWD -f Dockerfile -t $IMAGE:$TAG` to build an image with a tag. This will build it locally, you need to push this to an external image repository.

![images/docker-build-and-push.png](images/docker-build-and-push.png)

#### 2.11.1) Dockerfile

* This is a textfile containing the insutrctions to build the image. It uses the instruction and argument format. Insutrctions are in capital letters and are reserved words and the arguments are what o do.

![images/dockerfile.png](images/dockerfile.png)

#### 2.11.1.2) CMD vs ENTRYPOINT

* Dockerfiles may contain `CMD` and / or `ENTRYPOINT`.
* `CMD` by itself is a hard coded shell format or JSON array format for the command and its arguments. Any arguments supplied to `docker run` overwrite it. The first element is the command to be run.

![images/Dockerfile-CMD.png](images/Dockerfile-CMD.png)

* `ENTRYPOINT` by itself is a hard coded shell format or JSON array format for the command. Any arguments supplied to `docker run` are appended here as arguments.

![images/Dockerfile-CMD.png](images/Dockerfile-CMD.png)

* When used together `ENTRYPOINT` is the hard coded shell format or JSON array format for the command and `CMD` is the hard coded shell format or JSON array format for the default arguments. Any arguments supplied to `docker run` are appended to `ENTRYPOINT` as arguments and override `CMD`.

**NOTE:** `docker run --entrypoint $CMD $IMAGE_NAME` can be used to override the `ENTRYPOINT` of a Dockerfile.

![images/Dockerfile-BOTH.png](images/Dockerfile-BOTH.png)

### 2.12) docker push

**NOTE:** You can use `$IMAGE_NAME` or `$IMAGE_ID` on the commands below.

* Use `docker push $IMAGE:TAG` to push this to the Docker Hub image repo.

![images/docker-build-and-push.png](images/docker-build-and-push.png)

### 2.13) docker history

**NOTE:** You can use `$IMAGE_NAME` or `$IMAGE_ID` on the commands below.

* Docker builds images in a layered architecture. Each line in a Dockerfile creates a new image with the changes from the previous image. Each layer only stores the changes from the previous layer.

![images/dockerfile-v2.png](images/dockerfile-v2.png)

* Use `docker history $IMAGE_NAME` to view this layered architecture.
* All layers are cached by Docker and will be reused in subsequent builds.

## 3) Docker Compose

https://docs.docker.com/compose/

* Docker compose uses a YAML file called `docker-compose.yaml` to define and run applications that have multiple containers. This replaces having to run multiple `docker` commands to set everything up.
* `docker-compose up`

![images/docker-compose.png](images/docker-compose.png)

* You can build images via Docker compose as well. You need to use the `build: $PATH` entry to specify the path where to get the Dockerfile from to build the image.

![images/docker-compose-with-build.png](images/docker-compose-with-build.png)

* There are different versions of Docker compose so there are different valid syntaxes for `docker-compose-.yaml` files. Check out the documentation for what each version supports.

![images/docker-compose-versions.png](images/docker-compose-versions.png)

```yaml
services:
  redis:
    image: redis:alpine
  clickcounter:
    image: kodekloud/click-counter
    ports:
    - 8085:5000
version: '3.0'
```

## 4) Docker Registry

* This is a central repository of all Docker images, currently this is https://docker.io
* The `image: $IMAGE_NAME` actually expands into `image: $DOCKERHUB_URL/$DOCKERHUB_USER:$IMAGE_NAME`

![images/docker-registry-expansion.png](images/docker-registry-expansion.png)

* Use `docker login $PRIVATE_REGISTRY_URL` to access your personal registry and `docker run $PRIVATE_REGISTRY_URL $IMAGE_NAME` to run an image from your private registry. You must login first before doing this.

![images/docker-private-registry.png](images/docker-private-registry.png)

* You can deploy your own private Docker registry using the image `registry` on port 5000. You will need to use your `$PRIVATE_REGISTRY_URL` with all `docker` commands.

![images/docker-private-registry-v2.png](images/docker-private-registry-v2.png)

## 5) Docker Engine

The Docker Engine is a host with Docker installed on it. It has 3 parts:
1. **Docker CLI:** the command line interface that users use to submit commands. Commands are submitted to the REST API server.
2. **REST API server:** the API interface that programs use to talk to the Docker Daemon.
3. **Docker Daemon**: a background service that manages Docker objects (e.g. images, containers, volumes etc.)

![images/docker-engine.png](images/docker-engine.png)

* Use `docker -H=$HOST:$PORT $CMD` to run Docker CLI commands on a remote host.

![images/docker-engine-remote.png](images/docker-engine-remote.png)

* Docker uses Linux namespaces to isolate a container's workspace which makes the container thinks it is its own system. The namespaces cover things like:
  * Process IDs
  * Networking
  * Volume mounts
  * Unix timesharing
  * Interprocess communication

![images/namespaces.png](images/namespaces.png)

* For example the Process ID namespace allows a process to have multiple process IDs. e.g. its real process ID on the Docker Engine host and its fake process ID inside of its own namespace.

![images/process-id-namespace.png](images/process-id-namespace.png)

* A Docker container uses the system resources from the Docker Enginer host, such as CPU and memory. By default there is no restriction on how much resources a container can use. Docker can use cgroups (i.e. control groups) to manage how much Docker Engine host resources a container consumes.
* Use `docker run --cpus=.5 $IMAGE` and `docker run --memory=100m $IMAGE` to allocate resources.

![images/namespaces-v2.png](images/namespaces-v2.png)

## 6) Docker Storage

### Filesystems

* By default Docker creates its folders at `/var/lib/docker` and it stores all of its data here in a series of sub-folders.
  * The `containers` folder stores container related files.
  * The `image` folder stores image related files.
  * The `volumes` folder stores volume mount related files.

![images/docker-file-system-v1.png](images/docker-file-system-v1.png)

* We learnt earlier that Docker stores data a layered architecture and each layer only stores the changes from the previous layer. These layers are stored on the disk in `/var/lib/docker`. This approach is efficient because:
  * It saves space by not reusing existing layers.
  * It saves build time by not rebuilding existing layers.

![images/docker-file-system-v2.png](images/docker-file-system-v2.png)

* All of the layers that are used to create a Docker Image are known as the **Image Layer**. These become a read only layer inside of any container using this image. They can only be modified be doing another build.
* When a container is run a new layer that is readable and writeable is created, this layer is called the **Container Layer**.
  * Data created by the application is stored here.
  * This layer is transient and is destroyed when the container is destroyed. This
  * Any modifications attemped on a file  in the Image Layer results in copy of that file being created in the Container Layer. All edits are stored here and they are transient. This is called **Copy On Write**.
  * The same Container Layer is shared by all containers that were created with the same image.

![images/docker-file-system-v3.png](images/docker-file-system-v3.png)

![images/docker-file-system-v4.png](images/docker-file-system-v4.png)

### Volumes

* A **Persistent Volume** can be created and used by a container to store data that will not be deleted when the container finishes running.
  * The PV is mounted inside of the Container Layer but its lifecycle is decoupled from the container.
* `docker volume create $VOLUME_NAME` will create a Persistent Volume within `/var/lib/docker/volumes/$VOLUME_NAME`.
* `docker run -v $VOLUME_NAME:$MOUNT_PATH $IMAGE` will create a container using the PV from `/var/lib/docker/volumes/$VOLUME_NAME`. This is called **Volume Mounting**.
  * If you created the PV before `docker run` it will use that PV.
  * If you created the PV after `docker run` it will create a PV for you and mount it to the container.
* Use `ls /var/lib/docker/volumes` to see all Docker PVs.
* `docker run -v $VOLUME_PATH:$MOUNT_PATH $IMAGE` will create a container using the PV from `$VOLUME_PATH` on the Docker Host. This is called **Bind Mounting**.

![images/docker-volumes-v1.png](images/docker-volumes-v1.png)

* `docker run -v $VOLUME_PATH:$MOUNT_PATH $IMAGE` is deprecated and should be written as `docker run --mount type=bind,source=$VOLUME_PATH,target=$MOUNT_PATH $IMAGE`

### Storage Drivers

* **Storage Drivers** are responsible for all storage related actions. Such as looking after the image layers, mounting, etc.
* There are many types of Storage Drivers and Docker automatically detects which one is being used by the O/S on the Docker Host. Some O/S don't support some SDs.

![images/docker-storage-driver.png](images/docker-storage-driver.png)


## 7) Docker Networking

### 7.1) Network Types

![images/docker-networks-v1.png](images/docker-networks-v1.png)

* Docker has 3 types of networks:
  1. This is the default network. The **Bridge** network is private virtual network created on the Docker Host within a Network Namespace. All containers attach this by default using Virtual Ethernet pairs.  The default IP address range inside of the `172` series. Ports on the Docker Host need to be mapped to ports within the Network Namespace.
  2. The **Host** network is when containers are directly attached to the Docker Host's network. There is no isolation between them thus there is no need to map ports between them.
  3. The **None** network is when containers aren't attached to any network and have no network access.

![images/docker-networks-v2.png](images/docker-networks-v2.png)

* By default Docker only creates one Bridge Network within a Network Namespace. You can use `docker network create --driver bridge --subnet $CIDR $NETWORK_NAME` to create an additional one and attach containers to that network.
* Use `docker network ls` to view all Docker Networks.

![images/docker-networks-v3.png](images/docker-networks-v3.png)

### 7.2) docker inspect

* User `docker inspect $CONTAINER_NAME` or `docker inspect $CONTAINER_ID` to view details about the container, including networking details.

![images/docker-networks-v4.png](images/docker-networks-v4.png)

### 7.3) Docker DNS

* Docker creates a DNS server within the container network space. This allows containers to communicate with each other via `$CONTAINER_NAME` or `$CONTAINER_IP`. You should use the `$CONTAINER_NAME` as the IP address may change later.
* The Docker DNS Nameserver is running at `127.0.0.11`

![images/docker-networks-v5.png](images/docker-networks-v5.png)

## 8) Container Orchestration



![images/](images/)