#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SKILLS_SRC="${REPO_DIR}/.agent/skills"
GLOBAL_AGENT_DIR="${HOME}/.gemini/antigravity/skills"

echo "Comparing global agent skills against repository..."
if [ ! -d "$GLOBAL_AGENT_DIR" ]; then
    echo "No global skills directory found at $GLOBAL_AGENT_DIR."
    exit 0
fi

# Dry run sync using rsync logic or diff
CHANGES_DETECTED=0

for repodir in "$SKILLS_SRC"/*/; do
    skill=$(basename "$repodir")
    if [ -d "$GLOBAL_AGENT_DIR/$skill" ]; then
        if ! diff -qr "$GLOBAL_AGENT_DIR/$skill" "$SKILLS_SRC/$skill" | grep -qv "Only in $GLOBAL_AGENT_DIR"; then
            : # No meaningful differing contents (ignoring extra files like backups locally in global)
        else
            echo "Changes detected in skill: $skill"
            CHANGES_DETECTED=1
        fi
    fi
done

if [ $CHANGES_DETECTED -eq 1 ]; then
    echo "There are differences between your active global skills and the local repository."
    read -rp "Would you like to sync modifications from global BACK into the repo? [y/N] " CONFIRM
    if [[ "$CONFIRM" == "y" || "$CONFIRM" == "Y" ]]; then
        for repodir in "$SKILLS_SRC"/*/; do
            skill=$(basename "$repodir")
            if [ -d "$GLOBAL_AGENT_DIR/$skill" ]; then
                # Rsync back, excluding any backup files the agent might generate
                rsync -av --exclude="*.bak*" "$GLOBAL_AGENT_DIR/$skill/" "$SKILLS_SRC/$skill/"
            fi
        done
        echo "✅ Skills synchronized back to repository."
    else
        echo "Sync aborted."
    fi
else
    echo "✅ Agent skills are perfectly in sync."
fi
