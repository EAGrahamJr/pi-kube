# Services
Collection of some of the items that I'm running (or attempting to).

**Note:** services are _not_ using `Ingress` and ELB is not available, so `Node Port` is used for access.

| App        | Description | Port Description | Container Port | Node Port 
|------------|-------------|------------------|----------------|-----------
| Dashboard  | Kube dashboard | UI            |  8443          | 31080
| Grafana    | Monitoring  | UI               |    80          | 31082 
| gogs       | github-lite | Client/SSH       |    22          | 30022 
|            |             | UI               |  3000          | 30023 
| CouchDB    | NoSQL DB    | REST/UI          |  5984          | 30200
| Prometheus | Metrics     | Monitoring       |  9090          | 31090
| MQTT       | Message broker | MOM           |  1883          | 31883
|            |                |               |  9001          | 31901

##RabbitMQ##
The Rabbit images previously used were "custom" images built locally. Removed since that was in an
unknown state.

## Grafana
Straight up throw it on the server. Nothing is pre-configured. Uses the NFS mount for storage.

## GOGS
[GOGS](https://github.com/gogits/gogs) is a really simple, self-hosted GitHub-like server. This example is setup to
use a `Persisent Volume` mount via NFS. The "hardest" part is setting up the `git` remotes to use the off-color SSH
port correctly. In order to do this, you need to use the SSH "form" of the Git URL:

> ssh://git@<kube.node>:30022/<org>/<project>.git

## CouchDB
[Apache NoSQL](http://couchdb.apache.org/) database, using an NFS mount point. Once installed, you should be able to 
see the web UI at http://hostname:30200/_util/ui.

## HASS
Playing around with various [Home Assistant](https://www.home-assistant.io/) integrations.

### Prometheus
This is a straight up "scrape everything" from a HASS installation. The configuration is **not** included since
it contains _my_ HASS tokens, but I just copied the example from the 
[Prometheus Integration](https://www.home-assistant.io/integrations/prometheus/) page.

This also allows you to setup a source for Grafana using the default _service_ configuration:

> http://prometheus:9090

Note there is no authorization required.

### MQTT
Just a simple setup to receive messages from HASS using the 
[external integration](https://www.home-assistant.io/integrations/mqtt/).
