#!/bin/bash
# =====================================================================================
#  FirewallD Management Script [ RHEL & Debian Compatible ]
# =====================================================================================
#  This script ensures `firewalld.sh` is installed, started, and enabled on boot:
#  Works on both [ RHEL ] - CentOS, Fedora, Alma, Rocky  & [ Debian ] - Ubuntu, Debian
#
#  Features:
#   - Detects OS type and installs `firewalld.sh` if missing:
#   - Chekcs if firewall service is running and enabled at boot:
#   - Provides basic `firewalld.sh` usage options:
#
# Usage:
#    sudo ./firewalld.sh [start|stop|restart|status|reload]
# =====================================================================================

# ... color formatting for warnings:
green="\033[1;32m"
gray='\033[1;90m'
cyan="\033[1;36m"
red="\033[0;31m"
white="\033[1;37m"
yellow="\033[1;33m"
off="\033[0m"

# ... OS Type:
detect_os() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian)
                PACKAGE_MANAGER="apt"
                SYSTEMD_SERVICE="firewalld"
                ;;
            fedora|centos|rhel|rocky|almalinux)
                PACKAGE_MANAGER="yum"
                SYSTEMD_SERVICE="firewalld"
                ;;
            *)
                echo -e "${red}Unsupported Linux distribution: $ID${off}"
                exit 1
                ;;
        esac
    else
        echo -e "${red}Could not detect Linux distribution!${off}"
        exit 1
    fi
}

# ... if != Firewalld Install it:
install_firewalld() {
    if ! command -v firewalld &> /dev/null; then
        echo -e "${yellow}Firewalld not found! Installing...${off}"
        if [[ "$PACKAGE_MANAGER" == "apt" ]]; then
            sudo apt update && sudo apt install -y firewalld
        elif [[ "$PACKAGE_MANAGER" == "yum" ]]; then
            sudo yum install -y firewalld
        fi
    else
        echo -e "${green}Firewalld is already installed.${off}"
    fi
}

# ... start & enable firewalld:
enable_firewalld() {
    echo -e "${cyan}Starting and enabling firewalld...${off}"
    sudo systemctl start firewalld
    sudo systemctl enable firewalld
    sudo systemctl status firewalld --no-pager
}

# ... manage firewalld:
manage_firewalld() {
    case "$1" in
        start)
            sudo systemctl start firewalld && echo -e "${green}Firewalld started.${off}"
            ;;
        stop)
            sudo systemctl stop firewalld && echo -e "${red}Firewalld stopped.${off}"
            ;;
        restart)
            sudo systemctl restart firewalld && echo -e "${yellow}Firewalld restarted.${off}"
            ;;
        status)
            sudo systemctl status firewalld --no-pager
            ;;
        reload)
            sudo firewall-cmd --reload && echo -e "${cyan}Firewalld rules reloaded.${off}"
            ;;
        *)
            echo -e "${white}Usage: $0 {start|stop|restart|status|reload}${off}"
            exit 1
            ;;
    esac
}

# ... main:
detect_os
install_firewalld
enable_firewalld

# ... If user provided an argument, manage firewalld accordingly:
if [[ $# -eq 1 ]]; then
    manage_firewalld "$1"
fi
