---
title: Kubernetes
breadcrumbs:
- title: Containers
---
{% include header.md %}

## Information

### Miscellanea

- External traffic policy (ETP):
    - Details depend on the k8s/cloud provider.
    - Azure: ETP Cluster:
        - The LB sends incoming traffic to all nodes and kube-proxy on the nodes distributes it to healthy pods, possibly on different nodes.
        - Generally gives even traffic distribution and is responsive to pod health changes.
        - Long-lived connections may be impacted by cluster operations that change nodes the connections bounce throough.
    - Azure: ETP Local:
        - Traffic is only routed to nodes that are hosting the service.
        - Requires probing which can cause some traffic to be blackholed for a few seconds after pod changes.
        - Preserves source IP address.
- Pod disruption budget: Set up to avoid cluster-level operations like node upgrades don't kill everything, e.g. choosing how many instances of a container are allowed to be unavailable.
- Health probes:
    - Startup probe: Signals when the application has finished starting up, so the other probes can start. Prevents the liveness probe from restarting the pod before it's up. Mainly for containers that take a very long time to start and are unable to respond to liveless probes during that time.
    - Liveness probe: Signals if the container is healthy or if it should be restarted. Should check some internal logic, not just if the web endpoint is responding. Other containers in the pod like init containers are not restarted.
    - Readiness probe: Signals that the container is ready to accept traffic from the load balancer. Used to stop traffic to pods that are temporarily unhealthy e.g. due to startup, overload (with auto-scaling) or internal disconnects.

## Setup

1. Install:
    - Arch Linux: `yay -S kubectl`
1. (Optional) Setup command completion:
    - BASH (per-user): `echo 'source <(kubectl completion bash)' >>~/.bashrc`
        - More info: [k8s docs: bash auto-completion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/)
    - ZSH (per-user): `echo 'source <(kubectl completion zsh)' >>~/.zshrc`
        - More info: [k8s docs: zsh auto-completion](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-zsh/)

## Usage

- Config:
    - Show: `kubectl config view`
- Cluster:
    - Show basic info: `kubectl cluster-info`
- Nodes:
    - Show nodes: `kubectl get nodes [-o wide]`
    - Show node IP addresses: `kubectl get nodes -o=custom-columns="NAME:.metadata.name,ADDRESSES:.status.addresses[?(@.type=='InternalIP')].address,PODCIDRS:.spec.podCIDRs[*]"`
    - Show resource usage: `kubectl top nodes`
- Services:
    - Show: `kubectl get services`
- Pods:
    - Show pods from all namespaces: `kubectl get pods -A [-o wide]`
    - Show logs: `kubectl logs <pod> [container]`
- Manifests:
    - Show cluster state diff if a manifest were to be applied: `kubectl diff -f <manifest-file>`
- Events:
    - Show: `kubectl get events`

## Related Software

**TODO**

## Alternative Variants

### Minikube

Minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

#### Setup

1. See: [minikube start (minikube docs)](https://minikube.sigs.k8s.io/docs/start/)
1. Add `kubectl` symlink: `sudo ln -s $(which minikube) /usr/local/bin/kubectl`
1. Add command completion: See normal k8s setup instructions.

#### Usage

- Generally all of the normal k8s stuff applies.
- Generally sudo isn't required.
- Manage minikube cluster:
    - Start: `minikube start`
    - Pause (**TODO** what?): `minikube pause`
    - Stop: `minikube stop`
    - Delete (all clusters): `minikube delete --all`
- Set memory limit (requires restart): `minikube config set memory <megabytes>`
- Start and open web dashboard: `minikube dashboard`
- Show addons: `minikube addons list`

{% include footer.md %}
