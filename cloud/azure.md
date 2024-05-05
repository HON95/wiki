---
title: Azure
breadcrumbs:
- title: Cloud
---
{% include header.md %}

## General

### IPv6

- [Microsoft Learn: Overview for IPv6 for Azure Virtual Network](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/ipv6-overview)
- _Many_ features in Azure do not support IPv6. Some support dual-stack. Very few (none?) support IPv6-only.
- You're forced to use NAT (with an internal network conneted to the VM) both for IPv4 and IPv6 (_why?_).
- ICMPv6 isn't supported by network security groups. You can't ping inbound over IPv6, path MTU discovery (PMTUD) is broken, etc. Broken PMTUD can be somewhat avoided by simply setting the VM NIC MTU from 1500 to 1280 (the minimum for IPv6), so _outbound_ traffic will not need PMTUD.

## Azure CLI

### Install

- Arch:
    - Install CLI: `sudo pacman -S azure-cli`
    - Download command completion: `sudo curl -L https://raw.githubusercontent.com/Azure/azure-cli/dev/az.completion -o /etc/bash_completion.d/az`
        - First: To setup BASH command completion with ZSH, configure reading BASH profile configs and see `/etc/profile.d/completion.sh` in [Arch](personal-devices/arch-i3/). Create `/etc/bash_completion.d` if it doesn't exist yet.

### Usage

- Warning: Make sure to destroy test resources as they can get expensive to keep around for no reason.
- Login/logout:
    - Interactively (web): `az login`
    - Logout: `az logout`
- Subscriptions:
    - Show all subscriptions: `az account list`
    - Show active subscription: `az account show`
    - Set active subscription: `az account set --subscription <id>`
- Service principals:
    - Create (with subscription ID from login): `az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<sub-id>"`
    - Copy all the outputted value into the application that needs the credentials, including the inputted subscription ID.
- Resource Group (RG):
    - Create: `az group create --name <rg> --location norwayeast` (e.g. `test_rg`)
    - List all resources under an RG: `az resource list --resource-group=<name>`
- Azure Container Registry (ACR):
    - Note: The registry name must be unique in Azure and can only contain 5-50 alphanumeric characters.
    - Create: `az acr create --resource-group <rg> --name <acr> --sku Basic`
    - Delete: `az acr delete --name <acr>`
    - Build image and push: `az acr build --registry <acr> --image <image>:<tag> [path]` (path: must contain a `Dockerfile`) (image: e.g. `aks-store-demo/product-service:latest`)
    - Show images: `az acr repository list --name <acr> --output table`
- Miscellanea:
    - Get VM sizes: `az vm list-sizes --location "Norway East"`
        - With filtering (example): `az vm list-sizes --location "Norway East" | jq '.[] | select(.numberOfCores <= 2) | select(.memoryInMB == 1024)'`

## Virtual Machine (VM)

### Setup (Web Example)

This sets up a simple VM (called `Yolo`) in its own resource group and its own resources.

1. Create a resource group (`Yolo-RG`) in the desired region.
    - This will be used by all other resources for the VM.
    - You may want to put *all* your VMs and resources in the same resource group, in which case you probably want to call it something else.
1. Create a virtual network (`Yolo-VNet`).
    - Note: Remove any leading zeroes from IPv6 addresses and zero-compress everything. Azure doesn't like zeroes, apparently.
    - Press "add IPv6 address space" and add a valid and randomized /48 ULA prefix (e.g. from [here](https://simpledns.plus/private-ipv6)), so you'll get internal address spaces for both IPv4 (/16) and IPv6 (/48). Remove any existing IPv6 prefixes.
    - Remove the "default" subnet and add a new "default" containing the first IPv4 /24 and IPv6 /64 subnets from the address spaces. No NAT gateways or service endpoints are needed.
    - No bastion host, DDoS protection or firewall is needed.
    - If you plan on using a outbound NAT gateway, this can be configured later.
1. Create public IP addresses for the VM (IPv4 and IPv6) (`Yolo-IPv{4,6}`).
    - Note: This can be done differently if using a NAT gateway.
    - Select "both IPv4 and IPv6".
    - Use the "standard" SKU.
    - Use static assignment.
    - Use "Microsoft network" routing preference.
    - Use the "zone-redundant" availability zone.
    - Take note of the allocated IPv4 and IPv6 addresses so you can add it to DNS records.
    - **TODO** See the docs about "IPs created before the availability zone are not zone redundant" etc.
1. (Optional) Create a NAT gateway for outbound connections (`Yolo-NATGW`):
    - This is required when using multiple VMs behind a limited number of public IPv4 addresses, which may cause port exhaustion if the VMs create many outbound connections. This is not required if all VMs have dedicated public IPv4 addresses, however.
    - Create the NAT gateway with TCP idle timeout 10 minutes (e.g.).
    - **TODO** Add public IPv4/IPv6 addresess/prefixes and select the VNet. I haven't done this since all my VMs use public addresses.
1. Create a network security group (`Yolo-NSG`).
    - The configuration of this one is _after_ its creation.
    - Add the following inbound rules (depending on the purpose of the VM):
        - (Note) Use source "any", destination "any", source port "any" and action "allow".
        - (Note) The predefined services are a bit dumb, just use custom specifications instead.
        - ICMPv4: Port `*`, protocol ICMP.
        - SSH: Port `22`, protocol TCP.
        - HTTP(S): Port `80,443`, protocol any.
    - Go to the "subnets" tab and associate it with the just-created virtual network and subnet. This will implicitly associate it with NICs in the subnet too (no need to associate NICs explicitly).
1. Create a virtual machine (`Yolo-VM`).
    - Instance availability: Don't require infrastructure redundancy.
    - Instance security: Use standard security.
    - Instance OS: Use your desired OS image, e.g. Debian.
    - Instance type: Use an appropriate size. This might require a bit of research. The B-series is fine for e.g. smaller web hosting servers.
    - Admin account: If you plan on provisioning the server with e.g. Ansible after creation, use an appropriate username and SSH pubkey.
    - Inbound ports: Allow public inbound port SSH. The NSG can be changed later. (**TODO:** )
    - OS disk:
        - Use standard SSD unless you need high IOPS.
        - Use default encryption type (at-rest with platform-managed key).
        - Delete disk with VM.
    - Data disk (if needed):
        - Create a new disk.
        - The auto-generated name is fine IMO.
        - Use the same options as the OS disk, where applicable, except maybe "delete with VM".
    - Network:
        - Use the created virtual network and subnet.
        - Use the created IPv4 address, the created IPv6 address can be added later.
        - Don't use a NIC NSG, the created one is already assigned to the used subnet.
        - Delete NIC when VM is deleted, but don't dfelete IP address when VM is deleted.
        - Don't use load balancing.
    - Monitoring: You choose.
    - Backup:
        - Enable if not using other backup solutions.
        - Create a new recovery services vault (`Yolo-RSV`) within the RG.
        - Use policy subtype "standard".
        - Use the default, new backup policy or create a custom one.
    - Cloud-Init (optional): Add custom data and user data.
1. Fix the NIC:
    - (**TODO**) Was it pointless to select any inbound ports during VM creation when the NSG rules will be applied anyways?
    - Go to the "IP configurations" tab and add a new secondary config for IPv6 named `ipconfig2`, with dynamic assignment and associated with the created public IPv6 address.

### Usage

- Show VMs (CLI): `az vm list`

### Miscellanea

- Some guides may tell you that you need to create a load balancer in order to add IPv6 to VMs, but that's avoidable.
- The default ifupdown network config (which uses DHCP for v4 and v6) broke IPv6 connectivity for me after a while for some reason. Switching to systemd-networkd with DHCP and disabling Ifupdown (comment out everything in `/etc/network/interfaces` and mask `ifup@eth0.service`) solved this for me.
- If you configure non-Azure DNS servers in the VM config, it will seemingly only add one of the configured servers to `/etc/resolv.conf`. **TODO** It stops overriding `/etc/resolv.conf` if using Azure DNS servers?
- Adding IPv6 to VM:
    1. (Note) This was written afterwards, I may be forgetting some steps.
    1. Create an IPv4 address and an IPv6 address.
    1. In the virtual network for the VM, add a ULA IPv6 address space (e.g. an `fdXX:XXXX:XXXX::/48`). Then modify the existing subnet (e.g. `default`), tick the "Add IPv6 address space" box and add a /64 subnet from the address space you just added.
    1. In the network interface for the VM, configure the primary config to use the private IPv4 subnet and the public IPv4 address. Add a new secondary config for for the IPv6 (private) ULA subnet and the (public) GUA.

## Azure Kubernetes Service (AKS)

**UPDATE:** I have given up on this ... To bad IPv6 support and an error when trying to deploy AKS using dual-stack Cilium, _just like how the guides show how to do it_. IPv4-only is not an option ...

### Resources

- [Microsoft Learn: Quotas, virtual machine size restrictions, and region availability in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/quotas-skus-regions)
- [Microsoft Learn: Supported Kubernetes versions in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)

### Info

- AKS can be deployed as a public cluster or a private cluster:
    - Public AKS has a world-accessible IP address and world-resolvable hostname. The access can be restricted using the _API server authorized IP ranges_ feature.
    - Private AKS is only accessible from your resources within Azure and uses private DNS.
- To allow an AKS cluster to interact with other Azure resources, the Azure platform automatically creates a cluster identity. (From AKS docs.)
- AKS clusters can use Kubernetes role-based access control (Kubernetes RBAC), which allows you to define access to resources based on roles assigned to users. If a user is assigned multiple roles, permissions are combined. Permissions can be scoped to either a single namespace or across the whole cluster. (From AKS docs.)
- When you deploy an Azure Kubernetes Service cluster in Azure, it also creates a second resource group for the worker nodes. By default, AKS names the node resource group `MC_resourcegroupname_clustername_location`. (From AKS docs.)
- Managed resources:
    - Underlay/overlay networking is managed by AKS.
    - Creating a Kubernetes load balancer on Azure simultaneously sets up the corresponding Azure load balancer resource (layer 4 only).
    - As you open network ports to pods, Azure automatically configures the necessary network security group rules.
    - Azure can also manage external DNS configurations for HTTP application routing as new Ingress routes are established.
    - Service types: ClusterIP, NodePort, LoadBalancer (internal/external), ExternalName.

#### Nodes

- The k8s controller is completely managed by Azure.
- The k8s nodes are created as managed Azure VMs that run Ubuntu or Azure Linux (for a Linux cluster).
- Nodes are grouped into _node pools_, where all node VMs are the same type/size.
- The initial node pool created together with the AKS cluster is called the _system node pool_ and hosts critical system pods such as CoreDNS and konnektivity. For this reaon, the system node pool should use (at least) 3 nodes for proper redundancy for critical components.
- Additional pools may be created for different VM size requirements, additional pools can be created, called _user node pools_.
- Requirements and limitations for multiple ndoe pools:
    - Must use the Standard SKU load balancer.
    - Must use Virtual Machine Scale Sets for the nodes.
    - All nodes must reside in the same virtual network.
    - Node pool names must only contain lowercase alphanumeric characters and must begin with a letter. The name must be 1–12 characters for Linux pools and 1–6 characters for Windows pools.

#### Networking

- IPv6 support is somewhat limited, like most Azure things. Dual-stack AKS is mostly supported, but IPv6-only is not supported at all.
- IPv6 limitations (all network models):
    - Network policies: *Azure Network Policy* and *Calico* don't support dual-stack, but *Cilium* does.
    - *NAT Gateway* is not supported.
    - Virtual nodes are not supported.
    - Windows nodes pools are not supported.
    - Reverse FQDNs for _single_ public IPv6 addresses are not supported.

##### Outbound Node Networking Types

- Load balancer:
    - Default, appropriate for simple clusters.
    - Fixed SNAT ports are assigned per node.
- NAT gateway:
    - Better for high volumes of outbound connections.
    - Managed or user-assigned network.
    - Does not support IPv6 (yet)?
    - Better SNAT port handling than the load balancer.
    - Not zone redundant yet.
- User-defined routing (UDR):
    - For explicit network control.
    - Must provide a default route.

##### CNI Plugin

- Kubenet (legacy):
    - Default, but not recommended.
    - Simple/limited.
    - Doesn't provide global adressing for pods, such that direct connections between certain resources may be impossible/difficult.
    - Has okay-ish IPv6 support if used with Cilium network policy.
    - Doesn't support network policy (!).
    - Limited to 400 nodes per cluster (or 200 if dual-stack).
    - Underlay network:
        - A VNet subnet is allocated for the underlay.
        - Each node gets an address in this subnet.
    - Overlay network:
        - The cluster creation creates a private routing instance for the overlay network.
        - Pods have unrouted IP addresses and uses NAT through the node's underlay address to reach external resources.
    - IPv6 support:
        - More info: [Microsoft Learn: Use dual-stack Kubenet networking in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/configure-Kubenet-dual-stack)
        - Dual-stack support must be specified during cluster creation, using argument `--ip-families=ipv4,ipv6`. This will cause all nodes and pods to automatically get IPv6 too.
        - To enable dual-stack `LoadBalancer` services, see [this](https://learn.microsoft.com/en-us/azure/aks/configure-Kubenet-dual-stack#expose-the-workload-via-a-loadbalancer-type-service).
- Azure CNI (legacy):
    - Complex but flexible.
    - Each node and pod gets a unique IP address from a subnet within the same virtual network, yielding full connectivity within the cluster (no NAT).
    - Uses some limited form of static IP address allocation.
- Azure CNI Dynamic IP Allocation and Static Block Allocation:
    - Like Azure CNI (legacy), but with two new and more efficient IP address allocation methods. (I have no idea what other things are different.)
    - Dynamic IP Allocation: Very similar to Azure CNI (legacy), but better somehow.
    - Static Block Allocationn: Assigns IP _blocks_ to nodes on startup, allowing for better scalability.
- Azure CNI Overlay:
    - An evolved variant using private networks for pods, similar for Kubenet, allowing for greater scalability.
    - Supports up to 5 000 nodes and 250 000 nodes.
    - Allows the overlay IP space to be reused across different clusters.
    - Pods are not directly reachable from outside the cluster.
    - Supports dual-stack.
- Azure CNI Powered by Cilium (recommended):
    - Integrates with Azure CNI Dynamic/Static/Overlay and adds high-performance networking, observability and network policy enforcement.
    - Cilium is mostly orthogonal to the Azure CNI chosen, where Cilium is the dataplane and the CNI plugin will act more like an IPAM.
    - AKS manages the Cilium configuration and it can't be modified.
    - Uses the Azure CNI control plane paired with the Cilium eBPF data plane.
    - Provides the Cilium network policy engine for network policy enforcement.
    - Supports assigning IP addresses from an overlay network (like the Azure CNI Overlay mode) or from a virtual network (like the Azure CNI traditional mode).
    - Kubernetes `NetworkPolicy` resources are the recommended way to configure the policies (not `CiliumNetworkPolicy`).
    - Doesn't use `kube-proxy`.
    - Limitations:
        - Cilium L7 policy enforcement is disabled.
        - Cilium Hubble is disabled.
        - Network policies can't use `ipBlock` to allow access to node or pod IPs, use `namespaceSelector` and `podSelector` instead ([FAQ](https://learn.microsoft.com/en-us/azure/aks/azure-cni-powered-by-cilium#frequently-asked-questions)).
        - Kubernetes services with `internalTrafficPolicy=Local` aren't supported ([issue](https://github.com/cilium/cilium/issues/17796)).
        - Multiple Kubernetes services can't use the same host port with different protocols ([issue](https://github.com/cilium/cilium/issues/14287)).
        - Network policies may be enforced on reply packets when a pod connects to itself via service cluster IP ([issue](https://github.com/cilium/cilium/issues/19406) **TODO**: Fixed?).
- BYO CNI:
    - Create the luster without a CNI plugin and then install any CNI plugin that supports AKS.

##### Network Policy Engines

- Azure Network Policy Manager:
    - No IPv6 support, i.e. useless.
    - Requires the *Azure CNI* network model.
- Calico:
    - Seems OK, with some extra features.
    - Supports both the *Kubenet* and *Azure CNI* network models.
    - Supports Linux and Windows.
    - Supports all policy types.
    - Doesn't support IPv6 (?).
- Cilium:
    - Seems OK too.
    - Is used by default when using the *Azure CNI Powered by Cilium* network model.
    - Supports only Linux.
    - Supports all policy types.

#### Ingress Controllers

- General:
    - Only for HTTP-like traffic. Use a load balancer service instead for non-HTTP-like traffic.
- Managed ingress-nginx through the application routing add-on (managed).
- Azure Application Gateway for Containers (managed).
- Istio ingress gateway (managed).

### Setup (CLI Example)

Creates a public Linux AKS cluster, using dual-stack Azure CNI with Cilium networking.

Using Azure CLI and example resource names.

1. Log into Azure CLI and set an active subscription.
1. (**TODO** Maybe) Enable Cilium Preview for e.g. dual-stack support: `az feature register --namespace=microsoft.ContainerService --name=CiliumDataplanePreview`
1. Create AKS cluster: `az aks create --resource-group=test_rg --name=test_aks --tier=standard --load-balancer-sku=standard --vm-set-type=VirtualMachineScaleSets -s Standard_B2als_v2 --node-count=3 --kubernetes-version=1.29 --network-plugin=azure --network-plugin-mode=overlay --network-dataplane=cilium --ip-families=ipv4,ipv6 --pod-cidrs=172.16.0.0/16,fdfb:4d1e:98bf::/48 --service-cidrs=10.0.0.0/16,fd92:d839:1c02::/108 --os-sku=AzureLinux --generate-ssh-keys --api-server-authorized-ip-ranges=a.b.c.d/e`
    - To give the cluster identity rights to pull images from an ACR (see the optional first step), add argument `--attach-acr=<acr_id>`. You need owner/admin privileges to orchestrate this.
    - `--tier=standard` is for production. Use `free` for simple testing.
    - `--load-balancer-sku=standard` is for using the recommended load balancer variant, which is required for e.g. authorized IP ranges and multiple node pools.
    - `-s Standard_DS2_v2` is the default and has 2 vCPU, 7GiB RAM and 14GiB SSD temp storage. `Standard_B2als_v2` is a cheaper B-series alternative with 4GiB RAM.
    - `--node-count=3` creates 3 nodes if specified size. As this node pool is the _system node pool_ hosting critical pods, it' simportant to have at least 3 nodes for proper redundancy.
    - `--node-osdisk-type=Ephemeral` uses a host-local OS disk instead of a network-attached disk, yielding better performance and zero cost. This only works if the VM cache for the given size is big enough for the VM image, which is not the case for small VM sizes.
    - `--ip-families=ipv4,ipv6` enables IPv6 support (only dual-stack supported for IPv6).
    - `--api-server-authorized-ip-ranges=<cidr1>,[cidr2]...` is used to limit access to the k8s controller from any ranges you want access from. The cluster egress IP address is added to this list automatically. Up to 200 IP ranges can be specified. Does not support IPv6.
    - **TODO** "(UnsupportedDualStackNetworkPolicy) Network policy cilium is not supported for dual-stack clusters."
1. Add k8s credentials to local kubectl config: `az aks get-credentials --resource-group=test_rg --name=test_aks`
1. Check stuff:
    - Show nodes: `kubectl get nodes -o wide`
    - Show node resource usage: `kubectl top nodes`
    - Show all pods: `kubectl get pods -A -o wide`
    - Check Cilium status: `kubectl -n kube-system exec ds/cilium -- cilium status`
    - Check Cilium health: `kubectl -n kube-system exec ds/cilium -- cilium-health status`

#### TODO First

- General:
    - Best practices: https://learn.microsoft.com/en-us/azure/aks/best-practices
    - Uptime SLA?
    - "Image Cleaner" to purge old container images on ndoes.
    - Disable SSH? Can still access node through kubectl debug mode (`kubectl debug node/mynode -it --image=ubuntu`), Azure CLI run command (`az aks command invoke --resource-group=myrg --name=mycluster --command="curl -kv 127.0.0.1"`) or by reenabling SSH.
- Public/private cluster:
    - Private cluster?
    - Limit access to API server (public cluster): https://learn.microsoft.com/en-us/azure/aks/api-server-authorized-ip-ranges
- Upgrades:
    - Security patches for node OS? https://learn.microsoft.com/en-us/azure/aks/concepts-vulnerability-management#worker-nodes
    - Auto-upgrade: https://learn.microsoft.com/en-us/azure/aks/auto-upgrade-cluster
    - Kured: https://learn.microsoft.com/en-us/azure/aks/node-updates-kured
    - Check upgrade/maintenance window settings.
    - "Security Patch Channel" under "NodeOSUpgradeChannel", to replace Unattended Update. Extra cost.
- Cilium:
    - Validate status and connectivity: https://docs.cilium.io/en/latest/installation/k8s-install-aks/
    - CLI on admin host: https://docs.cilium.io/en/v1.12/gettingstarted/k8s-install-default/#install-the-cilium-cli

#### TODO Next

- General:
    - Test Cilium with IPv6 network policies.
    - Storage: https://learn.microsoft.com/en-us/azure/aks/concepts-storage
- Storage:
    - https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-storage
- Backup:
    - https://learn.microsoft.com/en-us/azure/backup/azure-kubernetes-service-backup-overview
    - https://learn.microsoft.com/en-us/azure/backup/quick-backup-aks
    - https://learn.microsoft.com/en-us/azure/backup/quick-install-backup-extension
- Automation:
    - Terraform: https://learn.microsoft.com/en-us/azure/aks/cluster-configuration#deploy-an-azure-linux-aks-cluster-with-terraform
    - Terraform with Azure Linux: https://learn.microsoft.com/en-us/azure/azure-linux/quickstart-terraform
- CI/CD:
    - GitOps/Flux v2: https://learn.microsoft.com/en-us/azure/azure-arc/kubernetes/conceptual-gitops-flux2
- Monitoring:
    - Network Observability add-on (Retina) to BYO Prometheus. Available by default? Check daemon sets. Check pre-built dashboards if not using managed Prom/Grafana.
- Security:
    - https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-network#securely-connect-to-nodes-through-a-bastion-host
    - https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-security?tabs=azure-cli
- Scheduling/isolation:
    - https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-scheduler
    - https://learn.microsoft.com/en-us/azure/aks/operator-best-practices-cluster-isolation

### Usage

Using example resource names.

- Kubernetes: See [Kubernetes](/containers/k8s/).
- Cluster:
    - Show info: `az aks show --resource-group=test_rg --name=test_aks`
    - Create: See setup example.
    - Destroy: **TODO**
    - Stop: `az aks stop --resource-group=test_rg --name=test_aks`
        - Don't repeatedly stop and start your clusters. This can result in errors. Once your cluster is stopped, you should wait at least 15-30 minutes before starting it again. (From AKS docs.)
    - Start (might regen some IP addresses): `az aks start --resource-group=test_rg --name=test_aks`
        - Check if running again: `az aks show --resource-group=test_rg --name=test_aks | jq '.powerState'`
- Node pools:
    - Show a nodepool (e.g. get VM size and count): `az aks nodepool show --resource-group=test_rg --cluster-name=test_aks --nodepool-name=nodepool1`

{% include footer.md %}
