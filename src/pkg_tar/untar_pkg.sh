#!/bin/bash
# ===============================================================================
# Script Name: untar_pkg.sh
#
# NOTE: This script extracts a `.tar` or `.tar.gz` archive.
#
# Description:
#       - Checks if the provided file exists and is a valid tar archive.
#       - Supports both compressed (`.tar.gz`) and uncompressed (`.tar`) files.
#       - Extracts the contents in the current directory.
#
# Usage:        ./untar_pkg.sh <tar_file>
#
# Example:      ./untar_pkg.sh archive.tar.gz
#               ./untar_pkg.sh archive.tar
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
decorator_init="echo -e ${yellow}\n"$(printf '.%.0s' {1..45})"${off}"
decorator_done="echo -e ${white}"$(printf '=%.0s' {1..45})"${off}"

# ... extract a tar file
main() {
    local tar_file=$1

    if [[ -z $tar_file || ! -f $tar_file ]]; then
        echo -e "\n\t${green}$(basename $0)${off} script usage: < tar_file >"
        echo -e "\tCall Example: ${green}$(basename $0)${yellow} shell-tools-hub.tar/${off}"
        exit 1
    fi

    echo -e "\n${yellow}Extracting ${cyan}$tar_file ${off}tar file:\n"
    
    # ... extract based on file type:
    case "$tar_file" in
        *.tar.gz|*.tgz) tar -xzf "$tar_file" ;;
        *.tar) tar -xf "$tar_file" ;;
        *)
            echo -e "\n\t${red}Unsupported ${off}file type.\n\t${white}Please provide a ${green}.tar ${off}or ${yellow}.tar.gz ${off}file:"
            exit 1
            ;;
    esac
}

$decorator_init
main "$1"

ls -asl 
$decorator_done

