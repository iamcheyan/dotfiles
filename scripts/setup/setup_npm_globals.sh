#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="$SCRIPT_DIR/lib"
if [ -f "$LIB_DIR/npmrc_cleanup.sh" ]; then
    # shellcheck source=/dev/null
    source "$LIB_DIR/npmrc_cleanup.sh"
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installing Global NPM Packages                    ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"

if ! command -v fnm >/dev/null 2>&1; then
    echo -e "${RED}✗ fnm not found. Please run install_fnm.sh first.${NC}"
    exit 1
fi

eval "$(fnm env --shell bash)"

if command -v cleanup_npmrc_conflicts >/dev/null 2>&1; then
    cleanup_npmrc_conflicts
fi

if ! fnm use default >/dev/null 2>&1; then
    echo -e "${YELLOW}'default' Node version not found. Running setup_node.sh...${NC}"
    bash "$SCRIPT_DIR/setup_node.sh"
    eval "$(fnm env --shell bash)"
    fnm use default >/dev/null
fi

NODE_MAJOR_VERSION=$(node -v | cut -d'.' -f1 | tr -d 'v')
if [ "$NODE_MAJOR_VERSION" -lt 20 ]; then
    echo -e "${YELLOW}Current default Node version ($NODE_MAJOR_VERSION) is too old. Upgrading to 22...${NC}"
    bash "$SCRIPT_DIR/setup_node.sh"
    eval "$(fnm env --shell bash)"
    fnm use default >/dev/null
fi

unset NPM_CONFIG_PREFIX
npm config delete prefix --location=user 2>/dev/null || true

TOOLS=(
    "@openai/codex"
    "@google/gemini-cli"
    "neovim"
    "tree-sitter-cli"
)

echo -e "${BLUE}Using Node: $(node -v)${NC}"
echo -e "${BLUE}Using npm:  $(npm -v)${NC}"
echo ""

for tool in "${TOOLS[@]}"; do
    echo -e "${BLUE}Installing $tool...${NC}"
    npm install -g "$tool"
done

echo ""
echo -e "${GREEN}✓ All tools installed successfully.${NC}"
