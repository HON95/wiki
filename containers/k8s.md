---
title: Kubernetes
breadcrumbs:
- title: Containers
---
{% include header.md %}

## Information

### Control Plane Components

- **TODO**

### Node Components

- **kubelet:**
    - The "node agent" that manages the node and communicates with the control plane.
    - Creates pods/containers by orchestrating the CRI, CNI and CSI plugins and reports back to the control plane.
- **kube-proxy:**
    - The network proxy on each node that provides L3/L4 routing for services toward associated pods, using NAT rules.
    - Not used if the CNI plugin provides the feature instead (e.g. Cilium).
- **Container Runtime Interface (CRI) plugin:**
    - Creates the container.
- **Container Network Interface (CNI) plugin:**
    - Attaches the container to the network.
- **Container Storage Interface (CSI) plugin:**
    - Attaches the container to storage.

### Miscellanea

- **External traffic policy (ETP):**
    - Details depend on the k8s/cloud provider.
    - Azure: ETP Cluster:
        - The LB sends incoming traffic to all nodes and kube-proxy on the nodes distributes it to healthy pods, possibly on different nodes.
        - Generally gives even traffic distribution and is responsive to pod health changes.
        - Long-lived connections may be impacted by cluster operations that change nodes the connections bounce throough.
    - Azure: ETP Local:
        - Traffic is only routed to nodes that are hosting the service.
        - Requires probing which can cause some traffic to be blackholed for a few seconds after pod changes.
        - Preserves source IP address.
- **Pod disruption budget:**
    - Set up to avoid cluster-level operations like node upgrades don't kill everything, e.g. choosing how many instances of a container are allowed to be unavailable.
- **Health probes:**
    - Startup probe: Signals when the application has finished starting up, so the other probes can start. Prevents the liveness probe from restarting the pod before it's up. Mainly for containers that take a very long time to start and are unable to respond to liveless probes during that time.
    - Liveness probe: Signals if the container is healthy or if it should be restarted. Should check some internal logic, not just if the web endpoint is responding. Other containers in the pod like init containers are not restarted.
    - Readiness probe: Signals that the container is ready to accept traffic from the load balancer. Used to stop traffic to pods that are temporarily unhealthy e.g. due to startup, overload (with auto-scaling) or internal disconnects.
- **Grafeful pod shutdown:**
    - When containers are scheduled for deletion, k8s will simultaneously tell the node to terminate the container and remove the container from any associated EndpointSlices.
    - By default, the node immediately sends the container a `SIGTERM`. If the container is still running after 30 seconds (by default, see `terminationGracePeriodSeconds`), it sends a `SIGKILL`.
    - Make sure the application listens for `SIGTERM` so it can shutdown gracefully, before the `SIGKILL` is sent a while after. Long-lived connections should be killed after some seconds so the application itself can be allowed to shut down gracefully before being killed.
    - Since the EndpointSlice update happens in parallel to the container being terminated, some new connections might be sent to the container until all EndpointSlice listeners (e.g. load balancers or ingress controllers) have responded to the update. When receiving the `SIGTERM` in the application, it might be a good idea to wait a few seconds to account for this.
    - If the application exits immediately when receiving a `SIGTERM`, consider adding a `PreStop` hook to the container that simply sleeps for some seconds, so new connections can be accepted until services etc. converge. Note that this hook eats from the same 30 second (default) grace period as the container, so it should sleep for at most 25 seconds.
    - For applications with long-lived connections or jobs, one solution to avoid getting killed is to simply increase the k8s wait timer. Another solution is to prevent the container from being killed, e.g. by rolling out new versions as a different deployment, leaving the outdated containers still running until remove manually or through some automation.
    - When using a lot of replicas and rolling out new versions such that all pods get recreated, there might be a considerable overlap in time between containers waiting to shut down gracefully and new containers getting created, using a lot of extra resources. Keep this in mind when designing the deployment.

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
    - Show node details: `kubectl describe nodes`
    - Show node resource usage: `kubectl top nodes`
- Services:
    - Show: `kubectl get services`
- Pods:
    - Show pods from all namespaces: `kubectl get pods -A [-o wide]`
    - Show pod resource usage: `kubectl top pod -A`
    - Show logs: `kubectl logs <pod> [container]`
- Manifests:
    - Show cluster state diff if a manifest were to be applied: `kubectl diff -f <manifest-file>`
- Events:
    - Show: `kubectl get events`

## Related Software

### Cilium

#### Setup (Self-Hosted)

**TODO**

#### Usage

- Check status: `kubectl -n kube-system exec ds/cilium -- cilium status`
- Check health: `kubectl -n kube-system exec ds/cilium -- cilium-health status`

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
