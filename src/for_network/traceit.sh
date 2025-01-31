#!/bin/bash

# Color codes
RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[0;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No color

# Function to get the public IP
get_public_ip() {
  echo -e "${BLUE}Retrieving public IP...${NC}"
  public_ip=$(curl -s ifconfig.me || echo "Unavailable")
  echo -e "${GREEN}Public IP: $public_ip${NC}"
}

# Function to get the private IP
get_private_ip() {
  echo -e "${BLUE}Retrieving private IP...${NC}"
  if command -v ip > /dev/null 2>&1; then
    private_ip=$(ip addr show | awk '/inet / && !/127.0.0.1/ {print $2}' | cut -d/ -f1 | head -n 1)
  elif command -v ifconfig > /dev/null 2>&1; then
    private_ip=$(ifconfig | awk '/inet / && !/127.0.0.1/ {print $2}' | head -n 1)
  else
    private_ip="Unavailable"
  fi
  echo -e "${GREEN}Private IP: $private_ip${NC}"
}

# Function to perform traceroute and mtr
trace_ip() {
  local ip=$1
  echo -e "${YELLOW}======================================${NC}"
  echo -e "${BLUE}Analyzing IP: $ip${NC}"

  hostname=$(nslookup $ip | awk '/name = / {print $4}')
  if [ -z "$hostname" ]; then
    echo -e "${RED}Hostname: No associated domain name found.${NC}"
  else
    echo -e "${GREEN}Hostname: $hostname${NC}"
  fi

  echo -e "${YELLOW}--------------------------------------${NC}"
  echo -e "${BLUE}Running traceroute for $ip...${NC}"
  traceroute_output=$(traceroute $ip 2>/dev/null)
  echo "$traceroute_output"

  start_point=$(echo "$traceroute_output" | head -n 2 | tail -n 1)
  end_point=$(echo "$traceroute_output" | tail -n 1)

  echo -e "${GREEN}Start Point: $start_point${NC}"
  echo -e "${GREEN}End Point: $end_point${NC}"

  echo -e "${YELLOW}--------------------------------------${NC}"
  echo -e "${BLUE}Running mtr for $ip...${NC}"
  mtr_output=$(mtr --report $ip 2>/dev/null)
  echo "$mtr_output"

  echo -e "${YELLOW}======================================${NC}\n"
}

# Prompt user for IP
read -p "Enter the IP you want to trace (or press Enter to see system IPs): " user_ip

if [ -z "$user_ip" ]; then
  echo -e "${YELLOW}No IP provided. Retrieving system IPs...${NC}"
  get_public_ip
  get_private_ip
  echo -e "${YELLOW}You can use these IPs to rerun the script.${NC}"
  exit 0
else
  echo -e "${YELLOW}Proceeding with the provided IP: $user_ip${NC}"
  trace_ip "$user_ip"
fi
