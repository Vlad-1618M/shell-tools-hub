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


remote_hosts=(
    # "devuser@10.30.2.206"
    # "devuser@10.30.2.208"
    # "devuser@10.30.2.198"
    # "devuser@10.30.2.199"
    # "devuser@10.30.2.200"
    # "devuser@10.30.2.201"
)

# ... check for existing SSH keys
ssh_key="$HOME/.ssh/id_rsa"
if [ ! -f "$ssh_key" ]; then
    echo "SSH key not found, creating one..."
    ssh-keygen -t rsa -b 2048 -f "$ssh_key" -N ""
fi

# ... copy SSH key and make initial connection
setup_ssh() {
    local remote_host=$1

    # .. SSH key copy
    echo "Copying SSH key to $remote_host..."
    ssh-copy-id -i "${ssh_key}.pub" $remote_host

    # ... Init connection and add host to known_hosts
    echo "Making initial connection to verify server fingerprint and add to known_hosts..."
    ssh -o StrictHostKeyChecking=accept-new $remote_host
}

# ... setup SSH loop
for host in "${remote_hosts[@]}"; do
    setup_ssh "$host"
done
