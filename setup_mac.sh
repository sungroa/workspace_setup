#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to prevent partial execution.
set -euo pipefail

# Check if homebrew is already installed before attempting an installation.
# Blindly curling and executing the installer causes unnecessary delays and prompts if already present.
if ! command -v brew &> /dev/null; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew already installed."
fi

# Dynamically set the brew path based on system architecture.
# Apple Silicon macs default to /opt/homebrew, while Intel macs default to /usr/local.
if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_CMD="/opt/homebrew/bin/brew"
elif [[ -x /usr/local/bin/brew ]]; then
    BREW_CMD="/usr/local/bin/brew"
else
    echo "Homebrew not found!"
    exit 1
fi

# Idempotently add homebrew to the PATH for login shells.
# We append to both .zprofile (for zsh) and .bash_profile (for bash users)
# only if the shellenv initialization does not already exist.
for profile in "${HOME}/.zprofile" "${HOME}/.bash_profile"; do
    if ! grep -q "brew shellenv" "$profile" 2>/dev/null; then
        echo >> "$profile"
        echo "eval \"\$($BREW_CMD shellenv)\"" >> "$profile"
    fi
done
eval "$($BREW_CMD shellenv)"

# Ensure recipes are latest and install required tools.
brew update
brew install tmux vim stow fonttool keychain withgraphite/tap/graphite
