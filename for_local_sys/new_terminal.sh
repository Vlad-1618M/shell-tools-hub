#!/bin/bash

# ===============================================================================
# Script Name: open_terminal.sh
# Description: This script opens a new terminal session in the specified path.
#              It supports both macOS (using `osascript` and `open`) and Linux
#              (using `gnome-terminal` or `konsole`).
#
# Compatibility: macOS, Linux (GNOME, KDE)
# ===============================================================================

# ... decorator for visual separation in output:
decorator='echo -e "\t-------------------------------------------"'

# ...  open new terminal session | path specified:
get_new_terminal() {
    if [[ $# -eq 0 ]]; then
        $decorator
        echo -e "\tPath was not specified:\n\tStarting new terminal session in default path:"
        $decorator
        start_terminal "$PWD"
    else
        $decorator
        echo -e "\tStarting new terminal session in path:\n\t$1"
        $decorator
        start_terminal "$@"
    fi
}

# ... expand session window | start in a new path:
_new_terminal_expand_session_window() {
    if [[ $# -eq 0 ]]; then
        $decorator
        echo -e '\tPath was not specified:\n\tStarting new terminal session in default path:'
        $decorator
        start_terminal "$PWD" expand
    else
        $decorator
        echo -e "\tStarting new terminal session in path:\n\t$1"
        $decorator
        start_terminal "$1" expand
    fi
}

# ... OS check | open the terminal accordingly:
start_terminal() {
    local target_path="$1"
    local expand_mode="$2"

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # ... macOS Terminal:
        if [[ "$expand_mode" == "expand" ]]; then
            osascript -e "tell application \"Terminal\" to do script \"cd '$target_path'\""
            osascript -e "tell application \"Terminal\" to activate"
            osascript -e "tell application \"Terminal\" to tell window 1 to set bounds to {100, 100, 800, 600}"
        else
            open -a "Terminal" "$target_path"
        fi
    elif command -v gnome-terminal &>/dev/null; then
        # ... Linux GNOME Terminal:
        if [[ "$expand_mode" == "expand" ]]; then
            gnome-terminal -- bash -c "cd '$target_path'; exec bash"
        else
            gnome-terminal --working-directory="$target_path"
        fi
    elif command -v konsole &>/dev/null; then
        # ... KDE Konsole:
        konsole --workdir "$target_path" &
    else
        echo -e "\n${red}Error:${off} No supported terminal emulator found!"
        exit 1
    fi
}

# ___________ Execute the script with the provided arguments __________________

# ... uncomment function call you'd prefer to use:
# get_new_terminal "$@"
_new_terminal_expand_session_window "$@"

