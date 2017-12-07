# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on
Raspberry Pi 3. Based on the article at
[How to Build a Kubernetes Cluster with ARM Raspberry Pi then run .NET Core on OpenFaas](https://www.hanselman.com/blog/HowToBuildAKubernetesClusterWithARMRaspberryPiThenRunNETCoreOnOpenFaas.aspx)

https://github.com/EAGrahamJr/pi-kube/PiCluster-11222017.jpg

# Quick Setup Instructions
## Initial Image
This install used the Debian Lite 2017-08-16 "stretch" image. I've had problems with the 09/07/2017 Raspian Lite 
image - YMMV.

There are a lot of comprehensive (and redundant) tutorials on how to set up Raspberry Pi systems, so it won't be 
re-hashed here again, too. But just for the record, the node names are:
- huginn
- muninn
- psyche
- ringo 

## Modify and Install
1. Turn off swap 
   - ```bash
     sudo dphys-swapfile swapoff && sudo dphys-swapfile uninstall && sudo update-rc.d dphys-swapfile remove
     ```
1. Enable all the `cgroup` settings
   - Edit `/boot/cmdline.txt`
   - Add `cgroup_enable=cpuset`
   - If `memory` is not enabled, add `cgroup_enable=memory cgroup_memory=1`
1. Install Docker
   - `curl -sSL get.docker.com | sh && sudo usermod pi -aG docker`
   - If available, enable the local insecure registry
     - Edit `/etc/docker/daemon.json`
     - Add `{ "insecure-registries":["<hostnane>:<port>"] }`
1. Install `kubeadm`
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
   - I also made a copy on my workstation and installed `kubectl` for full remote control
1. Install the internal network - this installation uses _Weave_
   - [Pod Network](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#pod-network)
1. Install one or more worker nodes. As shown in the picture, this was done on a 4-node cluster (1 admin, 3 worker)
   - If there are no worker nodes, the next several steps will stall
   - To "taint" the Master to also act as worker: `kubectl taint nodes --all node-role.kubernetes.io/master-`
   - This _may_ reset the previous - `kubectl taint node <masternode> node-role.kubernetes.io/master=:NoSchedule`
1. Install the dashboard
   - ```bash
     # pulls the recommended version
     GITLOC="https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/"
     kubectl apply -f "$GITLOC/recommended/kubernetes-dashboard-arm.yaml"
     # set up special admin by-pass for authentication
     kubectl apply -f setup/dashboard-admin.yaml
     # add a service to expose across all nodes (see table below)
     kubectl apply -f setup/dashboard-service.yaml
     ```
1. For more bells and whistles for monitoring, install Heapster/InfluxDB/Grafana. The files in the `setup` directory 
were copied (and modified) from the 
[Heapster/Influx](https://github.com/kubernetes/heapster/blob/master/docs/influxdb.md)) folks themselves.
  - ```bash
    kubectl apply -f setup/influxdb.yaml
    # Just to be sure, wait until the pod is in **Running** state
    kubectl apply -f setup/heapster.yaml
    kubectl apply -f setup/heapster-rbac.yaml
    ```

## RBAC
Kubernetes now runs by default in a "locked-down" authentication/authorization configuration. If you want to remove the
security restrictions (_really_ bad idea for a prod system), you can apply
```bash
kubectl create clusterrolebinding permissive-binding \
  --clusterrole=cluster-admin \
  --user=admin \
  --user=kubelet \
  --group=system:serviceaccounts
```

# Services
Deploy some of this stuff with the `k8s-apply.sh` script. Some of the images are also available in the individual
directories. No guarantees.

**Note:** services are _not_ using `Ingress` and ELB is not available, so `Node Port` is used for access.

| App        | Description | Port Description | Container Port | Node Port |
|------------|-------------|------------------|----------------|-----------|
| Kubernetes | Web UI      | UI               |  8443          | 31080 |
| Grafana    | Monitoring  | UI               |    80          | 31082 |
| Influxdb   | Monitoring  | DB               |  8086          | 31086 |
| gogs       | github-lite | Client/SSH       |    22          | 30022 |
|            |             | UI               |  3000          | 30023 |
| Rabbit     | MOM         | Client           |  5672          | 30100 |
|            |             | Management UI    | 15672          | 30101 |

## GOGS
[GOGS](https://github.com/gogits/gogs) is a really simple, self-hosted GitHub-like server. This example is setup to 
use a `Persisent Volume` mount via NFS. The "hardest" part is setting up the `git` remotes to use the off-color SSH 
port correctly. In order to do this, you need to use the SSH "form" of the Git URL:

> ssh://git@<kube.node>:30022/<org>/<project>.git

## RabbitMQ
A very simple image that relies more on environment variables than a configuration. Currently makes a 3.6.x image,
including the `autocluster` v 0.10 plugin and enables the _management_ plugin by default.
 
The Dockerfile relies on _build-arg_ argument passing, so a more recent version of `docker` is required to build it.

_Note:_ I tried using `ADD` to directly copy in the download files, but that seemed to have borked some permissions.

### Kubernetes
To run the cluster, the `auth` artifacts need to be applied first so that the auto-cluster plugin can access the 
Kubernetes API. Note that the authorization is overly broad and should really be dialed down.

## Grafana
The deployment uses the "stock" K8S dashboards. There are a couple of customized dashobards in `setup/grafana`, as well.
