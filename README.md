# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on Raspberry Pi 3.

![PiCluster](PiCluster-11222017.jpg)

## Background
Quickly, this started with actually running the "full" Kubernetes application(s) on Raspberry Pi. That stopped
working around v. 1.9.x due to increased memory requirements, so I've sadly been limited to Docker `swarm` since.

Until [k3s](https://k3s.io/) showed up. And since it's _so_ new (of this writing), it has some issues that makes it
not quite suitable for my internal needs. So these are now my `k3s` hacking notes.

# Setup
Just follow the instructions. Stupid simple. Works great, no monitoring. Once the "server" is up, setup an agent
according to the docs.

I also set up the following `bash` alias: `alias k='/usr/local/bin/k3s kubectl'`

## Caveats

1. If you read the installation doc carefully, you'll note there's no monitoring. Oh, well...
1. The `containerd` services can't pull images from my local, insecure Docker repo.
1. There's no "stop" command.
   - The "cleanest" way it appears is to reboot the Pi.
   - Just stopping/killing `k3s` leaves all the `containerd-shim` processes running

## TBD Insecure Registry
- Just go with the [Docker.io](https://docs.docker.com/registry/deploying/#run-an-externally-accessible-registry)
  - Why can't I get this to work?
- Maybe better on my NAS? 
   [CenturyLink article](https://www.ctl.io/developers/blog/post/how-to-secure-your-private-docker-registry/)


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
| CouchDB    | NoSQL DB    | REST/UI          |  5984          | 30200 |
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

## CouchDB
[Apache NoSQL](http://couchdb.apache.org/) database, using an NFS mount point. Once installed, you should be able to 
see the web UI at http://hostname:30200/_util/ui.

Note that this setup has *NOT* been tried due to the DNS issues mentioned at the top.

# Hints and Tricks
- I couldn't remember which Pi was which, so I used the following to turn on the Disk Activity LED on a node:
  ```bash
  echo none >/sys/class/leds/led0/trigger # to turn off the default behavior
  echo 1 >/sys/class/leds/led0/brightness # turn the LED on
  echo 0 /sys/class/leds/led0/brightness # turn it off
  echo mmc0 /sys/class/leds/led0/trigger # restore original behavior
  ```
