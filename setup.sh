#!/usr/bin/env bash
# ==============================================================================
# setup.sh - Primary Workspace Entry Point
# ==============================================================================
# This script coordinates the tiered installation process:
# 1. Detects the operating system (Linux, macOS, Windows).
# 2. Delegates to OS-specific drivers for package/runtime installation.
# 3. Performs pre-emptive backups of existing dotfiles to prevent collisions.
# 4. Deploys dotfiles using GNU Stow (or a symlink fallback).
#
# Usage: ./setup.sh [--upgrade] [--dry-run]
# ==============================================================================

# Fail on error, undefined vars, pipeline failures to prevent partial/broken execution.
# This ensures fail-fast behavior.
set -euo pipefail

# Resolve the directory this script lives in, so sibling scripts can be called
# regardless of the caller's working directory.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Dry-run mode: validate the script can parse and detect the OS without mutating state.
# Used by CI pipelines and the project manifest's validation commands.
if [[ "${1:-}" == "--dry-run" ]]; then
  echo "[dry-run] OS detected: $(uname -s)"
  echo "[dry-run] Script directory: ${SCRIPT_DIR}"
  echo "[dry-run] Would install OS-specific packages and deploy dotfiles to ${HOME}"
  echo "[dry-run] Dotfiles to deploy:"
  shopt -s dotglob nullglob
  for filepath in "${SCRIPT_DIR}"/home/*; do
    echo "  $(basename "$filepath")"
  done
  
  echo "[dry-run] Delegating to OS-specific validation..."
  case $(uname -s) in
    Darwin*)
      bash "${SCRIPT_DIR}/setup_mac.sh" --dry-run
      ;;
    Linux*)
      bash "${SCRIPT_DIR}/setup_linux.sh" --dry-run
      ;;
    MINGW*|MSYS*|CYGWIN*)
      bash "${SCRIPT_DIR}/setup_windows.sh" --dry-run
      ;;
    *)
      echo "Unsupported OS for dry-run delegation: $(uname -s)"
      ;;
  esac
  
  echo "[dry-run] Validation passed."
  exit 0
fi

# Delegate to the appropriate OS-specific setup script based on the kernel name.
# Forward all arguments (e.g., --upgrade) so OS scripts can act on them.
case $(uname -s) in
  Darwin*)
    bash "${SCRIPT_DIR}/setup_mac.sh" "$@"
    ;;
  Linux*)
    bash "${SCRIPT_DIR}/setup_linux.sh" "$@"
    ;;
  MINGW*|MSYS*|CYGWIN*)
    bash "${SCRIPT_DIR}/setup_windows.sh" "$@"
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
BACKUP_DIR=""
for filepath in "${SCRIPT_DIR}"/home/*; do
  f=$(basename "$filepath")
  if [ -e "$HOME/$f" ] && [ ! -L "$HOME/$f" ]; then
    if [ -z "$BACKUP_DIR" ]; then
      BACKUP_DIR="${HOME}/.dotfiles_backup.$(date +%Y%m%d_%H%M%S)"
      mkdir -p "$BACKUP_DIR"
      echo "Detected file collisions. Creating backup directory: $BACKUP_DIR"
    fi
    echo "Backing up $HOME/$f to $BACKUP_DIR/$f"
    mv "$HOME/$f" "$BACKUP_DIR/$f"
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
  stow -v -d "${SCRIPT_DIR}" -t ~ home
else
  echo "GNU Stow not found! Using standard 'ln -snf' fallback..."
  for filepath in "${SCRIPT_DIR}"/home/*; do
    f=$(basename "$filepath")
    ln -snf "${SCRIPT_DIR}/home/$f" "$HOME/$f"
    echo "Linked $HOME/$f -> ${SCRIPT_DIR}/home/$f"
  done
fi

