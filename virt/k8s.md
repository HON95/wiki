---
title: Kubernetes
breadcrumbs:
- title: Virtualization, Containerization and Orchestration
---
{% include header.md %}

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
