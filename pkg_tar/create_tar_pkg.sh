#!/bin/bash
# ===============================================================================
# Script Name: create_tar_pkg.sh
#
# NOTE: This script counts directories and files in a given directory,
#       reports file counts by type, and creates a timestamped `.tar` archive.
#
# Description:
#       - Counts the total directories & files in the target directory.
#       - Reports the number of files per file type (extension-based).
#       - Creates a `.tar` archive with a timestamp (NO compression).
#       - Supports older Bash versions (removes `declare -A` issue).
#
# Usage:        ./create_tar_pkg.sh <directory_to_tar>
#
# Example:      ./create_tar_pkg.sh dirname
#               Output: dirname_2025-01-29_19-54-11.tar
#
# ===============================================================================

# ... color vars for output formatting:
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[0;31m"
yellow="\033[1;33m"
white="\033[1;37m"
off="\033[0m"

# ... decorators:
decorator_init="echo -e ${yellow}"$(printf '.%.0s' {1..60})"${off}"
decorator_done="echo -e ${white}"$(printf '=%.0s' {1..45})"${off}"


# ... generate a  timestamp | human-readable format:
get_timestamp() {
    date +"%Y-%m-%d_%H-%M-%S"
}

# ... count directories, files, and file types [ without associative arrays ]
count_and_report() {
    local dir=$1

    # ... count directories [ excluding the base directory itself ]
    local dir_count
    dir_count=$(find "$dir" -mindepth 1 -type d | wc -l)

    # ... get total files count:
    local file_count
    file_count=$(find "$dir" -type f | wc -l)

    # ... get file types count: 
    local file_list
    file_list=$(find "$dir" -type f -exec basename {} \; | awk -F. '{print $NF}' | sort | uniq -c)

    echo -e "Dir Total:   ${yellow}$dir_count${off}"
    echo -e "Files Total: ${yellow}$file_count${off}"
    $decorator_init
    echo -e "${cyan}File count ${off}by type:"
    echo -e "$file_list" | awk '{print $2 ": " $1}'
    $decorator_done
}

# ... run main:
main() {
    local target_dir=$1
    local parent_dir
    local timestamp
    local tar_file

    if [[ -z $target_dir || ! -d $target_dir ]]; then
        # $decorator_init
        echo -e "\n\t${green}$(basename $0)${off} script usage: < directory path to tar >"
        echo -e "\tCall Example: ${green}$(basename $0)${yellow} shell-tools-hub/${off}"
        $decorator_init
        exit 1
    fi

    parent_dir=$(basename "$target_dir")
    timestamp=$(get_timestamp)
    tar_file="${parent_dir}_${timestamp}.tar"

    echo -e "${yellow}\nCounting${off} directories & files ..."
    count_and_report "$target_dir"

    echo -e "${yellow}Creating tar file:${white}\t-->  ${green}$tar_file${off}"
    tar -cf "$tar_file" -C "$(dirname "$target_dir")" "$parent_dir"
}

main "$1"
