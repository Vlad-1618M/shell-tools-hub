#!/bin/bash

# Color code definitions
cyan="\033[1;36m"
white="\033[1;37m"
yellow="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Decorative lines
decorator_init=$(echo -e "${white}$(printf '.%.0s' {1..50})${NC}")
decorator_done=$(echo -e "${white}$(printf '=%.0s' {1..65})${NC}\n")


read_selinux_config() {
    local remote_host="$1"
    echo -e "${yellow}Reading ${GREEN}/etc/selinux/config ${yellow}from ${cyan}$remote_host${NC}:"
    ssh "$remote_host" cat /etc/selinux/config | grep SELINUX
    echo
}

remote_hosts=(
    # "devuser@10.30.2.206"
    "devuser@10.30.2.208"
    "devuser@10.30.2.198"
    "devuser@10.30.2.199"
    "devuser@10.30.2.200"
    "devuser@10.30.2.201"
)

for host in "${remote_hosts[@]}"; do
    echo $decorator_init
    read_selinux_config "$host"
done
echo $decorator_done


