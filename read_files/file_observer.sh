#!/bin/bash
#
# ===============================================================================
#  FILE: file_observer.sh
#  DESCRIPTION:
#      A real-time log file monitoring script for Linux/macOS.
#      Uses `tail -Fn0` to track file updates dynamically, detects idle states,
#      and exits if no changes occur within a set time.
#
#  FEATURES:
#      - Monitors file changes in real-time:
#      - Supports both Linux and macOS [ `stat` compatibility ]:
#      - Tracks modification timestamps and file size changes:
#      - Handles idle timeout and auto-exit conditions:
#      - Provides detailed summary reports on exit:
#      - Clean signal handling using `trap`:
#
#  USAGE:
#      ./file_observer.sh <logfile>
#
#  EXAMPLES:
#      ./file_observer.sh /var/log/system.log
#      ./file_observer.sh /tmp/test.log
#
#  REQUIREMENTS:
#      - Bash 4.x+ [ for associative arrays and improved scripting behavior ]:
#      - A readable log file to monitor:
#
# ===============================================================================

# Time control variables:
IDLE_RESET_TIME=3               # ... Seconds before switching back to idle state
EXIT_IDLE_TIME=${2:-300}        # ... Default to 5 minutes (300 seconds) before exiting due to no changes

# ... color vars used in Output Formatting:
gray='\033[1;90m'
white='\033[1;97m'
yellow='\033[1;93m'
green='\033[1;92m'
orange='\033[1;91m'
magenta='\033[1;95m'
cyan='\033[1;96m'
red="\033[1;31m"
off="\033[0m"

# ... decorators: for visual separation in output
decorator_init="echo -e ${gray}$(printf '_%.0s' {1..111})${off}"
decorator_done="echo -e ${white}$(printf '=%.0s' {1..111})${off}\n"

# ...`stat` calls based on OS type: Mac | Most of Linux Distros:
if [[ "$OSTYPE" == "darwin"* ]]; then
    os_name="macOS"
    get_mod_time() { stat -f "%m" "$1" 2>/dev/null || echo 0; } # macOS: Last modification timestamp
    get_file_size() { stat -f "%z" "$1" 2>/dev/null || echo 0; } # macOS: File size in bytes
else
    os_name="Linux"
    get_mod_time() { stat -c "%Y" "$1" 2>/dev/null || echo 0; } # Linux: Last modification timestamp
    get_file_size() { stat --format="%s" "$1" 2>/dev/null || echo 0; } # Linux: File size in bytes
fi

# ... vars setup for data tracking / metrics:
START_TIME=$(date +%s)
ITERATIONS=0
CHANGES=0

# ... file input check:
validate_file() {
    local file_path="$1"

    if [[ -z "$file_path" ]]; then
        $decorator_init
        echo -e "\n\t${red}Error: ${off}No file specified:\tProvide a valid path: ${orange}path/to/logfile.log${off}"
        echo -e "\t${yellow}$(basename $0)${off} script call example:\t${white}--> ${red}[ ${yellow}$(basename $0) ${orange}path/to/${green}some/file/name${gray}.log ${white}.cfg ${green}.ini${off} ${red}]${off}"
        $decorator_done
        exit 1
    fi

    if [[ ! -f "$file_path" ]]; then
        $decorator_init
        echo -e "\n${red}Error: ${off}File path ${red}[${gray} $file_path ${red}]${off} does not exist or is inaccessible:"
        echo -e "\n${white}Check if file exists:\n${yellow}Run${off} this in your terminal:${white} --> ${gray}[[ -f your/file/path/file.log ]] && echo \"File exists\" || echo \"\t...nope File not found ¯\_(ツ)_/¯\"${off}"
        echo -e "\n${white}Check file permissions:"
        echo -e "${yellow}Run${off} this in your terminal${white} --> ${gray}[[ -r your/file/path/file.log ]] && echo \"Readable\" || echo \"\t...nope Not readable ¯\_(ツ)_/¯\"${off}"
        echo -e "${yellow}Run${off} this in your terminal${white} --> ${gray}[[ -w your/file/path/file.log ]] && echo \"Writable\" || echo \"\t...nope Not writable ¯\_(ツ)_/¯\"${off}"
        echo -e "${yellow}Run${off} this in your terminal${white} --> ${gray}[[ -x your/file/path/file.log ]] && echo \"Executable\" || echo \"\t...nope Not executable ¯\_(ツ)_/¯\"${off}"
        $decorator_done
        exit 1
    fi
}

# .. get timestamps:
get_timestamp() {
    date '+%Y-%m-%d %H:%M:%S'
}

# ... catch and show init file state:
print_initial_state() {
    local file="$1"
    local size
    size=$(get_file_size "$file")
    # echo -e "\n${gray}[$(get_timestamp)] Monitoring started for: $file | Size: ${size} bytes | ${orange}OS: ${green}$os_name${off}"
    echo -e "\n${gray}[$(get_timestamp)] ${white}Keeping Tabs on ${magenta}$file${off} | Detected File Size: ${magenta}${size}${off} bytes | ${orange}OS: ${green}$os_name${off}"
    $decorator_init
}

# ... trap setup | helsp with the clean up around `tail` process sys exit:
trap 'kill $tail_pid 2>/dev/null; exit_summary "$1"; exit 0' SIGINT SIGTERM

# ... background file monitor | using`tail` runtime:
monitor_file() {
    local file="$1"
    local prev_size=$(get_file_size "$file")
    local last_update=$(get_mod_time "$file")
    local last_activity=$(date +%s)
    local idle_timer=0

    # ... os based `tail` switch: 
    if [[ "$OSTYPE" == "darwin"* ]]; then
        tail_cmd="tail -Fn0 \"$file\""                    # .. no `--retry` if macOS: 
    else
        tail_cmd="tail --retry -Fn0 \"$file\""
    fi

    # ... run `tail` in background | get its PID:
    eval "$tail_cmd" | awk '{ gsub(/\x1B\[[0-9;]*[mGKF]/, ""); print }' | while read -r line; do
        local current_time=$(date +%s)
        local file_size=$(get_file_size "$file")
        local mod_time=$(get_mod_time "$file")

        if [[ "$file_size" -ne "$prev_size" || "$mod_time" -ne "$last_update" ]]; then
            CHANGES=$((CHANGES + 1))
            echo "$CHANGES" > /tmp/changes_count          # ... persist changes count:
            prev_size="$file_size"
            last_update="$mod_time"
            last_activity="$current_time"
            idle_timer=0                                  # ... idle timer reset

            echo -e "${orange}[$(get_timestamp)] ${cyan}File Updated: ${yellow}${file_size}${off} bytes${white}:${off}"
            echo -e "${green}$line${off}"
        fi
    done &

    tail_pid=$!                                           # ... store `tail` PsPID:

    # ... independent file change(s) monitor:
    while true; do
        ITERATIONS=$((ITERATIONS + 1))                    # ... persistant loop iteration counter:
        sleep 1
        local current_time=$(date +%s)
        local file_size=$(get_file_size "$file")
        local mod_time=$(get_mod_time "$file")

        if [[ "$file_size" -eq "$prev_size" && "$mod_time" -eq "$last_update" ]]; then
            idle_timer=$((current_time - last_activity))
            if ((idle_timer >= EXIT_IDLE_TIME)); then
                $decorator_init
                echo -e "To adjust ${white}Idle${off} timer in ${yellow}[${off} $(basename $0) ${yellow}]${off} script, Locate the ${gray}Time control variables:${off} Code line #31 ${gray}EXIT_IDLE_TIME ${off}"
                kill "$tail_pid" 2>/dev/null
                CHANGES=$(cat /tmp/changes_count 2>/dev/null || echo 0)  # ... get final CHANGES count:
                exit_summary "$file"
                rm -f /tmp/changes_count
                exit 0
            elif ((idle_timer >= IDLE_RESET_TIME)); then
                echo -e "${gray}[$(get_timestamp)] ${white}Idle - ${gray}Waiting for new data ${white}| ${orange}Size:${yellow} ${file_size} ${off}bytes: ${white} | ${gray}${ITERATIONS} ${off}"
            fi
        else
            last_activity="$current_time"
            prev_size="$file_size"
            last_update="$mod_time"
        fi
    done
}


# ... exit summary report:
exit_summary() {
    local file="$1"
    local final_size=$(get_file_size "$file")
    local total_time=$(( $(date +%s) - START_TIME ))
    
    echo -e "\n${magenta}----------------- Process Summary --------------------- ${off}"
    echo -e "${white}File  Monitored:${off} \t${magenta}$(basename $file)${off}"
    echo -e "${white}Final File Size:${off} \t${red}${final_size} ${off}bytes:"
    echo -e "${white}Total Iterations:${off} \t${gray}${ITERATIONS}${off}"
    echo -e "${white}Total Changes Detected:${off} ${magenta}${CHANGES}${off}"
    echo -e "${white}Total Operation Time:${off} \t${green}${total_time}${off} seconds:"
    $decorator_done
}

# ... main call:
main() {
    local file_path="$1"
    validate_file "$file_path"
    print_initial_state "$file_path"
    monitor_file "$file_path"
}

# ... run script + file path:
main "$1"
