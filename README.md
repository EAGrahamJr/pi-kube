# Update 5/2018

Some of my cluster survived a power failure, but one node did not. In all of my attempts
to resurrect it and/or create a new Kubernetes cluster, I was unable to
use **any** recent version (e.g. 1.10) to initialize. Accordingly, this popped up

See [Kubeadm init stuck...](https://github.com/kubernetes/kubernetes/issues/61277)

Despite following many of the tweaks suggested in this issue, I could get the cluster for form,
but Kube DNS was completely hosed, no matter which mesh provider used.

Caveat emptor.

## Extra Special Note 
I was able to get the cluster re-created, but `kube-dns` was not resolving anything from any pod and I can't find any
errors. The saga continues...

# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on
Raspberry Pi 3. Based on the article at
[How to Build a Kubernetes Cluster with ARM Raspberry Pi then run .NET Core on OpenFaas](https://www.hanselman.com/blog/HowToBuildAKubernetesClusterWithARMRaspberryPiThenRunNETCoreOnOpenFaas.aspx)

![PiCluster](PiCluster-11222017.jpg)

# Quick Setup Instructions
Not that it needs to be said, but this needs to be done on _every_ host for the cluster.

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
   - Add `cgroup_enable=cpuset cgroup_enable=memory cgroup_memory=1`
1. Install Docker
   - `curl -sSL get.docker.com | sh && sudo usermod pi -aG docker`
   - :bangbang: Immediately _downgrade_ Docker via `apt install docker-ce=17.12.1~ce-0~raspbian`
   - If desired, enable a local insecure registry for your images:
     - Edit `/etc/docker/daemon.json`
     - Add `{ "insecure-registries":["<hostnane>:<port>"] }`
1. Install `kubeadm`
   - ```bash
     curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add - && \
       echo "deb http://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
       sudo apt-get update -q && \
       sudo apt-get install -qy kubeadm
     ```
1. Modify the `kubeadm` service to not fret about network stuff
   - ```bash
     sudo sed -i '/KUBELET_NETWORK_ARGS=/d' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf   
     ```
1. Don't forget to reboot to pick up all of the changes...

### Upgrading
1, If this was a previous node, 
   - run `kubeadm reset`
   - remove leftovers `rm /etc/kubernetes/bootstrap-kubelet.conf`
   - :bangbang: clear up old networks `sudo ip link delete flannel.1`
1. Update **all** the packages and downgrade Docker
   - You may need to re-add the Google `apt` key above
1. Modify `kubeadm` service with the `sed` command and reboot for good measure

## Start It Up
1. Initialize the Master (never expiring token)
   - `sudo kubeadm init --token-ttl=0 --pod-network-cidr=10.244.0.0/16`
   - **Keep a copy of the join command! This is PITA to re-create!**
1. Make a copy of the config for `kubectl`
   - ```bash
     mkdir -p $HOME/.kube && sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config
     ```
   - I also made a copy on my workstation and installed `kubectl` for full remote control
1. :bangbang: Install the internal network - this installation uses _Flannel_. See the 
   [kubeadm instructions](https://kubernetes.io/docs/setup/independent/create-cluster-kubeadm/#instructions)
   for all the details. (Make sure you apply the IP tables fix to _all_ nodes.)
   - ```bash
     curl -sSL https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml | sed "s/amd64/arm/g" | kubectl create -f -
     ```
   - if Flannel is unable to start up, try running `sudo ip link delete flannel.1` and delete the Flannel pods
   - if NodePort services are not working, try also `sudo iptables -A FORWARD -o flannel.1 -j ACCEPT` 
   manually to force them to restart.
1. Install one or more worker nodes, using the command captured above.
   As shown in the picture, this was done on a 4-node cluster (1 admin, 3 worker)
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
[Heapster/Influx](https://github.com/kubernetes/heapster/blob/master/docs/influxdb.md) folks themselves.
  - The `Heapster` artifacts should be applied as a minimum - this will make the _Kubernetes_ dashboard prettier...
  - Slightly customized _Cluster_ and _Pod_ Grafana dashboards are in `setup/grafana`

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

# Hints and Tricks
- I couldn't remember which Pi was which, so I used the following to turn on the Disk Activity LED on a node:
  ```bash
  echo none >/sys/class/leds/led0/trigger # to turn off the default behavior
  echo 1 >/sys/class/leds/led0/brightness # turn the LED on
  echo 0 /sys/class/leds/led0/brightness # turn it off
  echo mmc0 /sys/class/leds/led0/trigger # restore original behavior
  ```
