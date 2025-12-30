#!/bin/bash
set -e

# 颜色定义
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Installing NVM (Node Version Manager)             ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

NVM_VERSION="v0.39.7"
NVM_DIR="$HOME/.nvm"

if [ -d "$NVM_DIR" ]; then
    echo -e "${GREEN}✓ nvm already installed at $NVM_DIR${NC}"
    exit 0
fi

echo -e "${BLUE}Downloading and installing nvm $NVM_VERSION...${NC}"
curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash

echo ""
echo -e "${GREEN}✓ nvm installed successfully.${NC}"

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Chain subsequent setup scripts
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
echo -e "${BLUE}IMPORTANT: Please restart your shell or run 'source ~/.zshrc' to start using nvm and the installed tools.${NC}"
