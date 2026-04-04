#!/usr/bin/env bash
# Fail on error, undefined vars, pipeline failures.
set -euo pipefail

echo "Running Windows-specific workspace configuration..."

# Verify winget is accessible (usually it is inside modern Windows via Git Bash, running as winget.exe)
if ! command -v winget.exe &> /dev/null; then
  echo "Error: winget.exe not found. Windows Package Manager is required."
  exit 1
fi

echo "Installing core utilities..."
# Install strictly without prompts
winget.exe install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements || true
winget.exe install --id Vim.Vim --exact --silent --accept-package-agreements --accept-source-agreements || true

echo "Installing runtimes..."
winget.exe install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements || true
winget.exe install --id Python.Python.3.11 --exact --silent --accept-package-agreements --accept-source-agreements || true

echo "Installing fonts (Microsoft Cascadia Code handles powerline)..."
winget.exe install --id Microsoft.CascadiaCode --exact --silent --accept-package-agreements --accept-source-agreements || echo "Font installation handled or skipped."

echo "Installing Node utilities..."
# Since winget installs Node natively, the bash environment might not see 'npm' immediately until reboot.
# Try to install graphite-cli if npm is available now. 
if command -v npm &> /dev/null; then
    npm install -g @withgraphite/graphite-cli
else
    echo "Warning: npm not found in current PATH. You may need to restart your terminal and run: 'npm install -g @withgraphite/graphite-cli' manually."
fi

echo "Windows setup script execution completed."
