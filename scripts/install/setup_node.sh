#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Setting up Node.js Environment with fnm           ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if ! command -v fnm >/dev/null 2>&1; then
    echo -e "${RED}✗ fnm not found. Please run install_nvm.sh first.${NC}"
    exit 1
fi

eval "$(fnm env --shell bash)"

NODE_VERSION="22"

echo -e "${BLUE}Installing Node.js $NODE_VERSION...${NC}"
fnm install "$NODE_VERSION"

echo -e "${BLUE}Setting default version to $NODE_VERSION...${NC}"
fnm default "$NODE_VERSION"
fnm use default

echo ""
echo -e "${GREEN}✓ Node.js $(node -v) is ready.${NC}"
echo -e "${GREEN}✓ npm $(npm -v) is ready.${NC}"
