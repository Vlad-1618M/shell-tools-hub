
########################################################################################################################
#!/bin/bash

# Color code definitions
cyan="\033[1;36m"
blue="\033[1;34m"
white="\033[1;37m"
yellow="\033[1;33m"
grey="\033[0;37m"
GREEN="\033[1;32m"
RED="\033[0;31m"
NC="\033[0m"  # No Color

# Decorative lines
decorator_init=$(echo "${white}$(printf '.%.0s' {1..50})${NC}")
decorator_done=$(echo "${grey}$(printf '=%.0s' {1..45})${NC}\n")

t_src="/$HOME/DEV/Network_Tools/tshark_tools"
t_file="native_tshark_cli_help.txt"

# .... optinoal help | Vlad's cli picks:
read_tshark_help() {
    t_help="${t_src}/${t_file}"
    
    if [[ ! -f "$t_help" ]]; then
        echo "File not found: $t_help"
        return 1
    fi

    while IFS= read -r line; do
        for (( i=0; i<${#line}; i++ )); do
            # echo -n "${line:$i:1}"
            printf "%s" "${line:$i:1}"
            sleep 0.02
        done
        echo
    done < "$t_help"
}

# .... os and pgk check:
detect_os() {
    echo $decorator_init
    echo "\n\t${cyan}OS${yellow} | ${cyan}Check${NC}:"
    OS=$(uname -s)
    if [[ "$OS" == "Linux" ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            case $ID in
                ubuntu|debian)
                    PACKAGE_MANAGER="apt"
                    ;;
                fedora|centos|rhel)
                    PACKAGE_MANAGER="yum"
                    if [[ $ID != "fedora" ]]; then
                        NEED_EPEL=1
                    fi
                    ;;
                *)
                    echo "${RED}Distribution not supported by this script.${NC}"
                    exit 1
                    ;;
            esac
            echo "\t${cyan}OS ${yellow}| ${cyan}Detected\t${white} --> ${RED}[${yellow} $NAME:${cyan} using ${yellow}$PACKAGE_MANAGER ${cyan}pkg manager${RED} ]${NC}"
        else
            echo "${RED}Unable to detect Linux distribution.${NC}"
            exit 1
        fi
    elif [[ "$OS" == "Darwin" ]]; then
        PACKAGE_MANAGER="brew"
        echo "${YELLOW}Detected OS: macOS using Homebrew${NC}"
    else
        echo "\t${cyan}OS${yellow} |${RED} Not Supported${NC}:"
        echo $decorator_done
        exit 1
    fi
}

# .... tshark install check:
check_install_tshark() {
    local package_manager=$1
    if ! command -v tshark &> /dev/null; then
        echo "\n${RED}tshark not found, installing...${NC}"
        echo "${YELLOW}Attempting installation on ${package_manager}${NC}"
        case $package_manager in
            "yum")
                if [[ $NEED_EPEL -eq 1 ]]; then
                    echo "${YELLOW}Enabling EPEL repository...${NC}"
                    sudo yum install epel-release -y
                fi
                sudo yum update && sudo yum install wireshark-cli -y
                ;;
            "apt")
                sudo apt-get update && sudo apt-get install tshark -y
                ;;
            "brew")
                brew install wireshark
                ;;
            *)
                echo "\n${RED}Automatic installation not supported for this OS using ${yellow}$package_manager${NC}."
                exit 1
                ;;
        esac
    else
        echo "\t${cyan}tshark ${NC}is already ${GREEN}installed on this system:${NC}"
        echo $decorator_init
        tshark_version=$(tshark -v)
        echo "${cyan}Version: ${grey}$tshark_version${NC}"
        echo $decorator_init
    fi
}

# .... list and select network interfaces:
select_interface() {
    echo "\n\t${yellow}Enter ${cyan}int ${yellow}value ${NC}located next to interface list below: ${RED}[ ${white}e.g ${cyan}1 ${RED} ]${NC}:"
    echo $decorator_init
    tshark -D | awk '{ print NR ": " $0 }'
    echo $decorator_init
    msg="\n\t${yellow}Select ${cyan}interface ${yellow}value ${NC}to monitor "
    echo "$msg" && read -p "" interface_num
    selected_interface=$(tshark -D | awk -v num="$interface_num" 'NR == num {print $2}')
    
    if [ -z "$selected_interface" ]; then
        echo "\n${yellow}[${RED} $interface_num ${yellow}] ${NC}<-- is ${RED}Invalid ${cyan}interface ${RED}selection.${NC}"
        echo $decorator_done
        exit 1
    fi
    # echo "\n${RED}Selected ${cayn}interface:\t${white}--> ${yellow}[${GREEN} $selected_interface ${yellow}]${NC} list int value $cyan $interface_num${NC}"
    echo $decorator_init
}

# .... set duration and run tshark:
# run_tshark() {
#     time_msg="\n\t${yellow}Select monitoring${cyan} duration ${yellow}in seconds${NC}: "
#     echo "$time_msg"
#     read -p "" duration

#     artifacts="\t${yellow}Save ${cyan}tshark ${yellow}output${NC} to a file ? ${yellow}[ ${GREEN}y${NC} / ${RED}n${yellow} ]${NC}: "
#     echo "$artifacts"
#     read -p "" save_output

#     if [ "$save_output" = "y" ]; then
#         # file_name="/tmp/tshark_output_$(date +%Y%m%d_%H%M%S).pcap"
#         file_name="./tshark_output_$(date +%Y%m%d_%H%M%S).pcap"
#         echo $decorator_init
#         echo "\n${GREEN}Starting Network Capture:${NC} on ${yellow}[${GREEN} $selected_interface ${NC}for ${yellow}$duration ${GREEN}seconds: ${yellow}] ${NC}"
#         sudo tshark -i "$selected_interface" -a duration:$duration -w "$file_name" 2>&1

#         if [ $? -ne 0 ]; then
#             echo $decorator_init
#             echo "\n${GREEN}$selected_interface ${NC}Capture ${RED}failed${NC} or no packets were captured:\nCheck ${RED}permissions ${NC}or ${RED}disk ${NC}space:"
#             echo $decorator_done
#             exit 1
#         fi
#         echo $decorator_init
#         echo "\nOutput for ${GREEN}$selected_interface${NC} saved to: ${white} --> ${cyan}${file_name}${NC}"
#         read_file="\n${yellow}Decode${NC} and read the output from the file ? ${yellow}[ ${GREEN}y${NC} / ${RED}n${yellow} ]${NC}: "
#         echo "$read_file"
#         read -p "" decode_output
#         echo "${GREEN}Starting capture on $selected_interface for $duration seconds...${NC}"


#         if [ "$decode_output" = "y" ]; then
#             tshark -r "$file_name"
#         fi
#     else
#         sudo tshark -i "$selected_interface" -a duration:$duration
#     fi
# }
run_tshark() {
    time_msg="\n\t${yellow}Select monitoring${cyan} duration ${yellow}in seconds${NC}: "
    echo "$time_msg"
    read -p "" duration

    artifacts="\t${yellow}Save ${cyan}tshark ${yellow}output${NC} to a file ? ${yellow}[ ${GREEN}y${NC} / ${RED}n${yellow} ]${NC}: "
    echo "$artifacts"
    read -p "" save_output

    if [ "$save_output" = "y" ]; then
        file_name="./tshark_output_$(date +%Y%m%d_%H%M%S).pcap"
        echo $decorator_init
        echo "\n${GREEN}Starting Network Capture:${NC} on ${yellow}[${GREEN} $selected_interface ${NC}for ${yellow}$duration ${GREEN}seconds: ${yellow}] ${NC}"
        sudo tshark -i "$selected_interface" -a duration:$duration -w "$file_name" 2>&1

        # Determine the operating system and change file ownership accordingly
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # System is macOS
            sudo chown $(whoami):staff "$file_name"
        else
            # Assume system is Linux
            sudo chown $(whoami):$(whoami) "$file_name"
        fi

        if [ $? -ne 0 ]; then
            echo $decorator_init
            echo "\n${GREEN}$selected_interface ${NC}Capture ${RED}failed${NC} or no packets were captured:\nCheck ${RED}permissions ${NC}or ${RED}disk ${NC}space:"
            echo $decorator_done
            exit 1
        fi
        echo $decorator_init
        echo "\nOutput for ${GREEN}$selected_interface${NC} saved to: ${white} --> ${cyan}${file_name}${NC}"
        read_file="\n${yellow}Decode${NC} and read the output from the file ? ${yellow}[ ${GREEN}y${NC} / ${RED}n${yellow} ]${NC}: "
        echo "$read_file"
        read -p "" decode_output
        echo "${GREEN}Starting capture on $selected_interface for $duration seconds...${NC}"

        if [ "$decode_output" = "y" ]; then
            tshark -r "$file_name"
        fi
    else
        sudo tshark -i "$selected_interface" -a duration:$duration
    fi
}


# .... main run:
main () {
    read -p "... need tshark example cli args or doc ? (y/n) " example
    if [ "$example" == "y" ]; then
        read_tshark_help
    else
        detect_os
        check_install_tshark $PACKAGE_MANAGER
        select_interface
        run_tshark
    fi
}

main
# read_tshark_help
# this_script_dir=$(dirname $1)
# echo "\n$this_script_dir"
# echo $(dirname -- $1)