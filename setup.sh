#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to prevent partial/broken execution.
# This ensures fail-fast behavior.
set -euo pipefail

# Delegate to the appropriate OS-specific setup script based on the kernel name.
case $(uname -s) in
  Darwin*)
    ./setup_mac.sh
    ;;
  Linux*)
    ./setup_linux.sh
    ;;
  MINGW*|MSYS*|CYGWIN*)
    ./setup_windows.sh
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

# Backup existing files that stow might collide with.
# We iterate over everything in the home/ directory (the stow source) 
# to proactively move any existing real files in $HOME out of the way. 
# GNU Stow will fail if it tries to symlink over a real file, so this ensures idempotency.
shopt -s dotglob nullglob
for filepath in home/*; do
  f=$(basename "$filepath")
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
# If stow is not natively available (common on Windows without specific builds),
# we fall back to standard `ln -snf` logic to achieve parity.
if command -v stow &> /dev/null; then
  stow -v -t ~ home
else
  echo "GNU Stow not found! Using standard 'ln -snf' fallback..."
  for filepath in home/*; do
    f=$(basename "$filepath")
    ln -snf "$(pwd)/home/$f" "$HOME/$f"
    echo "Linked $HOME/$f -> $(pwd)/home/$f"
  done
fi
