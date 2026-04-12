#!/usr/bin/env bash
# ==============================================================================
# setup_windows.sh - Windows (Git Bash/Winget) Provisioning Logic
# ==============================================================================
# This script manages Windows environments via Git Bash.
# It uses 'winget.exe' (Windows Package Manager) to install core utilities.
# Key features:
# 1. Detects winget availability inside the shell environment.
# 2. Performs idempotent installations of core apps (Git, Vim, Node, Python).
# 3. Synchronizes the Windows Registry PATH back into the bash environment.
# ==============================================================================

# Fail on error, undefined vars, pipeline failures.
set -euo pipefail

echo "Running Windows-specific workspace configuration..."

# Verify winget is accessible (usually it is inside modern Windows via Git Bash, running as winget.exe)
if ! command -v winget.exe &> /dev/null; then
  echo "Error: winget.exe not found. Windows Package Manager is required."
  exit 1
fi

# Dry-run mode: skip mutations but allow dependency/path validation.
if [[ "${1:-}" == "--dry-run" ]]; then
    echo "[dry-run:windows] Validating dependencies and path resolution..."
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
    if [ ! -f "${SCRIPT_DIR}/versions.json" ]; then
        echo "Error: versions.json not found in ${SCRIPT_DIR}"
        exit 1
    fi
    echo "[dry-run:windows] Path resolution and basic dependency checks passed."
    exit 0
fi

echo "Installing core utilities and runtimes..."
# Idempotent installation strictly without prompts.
# We iterate over a list of core packages and use versions.json if available.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
VERSIONS_FILE="${SCRIPT_DIR}/versions.json"

get_pkg_ver() {
    local target="$1"
    if [ ! -f "$VERSIONS_FILE" ]; then
        echo ""
        return
    fi
    jq -r ".windows.winget[\"${target}\"] // empty" "$VERSIONS_FILE"
}

for package in "Git.Git" "Vim.Vim" "OpenJS.NodeJS.LTS" "Python.Python.3.11" "Microsoft.CascadiaCode"; do
    VERSION="$(get_pkg_ver "$package")"
    INSTALL_ARGS=("--id" "$package" "--exact" "--silent" "--accept-package-agreements" "--accept-source-agreements")
    if [ -n "$VERSION" ]; then
        INSTALL_ARGS+=("--version" "$VERSION")
    fi

    if winget.exe list --exact --id "$package" &> /dev/null 2>&1; then
        echo "$package is already installed. Skipping."
    else
        echo "Installing $package ${VERSION:-}..."
        winget.exe install "${INSTALL_ARGS[@]}" \
            || echo "WARNING: Failed to install $package. Continuing with remaining packages."
    fi
done

echo "Refreshing PATH to detect newly installed tools..."
# Critical Step: Windows installations (like Node or Python) update the Registry PATH,
# but those changes aren't automatically visible in the current Git Bash session.
# We manually pull the 'Machine' and 'User' PATHs using PowerShell and convert them.
RAW_PATH=$(powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')" | tr -d '\r')

# Convert the semicolon-separated Windows path string (C:\...) to 
# a colon-separated Unix path string (/c/...) using 'cygpath'.
NEW_PATH=$(cygpath -u -p "$RAW_PATH")
export PATH="$NEW_PATH"

echo "Installing Node utilities..."
# Now that PATH is refreshed, attempt to install global npm packages.
if command -v npm &> /dev/null; then
    echo "npm detected. Installing graphite-cli..."
    npm install -g @withgraphite/graphite-cli@1.x.x
else
    echo "Warning: npm still not found in PATH. You may need to manually restart your terminal."
fi

echo "Windows setup script execution completed."
