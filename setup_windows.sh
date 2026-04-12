#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures.
set -euo pipefail

echo "Running Windows-specific workspace configuration..."

# Verify winget is accessible (usually it is inside modern Windows via Git Bash, running as winget.exe)
if ! command -v winget.exe &> /dev/null; then
  echo "Error: winget.exe not found. Windows Package Manager is required."
  exit 1
fi

echo "Installing core utilities and runtimes..."
# Idempotent installation strictly without prompts.
# We capture the exit code from `winget list` to avoid set -e aborting
# on network errors (which also return non-zero).
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
# Extract the combined Machine/User PATH from the Windows registry via PowerShell.
# We join them with a semicolon and then let 'cygpath' convert the entire string to Unix format.
RAW_PATH=$(powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "[Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')" | tr -d '\r')
# Convert the semicolon-separated Windows path to a colon-separated Unix path.
export PATH=$(cygpath -u -p "$RAW_PATH")

echo "Installing Node utilities..."
# Now that PATH is refreshed, attempt to install global npm packages.
if command -v npm &> /dev/null; then
    echo "npm detected. Installing graphite-cli..."
    npm install -g @withgraphite/graphite-cli@1.x.x
else
    echo "Warning: npm still not found in PATH. You may need to manually restart your terminal."
fi

echo "Windows setup script execution completed."
