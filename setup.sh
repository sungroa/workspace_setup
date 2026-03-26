#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures.
set -euo pipefail

case $(uname -s) in
  Darwin)
    ./setup_mac.sh
    ;;
  Linux)
    ./setup_linux.sh
    ;;
  *)
    echo "Unsupported OS."
    exit 1
    ;;
esac

# Backup existing files that stow might collision with
for f in .bashrc; do
  if [ -f "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    mv "$HOME/$f" "$HOME/$f.bak"
  fi
done

# We need to ensure tools installed by setup scripts (like stow from brew) are in the PATH
if [ "$(uname -s)" = "Darwin" ]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

stow -v -t ~ home
