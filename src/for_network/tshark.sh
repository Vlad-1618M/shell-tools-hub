#!/bin/bash
# ======================================================================================================================================
# Script Name: [ tshark.sh ] -- TShark Network Capture & Analysis Tool:
# Description:
#       This script provides an interactive way to capture network traffic using TShark, a cli version of Wireshark:
#       It guides users through:
#           - Detecting OS and package managers [ apt, yum, brew ]
#           - Checking if TShark is installed | if not will install it as needed:
#           - Listing available network interfaces and selecting one for monitoring:
#           - Capturing network traffic with optional file saving:
#           - Displaying TShark CLI help and useful commands from an external [ native_tshark_cli_help.cfg ] help file:
#
#   Usage:
#       ./tshark.sh
#       - Provides an option to display TShark CLI examples:
#       - If no help is needed, it proceeds to interface selection and packet capture:
#
#   Example:
#       - Run script: --> ./tshark.sh
#       - Select available interface from the list: [ e.g., `1` for `eth0`]
#       - Choose capture duration [ e.g., `60` seconds ]
#       - Optionally save captured packets to a file:
#
#   Sudo & Root Privileges:
#       - Running `tshark` [ may requires sudo ] to access detailed network scans:
#       - if sudo is need the `tshark` will [ prompt ] prior to scanning:
#
#   Compatibility:
#       - Ubuntu/Debian  
#       - RHEL/CentOS    
#       - macOS          
#   Prerequisites:
#       - `tshark` must be installed  → [ script installs it if missing ]
# ======================================================================================================================================
#   Some Info on TShark vs. Wireshark: What's the Difference?
#   Wireshark [ GUI-based ]
#       - A [ graphical network protocol analyzer ]
#       - Ideal for [ interactive packet analysis ], filtering, and exporting data:
#       - Requires a graphical interface:
#       - for more info see --> [ https://www.wireshark.org ] Website:
#
#   TShark    [ CLI-based ]
#       - A [ command-line ] version of Wireshark:
#       - Efficient for automation, scripting, and remote packet capture:
#       - Allows filtering, decoding, and exporting packets directly from the terminal:
#       - for more info see --> [ https://www.wireshark.org/docs/man-pages/tshark.html ] Website:
#
#  When to Use TShark ?
#   - When working on [ headless servers (no GUI) e.g onprem or cloud based Linux Distros/Imagies | Docker Containers ]
#   - When [ automating ] packet captures using custom scripts:
#   - When needing [ low-overhead network analysis ]
#
# ======================================================================================================================================
#   Useful HTTP Filtering Examples:
# ======================================================================================================================================
#
#   1️ - Capture only HTTP traffic:          --> [ sudo tshark -i eth0 -Y "http"                                                        ]
#   2 - Capture only GET & POST requests:   --> [ sudo tshark -i eth0 -Y "http.request.method"                                         ]
#   3 - Show full URLs in HTTP requests:    --> [ sudo tshark -i eth0 -T fields -e http.host -e http.request.uri                       ]
#   4 - Capture all HTTP and HTTPS packets: --> [ sudo tshark -i eth0 -f "port 80 or port 443"                                         ]
#   5 - Extract HTTP request headers:       --> [ sudo tshark -i eth0 -T fields -e http.request.method -e http.host -e http.user_agent ]
#
# --- More Filtering Examples ---   
#   - Wireshark Display Filters: --> [ https://wiki.wireshark.org/DisplayFilters ]
#   - TShark Capture Filters:    --> [ https://wiki.wireshark.org/CaptureFilters ]
# ======================================================================================================================================


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
decorator_init="echo -e ${gray}$(printf '_%.0s' {1..69})${off}"
decorator_done="echo -e ${gray}$(printf '=%.0s' {1..89})${off}"

# ... locate TShark help cfg file
find_tshark_help_file() {
    local search_file="native_tshark_cli_help.cfg"
    
    # ... call 'find'cli to search for the file in common locations:
    tshark_help_path=$(find $HOME -type f -name "$search_file" 2>/dev/null | head -n 1)

    # ... If not found, use predefined directories setup:
    if [[ -z "$tshark_help_path" ]]; then
        possible_paths=(
            "/shell-tools-hub/src/for_network/$search_file"
            "/src/for_network/$search_file"
            "/usr/local/share/$search_file"
            "/etc/$search_file"
        )
        
        for path in "${possible_paths[@]}"; do
            if [[ -f "$path" ]]; then
                tshark_help_path="$path"
                break
            fi
        done
    fi

    # ... final check | if file was found:
    if [[ -z "$tshark_help_path" ]]; then
        echo -e "\n${red}Error:${off} Unable to locate ${yellow}$search_file${off}\t Please ensure it exists:"
        exit 1
    fi
    echo -e "$tshark_help_path"  # ... return found path [ important! ]
}

# ... read to show TShark help and cli tips:
read_tshark_help() {
    # ... get thsar cfg help file path:
    t_help=$(find_tshark_help_file)

    # ... check if the file exists before reading:
    if [[ ! -f "$t_help" ]]; then
        echo -e "\n${red}Error:${off} Help file not found at: ${yellow}$t_help${off}"
        return 1
    fi

    # ... read print help file | use human like typing effect:
    while IFS= read -r line; do
        for (( i=0; i<${#line}; i++ )); do
            printf "%s" "${line:$i:1}"
            sleep 0.02
        done
        echo
    done < "$t_help"
}

# .... os and pgk check:
detect_os() {
    $decorator_init
    echo -e "OS${yellow} Check${off}:"
    # $decorator_init
    # echo -e "${gray}OS${yellow} | ${gray}Check${off}:"
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
                    echo -e "${red}Distribution not supported by this script.${off}"
                    exit 1
                    ;;
            esac
            echo -e "${magenta}OS ${yellow}| ${cyan}Detected\t${white} --> ${red}[${yellow} $NAME:${cyan} using ${yellow}$PACKAGE_MANAGER ${cyan}pkg manager${red} ]${off}"
            # echo -e "${green}JOB:\t${gray} --> ${magenta}OS ${yellow}| ${cyan}Detected\t${white} --> ${red}[${yellow} $NAME:${cyan} using ${yellow}$PACKAGE_MANAGER ${cyan}pkg manager${red} ]${off}"
        else
            echo -e "${red}Unable to detect Linux distribution.${off}"
            exit 1
        fi
    elif [[ "$OS" == "Darwin" ]]; then
        PACKAGE_MANAGER="brew"
        echo -e "${gray}OS Type: ${white}--> ${magenta}$(uname -a | awk '{print $1 , $2}')${off}"
        echo -e "\t ${white}--> ${off}Detected OS: ${cyan}macOS ${off}using Homebrew pkg manager:${off}"
    else
        echo -e "\t${cyan}OS${yellow} |${red} Not Supported${off}:"
        echo -e "\t${white}--> ${red}Unsupported ${magenta}OS${off} detected: $OS_TYPE${off}"
        $decorator_done
        exit 1
    fi
}

# .... tshark install check:
check_install_tshark() {
    local package_manager=$1
    if ! command -v tshark &> /dev/null; then
        echo -e "\n${red}tshark not found, installing${off} ..."
        echo -e "${yellow}Attempting installation on ${package_manager}${off}"
        case $package_manager in
            "yum")
                if [[ $NEED_EPEL -eq 1 ]]; then
                    echo -e "${yellow}Enabling EPEL repository${off} ..."
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
                echo -e "\n${red}Automatic installation not supported for this OS using ${yellow}$package_manager${off}."
                exit 1
                ;;
        esac
    else
        echo -e "\t ${white}--> ${magenta}tshark ${off}is already ${green}installed${off} on this system:"
        $decorator_init
        tshark_version=$(tshark -v)
        echo -e "${cyan}Version: ${grey}$tshark_version${off}"
        $decorator_init
    fi
}

# .... list and select network interfaces:
select_interface() {
    echo -e "${yellow}Enter ${cyan}int ${yellow}value ${off}located next to interface list below: ${red}[ ${white}e.g ${cyan}1 ${red} ]${off}:"
    $decorator_init
    tshark -D | awk '{ print NR ": " $0 }'
    $decorator_init
    msg="${yellow}Select ${cyan}interface ${yellow}value ${off}to monitor "
    echo -e "$msg" && read -p "" interface_num
    selected_interface=$(tshark -D | awk -v num="$interface_num" 'NR == num {print $2}')
    
    if [ -z "$selected_interface" ]; then
        echo -e "\n${yellow}[${red} $interface_num ${yellow}] ${off}<-- is ${red}Invalid ${cyan}interface ${red}selection.${off}"
        $decorator_done
        exit 1
    fi
    echo -e "${red}Selected ${cayn}interface:\t${white}--> ${yellow}[${green} $selected_interface ${yellow}]${off} list int value $cyan $interface_num${off}"
    $decorator_init
}

# .... set duration and run tshark:
run_tshark() {
    time_msg="${yellow}Select monitoring${cyan} duration ${yellow}in seconds${off}: "
    echo -e "$time_msg"
    read -p "" duration

    artifacts="${yellow}Save ${cyan}tshark ${yellow}output${off} to a file ? ${yellow}[ ${green}y${off} / ${red}n${yellow} ]${off}: "
    echo -e "$artifacts"
    read -p "" save_output

    if [ "$save_output" = "y" ]; then
        file_name="./tshark_output_$(date +%Y%m%d_%H%M%S).pcap"
        $decorator_init
        echo -e "\n${green}Starting Network Capture:${off} on ${yellow}[${green} $selected_interface ${off}for ${yellow}$duration ${green}seconds: ${yellow}] ${off}"
        sudo tshark -i "$selected_interface" -a duration:$duration -w "$file_name" 2>&1

        # ... determine current sys type - change file ownership accordingly:
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # ... system is macOS:
            sudo chown $(whoami):staff "$file_name"
        else
            # ... assume Linux Distros:
            sudo chown $(whoami):$(whoami) "$file_name"
        fi

        if [ $? -ne 0 ]; then
            $decorator_init
            echo -e "\n${green}$selected_interface ${off}Capture ${red}failed${off} or no packets were captured:\nCheck ${red}permissions ${off}or ${red}disk ${off}space:"
            $decorator_done
            exit 1
        fi
        $decorator_init
        echo -e "Output for ${green}$selected_interface${off} saved to: ${white} --> ${cyan}${file_name}${off}"
        read_file="\n${yellow}Decode${off} and read the output from the file ? ${yellow}[ ${green}y${off} / ${red}n${yellow} ]${off}: "
        echo -e "$read_file"
        read -p "" decode_output
        echo -e "\n${green}Starting capture on $selected_interface for $duration seconds${off} ..."

        if [ "$decode_output" = "y" ]; then
            tshark -r "$file_name"
        fi
    else
        sudo tshark -i "$selected_interface" -a duration:$duration
    fi
}


# .... main run:
main () {
    usr_prompt=$(echo -e "\n... ${yellow}need ${green}tshark example cli args${off} or ${magenta}doc ? ${gray}[ ${green}y${off}/${red}n ${gray}] ${off}")
    read -p "$usr_prompt " example
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
