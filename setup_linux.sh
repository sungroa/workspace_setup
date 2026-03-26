#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to prevent partial execution.
set -euo pipefail

# Export DEBIAN_FRONTEND to prevent prompts during automated installation
export DEBIAN_FRONTEND=noninteractive

# System upgrades.
sudo -E apt-get update -y
sudo -E apt-get upgrade -y
sudo -E apt-get autoremove -y

# To get basic settings and terminal enhancements.
sudo -E apt-get install --no-install-recommends -y tmux vim fonts-noto fonts-noto-color-emoji fonts-powerline stow locales bash-completion git

# Configure locale to ensure character encoding support.
# Failing to generate en_US UTF-8 can result in broken terminal UI/ascii formatting.
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8

# Alias python to python3 by default, aligning with modern python standards.
sudo -E apt-get install --no-install-recommends -y python-is-python3

# Node installation via NVM equivalent ('n').
sudo -E apt-get install --no-install-recommends -y npm
sudo npm install -g n
sudo n lts
sudo n prune
# Flush command cache location hash after n changes node binaries.
# Without this, the shell might mistakenly use the old apt-based npm
# instead of the newly installed n-managed npm.
hash -r
sudo npm i -g @withgraphite/graphite-cli

# To setup ssh into the device and cleanly manage auth agents.
sudo -E apt-get install --no-install-recommends -y keychain openssh-server
