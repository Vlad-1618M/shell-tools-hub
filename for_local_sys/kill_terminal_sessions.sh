#!/bin/bash

# ===============================================================================
# Script Name: kill_terminal_sessions.sh
# Description: This script forcefully closes all running terminal sessions on macOS.
#              It supports both Terminal.app and iTerm2.

# Warning: !!! --> Running this script will close ALL active terminal sessions!
# ===============================================================================

# ... color formatting for warnings:
red="\033[0;31m"
yellow="\033[1;33m"
green="\033[1;32m"
off="\033[0m"

# ... throw warning | ask for confirmation:
confirm_action() {
    echo -e "\n${yellow}Warning: This will close ALL active terminal sessions.${off}"
    read -rp "Are you sure ? ... should I continue? (yes/no): " confirm
    case "$confirm" in
        [yY][eE][sS] | [yY]) 
            echo -e "${green}Proceeding to close all terminals...${off}"
            ;;
        *)  
            echo -e "${red}Operation aborted. No terminal sessions were closed.${off}"
            exit 1
            ;;
    esac
}

# ... close a specific terminal application:
close_terminal() {
    local app_name="$1"
    local pids="$2"

    if [ -n "$pids" ]; then
        echo -e "${yellow}Closing all $app_name sessions...${off}"
        echo "Running $app_name session PIDs: $pids"

        # ... Loop through each ps-ID | close terminal application:
        for pid in $pids; do
            kill "$pid"
        done

        echo -e "${green}All $app_name sessions closed.${off}"
    else
        echo -e "${yellow}No active $app_name sessions found.${off}"
    fi
}

# ... close all terminal applications:
main_kill() {
    confirm_action
    terminal_pids=$(pgrep Terminal)                                  # ... get ps-IDs of all sys native terminal sessions:
    close_terminal "Terminal" "$terminal_pids"                       # ... close terminal sessions:
    iterm_pids=$(pgrep iTerm2)                                       # ... get ps-IDs of all iTerm sessions:
    close_terminal "iTerm" "$iterm_pids"                             # ... close terminal sessions:
    osascript -e 'tell application "Terminal" to quit' 2>/dev/null   # ... AppleScript | close sys native terminal 
    osascript -e 'tell application "iTerm" to quit' 2>/dev/null      # ... AppleScript | close iTerm 
}

# ... run main: 
main_kill
