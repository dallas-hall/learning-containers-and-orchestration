# Installing Docker In CentOS 8

* There is an issue with `containerd` version in CentOS 8 which blocks the latest version of `docker-ce` from installing.

```bash
dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
dnf install policycoreutils-python-utils.noarch
dnf install docker-ce --nobest
groupadd docker
usermod -aG docker vagrant
systemctl status docker
systemctl start docker
docker run hello-world
systemctl enable docker
dnf search docker-compose
curl -L "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
```
