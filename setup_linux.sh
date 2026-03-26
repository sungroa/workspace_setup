#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to prevent partial execution.
set -euo pipefail

# System upgrades.
sudo apt update -y
sudo apt upgrade -y
sudo apt autoremove -y

# To get basic settings and terminal enhancements.
sudo apt install tmux vim fonts-noto fonts-noto-color-emoji fonts-powerline stow locales bash-completion git -y

# Configure locale to ensure character encoding support.
# Failing to generate en_US UTF-8 can result in broken terminal UI/ascii formatting.
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Alias python to python3 by default, aligning with modern python standards.
sudo apt install python-is-python3 -y

# Node installation via NVM equivalent ('n').
sudo apt install npm -y
sudo npm install -g n
sudo n lts
sudo n prune
# Flush command cache location hash after n changes node binaries.
# Without this, the shell might mistakenly use the old apt-based npm
# instead of the newly installed n-managed npm.
hash -r
sudo npm i -g @withgraphite/graphite-cli

# To setup ssh into the device and cleanly manage auth agents.
sudo apt install keychain openssh-server -y
