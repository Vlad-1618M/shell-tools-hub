#!/bin/bash

# ======================================================================================================
#               SSH Key Setup Script [ Supports Ed25519 & RSA ]
# -----------------------------------------------------------------------------
#   This script automates SSH key-based authentication setup for remote hosts:
#   It performs the following actions:
#       1. Checks for an existing SSH key [ if not RSA | Ed25519 preferred ]
#       2. Generates a new SSH key if one does not exist:
#       3. Reads remote hosts dynamically from `ssh.cfg` one by one per each line in cfg:
#       4. Copies the SSH key to each remote host to enable passwordless login:
#       5. Establishes an initial SSH connection to verify server fingerprints:
#
# ======================================================================================================
#   Instructions:
#       1. Edit `ssh.cfg` and add the remote hosts: [ format: username@IP_or_Hostname ]
#       2. Ensure you have SSH access to the remote hosts (e.g., firewall & security rules allow SSH)
#       3. Run this script: `bash setup_ssh_keys.sh` to configure SSH authentication.
#
# ======================================================================================================
#   SSH Key Information:
#     * --> Ed25519      [ Recommended ] | Faster, more secure, and smaller key size:
#     * --> RSA 4096-bit [ Fallback    ] | Good for compatibility with older systems:
#     - If no key is found, the script generates a new Ed25519 key by default:
#     - The public key is copied to remote servers using `ssh-copy-id`
#
# ======================================================================================================
#
#    Compatibility:
#       Works on Linux & macOS
#       Avoids `mapfile` (uses `while read` for better shell compatibility)
#       Supports public & private cloud instances: [ AWS, Azure, On-Premises ]
#
# ======================================================================================================

# ... color vars used in Output Formatting:
gray='\033[1;90m'
white='\033[1;97m'
yellow='\033[1;93m'
green='\033[1;92m'
orange='\033[1;91m'
magenta='\033[1;95m'
cyan='\033[1;96m'
red="\033[1;31m"
off="\033[0m"

# ... decorators: for visual separation in output
decorator_init="echo -e ${gray}$(printf '_%.0s' {1..111})${off}"
decorator_done="echo -e ${white}$(printf '=%.0s' {1..111})${off}\n"

# ... SSH key configuration:
SSH_DIR="$HOME/.ssh"
ED25519_KEY="$SSH_DIR/id_ed25519"
RSA_KEY="$SSH_DIR/id_rsa"
CONFIG_FILE="src/for_network/cfgs/ssh.cfg"

# ... cfg file check:
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo -e "\n${red}Error:${off} config file ${gray}'$CONFIG_FILE' ${red}not found!${off}"
    exit 1
fi

# ... read hosts:
remote_hosts=()
while IFS= read -r line || [[ -n "$line" ]]; do
    [[ "$line" =~ ^#.*$ || -z "$line" ]] && continue  # ... skip comments | empty lines:
    remote_hosts+=("$line")
done < "$CONFIG_FILE"

# ...check existing SSH key | Ed25519 preferred | if not use RSA:
if [[ -f "$ED25519_KEY" ]]; then
    SSH_KEY="$ED25519_KEY"
    KEY_TYPE="Ed25519"
elif [[ -f "$RSA_KEY" ]]; then
    SSH_KEY="$RSA_KEY"
    KEY_TYPE="RSA"
else
    # ... generate a new SSH key:
    echo -e "${yellow}No SSH key found. Generating a new one...${off}"
    if ssh-keygen -t ed25519 -f "$ED25519_KEY" -N ""; then
        SSH_KEY="$ED25519_KEY"
        KEY_TYPE="Ed25519"
    else
        echo -e "${red}Failed to generate Ed25519 key. Falling back to RSA...${off}"
        ssh-keygen -t rsa -b 4096 -f "$RSA_KEY" -N ""
        SSH_KEY="$RSA_KEY"
        KEY_TYPE="RSA"
    fi
fi

$decorator_init
echo -e "${green}Using ${cyan}$KEY_TYPE${green} key at ${cyan}$SSH_KEY${off}\n"

# ... set up SSH access:
setup_ssh() {
    local remote_host=$1
    echo -e "${yellow}Copying SSH key to ${cyan}$remote_host${off}...\n"
    ssh-copy-id -i "${SSH_KEY}.pub" "$remote_host"
    echo -e "${yellow}Making initial connection to verify server fingerprint${off}...\n"
    $decorator_init
    ssh -o StrictHostKeyChecking=accept-new "$remote_host" "echo 'SSH setup complete for $remote_host'"
}

# ... cfg hosts Loop | set up SSH:
for host in "${remote_hosts[@]}"; do
    setup_ssh "$host"
done

$decorator_done
echo -e "${green}SSH key setup completed for all hosts.${off}"
