# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on Raspberry Pi 3.

![PiCluster](PiCluster-11222017.jpg)

## Background
Quickly, this started with actually running the "full" Kubernetes application(s) on Raspberry Pi. That stopped
working around v. 1.9.x due to increased memory requirements, so I detoured into

- Docker `swarm` (there's a reason it didn't catch on for Enterprise)
- [k3s](https://k3s.io/)
  - you can check the change history to see some of the weird deployment issues
  - the [_jump-start_](java-jumpstart.yaml) hack I was using to dynamically deploy was just painful

However as of May 2020, `kubeadm` is now fully functional again.

# Issues
## Overlay
Calico didn't work, but Weave does.

## Dashboard
Basically, all that was needed to do was copy the Dashboard plugins setup.
The RBAC was changed to user "dashboard-user" instead of "admin-user", so
that's found in [dashboard-rbac](setup/dashboard-rbac.yaml).

Add the new [`Service`](setup/dashboard-service.yaml) to expose the dashboard on `NodePort 31080`.

This is the new command to get the dashboard token (`config` file doesn't work).

> kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep dashboard-user | awk '{print $1}')

# Hints and Tricks
- I couldn't remember which Pi was which, so I used the following to turn on/off the Disk Activity LED on a node:
  ```bash
  echo none >/sys/class/leds/led0/trigger # to turn off the default behavior
  echo 1 >/sys/class/leds/led0/brightness # turn the LED on
  echo 0 > /sys/class/leds/led0/brightness # turn it off
  echo mmc0 > /sys/class/leds/led0/trigger # restore original behavior
  ```

Full instructions: https://www.jeffgeerling.com/blogs/jeff-geerling/controlling-pwr-act-leds-raspberry-pi
