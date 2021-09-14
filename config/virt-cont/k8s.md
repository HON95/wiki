---
title: Kubernetes
breadcrumbs:
- title: Configuration
- title: Virtualization & Containerization
---
{% include header.md %}

Using **Debian**.

## Setup

1. **TODO**
1. (Optional) Setup command completion:
    - BASH (per-user): `echo 'source <(kubectl completion bash)' >>~/.bashrc`
    - ZSH (per-user): `echo 'source <(kubectl completion zsh)' >>~/.zshrc`
    - More info:
        - [bash auto-completion (k8s docs)](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-bash-linux/)
        - [zsh auto-completion (k8s docs)](https://kubernetes.io/docs/tasks/tools/included/optional-kubectl-configs-zsh/)

## Usage

- Config:
    - Show: `kubectl config view`
- Cluster:
    - Show: `kubectl cluster-info`
- Nodes:
    - Show `kubectl get nodes`
- Services:
    - Show: `kubectl get services`
- Pods:
    - Show: `kubectl get pods [-A] [-o wide]`
        - `-A` for all namespaces instead of just the current/default one.
        - `-o wide` for more info.
    - Show logs: `kubectl logs <pod> [container]`
- Manifests:
    - Show cluster state diff if a manifest were to be applied: `kubectl diff -f <manifest-file>`
- Events:
    - Show: `kubectl get events`

## Minikube

Minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

### Setup

1. See: [minikube start (minikube docs)](https://minikube.sigs.k8s.io/docs/start/)
1. Add `kubectl` symlink: `sudo ln -s $(which minikube) /usr/local/bin/kubectl`
1. Add command completion: See normal k8s setup instructions.

### Usage

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