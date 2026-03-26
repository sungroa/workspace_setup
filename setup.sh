#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to prevent partial/broken execution.
# This ensures fail-fast behavior.
set -euo pipefail

# Delegate to the appropriate OS-specific setup script based on the kernel name.
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

# Backup existing files that stow might collide with.
# We iterate over everything in the home/ directory (the stow source) 
# to proactively move any existing real files in $HOME out of the way. 
# GNU Stow will fail if it tries to symlink over a real file, so this ensures idempotency.
for f in $(ls -A home); do
  if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    echo "Backing up $HOME/$f to $HOME/$f.bak"
    mv "$HOME/$f" "$HOME/$f.bak"
  fi
done

# We need to ensure tools installed by setup scripts (like stow from brew) are in the PATH.
# On macOS, Homebrew binaries are not automatically in the PATH for non-interactive scripts,
# so we explicitly load the shellenv to make those tools available before calling stow.
if [ "$(uname -s)" = "Darwin" ]; then
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Finally, leverage GNU Stow to create symbolic links from the `home/` directory
# directly into the user's home directory (`~`).
stow -v -t ~ home
