# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on Raspberry Pi 3.

![PiCluster](PiCluster-11222017.jpg)

## Background
Quickly, this started with actually running the "full" Kubernetes application(s) on Raspberry Pi. That stopped
working around v. 1.9.x due to increased memory requirements, so I detoured into

- Docker `swarm` (there's a reason it didn't catch on for Enterprise)
- [k3s](https://k3s.io/)
  - you can check the change history to see some of the weird deployment issues
  - the _jump-start_ hack I was using was just painful

However, `kubeadm` seems to be working again. I followed 
https://kubecloud.io/setting-up-a-kubernetes-1-11-raspberry-pi-cluster-using-kubeadm-952bbda329c8
(without setting any versions) and it appears to be working. 

**NOTE** There's a small typo - the command to set up the Weave CNI network is missing a trailing `"`

``bash
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
``

# Issues
## Monitoring
Updates to the [setup](setup) files courtesy of https://brookbach.com/2018/10/29/Heapster-on-Kubernetes-1.11.3.html

## Dashboard
https://www.donaldsimpson.co.uk/2019/01/09/kubernetes-dashboard-with-heapster-stats/

This produces the correct token for the Dashboard, but it seems to be broken (404)
`kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep --color=auto dashboard | awk '{print $1}')`

# Hints and Tricks
- I couldn't remember which Pi was which, so I used the following to turn on the Disk Activity LED on a node:
  ```bash
  echo none >/sys/class/leds/led0/trigger # to turn off the default behavior
  echo 1 >/sys/class/leds/led0/brightness # turn the LED on
  echo 0 > /sys/class/leds/led0/brightness # turn it off
  echo mmc0 > /sys/class/leds/led0/trigger # restore original behavior
  ```

Full instructions: https://www.jeffgeerling.com/blogs/jeff-geerling/controlling-pwr-act-leds-raspberry-pi
