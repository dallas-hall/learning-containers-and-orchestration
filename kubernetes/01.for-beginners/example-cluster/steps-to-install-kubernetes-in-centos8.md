# Installing kubectl only

* https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-on-linux

```
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
dnf install -y kubectl
```

# Install Minikube Single Node k8bs cluster

* https://kubernetes.io/docs/tasks/tools/install-minikube/

# Installing k8s Cluster With kubeadm

* https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

```
# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
ssh vms
sudo -s

cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

systemctl enable --now kubelet

# https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
ssh vm-master
sudo -s

# turn swap file off, Kubernetes can't run with swap.
swapoff -a

kubeadm init --pod-network-cidr=192.168.0.0/16 --apiserver-advertise-address=172.16.2.11
	run the comamnds in the output as a normal user
	save the kubeadm join key
kubeadm join 172.16.2.11:6443 --token 2ubq8a.w4f51jin8ftgxx01 \
    --discovery-token-ca-cert-hash sha256:bf102e4ff6456cdc42f30fe75b286572ee89ad9fdacd98566eefb2982eac7f97 

# Create POD networking
kubectl apply -f https://docs.projectcalico.org/v3.11/manifests/calico.yaml

# Test CoreDNS is running.
kubectl get pods --all-namespaces

# On worker nodes
# turn swap file off, Kubernetes can't run with swap.
sudo swapoff -a
sudo kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>

# Check the nodes
ssh vm-master
kubectl get nodes
kubectl run nginx --image=nginx
kubectl get pods
kubectl get pods --no-headers=true | awk '/nginx/{print $1}' | xargs  kubectl delete pod
kubectl delete pod nginx
```

# Install k8s cluster with Kubespray

* https://kubernetes.io/docs/setup/production-environment/tools/kubespray/
* Can use Ansible or Vagrant, I used my own Vagrant and then Ansible.
