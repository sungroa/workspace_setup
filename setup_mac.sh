#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures to prevent partial execution.
set -euo pipefail

# Load versions from unified JSON
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
VERSIONS_FILE="${SCRIPT_DIR}/versions.json"

# Check if homebrew is already installed before attempting an installation.
if ! command -v brew &> /dev/null; then
    # Pinned to ensure security integrity. 
    # Read from versions.json if available, otherwise fallback to defaults.
    if [ -f "$VERSIONS_FILE" ] && command -v jq &> /dev/null; then
        BREW_COMMIT=$(jq -r '.mac.homebrew.installer_commit' "$VERSIONS_FILE")
        EXPECTED_SHA=$(jq -r '.mac.homebrew.installer_sha256' "$VERSIONS_FILE")
    else
        BREW_COMMIT="de0b0bddf1c78731dcd16d953b2f5d29d070e229"
        EXPECTED_SHA="dfd5145fe2aa5956a600e35848765273f5798ce6def01bd08ecec088a1268d91"
    fi

    BREW_INSTALLER="$(mktemp)"
    trap 'rm -f "$BREW_INSTALLER"' EXIT
    curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/${BREW_COMMIT}/install.sh" -o "$BREW_INSTALLER"
    
    # Cryptographic Validation
    DOWNLOADED_SHA="$(shasum -a 256 "$BREW_INSTALLER" | cut -d' ' -f1)"
    if [ "$DOWNLOADED_SHA" != "$EXPECTED_SHA" ]; then
        echo "CRITICAL: Homebrew installer checksum mismatch!"
        echo "Expected: $EXPECTED_SHA"
        echo "Actual:   $DOWNLOADED_SHA"
        exit 1
    fi
    echo "Homebrew installer checksum verified: $EXPECTED_SHA"
    NONINTERACTIVE=1 /bin/bash "$BREW_INSTALLER"
else
    echo "Homebrew already installed."
fi

# Dynamically set the brew path based on system architecture.
if [[ -x /opt/homebrew/bin/brew ]]; then
    BREW_CMD="/opt/homebrew/bin/brew"
elif [[ -x /usr/local/bin/brew ]]; then
    BREW_CMD="/usr/local/bin/brew"
else
    echo "Homebrew not found!"
    exit 1
fi

# Idempotently add homebrew to the PATH for login shells.
for profile in "${HOME}/.zprofile" "${HOME}/.bash_profile"; do
    if ! grep -q "brew shellenv" "$profile" 2>/dev/null; then
        echo >> "$profile"
        echo "eval \"\$($BREW_CMD shellenv)\"" >> "$profile"
    fi
done
eval "$($BREW_CMD shellenv)"

# Throttled brew update (Once every 24 hours) to optimize performance.
LAST_UPDATE_FILE="${HOME}/.brew_update_last_run"
NOW=$(date +%s)
ONE_DAY=$((24 * 60 * 60))
if [ ! -f "$LAST_UPDATE_FILE" ] || [ $((NOW - $(cat "$LAST_UPDATE_FILE" 2>/dev/null || echo 0))) -gt $ONE_DAY ]; then
    echo "Running throttled brew update..."
    brew update
    date +%s > "$LAST_UPDATE_FILE"
else
    echo "Skipping brew update (last run less than 24h ago)."
fi

brew install tmux vim stow fonttool keychain withgraphite/tap/graphite
