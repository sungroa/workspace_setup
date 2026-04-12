#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
VERSIONS_FILE="$SCRIPT_DIR/versions.json"

if [ ! -f "$VERSIONS_FILE" ]; then
    echo "Error: $VERSIONS_FILE not found. Initialize it first."
    exit 1
fi

echo "Fetching latest package versions for Linux (apt)..."
if ! command -v apt-cache &> /dev/null; then
    echo "apt-cache not found. Make sure you are on a Debian/Ubuntu system."
    exit 1
fi

if ! command -v jq &> /dev/null; then
    echo "jq not found. Please install it to update pins."
    exit 1
fi

PKGS=(tmux vim fonts-noto fonts-noto-color-emoji fonts-powerline stow locales bash-completion git python-is-python3 npm keychain openssh-server)

for pkg in "${PKGS[@]}"; do
    VERSION="$(apt-cache policy "$pkg" 2>/dev/null | grep 'Candidate:' | awk '{print $2}')"
    if [ -n "$VERSION" ]; then
        echo "Locking $pkg -> $VERSION"
        # Update the JSON file in-place using a temporary file
        tmp=$(mktemp)
        jq --arg pkg "$pkg" --arg ver "$VERSION" '.linux.apt[$pkg] = $ver' "$VERSIONS_FILE" > "$tmp" && mv "$tmp" "$VERSIONS_FILE"
    else
        echo "Warning: Could not find version for $pkg"
    fi
done

echo "Successfully updated $VERSIONS_FILE"
