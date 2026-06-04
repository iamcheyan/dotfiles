#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installing fnm (Fast Node Manager)                ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if command -v fnm >/dev/null 2>&1; then
    echo -e "${GREEN}✓ fnm already installed: $(command -v fnm)${NC}"
else
    if ! command -v curl >/dev/null 2>&1; then
        echo -e "${RED}✗ curl is required to install fnm${NC}"
        exit 1
    fi
    echo -e "${BLUE}Downloading and installing fnm...${NC}"
    curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell
fi

export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if ! command -v fnm >/dev/null 2>&1; then
    echo -e "${RED}✗ fnm installation failed${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}✓ fnm installed successfully.${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo ""
echo -e "${BLUE}Proceeding to Node.js setup...${NC}"
if [ -f "$SCRIPT_DIR/setup_node.sh" ]; then
    bash "$SCRIPT_DIR/setup_node.sh"
else
    echo -e "${RED}Warning: setup_node.sh not found in $SCRIPT_DIR${NC}"
fi

echo ""
echo -e "${BLUE}Proceeding to NPM Global Tools setup...${NC}"
if [ -f "$SCRIPT_DIR/setup_npm_globals.sh" ]; then
    bash "$SCRIPT_DIR/setup_npm_globals.sh"
else
    echo -e "${RED}Warning: setup_npm_globals.sh not found in $SCRIPT_DIR${NC}"
fi

echo ""
echo -e "${GREEN}✓ All installation steps completed.${NC}"
echo -e "${BLUE}IMPORTANT: Please restart your shell or run 'source ~/.zshrc' to start using fnm and the installed tools.${NC}"
