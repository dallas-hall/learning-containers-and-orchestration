# Copy this example file to `vagrant/config.rb` for Vagrant to pick up your config
# changes. The `vagrant/config.rb` file is ignored by git.
#
#     cp vagrant/example_config.rb vagrant/config.rb

# One generic vm
# $nodes = [
#   {
#     :hostname => 'my-centos-8-vm',
#    :ip => '172.16.2.10',
#     :cpus => 4,
#     :memory => '4096',
#     :http_port => 8080,
#     :https_port => 8443,
#     :groups => ['centos8']
#   }
# ]


# Hadoop cluster
# Class B IP address with default subnet mask 255.255.0.0
# Host range = 172.16.0.1 - 172.16.255.254 (1 subnet & 65534 hosts)
# Subnet ID = 172.16.0.0
# CIDR = 172.16.0.0/16
# Broadcast address = 172.16.255.255

 $nodes = [
  {
    :hostname => 'centos-8-01',
    :ip => '172.16.2.11',
    :cpus => '2',
    :memory => '2048',
    :http_port => 1180,
    :https_port => 1443,
    :groups => ['cluster', 'master']
  },
  {
    :hostname => 'centos-8-02',
    :ip => '172.16.2.12',
    :cpus => '2',
    :memory => '2048',
    :http_port => 2280,
    :https_port => 2443,
    :groups => ['cluster', 'worker']
 	},
  {
    :hostname => 'centos-8-03',
    :ip => '172.16.2.13',
    :cpus => '2',
    :memory => '2048',
    :http_port => 3380,
    :https_port => 3443,
    :groups => ['cluster', 'worker']
 	}
 ]

# Use a proxy for yum (like apt-cacher-ng, speeds up repeat installs)
#$extra_vars[:os_yum_proxy] = "http://10.8.8.8:3142"

# Define a registry other than the vagrant/cre registry (speeds up repeat installs)
#$extra_vars[:docker_user] = false

# install registry
#$extra_vars[:install_registry] = "192.168.60.42:5000"
#$extra_vars[:install_registry_scheme] = "http"
##$extra_vars[:install_registry_auth_user] = "admin"
##$extra_vars[:install_registry_auth_pass] = "admin123"
#$extra_vars[:install_registry_ansible_host] = "install-registry"
#$extra_vars[:install_registry_become] = true
#$extra_vars[:install_registry_become_user] = "root"

# download registry
#$extra_vars[:download_registry] = "192.168.60.41:5000"
#$extra_vars[:download_registry_scheme] = "http"
#$extra_vars[:download_registry_ansible_host] = "download-registry"
#$extra_vars[:download_registry_become] = true
#$extra_vars[:download_registry_become_user] = "root"

# external download registry
#$extra_vars[:download_registry] = "10.8.8.8:5000"
#$extra_vars[:download_registry_scheme] = "http"
#$extra_vars[:download_registry_ansible_host] = "local"
#$extra_vars[:download_registry_become] = false
##$extra_vars[:download_registry_become_user] = "root"

# Run the image sync from the vagrant hypervisor
#$extra_vars[:docker_sync_ansible_host] = "local"

# Speed up docker installs
#$extra_vars[:docker_skip_selinux_troubleshooting] = true
