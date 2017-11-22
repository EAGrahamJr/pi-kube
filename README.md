# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on
Raspberry Pi 3. Based on the article at
[How to Build a Kubernetes Cluster with ARM Raspberry Pi then run .NET Core on OpenFaas](https://www.hanselman.com/blog/HowToBuildAKubernetesClusterWithARMRaspberryPiThenRunNETCoreOnOpenFaas.aspx)

# Quick Setup Instructions
## Initial Image
1. Use the Debian Lite image and burn to disk per usual
   - I've had problems with the 09/07/2017 Raspian Lite image - YMMV
1. Mount the FAT partition and make the `ssh` file (enables `ssh` on first boot)
   - ```bash
     mount /dev/sde1 /mnt
     touch /mnt/ssh
     umount /mnt
     ```
1. Do the usual boot and `raspi-config` (should be able to use `mDNS` name `raspberrypi.local`)

## Modify and Install
1. Turn off swap 
   - ```bash
     sudo dphys-swapfile swapoff && sudo dphys-swapfile uninstall && sudo update-rc.d dphys-swapfile remove
     ```
1. Enable all the `cgroup` settings
   - Edit `/boot/cmdline.txt`
   - Add `cgroup_enable=cpuset`
     - if `memory` is not enabled, add `cgroup_enable=memory cgroup_memory=1`
1. Install Docker
   - `curl -sSL get.docker.com | sh && sudo usermod pi -aG docker`
   - If available, enable the local insecure registry
     - Edit `/etc/docker/daemon.json`
     - Add `{ "insecure-registries":["<hostnane>:<port>"] }`
1. Install Kubeadm
   - ```bash
     curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
       echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
       sudo apt-get update -q && \
       sudo apt-get install -qy kubeadm
     ```
1. Don't forget to reboot to pick up all of the changes...
     
## Start It Up
1. Initialize the Master (never expiring token)
   - `sudo kubeadm init --token-ttl=0`
   - **Keep a copy of the join command! This is PITA to re-create!**
1. Make a copy of the config for `kubectl`
   - ```bash
     mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config
     ```
1. Install the internal network - used _Weave_
   - [Pod Network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
1. Install one or more worker nodes
   - If no worker nodes, the next several steps will stall
   - May also want to "taint" the Master to also act as worker: `kubectl taint nodes --all node-role.kubernetes.io/master-`
1. Install the dashboard
   - ```bash
     GITLOC="https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/"
     kubectl apply -f "$GITLOC/recommended/kubernetes-dashboard-arm.yaml"
     ```
   - Set up special admin by-pass for authentication
     - `kubectl apply -f setup/dashboard-admin.yaml`
   - Add a service to expose across all nodes (see table below)
     - `kubectl apply -f setup/dashboard-service.yaml`
1. Install `Heapster` for more betterer monitoring
   - `kubectl apply -f setup/heapster-binding.yaml`
   - `kubectl apply -f setup/heapster.yaml`

# Services
Deploy some of this stuff with the `k8s-apply.sh` script. Some of the images are also available in the individual
directories. No guarantees.

**Note:** services are _not_ using `Ingress` and ELB is not available, so `Node Port` is used for access.

| App        | Description | Port Description | Container Port | Node Port |
|------------|-------------|------------------|----------------|-----------|
| Kubernetes | Web UI      |                  | 8443           | 31080 |
| gogs       | github-lite | Client/SSH       |    22          | 30022 |
|            |             | UI               |  3000          | 30023 |
| Rabbit     | MOM         | Client           |  5672          | 30100 |
|            |             | Management UI    | 15672          | 30101 |
