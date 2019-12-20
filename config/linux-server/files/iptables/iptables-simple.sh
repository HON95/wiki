#!/bin/bash

# Simple IPTables script for servers.

set -eu

command -v iptables 1>/dev/null || (echo "Please install iptables." 1>&2 && exit -1)
command -v netfilter-persistent 1>/dev/null || (echo "Please install iptables-persistent and netfilter-persistent." 1>&2 && exit -1)

## Helper functions

ipt4() {
    iptables "$@" || return $?
}

ipt6() {
    ip6tables "$@" || return $?
}

ipt46() {
    ipt4 "$@" || return $?
    ipt6 "$@" || return $?
}

ipt_save() {
    netfilter-persistent save || return $?
}

## Policies
ipt46 -P INPUT DROP
ipt46 -P FORWARD DROP
ipt46 -P OUTPUT DROP

## Clear all
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

## Input Basic
# Connection tracking
ipt46 -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
ipt46 -A INPUT -m conntrack --ctstate INVALID -j DROP
# Localhost
ipt46 -A INPUT -i lo -j ACCEPT
# Ping
ipt4 -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
ipt6 -A INPUT -p icmpv6 --icmpv6-type echo-request -j ACCEPT
# NDP
ipt6 -A INPUT -p icmpv6 --icmpv6-type router-solicitation -j ACCEPT
ipt6 -A INPUT -p icmpv6 --icmpv6-type router-advertisement -j ACCEPT
ipt6 -A INPUT -p icmpv6 --icmpv6-type neighbor-solicitation -j ACCEPT
ipt6 -A INPUT -p icmpv6 --icmpv6-type neighbor-advertisement -j ACCEPT
# DHCPv6 client and server
ipt6 -A INPUT -p udp --dport 546 -j ACCEPT
ipt6 -A INPUT -p udp --dport 547 -j ACCEPT

## Input Special
# SSH
ipt46 -A INPUT -p tcp --dport 22 -j ACCEPT

## Output
# Accept all
ipt46 -A OUTPUT -j ACCEPT

## Save
ipt_save
echo "Done"
