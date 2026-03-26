#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to ensure robust operation.
set -euo pipefail

# Determine the absolute directory of the current script.
# This ensures the script works correctly no matter what directory it is executed from.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SKILLS_SRC="${REPO_DIR}/.agent/skills"

# The standard global agent directory Jetski processes.
GLOBAL_AGENT_DIR="${HOME}/.agent/skills"

echo "Configuring Jetski to default to this repository's skills..."

# Create the global agent config directory if it doesn't already exist.
mkdir -p "$GLOBAL_AGENT_DIR"

# Iterate over all skills in this repo and symlink them directly into the global directory.
# This approach avoids duplicating files, so updates to the repo directly reflect in the global agent pool.
for skill_path in "$SKILLS_SRC"/*; do
    if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        target_path="${GLOBAL_AGENT_DIR}/${skill_name}"
        
        # Remove existing symlink or folder safely to avoid `ln` errors or stow conflicts.
        # This provides idempotency so the script can be rerun without failure.
        if [ -e "$target_path" ] || [ -L "$target_path" ]; then
            rm -rf "$target_path"
        fi
        
        # Create exact symbolic link back to the repo logic.
        ln -s "$skill_path" "$target_path"
        echo "✅ Linked skill: ${skill_name} -> ${target_path}"
    fi
done

echo "Done! Jetski will now ingest these skills by default on startup."
