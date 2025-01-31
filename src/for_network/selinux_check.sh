#!/bin/bash

###################################################################################
# Script:  selinux_check.sh
# Purpose: Reads SELinux configurations from remote hosts listed in hosts.cfg
#   Description:
#       - Reads a list of remote hosts from 'hosts.cfg'
#       - Ensures SSH keys are added to remote hosts if needed
#       - Fetches SELinux configuration from each host
#       - Handles SSH fingerprints and authentication

###################################################################################

# ... color formatting for warnings:
cyan="\033[1;36m"
white="\033[1;37m"
yellow="\033[1;33m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# ... decorators: for visual separation in output
decorator_init=$(echo -e "${white}$(printf '.%.0s' {1..50})${NC}")
decorator_done=$(echo -e "${white}$(printf '=%.0s' {1..65})${NC}\n")

# ... hosts.cfg or alternative configuration file path:
CONFIG_FILE="shell-tools-hub/src/for_network/cfgs/hosts.cfg"

# ... file exists check | is readable check:
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "${RED}Error: Configuration file '$CONFIG_FILE' not found!${NC}"
    exit 1
fi

# ... config file data read:
mapfile -t remote_hosts < "$CONFIG_FILE"

# ... add SSH key | handle fingerprints:
setup_ssh_access() {
    local host="$1"
    
    # ... scan | add host + fingerprint to known_hosts file:
    echo -e "${yellow}Checking SSH fingerprint for ${cyan}$host${NC}..."
    ssh-keyscan -H "$host" >> ~/.ssh/known_hosts 2>/dev/null
    
    # ... copy SSH key to remote host: reduce auth ask for the next ssh sessions
    echo -e "${yellow}Ensuring SSH key is copied to ${cyan}$host${NC}..."
    ssh-copy-id -o StrictHostKeyChecking=no "$host" 2>/dev/null
    echo -e "${GREEN}SSH access setup complete for ${cyan}$host${NC}.\n"
}

# ... read SELinux policy:
read_selinux_config() {
    local host="$1"
    echo -e "${yellow}Reading ${GREEN}/etc/selinux/config ${yellow}from ${cyan}$host${NC}:"
    ssh "$host" cat /etc/selinux/config | grep SELINUX
    echo
}

# ... host addr loop:
for host in "${remote_hosts[@]}"; do
    echo "$decorator_init"
    
    # Ensure SSH key is added before fetching SELinux config
    setup_ssh_access "$host"
    
    # Fetch SELinux configuration
    read_selinux_config "$host"
done

echo "$decorator_done"


