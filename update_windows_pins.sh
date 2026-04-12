#!/usr/bin/env bash
# ==============================================================================
# update_windows_pins.sh - Windows Dependency Pinning Tool
# ==============================================================================
# This script refreshes the 'winget' package versions in versions.json.
# It queries 'winget.exe' for the latest available versions of core tools.
#
# Requirements: Windows environment with winget.exe, jq.
# Usage: ./update_windows_pins.sh
# ==============================================================================

set -euo pipefail

# Define operational paths.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/versions.json"

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "Error: $VERSIONS_FILE not found. Initialize it first."
    exit 1
fi

echo "Fetching latest package versions for Windows (winget)..."

# Dependency Check: winget.exe and jq are required.
if ! command -v winget.exe &> /dev/null; then
  echo "Error: winget.exe not found."
  exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq not found. Please install it to update pins."
    exit 1
fi

PKGS=("Git.Git" "Vim.Vim" "OpenJS.NodeJS.LTS" "Python.Python.3.11" "Microsoft.CascadiaCode")

for package in "${PKGS[@]}"; do
    # 'winget show' provides a detailed view of the package. 
    # We grep for the 'Version:' line and clean up Windows carriage returns (\r).
    VERSION="$(winget.exe show --id "$package" --exact | grep '^Version:' | awk '{print $2}' | tr -d '\r' || true)"
    if [ -n "$VERSION" ]; then
        echo "Locking $package -> $VERSION"
        # Atomic update of versions.json using a temporary file.
        tmp=$(mktemp)
        jq --arg pkg "$package" --arg ver "$VERSION" '.windows.winget[$pkg] = $ver' "$VERSIONS_FILE" > "$tmp" && mv "$tmp" "$VERSIONS_FILE"
    else
        echo "Warning: Could not find version for $package"
    fi
done

echo "Successfully updated $VERSIONS_FILE"
