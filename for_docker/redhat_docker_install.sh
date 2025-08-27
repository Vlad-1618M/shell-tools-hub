#!/bin/bash

# ===========================================================================================
# Script Name: install_docker.sh
# Description:
#   - This script checks whether Docker is installed on a Red Hat-based system.
#   - If Docker is not installed, it automates the installation using the official Docker CE repository.
#   - After installation, it verifies Docker’s health status and logs relevant details.
#   - If Docker is already installed but not running, the script provides troubleshooting steps.
#
#   Compatibility:
#   - Designed for RHEL-based systems (RHEL 8, CentOS 8, Fedora).
#   - Works around Red Hat's restrictions by leveraging CentOS package repositories.
#   - Not suitable for macOS (Docker Desktop should be used instead).
#
#   Why This Script?
#   - Red Hat Enterprise Linux (RHEL) does not provide Docker Engine via traditional package managers.
#   - Instead, RHEL enforces Podman as its container runtime due to its subscription model.
#   - This script helps by using an older CentOS repository (`centos/docker-ce.repo`) to install Docker CE.
#   - Automates the required setup, reducing the need for manual repo searches and configuration.
#
#   Prerequisites:
#   - Must be run with sudo/root privileges.
#   - Internet access is required to download the necessary packages.
#
#   References:
#   - Official installation steps: https://linuxconfig.org/how-to-install-docker-in-rhel-8
# ===========================================================================================

# ... color vars for output formatting:
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[0;31m"
yellow="\033[1;33m"
white="\033[1;37m"
off="\033[0m"

# ... decorators:
decorator_init="echo -e \t${cyan}"$(printf '.%.0s' {1..95})"${off}"
decorator_done="echo -e \t"$(printf '=%.0s' {1..85})""


# ... function to print the script's intent and limitations:
script_intro() {
    $decorator_init
    echo -e "🔹\tThis script ${yellow}[ ${green}$(basename $0)${yellow} ]${off} is designed to check for Docker installation on ${yellow}RHEL-based${off} systems."
    echo -e "🔹\tUnfortunatly the ${yellow}RedHat Enterprise Linux (RHEL)${cyan} does not support ${off}traditional Docker Engine installation via standard package managers: ${yellow}YUM${off} | ${yellow}DNF:${off}"
    echo -e "🔹\tMostly due to Red Hat's shift towards ${yellow}Podman${off} and its subscription-based licensing model."
    echo -e "🔹\n\tTo work around this, an older CentOS package repository (${yellow}centos/docker-ce.repo${off}) can be leveraged."
    echo -e "🔹\tThis script automates the necessary configurations, eliminating the need for manual research and repo setup."
    echo -e "🔹\tIt provides a consolidated and tested method to install Docker CE on RHEL-based systems, including:"
    echo -e "\n📌 \tTested CLI commands for Docker CE installation:"
    echo -e "\t${cyan}dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo${off}" 
    echo -e "\t${cyan}dnf repolist -v${off}" 
    echo -e "\t${cyan}dnf install --nobest docker-ce${off}" 
    echo -e "\t${cyan}systemctl enable --now docker${off}"
    echo -e "\t${cyan}systemctl is-active docker${off}"
    echo -e "\t${cyan}systemctl is-enabled docker${off}"
    echo -e "🔹\tSource: ${yellow}https://linuxconfig.org/how-to-install-docker-in-rhel-8${off}"
    echo -e "\n🔹\tIf Docker is not installed, this script will proceed with the installation using the official repository."
    echo -e "🔹\tAfter installation, it verifies Docker’s health and logs relevant details."
    echo -e "🔹\tSupported Operating Systems: ${yellow}RHEL 8, CentOS 8, Fedora${off}"
    echo -e "\n⚠️ \tEnsure you have ${yellow}sudo/root${off} privileges before running this script."
    $decorator_init
}

# ... check if Docker is installed:
check_docker_installed() {
    which docker &>/dev/null
    return $?
}

# ... install Docker:
install_docker() {
    dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
    dnf repolist -v
    dnf install --nobest docker-ce
    systemctl enable --now docker
    systemctl is-active docker
    systemctl is-enabled docker
}

# ... check Docker details:
check_docker_health() {
    docker info &>/dev/null
    return $?
}

# ... log installation details:
log_install_details() {
    local dir_name="docker_install"
    local file_name="$(date '+%Y%m%d_%H%M%S')_install_log.txt"
    
    if [ ! -d "$dir_name" ]; then
        mkdir -p "$dir_name"
    fi

    {
        echo "Installation Date and Time: $(date)"
        echo "Docker Installation Method: Docker-CE"
        echo "Used Libraries and Sources: https://download.docker.com/linux/centos/docker-ce.repo"
        dnf list installed | grep docker
    } >> "$dir_name/$file_name"
}

# ... run script intro before execution:
script_intro

if ! check_docker_installed; then
    echo -e "\n🔹 Docker is not installed. Proceeding with installation..."
    install_docker

    if check_docker_health; then
        echo -e "✅ Docker installation successful! The Docker service is running and ready to use."
        log_install_details
    else
        echo -e "⚠️ Docker was installed, but its service is not running or inaccessible."
        echo -e "ℹ️  Try restarting Docker with: ${cyan}sudo systemctl restart docker${off}"
        echo -e "🛠️  If issues persist, check logs using: ${cyan}sudo journalctl -u docker --no-pager | tail -20${off}"
    fi
else
    echo -e "\n✅\tDocker engine ${green}exists${off} already installed:"
    if ! check_docker_health; then
        echo -e "⚠️\tDocker engine is ${green}installed${off} but ${yellow}currently not running${off} or ${red}inaccessible:${off}"
        echo -e "ℹ️\n\tCheck your setup, you can use the following commands:"
        $decorator_init
        echo -e "\t🔹 sudo systemctl ${yellow}status${off} docker${off} ${white}\t<-${off} # Check Docker service status:"
        echo -e "\t🔹 sudo systemctl ${yellow}start${off} docker${off} ${white}\t\t<-${off} # Start Docker if it’s not running:"
        echo -e "\t🔹 docker ${yellow}system df${off} ${white}\t\t\t<-${off} # Show disk usage by Docker:"
        echo -e "\t🔹 docker ${yellow}ps -a${off} ${white}\t\t\t<-${off} # List all containers (including stopped ones):"
        echo -e "\t🔹 docker ${yellow}images -a${off} ${white}\t\t\t<-${off} # List all Docker images:"
        echo -e "📌\n\tIf ${red}!=RedHat${off} (e.g., ${cyan}using macOS${off}), ensure Docker Desktop is running: ${cyan}open -a Docker${off}"
    else
        echo -e "✅ Docker is installed and running properly."
    fi
fi
$decorator_done