#!/bin/bash

# Color Codes and Decorators
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[0;31m"
blue="\033[1;34m"
pink="\033[1;35m"
off="\033[0m"
white="\033[1;37m"
yellow="\033[1;33m"

# Decorative lines
decorator_init=$(echo -e "${yellow}$(printf '.%.0s' {1..99})${off}")
decorator_done=$(echo -e "${white}$(printf '=%.0s' {1..172})${off}\n")
sys_decorator=$(echo -e "\t${red}$(printf '_%.0s' {1..100})$off")
job_stat=$(echo -e "${green}$(printf '.%.0s' {1..120})$off")

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

        # Updated regex to match IPs/hostnames and -> patterns
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
    # echo -e "$decorator_init"
    # echo "$job_stat"
    echo -e "\n${yellow}Enter${off} the process name as an ${pink}COMMAND${off} to check for: ${red}[${white}e.g${off}., ${pink}k9s ${off}|${pink} Slack ${off}| ${pink}ssh ${red}]${off}:"
    read command
    if [[ -z "$command" ]]; then
        echo -e "${red}Nothing ${off}was ${red}entered${off}!\n${green}Exiting${off} ...."
        echo -e "$decorator_done"
        exit 1
    fi

    # echo -e "$job_stat"
    echo -e "\n${yellow}Searching for ports used by ${white}$command${cyan}...${off}"
    matching_ports=$(lsof -i -P -n | grep "$command")
    
    if [[ -z "$matching_ports" ]]; then
        echo -e "\n${red}[ ${yellow}$command ${red}] ${white}Ports\t${red}Not ${off}found${off}:\n${green}Exiting${off} ...."
        echo -e "$decorator_done"
        exit 0
    fi

    echo -e "Existing ${green}Ports ${off} allocated for:${yellow} --> ${green}$command${off}:\n"
    echo "$matching_ports"
    # echo -e "$decorator_done"
    echo -e "$sys_decorator"
}

# ... kill process:
kill_process() {
    echo -ne "\t... ${red}kill${off} any ${pink}annoying${off} process ${yellow}(${green}y${off}/${red}n${yellow}) ? ${off}"
    read choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
        echo -ne "\t${yellow}Enter ${pink}PID process${off} to ${red}kill: ${off}"
        read pid
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


# if (name ~ /^([0-9]{1,3}\.){3}[0-9]{1,3}(:[0-9]+)?$/ || name ~ /^[a-zA-Z0-9.-]+(:[0-9]+)?$/) {
#             name = cyan name off;
#         }

# 🤨😎
# cockroach sql --url="postgresql://qusecure_admin:Change11me@cockroachdb-public.cockroach.svc.cluster.local:26257/goku_qusecure?sslmode=verify-ca&sslrootcert=/cockroach/cockroach-certs/ca.crt"

