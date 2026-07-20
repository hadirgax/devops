#!/usr/bin/env bash
#
# Python virtual environments configuration
#
set -euo pipefail  # Exit on Error / Nounset / Exit on Unset Variables / Exit on Pipe Failures
set -x  # Debug Trace Mode

# Backup ~/.zshrc if exists, then create a new one from template
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.bak-$(date +%Y%m%d-%H%M%S)"
fi
cat "$PWD/templates/.zshrc-custom-template" > "$HOME/.zshrc"

# Creates the .virtualenvs folder with the commands file
COMMANDS_FILE_PATH="$HOME/.virtualenvs/bin/venv_cmds.sh"
COMMANDS_FILE_TEMPLATE_PATH="$PWD/templates/venv_cmds.sh-template"
# check if ~.virtualenvs/bin/venv_commands.sh already exists, if yes so skip creating the commands file
if [ ! -f "$COMMANDS_FILE_PATH" ]; then
    mkdir -p "$HOME/.virtualenvs/envs"
    mkdir -p "$HOME/.virtualenvs/bin"
    cp "$COMMANDS_FILE_TEMPLATE_PATH" "$COMMANDS_FILE_PATH"
fi

# Add passwordless sudo for the user
if [ ! -f "/etc/sudoers.d/90-passwordless-user" ]; then
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/90-passwordless-user
    echo "${USER} ALL=(ALL) NOPASSWD: /usr/bin/chsh -s * ${USER}" | sudo tee -a /etc/sudoers.d/90-passwordless-user
    # sudo nano /etc/pam.d/chsh  >> sufficient pam_shells.so
    # sudo visudo >> %sudo ALL=(ALL) NOPASSWD: /usr/bin/chsh -s *
fi

# Import the helper functions
source ./helper_functions.sh

cat << EOF
🐎 This script will setup the python virtual environment configuration.
EOF

install_packages_and_tools
install_rust
install_git
install_docker_engine
install_homebrew
# install_miniconda
install_astral_uv
install_nodejs
install_gurobi_optimizer

# Get email address from ~/.git configurations
USER_EMAIL=$(git config --global user.email)
create_ssh_key  --email_address=${USER_EMAIL}  --platform=github.com

install_oh_my_zsh