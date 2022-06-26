# k8s Security (CKS) Notes <!-- omit in toc -->

* Forth course in a series [[beginner](../02.applications-developer/README.md#1-core-concepts), [developer](../02.applications-developer/README.md#2-configuration), [administrator](../03.administrator/README.md#1-core-concepts), security]
* Can do the exam if you want, but you require CKA for this. There are plenty of mock exams for this.

- [1) Understanding The k8s Attack Surface](#1-understanding-the-k8s-attack-surface)
  - [The Attack Scenario](#the-attack-scenario)
  - [The 4 C's Of Cloud Native Security](#the-4-cs-of-cloud-native-security)
- [2) Cluster Setup & Hardening](#2-cluster-setup--hardening)
  - [CIS Benchmarks](#cis-benchmarks)
    - [CIS Benchmarks For k8s](#cis-benchmarks-for-k8s)
  - [kube-bench](#kube-bench)
  - [k8s Security Primitives](#k8s-security-primitives)
    - [Authentication](#authentication)
    - [TLS Encryption](#tls-encryption)
      - [TLS Basics](#tls-basics)
      - [TLS In k8s](#tls-in-k8s)
    - [Authorisation](#authorisation)
    - [Kubelet Security](#kubelet-security)
    - [kubectl Proxy & Port Forward](#kubectl-proxy--port-forward)
    - [k8s Dashboard](#k8s-dashboard)
      - [Securing k8s Dashboard](#securing-k8s-dashboard)
    - [k8s Software](#k8s-software)
      - [Versions](#versions)
      - [Verifying Application Binaries](#verifying-application-binaries)
      - [Cluster Upgrades](#cluster-upgrades)
    - [Network Policies](#network-policies)
    - [Ingress](#ingress)
    - [Docker](#docker)
      - [Securing The Docker Daemon](#securing-the-docker-daemon)
      - [System Service vs Daemon](#system-service-vs-daemon)
      - [Unix Socket vs TCP/IP Socket](#unix-socket-vs-tcpip-socket)
      - [TLS Encryption](#tls-encryption-1)
      - [Client Certificates](#client-certificates)
- [3) System Hardening](#3-system-hardening)
  - [Principle Of Least Privilege (PoLP)](#principle-of-least-privilege-polp)
  - [Minimising Host OS Footprint](#minimising-host-os-footprint)
  - [Limiting Node Access](#limiting-node-access)
  - [SSH](#ssh)
    - [Hardening](#hardening)
  - [Privilege Escalation In Linux](#privilege-escalation-in-linux)
  - [Removing Obsolete Packages & Services](#removing-obsolete-packages--services)
    - [Software](#software)
    - [Services](#services)
  - [Restricting Kernel Modules](#restricting-kernel-modules)
  - [Identifying & Disabling Open Ports](#identifying--disabling-open-ports)
  - [Cloud IdAM](#cloud-idam)
  - [Restricting Network Access](#restricting-network-access)
    - [UFW Firewall Basics](#ufw-firewall-basics)
  - [Linux Syscalls](#linux-syscalls)
    - [Tracing Syscalls](#tracing-syscalls)
      - [AquaSec Tracee](#aquasec-tracee)
    - [Restricting Syscalls](#restricting-syscalls)
      - [Seccomp](#seccomp)
        - [Seccomp Within k8s](#seccomp-within-k8s)
  - [Kernel Hardening With AppArmor](#kernel-hardening-with-apparmor)
    - [Overview](#overview)
    - [Creating Profiles](#creating-profiles)
    - [In k8s](#in-k8s)
  - [Linux Capabilites](#linux-capabilites)
- [4) Minimising Microservices Vulnerabilities](#4-minimising-microservices-vulnerabilities)
  - [Security Contexts](#security-contexts)
  - [Admission Contollers](#admission-contollers)
    - [Validating & Mutating](#validating--mutating)
  - [Pod Security Policies](#pod-security-policies)
  - [Open Policy Agent](#open-policy-agent)
    - [In k8s](#in-k8s-1)
  - [Secrets](#secrets)
  - [Sandboxing](#sandboxing)
    - [Virtual Machines](#virtual-machines)
    - [Containers](#containers)
      - [gVisor](#gvisor)
      - [kata Containers](#kata-containers)
      - [Container Runtime Classes](#container-runtime-classes)
        - [Using Specific Container Runtime Classes](#using-specific-container-runtime-classes)
  - [TLS Extras](#tls-extras)
    - [One Way TLS Vs Two Way TLS](#one-way-tls-vs-two-way-tls)
    - [Pod To Pod mTLS](#pod-to-pod-mtls)
- [5) Supply Chain Security](#5-supply-chain-security)
  - [Image Terminology](#image-terminology)
  - [Image Security Best Practices](#image-security-best-practices)
    - [Cohesion & Modularity](#cohesion--modularity)
    - [State Persistance](#state-persistance)
    - [Official Base Images](#official-base-images)
    - [Slim/Minimal Vs Fat Images](#slimminimal-vs-fat-images)
    - [Dev Vs Prod Images](#dev-vs-prod-images)
    - [Distroless Images](#distroless-images)
    - [Image Registries](#image-registries)
      - [Public Official Registries](#public-official-registries)
      - [Private Internal Registries](#private-internal-registries)
      - [Allowlisting Image Registries](#allowlisting-image-registries)
  - [Static Analysis & Dynamic Analysis](#static-analysis--dynamic-analysis)
    - [kubesec](#kubesec)
  - [Image Scanning](#image-scanning)
    - [Aquasec Trivy](#aquasec-trivy)
    - [Best Practices](#best-practices)
- [6) Monitoring, Logging, & Runtime Security](#6-monitoring-logging--runtime-security)
  - [Behavioural Analytics](#behavioural-analytics)
  - [Falco](#falco)
    - [Detecting Threats](#detecting-threats)
    - [Configuration](#configuration)

# 1) Understanding The k8s Attack Surface

## The Attack Scenario

There are 2 sites, 1 for voting and 1 for results. The attacker:

* Pings both websites using their domain names and finds they are on the same IP address. So they are on the same webserver.
* Does a port scan of the webserver IP address and finds the Docker service is open.
* Runs a Docker command against the server IP address and the default Docker behaviour is no authentication so the commands work. The running containers who k8s control plane components.

![images/the-attack-1.png](images/the-attack-1.png)

* Runs a privileged container on the webserver as root. Uses an exploit within the container to escape from the container and is now root on the webserver.

![images/the-attack-2.png](images/the-attack-2.png)

* From this position the attacker has full control of the webserver and can do anything.

## The 4 C's Of Cloud Native Security

https://kubernetes.io/docs/concepts/security/overview/

The 4 C's are:

1. **Cloud** or on-premesis, securing the entire platform infrastructure.
   1. Discussed in System Hardening and Monitoring, Logging, and Runtime Security
2. **Cluster**, securing the k8s cluster.
   1. Discussed in Cluster Setup & Hardening
3. **Container**, securing the container runtime engine.
   1. Discussed in Minimise Microservice Vulnerabilites and Supply Chain Security
4. **Code** for the application needs to be designed in a secure way.
   1. Kind of discussed in this course but mainly out of scope. e.g. the app should be built with TLS and not hard code secrets like database passwords.

![images/the-4-cs.png](images/the-4-cs.png)

# 2) Cluster Setup & Hardening

## CIS Benchmarks

https://www.cisecurity.org/cis-benchmarks/

A **security benchmarks** are configuration baselines and best practices for securely configuring a system. There are many tools that can provide this and a common one is CIS Benchmarks from the Center For Internet Security.

![images/security-benchmarks-1.png](images/security-benchmarks-1.png)

The CIS Benchmark suite covers cloud infrastructure, operating systems, networking, desktop and virtualisation applications, etcetera. To use it you download the CIS Benchmark for the area of concern and run it, the report will detail your current configuration against the best practice configuration and tell you what to do to secure your system.

CIS-CAT Lite can run the CIS Benchmarks and apply remediation processes automatically.

https://learn.cisecurity.org/cis-cat-lite

Go to https://www.cisecurity.org/benchmark/distribution_independent_linux for Linux distribution independent advice.

### CIS Benchmarks For k8s

https://www.cisecurity.org/cis-benchmarks/#kubernetes > Server Software > Virtualization > Kubernetes contains a configuration baseline for k8s. The CIS-CAT Pro is needed for k8s support. https://www.cisecurity.org/cybersecurity-tools/cis-cat-pro/cis-benchmarks-supported-by-cis-cat-pro/

## kube-bench

kube-bench can performan automated check on a k8s cluster to see if it is following security best practices from the k8s CIS Benchmark. It can install as a Docker container, as a Pod, or as a binary.

## k8s Security Primitives

See [CKA Security Primitives](../03.administrator/README.md#61-primitives)

### Authentication

For human accounts k8s doesn't manage user accounts natively, it relies on an external source (e.g. file, LDAP, etc) for that. Bots are covered by Service Accounts.

See [CKA Authentication](../03.administrator/README.md#61-authentication)

See [CKAD Service Accounts](../02.applications-developer/README.md#service-accounts)

The `default` Service Account that is automatically created in each namespace can be used to access the `kube-apiserver` but it is very heavily restricted in what it can do. Create your own Service Account for extra permissions.

### TLS Encryption

See [CKA TLS Encryption](../03.administrator/README.md#62-tls-encryption)

#### TLS Basics

See [CKA TLS Basics](../03.administrator/README.md#621--tls-basics)

#### TLS In k8s

See [CKA TLS In k8s](../03.administrator/README.md#622-tls-in-k8s)

See [CKA Creating Digital Certificates For k8s](../03.administrator/README.md#6221-creating-digital-certificates-for-k8s)

See [CKA Certificates API](../03.administrator/README.md#6222-certificates-api)

See [CKA Kube Config](../03.administrator/README.md#6223-kube-config)

### Authorisation

See [CKA API Groups](../03.administrator/README.md#63-api-groups)

See [CKA Authorisation](../03.administrator/README.md#64-authorisation)

### Kubelet Security

`kubeadm` doesn't automatically deploy `kubelet`, you need to do that manually. You should configure it securely before you manually deploy it. You can configure `kubelet` 2 ways:
1. Updating the flags in `kubelet` service file.
2. Updating the entries `kubelet` YAML config file. This is preferred and by default `kubeadm` installs this file at `/var/lib/kubelet/config.yaml` and this file uses camelCase.

**Note:** The flags in the service file take precedence over the entries in the YAML config file.

Use `ps aux | grep kubelet | grep config` to see where the `kubelet` YAML config file is, again by default `kubeadm` installs this file at `/var/lib/kubelet/config.yaml`.

The main things to secure within `kubelet` are:
* The 2 ports that `kubelet` serves on:
  * 10250 serves API with authenticated full access. The authentication depends on what mode is set. e.g. `curl -sk https://localhost:10250/pods/` will show you all Pods running in the cluster.
  * 10255 serves API with unauthenticated read only access. e.g. `curl -sk https://localhost:10255/metrics` will show you metrics for the cluster.
* By default the authentication mode is always allow.

You can secure `kubelet` via the service file or the YAML config file.
* The 2 ports that `kubelet` serves on can be secured by:
  * The API being served on port 10250 can be turned off by setting anonymous auth off. You can also change this API's authentication mode to use either x509 client certificates or API access tokens. Remember that the `kube-apiserver` is also a client so will require client access.
  * The API being served on port 10255 can be turned off by setting the port to 0.
* The default authorization can be updated to Webhook for example, which will delegate authorization to the `kube-apiserver`.

![images/securing-kubelet-1.png](images/securing-kubelet-1.png)

### kubectl Proxy & Port Forward

You can connect a variety of ways to the cluster.
* Using `kubectl` directly with the `$KUBECONFIG`.
![images/kubectl-connection-1.png](images/kubectl-connection-1.png)
* Using `curl` on port 6443, remember you need to specify client certificate and key.
![images/kubectl-connection-2.png](images/kubectl-connection-2.png)
* Using `kubectl proxy` with the `$KUBECONFIG` via localhost loopback address..
* Using `kubectl port-forward` with the `$KUBECONFIG`.

![images/kubectl-connection-3.png](images/kubectl-connection-3.png)

`kubectl proxy` opens proxy port to API server. It uses the `$KUBECONFIG` file to connection properties.

```bash
# Run the proxy
kubectl proxy
Starting to serve on 127.0.0.1:8001

# View all API end points
curl -k localhost:8001
```

![images/kubectl-connection-4.png](images/kubectl-connection-4.png)


`kubectl port-forward` opens a port to target deployment pods.

```bash
# Run the port forward
kubectl port-forward pod/$POD_NAME $LOCAL_PORT:$POD_PORT
kubectl port-forward svc/$SERVICE_NAME $LOCAL_PORT:$SERVICE_PORT

# View the forwarded app
curl -k localhost:$LOCAL_PORT
```

### k8s Dashboard

https://kubernetes.io/docs/tasks/access-application-cluster/web-ui-dashboard/

The k8s dashboard is a web based UI that can used to view and create cluster objects. It is a powerful tool that needs to be safeguarded. Tesla had their k8s cluster hijacked to mine cryptocurrency through this feature after they exposed it to the internet.

![images/k8s-dashboard.png](images/k8s-dashboard.png)

![images/k8s-dashboard-2.png](images/k8s-dashboard-2.png)

You can deploy the k8s dashboard through the YAML file at the k8s dashboard GitHub repository. The dashboard is now by default only accessible through a ClusterIP Service object making it available for local access only. You can get around this by using the Kube Proxy and accessing the ClusterIP service that way.

![images/k8s-dashboard-3.png](images/k8s-dashboard-3.png)

![images/k8s-dashboard-4.png](images/k8s-dashboard-4.png)

You could change the ClusterIP service to a NodePort service and gate access to that with some kind of IdAM solution.

#### Securing k8s Dashboard

When you access the k8s dashboard you get 2 authentication options:
* Token access from an existing Role or ClusterRole token that is stored in a Secret. The token within the secret must be base64 decoded first.
* KUBECONFIG access.

![images/k8s-dashboard-5.png](images/k8s-dashboard-5.png)

https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md

You can combine existing ClusterRoles with Roles or ServiceAccounts to grant access within namespaces or the cluster itself.

### k8s Software

#### Versions

See [CKA Software Versions](../03.administrator/README.md#52-software-versions)

#### Verifying Application Binaries

The k8s binaries are available at the [k8s GitHub release page](https://github.com/kubernetes/kubernetes/releases). You must confirm all downloaded binary hashes against the hashes provided there.

![images/k8s-binaries.png](images/k8s-binaries.png)

```bash
# Method 1 - automatic check
# Create checksum file
cat > ${k8s_BINARY}.sha512
${k8s_BINARY} ${DOWNLOAD_PAGE_k8s_BINARY_SHA512_HASH}
^D

# Check the file against the checksum
sha512sum -c ${k8s_BINARY}.sha512

# Method 2 - manual check
sha512sum ${k8s_BINARY}

# Cross check hash against the hash on the page.
```

#### Cluster Upgrades

See [CKA Cluster Upgrades](../03.administrator/README.md#53-cluster-upgrades)

Use `kubeadm upgrade plan` to see what is the latest version you can upgrade to.

### Network Policies

See [CKA Network Policies](../03.administrator/README.md#65-network-policies)

### Ingress

See [CKA Ingress](../03.administrator/README.md#846-ingress)

In >= 1.20 you can create Ingress Resources via the command line.

```bash
# Format
kubectl create ing $NAME --rule="$DOMAIN_HOST/$URI_PATH=$SERVICE_NAME:$SERVICE_PORT"

# Example
kubectl create ing my-ingress --rule="wear.example.com/wear*=wear-service:8080"
```

### Docker

#### Securing The Docker Daemon

The Docker Daemon needs to be secured because anyone with access to it can:
* Delete any Docker object, e.g. containers or volumes.
* Create any Docker objects, e.g. container with a cryptominer.
* Run a privileged container and gain root access to the CRE host.

The host running the Docker Daemon needs securing as well. See (System Hardening)[#3-system-hardening]


#### System Service vs Daemon

The Docker daemon can be installed as a system service. You could also just run Docker daemon commands as well.

```bash
# Systemctl commands
systemctl start docker
systemctl status docker
systemctl restart docker
systemctl stop docker

# Docker Daemon commands
dockerd
dockerd --debug
```

#### Unix Socket vs TCP/IP Socket

The Docker Daemon listens on a Unix socket at `/var/run/docker.sock`. A [Unix socket](https://serverfault.com/a/124518) is an inter-process communication mechanism that allows bidirectional data exchange between processes running on the same machine. This means the Docker Daemon is only accessible on the same host.

![images/docker-daemon-1.png](images/docker-daemon-1.png)

[IP sockets](https://serverfault.com/a/124518), especially TCP/IP sockets, are a mechanism allowing communication between processes over the network. In some cases you can use TCP/IP sockets to talk with processes running on the same computer by using the loopback interface.

If you bound the Docker Daemon to an IP socket via the host's network interface it would be accessible on the network via anyone who can access that network interface. Do not do this over a public facing interface otherwise the public can access it.

```bash
# Start Docker Daemon listening on a TCP/IP socket
# 2375 is the standard Docker port using no encryption.
dockerd --host=tcp://$LOCAL_IP:2375
```

The other host needs to use `DOCKER_HOST=tcp://$LOCAL_IP:2375` so its docker commands are sent to the external Docker Daemon. Or use the equivalent `docker` command options.

![images/docker-daemon-2.png](images/docker-daemon-2.png)

Exposing the Docker Daemon on a TCP/IP socket is a security risk as by default Docker has no authentication mechanism and no encryption.

#### TLS Encryption

You can see up TLS with:

```bash
# 2376 is the standard Docker port using encryption.
dockerd --host=tcp://$LOCAL_IP:2376
# enable encryption
--tls=true \
--tlscert=/var/docker/server.crt \
--tlskey=/var/docker/server.key
```

The other host needs to use `DOCKER_HOST=tcp://$LOCAL_IP:2376` and `DOCKER_TLS=true` so its docker commands are sent to the external Docker Daemon using encryption. Or use the equivalent `docker` command options.

![images/docker-daemon-3.png](images/docker-daemon-3.png)

You can place Docker Daemon command line options into a JSON configuration file at `/etc/docker/daemon.json`. If you try to use the command line options and the config file at the same time there will be an error.

![images/docker-daemon-4.png](images/docker-daemon-4.png)

This configuration file is also read when you start the Docker Daemon as a system service.

#### Client Certificates

You can set up TLS client authentication with:

```bash
# 2376 is the standard Docker port using encryption.
dockerd --host=tcp://$LOCAL_IP:2376 \
# enable encryption
--tls=true \
--tlscert=/var/docker/server.crt \
--tlskey=/var/docker/server.key \
# enable client certificates
--tlsverify=true
--tlscacert=/var/docker/ca.cert
```

![images/docker-daemon-5.png](images/docker-daemon-5.png)

The client certificate can be supplied via the `docker` command option or placed into `~/.docker`. These client certificates must be signed by the Docker CA certificate.

# 3) System Hardening

Go to https://www.cisecurity.org/benchmark/distribution_independent_linux for Linux distribution independent advice.

## Principle Of Least Privilege (PoLP)

**Principle Of Least Privilege (PoLP)** addresses access control and states that an individual should have only the minimum access privileges necessary to perform a specific job or task and nothing more.

## Minimising Host OS Footprint

We can reduce the attack surface by having a strong security posture and implementing best practices for securing networks, hosts, applications, and user accounts.

![images/minimise-host-footprint.png](images/minimise-host-footprint.png)

## Limiting Node Access

The k8s Nodes should be deployed on a private network IP range and shouldn't be accessible from the internet directly, except via authorised channels like a VPN or from an allow listed CIDR range.

![images/limit-node-access.png](images/limit-node-access.png)

![images/limit-node-access-2.png](images/limit-node-access-2.png)

SSH access within the private network must be restricted as well. Only cluster administrators will require SSH access.

There are 4 types of Linux user accounts:
1. **User accounts**, these are for people who can log into the system and may or may not have administrator access.
2. **Superuser account**, the system account that can do anything on the system. Also known as root. User accounts can be granted access to this account.
3. **System accounts**, typically created during the O/S installation for software that will not run as the superuser.
4. Service accounts, are similar to the system accounts. They are created when when the service is installed and doesn't require to run as the superuser.

![images/linux-users.png](images/linux-users.png)

There are a variety of commands you can use to view information about Linux users.

```bash
# View information about the current user
id

# View the list of currently logged in users
who

# View the users who recently logged into the system
last
```

![images/linux-users-2.png](images/linux-users-2.png)

There are 3 popular files relating to Linux user accounts:

1. `/etc/passwd` contains information about the user, such as:
   1. Account name
   2. User ID (uid)
   3. Group name
   4. Group ID (gid)
   5. Login shell
   6. Home directory
2. `/etc/shadow` contains the hashed passwords of users.
3. `/etc/group` contains information about groups such as:
   1. Group name
   2. Group ID (gid)
   3. Group members (i.e. the users in that group.)

![images/linux-users-3.png](images/linux-users-3.png)

You can easily disable and delete users within Linux.
* Disable users by setting their shell to `/bin/nologin` inside of `/etc/passwd`.
* Delete users by using the `deluser $USERNAME` command.

![images/linux-users-4.png](images/linux-users-4.png)

You can easily remove users from groups that they shouldn't be in with the following commands:
* `gpasswd -d $USERNAME $GROUPNAME` works on Red Hat and Debian based systems.
* `deluser -d $USERNAME $GROUPNAME` works on Debian based systems.
* `usermod -g $GROUPS_TO_STAY_IN $USERNAME` works on Red Hat and Debian based systems. Remeber that you are omitting any groups you want to remove the user from.

![images/linux-users-5.png](images/linux-users-4.png)

## SSH

SSH is used to securely connect to an external server with a username and password or via ssh key pairs. Here are some important things to remember about ssh:

* The default connection strategy is username and password.
* The default port for ssh 22.
* The default directory for ssh files is `~/.ssh` for the client and server.
* On the client:
  * ssh keys are stored in `~/.ssh/id_$ALGORITHM`
  * The global ssh configuration is stored in `/etc/ssh/ssh_config` which can be overriden with `~/.ssh/config`
  * Metadata about ssh servers that have been connected to from this client is stored in `~/.ssh/known_hosts`
* On the server:
  * ssh keys copied from previously connected clients are are stored in `~/.ssh/authorized_keys`.
  * The global ssh daemon configuration is stored in `/etc/ssh/sshd_config`

```bash
# Connect as the current user
ssh $HOSTNAME
ssh $IP_ADDRESS

# Connect as a different user
ssh $USERNAME@$HOSTNAME
ssh $USERNAME@$IP_ADDRESS
```

![images/ssh.png](images/ssh.png)

It is not considered best practice to use username and passwords for ssh connections, you should use ssh keys instead. Remember that you need to use username and password to supply the key to the remote host.

```bash
# Create an ssh key, the default path is ~/.ssh/
ssh-keygen
ssh-keygen -t $ALGORITHM
ssh-keygen -t $ALGORITHM -i $KEY_PATH
```

![images/ssh-2.png](images/ssh-2.png)

```bash
# Copy ssh key to a server
ssh-copy-id -i $KEY_PATH $USERNAME@$HOSTNAME
ssh-copy-id -i $KEY_PATH $USERNAME@$IP_ADDRESS
```

![images/ssh-3.png](images/ssh-3.png)

### Hardening

CIS section 5.2 has elaborate steps to harden the ssh service. But the following basic steps should be used to harden ssh via the `/etc/ssh/sshd_config` file:
* Disable root logins over ssh.
* Disable password logins over ssh.

![images/ssh-4.png](images/ssh-4.png)

**Note:** Remember to restart the sshd service after making changes to the configuration.

## Privilege Escalation In Linux

Using root as the daily driver account is a bad idea. But you will need to use the root user to perform some tasks within the system. The best way to do this is via `su` or `sudo`.
* The `su` command will ask for the root account password before switching to the root user.
* The `sudo` command will ask for the current user's account password before switching to the root user. That user must be granted `sudo` access within `/etc/sudoers` file or `/etc/sudoers.d/` included files.

**Note:** You should update `/etc/sudoers` with `visudo` as this command will validate the file and make sure you don't make any breaking changes which may lock you out of the root account.

![images/sudo.png](images/sudo.png)

Once you have granted `sudo` access you could then disable the root user account by updating the root account shell to `/usr/sbin/nologin` inside of `/etc/passwd`.

[The syntax](https://askubuntu.com/a/118227) for `/etc/sudoers` is:
* Comments are lines that start with a `#`
* The first field is the user or group that privileges are being granted to. Groups must begin with a percent sign, e.g. `%sudo`
* The second field is which host the user can use `sudo` on. By default this is ALL and on a typical setup this just means localhost. If you were sharing this file across mutiple hosts you can supply hostnames here.
* The third field enclosed in brackets is the users `-u` and which groups `-g` can be used to run commands. By default this is ALL which means any user or group.
* The forth field is the command(s) that can be run. By default this is ALL which means any command.

![images/sudo-2.png](images/sudo-2.png)

You can make `sudo` switching passwordless with `$USER ALL=(ALL:ALL) NOPASSWD:ALL` inside of `/etc/sudoers`

## Removing Obsolete Packages & Services

### Software

Best practice dictates to ensure only the required software is installed on the system and to ensure that software is kept up to date.

```bash
# Ubuntu - install a package
apt install $PACKAGE_NAME

# Ubuntu - remove a package
apt remove $PACKAGE_NAME

# Ubuntu - refresh package cache data
apt update

# Ubuntu -- upgrade all packages
apt upgrade

# Ubuntu - refresh package cache data and upgrade all packages
apt update -y && apt upgrade
```

![images/apt.png](images/apt.png)

```bash
# Red Hat - install a package
dnf install $PACKAGE_NAME

# Red Hat - remove a package
dnf remove $PACKAGE_NAME

# Red Hat - refresh package cache data and upgrade all packages
dnf upgrade --refresh
```

### Services

You should also only enable O/S services that are needed. Remember that service files are installed when the package is installed, these may or may not be automatically enabled and started.

O/S service files are located in `/lib/systemd/system/$SERVICE_NAME`

```bash
# View all active services on the system
systemctl list-units --type service

# Check the service's status
systemctl status $SERVICE_NAME

# Start a service
systemctl start $SERVICE_NAME
systemctl restart $SERVICE_NAME

# Automatically start a service at boot time
systemctl enable  $SERVICE_NAME

# Stop a service
systemctl stop $SERVICE_NAME

# Disable a service from automatically starting at boot time
systemctl disable $SERVICE_NAME
```

![images/services.png](images/services.png)

![images/services-2.png](images/services-2.png)

CIS section 2 has elaborate steps to harden the O/S services.

## Restricting Kernel Modules

**Kernel modules** are pieces of code that can be loaded and unloaded into the kernel upon demand. They extend the functionality of the kernel without needing to reboot the system. A common example of this is a GPU hardware device driver being loaded as a kernel module after a GPU has been installed.

![images/kernel-modules.png](images/kernel-modules.png)

You can manually load a kernel module into the kernel using `modprobe $MODULE_NAME`. You can list all running kernel modules using `lsmod`.

![images/kernel-modules-2.png](images/kernel-modules-2.png)

It is security best practise to disable and disallow unnecessary kernel modules. You can disallow kernel modules by adding them to a deny list which is typically stored at `/etc/modprobe.d/blacklist.conf`. This file can be called anything but must have the `.conf` extension. A reboot is required to add a kernel module to the deny list.

![images/kernel-modules-3.png](images/kernel-modules-3.png)

In k8s to common kernel modules to disable are sctp and dccp. CIS section 3.4 has elaborate steps to harden kernel modules.

## Identifying & Disabling Open Ports

When applications and services they can bind to a port on the host's network interface. Once bound, the host's IP address and this port can allow traffic into the host.

![images/ports.png](images/ports.png)

You can view all the ports currently be used by the system in a variety of ways, 2 common approaches are `netstat` and `ss`.

```bash
# View all TCP and UPD ports on the system, regardless of their state
ss -antup
netstat -antup

# View listening TCP only
ss -lntp
netstat -lntp

# View listening UDP only
ss -ltup
netstat -ltup
```

You can check what a port is doing by looking it up in SystemD services, e.g. `cat /etc/services | fgrep -w $PORT`.

![images/ports-2.png](images/ports-2.png)

The k8s documentation [Ports & Protocols page](https://kubernetes.io/docs/reference/ports-and-protocols/) has a list of what ports are required by a k8s cluster.

![images/ports-3.png](images/ports-3.png)

**Note:** These ports will differ depending on how you install the cluster, e.g. kubeadm vs Rancher, etc.

## Cloud IdAM

**Note:** This is NOT on the exam, for education only.

Security concepts like least privilege for accounts apply to cloud environments as well. The root account in Linux equates to the Windows admin user and AWS Root account.

![images/cloud.png](images/cloud.png)

When you sign up to AWS you get an AWS Root account for that subscription. With that account you have full access to any AWS object. This account shouldn't be used for the daily driver so you must use it to create additional user accounts.

![images/cloud-2.png](images/cloud-2.png)

AWS IAM Polcies are used to grant authorised access to AWS users and groups to AWS resources (e.g. user can access an s3 bucket.). There are many types of [AWS policies](https://docs.aws.amazon.com/IAM/latest/UserGuide/access_policies.html). AWS IAM supports ABAC and RBAC, RBAC is preferred.

ABAC

![images/cloud-3.png](images/cloud-3.png)

RBAC

![images/cloud-4.png](images/cloud-4.png)

IAM Roles allow AWS services to interact with other AWS services.

![images/cloud-5.png](images/cloud-5.png)

Cloud providers typically provide automated tools for reviewing security configurations within their environments. AWS has the AWS Trusted Advisor, GCP has Security Command Center, and Azure has the Azure Advisor.

![images/cloud-6.png](images/cloud-6.png)

## Restricting Network Access

A common approach to restricting network access is having active firewalls on networks devices like routers and proxies, and also having firewalls and disabling services on clients as well.

A **firewall** is a way to protect machines from any unwanted traffic from outside through firewall rules. These rules are used to sort the incoming traffic and either block it or allow through.

![images/network.png](images/network.png)

![images/network-2.png](images/network-2.png)

What is `0.0.0.0`? It depends on the context.
* In the context of routing it means the default route.
* In the context of servers it means all IPv4 addresses on the local machine.
* In all other contexts it means no particular address.

image.png
### UFW Firewall Basics

**Uncomplicated firewall (UFW)** is a frontend for managing firewall rules in Arch Linux, Debian, or Ubuntu. UFW is used through the command line and aims to make firewall configuration easy. Under the hood it is creating iptables or nftables rules. [Linode](https://www.linode.com/docs/guides/configure-firewall-with-ufw/) has a good guide on this.

```bash
# Install and start ufw
apt update
apt install ufw
systemctl enable ufw
systemctl start ufw

# Check firewall rule status.
ufw status

# Allow all outbound connections
ufw default allow outgoing

# Block all inbound connections
ufw default deny incoming
```

![images/network-3.png](images/network-3.png)

**Note:** `ufw` is inactive by default when installed.

```bash
# Allow ssh
ufw allow ssh
ufw allow 22

# Allow HTTP traffic via TCP
ufw allow http/tcp
ufw allow 80/tcp

# Allow ssh from a specific IP
ufw allow from $IP_ADDRESS to any port 22 proto tcp

# Allow specific range
ufw allow ${START}:${END}/$PROTOCOL

# Block a specific port that is already listening
ufw deny $PORT
```

![images/network-4.png](images/network-4.png)

```bash
# Enable the firewall and its current rules
ufw enable

# Delete a rule
ufw delete $RULE

ufw status numbered
ufw delete $RULE_NUMBER_FROM_STATUS
```

![images/network-5.png](images/network-5.png)

![images/network-6.png](images/network-6.png)

```bash
# Reset to defaults
ufw reset
```

## Linux Syscalls

The **kernel** is a computer program at the core of a computer's O/S and generally has complete control over everything in the system. It is O/S code that is always resident in memory, and facilitates interactions between hardware and software components.

The simplified answer is that computer memory gets divided into 2 separate memory locations, kernel space and user space. Kernel space is where kernel code is stored and executed. User space is where everything else is stored and is executed.

https://unix.stackexchange.com/questions/87625/what-is-difference-between-user-space-and-kernel-space

![images/syscalls.png](images/syscalls.png)

A **system call (syscall)** is a function that allows a process from user space to communicate with the Linux kernel. There are over 400 syscalls, for example `execve` is used to execute a binary.

![images/syscalls-2.png](images/syscalls-2.png)

You can trace the syscalls being made by a process using `strace`.

```bash
# Trace the syscalls of a command about to be executed
strace $COMMAND
```

The output below means:
* Call `execve` to execut the program with the following parameters:
  * Execution path.
  * Command & arguments
  * The amount of environment variables the command inherited. This number will match `env | wc -l`

![images/syscalls-3.png](images/syscalls-3.png)

```bash
# Get PID of running command
pidof $RUNNING_CMD

# Trace the syscalls of a command already running
strace -p $RUNNING_CMD
```

![images/syscalls-4.png](images/syscalls-4.png)

Use `strace -c` to view a summary of the entire syscall output.

![images/syscalls-5.png](images/syscalls-5.png)

### Tracing Syscalls

#### AquaSec Tracee

Is an open source tool that uses EBPF and can be used to trace syscalls from a container at runtime. It is easy to run this as a Docker container but it requires a couple of Docker Volume mounts and to run in privileged mode.

![images/tracee.png](images/tracee.png)

Can be used to trace syscalls from a single command.

![images/tracee-2.png](images/tracee-2.png)

Can be used to trace syscalls from all new processes in a running container.

![images/tracee-3.png](images/tracee-3.png)

Can be used to trace syscalls from all processes in a new container.

![images/tracee-4.png](images/tracee-4.png)

### Restricting Syscalls

#### Seccomp

There are over 400 syscalls in Linux and it is doubtful that an application needs acecss to all of them. By default the Linux kernel will allow any syscalls to be made by any programs running in user space. You can restrict what syscalls an app has access to with a tool like Seccomp.

**Seccomp** stands for secure computing mode and has been a feature of the Linux kernel since version 2.6.12 in 2005. It can be used to sandbox the privileges of a process, restricting the calls it is able to make from userspace into the kernel.

![images/syscalls-6.png](images/syscalls-6.png)

```bash
# Check to see if seccomp is running
grep -i seccomp /boot/config-$(uname -r)
```

![images/seccomp.png](images/seccomp.png)

```bash
# Check the seccomp filtering level of a running processing
ps aux | grep $PROCESS
grep -i seccomp /proc/$PID/status
```

![images/seccomp-2.png](images/seccomp-2.png)


Seccomp has 3 modes:

0. Disabled.
1. Strict mode, only allows `[read, write, exit, rt_sigreturn]`
2. Filtered, used to create allow list and deny lists.

![images/seccomp-3.png](images/seccomp-3.png)

Docker uses this Seccomp mode 2 and applies syscall filters via a JSON file. The default Docker Seccomp deny list JSON file blocks about 60 syscalls on all containers when the CRE host has Seccomp enabled.

![images/seccomp-5.png](images/seccomp-5.png)

The Docker Seccomp JSON file has 3 elements:
1. Architectures array filled with all the CPU architectures it applies to.
2. Syacalls array filled with all the syscalls it is blocking or allowing.
3. Default action determins what to do with syscalls not defined inside the syscalls array.

![images/seccomp-4.png](images/seccomp-4.png)

**Note:** `SCMP_ACT_ERRNO` will reject all other syscalls and `SCMP_ACT_ALLOW` will allow all other syscalls.

You can create additional Seccomp filters to augment the default Docker deny list.

![images/seccomp-6.png](images/seccomp-6.png)

##### Seccomp Within k8s

You can use `amicontained` to view the Seccomp status and the blocked syscalls inside of a container. k8s doesn't use Seccomp by default. You can add this under `/spec/securityContext/seccompProfile/type`, valid settings are:
* Unconfined, Seccomp turned off.
* RuntimeDefault, the CRE default. e.g. Docker blocks about 60 syscalls by default.
* Localhost, use a custom Seccomp JSON file. This path is relative to the default Seccomp path which is `/var/lib/kubelet/seccomp` by default.

![images/seccomp-7.png](images/seccomp-7.png)

You should also add `/spec/containers/[i]/securityContext/allowPrivilegeEscalation` as False to stop a container from being able to escalate privileges.

![images/seccomp-8.png](images/seccomp-8.png)

![images/seccomp-9.png](images/seccomp-9.png)

To use a custom local Seccomp JSON file, create the folder `/var/lib/kubelet/seccomp/profiles` and create your custom JSON file in there. Call that from  `/spec/securityContext/seccompProfile/localhostProfile`.

![images/seccomp-10.png](images/seccomp-10.png)

The logs for the custom Seccomp JSON file are located in `/var/logs/syslog`.

![images/seccomp-11.png](images/seccomp-11.png)

![images/seccomp-12.png](images/seccomp-12.png)

Remember you can use Tracee for this as well.

**EXAM TIP:** You shouldn't have to create a custom Seccomp profile from scratch, but you will need to be able to copy an existing one to all nodes on the cluster and use it to create Pods.

## Kernel Hardening With AppArmor

https://wiki.ubuntu.com/AppArmor

### Overview

Seccomp profiles can only limit access to syscalls, which cannot block access to some resources. e.g. accessing a file or directory. The AppArmor kernel module can be used to gate resource and Linux capabilities access. It is conceptually similar to SELinux. AppArmor is configured with simple text files.

```bash
# Check if apparmor is running
systemctl status apparmor
```

In k8s the AppArmor kernel modules needs to be loaded into the kernel of all the Nodes.

```bash
# Check if the AppArmor kernel module is running, returns Y for yes or N or No.
cat /sys/module/apparmor/parameters/enabled

# Check if the AppArmor profile has been loaded into the kernel. Prints out all the loaded profiles.
cat /sys/kernel/security/apparmor/profiles

# Or use an AppArmor tool
aa-status
```

AppArmor profiles can be loaded in 3 different modes:
1. **Enforce:** AppArmor enforces its loaded profiles.
2. **Complain:** AppArmor allows the application to function but logs any events that breach its loaded profiles.
3. **Unconfined:** AppArmor does nothing.

![images/apparmor.png](images/apparmor.png)

The below profile denies write access to the entire file system `/`.
* `file` is shorthand for allowing complete access to entire file system.
* `deny /** w` denies write access to the entire file system.
So the below profile allows read only access to the entire filesystem.

![images/apparmor-2.png](images/apparmor-2.png)

The below profile denies write access to the file system within `/proc`.

![images/apparmor-3.png](images/apparmor-3.png)

The below profile denies mounting entire file system `/` as read only.

![images/apparmor-4.png](images/apparmor-4.png)

### Creating Profiles

https://documentation.suse.com/sles/15-SP1/html/SLES-all/cha-apparmor-commandline.html#sec-apparmor-commandline-profiling-summary-genprof

AppArmor comes with tools that help you build profiles.

```bash
# Install the AA tools package
apt install apparmor-tools

# Use AA tools to create a profile
aa-genprof $SCRIPT

# Run the $SCRIPT in another terminal and answer the questions
```

![images/apparmor-5.png](images/apparmor-5.png)

![images/apparmor-6.png](images/apparmor-6.png)

The `aa-genprof` command will ask security related questions about the script you are running so it can create the profile. The most common options are (I)nherit which is for allowing processes and child processes, (A)llow filesystem access, and (D)eny filesystem access.

https://documentation.suse.com/sles/15-SP1/html/SLES-all/cha-apparmor-commandline.html#ex-apparmor-commandline-profiling-summary-genprof-learn

https://documentation.suse.com/sles/15-SP1/html/SLES-all/cha-apparmor-commandline.html#ex-apparmor-commandline-profiling-summary-genprof-perms

![images/apparmor-7.png](images/apparmor-7.png)

AppArmor profiles are stored at `/etc/apparmor.d/` and you can run them by `apparmor_parser /etc/apparmor.d/$PROFILE`.

You can disable a program with:
```bash
apparmor_parser -R /etc/apparmor.d/$PROFILE
ln -s /etc/apparmor.d/$PROFILE /etc/apparmor.d/disable/
```

### In k8s

Using AppArmor in k8s it is still in beta. The runtime requirements are:
* AppArmor kernel module is loaded in all the Nodes.
* AppArmor profile is loaded in the kernel on all the Nodes.
* Requires a CRE that supports AppArmor.
* Apply the AppArmor profile against the container you want to use it on. This needs to be done as an annotation.

![images/apparmor-8.png](images/apparmor-8.png)

![images/apparmor-9.png](images/apparmor-9.png)

**Note:** The sytax for the AppArmor profile is `localhost/$PROFILE_NAME` with the profile coming from `/etc/apparmor.d/`.

## Linux Capabilites

There are 2 types of processes, unprivilged processes (uid != 0) and privileged processes (uid = 0). In Linux kernel versions < 2.2 privileged processes could do anything and unprivileged proccesses had a lot of kernel restrictions. In Linux kernel versions >= 2.2 Linux capabilities were added and privileged processes could have restricted privileged access.

![images/linux-capabilities.png](images/linux-capabilities.png)

You can use `getcap $PATH` to view the Linux capabilities used by an application. You can use `getpcap $PID` to view the Linux capabilities used by a process.

![images/linux-capabilities-2.png](images/linux-capabilities-2.png)

See [CKAD Security Contexts](../02.applications-developer/README.md#security-contexts) for adding and removing Linux Capabilities to Pods and containers.

# 4) Minimising Microservices Vulnerabilities

## Security Contexts

See [CKAD Security Contexts](../02.applications-developer/README.md#security-contexts)

## Admission Contollers

Every request through `kubectl` goes through the following stages:
1. Authenticate the user sending the request. Typically done with certificates.
2. Validate the request being made.
3. Retrieve or update the data from ETCD
4. Send a response

![images/admission-controller.png](images/admission-controller.png)

![images/admission-controller-2.png](images/admission-controller-2.png)

RBAC is good but limited. Admission Controllers provide extended functionality to RBAC.

**An admission controller** is a piece of code that intercepts requests to the Kubernetes API server prior to persistence of the object, but after the request is authenticated and authorized. Admission controllers may be "validating", "mutating", or both. Mutating controllers may modify related objects to the requests they admit, validating controllers only verify.

![images/admission-controller-3.png](images/admission-controller-3.png)

![images/admission-controller-4.png](images/admission-controller-4.png)

You can see the list of currently running admission controllers by using:

```bash
# Systemctl
kube-apiserver -h | grep admission-plugins

# Kubeabm
kubectl -n kube-system exec kube-apiserver-controlplane -- kube-apiserver -h | grep admission-plugins
```

![images/admission-controller-5.png](images/admission-controller-5.png)

You can add and remove admission controllers via the `kube-apiserver` options when it starts.

![images/admission-controller-6.png](images/admission-controller-6.png)

### Validating & Mutating

**Validating** admission controllers will only verify the submitted request is able to be executed. For example, the `NamespaceLifecycle` admission controller will make sure that requests to a non-existent namespace are rejected and that the default namespaces such as `default`, `kube-system` and `kube-public` cannot be deleted.

**Mutating** admission controllers will modify the submitted request before it is executed. For example, the DefaultStorageClass admission controller will automatically add the `/spec/storageClassName` field to all requests where it is missing.

There are admission controllers that can be do both. Typically mutating admission controllers run first before validating admission controllers, this gives the mutating admission controller a chance to modify the request to pass the validation.

![images/admission-controller-7.png](images/admission-controller-7.png)

You can write your own admission controllers and use the `MutatingAdmissionWebhook` and the `ValidatingAdmissionWebhook` to call them from the server you are hosting them on. That server must respond with the expected JSON response. The server could be hosted as a Pod in the Cluster.

![images/admission-controller-8.png](images/admission-controller-8.png)

![images/admission-controller-9.png](images/admission-controller-9.png)

**EXAM TIP:** You won't have to write your own webhook in the exam.

## Pod Security Policies

**NOTE:** PodSecurityPolicy is deprecated as of Kubernetes v1.21, and will be removed in v1.25!

A **Pod Security Policy** is a cluster-level resource that controls security sensitive aspects of the pod specification. They define a set of conditions that a pod must run with in order to be accepted into the system, as well as defaults for the related fields. They are an example of a validating and mutating Admission Controller. It can be enabled like any other Admission Controller through the `kube-apiserver` startup options.

![images/pod-security-policy-1.png](images/pod-security-policy-1.png)

Once enabled, create a PSP object.

![images/pod-security-policy-2.png](images/pod-security-policy-2.png)

Unfortunately by default the Admission Controller will not have access to PSP objects API, you need to update RBAC for that.

![images/pod-security-policy-3.png](images/pod-security-policy-3.png)

To fix this, create a Role and RoleBinding using the default Service Account from the PSP object's namespace.

![images/pod-security-policy-4.png](images/pod-security-policy-4.png)

![images/pod-security-policy-5.png](images/pod-security-policy-5.png)

Again, PSP are an example of a validating and mutating Admission Controller.

![images/pod-security-policy-6.png](images/pod-security-policy-6.png)

```bash
kubectl $CMD podsecuritypolicy
kubectl $CMD psp
```

## Open Policy Agent

[Open Policy Agent (OPA)](https://www.openpolicyagent.org/) is an authorisation policy application. It provides a high-level declarative policy language for policy as code and an API that can be called by your software for authorisation decisions.

![images/open-policy-agent-1.png](images/open-policy-agent-1.png)

```bash
# Run OPA binary in server mode on port 8181, by default has no authentication or authorisation
./opa run -s

# Load a policy into OPA
curl -X PUT --data-binary @my-policy.rego https://localhost:8181/v1/policies/my-policy

# View existing OPA policies
cutl http://localhost:8181/v1/policies
```

![images/open-policy-agent-3.png](images/open-policy-agent-3.png)

You can test and validate your policies in the [Rego Playground](https://play.openpolicyagent.org/) and OPA also provides a way to validate them through the command line via `opa test -v`

![images/open-policy-agent-4.png](images/open-policy-agent-4.png)

![images/open-policy-agent-5.png](images/open-policy-agent-5.png)

**EXAM TIP:** You won't have to write your OPA policy but you should be able to load one.

### In k8s

You can deploy OPA as an Admission Controller in k8s through. It was originally deployed like this:

![images/open-policy-agent-6.png](images/open-policy-agent-6.png)

![images/open-policy-agent-7.png](images/open-policy-agent-7.png)

The `kube-mgmt` sidecar container is used to cache k8s objects and also load policies into OPA via a ConfigMap.

```bash
# Create an OPA CM from the command line
kubectl create cm $NAME --from-file=$REGO_FILE
```

But now it can be easily deployed with [OPA Gatekeeper.](https://www.openpolicyagent.org/docs/latest/kubernetes-introduction/#what-is-opa-gatekeeper)

![images/open-policy-agent-2.png](images/open-policy-agent-2.png)

**EXAM TIP:** OPA Gatekeeper is not in the exam.

## Secrets

See [CKA Secrets](../03.administrator/README.md#44-secrets)

## Sandboxing

**Sandboxing** is a software management strategy that isolates applications from critical system resources and other programs. Sandboxing helps reduce the impact any individual program or app will have on your system.

### Virtual Machines

Virtual machines provide basic sandboxing from other VMs on the same hypervisor because each VM has its own O/S and its own O/S kernel. But they does not provide a sandbox within themselves.

![images/sandboxing.png](images/sandboxing.png)

The VMs running in a multi-tenanted cloud environments are providing basic sandboxing because they have their own O/S and own O/S kernel. A mutli-tenanted environment means there are multiple VMs running on the same hardware which are hosting different customers.

![images/sandboxing-2.png](images/sandboxing-2.png)

### Containers

Containers do not provide sandboxing because even though they have their own O/S they are actually sharing the kernel with the CRE host and are merely a process running on the CRE host within their Linux namespace.

![images/sandboxing-3.png](images/sandboxing-3.png)

![images/sandboxing-4.png](images/sandboxing-4.png)


The problem is that every container on the CRE host is making syscalls from userspace to the same O/S kernel and there have been exploits developed to break out of the container and into the CRE host. An example of this is the Dirty COW exploit.

![images/sandboxing-5.png](images/sandboxing-5.png)

Containers must be sandboxed with third party tools. Sandboxing can be achieved by restricting the syscalls they can make through tools like Seccomp, gVisor, kata Containers, etc. Other O/S hardening techniques like SELinux or AppArmor can be used as well to create a sandbox for the container.

#### gVisor

https://github.com/google/gvisor

**gVisor** is an application kernel for containers. It limits the host kernel surface accessible to the application while still giving the application access to all the features it expects.

![images/sandboxing-6.png](images/sandboxing-6.png)

The gVisor Sentry component intercepts syscalls from the container and decides whether those syscalls are allowed or not. It provides gated access mechanisms to the Linux kernel, either directly or indirectly. .e.g file system access is handled by Gopher. This of course adds additional overhead which may slow the application down.

![images/sandboxing-7.png](images/sandboxing-7.png)

Importantly each container gets its own instance of gVisor, this provides additional isolation between containers.

![images/sandboxing-8.png](images/sandboxing-8.png)

#### kata Containers

https://katacontainers.io/

**Kata Containers** provide a secure container runtime with lightweight virtual machines that feel and perform like containers, but provide stronger workload isolation using hardware virtualization technology as a second layer of defense. This of course adds additional overhead which may slow the application down but also consumes more compute resources due to the additional VM.

![images/sandboxing-9.png](images/sandboxing-9.png)

Kata Containers typically cannot run on cloud service provides, because you would be trying to run a Kata Container VM inside of the cloud provider VM. VM nesting is typically not supported by cloud service providers.

#### Container Runtime Classes

https://opensource.com/article/21/9/container-runtimes

**Lower-level Container runtimes** (e.g. runC) focus more on running containers, setting up namespace and cgroups for containers. **Higher-level container runtimes** or container runtime engines (e.g. Docker) focus on formats, unpacking, management, and image-sharing. They also provide APIs for developers.

https://github.com/opencontainers/runc

**runC** is a low-level container runtime CLI tool for spawning and running containers on Linux according to the OCI specification. It is used by Docker, CRIO, and containerd to run containers. Other container runtime classes are available, e.g. Kata Containers use kata-runtime and gVisor uses Runsc.

![images/sandboxing-10.png](images/sandboxing-10.png)

##### Using Specific Container Runtime Classes

CREs allow you to choose which container runtime class to use.

![images/sandboxing-11.png](images/sandboxing-11.png)

This means that you can do this within k8s as well using the [RuntimeClass object](https://kubernetes.io/docs/concepts/containers/runtime-class/).

Use `kubectl $CMD runtimeclasses` to interact with them.

Create RuntimeClass with:

```yaml
# RuntimeClass is defined in the node.k8s.io API group
apiVersion: node.k8s.io/v1
kind: RuntimeClass
metadata:
  # The name the RuntimeClass will be referenced by.
  # RuntimeClass is a non-namespaced resource.
  name: myclass
# The name of the corresponding CRI configuration
handler: myconfiguration
```

Use Runtimeclass with:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  runtimeClassName: myclass
  # ...
```

![images/sandboxing-12.png](images/sandboxing-12.png)

This would mean you can't see the container process on the CRE host.

![images/sandboxing-13.png](images/sandboxing-13.png)

**EXAM TIP:** Know how to create and use a RuntimeClass. The exam cluster may use any of the runtime classes above.

## TLS Extras

### One Way TLS Vs Two Way TLS

In **one way TLS**, only the client validates the server through its X.509 certificate to ensure that it receives data from the intended server. The server certificate is shared with the client. The server knows who the client is by the supplied username or account ID.

![images/tls-extras.png](images/tls-extras.png)

This is typically done between a person and a business or service.

![images/tls-extras-2.png](images/tls-extras-2.png)

In **two way TLS i.e. mutual TLS (mTLS)**, both the client and server authenticate each other through their X.509 certificates to ensure that both parties involved in the communication are trusted. The server certificate is shared with the client and the client certificate is shared with the server.

![images/tls-extras-3.png](images/tls-extras-3.png)

This is typically done in business to business (B2B) scenarios.

![images/tls-extras-4.png](images/tls-extras-4.png)

### Pod To Pod mTLS

By default Pod to Pod communication is via unencrypted HTTP. mTLS (i.e. two way TLS) can be used to secure Pod to Pod communication via HTTPS. mTLS should not be done at the applicaiton layer, it should be down at the Pod layer to ensure encryption algorithm compatibility.

![images/tls-extras-5.png](images/tls-extras-5.png)

Applications still communicate with each other via HTTP but third party tools like Istio and Linkerd can be used to provide the HTTPS layer between Pods. Istio and Linkerd provide other features as well. collectively called a service mesh.

![images/tls-extras-6.png](images/tls-extras-6.png)

A **service mesh** is a dedicated infrastructure layer that you can add to your applications. It allows you to transparently add capabilities like observability, traffic management, and security, without adding them to your own code.

![images/tls-extras-7.png](images/tls-extras-7.png)

In k8s Istio works by injecting a sidecar container into each Pod. Everytime the main application goes to send a message the Istio sidecare container intercepts it and will decide if it can be encrypted or not. After the possible encryption, the Istio sidecar container sends the message to the other Istio sidecare container. The message is decrypted if needed and is passed along to its application. The application may be outside of the k8s cluster.

![images/tls-extras-8.png](images/tls-extras-8.png)

 The 2 sending modes supported by Istio are:
1. **Permissive / Opportunistic:** will send via mTLS if possible otherwise use plain text.
2. **Enforce / Strict:** will send via mTLS only.

![images/tls-extras-9.png](images/tls-extras-9.png)

![images/tls-extras-10.png](images/tls-extras-10.png)

# 5) Supply Chain Security

## Image Terminology

A **parent image** is the image you use to build your application. A **base image** is an image that has no parent image and is built from scratch.

![images/images.png](images/images.png)

**Note:** the term base image can also be used to describe any image that was used to build a container.

It is a good idea to minimise the base image attack surface as much as possible by using the recommended best practises.

## Image Security Best Practices

### Cohesion & Modularity

Images should be highly cohesive and modular, meaning that they only have 1 application installed into them and be used as modules connecting to any other images or applications.

![images/images-2.png](images/images-2.png)

### State Persistance

An applications state should never be stored in the container because containers are ephemeral.  Always store application state in an external volume or caching application (e.g. Redis).

### Official Base Images

How do you choose a base image? Look at your technical requirements to answer that question. For example, want to run a webserver? Then choose httpd or nginx or a webserver base image. Once the base image has been chosen, you must make sure that you are using the latest official image for that application.

### Slim/Minimal Vs Fat Images

Consider using the slim/minimal versions of images as this makes pulling them faster, they are more efficient when running, and also contain less vulnerabilities as their attack surface is smaller. Only install what you need and remove anything that you don't need, e.g. uninstall package managers.

![images/images-3.png](images/images-3.png)

### Dev Vs Prod Images

Have separate images that run in the development environment and the production environment. The dev images will have lots of things needed to build and debug the application. The prod images will only have what is necessary to run the application, maybe some simple debugging tools as well. Alternatively you can have a debugging image in prod that can be turned on when neededing to debug and turned off at all other times.

### Distroless Images

Google provides some images that only contain the application and libraries, they have no package managers, shells, text editors, etc.

### Image Registries

#### Public Official Registries

Only use official registries to download offical base images. Remember that the image name inside a Pod definition file gets expanded following the Docker conventions. So if you don't supply a username for official images the `library` username is injected. And if you don't supply a registry address the `docker.io` website is injected.

![images/images-4.png](images/images-4.png)

There are many official registries, e.g. `gcr.io` for Google's container registry.

#### Private Internal Registries

You will also need to login to access private registries. In k8s can access private registries with a Docker Secret object with `kubectl create secret docker-registry $NAME $OPTIONS` and inject that into the Pod via `/spec/imagePullSecrets/[i]/name:$NAME`

![images/images-5.png](images/images-5.png)

![images/images-6.png](images/images-6.png)

#### Allowlisting Image Registries

Without restrictions in place, anyone who can create a Pod can create one using any image they have access to and introduce security vulnerabilities. You can block this by using a variety of AdmissionController options:


Create your own validating AdmissionController webhook.

![images/images-7.png](images/images-7.png)

Use a third party tool like Open Policy Agent as an AdmissionController.

![images/images-8.png](images/images-8.png)

Configure an existing AdmissionController called [ImagePolicyWebhook](https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#imagepolicywebhook).

![images/images-9.png](images/images-9.png)

The **ImagePolicyWebhook** Admission Controller allows a backend webhook to make admission decisions.

**Note:** This must be enabled like all other [Admission Controller](./README.md#admission-contollers) plugins. The `ImagePolicyWebhook` Admission Controlle is passed into `kube-apiserver` through the `--admission-control-config-file` option.

![images/images-11.png](images/images-11.png)

The `ImagePolicyWebhook` Admission Controller is configured by the `AdmissionConfiguration` Object. The configuration can be supplied in the YAML definition file or referrenced from an external YAML or JSON file.

This is an example of the `ImagePolicyWebhook` configuration external file referenced in the `AdmissionConfiguration` YAML definition file.

External confiugration file:

```yaml
# ImagePolicyWebhook configuration in external file
imagePolicy:
  kubeConfigFile: /path/to/kubeconfig/for/backend
  # time in s to cache approval
  allowTTL: 50
  # time in s to cache denial
  denyTTL: 50
  # time in ms to wait between retries
  retryBackoff: 500
  # determines behavior if the webhook backend fails
  defaultAllow: true
```

YAML definition file:

```yaml
# k8s AdmissionConfiguration YAML definition
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  path: imagepolicyconfig.yaml
...
```

This is an example of the `ImagePolicyWebhook` configuration within the `AdmissionConfiguration` YAML definition file.

```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: AdmissionConfiguration
plugins:
- name: ImagePolicyWebhook
  configuration:
    imagePolicy:
      kubeConfigFile: /path/to/kubeconfig/for/backend
      allowTTL: 50
      denyTTL: 50
      retryBackoff: 500
      defaultAllow: true
```

The `ImagePolicyWebhook` config file must reference a KUBECONFIG formatted file which sets up the connection to the backend. It is required that the backend communicate over TLS.

```yaml
# clusters refers to the remote service.
clusters:
- name: name-of-remote-imagepolicy-service
  cluster:
    certificate-authority: /path/to/ca.pem    # CA for verifying the remote service.
    server: https://images.example.com/policy # URL of remote service to query. Must use 'https'.

# users refers to the API server's webhook configuration.
users:
- name: name-of-api-server
  user:
    client-certificate: /path/to/cert.pem # cert for the webhook admission controller to use
    client-key: /path/to/key.pem          # key matching the cert
```

## Static Analysis & Dynamic Analysis

**Static analysis** is analysing computer software without executing the software. This is typically done for security auditing or debugging. **Dynamic analysis** is analysing computer software while executing the software. This is typically done for security auditing or debugging.

### kubesec

[kubesec](https://kubesec.io/) is a tool that can be used to do static analysis on k8s YAML defintion files. You can run this locally as a binary, use it via SaaS, or run it as a local webserver.

![images/kubesec.png](images/kubesec.png)

![images/kubesec-2.png](images/kubesec-2.png)

## Image Scanning

Image scanning is used to look for Common Vulnerabilities & Exposures (CVEs) with images. CVEs are bugs in software that are security vulnerabilites. CVEs are given a unique ID and a score ranking their severity. CVEs with high scores should be dealt with as soon as possible.

![images/cve.png](images/cve.png)

![images/cve-2.png](images/cve-2.png)

### Aquasec Trivy

[Trivy](https://www.aquasec.com/products/trivy/) is a product for vulnerability and infrastructure as code (IaC) scanning.

![images/trivy.png](images/trivy.png)

![images/trivy-2.png](images/trivy-2.png)

You can apply several filter options to the `trivy` command to tailor its output. It can also scan Docker images from a tarball.

![images/trivy-3.png](images/trivy-3.png)

### Best Practices

* Continually rescan images peridoically.
* Use k8s Admission Controllers to scan images.
* Have your own registry of pre-scanned images.
* Integrate scanning into your CI/CD pipeline.

# 6) Monitoring, Logging, & Runtime Security

## Behavioural Analytics

**Behavioral analysis** tries to identify malicious behavior by analyzing differences in normal and everyday activities. This can be applied to users and the system services.

![images/falco.png](images/falco.png)

## Falco

[Falco](https://falco.org/) is tool that monitors syscalls from user space into kernel space and uses behaviour analysis to flag abnormal or malicious activities. It needs to be running at the kernel level as its own kernel module or using the extended berkley packet filter (eBPF) kernel module.

![images/falco-2.png](images/falco-2.png)

Falco can be installed a system service or as a Daemon Set via a Helm chart.

### Detecting Threats

```bash
# Is it running?
systemctl status falco

# Tail the logs
journalctl -fu falco
```

![images/falco-3.png](images/falco-3.png)

Falco uses rules to detect abnormal and malicous behaviour. These rules are defined in YAML files. There are 3 sections, rules, lists, and macros.

**Rules** define the conidtions for when an alert is triggered.

![images/falco-4.png](images/falco-4.png)

There is a variety of objects that you can use within rule conditions.

![images/falco-5.png](images/falco-5.png)

 **Lists**  define what to monitor.

![images/falco-6.png](images/falco-6.png)

 **Macros** can simplify rule logic by defining conditions inside the macro and calling the macro within the rule. You can create custom macros or use builtin ones.

![images/falco-7.png](images/falco-7.png)

### Configuration

The global Falco configuration file is located at `/etc/falco/falco.yaml` and is used by Falco when it starts up.

![images/falco-8.png](images/falco-8.png)

![images/falco-9.png](images/falco-9.png)

The global Falco rules files is located at `/etc/falco/falco_rules.yaml`. The builtin rules are defined here.

![images/falco-10.png](images/falco-10.png)

Any updates to the builtin rules should be applied to `/etc/falco/falco_rules.local.yaml` file so they are not overwritten when Falco is updated. Custom fules are defined here.

![images/falco-11.png](images/falco-11.png)
