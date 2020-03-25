# Docker Concepts

My notes from the official Getting Started page.

## Getting Started Part 1

https://docs.docker.com/get-started/

* A Docker image is an executable package that includes everything needed to run an application. Such as the code, runtime libraries, environments variables, and configuration files.
* A Docker container is a runtime instance of a Docker image. These run natively on Linux and share the kernel of the host machine. This makes its more resource friendly than a virtual machine.
* A virtual machine is a full blown operating system sitting on top of a hypervisor.

## Getting Started Part 2

https://docs.docker.com/get-started/part2/

The Docker hierarchy looks like:

* Stack
* Services
* Container

Building Docker apps starts at the bottom. You can just grab a portable Docker runtime environment for your chosen programming language and start coding. You just need to include the Docker base runtime environment with your application code and dependencies. These will all travel together when being deployed. These portable Docker images are known as Dockerfiles.

* A Dockerfile defines what goes on inside the environment within a Docker container. This is where you can define environment variables, map ports, define what files exist inside the container, etcetera. This will make sure that whereever the container is deployed it will have the same configuration.
** The filename is `Dockerfile`
* The requirements file lists all the dependencies for the application.
** The filename is `requirements.txt`

When accessing the name of a host when inside a container, the container ID will be returned. Conceptually similar to a process ID.
When accessing apps within a container, use the address and ports that were mapped in the Dockerfile.
When running in detached (background) mode, you will receive the container ID as output from the startup. Use this control the container.

* A registry is a collection of repositories. `docker` uses the Public registry by default.
* A repository is a collection of images.
* Image tags are the mechanism used by repostitories to apply version numbers to images. The syntax to tag a local image to a repository is `username/repository:tag`
* No matter where `docker run` is executed, it will always pull from `requirements.txt`
