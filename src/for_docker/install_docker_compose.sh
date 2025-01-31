#!/bin/bash

# ===========================================================================================
# Script Name: install_docker_compose.sh
# Description:
#   - Checks if Docker is installed before installing Docker Compose.
#   - Works on macOS, Ubuntu, and Red Hat-based systems.
#   - Prompts the user before installing the latest version of Docker Compose.
#   - Verifies installed versions after installation.
#   - Warns if there is a version mismatch between Docker and Docker Compose.
#
#   Compatibility:
#   - macOS (Docker Desktop)
#   - Ubuntu (Docker Engine)
#   - Red Hat-based systems (RHEL 8, CentOS 8, Fedora)
#
#   Prerequisites:
#       - Requires sudo/root privileges for installation.
#       - Internet access is needed to fetch the latest Docker Compose version.
#
# References:
# - Docker Compose Releases: https://github.com/docker/compose/releases
# ===========================================================================================

# ... color vars for output formatting:
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[0;31m"
yellow="\033[1;33m"
white="\033[1;37m"
off="\033[0m"

# ... decorators:
decorator_init="echo -e ${cyan}"$(printf '.%.0s' {1..65})"${off}"
decorator_done="echo -e "$(printf '=%.0s' {1..65})""

# ... install Docker Compose:
install_docker_compose() {
    echo -e "Fetching latest ${yellow}version${off} for Docker Compose${off} ..."
    COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep -Po '"tag_name": "\K[^\"]*')

    if [[ -z "$COMPOSE_VERSION" ]]; then
        echo -e "\t${red}Error:${off} Failed to retrieve the latest Docker Compose version:"
        exit 1
    fi

    echo -e "Latest Docker Compose ${green}version${off} found: ${green}$COMPOSE_VERSION${off}"
    read -p "Proceed with installation? (yes/no): " user_response

    case "$user_response" in
        [Yy]*)
            sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
            sudo chmod +x /usr/local/bin/docker-compose
            echo -e "Docker Compose ${green}version $COMPOSE_VERSION installed ${off}successfully."
            ;;
        *)
            echo -e "${red}Installation aborted:${off} Docker Compose was not installed:"
            exit 0
            ;;
    esac
}

# ... check Docker and Docker Compose versions:
check_versions() {
    DOCKER_VERSION=$(docker --version | awk '{print $3" "$4}' | sed 's/build//')

    if docker-compose --version > /dev/null 2>&1; then
        COMPOSE_VERSION=$(docker-compose --version | awk '{print $4" "$5}' | sed 's/v//')
    else
        COMPOSE_VERSION="not installed"
    fi

    echo -e "\t${green}Docker ${off}version: ${green}$DOCKER_VERSION${off}"
    echo -e "\tDocker ${yellow}Compose${off} version: ${yellow}$COMPOSE_VERSION${off}"

    # ... version mismatch check:
    if [[ $COMPOSE_VERSION != "not installed" ]]; then
        DOCKER_MAJOR_VERSION=$(echo -e "$DOCKER_VERSION" | cut -d. -f1)
        COMPOSE_MAJOR_VERSION=$(echo -e "$COMPOSE_VERSION" | cut -d. -f1)

        if [[ "$DOCKER_MAJOR_VERSION" -ne "$COMPOSE_MAJOR_VERSION" ]]; then
            $decorator_init
            echo -e "${red}Warning:\n\t${yellow}potential version mismatch ${off}between Docker ${yellow}($DOCKER_VERSION)${off} and Docker Compose ${yellow}($COMPOSE_VERSION)${off}:"
            echo -e "${red}\tConsider${off} upgrading or downgrading one of them to avoid compatibility issues:"
        else
            echo -e "${green}Docker ${off}and ${green}Docker Compose${off} versions are compatible:"
        fi
    fi
}

# ...  check if Docker is installed:
check_docker_installed() {
    if ! command -v docker &>/dev/null; then
        echo -e "${red}Error:${off} Docker is not installed."
        echo -e "${yellow}Please install Docker before proceeding:${off}"
        exit 1
    fi
}

# ... main:
main() {
    $decorator_init
    check_docker_installed

    if command -v docker-compose &>/dev/null; then
        echo -e "\nDocker Compose ${green}exists${off} | already ${green}installed${off}"
    else
        install_docker_compose
    fi

    check_versions
    echo -e "\n${green}Docker Compose setup complete:${off}"
    $decorator_done
}

# ...  run main:
main
