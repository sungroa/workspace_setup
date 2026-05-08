#!/usr/bin/env bash
# ==============================================================================
# setup_linux.sh - Linux Provisioning Logic
# ==============================================================================
# This script handles package management for major Linux distributions:
# - Debian/Ubuntu/Mint (apt)
# - Fedora/CentOS/RHEL (dnf)
# - Arch/Manjaro (pacman)
#
# It manages system updates, dependencies, locale configuration, and
# Node.js runtime environments (via 'n').
# ==============================================================================

# Fail on error, undefined vars, pipeline failures to prevent partial execution.
set -euo pipefail

# Resolve the directory this script lives in.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# Detect available package manager to support multiple distributions.
if command -v apt-get &> /dev/null; then
    PM="apt-get"
elif command -v dnf &> /dev/null; then
    PM="dnf"
elif command -v pacman &> /dev/null; then
    PM="pacman"
else
    echo "Error: Unsupported Linux distribution. No recognized package manager (apt, dnf, pacman) found."
    exit 1
fi

pkg_update() {
    case "$PM" in
        apt-get) sudo -E apt-get update -y ;;
        dnf) sudo -E dnf check-update || true ;;
        pacman) sudo -E pacman -Sy --noconfirm ;;
    esac
}

pkg_upgrade() {
    case "$PM" in
        apt-get) sudo -E apt-get upgrade -y && sudo -E apt-get autoremove -y ;;
        dnf) sudo -E dnf upgrade -y ;;
        pacman) sudo -E pacman -Syu --noconfirm ;;
    esac
}

pkg_install() {
    case "$PM" in
        apt-get) sudo -E apt-get install --no-install-recommends -y "$@" ;;
        dnf) sudo -E dnf install -y "$@" ;;
        pacman) sudo -E pacman -S --noconfirm --needed "$@" ;;
    esac
}

# Export DEBIAN_FRONTEND for Debian systems to prevent prompts
export DEBIAN_FRONTEND=noninteractive

# Dry-run mode: skip mutations but allow dependency/path validation.
if [[ "${1:-}" == "--dry-run" ]]; then
    echo "[dry-run:linux] Validating dependencies and path resolution..."
    if [ ! -f "${SCRIPT_DIR}/versions.json" ]; then
        echo "Error: versions.json not found in ${SCRIPT_DIR}"
        exit 1
    fi
    echo "[dry-run:linux] Path resolution and basic dependency checks passed."
    exit 0
fi

# System update (always) + upgrade (only with --upgrade flag).
pkg_update
if [[ "${1:-}" == "--upgrade" ]]; then
    echo "Upgrade flag detected. Running full system upgrade..."
    pkg_upgrade
fi

# Ensure jq is available for version parsing
if ! command -v jq &> /dev/null; then
    echo "jq not found. Installing bootstrap jq..."
    pkg_install jq
fi

# Load pinned versions from the unified JSON file to ensure environment consistency.
# If versions.json is missing, the script falls back to installing the 'latest' package.
VERSIONS_FILE="${SCRIPT_DIR}/versions.json"

# Helper function to resolve package names with pinned versions.
# Standardizes the pinning syntax for different package managers:
# apt: pkg=version
# dnf: pkg-version
# pacman: pkg (Latest only, as pacman pinning is discouraged)
get_pkg() {
    local base_pkg=$1
    local section=""
    case "$PM" in
        apt-get) section="apt" ;;
        dnf) section="dnf" ;;
        pacman) section="pacman" ;;
    esac
    
    if [ ! -f "$VERSIONS_FILE" ]; then
        echo "$base_pkg"
        return
    fi

    local version
    # Use jq to extract the pinned version for the current package manager.
    version=$(jq -r ".linux.${section}[\"${base_pkg}\"] // empty" "$VERSIONS_FILE")
    if [ -n "$version" ]; then
        case "$PM" in
            apt-get) echo "${base_pkg}=${version}" ;;
            dnf) echo "${base_pkg}-${version}" ;;
            pacman) echo "${base_pkg}" ;; 
        esac
    else
        # Fallback to base package name if no pin is found.
        echo "${base_pkg}"
    fi
}

PKGS=(
    "$(get_pkg tmux)"
    "$(get_pkg vim)"
    "$(get_pkg stow)"
    "$(get_pkg git)"
)

# Distro-specific Font/Locale naming
if [ "$PM" == "apt-get" ]; then
    PKGS+=("$(get_pkg fonts-noto)" "$(get_pkg fonts-noto-color-emoji)" "$(get_pkg fonts-powerline)" "$(get_pkg locales)" "$(get_pkg bash-completion)")
elif [ "$PM" == "dnf" ]; then
    PKGS+=("$(get_pkg google-noto-sans-fonts)" "$(get_pkg google-noto-emoji-color-fonts)" "$(get_pkg powerline-fonts)" "$(get_pkg bash-completion)")
elif [ "$PM" == "pacman" ]; then
    PKGS+=("noto-fonts" "noto-fonts-emoji" "powerline-fonts" "bash-completion")
fi

# To get basic settings and terminal enhancements.
pkg_install "${PKGS[@]}"

# Configure locale to ensure character encoding support.
if [ "$PM" == "apt-get" ]; then
    sudo locale-gen en_US.UTF-8
    sudo update-locale LANG=en_US.UTF-8
fi

# Node.js installation via NPM/N.
# We use 'n' to manage Node versions because it's lightweight and works well in scripts.
# python3-pip and python3-venv are required on Ubuntu 24.04+ (PEP 668 externally-managed Python).
if [ "$PM" == "apt-get" ]; then
    pkg_install "$(get_pkg python-is-python3)" "$(get_pkg npm)" "$(get_pkg python3-pip)" "$(get_pkg python3-venv)"
else
    # For dnf/pacman, assume python3/npm are available or standard names
    pkg_install "$(get_pkg npm)" "$(get_pkg python3)" "$(get_pkg python3-pip)"
fi

# Configure 'n' to install Node in a user-local directory (~/.n)
# to avoid permission issues and keep the system clean.
export N_PREFIX="$HOME/.n"
mkdir -p "$N_PREFIX"
npm config set prefix "$N_PREFIX"
npm install -g n
n lts             # Install the Long Term Support (LTS) version
n prune           # Remove old cached versions
hash -r           # Refresh command hash table
export PATH="$N_PREFIX/bin:$PATH"

# Install modern developer CLI tools
npm i -g @withgraphite/graphite-cli@1.x.x

# Agent skill dependencies (Python packages required by .agent/skills/)
# google-generativeai: used by the principal_engineer LLM behavioral test suite.
# Installed into a dedicated venv (~/.agent-venv) to respect PEP 668 on Ubuntu 24.04+.
echo "Installing Python agent skill dependencies..."
AGENT_VENV="${HOME}/.agent-venv"
python3 -m venv "$AGENT_VENV"
GENAI_VERSION=$(jq -r '.pip["google-generativeai"] // empty' "$VERSIONS_FILE" 2>/dev/null || echo "")
if [ -n "$GENAI_VERSION" ]; then
    "${AGENT_VENV}/bin/pip" install "google-generativeai==${GENAI_VERSION}"
else
    "${AGENT_VENV}/bin/pip" install google-generativeai
fi
echo "✅ Python agent skill dependencies installed into ${AGENT_VENV}."
echo "   Run tests with: ${AGENT_VENV}/bin/python3 .agent/skills/principal_engineer/tests/run_tests.py"

# Scaffold ~/.bash_secrets if it doesn't exist.
# This file is gitignored and holds machine-local secrets (API keys, tokens).
# It is sourced automatically by ~/.bash_common on every shell startup.
if [ ! -f "${HOME}/.bash_secrets" ]; then
    cat > "${HOME}/.bash_secrets" << 'SECRETS_EOF'
# ~/.bash_secrets — Machine-local secrets. DO NOT commit to git.
# Sourced automatically by ~/.bash_common on every shell startup.

# Gemini API key — used by .agent/skills/principal_engineer/tests/run_tests.py
# Get/regenerate at: https://aistudio.google.com/app/apikey
export GEMINI_API_KEY="your-gemini-api-key-here"
SECRETS_EOF
    chmod 600 "${HOME}/.bash_secrets"
    echo "✅ Created ~/.bash_secrets with placeholders. Edit it to add your API keys."
else
    echo "✅ ~/.bash_secrets already exists. Skipping scaffold."
fi

# SSH and Remote Access Tools
SSH_PKGS=("$(get_pkg keychain)")
if [ "$PM" == "apt-get" ]; then
    SSH_PKGS+=("$(get_pkg openssh-server)")
fi
pkg_install "${SSH_PKGS[@]}"
