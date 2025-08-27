#!/bin/bash
# ==============================================================================================================
# Script Name: [ vmstats.sh ] System Memory & CPU Monitoring [ vmstat / vm_stat ]
#   Description:
#       This script monitors memory and CPU statistics: 
#        --> using `vmstat`  on [ Linux Distros ]
#        --> using `vm_stat` on [ macOS         ] 
#       It provides real-time system insights with color-coded output based on usage thresholds:
#
#   Features:
#       - Detects the OS type and selects the appropriate command []`vmstat` or `vm_stat`]
#       - Checks if the required cli is installed | will install if not found:
#       - Allows users to set a monitoring interval and iteration count:
#       - Displays system statistics with [ color-coded values ]
#
#   Usage:
#       ./vmstats.sh [ time_interval ] [ iteration_count ]
#
#   Example:
#       - Monitor every [0.5 seconds ] for [ 10 iterations ]
#       ./vmstats.sh 0.5 10
#
# ==============================================================================================================
#   More Info on  `vmstat` vs `vm_stat`: What's the Difference?
#
#   `vmstat` in [ Linux Distros ]
#       - Displays [ CPU, memory, I/O ] and system performance statistics:
#       - Comes [ pre-installed on most Linux distributions ] package name: `procps`
#       - Command usage:
#           [ vmstat 1 5 -t -w ]
#       - Documentation: https://man7.org/linux/man-pages/man8/vmstat.8.html
#
#  `vm_stat` in [ macOS ]
#       - Provides [ virtual memory statistics ]
#       - Displays [ page activity instead of CPU stats --> unlike Linux `vmstat`]
#       - Requires [ Xcode command-line tools ] on macOS:
#       - Command usage:
#           [ vm_stat 1 ]
#       - Documentation: https://stackoverflow.com/questions/14150626/understanding-vm-stat-in-mac-os-how-to-convert-those-numbers-to-something-simil
#                        https://www.oreilly.com/library/view/mac-os-x/0596003560/ch08s01s05.html
#                        https://developer.apple.com/library/archive/documentation/Performance/Conceptual/ManagingMemory/Articles/VMPages.html       
#
#   Key Differences:
#       `vmstat` in  [ Linux Distros ] shows      [ CPU, disk, and memory activity                ]
#       `vm_stat` in [ macOS         ] focuses on [ memory paging ] [ free, active, inactive pages]
# ==============================================================================================================


# ... color formatting for warnings:
gr='\033[1;32m'    # Green
cy='\033[1;36m'    # Cyan
yl='\033[1;33m'    # Yellow
rd='\033[0;31m'    # Red
wt='\033[1;37m'    # White
gry='\033[0;37m'   # Gray
coff='\033[0m'     # No color

# ... decorators: for visual separation in output
decorator_init="echo -e ${yl}"$(printf '.%.0s' {1..70})"${coff}"
decorator_done="echo -e ${gry}"$(printf '=%.0s' {1..70})"${coff}"

# ... instructions
usage() {
    echo -e "\n\t${gr}Usage${coff} for ${yl}$(basename $0)${coff} script:"
    echo -e "\tArguments expected: [ ${wt}time_interval${coff} ] & [ ${wt}iteration_count${coff} ]"
    echo -e "\tCall Example: ${yl}$(basename $0)${wt} 0.5 ${cy}10${coff}\n"
    $decorator_done
    exit 1
}

# ... check for vm_stat or vmstat availability:
check_vmstat() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if ! command -v vm_stat &>/dev/null; then
            echo -e "${rd}Error: 'vm_stat' is not available on macOS.${coff}"
            echo -e "${yl}Ensure Xcode command line tools are installed with:${coff} ${gr}xcode-select --install${coff}"
            exit 1
        fi
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if ! command -v vmstat &>/dev/null; then
            echo -e "${rd}Error: 'vmstat' is not installed on Linux.${coff}"
            echo -e "${yl}Attempting to install it automatically...${coff}"
            if command -v apt-get &>/dev/null; then
                sudo apt-get update && sudo apt-get install -y procps
            elif command -v yum &>/dev/null; then
                sudo yum install -y procps
            else
                echo -e "${rd}Error: Unable to determine the package manager. Install 'vmstat' manually.${coff}"
                exit 1
            fi
        fi
    else
        echo -e "${rd}Unsupported OS. Please ensure 'vmstat' or 'vm_stat' is installed.${coff}"
        exit 1
    fi
}

# ... set color thresholds for output:
colorize_output() {
    local value=$1
    local threshold_low=$2
    local threshold_high=$3
    local output="$value"

    if (( $(echo "$value > $threshold_high" | bc -l) )); then
        echo -e "${rd}$output${coff}"       #  ... high consumption    [ red    ]
    elif (( $(echo "$value > $threshold_low" | bc -l) )); then
        echo -e "${yl}$output${coff}"       # ... moderate consumption [ yellow ]
    else
        echo -e "${gr}$output${coff}"       # ... low consumption      [ green  ]
    fi
}

# ... run  check before proceeding:
check_vmstat

# ... args check:
if [ "$#" -ne 2 ]; then
    usage
fi

# ... parse args:
TIME_INTERVAL=$1
ITER_COUNT=$2

if ! [[ "$TIME_INTERVAL" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$ITER_COUNT" =~ ^[0-9]+$ ]]; then
    echo -e "${rd}Error: TIME_INTERVAL must be a positive decimal and ITER_COUNT must be a positive integer.${coff}"
    usage
fi

echo -e "\n\tRunning ${gr}vm_stat${coff} or ${gr}vmstat${coff} call with:"
echo -e "\t${cy}Interval: ${yl}${TIME_INTERVAL}${coff} seconds${cy}, Iterations: ${yl}${ITER_COUNT}${coff}\n"

# ... run based on OS type:
if [[ "$OSTYPE" == "darwin"* ]]; then
    # ... if macOS vm_stat:
    vm_stat -c $ITER_COUNT $TIME_INTERVAL | while IFS= read -r line; do
        # ... skip header:
        if [[ "$line" == *"Mach Virtual Memory Statistics"* ]]; then
            echo -e "${cy}$line${coff}"
            continue
        fi
        # ... parse key-value pairs:
        if [[ "$line" =~ ^Pages\ free:\ *([0-9]+) ]]; then
            free_pages=${BASH_REMATCH[1]}
            echo -e "Free Pages: $(colorize_output $free_pages 100000 500000)"
        elif [[ "$line" =~ ^Pages\ active:\ *([0-9]+) ]]; then
            active_pages=${BASH_REMATCH[1]}
            echo -e "Active Pages: $(colorize_output $active_pages 500000 1000000)"
        elif [[ "$line" =~ ^Pages\ inactive:\ *([0-9]+) ]]; then
            inactive_pages=${BASH_REMATCH[1]}
            echo -e "Inactive Pages: $(colorize_output $inactive_pages 300000 700000)"
        elif [[ "$line" =~ ^Pages\ speculative:\ *([0-9]+) ]]; then
            speculative_pages=${BASH_REMATCH[1]}
            echo -e "Speculative Pages: $(colorize_output $speculative_pages 20000 50000)"
        else
            echo -e "${gry}$line${coff}"  #... gray for unclassified lines:
        fi
    done
else
    # ... if Linux vmstat:
    vmstat $TIME_INTERVAL $ITER_COUNT -S M -t -w | while IFS= read -r line; do
        if [[ "$line" =~ ^procs ]]; then
            echo -e "${cy}$line${coff}"  # ... highlight header:
        else
            cpu_idle=$(echo "$line" | awk '{print $15}')
            echo -e "CPU Idle: $(colorize_output $cpu_idle 30 80)"
        fi
    done
fi
