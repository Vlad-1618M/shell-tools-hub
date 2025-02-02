#!/bin/bash

#####################################################################################################################
#  Script:  ports_ps_kill.sh
#  Purpose: Displays open ports, checks for processes using specific ports | allows user to kill unwanted processes:
#  Description:
#       - Lists active network ports and their statuses:
#       - Searches for a process by name to check its network usage:
#       - Provides an option to kill a selected process by PID:
#
#  Compatibility:
#       - Works on **Linux** and **macOS** (BSD `lsof` version differs).
#       - Uses `lsof`, `grep`, and `kill` (must be installed).
#
#  Prerequisites:
#       - Requires `lsof` for port listing.
#       - Must have appropriate permissions to kill processes.
#       - macOS users might need to install `lsof` using Homebrew (`brew install lsof`).
#
#####################################################################################################################

# ... color formatting for warnings:
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[0;31m"
blue="\033[1;34m"
pink="\033[1;35m"
off="\033[0m"
white="\033[1;37m"
yellow="\033[1;33m"

# ... decorators: for visual separation in output
decorator_init=$(echo -e "${yellow}$(printf '.%.0s' {1..99})${off}")
decorator_done=$(echo -e "${white}$(printf '=%.0s' {1..172})${off}\n")
sys_decorator=$(echo -e "\t${red}$(printf '_%.0s' {1..100})$off")
job_stat=$(echo -e "${green}$(printf '.%.0s' {1..120})$off")

# ... check for Linux or macOS compatibility
OS_TYPE=$(uname -s)

if [[ "$OS_TYPE" != "Linux" && "$OS_TYPE" != "Darwin" ]]; then
    echo -e "\n${red}Unsupported OS detected: ${yellow}$OS_TYPE${off}"
    exit 1
fi

# ... check if `lsof` is installed
if ! command -v lsof &> /dev/null; then
    echo -e "${red}Error:${off} 'lsof' is required but not installed."
    if [[ "$OS_TYPE" == "Darwin" ]]; then
        echo -e "${yellow}Install it using: ${cyan}brew install lsof${off}"
    else
        echo -e "${yellow}Install it using: ${cyan}sudo apt install lsof${off} (Debian-based) or ${cyan}sudo yum install lsof${off} (RHEL-based)"
    fi
    exit 1
fi

# ... display ports and status:
show_ports() {
    echo -e "\n${pink}Listening ${yellow}Ports${off} | ${pink} Status${off}:"
    lsof -i -P -n | awk -v yellow="${yellow}" -v green="${green}" -v pink="${pink}" -v red="${red}" -v cyan="${cyan}" -v off="${off}" '
    BEGIN {
        printf "%s\n", "'${decorator_done}'";
    }
    {
        command = $1;
        pid = $2;
        user = $3;
        fd = $4;
        type = $5;
        device = $6;
        size_off = $7;
        node_name = $8;
        name = $9;

        command = pink command off;
        pid = yellow pid off;

        if (node_name ~ /LISTEN/) {
            node_name = yellow "LISTEN" off;
        } else if (node_name ~ /ESTABLISHED/) {
            node_name = green "ESTABLISHED" off;
        } else if (node_name ~ /CLOSED/) {
            node_name = red "CLOSED" off;
        } else if (node_name ~ /CLOSE_WAIT/) {
            node_name = red "CLOSE_WAIT" off;
        }

        if (name ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}(:[0-9]+)?(->([0-9]{1,3}\.){3}[0-9]{1,3}(:[0-9]+)?)?$|^[a-zA-Z0-9.-]+(:[0-9]+)?$/) {
            name = cyan name off;
        }
        printf "%-27s %-18s %-10s %-10s %-10s %-30s %-9s %-10s\n", command, pid, user, fd, type, device, node_name, name;
    }'

    echo "$decorator_done"
    echo -e "${green} *** ${pink}End${off} of ${green}port${off} list ${green}***${off}"
}

# ... check for a specific PS and its ports:
check_command_ports() {
    echo -e "\n${yellow}Enter${off} the process name as an ${pink}COMMAND${off} to check for: ${red}[${white}e.g${off}., ${pink}k9s ${off}|${pink} Slack ${off}| ${pink}ssh ${red}]${off}:"
    read -r command
    if [[ -z "$command" ]]; then
        echo -e "${red}Nothing ${off}was ${red}entered${off}!\n${green}Exiting${off} ...."
        echo -e "$decorator_done"
        exit 1
    fi

    echo -e "\n${yellow}Searching for ports used by ${white}$command${cyan}...${off}"
    matching_ports=$(lsof -i -P -n | grep "$command")

    if [[ -z "$matching_ports" ]]; then
        echo -e "\n${red}[ ${yellow}$command ${red}] ${white}Ports\t${red}Not ${off}found${off}:\n${green}Exiting${off} ...."
        echo -e "$decorator_done"
        exit 0
    fi

    echo -e "Existing ${green}Ports ${off} allocated for:${yellow} --> ${green}$command${off}:\n"
    echo "$matching_ports"
    echo -e "$sys_decorator"
}

# ... kill process:
kill_process() {
    echo -ne "\t... ${red}kill${off} any ${pink}annoying${off} process ${yellow}(${green}y${off}/${red}n${yellow}) ? ${off}"
    read -r choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo -ne "\t${yellow}Enter ${pink}PID process${off} to ${red}kill: ${off}"
        read -r pid
        if [[ -z "$pid" ]]; then
            echo -e "\n${cyan}No PID entered:\t${green}Skipping ${off}..."
        else
            echo -e "\t${red}Killing ${yellow}$pid ${off}process ..."
            kill -9 "$pid" && echo -e "\t${yellow}$pid ${red}killed${green} successfully${off}:" || echo -e "\n\t ... ${red}Failed to kill [ ${yellow}$pid ]${off} process:"
            echo -e "$decorator_done"
        fi
    else 
        echo -e "\t... ok, there's always something to kill later ... 🤨\t${green}Skipping ${off}..."
    fi
}

# ... main logic
main(){
    show_ports
    check_command_ports
    kill_process
}
main
