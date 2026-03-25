#!/usr/bin/env bash
# Fail on error, undefined variables, and pipeline failures.
set -euo pipefail

# Copies out all the appropriate files from this repo to ~.
rm -rf ~/.backup_my_personal_settings
mkdir -p ~/.backup_my_personal_settings

# shopt -s dotglob ensures * matches hidden files (dotfiles) too.
shopt -s dotglob
for file in *; do
    # Skip directories and specific files we don't want to copy.
    if [[ "$file" == ".git" ]] || [[ "$file" == ".gitignore" ]] || \
       [[ "$file" == *.swp ]] || [[ "$file" == *.sh ]] || \
       [[ "$file" == "bash_history_cache" ]]; then
        continue
    fi
    
    # Backup the current file in the home directory before overwriting it.
    if [[ -e "$HOME/$file" ]]; then
        cp -a "$HOME/$file" ~/.backup_my_personal_settings/
    fi
    
    echo "Copying $file to $HOME"
    cp -a "$file" "$HOME/"
done
