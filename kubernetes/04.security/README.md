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
      - [Service Configuration](#service-configuration)
      - [Daemon Security](#daemon-security)
- [3) System Hardening](#3-system-hardening)
- [4) Minimising Microservices Vulnerabilities](#4-minimising-microservices-vulnerabilities)
- [5) Supply Chain Security](#5-supply-chain-security)
- [6) Monitoring, Logging, & Runtime Security](#6-monitoring-logging--runtime-security)

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
* Token access from an existing Role or ClusterRole token that is stored in a Secret.
* KUBECONFIG access.

![images/k8s-dashboard-5.png](images/k8s-dashboard-5.png)

### k8s Software

#### Versions

#### Verifying Application Binaries

#### Cluster Upgrades

See [CKA Cluster Upgrades](#52-cluster-upgrades)

### Network Policies

See [CKA Network Policies](../03.administrator/README.md#65-network-policies)

### Ingress

See [CKA Ingress](../03.administrator/README.md#846-ingress)

### Docker

#### Service Configuration

#### Daemon Security

# 3) System Hardening

# 4) Minimising Microservices Vulnerabilities

# 5) Supply Chain Security

# 6) Monitoring, Logging, & Runtime Security

