#!/bin/bash

# ===========================================================================================
# Script Name: active_container_logs.sh
#
# Description:
#   - This script captures and displays logs from active Docker containers.
#   - Allows the user to select specific containers or capture logs from all running containers.
#   - Provides an option to save logs to a file, including specifying the number of log lines to capture.
#   - Uses color-coded output to differentiate logs from multiple containers.
#
# Compatibility:
#   - Works on macOS, Ubuntu, and Red Hat-based systems (RHEL, CentOS, Fedora).
#
# Features:
#   - Detects active Docker containers before proceeding.
#   - Provides an interactive menu to select containers.
#   - Supports live log following or capturing a specified number of log lines.
#   - Offers an option to save logs with timestamps for later review.
#
# Prerequisites:
#   - Docker must be installed and running.
#   - Requires sudo/root privileges if Docker is restricted.
#   - Internet access is not required for operation.
#
# Usage:
#   - Run the script and follow the interactive prompts to select containers and capture logs.
#   - If logs are to be saved, the script will generate timestamped log files.
#
# References:
#   - Docker logs command: https://docs.docker.com/engine/reference/commandline/logs/
# ===========================================================================================

# ... colors:
yellow=$(tput setaf 3)
green=$(tput setaf 2)
cyan=$(tput setaf 6)
red=$(tput setaf 1)
blue=$(tput setaf 4)
white=$(tput setaf 7)
pink=$(tput setaf 5)
off=$(tput sgr0)

decorator_init="echo -e ${yellow}$(printf '_%.0s' {1..75})${off}"
decorator_done="echo -e ${green}$(printf '=%.0s' {1..65})$off"
sys_decorator="echo -e ${pink}$(printf '__%.0s' {1..30})$off"
job_stat="echo -e ${white}$(printf '=%.0s' {1..76})$off"

# ... containers color array set: 
colors=($(tput setaf 1) $(tput setaf 2) $(tput setaf 3) $(tput setaf 4) $(tput setaf 5) $(tput setaf 6) $(tput setaf 9) $(tput setaf 10))

# ... log files timestamp:
timestamp=$(date +"${yellow}%Y-%m-%d-${white}%H_%M_%S"${off})

# ... active containers check:
check_active_containers() {
    container_ids=($(docker ps -q))
    if [ ${#container_ids[@]} -eq 0 ]; then
        echo -e "\n${red}No active containers found:${off}"
        $sys_decorator
        exit 1
    fi
}

# ... container selector | all containers
select_container() {
    echo -e "\n\t${white}Select Container:\t ${pink}______________________________________ ${off}"
    for i in "${!container_ids[@]}"; do
        container_name=$(docker inspect --format '{{.Name}}' "${container_ids[$i]}" | sed 's/\///')
        echo -e "\t${red}[ ${yellow}$((i+1))${off} ${red}] ${green}$container_name\t${white}<- ${yellow}${container_ids[$i]}"
    done
    echo -e "\t${red}[ ${yellow}a ${red}]${white} <--${off} for ${yellow}all containers:\n${off}"
    echo -e "\t${pink}Enter the ${green}container ${pink}number ${off}or use ${yellow} a ${off}for all:\n"

    # ... input read:
    read -rp "${white}select an option ... ${off}" container_choice
    if [[ $container_choice == "a" ]]; then
        selected_containers=("${container_ids[@]}")
    else
        selected_containers=("${container_ids[$((container_choice-1))]}")
    fi
}

# ... user prompt | capture log data management:
prompt_save_logs() {
    echo -e "${white}write logs to a file ${yellow}? ${white}[ ${yellow}y${off}/${red}n ${white}]${off}"
    read -r save_logs

    # ... log line limit to capture:
    while true; do
        echo -e "${pink}How many log lines to capture?${off}"
        read -rp "Enter the number of lines (0 for unlimited): " lines

        # .... input check | must be an integer value:
        if [[ "$lines" =~ ^[0-9]+$ ]]; then
            break
        else
            echo -e "${red}Please enter a valid number.${off}"
        fi
    done
}

# ... show logs for each container:
display_logs() {
    local container_id=$1
    local container_name=$2
    local color=$3
    local lines=$4

    # echo -e "\n${color}Showing logs for container ID: $container_id (Name: $container_name)${off}"
    $job_stat
    echo -e "${pink}log watcher in progress:\t${red}-->${off} container ID: ${red}[ ${yellow}$container_id ${off} | ${green}Name: ${pink}$container_name ${red}]${off}"
    # $job_stat
    $sys_decorator
    if [ "$save_logs" == "y" ] || [ "$save_logs" == "Y" ]; then
        # log_file="${container_name}_${container_id}_${timestamp}.log"
        log_file="${pink}${container_name}_${white}${container_id}_${off}${timestamp}.log"
        
        echo -e "\n${yellow}Saving ${white}logs ${off}to\n${yellow}file: --> ${pink}$log_file${off}"
        if [ "$lines" -eq 0 ]; then
            docker logs "$container_id" > "$log_file" 2>&1 &
        else
            docker logs -n "$lines" "$container_id" > "$log_file" 2>&1 &
        fi
    else
        if [ "$lines" -eq 0 ]; then
            docker logs -f "$container_id" 2>&1 | sed "s/^/${color}[${container_id}]: ${off}/" &
        else
            docker logs -n "$lines" "$container_id" 2>&1 | sed "s/^/${color}[${container_id}]: ${off}/" &
        fi
    fi
}


# ... main:
main() {
    $job_stat
    check_active_containers
    select_container
    prompt_save_logs

    for i in "${!selected_containers[@]}"; do
        container_id="${selected_containers[$i]}"
        container_name=$(docker inspect --format '{{.Name}}' "$container_id" | sed 's/\///')
        color="${colors[$((i % ${#colors[@]}))]}"
        display_logs "$container_id" "$container_name" "$color" "$lines"
    done

    wait
    $decorator_done
    echo -e "\n\t${white}Log capturing finished:${off}"
}

main "$@"
