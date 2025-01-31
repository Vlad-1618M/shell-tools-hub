#!/bin/bash

# Define color codes for styling output
gr='\033[1;32m'    # Green
cy='\033[1;36m'    # Cyan
yl='\033[1;33m'    # Yellow
rd='\033[0;31m'    # Red
wt='\033[1;37m'    # White
gry='\033[0;37m'   # Gray
coff='\033[0m'     # No color

# Decorators for better script output
decorator_init="echo -e ${yl}"$(printf '.%.0s' {1..70})"${coff}"
decorator_done="echo -e ${gry}"$(printf '=%.0s' {1..70})"${coff}"

# Usage instructions
usage() {
    echo -e "\n\t${gr}Usage${coff} for ${yl}$(basename $0)${coff} script:"
    echo -e "\tArguments expected: [ ${wt}time_interval${coff} ] & [ ${wt}iteration_count${coff} ]"
    echo -e "\tCall Example: ${yl}$(basename $0)${wt} 0.5 ${cy}10${coff}\n"
    $decorator_done
    exit 1
}

# Function to check for vm_stat or vmstat availability
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

# Function to apply color thresholds for output
colorize_output() {
    local value=$1
    local threshold_low=$2
    local threshold_high=$3
    local output="$value"

    if (( $(echo "$value > $threshold_high" | bc -l) )); then
        echo -e "${rd}$output${coff}"   # High consumption (red)
    elif (( $(echo "$value > $threshold_low" | bc -l) )); then
        echo -e "${yl}$output${coff}"   # Moderate consumption (yellow)
    else
        echo -e "${gr}$output${coff}"   # Low consumption (green)
    fi
}

# Run the check before proceeding
check_vmstat

# Ensure both arguments are provided
if [ "$#" -ne 2 ]; then
    usage
fi

# Parse and validate arguments
TIME_INTERVAL=$1
ITER_COUNT=$2

if ! [[ "$TIME_INTERVAL" =~ ^[0-9]+([.][0-9]+)?$ ]] || ! [[ "$ITER_COUNT" =~ ^[0-9]+$ ]]; then
    echo -e "${rd}Error: TIME_INTERVAL must be a positive decimal and ITER_COUNT must be a positive integer.${coff}"
    usage
fi

echo -e "\n\tRunning ${gr}vm_stat${coff} or ${gr}vmstat${coff} call with:"
echo -e "\t${cy}Interval: ${yl}${TIME_INTERVAL}${coff} seconds${cy}, Iterations: ${yl}${ITER_COUNT}${coff}\n"

# Execute based on OS type
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS: Use vm_stat
    vm_stat -c $ITER_COUNT $TIME_INTERVAL | while IFS= read -r line; do
        # Skip header
        if [[ "$line" == *"Mach Virtual Memory Statistics"* ]]; then
            echo -e "${cy}$line${coff}"
            continue
        fi
        # Parse the key-value pairs
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
            echo -e "${gry}$line${coff}"  # Gray for unclassified lines
        fi
    done
else
    # Linux: Use vmstat
    vmstat $TIME_INTERVAL $ITER_COUNT -S M -t -w | while IFS= read -r line; do
        if [[ "$line" =~ ^procs ]]; then
            echo -e "${cy}$line${coff}"  # Highlight header
        else
            cpu_idle=$(echo "$line" | awk '{print $15}')
            echo -e "CPU Idle: $(colorize_output $cpu_idle 30 80)"
        fi
    done
fi






# uptime; echo "\nCurrent Directory: $(pwd)"; echo "\nFiles in Directory:"; ls -asl; echo "\nTotal File Count and Size:"; find . -type f -exec du -sh {} + | awk '{sum += $1} END {print "Count:", NR, "Total Size:", sum " KB"}'
# uptime; echo -e "\nCurrent Directory: $(pwd)"; echo "\nFiles in Directory:"; tree .; echo "\nTotal File Count and Size:"; find . -type f -exec du -sh {} + | awk '{sum += $1} END {print "Count:", NR, "Total Size:", sum " KB"}'
# uptime; echo -e "\nCurrent Directory: $(pwd)"; echo "\nFiles in Directory:"; tree .; echo "\nTotal File Count and Size:"; find . -type f -exec du -sh {} + | awk '{sum += $1} END {print "Count:", NR, "Total Size:", sum " KB"}'