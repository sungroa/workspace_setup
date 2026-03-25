#!/usr/bin/env bash
# Fail on error, undefined variables, and pipeline failures.
set -euo pipefail

# Loads all the appropriate files into this repo from ~.
rm -rf ~/.backup_my_personal_settings
mkdir -p ~/.backup_my_personal_settings

# shopt -s dotglob ensures * matches hidden files (dotfiles) too.
shopt -s dotglob
for file in *; do
    # Skip directories and specific files we don't want to load over.
    if [[ "$file" == ".git" ]] || [[ "$file" == ".gitignore" ]] || \
       [[ "$file" == *.swp ]] || [[ "$file" == *.sh ]] || \
       [[ "$file" == "bash_history_cache" ]]; then
        continue
    fi
    
    # Backup the current file in the repo before overwriting it.
    if [[ -e "$file" ]]; then
        cp -a "$file" ~/.backup_my_personal_settings/
    fi

    echo "Loading $file from $HOME"
    cp -a "$HOME/$file" .
done
