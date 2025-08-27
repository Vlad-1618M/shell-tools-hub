#!/bin/bash

#####################################################################################################################
#  Script:  nmaps.sh
#  Purpose: Scans network interfaces and their open ports | allows monitoring of specific ports in real time:
#
#  Description:
#       - Lists all available network interfaces:
#       - Scans each interface for open ports using the `nmap` network scanning tool:
#       - Provides an option to monitor network traffic on a selected port:
#       - Uses OS-specific commands to fetch network interfaces and IP addresses:
#       - Supports real-time traffic monitoring with `ss` (Linux) and `netstat` (macOS/Linux):
#
#  How nmaps.sh Works:
#       1. Detects Operating System:    [ macOS, Ubuntu/Debian, RHEL/CentOS ]
#       2. Ensures `nmap` is Installed:
#          --> If `nmap` is missing, it installs it using the system's package manager [`brew`, `apt`, or `yum`]
#       3. Lists Available Network Interfaces:
#          --> Uses `ifconfig` for macOS and Ubuntu/Debian:
#          --> Uses `ip addr show` for RHEL/CentOS.:
#       4. Scans Each Interface for Open Ports:
#          --> Runs `nmap -p- -T4 <IP>` to identify open ports:
#       5. Allows User to Select an Interface & Port for Monitoring:
#          --> Monitors traffic on the selected port using `ss` or `netstat`:
#
#  What is `nmap`?:
#       - `nmap` [ Network Mapper ] is an open-source tool for network discovery and security auditing:
#       - It is commonly used on Linux Distributions to scan hosts, find open ports, and identify running services on the networ:
#       - This script uses `nmap` lib to scan each network interface for an open ports:
#       - More about `nmap`: https://nmap.org/
#
#  Sudo & Root Privileges:
#       - Running `nmap` [ requires sudo ] to access detailed port scans:
#       - The script **prompts for sudo** when scanning ports:
#       - Traffic monitoring (`ss`/`netstat`) may also need a root privileges:
#
#  Compatibility:
#       - Ubuntu/Debian → Uses `ifconfig` [ fallback: `ip addr show` ]
#       - RHEL/CentOS   → Uses            [`ip addr show`            ]
#       - macOS         → Uses `ifconfig` [ no `ip` command          ]
#
#  Prerequisites:
#       - `nmap` must be installed  →      [ script installs it if missing                 ]
#       - `ss` (Linux) or `netstat` →      [ macOS/Linux is needed for traffic monitoring  ]
#
#####################################################################################################################

# ... color formatting for warnings:
gray='\033[1;90m'
white='\033[1;97m'
yellow='\033[1;93m'
magenta='\033[1;95m'
orange='\033[1;91m'
green='\033[1;92m'
cyan='\033[1;96m'
red="\033[1;31m"
off="\033[0m"

# ... decorators: for visual separation in output
decorator_init="echo -e ${gray}$(printf '_%.0s' {1..89})${off}"
decorator_done="echo -e ${gray}$(printf '=%.0s' {1..69})${off}"

# ... fgureout Sys Type/OS | assign cli call adequetly: 
detect_os() {
    $decorator_init
    OS_TYPE=$(uname -s)
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        PKG_MANAGER="brew"
        INTERFACE_CMD="ifconfig"
        IP_CMD="ifconfig"
        echo -e "\n${gray}OS Type: ${white} --> ${magenta}$(uname -a | awk '{print $1 , $2}')${off}"
    elif [[ -f "/etc/os-release" ]]; then
        source /etc/os-release
        if [[ "$ID" == "ubuntu" || "$ID_LIKE" == "debian" ]]; then
            PKG_MANAGER="apt"
            INTERFACE_CMD="ifconfig"
            IP_CMD="ifconfig"
            echo -e "\n${gray}OS Type: ${white} --> ${magenta}$(uname -a | awk '{print $1 , $2}')${off}"
        elif [[ "$ID" == "rhel" || "$ID_LIKE" == "fedora" || "$ID_LIKE" == "centos" ]]; then
            PKG_MANAGER="yum"
            INTERFACE_CMD="ip addr show"
            IP_CMD="ip -o -4 addr show"
            echo -e "\n${gray}OS Type: ${white} --> ${magenta}$(uname -a | awk '{print $1 , $2}')${off}"
        else
            echo -e "\n${red}Unsupported ${gray}Linux ${off}distribution: ${magenta}$ID${off}"
            exit 1
        fi
    else
        echo -e "\n\t${white}--> ${red}Unsupported ${magenta}OS${off} detected: $OS_TYPE${off}"
        exit 1
    fi
}

# ... install required packages:
install_package() {
    local package="$1"
    if ! command -v "$package" &>/dev/null; then
        echo "Installing $package..."
        case "$PKG_MANAGER" in
            brew) brew install "$package" ;;
            apt) sudo apt update && sudo apt install -y "$package" ;;
            yum) sudo yum install -y "$package" ;;
            *)
                echo "Unknown package manager: $PKG_MANAGER"
                exit 1
                ;;
        esac
    fi
}

# ... scan for open ports using nmap lib:
scan_open_ports() {
    local ip_address="$1"
    ports=$(sudo nmap -p- -T4 "$ip_address" | grep 'open' | awk '{print $1}' | tr '\n' ' ')
    echo "$ports"
}

# ... list network interfaces:
get_interfaces() {
    if [[ "$INTERFACE_CMD" == "ifconfig" ]]; then
        ifconfig | grep -E '^[a-zA-Z0-9]' | awk '{print $1}' | sed 's/://'
    else
        ip -o link show | awk -F': ' '{print $2}'
    fi
}

# ... get IP for a given interface:
get_ip_for_interface() {
    local interface="$1"
    if [[ "$IP_CMD" == "ifconfig" ]]; then
        ifconfig "$interface" 2>/dev/null | grep 'inet ' | awk '{print $2}'
    else
        ip -o -4 addr show "$interface" 2>/dev/null | awk '{print $4}' | cut -d/ -f1
    fi
}

# ... monitor traffic on port:
monitor_port() {
    local ip_address="$1"
    local port="$2"
    echo -e "${green}JOB:\t${gray}init traffic monitor${off} on IP:${magenta} $ip_address ${off}Port: ${green}$port${off}\n"
    local counter=0
    while true; do
        if ss -ntpl 2>/dev/null | grep ":$port" > /dev/null || netstat -an 2>/dev/null | grep ":$port" > /dev/null; then
            echo -e "${gray}$(date)${off}:\t${magenta}Traffic Detected:${off}\t${gray}--> ${red}[${yellow} $ip_address${off}:${green}$port ${red}]${gray} -> ${white}iter ${gray}count${off}: ${yellow}$counter${off}"
        else
            echo -e "${gray}$(date)${off}:\t${red}No ${gray}traffic detected: ${gray}--> ${red}[${yellow} $ip_address${off}:${green}$port ${red}]${gray} -> ${white}iter ${gray}count${off}: ${yellow}$counter${off}"
        fi
        sleep 3
        ((counter++))
    done
}

# ... main:
detect_os
install_package "nmap"

interfaces=()
ips=()
ports=()

echo -e "${gray}Existing:${white} --> ${yellow}Network ${off}Interfaces${gray} & ${yellow}Open${off} Ports"
$decorator_init

for interface in $(get_interfaces); do
    ip_address=$(get_ip_for_interface "$interface")
    if [[ -n "$ip_address" ]]; then
        echo -e "\n${green}JOB:\t${gray}scanning: ${yellow}$interface\t${gray}--> ${off}IP:${magenta} $ip_address\n"
        open_ports=$(scan_open_ports "$ip_address")

        # ... dtore interface, IP, ports:
        interfaces+=("$interface")
        ips+=("$ip_address")
        ports+=("$open_ports")
    else
        # fixed space shift: == Left-Aligned (<--):
        normalize_spaces_left=$(printf "%b%-10s%b --> %b%s%b\n" "$yellow" "$interface" "$gray" "$red" "IP address not found" "$off")
        echo -e "$normalize_spaces_left"

        # fixed space shift: == Right-Aligned (-->):
        # normalize_spaces_right=$(printf "%b%10s%b --> %b%s%b\n" "$yellow" "$interface" "$gray" "$red" "IP address not found" "$off")
        # echo -e "$normalize_spaces_right"

    fi
done

# ... show results:
$decorator_init
for i in "${!interfaces[@]}"; do
    echo -e "${off}Interface:${yellow} ${interfaces[$i]}${gray}\t --> ${off}IP:${magenta} ${ips[$i]}${gray}\t--> ${off}Ports:${green} ${ports[$i]}${off}"
done

# ... interface | port - user selection prompts:
$decorator_init
echo -e "${yellow}Enter interface ${off}to${yellow} monitor${off}:"
read -r selected_interface

found=false
for i in "${!interfaces[@]}"; do
    if [[ "${interfaces[$i]}" == "$selected_interface" ]]; then
        found=true
        ip_address="${ips[$i]}"
        break
    fi
done

if [[ "$found" == false ]]; then
    echo "Invalid selection."
    exit 1
fi

echo -e "${yellow}Enter port ${off}to${yellow} monitor${off}:"
read -r selected_port
$decorator_init

monitor_port "$ip_address" "$selected_port"