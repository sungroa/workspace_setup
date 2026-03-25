#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures.
set -euo pipefail

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> "${HOME}/.zprofile"
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "${HOME}/.zprofile"
eval "$(/opt/homebrew/bin/brew shellenv)"

brew update
brew install tmux vim fonttool withgraphite/tap/graphite
