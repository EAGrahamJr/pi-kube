# Services
Maybe on a later version of K3S we'll be able to get back to having some of this stuff running...

# Overview
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
