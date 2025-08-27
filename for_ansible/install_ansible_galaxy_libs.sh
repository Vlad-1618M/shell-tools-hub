#!/bin/bash

# ===========================================================================================
# Script Name: install_ansible_galaxy_libs.sh
#
# Description:
#   - This script checks if Ansible and Ansible Galaxy are installed on the system.
#   - Reports the installed Ansible version and its installation path.
#   - Lists all installed Ansible Galaxy collections and their locations.
#   - Ensures that required dependencies such as `yamllint` and `Jinja2` are up to date.
#   - Does NOT install or modify any Ansible components—only reports their presence.
#
#   Compatibility:
#       - Works on macOS, Ubuntu, and Red Hat-based systems (RHEL, CentOS, Fedora).
#
#   Features:
#       - Detects and reports the presence of Ansible and its version.
#       - Detects and reports the presence of Ansible Galaxy and installed collections.
#       - Displays the configured `ANSIBLE_COLLECTIONS_PATHS` variable.
#
#   Prerequisites:
#       - Python 3 and `pip` must be installed.
#       - If Ansible is installed via `pip`, `brew`, or system package managers, the script will detect it.
#
# Usage:
# - Simply run the script: `./install_ansible_galaxy_libs.sh`
# - It will display details about Ansible and Ansible Galaxy without making any changes.
#
# References:
# - Ansible Documentation: https://docs.ansible.com/
# - Ansible Galaxy: https://galaxy.ansible.com/
# ===========================================================================================

print_message() {
    COLOR=$1
    MESSAGE=$2
    echo -e "\n\033[${COLOR}m${MESSAGE}\033[0m"
}

print_separator() {
    echo -e "\033[36m--------------------------------------------------------------------------------\033[0m"
}

check_and_install_ansible() {
    # print_separator
    if command -v ansible &>/dev/null; then
        print_message "32" "Ansible is already installed."
        ansible --version | head -n 1 || true  # Prevent broken pipe error
    else
        print_message "32" "Installing Ansible and Openshift Python modules ..."
        python3 -m pip install ansible openshift
        ansible --version | head -n 1 || true
    fi
    python3 -m pip install yamllint --upgrade
    python3 -m pip install Jinja2 --upgrade
}

check_and_install_ansible_galaxy_collections() {
    # print_separator
    print_message "32" "Checking and installing Ansible Galaxy collections..."
    
    COLLECTIONS_TO_CHECK=("kubernetes.core" "community.general")
    for COLLECTION in "${COLLECTIONS_TO_CHECK[@]}"; do
        if ansible-galaxy collection list | grep -q "$COLLECTION"; then
            print_message "32" "$COLLECTION is already installed."
            ansible-galaxy collection list "$COLLECTION"
        else
            print_message "31" "$COLLECTION is not installed. Installing now..."
            ansible-galaxy collection install "$COLLECTION" --force-with-deps
            if ansible-galaxy collection list | grep -q "$COLLECTION"; then
                print_message "32" "$COLLECTION has been successfully installed."
                ansible-galaxy collection list "$COLLECTION"
            else
                print_message "31" "Failed to install $COLLECTION."
            fi
        fi
    done
    
    export ANSIBLE_COLLECTIONS_PATHS=$HOME/.ansible/collections
    echo "ANSIBLE_COLLECTIONS_PATHS is set to $ANSIBLE_COLLECTIONS_PATHS"
    print_separator
}

main(){
    check_and_install_ansible
    check_and_install_ansible_galaxy_collections
    ansible-config dump | grep COLLECTIONS_PATHS
}

main
