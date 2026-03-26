#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures.
set -euo pipefail

NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Dynamically set brew path based on architecture
if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_CMD="/opt/homebrew/bin/brew"
elif [[ -x /usr/local/bin/brew ]]; then
    BREW_CMD="/usr/local/bin/brew"
else
    echo "Homebrew not found!"
    exit 1
fi

if ! grep -q "brew shellenv" "${HOME}/.zprofile" 2>/dev/null; then
    echo >> "${HOME}/.zprofile"
    echo "eval \"\$($BREW_CMD shellenv)\"" >> "${HOME}/.zprofile"
fi
eval "$($BREW_CMD shellenv)"

brew update
brew install tmux vim stow fonttool keychain withgraphite/tap/graphite
