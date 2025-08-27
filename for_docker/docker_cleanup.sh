#!/bin/bash

# ===========================================================================================
# Script Name: docker_cleanup.sh
#
# Description:
#   - This script provides a set of CLI tools for managing and cleaning up Docker resources.
#   - Supports listing, stopping, and removing containers, images, and volumes.
#   - Offers an automated cleanup option (`-K`) that stops and removes all Docker data while keeping cache IDs.
#
# Compatibility:
#   - Works on macOS, Ubuntu, and Red Hat-based systems (RHEL, CentOS, Fedora).
#
# Prerequisites:
#   - Docker must be installed and accessible from the CLI.
#   - Requires sudo/root privileges for stopping and removing containers.
#
# Usage:
#   - Run the script with the desired argument to execute a Docker command:
#     - `-d` → Show Docker system disk usage (`docker system df`)
#     - `-a` → List all containers (`docker ps -a`)
#     - `-i` → List all images (`docker images -a`)
#     - `-s` → Stop all running containers (`docker stop $(docker ps -a -q)`)
#     - `-r` → Remove all stopped containers (`docker rm $(docker ps -a -q)`)
#     - `-m` → Remove all images (`docker rmi -f $(docker images -q)`)
#     - `-p` → Remove all unused data and volumes (`docker system prune -af --volumes`)
#     - `-K` → Perform a full cleanup (stop, remove containers/images, show final status)
#
# References:
#   - Docker documentation: https://docs.docker.com/engine/reference/commandline/
# ===========================================================================================

cyan="\033[1;36m"
blue="\033[1;34m"
white="\033[1;37m"
yellow="\033[1;33m"
grey="\033[0;37m"
GREEN="\033[0;32m"
RED="\033[0;31m"
NC="\033[0m"

decorator_init="echo -e ${cyan}"$(printf '.%.0s' {1..151})"${NC}"
decorator_done="echo -e ${white}"$(printf '=%.0s' {1..151})"${NC}"

function usage {
	echo -e "\nFile Name: --> ./$(basename $0)"
    echo -e "cwd: --> "$PWD""
    echo -e "\n\t ${white}- - -${cyan} Available arguments and usage ${white}- - - ${NC}"
    $decorator_done
    echo -e "./${yellow}$(basename $0) ${GREEN}-d  ${white}<-- ${NC}argument\t${white}equivalent ${NC}to\t${GREEN}dockers${white} system df                  ${white}|${NC} Returns ${yellow}-> ${cyan}Docker summary usage report                   ${white}|${NC}"
    echo -e "./${yellow}$(basename $0) ${GREEN}-a  ${white}<-- ${NC}argument\t${white}equivalent ${NC}to\t${GREEN}docker ${white}ps -a                       ${white}|${NC} Returns ${yellow}-> ${cyan}Existing docker process check                 ${white}|${NC}"
    echo -e "./${yellow}$(basename $0) ${GREEN}-i  ${white}<-- ${NC}argument\t${white}equivalent ${NC}to\t${GREEN}docker ${white}images -a                   ${white}|${NC} Returns ${yellow}-> ${cyan}Existing docker images check                  ${white}|${NC}"
    echo -e "./${yellow}$(basename $0) ${GREEN}-s  ${white}<-- ${NC}argument\t${white}equivalent ${NC}to\t${GREEN}docker ${white}stop docker ps -a -q        ${white}|${NC} Returns ${yellow}-> ${cyan}Stop All Existing docker process ids          ${white}|${NC}"
    echo -e "./${yellow}$(basename $0) ${GREEN}-r  ${white}<-- ${NC}argument\t${white}equivalent ${NC}to\t${GREEN}docker ${white}rm docker ps -a -q          ${white}|${NC} Returns ${yellow}-> ${cyan}Removed All Existing docker process ids       ${white}|${NC}"
    echo -e "./${yellow}$(basename $0) ${GREEN}-m  ${white}<-- ${NC}argument\t${white}equivalent ${NC}to\t${GREEN}docker ${white}rmi docker images -q        ${white}|${NC} Returns ${yellow}-> ${cyan}Removed All Existing docker container images  ${white}|${NC}"
    echo -e "./${yellow}$(basename $0) ${GREEN}-p  ${white}<-- ${NC}argument\t${white}equivalent ${NC}to\t${GREEN}docker ${white}system prune -af --volumes  ${white}|${NC} Returns ${yellow}-> ${cyan}Pruned All cached docker volumes              ${white}|${NC}"
    $decorator_init
    echo -e "./${yellow}$(basename $0) ${GREEN}-K  ${white}<-- ${NC}argument\t${yellow}Stop and Remove All docker volumees on this system:${cyan}\tKeeps Docker Cache ids:${NC}"
    $decorator_done
}

function docker_summary_report {
    docker system df
}

function docker_ps_check {
    docker ps -a
}

function docker_images_check {
    docker images -a 
}

function docker_stop_all {
    docker stop $(docker ps -a -q) 
}

function docker_remove_all_ps_ids {
    docker rm $(docker ps -a -q)
}

function docker_remove_all_images {
    # docker rmi $(docker images -q)
    docker rmi -f $(docker images -q)
}

function docker_prune_all {
    docker system prune -af --volumes
}

function use_all {
  docker_summary_report
  sleep 1
  docker_stop_all
  sleep 1
  docker_remove_all_ps_ids
  sleep 1
  docker_remove_all_images
  sleep 1
  echo -e "\n--------------------------------"
  sleep 1
  docker_ps_check
  sleep 1
  docker_summary_report
}

[ $# -eq 0 ] && usage
optstring=":hdaisrmpK"

while getopts ${optstring} arg; do
  case ${arg} in
    h)
      echo
      echo -e "HELP:\n$(date)\n"
      echo -e "The purpose of this script is to help with sys docker cleaup tasks.\nArguments provided, are general docker cli selections:"
      echo -e "-------------------------------------------------------------------"
      usage
      echo -e "\nI hope it helps ...\nThe Clean system is a healthy system.\t;0 )"
      ;;

    d)
      echo -e "\n( -d )\tdocker command\t-> docker system df\n"
      echo -e "Docker summary usage report:\n-------------------------------------------------------------"
      docker_summary_report
      ;;

    a)
      echo -e "\n( -a )\tdocker command\t-> docker ps -a\n"
      echo -e "Checking All existing process:\n-------------------------------------------------------------"
      docker_ps_check
      ;;
    
    i)
      echo -e "\n( -i )\tdocker command\t-> docker images -a\n"
      echo -e "Checking All existing container images:\n-------------------------------------------------------------"
      docker_images_check
      ;;
    
    s)
      echo -e "\n( -s )\tdocker command\t-> docker stop $ (docker ps -a -q)\n"
      echo -e "Stopping All running process ids:\n-------------------------------------------------------------"
      docker_stop_all
      ;;
    
    r)
      echo -e "\n( -r )\tdocker command\t-> docker rm $ (docker images -q)\n"
      echo -e "Removing All existing process ids:\n-------------------------------------------------------------"
      docker_remove_all_ps_ids
      ;;
    
    m)
      echo -e "\n( -m )\tdocker command\t-> docker rmi $ (docker images -q)\n"
      echo -e "Removing All existing Container Images:\n-------------------------------------------------------------"
      docker_remove_all_images
      ;;
     
    p)
      echo -e "\n( -p )\tdocker command\t-> docker system prune -af --volumes\n"
      echo -e "Prune All docker volumees on this system:\n-------------------------------------------------------------"
      docker_prune_all
      ;;
    
    K)
      echo -e "\n( -K )"
      echo -e " Stop and Remove All docker volumees on this system:\n Keep Docker Cache ids:"
      echo -e "\n No prune:\n-------------------------------------"
      use_all
      ;;

    ?)
      echo -e "\nError: -${OPTARG} \nInvalid option: -> ${OPTARG} | Try -h, might help.\t¯\_(ツ)_/¯ "
      exit 2
      ;;
  esac
done
