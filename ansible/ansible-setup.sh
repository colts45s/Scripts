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
echo_color "This script is designed to set up Ansible on this host machine and help you get started with your configuration management. It will install Ansible, and optionally clone a Git repository of your Ansible playbooks." $YELLOW


# Check if the user can execute commands with sudo and prompt for password if necessary
echo_color "Checking for sudo access..." $YELLOW
sudo -v
if [ $? -ne 0 ]; then
    echo_color "You do not have sudo access or have entered an incorrect password." $RED
    exit 1
fi

# Ask if the user wants to continue
read -p "Do you want to continue with the setup? (y/n): " continue_setup
if [[ $continue_setup != [yY] ]]; then
    echo_color "Setup aborted by the user." $RED
    exit 1
fi

# Install Ansible
echo_color "Installing Ansible..." $GREEN
if sudo apt install ansible -y; then
    echo_color "Ansible has been successfully installed." $GREEN
else
    echo_color "Failed to install Ansible." $RED
    # send error to syslog
    logger -p user.err -t ansible-setup "Failed to install Ansible."
    exit 1
fi

# Function to validate Git repository URL
validate_git_url() {
    if [[ $1 =~ ^git@github\.com:.+\.git$ ]] || [[ $1 =~ ^https://github\.com/.+\.git$ ]]; then
        return 0 # Valid
    else
        return 1 # Invalid
    fi
}

# Ask if the user wants to download playbooks from a Git repository
read -p "Do you want to download playbooks from a Git repository? (y/n): " download_playbooks
if [[ $download_playbooks == [yY] ]]; then
    # Check if Git is installed and install it if not
    echo_color "Checking for Git installation..." $YELLOW
    if ! command -v git &> /dev/null; then
        echo_color "Git is not installed. Installing Git..." $YELLOW
        sudo apt install git -y
        if [ $? -eq 0 ]; then
            echo_color "Git has been successfully installed." $GREEN
        else
            echo_color "Failed to install Git." $RED
            # send error to syslog
            logger -p user.err -t ansible-setup "Failed to install Git."
            exit 1
        fi
    else
        echo_color "Git is already installed." $GREEN
    fi
    # Ask if it's a public repository
    read -p "Is it a public repository? (y/n): " is_public
    if [[ $is_public == [yY] ]]; then
        # Ask for HTTPS link
        while true; do
            read -p "Enter the HTTPS repository URL (e.g., https://github.com/user/repo.git): " repo_url
            validate_git_url "$repo_url" && break
            echo_color "Invalid HTTPS repository URL. Please enter a valid URL." $RED
        done
    else
        # Ask for SSH link
        while true; do
            read -p "Enter the SSH repository URL (e.g., git@github.com:user/repo.git): " repo_url
            validate_git_url "$repo_url" && break
            echo_color "Invalid SSH repository URL. Please enter a valid URL. Or press ctrl+z to exit" $RED
        done

        # Check if an SSH key is already configured
        read -p "Is an SSH key configured for this repository already? (y/n): " ssh_key_configured
        if [[ $ssh_key_configured != [nN] ]]; then
            # Generate and set up SSH key
            echo_color "Generating SSH key..." $GREEN
            # Ask user for email address
            read -p "Enter your email address: " email_address
            # Validate email address
            while true; do
                if [[ $email_address =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
                    break
                else
                    echo_color "Invalid email address. Please enter a valid email address." $RED
                    read -p "Enter your email address: " email_address
                fi
            done
            ssh-keygen -t rsa -b 4096 -f "$HOME/.ssh/id_rsa" -N "" -C "$email_address"
            eval "$(ssh-agent -s)"
            ssh-add "$HOME/.ssh/id_rsa"
            echo_color "Copy the following SSH public key to your GitHub account:" $YELLOW
            cat "$HOME/.ssh/id_rsa.pub"
            echo_color "After adding it to GitHub, press enter to continue..." $YELLOW
            read -p ""
        fi
    fi

    # Set the directory to store the playbooks to the current directory
    playbooks_dir=$(pwd)

    # Clone the Git repository
    echo_color "Cloning Ansible playbooks from repository into $playbooks_dir..." $GREEN
    mkdir -p "$playbooks_dir/playbooks"
    if git clone "$repo_url" "$playbooks_dir/playbooks"; then
        echo_color "Successfully cloned the playbook repository." $GREEN
    else
        echo_color "Failed to clone the repository. Ensure your SSH key is added to GitHub and the repository URL is correct." $RED
        # send error to syslog
        logger -p user.err -t ansible-setup "Failed to clone the repository. Ensure your SSH key is added to GitHub and the repository URL is correct."
        exit 1
    fi
else
    # Create an empty folder for playbooks in the current directory
    playbooks_dir=$(pwd)/playbooks
    mkdir -p "$playbooks_dir/{group_vars,host_vars,roles,tasks}"
    echo_color "Created an empty playbook structure in $playbooks_dir" $GREEN
fi
# Create a 'Hello World' Ansible playbook
cat > "$playbooks_dir/hello_world.yml" << EOF
- name: Hello World playbook
  hosts: localhost
  tasks:
    - name: Print a message
      command: echo "Hello World"
EOF

echo_color "Ansible installation and setup is complete. Your playbook directory is located at $playbooks_dir" $GREEN
echo_color "Added a 'Hello World' playbook. Run it with 'ansible-playbook $playbooks_dir/hello_world.yml' to test Ansible." $GREEN
