#!/bin/bash

###################################################################################
# Script:  selinux_check.sh
#  Purpose: Reads SELinux configurations from remote hosts listed in hosts.cfg
#  Description:
#       - Reads a list of remote hosts from 'hosts.cfg'
#       - Ensures SSH keys are added to remote hosts if needed
#       - Fetches SELinux configuration from each host
#       - Handles SSH fingerprints and authentication
#
#   Prerequisites:
#       - Requires sudo/root privileges:
#
###################################################################################

# ... color formatting for warnings:
cyan="\033[1;36m"
white="\033[1;37m"
yellow="\033[1;33m"
green="\033[0;32m"
red="\033[0;31m"
off="\033[0m"  # No Color

# ... decorators: for visual separation in output
decorator_init=$(echo -e "${white}$(printf '.%.0s' {1..50})${off}")
decorator_done=$(echo -e "${white}$(printf '=%.0s' {1..65})${off}\n")

# ... hosts.cfg or alternative configuration file path:
CONFIG_FILE="src/for_network/cfgs/hosts.cfg"

# ... file exists check | is readable check:
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "\n${red}Error: Configuration file '$CONFIG_FILE' not found!${off}"
    exit 1
fi

# ... config file data read:
remote_hosts=()
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue  # ... skip comments | empty lines:
    remote_hosts+=("$line")
done < "$CONFIG_FILE"
# mapfile -t remote_hosts < "$CONFIG_FILE"

# ... add SSH key | handle fingerprints:
setup_ssh_access() {
    local host="$1"
    
    # ... scan | add host + fingerprint to known_hosts file:
    echo -e "${yellow}Checking SSH fingerprint for ${cyan}$host${off}..."
    ssh-keyscan -H "$host" >> ~/.ssh/known_hosts 2>/dev/null
    
    # ... copy SSH key to remote host: reduce auth ask for the next ssh sessions
    echo -e "${yellow}Ensuring SSH key is copied to ${cyan}$host${off}..."
    ssh-copy-id -o StrictHostKeyChecking=no "$host" 2>/dev/null
    echo -e "${green}SSH access setup complete for ${cyan}$host${off}.\n"
}

# ... read SELinux policy:
read_selinux_config() {
    local host="$1"
    echo -e "${yellow}Reading ${green}/etc/selinux/config ${yellow}from ${cyan}$host${off}:"
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


