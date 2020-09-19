# Pi-Kube - My Kubernetes Cluster
A collection of notes and scripts for how I set up my personal Kubernetes cluster on Raspberry Pi 3.

![PiCluster](PiCluster-11222017.jpg)

:fire: **FINAL UPDATE** :fire:<br/>
_September 2020_<br/>
A brown-out somehow caused 3 of the 4 nodes to completely lose their minds, either the disk or hardware
itself. Since I really didn't feel like rebuilding from scratch (looking at Pi 4's), I am effectively
shuttering this project.

For anyone that was following along, thanks! It was an interesting project. :grin:

## Background
Quickly, this started with actually running the "full" Kubernetes application(s) on Raspberry Pi -
I've been dabbling with Home Automation for a long time and had a collection of Java "services"
that I wanted to "Docker-ize" and run on something other than my workstation.

So I needed to be able to deploy custom images from a private Docker repository.

The initial deployments were around v 1.8 (August 2017) and rather successful. However, the cluster stopped working
around v. 1.9.x due to increased memory requirements. That was a 6-month lifetime, so I wasn't particularly
pleased about that.

### Docker Swarm - Jan 2018
When the initial cluster died (hard), I resorted to building out a _Swarm_ cluster. I will admit
it was very simple to setup and it was workable. However, it was a bit cumbersome: I was relying on 
a lot of custom scripts with minor variations to mange it. It **probably** would have gotten more traction
if Kubernetes hadn't arrived at the same time.

### K3S - Sep 2019
[k3s](https://k3s.io/) is a reduced-footprint Kubernetes server/cluster that's intended for
smaller devices (like the Pi). At the time of it's initial release, K3S was not able to deploy very much
or very well, especially from a private repository, so I tried to kind of game it.

You can check the change history to see some of the weird deployment items I tried, but I've left
the [_jump-start_](java-jumpstart.yaml) hack I was using, just as an exercise in masochism.

### Kubernetes Again - May 2020
`kubeadm` is now fully functional again. [This article](https://opensource.com/article/20/6/kubernetes-raspberry-pi)
is an excellent source for most of the setup. I basically tore down everything, removed all of the prior Kubernetes installation files and cruft,
ditto for Docker, and started as fresh as you can without reimaging the SD card. I still opted for 32-bit because
I didn't want to start from bare disk images again, so I stayed on Debian Stretch.

#### Issues
- Still need to use `docker-ce`, **not** `docker.io` in Stretch
- For some reason I could not find a way to get rid of the `WARNING: No swap limit support` for Docker
- Flannel installation was smooth
- The Dashboard plugins setup worked smoothly - I changed the RBAC to use **dashboard-user** instead of
  **admin-user** in [dashboard-rbac](setup/dashboard-rbac.yaml).
  
  To avoid the awkward proxy syntax, I added the new [`Service`](setup/dashboard-service.yaml)
  to expose the dashboard on `NodePort 31080`. Note that it still needs to be accessed via `https`:
  
  > https://somenode.local:31080
  
  Use this command to get the dashboard token:
  
  ```bash
  kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep dashboard-user | awk '{print $1}') | grep "token:"
  ``` 

# Hints and Tricks
- I couldn't remember which Pi was which, so I used [this script](led-ctrl.sh) to turn on/off the LEDs
  on a node - [h/t](https://www.jeffgeerling.com/blogs/jeff-geerling/controlling-pwr-act-leds-raspberry-pi)
