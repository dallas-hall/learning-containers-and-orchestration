# Course

Getting Start with Google Kubernetes - https://www.coursera.org/learn/google-kubernetes-engine/home/welcome

# Week 1

## 1.1) Introduction To Containers
### Environments

`Develop -> Staging -> Production`

### Why Containers?
#### Traditional

Used bare metal computers. For each application, you had the following stack in a dedicated server.

* App code
* App dependencies
* OS and kernel
* Hardware

This usually took months to deploy, there was low hardware resource usage, and it wasn't poratable.

It was very hard to keep application dependencies in sync.

#### Virtual Machines

VM Ware came up with the hypervisor layer, which decoupled hardware from the application and its dependencies. You could only install a single instance of the application into one VM only, because of conflicts and dependency issues. So to get around this you would create multiple VMs to run the same application. These VMs could be running on the same hardware or different hardware.

* App code
* App dependencies
* OS and kernel
* Hardware + hypervisor

This reduced deployment into days and it improved the hardware resource usage, but it had low isolation as it was tied to the OS and VM.

#### Containers

* App code (inside the container)
* App dependencies (inside the container)
* OS and kernel + container runtime
* Hardware + hypervisor OR bare metal hardware

#### Why Developers Like Containers

* Code works the same everywhere (dev -> staging -> production)
* They can run on bare metal, VMs, or the cloud.
* Speeds up development and testing by
  * Agile creation and deployment
  * Easy to use continuous integration and delivery
  * A single file to deploy
* Provides a path to microservices.
* They provide isolation from other containers, applications, systems. 

## 1.2) Introduction To Docker

Docker is a program that provides a way to build and run containers. Its usage is very widespread these days. Containers are very efficient.
 

# Week 2

