# #!/bin/bash

# Color code definitions
cyan="\033[0;36m"
blue="\033[1;34m"
white="\033[1;37m"
yellow="\033[1;33m"
grey="\033[0;37m"
GREEN="\033[1;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Decorative lines
decorator_init=$(echo -e "${white}$(printf '.%.0s' {1..50})${NC}")
decorator_done=$(echo -e "${white}$(printf '=%.0s' {1..85})${NC}\n")

uname_info() {
    local default_os_info=$(uname -a)
    local os_info=$(echo $default_os_info | awk '{print $1, $3}')
    echo -e "${GREEN}Sys Info: ${white}--> ${cyan}Distro Type: ${RED}[ ${yellow}$os_info ${RED}]${NC}"
}

# .. sys distro check:
sys_check() {
    local os_info=$(uname -a)
    uname_info
    if [[ "$os_info" == *"Linux"* ]]; then
        if [[ -f /etc/redhat-release ]]; then
            echo -e "\t ${white} --> ${cyan}Rhel ${GREEN}detected:${NC}"
            check_netstat "yum"
        elif [[ -f /etc/lsb-release ]]; then
            echo -e "\t ${white} --> ${cyan}Ubuntu ${GREEN}detected:${NC}"
            check_netstat "apt"
        elif grep -iq "docker" /proc/1/cgroup; then
            echo -e "\t ${white} --> ${cyan}Docker ${GREEN}detected:${NC}"
            if [ ! command -v netstat &>/dev/null ]; then 
                check_netstat "yum"
            fi
        else
            echo -e "\n${RED}Non-standard Linux distribution or unable to identify${NC}:"
            echo "$decorator_done"
        fi
    elif [[ "$os_info" == *"Darwin"* ]]; then
        echo -e "\t ${white} --> ${cyan}MacOS ${GREEN}detected${NC}:"
        check_netstat "brew"
    else
        echo -e "\n${RED}Unsupported OS:\n"
        echo "$decorator_done"
    fi
    echo "$decorator_init"
}

# ... netstat if exists check: 
check_netstat() {
    local package_manager=$1
    if ! command -v netstat &>/dev/null; then
        echo "'netstat' is not installed. Attempting to install..."
        case $package_manager in
            "yum")
                sudo yum install -y net-tools
                ;;
            "apt")
                sudo apt-get update && sudo apt-get install -y net-tools
                ;;
            "brew")
                brew install net-tools
                ;;
            *)
                echo "Package manager not supported. Please install 'net-tools' manually."
                ;;
        esac
    else
        echo -e "\t ${white} --> ${cyan}netstat ${GREEN}exists${NC}:"
    fi
}

# .... ports status monitor:
monitorPorts() {
    local duration_minutes=$1
    local duration_seconds=$((duration_minutes * 60))
    local start_time=$(date +%s)
    local current_time=$start_time
    local clear_count=0 
    declare -A connection_status

    while [[ $(($current_time - $start_time)) -lt $duration_seconds ]]; do
        # clear
        clear_count=$((clear_count + 1))
        echo "Monitoring all connections at $(date '+%Y-%m-%d %H:%M:%S'):"
        connections=$(netstat -tun | awk '{if (NR>2) print $4 " " $5 " " $6}')
        
        printf "%-20s %-20s %-15s %-20s %s\n" "Local Address" "Foreign Address" "State" "Local Port" "Occurrences"
        echo "---------------------------------------------------------------------------------------------------"

        while read -r line; do
            local addr=$(echo $line | awk '{print $1}')
            local foreign=$(echo $line | awk '{print $2}')
            local state=$(echo $line | awk '{print $3}')
            local key="$addr $foreign $state"

            # Update or initialize connection count
            if [[ -z "${connection_status[$key]}" ]]; then
                connection_status[$key]=1
            else
                ((connection_status[$key]++))
            fi

            # Split address into IP and port
            local local_ip=$(echo $addr | cut -d':' -f1)
            local local_port=$(echo $addr | cut -d':' -f2)
            local foreign_ip=$(echo $foreign | cut -d':' -f1)
            local foreign_port=$(echo $foreign | cut -d':' -f2)

            # Set colors
            local ip_color=$(tput setaf 7)      # White for IP
            local port_color=$(tput setaf 3)    # Yellow for port
            local count_color=$(tput setaf 2)   # Green for counts
            local state_color=$(tput setaf 2)   # Green for stable states, will change if state is problematic

            if [[ "$state" != "ESTABLISHED" && "$state" != "LISTEN" && "$state" != "TIME_WAIT" ]]; then
                state_color=$(tput setaf 1)    # Red for problematic states
            fi

            # Print with separate coloring for IP, port, state, and occurrences
            printf "%s%-20s %s%-20s %s%-15s %s%-20s %s%d%s\n" \
                   "$ip_color" "$local_ip" \
                   "$ip_color" "$foreign_ip" \
                   "$state_color" "$state" \
                   "$port_color" "$local_port" \
                   "$count_color" "${connection_status[$key]}" "$(tput sgr0)"
        done <<< "$connections"

        current_time=$(date +%s)
        sleep 10
        echo -e "\n... iter ${yellow}clear${NC} count: ${RED}[ ${yellow}$clear_count ${RED}]${NC}"
        echo "$decorator_done"
    done
}

sys_check
monitorPorts $1




# #!/bin/bash

# # Color code definitions
# cyan="\033[0;36m"
# blue="\033[1;34m"
# white="\033[1;37m"
# yellow="\033[1;33m"
# grey="\033[0;37m"
# GREEN="\033[1;32m"
# RED="\033[0;31m"
# NC="\033[0m"  # No Color

# # Decorative lines
# decorator_init=$(echo -e "${white}$(printf '.%.0s' {1..50})${NC}")
# decorator_done=$(echo -e "${white}$(printf '=%.0s' {1..65})${NC}\n")

# uname_info() {
#     local default_os_info=$(uname -a)
#     local os_info=$(echo $default_os_info | awk '{print $1, $3}')
#     echo -e "${GREEN}Sys Info: ${white}--> ${cyan}Distro Type: ${RED}[ ${yellow}$os_info ${RED}]${NC}"
# }

# # .. sys distro check:
# sys_check() {
#     local os_info=$(uname -a)
#     uname_info
#     if [[ "$os_info" == *"Linux"* ]]; then
#         if [[ -f /etc/redhat-release ]]; then
#             echo -e "\t ${white} --> ${cyan}Rhel ${GREEN}detected:${NC}"
#             check_netstat "yum"
#         elif [[ -f /etc/lsb-release ]]; then
#             echo -e "\t ${white} --> ${cyan}Ubuntu ${GREEN}detected:${NC}"
#             check_netstat "apt"
#         elif grep -iq "docker" /proc/1/cgroup; then
#             echo -e "\t ${white} --> ${cyan}Docker ${GREEN}detected:${NC}"
#             if [ ! command -v netstat &>/dev/null ]; then 
#                 check_netstat "yum"
#             fi
#         else
#             echo -e "\n${RED}Non-standard Linux distribution or unable to identify${NC}:"
#             echo "$decorator_done"
#         fi
#     elif [[ "$os_info" == *"Darwin"* ]]; then
#         echo -e "\t ${white} --> ${cyan}MacOS ${GREEN}detected${NC}:"
#         check_netstat "brew"
#     else
#         echo -e "\n${RED}Unsupported OS:\n"
#         echo "$decorator_done"
#     fi
#     echo "$decorator_init"
# }

# # ... netstat if exists check: 
# check_netstat() {
#     local package_manager=$1
#     if ! command -v netstat &>/dev/null; then
#         echo "'netstat' is not installed. Attempting to install..."
#         case $package_manager in
#             "yum")
#                 sudo yum install -y net-tools
#                 ;;
#             "apt")
#                 sudo apt-get update && sudo apt-get install -y net-tools
#                 ;;
#             "brew")
#                 brew install net-tools
#                 ;;
#             *)
#                 echo "Package manager not supported. Please install 'net-tools' manually."
#                 ;;
#         esac
#     else
#         echo -e "\t ${white} --> ${cyan}netstat ${GREEN}exists${NC}:"
#     fi
# }


# # Function to monitor and report port status with detailed formatting and coloring
# # monitorPorts() {
# #     local duration_minutes=$1
# #     local duration_seconds=$((duration_minutes * 60))
# #     local start_time=$(date +%s)
# #     local current_time=$start_time
# #     # declare -A connection_status
# #     declare -A 

# #     while [[ $(($current_time - $start_time)) -lt $duration_seconds ]]; do
# #         # clear
# #         echo "Monitoring all connections at $(date '+%Y-%m-%d %H:%M:%S'):"
# #         # Fetch all connections
# #         connections=$(netstat -tun | awk '{if (NR>2) print $4 " " $5 " " $6}')
        
# #         printf "%-20s %-20s %-15s %-20s %s\n" "Local Address" "Foreign Address" "State" "Local Port" "Occurrences"
# #         echo "---------------------------------------------------------------------------------------------------"

# #         while read -r line; do
# #             local addr=$(echo $line | awk '{print $1}')
# #             local foreign=$(echo $line | awk '{print $2}')
# #             local state=$(echo $line | awk '{print $3}')
# #             local key="$addr $foreign $state"

# #             # Update or initialize connection count
# #             if [[ -z "${connection_status[$key]}" ]]; then
# #                 connection_status[$key]=1
# #             else
# #                 ((connection_status[$key]++))
# #             fi

# #             # Split address into IP and port
# #             local local_ip=$(echo $addr | cut -d':' -f1)
# #             local local_port=$(echo $addr | cut -d':' -f2)
# #             local foreign_ip=$(echo $foreign | cut -d':' -f1)
# #             local foreign_port=$(echo $foreign | cut -d':' -f2)

# #             # Set colors
# #             local ip_color=$(tput setaf 7)      # White for IP
# #             local port_color=$(tput setaf 3)    # Yellow for port
# #             local count_color=$(tput setaf 2)   # Green for counts
# #             local state_color=$(tput setaf 2)   # Green for stable states, will change if state is problematic

# #             if [[ "$state" != "ESTABLISHED" && "$state" != "LISTEN" && "$state" != "TIME_WAIT" ]]; then
# #                 state_color=$(tput setaf 1)    # Red for problematic states
# #             fi

# #             # Print with separate coloring for IP, port, state, and occurrences
# #             printf "%s%-20s %s%-20s %s%-15s %s%-20s %s%d%s\n" \
# #                    "$ip_color" "$local_ip" \
# #                    "$ip_color" "$foreign_ip" \
# #                    "$state_color" "$state" \
# #                    "$port_color" "$local_port" \
# #                    "$count_color" "${connection_status[$key]}" "$(tput sgr0)"
# #         done <<< "$connections"

# #         # Update current time
# #         current_time=$(date +%s)
# #         sleep 5
# #     done
# # }
# # Function to monitor and report port status with detailed formatting and coloring
# monitorPorts() {
#     local duration_minutes=$1
#     local duration_seconds=$((duration_minutes * 60))
#     local start_time=$(date +%s)
#     local current_time=$start_time

#     # Use the OS information to determine if associative arrays can be used
#     local os_info=$(uname -a)
#     if [[ "$os_info" == *"Linux"* ]]; then
#         declare -A connection_status  # Associative array for Linux
#     else
#         declare -a connection_keys   # Indexed arrays for macOS or other systems
#         declare -a connection_counts
#     fi

#     while [[ $(($current_time - $start_time)) -lt $duration_seconds ]]; do
#         clear
#         echo "Monitoring all connections at $(date '+%Y-%m-%d %H:%M:%S'):"
#         connections=$(netstat -tun | awk '{if (NR>2) print $4 " " $5 " " $6}')
        
#         printf "%-20s %-20s %-15s %-20s %s\n" "Local Address" "Foreign Address" "State" "Local Port" "Occurrences"
#         echo "---------------------------------------------------------------------------------------------------"

#         while read -r line; do
#             local addr=$(echo $line | awk '{print $1}')
#             local foreign=$(echo $line | awk '{print $2}')
#             local state=$(echo $line | awk '{print $3}')
#             local key="$addr $foreign $state"

#             if [[ "$os_info" == *"Linux"* ]]; then
#                 # Update or initialize connection count using associative array
#                 if [[ -z "${connection_status[$key]}" ]]; then
#                     connection_status[$key]=1
#                 else
#                     ((connection_status[$key]++))
#                 fi
#             else
#                 # Use indexed arrays for non-Linux OS
#                 local key_exists=0
#                 local index=0
#                 for existing_key in "${connection_keys[@]}"; do
#                     if [[ "$existing_key" == "$key" ]]; then
#                         key_exists=1
#                         break
#                     fi
#                     ((index++))
#                 done

#                 if [[ $key_exists -eq 0 ]]; then
#                     connection_keys+=("$key")
#                     connection_counts+=(1)
#                 else
#                     ((connection_counts[index]++))
#                 fi
#             fi

#             local local_ip=$(echo $addr | cut -d':' -f1)
#             local local_port=$(echo $addr | cut -d':' -f2)
#             local foreign_ip=$(echo $foreign | cut -d':' -f1)
#             local foreign_port=$(echo $foreign | cut -d':' -f2)

#             # Print with separate coloring for IP, port, state, and occurrences
#             if [[ "$os_info" == *"Linux"* ]]; then
#                 printf "%s%-20s %s%-20s %s%-15s %s%-20s %s%d%s\n" \
#                        "$(tput setaf 7)" "$local_ip" \
#                        "$(tput setaf 7)" "$foreign_ip" \
#                        "$(tput setaf 2)" "$state" \
#                        "$(tput setaf 3)" "$local_port" \
#                        "$(tput setaf 2)" "${connection_status[$key]}" "$(tput sgr0)"
#             else
#                 printf "%s%-20s %s%-20s %s%-15s %s%-20s %s%d%s\n" \
#                        "$(tput setaf 7)" "$local_ip" \
#                        "$(tput setaf 7)" "$foreign_ip" \
#                        "$(tput setaf 2)" "$state" \
#                        "$(tput setaf 3)" "$local_port" \
#                        "$(tput setaf 2)" "${connection_counts[$index]}" "$(tput sgr0)"
#             fi
#         done <<< "$connections"

#         # Update current time
#         current_time=$(date +%s)
#         sleep 5
#     done
# }


# sys_check
# monitorPorts $1
