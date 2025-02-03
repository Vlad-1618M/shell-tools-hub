#!/bin/bash

# ===============================================================================
# Script Name: deps_check_sys_tools.sh
# Description: This script checks the installed versions and locations of:
#              - Python, pip, Ansible
#              - Docker, Docker Compose
#              - Kubernetes tools (kubectl, Helm, k9s)
#              - Shell version, OS type
# ... dynamically detects whether to use `python` or `python3` and `pip` or `pip3`.
# ===============================================================================

# ... color vars for output formatting:
green="\033[1;32m"
cyan="\033[1;36m"
red="\033[0;31m"
blue="\033[1;34m"
pink="\033[1;35m"
white="\033[1;37m"
yellow="\033[1;33m"
off="\033[0m"

# ... decorators: for visual separation in output
decorator_init="echo -e ${pink}"$(printf '.%.0s' {1..50})"${off}\n"
decorator_done="echo -e ${white}"$(printf '=%.0s' {1..65})"${off}"

# ... get sys/OS type:
OS_TYPE=$(uname -s)

# ... get shell version:
SHELL_NAME=$(basename "$SHELL")
SHELL_VERSION=$("$SHELL" --version 2>/dev/null | head -n 1)

# ... get python binary:
PYTHON_CMD=""
if command -v python3 &>/dev/null; then
    PYTHON_CMD="python3"
elif command -v python &>/dev/null; then
    PYTHON_CMD="python"
else
    echo -e "\n${red}Error:\t${white}--> ${yellow}Python${red} is not installed!${off}"
    exit 1
fi

# ... get pip binary:
PIP_CMD=""
if command -v pip3 &>/dev/null; then
    PIP_CMD="pip3"
elif command -v pip &>/dev/null; then
    PIP_CMD="pip"
else
    echo -e "\n${red}Error:\t${white}--> ${yellow}pip${red} is not installed!${off}"
    exit 1
fi

# ... check if command exists & print its version:
run_version_check() {
    local cmd=$1
    local version_flag=${2:---version}

    if command -v "$cmd" &>/dev/null; then
        if [ "$cmd" == "kubectl" ]; then
            local version_output
            version_output=$("$cmd" version 2>/dev/null | awk '/Client Version:/ {print $3}')

            if [ -n "$version_output" ]; then
                echo -e "${green}$cmd ${off}Version:${off} ${cyan}$version_output${off}"
            else
                echo -e "${yellow}$cmd${off}:\t${white}--> ${red}Version could not be determined.${off}"
            fi
        else
            local version_output
            version_output=$("$cmd" "$version_flag" 2>/dev/null | head -n 1)
            echo -e "${green}$cmd ${off}Version:${off} ${cyan}$version_output${off}"
        fi
    else
        echo -e "${yellow}$cmd${off}:\t${white}--> ${red}Not installed.${off}"
    fi
}

# ... run system checks:
$decorator_done
echo -e "Operating System:\t${green}$OS_TYPE${off}"
echo -e "Shell Type:\t\t${green}$SHELL_NAME${off}"
echo -e "Shell Version:\t\t${green}$SHELL_VERSION${off}"
$decorator_init

$PYTHON_CMD -c "import sys, subprocess;
print('Python Version:', sys.version.split()[0]); 
print('Python Location:', sys.executable);

try:
    pip_output = subprocess.check_output(['$PIP_CMD', '--version']).decode().strip();
    pip_version = pip_output.split()[1]  # Extract actual version
    print('Pip Version:', pip_version);
except Exception:
    print('\nPip\t--> is not installed or not accessible.');

try:
    ansible_output = subprocess.check_output(['ansible', '--version']).decode();
    ansible_version = ansible_output.split('[')[1].split()[1].split(']')[0];
    print('Ansible Version:', ansible_version);
    
    ansible_location = [line.split()[1] for line in subprocess.check_output(['$PIP_CMD', 'show', 'ansible']).decode().splitlines() if line.startswith('Location')][0]; 
    print('Ansible Galaxy Location:', ansible_location);
except Exception:
    print('\nAnsible\t--> is not installed or could not be found.');"

# ... check versions of system tools:
run_version_check "docker"
run_version_check "docker-compose"
run_version_check "kubectl"
run_version_check "helm"
run_version_check "k9s"

$decorator_done
