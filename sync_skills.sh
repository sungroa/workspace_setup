#!/usr/bin/env bash
# ==============================================================================
# sync_skills.sh - Agent Skill Synchronization Tool
# ==============================================================================
# This script bridges the gap between the agents global directory and the repo.
#
# Because agent skills MUST be hard-copied (not symlinked), we need a way
# to detect modifications made by the agent during a session and port them
# back to the repository for source control.
# ==============================================================================

set -euo pipefail

# Define source and destination paths.
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
SKILLS_SRC="${REPO_DIR}/.agent/skills"
GLOBAL_AGENT_DIR="${HOME}/.gemini/antigravity/skills"

echo "Comparing global agent skills against repository..."
if [ ! -d "$GLOBAL_AGENT_DIR" ]; then
    echo "No global skills directory found at $GLOBAL_AGENT_DIR."
    exit 0
fi

# Dry run sync: Detect if ANY differences exist between repo and global.
# We iterate through each skill directory in the repository.
CHANGES_DETECTED=0

for repodir in "$SKILLS_SRC"/*/; do
    skill=$(basename "$repodir")
    if [ -d "$GLOBAL_AGENT_DIR/$skill" ]; then
        # Check for meaningful differences. We ignore files that only exist in global
        # (like session-specific logs or agent-generated temporary files).
        if ! diff -qr "$GLOBAL_AGENT_DIR/$skill" "$SKILLS_SRC/$skill" | grep -qv "Only in $GLOBAL_AGENT_DIR"; then
            : # No meaningful differing contents
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
                # Perform the transfer using rsync.
                # --exclude="*.bak*": Crucial to avoid pulling back the agent's internal 
                # state backups which shouldn't be committed to Git.
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

# Check that GEMINI_API_KEY is set — required by the principal_engineer test suite.
# The key should live in ~/.bash_secrets (gitignored), not hardcoded here.
echo ""
if [ -z "${GEMINI_API_KEY:-}" ]; then
    echo "⚠️  GEMINI_API_KEY is not set in the current shell."
    echo "   The principal_engineer LLM behavioral tests will not run without it."
    echo ""
    echo "   To fix: add your key to ~/.bash_secrets:"
    echo "     echo 'export GEMINI_API_KEY=\"your-key-here\"' >> ~/.bash_secrets"
    echo "   Then reload: source ~/.bash_secrets"
    echo "   Get/regenerate key at: https://aistudio.google.com/app/apikey"
else
    echo "✅ GEMINI_API_KEY is set. Run tests with:"
    echo "   python3 .agent/skills/principal_engineer/tests/run_tests.py"
fi
