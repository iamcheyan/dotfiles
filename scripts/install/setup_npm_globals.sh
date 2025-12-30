#!/bin/bash
set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installing Global NPM Packages                    ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

export NVM_DIR="$HOME/.nvm"


# 尝试加载 nvm
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
else
    echo -e "${RED}✗ nvm not found. Please run install_nvm.sh first.${NC}"
    exit 1
fi

# Ensure we are using the default node version and environment
echo -e "${BLUE}Activating nvm environment...${NC}"

# Helper function to ensure setup_node.sh is run if needed
ensure_node_setup() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [ -f "$script_dir/setup_node.sh" ]; then
        echo -e "${YELLOW}'default' alias not found or invalid. Running setup_node.sh...${NC}"
        bash "$script_dir/setup_node.sh"
        # Reload nvm to pick up changes
        . "$NVM_DIR/nvm.sh"
    else
        echo -e "${RED}Error: setup_node.sh not found and 'default' alias is missing.${NC}"
        echo -e "${YELLOW}Please run: nvm install 18 && nvm alias default 18${NC}"
        exit 1
    fi
}

if ! nvm use default >/dev/null 2>&1; then
    ensure_node_setup
else
    # Check if the default version is at least 20
    NODE_MAJOR_VERSION=$(node -v | cut -d'.' -f1 | tr -d 'v')
    if [ "$NODE_MAJOR_VERSION" -lt 20 ]; then
        echo -e "${YELLOW}Current default Node version ($NODE_MAJOR_VERSION) is too old. Upgrading to 20...${NC}"
        ensure_node_setup
    fi
fi

# Try again to activate
if ! nvm use default >/dev/null 2>&1; then
     echo -e "${RED}Failed to activate default node version even after setup.${NC}"
     exit 1
fi

# Unset any potential prefix override that might be causing permissions issues
unset NPM_CONFIG_PREFIX
# Force delete user prefix if it exists (just in case)
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
