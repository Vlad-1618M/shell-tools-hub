#!/bin/bash

# ===============================================================================
# Script Name: fqdn_ip_logger.sh
#
# NOTE: This script reads a list of domains from a configuration file (`domains.cfg`),
#       allows the user to select a resolution method (CURL, DIG, or NSLOOKUP),
#       and logs the results for further analysis.
#
# Description:
#       - Reads Fully Qualified Domain Names (FQDN) from `domains.cfg`.
#       - Allows the user to choose a resolution method:
#           1. **CURL**      → Checks if the domain is reachable and extracts the HTTP status.
#           2. **DIG**       → Performs a DNS lookup and retrieves the domain’s IP.
#           3. **NSLOOKUP**  → Queries DNS servers for the domain’s IP.
#       - Logs successful and failed resolutions in `results.log`.
#       - Uses ANSI colors for formatted output.
#
# ===============================================================================
#
# 🔹 **Differences Between CURL, DIG, and NSLOOKUP**
#
# 1️⃣ **CURL** (Connection Testing)
#      - Used to test whether the domain is **accessible over HTTP/HTTPS**.
#      - Fetches the **HTTP status code** (e.g., `200 OK`, `404 Not Found`).
#      - Does **not** perform a DNS lookup directly.
#
# 2️⃣ **DIG** (DNS Query)
#      - Queries DNS records to find the **IP address of a domain**.
#      - Uses the system's **configured DNS servers**.
#      - Preferred for **checking actual DNS resolution**.
#
# 3️⃣ **NSLOOKUP** (Legacy DNS Query)
#      - Similar to `dig` but **older** and sometimes less detailed.
#      - Useful for **quick lookups** and debugging.
#
# ===============================================================================
#
# 🔹 **Requirements & Installation**
#
# The script requires the following utilities:
#
# ✅ **CURL** → Used to check HTTP response codes.
# ✅ **DIG**  → Used for DNS resolution (part of `bind-utils` or `dnsutils`).
# ✅ **NSLOOKUP** → Used for alternative DNS lookups.
#
# Install them using the following commands:
#
# 📌 **macOS (Homebrew)**
# ```sh
# brew install curl
# brew install bind  # (Includes `dig`)
# ```
#
# 📌 **Debian/Ubuntu (APT)**
# ```sh
# sudo apt update
# sudo apt install curl dnsutils
# ```
#
# 📌 **Red Hat/CentOS/Fedora (DNF/YUM)**
# ```sh
# sudo dnf install curl bind-utils
# ```
#
# 📌 **Arch Linux (Pacman)**
# ```sh
# sudo pacman -S curl bind
# ```
#
# ===============================================================================
#
# Usage:
#       ./domain_resolver.sh
#
# Example:
#       - Reads domains from `domains.cfg`
#       - User selects resolution method (CURL, DIG, or NSLOOKUP)
#       - Outputs results in the terminal and logs to `results.log`
#
# ===============================================================================


# ... color codes:
white="\033[1;37m"
BLUE="\033[0;34m"
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
CYAN="\033[1;36m"
grey="\033[0;37m"
_off="\033[0m" # No color

decorator_init="echo -e ${grey}"$(printf '_%.0s' {1..50})"${_off}"
decorator_done="echo -e ${grey}"$(printf '=%.0s' {1..50})"${_off}"

# Configurations
config_file="domains.cfg"
log_file="ip_results.log"

# Fu_offtion to read domain names from configuration file
read_domains() {
  local config_file=$1
  if [ ! -f "$config_file" ]; then
    echo -e "\n${RED}Error: Configuration file $config_file not found.${_off}"
    exit 1
  fi

  # echo -e "\tReading fqdn/domain list from: ${GREEN}--> ${YELLOW}$config_file:${_off}\n"
  echo -e "Reading fqdn/domain list from: ${white}--> ${YELLOW}$(basename $config_file):${_off}\n"
  domains=()
  count=0  # Initialize counter

  while IFS= read -r line; do
    # Skip empty lines and comments
    [[ -z "$line" || "$line" =~ ^# ]] && continue
    domains+=("$line")
    count=$((count + 1))                                      # Increment counter
    echo -e "\t${CYAN}$count ${grey}-->\t${white}$line${_off}"  # Display domain with counter
  done < "$config_file"
  $decorator_done
  echo -e "Total domains read: ${GREEN}$count${_off}"
}

resolve_with_curl() {
  local domain=$1
  local curl_output
  local ip
  local http_status
  # local log_file="curl_resolve.log" # Log file path

  # Fetch headers from the domain
  curl_output=$(curl -sI "$domain" 2>&1)

  # Extract HTTP status (e.g., HTTP/2 200 or HTTP/1.1 404)
  http_status=$(echo "$curl_output" | grep -oE "HTTP/[0-9.]+ [0-9]{3}" | awk '{print $2}')

  # Extract the base domain name
  base_domain=$(echo "$domain" | awk -F/ '{print $3}')
  
  # Log timestamp
  timestamp="[$(date +'%Y-%m-%d %H:%M:%S')]"

  # Check if the HTTP status indicates success
  if [ "$http_status" = "200" ]; then
    # Resolve IP using dig
    ip=$(dig +short "$base_domain" | head -n 1)

    # If IP resolution fails
    if [ -z "$ip" ]; then
      ip="IP not found"
      printf "CURL: %-35s ${YELLOW}%-12s${_off} %-50s\n" "$domain" "Connected" "$ip"
      echo "${timestamp} [INFO] Domain: $domain | Status: Connected | IP: $ip" >> "$log_file"
    else
      printf "CURL: ${white}%-35s ${YELLOW}%-12s${_off} ${CYAN}%-15s${_off} ${YELLOW}%s${_off}\n" "$domain" "Connected" "Resolved IP:" "$ip"
      echo "${timestamp} [INFO] Domain: $domain | Status: Connected | Resolved IP: $ip" >> "$log_file"
    fi
  else
    http_status=${http_status:-"Unknown"}
    printf "CURL: ${white}%-35s ${RED}%-12s${_off} ${grey}%-16s${RED}%s\n" "$domain" "Failed" "Status:" "$http_status"
    echo "${timestamp} [ERROR] Domain: $domain | Status: Failed | HTTP Status: $http_status" >> "$log_file"
  fi

  # Add visual decorator to the log file
  >> "$log_file"
}

# Fu_offtion to resolve domains using `dig`
resolve_with_dig() {
  local domain=$1
  # local log_file="dig_resolve.log"
  result=$(dig +short "$domain" 2>&1)
  if [ -z "$result" ]; then
    echo -e "${RED}DIG: Failed to resolve $domain${_off}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] DIG: Failed to resolve $domain (NXDOMAIN)" >> "$log_file"
  else
    echo -e "\n${GREEN}DIG: Resolved ${YELLOW}$domain ${_off}to ${CYAN}$result${_off}\n"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] DIG: Resolved $domain to $result" >> "$log_file"
  fi
}

# Fu_offtion to resolve domains using `nslookup`
resolve_with_nslookup() {
  local domain=$1
  result=$(nslookup "$domain" 2>&1)
  if echo "$result" | grep -q "NXDOMAIN"; then
    echo -e "\t${RED}NSLOOKUP: Failed to resolve $domain${_off}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] NSLOOKUP: Failed to resolve $domain (NXDOMAIN)" >> "$log_file"
  else
    ip=$(echo "$result" | awk '/Address:/ {print $2}' | tail -n1)
    echo -e "${GREEN}NSLOOKUP: Resolved ${YELLOW}$domain ${_off}to ${CYAN}$ip${_off}"
    # echo -e "${GREEN}NSLOOKUP: Resolved $domain to $ip${_off}"
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] NSLOOKUP: Resolved $domain to $ip" >> "$log_file"
  fi
}

# Main fu_offtion to prompt user for resolution method
resolve_domains() {
  echo -e "\n${YELLOW}Choose a resolution method:${_off}"
  echo -e ${CYAN}"1.${_off} CURL"
  echo -e ${GREEN}"2.${_off} DIG"
  echo -e ${RED}"3.${_off} NSLOOKUP"
  read -p "Enter your choice (1/2/3): " choice

  case $choice in
    1)
      method="CURL"
      resolver=resolve_with_curl
      ;;
    2)
      method="DIG"
      resolver=resolve_with_dig
      ;;
    3)
      method="NSLOOKUP"
      resolver=resolve_with_nslookup
      ;;
    *)
      echo -e "${RED}Invalid choice. Exiting.${_off}"
      exit 1
      ;;
  esac

  echo -e "${BLUE}Using $method for domain resolution.${_off}"
  for domain in "${domains[@]}"; do
    $resolver "$domain"
  done
}

# Start of the script
$decorator_init
echo -e "\t${YELLOW}>>> ${_off}Domain Resolution Script ${YELLOW}<<<${_off}"

# Read domain names from configuration file
read_domains "$config_file"

# Prompt user for resolution method and resolve domains
resolve_domains
$decorator_done
echo -e "${GREEN}Resolution completed. Check $log_file for details.${_off}"
