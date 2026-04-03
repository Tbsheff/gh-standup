#!/bin/bash
set -euo pipefail

# standup-report installer
# Usage: curl -fsSL https://raw.githubusercontent.com/Tbsheff/standup-report/main/install.sh | bash

REPO="Tbsheff/standup-report"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
SCRIPT_NAME="standup-report"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC} $1"; }
err()  { echo -e "${RED}[ERROR]${NC} $1"; }

echo ""
echo -e "${BOLD}📊 standup-report installer${NC}"
echo ""

# Check dependencies
missing=()
command -v gh  &>/dev/null || missing+=("gh (GitHub CLI)")
command -v jq  &>/dev/null || missing+=("jq")
command -v curl &>/dev/null || missing+=("curl")

if [ ${#missing[@]} -gt 0 ]; then
    err "Missing required dependencies:"
    for dep in "${missing[@]}"; do
        echo "  - $dep"
    done
    echo ""
    info "Install with: brew install gh jq curl"
    exit 1
fi

# Check gh auth
if ! gh auth status &>/dev/null; then
    err "GitHub CLI not authenticated. Run: gh auth login"
    exit 1
fi
ok "GitHub CLI authenticated"

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download the script
info "Downloading standup-report..."
curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/standup-report" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
ok "Installed to ${INSTALL_DIR}/${SCRIPT_NAME}"

# Check if install dir is in PATH
if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
    echo ""
    echo -e "${BOLD}Add to your PATH:${NC}"

    if [ -f "$HOME/.config/fish/config.fish" ]; then
        echo -e "  ${DIM}# Fish shell${NC}"
        echo "  fish_add_path $INSTALL_DIR"
    fi
    if [ -f "$HOME/.zshrc" ]; then
        echo -e "  ${DIM}# Zsh${NC}"
        echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.zshrc"
    fi
    if [ -f "$HOME/.bashrc" ]; then
        echo -e "  ${DIM}# Bash${NC}"
        echo "  echo 'export PATH=\"$INSTALL_DIR:\$PATH\"' >> ~/.bashrc"
    fi
fi

echo ""
echo -e "${BOLD}Optional: AI-powered standup summary${NC}"
echo -e "  Set ${DIM}FIREWORKS_API_KEY${NC} for AI summaries (uses Kimi K2.5 via Fireworks)"
echo -e "  Or use ${DIM}--provider claude${NC} with Claude CLI installed"
echo ""
echo -e "${BOLD}Usage:${NC}"
echo "  standup-report                    # auto-detects your GitHub org"
echo "  standup-report --org mycompany    # specify org"
echo "  standup-report --no-summary       # skip AI summary"
echo "  standup-report --help             # all options"
echo ""
ok "Done! Run ${BOLD}standup-report${NC} to try it."
