#!/bin/bash

# ===========================================================================================
# Script Name: docker_container_stats.sh
#
# Description:
#   - This script monitors active Docker containers and system resource usage.
#   - Displays real-time statistics, including container uptime, PID, and resource consumption.
#   - Supports multiple iterations to continuously track running containers.
#   - If no active containers are found, it lists available Docker images as alternatives.
#
# Compatibility:
#   - Works on macOS, Ubuntu, and Red Hat-based systems (RHEL, CentOS, Fedora).
#
# Features:
#   - Detects and displays active container IDs and associated details.
#   - Reports system status, including CPU and memory usage via `vmstat`.
#   - Auto-refreshes the container list every iteration.
#   - If no containers are running, it provides guidance on available images.
#
# Prerequisites:
#     - Docker must be installed and running.
#     - Requires `vmstat` (part of `procps` package) for system resource monitoring.
#     - jq - commandline JSON processor `jq` is required for parsing container command details.
#
#     [ Debian/Ubuntu ]         --> sudo apt update && sudo apt install -y jq
#     [ RHEL/CentOS (YUM) ]     -->	sudo yum install -y jq
#     [ RHEL 8+/Fedora (DNF) ]  -->	sudo dnf install -y jq
#     [ Alpine Linux ]          --> sudo apk add jq
#     [ Arch Linux ]            --> sudo pacman -S jq
#     [ macOS (Homebrew)]       -->	brew install jq
#
# Usage:
#   - Run the script with a numeric argument specifying the number of monitoring iterations.
#     Example: `./docker_container_stats.sh 5` (Runs for 5 iterations)
#
# References:
#   - Docker stats command: https://docs.docker.com/engine/reference/commandline/stats/
#   - VMStat documentation: https://man7.org/linux/man-pages/man8/vmstat.8.html
# ===========================================================================================


yellow="\033[1;33m"
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[1;31m"
blue="\033[1;34m"
pink="\033[1;35m"
off="\033[0m"
white="\033[1;97m"

decorator_init="echo -e ${yellow}$(printf '_%.0s' {1..65})${off}"
decorator_done="echo -e ${green}$(printf '=%.0s' {1..65})$off"
sys_decorator="echo -e ${blue}$(printf '_%.0s' {1..30})$off"
job_stat="echo -e ${blue}$(printf '.%.0s' {1..67})$off"

# ... user args:
if [ -z "$1" ]; then
  echo -e "\n\t${red}Usage${off} for: ${red}[${yellow} $(basename $0) ${red}]:\n\t${white}How many ${yellow}iterations ${off}did you need ?"
  $decorator_init
  exit 1
fi

ITERATIONS=$1 # ... iter count setting
# ... active | running Docker container IDs:
get_active_containers() { 
  call=$(docker ps --format "{{.ID}}") 
  if [ -z "$call" ]; then
    echo -e "\n\t${red}No active containers found:${off}"
    return 1
  else
    echo "$call"
  fi
  #   exit 1
  # else
  #   echo "$call" | awk '{printf " %s", $1}'
  # fi
}

# ... existing Docker images:
get_existing_images() {
  call=$(docker images --format "{{.Repository}}")
  if [ -z "$call" ]; then
    return 1
    # exit 1
  else
    echo "$call" | awk '{print "\t" $1}'
  fi
}

# ... get PID for running call + uptime
get_container_info() {
  CONTAINER_ID=$1
  PID=$(docker inspect --format '{{.State.Pid}}' "$CONTAINER_ID")                          # ... get container PID:
  COMMAND=$(docker inspect --format '{{json .Config.Cmd}}' "$CONTAINER_ID" | jq -r '.[]')  # ... cli for container is running:
  START_TIME=$(docker inspect --format '{{.State.StartedAt}}' "$CONTAINER_ID")             # ... get container start time:

  # ... start time to a timestamp:
  START_TIMESTAMP=$(date -d "$START_TIME" +%s)
  CURRENT_TIMESTAMP=$(date +%s)

  # ... convert uptime to hours, minutes, and seconds:
  UPTIME_SECONDS=$((CURRENT_TIMESTAMP - START_TIMESTAMP))
  UPTIME=$(printf "%02dh %02dm %02ds" $((UPTIME_SECONDS/3600)) $((UPTIME_SECONDS%3600/60)) $((UPTIME_SECONDS%60)))
  echo -e "Container Details:${yellow} --> ${off}PID ${yellow}[${pink} $PID ${yellow}]${off} UPTIME ${yellow}[${pink} $UPTIME ${yellow}]${off}"
  param_flag=""
  echo -e "\n${green}JOB${off}:"
  echo "$COMMAND" | while read -r line; do
    if [[ "$line" =~ ^-- ]]; then
        if [ -n "$param_flag" ]; then
            echo -e "\t${green}$param_flag${off}"
        fi
        param_flag="$line"
    else
        if [ -n "$param_flag" ]; then
            echo -e "\t${pink}$param_flag${off}  ${yellow}$line${off}"
            param_flag=""
        else
            echo -e "${yellow}$line${off}"
        fi
    fi
  done
  if [ -n "$param_flag" ]; then
    echo -e "\t${green}$param_flag${off}"
  fi
}

ACTIVE_CONTAINERS=$(get_active_containers)
EXISTING_IMAGES=$(get_existing_images)

if [ -z "$ACTIVE_CONTAINERS" ]; then
  echo -e "\n\t${red}No Active ${pink}Docker ${off}Containers found."
  if [ -z "$EXISTING_IMAGES" ]; then
    echo -e "\t${red}No Active ${pink}Docker ${off}Containers or Existing Images found:\n\t${yellow}sys exit${green} ...${off}"
    $sys_decorator
    exit 1
  else
    echo -e "\t${green}however, ${off}the following images are ${pink}available to start with${off}:"
    echo -e "${blue}$EXISTING_IMAGES\n${off}"
    $decorator_done
    exit 1
  fi
else
  echo -e "\t${pink}Active Containers${off}:"
  # Print container IDs vertically
  echo -e "${yellow}"
  for CONTAINER_ID in $ACTIVE_CONTAINERS; do
    echo -e "\t${CONTAINER_ID}"
  done
  echo -e "${off}"
  
  # Count and display the total number of active containers
  CONTAINER_COUNT=$(echo "$ACTIVE_CONTAINERS" | wc -w)
  echo -e "\t${green}Total active containers: ${yellow}$CONTAINER_COUNT${off}"
fi

vm=$(uname -ns)
echo -e "\n\tSys stats check:\n\t${green}Server Name${off}:\t--> ${red}[${yellow} $vm ${red}]${off}\n\t${cyan}Container IDs${off}:\t--> ${red}[${yellow} $CONTAINER_COUNT ${red}]${off}\n"
echo -e "\n\tSys stats check:\n\t${green}Server Name${off}:\t--> ${red}[${yellow} $vm ${red}]${off}\n\t${cyan}Container IDs${off}:\t--> ${red}[${yellow} $ACTIVE_CONTAINERS ${red}]${off}\n"
echo " =======" 

# Monitor loop:
for ((i=1; i<=ITERATIONS; i++)); do
  TIMESTAMP=$(date "+%Y-%m-%d %H:%M:%S")
  echo -e "VM Stats: ${pink}$TIMESTAMP ${off}"
  vmstat_output=$(vmstat 1 5 -S M -t -w | tail -n 10)
  echo -e "\n${green}$vmstat_output${off}\n"

  # Refresh the list of active containers in each iteration
  echo -e "${cyan}Refreshing list of active containers...${off}"
  ACTIVE_CONTAINERS=$(get_active_containers)

  # Count active containers
  CONTAINER_COUNT=$(echo "$ACTIVE_CONTAINERS" | wc -w)
  echo -e "${green}Total active containers: ${yellow}$CONTAINER_COUNT${off}"

  if [ -z "$ACTIVE_CONTAINERS" ]; then
    echo -e "\n\t${red}No Active ${pink}Docker ${off}Containers found."
    exit 1
  fi

  # Loop over each active container | show stats:
  for CONTAINER_ID in $ACTIVE_CONTAINERS; do
    $job_stat
    echo -e "Docker Stats:${pink} $TIMESTAMP${off} Container ID: ${yellow}[${pink} $CONTAINER_ID ${yellow}] ${off}"
    docker stats --no-stream --format "table {{.ID}}\t{{.Name}}\t{{.MemUsage}}\t{{.BlockIO}}" | grep "$CONTAINER_ID"
    get_container_info "$CONTAINER_ID"
  done

  sleep 0.04
done

$decorator_done
echo -e "${pink}Monitoring Completed:${off}"
