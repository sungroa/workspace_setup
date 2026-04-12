#!/usr/bin/env bash
# ==============================================================================
# cleanup_backups.sh - Maintenance Tool for Dotfile Backups
# ==============================================================================
# This script identifies and removes old timestamped backup directories
# created by 'setup.sh' during dotfile conflicts.
#
# Usage: ./cleanup_backups.sh [age_in_days (default: 7)]
# ==============================================================================

set -euo pipefail

# Default to 7 days if no threshold is specified by the caller.
DAYS_OLD="${1:-7}"

echo "Cleaning up dotfile backups older than $DAYS_OLD days..."

# Discovery Logic:
# 1. We search for .dotfiles_backup.* directories directly in the HOME root.
# 2. We use 'mtime' (modification time) as the selector for age.
# 3. Directories are deleted recursively with 'rm -rf'.
find "$HOME" -maxdepth 1 -name ".dotfiles_backup.*" -type d -mtime +"$DAYS_OLD" -print -exec rm -rf {} +

echo "Cleanup complete."
