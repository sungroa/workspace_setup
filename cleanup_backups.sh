#!/usr/bin/env bash
# cleanup_backups.sh: Safely remove old timestamped dotfile backups.
set -euo pipefail

# Default to 7 days if not specified
DAYS_OLD="${1:-7}"

echo "Cleaning up dotfile backups older than $DAYS_OLD days..."

# We search for .dotfiles_backup.* directories in $HOME
# and delete them if their modification time is older than the threshold.
# 'mtime' is used as a proxy for the backup date.
find "$HOME" -maxdepth 1 -name ".dotfiles_backup.*" -type d -mtime +"$DAYS_OLD" -print -exec rm -rf {} +

echo "Cleanup complete."
