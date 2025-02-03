#!/bin/bash

# ===================================================================================
# Script Name: helm_install.sh
# Description: 
#   - Checks if Helm is installed. If not, prompts the user to install it.
#   - Reports the Helm version and installation path if already installed.
#   - Handles installation safely, including script cleanup.
#
# Compatibility: Linux (Ubuntu, RHEL, Debian) & macOS (default shell)
# ===================================================================================

# ... print messages | in color:
print_message() {
    COLOR=$1
    MESSAGE=$2
    echo -e "\033[${COLOR}m${MESSAGE}\033[0m"
}

# ... print line for visual separation in output:
print_separator() {
    echo -e "\033[36m-----------------------------------\033[0m"
}

# ... check if Helm is installed:
check_helm() {
    if command -v helm >/dev/null 2>&1; then
        print_separator
        print_message "32" "✅ Helm is already installed."
        helm_version=$(helm version --short 2>/dev/null)
        helm_path=$(command -v helm)
        print_message "37" "Version: \033[36m${helm_version}\033[0m"
        print_message "37" "Location: \033[36m${helm_path}\033[0m"
        print_separator
        return 0  # ... success Helm exists | already installed:
    else
        print_message "33" "⚠️  Helm is not installed."
        return 1  # ... Helm missing or not found or not installed: 
    fi
}

# ... install Helm:
install_helm() {
    print_separator
    print_message "33" "Do you want to install Helm? (yes/no)"
    read response
    case "$response" in
        [Yy]*)
            ;;
        *)
            print_message "31" "❌ Skipping Helm installation."
            return 1  # ... skipped installation:
            ;;
    esac

    print_separator
    print_message "32" "🚀 Installing Helm..."

    # ... download get_helm.sh installation script:
    curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
    chmod 700 get_helm.sh

    # ... run get_helm.sh | execute installation script:
    ./get_helm.sh
    install_status=$?

    # ... cleanup installation script:
    rm -f get_helm.sh

    if [[ $install_status -ne 0 ]]; then
        print_message "31" "❌ Helm installation failed!"
        return 1  # ... failure | installation failed: 
    fi

    print_message "32" "✅ Helm installation completed successfully."

    # ... verify Helm installation:
    helm version --short

    # ... install Helm Diff plugin:
    print_separator
    print_message "32" "📌 Installing Helm Diff plugin..."
    helm plugin install https://github.com/databus23/helm-diff
}

# ... main script call:
main() {
    if check_helm; then
        exit 0  # ... If Helm exists | already installed, exit:
    else
        install_helm  # ... If Helm is not found | not installed or missing | prompt for installation:
    fi
}

main