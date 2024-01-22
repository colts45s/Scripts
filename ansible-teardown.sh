#!/bin/bash

# Define colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display messages in color
echo_color() {
    echo -e "${2}${1}${NC}"
}

# Script introduction
echo_color "This script will uninstall Ansible and remove all related files and directories created by the setup script." $YELLOW

# Confirm before proceeding
read -p "Are you sure you want to continue? (y/n): " confirmation
if [[ $confirmation != [yY] ]]; then
    echo_color "Operation aborted by the user." $RED
    exit 1
fi

# Check for sudo access
echo_color "Checking for sudo access..." $YELLOW
sudo -v
if [ $? -ne 0 ]; then
    echo_color "You do not have sudo access or have entered an incorrect password." $RED
    exit 1
fi

# Uninstall Ansible
echo_color "Uninstalling Ansible..." $YELLOW
sudo apt-get remove --purge ansible -y
if [ $? -eq 0 ]; then
    echo_color "Ansible has been successfully uninstalled." $GREEN
else
    echo_color "Failed to uninstall Ansible." $RED
    exit 1
fi

# Remove the playbooks directory
playbooks_dir=$(pwd)/playbooks
if [ -d "$playbooks_dir" ]; then
    echo_color "Removing playbook directory at $playbooks_dir..." $YELLOW
    rm -rf "$playbooks_dir"
    echo_color "Playbook directory removed." $GREEN
else
    echo_color "Playbook directory not found. No action required." $YELLOW
fi

echo_color "Cleanup complete. Ansible and related files have been removed." $GREEN
