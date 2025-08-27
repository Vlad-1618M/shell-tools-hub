#!/bin/bash

# ===============================================================================
# Script Name: find_files.sh
# 
# NOTE: This script searches for files in the current directory and subdirectories 
#       based on a user-provided pattern. It utilizes the 'find' and 'grep' 
#       commands to locate matching files and highlights results for better 
#       readability.
#
# Description:  
#       - Prompts the user to enter a file name or pattern to search for.
#       - Uses 'find' to scan the current directory and subdirectories.
#       - Highlights the directory path and filename separately in output.
#       - Displays the total count of matching files.
#
# Usage:        Run [ ./find_files.sh script ] and enter a search pattern when prompted.
#
# ===============================================================================


search_file() {
    # ... color vars for output formatting:
    white="\033[1;37m"
    red="\033[0;31m"
    green="\033[0;32m"
    yellow="\033[0;33m"
    cyan="\033[1;36m"
    grey="\033[0;37m"
    _off="\033[0m"

    # ... decorators: for visual separation in output
    decorator_init="echo -e ${grey}$(printf '_%.0s' {1..70})${_off}\n"
    decorator_done="echo -e ${white}$(printf '=%.0s' {1..70})${_off}\n"

    # ... user prompt for search pattern:
    $decorator_init
    echo -e "${cyan}Enter${_off} the file ${white}name${_off} or ${white}pattern${_off} to ${white}search${_off} for:"
    echo -n "--> " # ... inline prompt:
    read pattern

    # ... pattern | check if provided:
    if [ -z "$pattern" ]; then
        echo -e "\n${red}No ${_off}pattern provided. Exiting..."
        $decorator_done
        return 1
    fi

    # ... call `find` and `grep` for a given pattern:
    echo -e "\n${yellow}Searching ${_off}for files matching ${cyan}'$pattern'${_off}..."
    $decorator_init
    result=$(find "$(pwd)" -type f | grep "$pattern")
    count=$(echo "$result" | wc -l) # ... count matching files:

    # ... check files | if found show result:
    if [ -z "$result" ]; then
        echo -e "${red}No ${_off}files matching ${red}'$pattern'${_off} were found."
    else
        # $decorator_init
        echo -e "${cyan}Total Paths Found:${yellow} -> ${green}$count${_off}\n"
        echo "$result" | while read -r file; do
            # Highlight directory path and filename separately
            dir_path=$(dirname "$file")
            filename=$(basename "$file")
            echo -e "${green}$dir_path${_off}/${white}$filename${_off}"
        done
        $decorator_done
    fi
}

search_file
