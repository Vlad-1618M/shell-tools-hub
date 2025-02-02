#!/bin/bash
# =========================================================================================
# Script Name: net_stats_trace.sh | Network Connection Monitor:
# Description:
#   This script monitors active network connections using 'netstat'. It provides two modes:
#     1. Raw netstat output (default, unprocessed).
#     2. Processed network statistics (filtered and formatted).
#
#   User can specify the mode and duration in minutes for monitoring.
#   Script supports both Linux and macOS by detecting the OS and choosing the 
#   appropriate netstat command.
#
# Usage:
#   ./net_stats_trace.sh [mode] [duration]
#   - mode: 1 (Raw netstat) or 2 (Processed User-Tuned netstat)
#   - duration: Duration in minutes
#   - ctr+c == stop the script:
#
# Timing Mechanism:
#   - The script calculates the total execution time in seconds by multiplying 
#     the user-specified duration (in minutes) by 60.
#   - It records the start time using `date +%s` (Unix timestamp in seconds).
#   - It runs a loop until the elapsed time reaches the specified duration.
#   - The `sleep` command ensures controlled intervals between each iteration.
#
# Clear Call:
#   - The `clear` command is used at the start of each loop iteration in both 
#     `default_netstat_raw()` and `user_tuned_netstats()` functions.
#
#   - This ensures that the terminal output remains clean and refreshed, avoiding 
#     clutter from previous iterations.
#   - The cleared output makes it easier to read and track the latest connections 
#     without unnecessary scrolling.
#
# Requirements:
#   - 'netstat' command [ provided by 'net-tools' package ]
#   -  bash-compatible environment [ Linux/macOS ] 
#
# =========================================================================================


# ... color formatting:
gray='\033[1;90m'
white='\033[1;97m'
yellow='\033[1;93m'
magenta='\033[1;95m'
red="\033[1;31m"
green='\033[1;92m'
cyan='\033[1;96m'
off="\033[0m"

# ... decorators:
decorator_init="echo -e ${gray}"$(printf '.%.0s' {1..87})"${off}"
decorator_done="echo -e ${gray}"$(printf '=%.0s' {1..87})"${off}"

# ... temporary file for tracking connections:
CONNECTION_FILE="/tmp/connection_status.tmp"> "$CONNECTION_FILE"

OS_TYPE="unknown"
ITERATIONS=0

# ... show help message:
show_help() {
    echo -e "\n${cyan}Usage:${white} $(basename "$0") ${red}[${yellow} mode ${red}]${off} ${red}[${yellow} duration ${red}]"
    echo -e "${yellow}Modes:${off}"
    echo -e "\t${green}1${gray} --> ${white} Raw Lib Default ${off}network stats:"
    echo -e "\t${green}2${gray} --> ${white} Processed User-Tuned ${off}network stats:"
    echo -e "${cyan}Examples:${off}"
    echo -e "${green}  $(basename "$0")${magenta} 1 ${green}5${gray} --> ${off}Runs ${white}Raw${off} / ${white}Lib Default netstat ${off}output for${green} 5 ${off}minutes:"
    echo -e "${green}  $(basename "$0")${magenta} 2 ${green}2${gray} --> ${off}Runs ${white}Processed User-Tuned ${off}network stats for ${magenta}2${off} minutes:"
    $decorator_done
    echo -e "If ${red}no arguments ${off}provided: The ${green}$(basename "$0")${off} script will prompt for mode and duration:"
    exit 0
}

# ... check net-tools pks: 
check_netstat() {
    local package_manager=$1
    if ! command -v netstat &>/dev/null; then
        $decorator_init
        echo -e"\n\t${white} --> ${gray}'netstat'${off} is ${red}not installed${off}: ${gray}Attempting to install ${magenta}'net-tools' ${off}..."
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
                echo -e "\n${red}Package manager not supported:${off}\nPlease install ${gray}'net-tools'${off} manually."
                ;;
        esac
    else
        echo -e "\t ${white} --> ${gray}netstat: \t   ${red}|${green} exists ${yellow}$(basename $0) ${off}is ready:"
    fi
    $decorator_done
}

# ... figureout proper netstat command | per sys type:  
get_netstat_command() {
    if [[ "$OS_TYPE" == "linux" ]]; then
        echo "netstat -tun"
    elif [[ "$OS_TYPE" == "macos" ]]; then
        echo "netstat -an"
    else
        echo "echo 'Unsupported OS'"
        exit 1
    fi
}

# ... which OS:
detect_os() {
    $decorator_init
    local os_info=$(uname -s)
    uname_info
    if [[ "$os_info" == "Linux" ]]; then
        echo -e "\t ${white} --> ${gray}Linux:\t   ${red}|${yellow} $(uname -a | awk '{print $2}')${off}"
        OS_TYPE="linux"
        check_netstat
    elif [[ "$os_info" == "Darwin" ]]; then
        OS_TYPE="macos"
        echo -e "\t ${white} --> ${gray}MacOS:\t   ${red}|${yellow} $(uname -a | awk '{print $2}')${off}"
        check_netstat
    else
        echo -e "\t ${white} --> ${gray}Unsupported OS:\t   ${red}|${yellow} $(uname -a | awk '{print $2}')${off}\n"
        exit 1
    fi
}


# ... default / Raw netstat output:
default_netstat_raw() {
    local duration_minutes=$1
    local duration_seconds=$((duration_minutes * 60))
    local start_time=$(date +%s)
    local current_time=$start_time
    local netstat_command
    netstat_command=$(get_netstat_command)
    while [[ $((current_time - start_time)) -lt $duration_seconds ]]; do 
        clear
        ITERATIONS=$((ITERATIONS + 1))
        echo -e "\n${gray}$(date '+%Y-%m-%d %H:%M:%S')${white} --> ${magenta}Monitoring Connections Progress: ${white} --> ${yellow}$ITERATIONS${off}"
        raw_output=$(eval "$netstat_command")
        echo -e "\n${yellow} ----- Raw netstat output ------${off}"
        $decorator_init
        echo "$raw_output" | head -25
        sleep 3
        current_time=$(date +%s)  # Update time each loop iteration
    done
}

# ... user-tunned / Processed network statistics: 
user_tuned_netstats() {
    local duration_minutes=$1
    local duration_seconds=$((duration_minutes * 60))
    local start_time=$(date +%s)
    local current_time=$start_time
    local netstat_command

    netstat_command=$(get_netstat_command)
    touch "$CONNECTION_FILE"  # ... if exists temp file check:
    
    while [[ $((current_time - start_time)) -lt $duration_seconds ]]; do 
        clear
        ITERATIONS=$((ITERATIONS + 1))
        echo -e "\n${gray}$(date '+%Y-%m-%d %H:%M:%S')${white} --> ${magenta}Processing Network Connections: ${white} --> ${yellow}$ITERATIONS${off}"

        # Execute netstat command
        raw_output=$(eval "$netstat_command")
        echo -e "\n${yellow} ----- Raw netstat output ------${off}"
        echo "$raw_output" | head -15  # ... show up to first 15 lines:
        $decorator_init
        
        # ... get valid connections dynamically based on actual format:
        connections=$(echo -e "$raw_output" | awk '/ESTABLISHED|LISTEN|CLOSE_WAIT|TIME_WAIT/ {print $4, $5, $6}')

        printf "\n${gray}%-25s ${magenta}%-25s ${yellow}%-15s ${cyan}%-10s %s${off}\n" "Local Address" "Foreign Address" "State" "Port" "Count"
        $decorator_done

        # ... if empty connections check:
        if [[ -z "$connections" ]]; then
            echo -e "${red}No valid connections found!${off}"
            sleep 2
            current_time=$(date +%s)
            continue
        fi

        while read -r line; do
            [[ -z "$line" ]] && continue

            local addr=$(echo "$line" | awk '{print $1}')
            local foreign=$(echo "$line" | awk '{print $2}')
            local state=$(echo "$line" | awk '{print $3}')

            [[ -z "$addr" || -z "$foreign" || -z "$state" ]] && continue

            # ... get IP | get Port:
            local local_ip="${addr%:*}"
            local local_port="${addr##*:}"
            local foreign_ip="${foreign%:*}"
            local foreign_port="${foreign##*:}"

            # ... check port numbers:
            if ! [[ "$local_port" =~ ^[0-9]+$ ]]; then
                local_port="UNKNOWN"
            fi
            if ! [[ "$foreign_port" =~ ^[0-9]+$ ]]; then
                foreign_port="UNKNOWN"
            fi
            
            # ... generate unique key:
            local key="$local_ip:$local_port -> $foreign_ip:$foreign_port [$state]"
            count=$(grep -c "$key" "$CONNECTION_FILE")
            if [[ $count -eq 0 ]]; then
                echo "$key" >> "$CONNECTION_FILE"
                count=1
            else
                count=$((count + 1))
                sed -i '' "s|$key|$key ($count)|" "$CONNECTION_FILE"
            fi
            
            # ... customize colors for "ESTABLISHED", "LISTEN", "CLOSE_WAIT", and "TIME_WAIT" output:
            if [[ "$state" == "ESTABLISHED" ]]; then
                printf "%-25s %-25s ${green}%-15s${off} %-10s ${yellow}%-5s${off}\n" "$local_ip" "$foreign_ip" "$state" "$local_port" "$count"
            elif [[ "$state" == "LISTEN" ]]; then
                printf "%-25s %-25s ${yellow}%-15s${off} %-10s ${yellow}%-5s${off}\n" "$local_ip" "$foreign_ip" "$state" "$local_port" "$count"
            elif [[ "$state" == "CLOSE_WAIT" ]]; then
                printf "%-25s %-25s ${red}%-15s${off} %-10s ${yellow}%-5s${off}\n" "$local_ip" "$foreign_ip" "$state" "$local_port" "$count"
            elif [[ "$state" == "TIME_WAIT" ]]; then
                printf "%-25s %-25s ${magenta}%-15s${off} %-10s ${yellow}%-5s${off}\n" "$local_ip" "$foreign_ip" "$state" "$local_port" "$count"
            else
                printf "%-25s %-25s %-15s %-10s ${yellow}%-5s${off}\n" "$local_ip" "$foreign_ip" "$state" "$local_port" "$count"
            fi            

        done <<< "$connections"
        current_time=$(date +%s)
        sleep 1
    done
}



uname_info() {
    local os_info=$(uname -a | awk '{print $1, $3}')
    echo -e "${gray}Sys Info:${white} --> ${magenta}Distro Type: ${red}| ${yellow}$os_info${off}"
}

detect_os
# ... handle cli args or interactive mode:
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
elif [[ $# -eq 2 ]]; then
    mode="$1"
    duration="$2"
else
    echo -e "\n${cyan}Choose Mode:${off}\n ${magenta}1. ${gray}netstat ${white}Lib Default${off} network stats output:${off}\n ${magenta}2. ${gray}netstat ${yellow}User-Tuned ${white}Processed ${off}network stats output:\n"
    read -rp "Enter choice (1 or 2): " mode
    read -rp "Enter duration in minutes: " duration
fi

# ... user input check:
if [[ ! "$mode" =~ ^[12]$ ]]; then
    echo -e "\n${red}Invalid mode!${off}" && exit 1
fi
if [[ ! "$duration" =~ ^[0-9]+$ ]]; then
    echo -e "\n${red}Invalid duration! Must be a number.${off}" && exit 1
fi

# ... run selected mode:
if [[ "$mode" -eq 1 ]]; then
    default_netstat_raw "$duration"
else
    user_tuned_netstats "$duration"
fi
