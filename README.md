# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on Raspberry Pi 3.

![PiCluster](PiCluster-11222017.jpg)

## Background
Quickly, this started with actually running the "full" Kubernetes application(s) on Raspberry Pi. That stopped
working around v. 1.9.x due to increased memory requirements, so I've sadly been limited to Docker `swarm` since.

Until [k3s](https://k3s.io/) showed up. And since it's _so_ new (of this writing), it has some issues that makes it
not _quite_ "ready", so these are now my evolving `k3s` hacking notes.

# Setup
Just follow the instructions. Stupid simple. Works great, no monitoring. Once the "server" is up, setup an agent
according to the docs.

I also set up the following `bash` alias: `alias k='/usr/local/bin/k3s kubectl'`

## Caveats

1. If you read the installation doc carefully, you'll note there's no monitoring. Oh, well...
1. The `containerd` services can't pull images from my local, insecure Docker repo.
   - Waiting on docs for the "local copy" deployment type

## Insecure Registry Work-Around
Wow - lots of issues trying to get a Docker registry to work without lots of hoops.

**BUT** you can run a "startup" script from a `ConfigMap` that basically re-creates the Docker image you were hoping to
pull from an insecure registry. A really stupid simple example is, obviously,
[Stupid Rabbit](rabbitmq/rabbit-stupid.yaml)

Most of my home-control apps are currently written in `Java`, so there's also an example 
[java-jumpstart.yaml](java-jumpstart.yaml) that uses `ftpcopy` to suck in the runnable JAR from
a "local" FTP server. (N.B. `ftpcopy` doesn't require dependencies)

# Hints and Tricks
- I couldn't remember which Pi was which, so I used the following to turn on the Disk Activity LED on a node:
  ```bash
  echo none >/sys/class/leds/led0/trigger # to turn off the default behavior
  echo 1 >/sys/class/leds/led0/brightness # turn the LED on
  echo 0 /sys/class/leds/led0/brightness # turn it off
  echo mmc0 /sys/class/leds/led0/trigger # restore original behavior
  ```
