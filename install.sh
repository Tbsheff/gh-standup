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

    # Create 'standup' alias so users can just type 'standup'
    alias_installed=false
    if [ -f "$HOME/.config/fish/config.fish" ]; then
        if ! grep -q 'standup' "$HOME/.config/fish/config.fish" 2>/dev/null; then
            echo "" >> "$HOME/.config/fish/config.fish"
            echo "alias standup 'gh standup'" >> "$HOME/.config/fish/config.fish"
            ok "Added ${BOLD}standup${NC} alias to ~/.config/fish/config.fish"
            alias_installed=true
        else
            ok "Fish alias already exists"
            alias_installed=true
        fi
    fi
    if [ -f "$HOME/.zshrc" ]; then
        if ! grep -q "alias standup=" "$HOME/.zshrc" 2>/dev/null; then
            echo "" >> "$HOME/.zshrc"
            echo "alias standup='gh standup'" >> "$HOME/.zshrc"
            ok "Added ${BOLD}standup${NC} alias to ~/.zshrc"
            alias_installed=true
        else
            ok "Zsh alias already exists"
            alias_installed=true
        fi
    fi
    if [ -f "$HOME/.bashrc" ]; then
        if ! grep -q "alias standup=" "$HOME/.bashrc" 2>/dev/null; then
            echo "" >> "$HOME/.bashrc"
            echo "alias standup='gh standup'" >> "$HOME/.bashrc"
            ok "Added ${BOLD}standup${NC} alias to ~/.bashrc"
            alias_installed=true
        fi
    fi
    if [ "$alias_installed" = false ]; then
        info "Add this alias to your shell config:"
        echo "  alias standup='gh standup'"
    fi

    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "  standup                        # just works"
    echo "  standup --org mycompany        # specify org"
    echo "  standup --no-summary           # skip AI summary"
    echo "  standup --help                 # all options"
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
