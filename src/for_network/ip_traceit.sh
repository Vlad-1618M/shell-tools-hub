#!/bin/bash

# =============================================================================================================================
# Script Name: [ ip_tracer.sh ] - IP & Network Tracer:
# Description:
#   This script allows users to analyze network paths and connectivity using `traceroute` and `mtr` utilities. 
#     Unless input is provided:
#       - It retrieves the system’s public and private IP addresses and runs `traceroute` & `MTR` analysis specified IP address:
#
#   Features:
#     - Automatically detects OS type [ Linux/macOS ] and its package manager:
#     - Retrieves system's public and private IP addresses:
#     - Performs a `traceroute` for hop-by-hop analysis:
#     - Runs `mtr` to get detailed real-time network latency and loss statistics:
#     - Shows useful information about the network path:
#
#   Usage:
#       sudo ./src/for_network/ip_traceit.sh
#       - Prompts the user to enter an IP address for tracing:
#       - If no IP is provided, it displays system IPs:
#       - Runs `traceroute` and `mtr` on the given IP:
#
#   Example:
#     sudo ./src/for_network/ip_traceit.sh
#       Enter IP you'd like to trace or press Enter to see system IPs: 8.8.8.8
#
#   Expected Output:
#       - Traceroute results showing the hops from source to destination:
#       - MTR output displaying real-time network statistics, packet loss, and latency:
#
# =============================================================================================================================
#                 Understanding `traceroute` vs `mtr`
#
#  `traceroute`:  -- [    usually comes by default on Linux Distros and MacOS     ]
#   - A diagnostic tool desinged to return the [ route packets ] details thus take to reach a destination:
#   - Provides a [ static snapshot ] of network hops:
#       - Example: traceroute 8.8.8.8
#       - Output example:
#         1  192.168.1.1  1.23 ms
#         2  10.0.0.1     5.67 ms
#         3  198.51.100.5 20.1 ms
#         4  8.8.8.8      40.5 ms
#
#  `mtr`: or -- [ My Traceroute ] Needs to be Installed using sys pkg manager:
#     - A [ real-time network diagnostic tool ] designed to continuously monitors packet routes:
#     - Provides [ live packet loss statistics ] for each hop:
#     - Useful for detecting [ intermittent connection issues ]
#       - Example: sudo mtr --report 8.8.8.8
#       - Output example:
#         HOST: myserver.local      Loss%   Snt   Last   Avg  Best  Wrst StDev
#           1.|-- 192.168.1.1       0.0%    10    1.1    1.0   0.9   1.2   0.1
#           2.|-- 10.0.0.1          2.0%    10    2.3    2.1   2.0   2.5   0.2
#           3.|-- 198.51.100.5      8.0%    10   30.2   35.4  30.1  45.2   5.4
#
#   Important `mtr` NOTE:
#     - `mtr`requires  [ sudo/root privileges ] on some systems:
#      - If `mtr` does not run, try `sudo mtr 8.8.8.8`
# =============================================================================================================================
#                   some data | Public IPs for Test or Practicse Tracing
#     Major ISP & Backbone Network IPs
#     Provider        IP Address       Description
#     -------------- ---------------- ------------------------------
#     Google DNS      8.8.8.8          Primary Google DNS
#     Google DNS      8.8.4.4          Secondary Google DNS
#     Cloudflare DNS  1.1.1.1          Fast privacy-focused DNS
#     OpenDNS         208.67.222.222   Cisco’s OpenDNS (Anycast)
#     Level 3 (Lumen) 4.2.2.2          Large backbone provider
#     Quad9 DNS       9.9.9.9          Privacy & security DNS
#     AT&T (SBC)      12.129.193.251   AT&T network
#     AT&T Legacy     68.94.156.1      AT&T legacy DNS
#     Comcast         75.75.75.75      Primary Comcast DNS
#     Comcast         75.75.76.76      Secondary Comcast DNS
# =============================================================================================================================


# ... color formatting for warnings:
green="\033[1;32m"
gray='\033[1;90m'
cyan="\033[1;36m"
red="\033[0;31m"
blue="\033[1;34m"
pink="\033[1;35m"
white="\033[1;37m"
yellow="\033[1;33m"
magenta='\033[1;95m'
off="\033[0m"

# ... decorators: for visual separation in output
decorator_init="echo -e ${gray}$(printf '_%.0s' {1..59})${off}"
decorator_done="echo -e ${gray}$(printf '=%.0s' {1..89})${off}"

# ... figureout OS-Type: 
detect_os() {
  $decorator_init
  local os_info
  os_info=$(uname -a | awk '{print $1 , $2}')  # Extracts OS and hostname
  echo -e "\n${gray}OS Type:\t  ${gray} --> ${magenta}$os_info${off}"

  case "$(uname -s)" in
    Linux*) 
      OS="linux"
      echo -e "${gray}Detected OS:\t${green}Linux${gray} --> ${magenta}Compatible with ${yellow}apt${off}/${magenta}yum package managers${off}:"
      ;;
    Darwin*) 
      OS="macos"
      echo -e "${gray}Detected OS: ${green}MacOS${gray} --> ${magenta}Uses ${yellow}Homebrew package management${off}:"
      ;;
    *) 
      OS="unknown"
      echo -e "${red}Unsupported OS!${off} - ${yellow}Please install dependencies manually${off}:"
      exit 1
      ;;
  esac
}

# ... required commands check:
check_dependencies() {
  local missing=()
  detect_os

  for cmd in curl traceroute mtr dig; do
    if ! command -v "$cmd" &>/dev/null; then
      missing+=("$cmd")
    fi
  done

  if [[ ${#missing[@]} -gt 0 ]]; then
    echo -e "\n ${white}--> ${magenta}Missing Dependencies: ${red}[ ${yellow}${missing[*]} ${red}] ${white}<--${off}"
    # ... help with installation instructions:
    echo -e "\tTo install the missing tools ..."
    if [[ "$OS" == "linux" ]]; then
      if command -v apt &>/dev/null; then
        echo -e "\t${green}run:${white} --> ${yellow}[${magenta} sudo ${green}apt update && sudo apt install -y ${missing[*]} ${yellow}]${off}"
      elif command -v yum &>/dev/null; then
        echo -e "\t${green}run:${white} --> ${yellow}[${magenta} sudo ${green}yum install -y ${missing[*]} ${yellow}]${off}"
      fi
    elif [[ "$OS" == "macos" ]]; then
      if command -v brew &>/dev/null; then
        echo -e "\t${green}run:${white} --> ${yellow}[${green} brew install ${missing[*]} ${yellow}]${off}"
      else
        echo -e "\n${red}Homebrew not found! ${green}you may want to Install it from:${cyan} https://brew.sh/${off}"
      fi
    else
      echo -e "${red}Unsupported OS! Install the missing dependencies manually:${off}"
    fi

    echo -e "\t${yellow}Press Enter${off} to exit:"
    read -r
    exit 1
  fi
}

# ... get Public IP:
get_public_ip() {
  echo -e "\n${white} --> ${magenta}Retrieving Public IPs${off}"
  local public_ip
  public_ip=$(curl -s ifconfig.me || echo "Unavailable")
  echo -e "${white} --> ${green}Public IP: $public_ip${off}"
}

# ... get Private IP(s):
get_private_ip() {
  echo -e "\n${white} --> ${magenta}Retrieving Private IP(s)\n"
  if command -v ip &>/dev/null; then
    ip addr show | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d/ -f1
  elif command -v ifconfig &>/dev/null; then
    ifconfig | awk '/inet / && !/127.0.0.1/ {print $2}'
    # ifconfig | awk '/inet / && !/127.0.0.1/ {print $1, $2, $3, $4}'
  else
    echo -e "${red}Unable to determine private IP.${off}"
  fi
}

# ... run network tracing:
trace_ip() {
  local ip=$1
  echo -e "${green}JOB:\t${gray} --> ${yellow}Analyzing IP: ${magenta}$ip${off} ..." 
  local hostname
  hostname=$(dig +short -x "$ip")
  if [[ -z "$hostname" ]]; then
    echo -e "${magenta}Hostname: ${red}No associated domain name found${off} ... "
  else
    echo -e "${green}JOB:\t${gray} --> ${magenta}Hostname: ${green}$hostname${off}"
  fi

  $decorator_init
  echo -e "${green}JOB:\t${gray} --> ${magenta}Running ${yellow}[${cyan} traceroute ${yellow}] ${off}IP ${white}$ip${off} trace ...\n"
  traceroute_output=$(traceroute -n "$ip" 2>/dev/null)
  echo "$traceroute_output"

  local start_point
  local end_point
  start_point=$(echo "$traceroute_output" | awk 'NR==2')
  end_point=$(echo "$traceroute_output" | tail -n 1)
  echo -e "\n${green}RESULTS: ${gray}--> ${magenta}Start Point:${white}$start_point${off}"
  echo -e "${green}RESULTS: ${gray}--> ${green}End Point:\t ${white}$start_point${off}"

  $decorator_init
  echo -e "${green}JOB:\t${gray} --> ${magenta}Running ${yellow}[${cyan} MTR ${yellow}] ${off}IP ${white}$ip${off} stack trace ..."
  mtr_output=$(mtr --report "$ip" 2>/dev/null)
  echo -e "${cyan}MTR ${green}RESULTS:"
  $decorator_init
  echo -e "${white}$mtr_output${off}"
  $decorator_done
}

# ... main call: 
check_dependencies
$decorator_init
usr_prompt=$(echo -e "${yellow}\nEnter ${green}IP${off} you'd like to run the trace calls for:\n\t .... ${yellow}or${green} press ${yellow}Enter ${off}to see system ${green}IPs${off}:")
read -rp "$usr_prompt " user_ip
$decorator_init

if [[ -z "$user_ip" ]]; then
  echo -e "${red}No${off} IP provided:\t${gray}-->${yellow} Retrieving system IPs${off} ..."
  get_public_ip
  get_private_ip
  echo -e "${white} ... you can use the IPs above to ${yellow}rerun${off} the ${green}$(basename $0)${off} script${off} ..."
  $decorator_done
  exit 0
else
  echo -e "${green}JOB:\t${gray} --> ${yellow}Proceeding${off} with provided ${magenta}$user_ip IP${off} ... "
  trace_ip "$user_ip"
fi

