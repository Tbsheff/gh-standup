#!/bin/bash
set -euo pipefail

# gh-standup installer (fallback for users who prefer curl over gh extension install)
# Preferred: gh extension install Tbsheff/gh-standup

REPO="Tbsheff/gh-standup"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.local/bin}"
SCRIPT_NAME="standup"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
NC='\033[0m'

info() { echo -e "${BLUE}>${NC} $1"; }
ok()   { echo -e "${GREEN}✓${NC} $1"; }
err()  { echo -e "${RED}✗${NC} $1"; }

echo ""
echo -e "${BOLD}📊 gh-standup installer${NC}"
echo ""

# Check dependencies
missing=()
command -v gh  &>/dev/null || missing+=("gh (GitHub CLI)")
command -v jq  &>/dev/null || missing+=("jq")

if [ ${#missing[@]} -gt 0 ]; then
    err "Missing required dependencies:"
    for dep in "${missing[@]}"; do
        echo "  - $dep"
    done
    echo ""
    info "Install with: ${BOLD}brew install gh jq${NC}"
    exit 1
fi

# Check gh auth
if ! gh auth status &>/dev/null; then
    err "GitHub CLI not authenticated. Run: ${BOLD}gh auth login${NC}"
    exit 1
fi
ok "GitHub CLI authenticated"

# Install as gh extension (preferred) or standalone
if gh extension install "$REPO" 2>/dev/null; then
    ok "Installed as gh extension"
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "  gh standup                     # auto-detects your GitHub org"
    echo "  gh standup --org mycompany     # specify org"
    echo "  gh standup --no-summary        # skip AI summary"
    echo "  gh standup --help              # all options"
else
    info "gh extension install failed, installing standalone..."
    mkdir -p "$INSTALL_DIR"
    curl -fsSL "https://raw.githubusercontent.com/${REPO}/main/gh-standup" -o "${INSTALL_DIR}/${SCRIPT_NAME}"
    chmod +x "${INSTALL_DIR}/${SCRIPT_NAME}"
    ok "Installed to ${INSTALL_DIR}/${SCRIPT_NAME}"

    if [[ ":$PATH:" != *":${INSTALL_DIR}:"* ]]; then
        echo ""
        info "Add to your PATH:"
        echo "  export PATH=\"$INSTALL_DIR:\$PATH\""
    fi

    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "  standup                        # auto-detects your GitHub org"
    echo "  standup --org mycompany        # specify org"
    echo "  standup --no-summary           # skip AI summary"
    echo "  standup --help                 # all options"
fi

echo ""
echo -e "${BOLD}Optional:${NC} Set ${DIM}FIREWORKS_API_KEY${NC} for AI summaries (Kimi K2.5 via Fireworks)"
echo ""
