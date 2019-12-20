#!/bin/bash

# Firewall script for XXX.
#
# General notes:
# - ISC DHCP server uses raw sockets for DHCPv4, which bypasses the firewall.
# - DHCP responses from a server counts as established/related,
#   so responses from WAN DHCP servers with private addresses are not blocked.
# - Linux with bridge-netfilter may filter bridged traffic, meaning bridge-internal
#   traffic passes through IPTables, therefore packets forwarded from and to
#   the same bridge subnet must be accepted for bridged devices to communicate.
#
# Notes about this network and script:
# - All policies are set to DROP while updating the rules,
#   to prevent both unauthorized access (ACCEPT) and disconnects (REJECT).
# - External traffic is bogon filtered.
# - Internal traffic is source verified.
# - Both IPv4 and IPv6 is NATed.
# - Automatic rules and chains, e.g. from Docker and Fail2Ban, will be removed when this script is run.

################################################################################

set -eu

### Config

# Network subnets used to verify source
NET_LAN_SUPER=(     [4]="10.0.0.0/16"      [6]="fd00:0:0::0/48"      )
NET_CORE_MGMT=(     [4]="10.0.10.0/24"     [6]="fd00:0:0:a::0/64"    )
NET_PERF_MGMT=(     [4]="10.0.11.0/24"     [6]="fd00:0:0:b::0/64"    )
NET_APPS=(          [4]="10.0.30.0/24"     [6]="fd00:0:0:1e::0/64"   )
NET_USERS=(         [4]="10.0.100.0/24"    [6]="fd00:0:0:64::0/64"   )
NET_GUESTS=(        [4]="10.0.101.0/24"    [6]="fd00:0:0:65::0/64"   )
NET_ADMINS=(        [4]="10.0.102.0/24"    [6]="fd00:0:0:66::0/64"   )

IF_WAN="enp0s0"
IF_CORE_MGMT="enp0s0"
IF_PERF_MGMT="enp0s0"
IF_APPS="enp0s0"
IF_USERS="enp0s0"
IF_GUESTS="enp0s0"
IF_ADMINS="enp0s0"

HOST_UNIFI=(    [4]="10.0.30.7"    [6]="fd00:0:0:1e::7"   )

IPT4="iptables"
IPT6="ip6tables"
IPT_SAVE="netfilter-persistent"

################################################################################

### Helper structures

find_cmd() {
    set +e
    val=$(which $1)
    if [ -z "$val" ]; then
        echo "Error: $1 missing." 1>&2
        return -1
    fi
    echo "$val"
}

IPT4_CMD="$(find_cmd "$IPT4")"
IPT6_CMD="$(find_cmd "$IPT6")"
IPT_SAVE_CMD="$(find_cmd "$IPT_SAVE") save"

ipt4() {
    $IPT4_CMD "$@" || return $?
}

ipt6() {
    $IPT6_CMD "$@" || return $?
}

ipt46() {
    ipt4 "$@" || return $?
    ipt6 "$@" || return $?
}

ipt_save() {
  $IPT_SAVE_CMD || return $?
}

## Add accept rules for specified services the specified chain.
# Syntax: add_chain_services <chain> [service]*
add_chain_services() {
    [[ $# -lt 1 ]] && { echo "In ${FUNCNAME[0]}: Missing argument 1"; return -1; }
    chain=$1
    shift

    for srv in "$@"; do
        case "$srv" in
        # In alphabetic order
        dns)
            ipt46 -A $chain -p udp --dport 53 -j ACCEPT
            ;;
        iperf3)
            ipt46 -A $chain -p tcp --dport 5201 -j ACCEPT
            ;;
        ntopng)
            ipt46 -A $chain -p tcp --dport 3000 -j ACCEPT
            ;;
        ntp)
            ipt46 -A $chain -p udp --dport 123 -j ACCEPT
            ;;
        ping)
            ipt4 -A $chain -p icmp --icmp-type echo-request -j ACCEPT
            ipt6 -A $chain -p icmpv6 --icmpv6-type echo-request -j ACCEPT
            ;;
        ssh)
            ipt46 -A $chain -p tcp --dport 22 -j ACCEPT
            ;;
        *)
            echo "Cannot add unknown service: $srv"
            return -1
            ;;
        esac
    done
}

################################################################################

echo "Deleting existing rules and chains, then adding new ones ..."

################################################################################

### Temporary policies
ipt46 -P INPUT DROP
ipt46 -P OUTPUT DROP
ipt46 -P FORWARD DROP

################################################################################

### Clear all
# TODO whitelist to not remove all chains
ipt46 -F
ipt46 -X
ipt46 -t nat -F
ipt46 -t nat -X
ipt46 -t mangle -F
ipt46 -t mangle -X
ipt46 -t raw -F
ipt46 -t raw -X
ipt46 -t security -F
ipt46 -t security -X

################################################################################

### Filter chains

## IPv4 source bogon filter
chain="bogon-src-filter"
ipt4 -N $chain
ipt4 -A $chain -s 0.0.0.0/8 -j DROP             # "This" Network
ipt4 -A $chain -s 10.0.0.0/8 -j DROP            # Private-Use Networks
ipt4 -A $chain -s 100.64.0.0/10 -j DROP         # Shared Address Space
ipt4 -A $chain -s 127.0.0.0/8 -j DROP           # Loopback
ipt4 -A $chain -s 169.254.0.0/16 -j DROP        # Link local
ipt4 -A $chain -s 172.16.0.0/12 -j DROP         # Private-Use Networks
ipt4 -A $chain -s 192.0.0.0/24 -j DROP          # IETF Protocol Assignments
ipt4 -A $chain -s 192.0.2.0/24 -j DROP          # TEST-NET-1
ipt4 -A $chain -s 192.168.0.0/16 -j DROP        # Private-Use Networks
ipt4 -A $chain -s 198.18.0.0/15 -j DROP         # Network Interconnect Device Benchmark Testing
ipt4 -A $chain -s 198.51.100.0/24 -j DROP       # TEST-NET-2
ipt4 -A $chain -s 203.0.113.0/24 -j DROP        # TEST-NET-3
ipt4 -A $chain -s 224.0.0.0/4 -j DROP           # Multicast
ipt4 -A $chain -s 240.0.0.0/4 -j DROP           # Reserved for Future Use
ipt4 -A $chain -s 255.255.255.255/32 -j DROP    # Limited Broadcast

## IPv4 destination bogon filter
# Duplicate of source filter
chain="bogon-dst-filter"
ipt4 -N $chain
ipt4 -A $chain -d 0.0.0.0/8 -j DROP
ipt4 -A $chain -d 10.0.0.0/8 -j DROP
ipt4 -A $chain -d 100.64.0.0/10 -j DROP
ipt4 -A $chain -d 127.0.0.0/8 -j DROP
ipt4 -A $chain -d 169.254.0.0/16 -j DROP
ipt4 -A $chain -d 172.16.0.0/12 -j DROP
ipt4 -A $chain -d 192.0.0.0/24 -j DROP
ipt4 -A $chain -d 192.0.2.0/24 -j DROP
ipt4 -A $chain -d 192.168.0.0/16 -j DROP
ipt4 -A $chain -d 198.18.0.0/15 -j DROP
ipt4 -A $chain -d 198.51.100.0/24 -j DROP
ipt4 -A $chain -d 203.0.113.0/24 -j DROP
ipt4 -A $chain -d 224.0.0.0/4 -j DROP
ipt4 -A $chain -d 240.0.0.0/4 -j DROP
ipt4 -A $chain -d 255.255.255.255/32 -j DROP

## IPv6 source bogon filter
chain="bogon-src-filter"
ipt6 -N $chain
ipt6 -A $chain -s ::/8 -j DROP                  # Unspecified, loopback and compatible and mapped IPv4
# Covered
#ipt6 -A $chain -s ::/128 -j DROP               # Unspecified
#ipt6 -A $chain -s ::1/128 -j DROP              # Loopback
#ipt6 -A $chain -s ::/96 -j DROP                # IPv4-compatible
#ipt6 -A $chain -s ::ffff:0:0/96 -j DROP        # IPv4-mapped
ipt6 -A $chain -s 64:ff9b::/96 -j DROP          # IPv4-IPv6 Translation
ipt6 -A $chain -s 100::/64 -j DROP              # Discard-Only
ipt6 -A $chain -s 200::/7 -j DROP               # OSI NSAP-mapped prefix set (deprecated)
ipt6 -A $chain -s 2001::/23 -j DROP             # IETF Protocol Assignments
# Covered
#ipt6 -A $chain -s 2001::/32 -j DROP            # TEREDO
ipt6 -A $chain -s 2001:2::/48 -j DROP           # Benchmarking
ipt6 -A $chain -s 2001:db8::/32 -j DROP         # Documentation
ipt6 -A $chain -s 2001:10::/28 -j DROP          # ORCHID
ipt6 -A $chain -s 2002::/16 -j DROP             # All 6to4
ipt6 -A $chain -s 3ffe::/16 -j DROP             # 6bone (decommissioned)
ipt6 -A $chain -s fc00::/7 -j DROP              # Unique-Local
ipt6 -A $chain -s fe80::/10 -j DROP             # Linked-Scoped Unicast
ipt6 -A $chain -s fec0::/10 -j DROP             # Site-local unicast (deprecated)
ipt6 -A $chain -s ff00::/8 -j DROP              # Multicast (includes solicited-node)

## IPv6 destination bogon filter
# Duplicate of source filter
chain="bogon-dst-filter"
ipt6 -N $chain
ipt6 -A $chain -d ::/8 -j DROP
ipt6 -A $chain -d 64:ff9b::/96 -j DROP
ipt6 -A $chain -d 100::/64 -j DROP
ipt6 -A $chain -d 200::/7 -j DROP
ipt6 -A $chain -d 2001::/23 -j DROP
ipt6 -A $chain -d 2001:2::/48 -j DROP
ipt6 -A $chain -d 2001:db8::/32 -j DROP
ipt6 -A $chain -d 2001:10::/28 -j DROP
ipt6 -A $chain -d 2002::/16 -j DROP
ipt6 -A $chain -d 3ffe::/16 -j DROP
ipt6 -A $chain -d fc00::/7 -j DROP
ipt6 -A $chain -d fe80::/10 -j DROP
ipt6 -A $chain -d fec0::/10 -j DROP
ipt6 -A $chain -d ff00::/8 -j DROP

################################################################################

### Input

## Input basic
ipt46 -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ipt46 -A INPUT -m conntrack --ctstate INVALID -j DROP
# IPv6 NDP
ipt6 -A INPUT -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
ipt6 -A INPUT -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
ipt6 -A INPUT -p icmpv6 --icmpv6-type neighbor-solicitation -j ACCEPT
ipt6 -A INPUT -p icmpv6 --icmpv6-type neighbor-advertisement -j ACCEPT
# DHCPv6 client+server (v6 doesn't use raw sockets)
ipt6 -A INPUT -p udp --dport 546 -j ACCEPT
ipt6 -A INPUT -p udp --dport 547 -j ACCEPT

## Input from localhost
ipt46 -A INPUT -i lo -j ACCEPT

## Input from wan
chain="in-from-wan"
echo $chain
ipt46 -N $chain
ipt46 -A INPUT -i $IF_WAN -j $chain
# Bogon filter src
ipt46 -A $chain -j bogon-src-filter
# Drop external traffic from internal addresses
ipt4 -A $chain -s ${NET_LAN_SUPER[4]} -j DROP # IPv4
ipt6 -A $chain -s ${NET_LAN_SUPER[6]} -j DROP # IPv6
# Services
add_chain_services $chain ping
# Default action
ipt46 -A $chain -j DROP

## Input from core-mgmt
chain="in-from-core-mgmt"
echo $chain
ipt46 -N $chain
ipt46 -A INPUT -i $IF_CORE_MGMT -j $chain
ipt4 -A $chain ! -s ${NET_CORE_MGMT[4]} -j DROP # IPv4
ipt6 -A $chain ! -s ${NET_CORE_MGMT[6]} -j DROP # IPv6
add_chain_services $chain ping dns ntp iperf3 ssh ntopng
ipt46 -A $chain -j REJECT

## Input from perf-mgmt
chain="in-from-perf-mgmt"
echo $chain
ipt46 -N $chain
ipt46 -A INPUT -i $IF_PERF_MGMT -j $chain
ipt4 -A $chain ! -s ${NET_PERF_MGMT[4]} -j DROP # IPv4
ipt6 -A $chain ! -s ${NET_PERF_MGMT[6]} -j DROP # IPv6
add_chain_services $chain ping dns ntp iperf3
ipt46 -A $chain -j REJECT

## Input from apps
chain="in-from-apps"
echo $chain
ipt46 -N $chain
ipt46 -A INPUT -i $IF_APPS -j $chain
ipt4 -A $chain ! -s ${NET_APPS[4]} -j DROP # IPv4
ipt6 -A $chain ! -s ${NET_APPS[6]} -j DROP # IPv6
add_chain_services $chain ping dns ntp
ipt46 -A $chain -j REJECT

## Input from users
chain="in-from-users"
echo $chain
ipt46 -N $chain
ipt46 -A INPUT -i $IF_USERS -j $chain
ipt4 -A $chain ! -s ${NET_USERS[4]} -j DROP # IPv4
ipt6 -A $chain ! -s ${NET_USERS[6]} -j DROP # IPv6
add_chain_services $chain ping dns ntp iperf3
ipt46 -A $chain -j REJECT

## Input from guest
chain="in-from-guests"
echo $chain
ipt46 -N $chain
ipt46 -A INPUT -i $IF_GUESTS -j $chain
ipt4 -A $chain ! -s ${NET_GUESTS[4]} -j DROP # IPv4
ipt6 -A $chain ! -s ${NET_GUESTS[6]} -j DROP # IPv6
add_chain_services $chain ping dns ntp
ipt46 -A $chain -j REJECT

## Input from admins
chain="in-from-admins"
echo $chain
ipt46 -N $chain
ipt46 -A INPUT -i $IF_ADMINS -j $chain
ipt4 -A $chain ! -s ${NET_ADMINS[4]} -j DROP # IPv4
ipt6 -A $chain ! -s ${NET_ADMINS[6]} -j DROP # IPv6
add_chain_services $chain ping dns ntp iperf3 ssh ntopng
ipt46 -A $chain -j REJECT

################################################################################

### Output

## Output basic
ipt46 -A OUTPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ipt46 -A OUTPUT -m conntrack --ctstate INVALID -j DROP
# IPv6 NDP
ipt6 -A OUTPUT -p icmpv6 --icmpv6-type neighbor-solicitation -j ACCEPT
ipt6 -A OUTPUT -p icmpv6 --icmpv6-type neighbor-advertisement -j ACCEPT

## Output to localhost
ipt46 -A OUTPUT -o lo -j ACCEPT

## Output to WAN
chain="out-to-wan"
echo $chain
ipt46 -N $chain
ipt46 -A OUTPUT -o $IF_WAN -j $chain
# Block LAN leakage
ipt4 -A $chain -d ${NET_LAN_SUPER[4]} -j DROP # IPv4
ipt6 -A $chain -d ${NET_LAN_SUPER[6]} -j DROP # IPv6
# Default action
ipt46 -A $chain -j ACCEPT

## Output to LAN
chain="out-to-lan"
echo $chain
ipt46 -N $chain
ipt46 -A OUTPUT -o $IF_CORE_MGMT -j $chain
ipt46 -A OUTPUT -o $IF_PERF_MGMT -j $chain
ipt46 -A OUTPUT -o $IF_APPS -j $chain
ipt46 -A OUTPUT -o $IF_USERS -j $chain
ipt46 -A OUTPUT -o $IF_GUESTS -j $chain
ipt46 -A OUTPUT -o $IF_ADMINS -j $chain
ipt46 -A $chain -j ACCEPT

################################################################################

### Forward

## Forward basic
ipt46 -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ipt46 -A FORWARD -m conntrack --ctstate INVALID -j DROP

## Verify source for stub LANs
ipt4 -A FORWARD -i $IF_CORE_MGMT ! -s ${NET_CORE_MGMT[4]} -j DROP
ipt6 -A FORWARD -i $IF_CORE_MGMT ! -s ${NET_CORE_MGMT[6]} -j DROP
ipt4 -A FORWARD -i $IF_PERF_MGMT ! -s ${NET_PERF_MGMT[4]} -j DROP
ipt6 -A FORWARD -i $IF_PERF_MGMT ! -s ${NET_PERF_MGMT[6]} -j DROP
ipt4 -A FORWARD -i $IF_APPS ! -s ${NET_APPS[4]} -j DROP
ipt6 -A FORWARD -i $IF_APPS ! -s ${NET_APPS[6]} -j DROP
ipt4 -A FORWARD -i $IF_USERS ! -s ${NET_USERS[4]} -j DROP
ipt6 -A FORWARD -i $IF_USERS ! -s ${NET_USERS[6]} -j DROP
ipt4 -A FORWARD -i $IF_GUESTS ! -s ${NET_GUESTS[4]} -j DROP
ipt6 -A FORWARD -i $IF_GUESTS ! -s ${NET_GUESTS[6]} -j DROP
ipt4 -A FORWARD -i $IF_ADMINS ! -s ${NET_ADMINS[4]} -j DROP
ipt6 -A FORWARD -i $IF_ADMINS ! -s ${NET_ADMINS[6]} -j DROP

## Forward from wan
chain="fwd-from-wan"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -i $IF_WAN -j $chain
# Bogon filter src and dst addresses
ipt46 -A $chain -j bogon-src-filter
ipt46 -A $chain -j bogon-dst-filter
# Drop external traffic from internal addresses
ipt4 -A $chain -s ${NET_LAN_SUPER[4]} -j DROP # IPv4
ipt6 -A $chain -s ${NET_LAN_SUPER[6]} -j DROP # IPv6
# Drop external traffic to internal addresses (because NAT44 + NAT66)
ipt4 -A $chain -d ${NET_LAN_SUPER[4]} -j DROP # IPv4
ipt6 -A $chain -d ${NET_LAN_SUPER[6]} -j DROP # IPv6
# Return

## Forward to wan
chain="fwd-to-wan"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -o $IF_WAN -j $chain
# Block LAN leakage
ipt4 -A $chain -d ${NET_LAN_SUPER[4]} -j DROP # IPv4
ipt6 -A $chain -d ${NET_LAN_SUPER[6]} -j DROP # IPv6
# LANs
ipt46 -A $chain -i $IF_CORE_MGMT        -j ACCEPT
ipt46 -A $chain -i $IF_PERF_MGMT        -j ACCEPT
ipt46 -A $chain -i $IF_APPS             -j ACCEPT
ipt46 -A $chain -i $IF_USERS            -j ACCEPT
ipt46 -A $chain -i $IF_GUESTS           -j ACCEPT
ipt46 -A $chain -i $IF_ADMINS           -j ACCEPT
# Default action
ipt46 -A $chain -j DROP

## Forward to core-mgmt
chain="fwd-to-core-mgmt"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -o $IF_CORE_MGMT -j $chain
# LANs
ipt46 -A $chain -i $IF_CORE_MGMT        -j ACCEPT # Self
ipt46 -A $chain -i $IF_PERF_MGMT        -j REJECT
ipt46 -A $chain -i $IF_APPS             -j REJECT
ipt46 -A $chain -i $IF_USERS            -j REJECT
ipt46 -A $chain -i $IF_GUESTS           -j REJECT
ipt46 -A $chain -i $IF_ADMINS           -j ACCEPT # Admin
# Default action
ipt46 -A $chain -j DROP

## Forward to perf-mgmt
chain="fwd-to-perf-mgmt"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -o $IF_PERF_MGMT -j $chain
# LANs
ipt46 -A $chain -i $IF_CORE_MGMT        -j REJECT
ipt46 -A $chain -i $IF_PERF_MGMT        -j ACCEPT # Self
ipt46 -A $chain -i $IF_APPS             -j REJECT
ipt46 -A $chain -i $IF_USERS            -j REJECT
ipt46 -A $chain -i $IF_GUESTS           -j REJECT
ipt46 -A $chain -i $IF_ADMINS           -j ACCEPT # Admin
# Default action
ipt46 -A $chain -j DROP

## Forward to apps
chain="fwd-to-apps"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -o $IF_APPS -j $chain
# UniFi: From APs to controller
ipt4 -A $chain -i $IF_PERF_MGMT -d ${HOST_UNIFI[4]} -p tcp --dport=8080 -j ACCEPT # IPv4
ipt6 -A $chain -i $IF_PERF_MGMT -d ${HOST_UNIFI[6]} -p tcp --dport=8080 -j ACCEPT # IPv6
ipt4 -A $chain -i $IF_PERF_MGMT -d ${HOST_UNIFI[4]} -p udp --dport=3478 -j ACCEPT # IPv4
ipt6 -A $chain -i $IF_PERF_MGMT -d ${HOST_UNIFI[6]} -p udp --dport=3478 -j ACCEPT # IPv6
# LANs
ipt46 -A $chain -i $IF_CORE_MGMT        -j REJECT
ipt46 -A $chain -i $IF_PERF_MGMT        -j REJECT
ipt46 -A $chain -i $IF_APPS             -j ACCEPT # Self
ipt46 -A $chain -i $IF_USERS            -j REJECT
ipt46 -A $chain -i $IF_GUESTS           -j REJECT
ipt46 -A $chain -i $IF_ADMINS           -j ACCEPT # Admin
# Default action
ipt46 -A $chain -j DROP

## Forward to users
chain="fwd-to-users"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -o $IF_USERS -j $chain
# LANs
ipt46 -A $chain -i $IF_CORE_MGMT        -j REJECT
ipt46 -A $chain -i $IF_PERF_MGMT        -j REJECT
ipt46 -A $chain -i $IF_APPS             -j REJECT
ipt46 -A $chain -i $IF_USERS            -j ACCEPT # Self
ipt46 -A $chain -i $IF_GUESTS           -j REJECT
ipt46 -A $chain -i $IF_ADMINS           -j ACCEPT # Admin

## Forward to guests
chain="fwd-to-guests"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -o $IF_GUESTS -j $chain
# LANs
ipt46 -A $chain -i $IF_CORE_MGMT        -j REJECT
ipt46 -A $chain -i $IF_PERF_MGMT        -j REJECT
ipt46 -A $chain -i $IF_APPS             -j REJECT
ipt46 -A $chain -i $IF_USERS            -j ACCEPT # Allow
ipt46 -A $chain -i $IF_GUESTS           -j REJECT # Self, client isolation
ipt46 -A $chain -i $IF_ADMINS           -j ACCEPT # Admin

## Forward to admins
chain="fwd-to-admins"
echo $chain
ipt46 -N $chain
ipt46 -A FORWARD -o $IF_ADMINS -j $chain
# LANs
ipt46 -A $chain -i $IF_CORE_MGMT        -j REJECT
ipt46 -A $chain -i $IF_PERF_MGMT        -j REJECT
ipt46 -A $chain -i $IF_APPS             -j REJECT
ipt46 -A $chain -i $IF_USERS            -j REJECT
ipt46 -A $chain -i $IF_GUESTS           -j REJECT
ipt46 -A $chain -i $IF_ADMINS           -j ACCEPT # Self, admin

################################################################################

### NAT

## SNAT + masquerade
ipt4 -t nat -A POSTROUTING -o $IF_WAN -j MASQUERADE # IPv4
ipt6 -t nat -A POSTROUTING -o $IF_WAN -j MASQUERADE # IPv6

## DNAT + port Forward
# Port range for direct-wan: 50000-50999
# Forward HTTP+HTTPS to Nginx container
#ipt4 -t nat -A PREROUTING -i $IF_PUBLIC_WAN -p tcp -m multiport --dports 80,443 -j DNAT --to-destination ${HOST_NGINX_MASTER[4]}
#ipt6 -t nat -A PREROUTING -i $IF_PUBLIC_WAN -p tcp -m multiport --dports 80,443 -j DNAT --to-destination ${HOST_NGINX_MASTER[6]}

################################################################################

### Final policies
ipt46 -P INPUT DROP
ipt46 -P OUTPUT DROP
ipt46 -P FORWARD DROP

################################################################################

### Finish
num_rules=$(iptables -n --list --line-numbers | sed '/^num\|^$\|^Chain/d' | wc -l)
echo
# TODO chain count
echo "Rule count: $num_rules"
echo
echo "Please verify that you have not locked yourself out!"
echo "Try opening another SSH session."
echo "This can not easily be undone!"
echo

finished=false
while [[ $finished != true ]]; do
    echo "Save running config to startup config?"
    read -p "Type \"YES\" to continue or CTRL+C to abort: " input
    if [[ $input == "YES" ]]; then
        finished=true
    else
        echo "Invalid input, try again."
    fi
done

ipt_save
echo "Updated iptables startup config"
