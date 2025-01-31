#!/bin/bash

# Color code definitions
cyan="\033[1;36m"
blue="\033[1;34m"
white="\033[1;37m"
yellow="\033[1;33m"
grey="\033[0;37m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Decorative lines
decorator_init=$(echo -e "${RED}$(printf '.%.0s' {1..50})${NC}")
decorator_done=$(echo -e "${RED}$(printf '=%.0s' {1..50})${NC}\n")

# Function to format and print each interface and its ports with proper spacing
space_formater() {
    local interface="$1"
    local ip_address="$2"
    local ports="$3"
    max_iface_width=20
    max_ports_width=30
    printf "%-${max_iface_width}s --> IP: %-15s Ports: %s\n" "Interface: $interface" "$ip_address" "$ports"
}

# Function to monitor traffic on a specific port
tail_port() {
    local ip_address="$1"
    local port="$2"
    echo "$decorator_init"
    echo -e "${white}Starting ${GREEN}traffic monitor on IP: ${cyan}$ip_address ${yellow}Port: ${GREEN}$port${NC}\n"
    local counter=0
    while true; do
        if ss -ntpl | grep ":$port" > /dev/null; then
            echo -e "$(date): ${yellow}Traffic detected on ${RED}[${GREEN} $ip_address ${white}: ${cyan}$port ${RED}]${NC} --> ${grey}Trace Count: ${cyan}$counter${NC}"
        else
            # echo "$decorator_init"
            echo -e "$(date): ${white}\t--> ${RED}No ${NC}traffic ${RED}detected ${NC}on ${RED}[${NC} $ip_address : $port ${RED}]${cyan} -->${NC} Trace Count: ${NC}$counter"
        fi
        sleep 3
        ((counter++))
    done
    echo "$decorator_done"
}

# Initial system checks and installations
if ! command -v ifconfig &>/dev/null; then
    echo -e "${GREEN}ifconfig ${RED}not found, ${GREEN}installing ${NC}..."
    echo $decorator_init
    sudo yum install net-tools -y
    echo $decorator_done
fi

if ! command -v nmap &>/dev/null; then
    echo -e "${GREEN}nmap ${RED}not found, ${GREEN}installing ${NC}..."
    echo $decorator_init
    sudo yum install nmap -y
    echo $decorator_done
fi

# Main script logic to gather network interfaces and ports
echo "$decorator_init"
echo -e "${white}Available network interfaces and open ports:${NC}\n"
declare -A hosts

while IFS= read -r line; do
    interface=$(echo "$line" | sed 's/:.*//')
    ip_address=$(ifconfig $interface | grep 'inet ' | awk '{print $2}')
    if [[ -n "$ip_address" ]]; then
        echo -e "${RED}Scanning: ${white}--> ${yellow}\t$interface${NC}\t with IP ${cyan}\t$ip_address${NC}"
        ports=$(sudo nmap -p- -T4 $ip_address | grep 'open' | awk '{print $1}' | tr '\n' ' ')
        hosts["$interface"]="$ports"
    else
        echo -e "\n${RED}No ${NC}IP address found for:\t${white}-->  ${yellow}$interface${NC}:"
        echo "$decorator_init"
    fi
done < <(ifconfig | grep -E '^[a-zA-Z0-9]' | sed 's/^\([^ ]*\).*/\1/')

for interface in "${!hosts[@]}"; do
    ip_address=$(ifconfig $interface | grep 'inet ' | awk '{print $2}')
    ports="${hosts[$interface]}"
    if [[ -n "$ports" ]]; then
        space_formater "$interface" "$ip_address" "$ports"
    else
        space_formater "$interface" "$ip_address" "No open ports detected."
    fi
done

# User input for monitoring
echo "$decorator_init"
init_msg="$(echo -e Enter ${yellow}interface${NC} type from the ${yellow}list${NC} to monitor: )"
read -p "$init_msg " selected_interface

# Interface existence check
if [[ -z ${hosts[$selected_interface]} ]]; then
    echo "${RED}Selected interface is not in the list or has no open ports detected.${NC}"
    exit 1
fi

ip_address=$(ifconfig $selected_interface | grep 'inet ' | awk '{print $2}')
echo -e "\n${white}Available ports for ${yellow}$selected_interface${NC}:\t${yellow}-->${GREEN} ${hosts[$selected_interface]}${NC}"
port_msg="$(echo -e Enter ${yellow}port${NC} to${yellow} monitor${NC}: )"
read -p "$port_msg " selected_port

# Start Monitoring
tail_port "$ip_address" "$selected_port"
