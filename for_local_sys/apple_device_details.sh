#!/bin/bash

# ===============================================================================
# Script Name: apple_device_details.sh
# Description: This script detects and displays various system details including:
#              - Processor type
#              - Shell type and version
#              - Bash version
#              - Homebrew installation details (if available)
# ===============================================================================

# ... color vars for output formatting:
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[0;31m"
yellow="\033[1;33m"
white="\033[1;37m"
off="\033[0m"

# ... decorators:
decorator_init="echo -e ${yellow}"$(printf '.%.0s' {1..40})"${off}"
decorator_done="echo -e ${white}"$(printf '=%.0s' {1..65})"${off}"

# ...  detect processor type:
detect_processor() {
    # echo -e "\nDetecting processor type${off}..."
    processor=$(uname -m)
    if [[ "$processor" == "arm64" ]]; then
        echo -e "${green}Apple Silicon:\t ${red}[ ${cyan}arm64${red} ]${off}"
    elif [[ "$processor" == "x86_64" ]]; then
        echo -e "Processor:\t ${green}Intel ${red}[${cyan}x86_64${red}]${off}"
    else
        echo -e "Processor:\t Unknown ${red}[${yellow}$processor${red}]${off}"
    fi
}

# ...  shell type | version:
detect_shell() {
    # echo -e "\n${cyan}Detecting shell and version...${off}"
    current_shell=$(ps -p $$ -o comm=)
    shell_version=$($current_shell --version 2>/dev/null | head -n 1)
    if [[ -n "$shell_version" ]]; then
        echo -e "Shell:\t\t ${red}[ ${cyan}$current_shell${red} ]${off}"
        echo -e "Version:\t ${red}[ ${cyan}$shell_version${red} ]${off}"
    else
        echo -e "Shell:\t --> ${white}$current_shell${off} ... version information not available:"
    fi
}

# ...  check bash version:
detect_bash_version() {
    # echo -e "\n${cyan}Checking bash version...${off}"
    if command -v bash >/dev/null 2>&1; then
        bash_version=$(bash --version | head -n 1)
        echo -e "\n${green}Bash Version:${off} ${cyan}$bash_version${off}"
    else
        echo -e "${red}Bash is not installed on this system.${off}"
    fi
}

# ... check if Homebrew is installed | details if true:
detect_brew() {
    # echo -e "\n${cyan}Checking Homebrew installation...${off}"
    if command -v brew >/dev/null 2>&1; then
        brew_version=$(brew --version | head -n 1)
        echo -e "${green}Homebrew Version:${off} ${cyan}$brew_version${off}"
        echo -e "\nListing ${yellow}installed libraries${off} and ${yellow}CLI ${off}tools ..."
        brew list | while read -r line; do
            echo -e "${yellow} - $line${off}"
        done
        echo -e "\nAvailable ${yellow}Homebrew${off} CLI Arguments:"
        $decorator_init
        brew help | head -n 10
        $decorator_init
    else
        echo -e "${red}Homebrew is not installed on this system.${off}"
    fi
}

# ... main script call:
echo -e "\n\t${cyan}Device Details Script${off}"
$decorator_init
detect_processor
detect_shell
detect_bash_version
detect_brew

echo -e "${green}Script execution completed successfully.${off}\n"
exit 0
