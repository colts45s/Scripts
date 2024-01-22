# 🚀 Ansible Setup and Teardown Scripts

## Overview 📖

This repository contains two Bash scripts for managing the setup and teardown of Ansible on a host machine. The `setup.sh` 🛠 script installs Ansible, sets up a basic playbook structure, and optionally clones a Git repository of Ansible playbooks. The `teardown.sh` 🧹 script uninstalls Ansible and removes the files and directories created by the setup script.

### Setup Script (`setup.sh`) 🛠

The setup script performs the following tasks:
- 📌 Installs Ansible on the host machine.
- 🔑 Checks for sudo access.
- 📁 Creates a directory structure for Ansible playbooks.
- 🌐 Provides an option to clone Ansible playbooks from a Git repository.
- 🎉 Adds a 'Hello World' Ansible playbook as a starting point.

### Teardown Script (`teardown.sh`) 🧹

The teardown script performs the following tasks:
- ❌ Uninstalls Ansible from the host machine.
- 🗑 Removes the specific files and directories created by the setup script.
- 🛡 Ensures that only the components added by the setup script are removed.

## Usage ⚙️

### Setup

1. Run the setup script:
   ```bash
   ./setup.sh
   ```
2. Follow the on-screen prompts to complete the installation. 🖥️

### Teardown

1. Run the teardown script:
   ```bash
   ./teardown.sh
   ```
2. Confirm the actions when prompted. ✅

## Considerations 🤔

- Ensure you have the necessary permissions to install software and make changes to your system. 🔐
- The scripts are designed for environments using `apt-get` (like Debian or Ubuntu). Adjustments may be needed for other package managers. 🔄
- The teardown script is careful not to remove anything outside what the setup script created. 🚫

## Extensibility 🌟

### Customizing Setup

- Modify the playbook examples or add additional roles and tasks as per your requirement. 📝
- Extend the Git repository cloning functionality to support other hosting services besides GitHub. 🌍

### Enhancing Teardown

- Integrate cleanup of additional configurations or installations made post-setup. 🧼
- Implement checks to ensure that no unrelated files or directories are accidentally removed. 🛠️

## Contributing 💡

Contributions to improve the scripts are welcome. Please submit pull requests or open issues for any bugs or feature requests. 🤝
