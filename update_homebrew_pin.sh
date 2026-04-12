#!/usr/bin/env bash
# ==============================================================================
# update_homebrew_pin.sh - macOS Homebrew Security Pinning Tool
# ==============================================================================
# This script updates the Homebrew installer commit and SHA256 sum in 
# versions.json. It ensures that the macOS setup process always uses a 
# verified and trusted version of the Homebrew installer.
#
# Requirements: git, curl, shasum, jq.
# Usage: ./update_homebrew_pin.sh
# ==============================================================================

set -euo pipefail

# Locate the versions.json file.
VERSIONS_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/versions.json"

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "Error: $VERSIONS_FILE not found. Initialize it first."
    exit 1
fi

echo "Fetching latest Homebrew installer commit from GitHub..."
# Resolve the latest HEAD commit hash from the official Homebrew repository.
COMMIT=$(git ls-remote https://github.com/Homebrew/install.git HEAD | awk '{print $1}')
if [ -z "$COMMIT" ]; then
    echo "Failed to fetch commit."
    exit 1
fi

URL="https://raw.githubusercontent.com/Homebrew/install/${COMMIT}/install.sh"
echo "Fetching installer script to compute SHA256 checksum..."
# Stream the installer script directly into shasum to calculate its hash.
SHA=$(curl -fsSL "$URL" | shasum -a 256 | awk '{print $1}')

echo "Latest Commit: $COMMIT"
echo "Latest SHA:    $SHA"
echo ""
echo "⚠️  TOFU WARNING: This is the first time you are trusting this specific commit."
echo "    Cross-verify the SHA against the official Homebrew repository:"
echo "    https://github.com/Homebrew/install/commit/$COMMIT"
echo ""
read -rp "Does the SHA look correct? Apply to versions.json? [y/N] " CONFIRM
if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Aborted. No changes made."
    exit 0
fi

if command -v jq &> /dev/null; then
    tmp=$(mktemp)
    jq --arg commit "$COMMIT" --arg sha "$SHA" '.mac.homebrew.installer_commit = $commit | .mac.homebrew.installer_sha256 = $sha' "$VERSIONS_FILE" > "$tmp" && mv "$tmp" "$VERSIONS_FILE"
    echo "Successfully updated $VERSIONS_FILE"
else
    echo "jq not found. Please install jq to update versions.json."
    exit 1
fi
