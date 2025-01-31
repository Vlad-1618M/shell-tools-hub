#!/bin/bash

# ==============================================================================================================
# Script Name: smart_cat_highlighter.sh
# 
# Description:  This script simulates human typing by reading a file line by line 
#               with optional keyword highlighting and adjustable delay.
#
# Usage:        smart_cat_highlighter.sh <file> [start_line] [keyword] [color]
#               - file:        File to read.
#               - start_line:  Optional. Line number to start reading from (default: 1).
#               - keyword:     Optional. Keyword to highlight.
#               - color:       Optional. Highlight color (default: green). Choices: red, blue, yellow, cyan.
#
# ==============================================================================================================
# NOTE: 
# ... the name `smart_cat_highlighter` has nothing to do with Cats :0) 
# comes from `cat` or `concatenate` command in Linux / Unix-like systems:
#       - meaning to link things together in a sequence:
# In its original and intended use, `cat` was used to combine multiple files into one:
# Over time became a way to read file contents, which made `cat` one of the most commonly used commands. 
#
# Fun Fact: 
#              `cat` is often misused for simply viewing a file, 
#               when commands like `less`, `more`, or `head` might be much more efficient. 
#               This led to a famous term in the Linux community: "Useless Use of Cat" (UUOC) :0)
# ==============================================================================================================

# ... color vars for output formatting:
blue="\033[1;34m"
cyan="\033[1;36m"
green="\033[1;32m"
red="\033[1;31m"
yellow="\033[1;33m"
white="\033[1;37m"
off="\033[0m" # Reset color

# ... decorators: for visual separation in output
decorator_init="echo -e ${cyan}$(printf '_%.0s' {1..29})${off}"
decorator_done="echo -e \t${white}$(printf '=%.0s' {1..70})${off}"
decorator="echo -e ${cyan}\t$(printf '_%.0s' {1..29})${off}"

# ... simulate human typing | use ascci colorr for highlighting:
print_human_typing() {
    local file_to_read=$1
    local start_line=${2:-1}
    local keyword=${3:-} # If no keyword is provided, prompt for one
    local color=$4

    # ... file validation:
    if [[ ! -f "$file_to_read" ]]; then
        echo -e "\n${red}Error:${off} File '$file_to_read' not found."
        exit 1
    fi

    # ... line start validation:
    if ! [[ "$start_line" =~ ^[0-9]+$ ]] || [[ "$start_line" -lt 1 ]]; then
        echo -e "${red}Error:${off} Start line must be a positive number."
        exit 1
    fi

    # ... user prompt | keyword if not provided:
    if [[ -z "$keyword" ]]; then
        msg=$(echo -e "\n${yellow}Enter a ${white}keyword${off} to highlight:")
        read -p "$msg " keyword
    fi

    # ... user prompt | color if not provided:
    if [[ -z "$color" ]]; then
        echo -e "\nChoose a color for highlighting:"
        echo -e "\t${red}r${off} - Red"
        echo -e "\t${blue}b${off} - Blue"
        echo -e "\t${yellow}y${off} - Yellow"
        echo -e "\t${cyan}c${off} - Cyan"
        echo -e "\t${green}g${off} - Green (default)"
        cmsg=$(echo -e "\n\t... in what color should I ${yellow}highlight${off} the ${white}text${off} for you ?")
        read -p "$cmsg " color
        [[ -z "$color" ]] && color="green" # Default to green
    fi

    # ... codes mapping
    case $color in
        "r") color=$red ;;
        "b") color=$blue ;;
        "y") color=$yellow ;;
        "c") color=$cyan ;;
        g | green | "") color=$green ;; # Default to green
        *)
            echo -e "${red}Invalid color choice.${off} Please choose from r, b, y, c, g."
            exit 1
            ;;
    esac

    # ... output speed adjustment user prompt:
    smsg=$(echo -e "\t... how ${yellow}slow ${off}do I ${blue}delay${off} the read output ? ${yellow}[${green} in seconds, ${off}e.g., ${blue}0.1${yellow} ]${off} else, press ${green}Enter ${off}for instant output:")
    read -p "$smsg " sleep_time
    if [[ -z "$sleep_time" ]]; then
        sleep_time=0
    elif ! [[ "$sleep_time" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo -e "${red}Invalid delay. Using default value (0).${off}"
        sleep_time=0
    fi

    # ... timer init | counter init:
    local current_line=0
    local keyword_count=0
    local start_time=$(date +%s)

    # ... file content read and print:
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((current_line++))
        if [[ $current_line -lt $start_line ]]; then
            continue
        fi

        # ... highlight located keyword(s):
        if [[ -n "$keyword" && "$line" =~ $keyword ]]; then
            echo -e "${line//$keyword/${color}$keyword${off}}"
            ((keyword_count++))
        else
            echo "$line"
        fi

        # ... fun part |  simulate human typing in console output:
        if (( $(awk "BEGIN {print ($sleep_time > 0)}") )); then
            sleep "$sleep_time"
        fi
    done <"$file_to_read"

    # ... calculate total time:
    local end_time=$(date +%s)
    local total_time=$((end_time - start_time))

    # ... show summary:
    $decorator_done
    echo -e "\n\t${white}[${cyan} $(basename $0) ${white}]${off} script execution: ____ ${green}summary:${off}"
    echo -e "\t\tTotal: time${off} taken: ${yellow}${total_time} ${off}seconds:"
    echo -e "\t\tTotal: keywords:${white}[ ${yellow}${keyword} ${white}]${off} highlighted keywords found: ${cyan}${keyword_count}${off}"
    if [[ $keyword_count -eq 0 ]]; then
        echo -e "\t\t${red}No matches found for keyword:${off} ${yellow}${keyword}${off}"
    fi
    $decorator_done
}

# ... show usage msgs:
show_usage() {
    echo -e "\n\t${yellow} Usage:${off} for ${green}$(basename $0)${off} script:${cyan} file ${red}[${yellow} start_line ${red}] [${yellow} keyword ${red}] [${yellow} enable color ${red}]${off}"
    $decorator
    # echo -e "\n\t${red}Usage:${off} ${green}$0 <file> [start_line] [keyword] [color]${off}"
    echo -e "\t${red}[${yellow} file       ${red}]${cyan} - ${off}File to read."
    echo -e "\t${red}[${yellow} start_line ${red}]${cyan} - ${off}Optional. Line number to start reading from (default: 1)."
    echo -e "\t${red}[${yellow} keyword    ${red}]${cyan} - ${off}Optional. Keyword to highlight in the file."
    echo -e "\t${red}[${yellow} color      ${red}]${cyan} - ${off}Optional. Highlight color (default: green). Choices: red, blue, yellow, cyan."
    $decorator_done
    exit 1
}

# ... args input check: 
if [[ $# -lt 1 ]]; then
    show_usage
fi

# ... function call:
print_human_typing "$1" "$2" "$3" "$4"
