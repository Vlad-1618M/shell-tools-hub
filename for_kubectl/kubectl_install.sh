#!/bin/bash

# ===================================================================================
# Script Name: kubectl_install.sh
# Description: 
#   - Checks if kubectl is installed. If not, prompts the user to install it.
#   - Searches for kubeconfig files based on user input.
#   - Provides indexed path selection for the search.
#   - Displays file details (size, age).
#   - Prompts to set the KUBE environment variable and validates per user selections: 
#
# Compatibility: Linux (Ubuntu, RHEL, Debian) & macOS (default shell)
# ===================================================================================

# ... set kubeconfig search locations:
KUBE_SRC="$HOME/"

# ... print messages | in color:
print_message() {
    COLOR=$1
    MESSAGE=$2
    echo -e "\033[${COLOR}m${MESSAGE}\033[0m"
}

# ... print line for visual separation in output:
print_separator() {
    echo -e "\033[36m--------------------------------------------------------------------------------\033[0m"
}

# ... check if kubectl is installed:
check_kubectl() {
    if command -v kubectl >/dev/null 2>&1; then
        print_separator
        print_message "32" "Kubectl is already installed."
        kubectl_version=$(kubectl version kubectl version --client -o yaml 2>/dev/null)
        if [[ -n "$kubectl_version" ]]; then
            print_message "37" "Version: \033[36m${kubectl_version}\033[0m"
        else
            print_message "31" "Unable to determine Kubectl version!"
        fi
        print_separator
        return 0  # ... success | kubectl already exists:
    else
        print_message "33" "Kubectl is not installed."
        return 1  # .. failure | missing kubectl:
    fi
}

# ... install kubectl from its src:
install_kubectl() {
    print_separator
    print_message "33" "Do you want to install Kubectl? (yes/no)"
    read response
    case "$response" in
        [Yy]*)
            ;;
        *)
            print_message "31" "Skipping Kubectl installation."
            return 1  # ... failure skipped installation:
            ;;
    esac

    print_separator
    print_message "32" "Installing Kubectl..."
    
    KUBECTL_URL="https://dl.k8s.io/release/$(curl -sL https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    
    if curl -LO "$KUBECTL_URL"; then
        chmod +x ./kubectl
        sudo mv ./kubectl /usr/local/bin/kubectl
        print_message "32" "Kubectl installation completed."
        return 0  # ... success | installed kubectl:
    else
        print_message "31" "Failed to download kubectl. Please check your network connection."
        return 1  # ... exit 1 | download failed:
    fi
}

# ... search for kubeconfig files:
search_kubeconfig() {
    print_separator
    print_message "33" "... search for a kubeconfig file on this system ? (yes/no)"
    read response
    case "$response" in
        [Yy]*)
            ;;
        *)
            print_message "31" "\t --> ... skipping kubeconfig search:"
            return
            ;;
    esac

    # ... set search paths
    cwd=$(pwd)
    up_one=$(dirname "$cwd")
    down_one=$(find "$cwd" -mindepth 1 -type d | head -n 1)
    if [[ -z "$down_one" ]]; then
        down_one="$cwd"  # ... if no subdirectories exist | go back to cwd:
    fi

    # ... show indexed paths:
    print_message "36" "... where am I searching in ? select a search path location:"
    echo -e "  [1] Current Directory:\t-> \033[32m$cwd\033[0m"
    echo -e "  [2] One Directory Up:\t\t-> \033[32m$up_one\033[0m"
    echo -e "  [3] One Directory Down:\t-> \033[32m$down_one\033[0m"
    read -p "Select path index to search in: (1, 2, 3): " selection

    case "$selection" in
        1) search_path="$cwd" ;;
        2) search_path="$up_one" ;;
        3) search_path="$down_one" ;;
        *) print_message "31" "Invalid selection! Exiting..."; exit 1 ;;
    esac

    print_separator
    print_message "37" "Searching for kubeconfig files in: \033[35m$search_path\033[0m"

    # ... find kubeconfig files:
    kubeconfig_file=$(find "$search_path" -type f \( -name "kubeconfig.yml" -o -name "kubeconfig.yaml" \) 2>/dev/null | head -n 1)

    if [[ -z "$kubeconfig_file" ]]; then
        print_message "31" "No kubeconfig file found in $search_path"
        return
    fi

    # ... file details [ cross-platform handling ]
    if [[ "$(uname)" == "Darwin" ]]; then
        file_size=$(stat -f%z "$kubeconfig_file")
        file_age=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$kubeconfig_file")
    else
        file_size=$(stat --format=%s "$kubeconfig_file")
        file_age=$(stat --format='%y' "$kubeconfig_file")
    fi

    print_separator
    print_message "37" "Kubeconfig File Found:"
    print_message "32" "Path: \033[36m$kubeconfig_file\033[0m"
    print_message "32" "Size: \033[33m$file_size bytes\033[0m"
    print_message "32" "Last Modified: \033[33m$file_age\033[0m"
    print_separator

    # ... user prompt | set KUBE environment variable:
    print_message "33" "Do you want to set the KUBE environment variable to this file? (yes/no)"
    read set_env
    case "$set_env" in
        [Yy]*)
            export KUBE="$kubeconfig_file"
            print_message "32" "KUBE variable set to: \033[36m$KUBE\033[0m"
            validate_kubeconfig
            ;;
        *)
            print_message "31" "Skipping KUBE environment variable setup."
            ;;
    esac
}

# ... validate KUBE environment variable:
validate_kubeconfig() {
    if [[ -z "$KUBE" ]]; then
        print_message "31" "KUBE environment variable is not set!"
        return
    fi

    print_separator
    print_message "32" "Validating kubeconfig file: \033[36m$KUBE\033[0m"

    # ... extract server and host info from *.yml config:
    server_info=$(grep -E "server: " "$KUBE" 2>/dev/null | awk '{print $2}')
    host_info=$(grep -E "host: " "$KUBE" 2>/dev/null | awk '{print $2}')

    if [[ -n "$server_info" ]]; then
        print_message "37" "Server: \033[35m$server_info\033[0m"
    else
        print_message "31" "No 'server' field found in kubeconfig!"
    fi

    if [[ -n "$host_info" ]]; then
        print_message "37" "Host: \033[35m$host_info\033[0m"
    else
        print_message "31" "No 'host' field found in kubeconfig!"
    fi
}

# ... main script call:
main() {
    if check_kubectl; then
        search_kubeconfig           # ... Kubectl exists: → search for kubeconfig files:
    else
        if install_kubectl; then
            search_kubeconfig       # ... user promp to install → search for kubeconfig files:
        else
            search_kubeconfig       # ... user promp for skipped installation → Still search for kubeconfig files:
        fi
    fi
}

main
