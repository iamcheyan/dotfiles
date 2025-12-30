#!/bin/bash
set -e

# 颜色定义
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Checking environment for Gemini installation...${NC}"

# Check if NVM is installed
export NVM_DIR="$HOME/.nvm"
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
    echo -e "${BLUE}NVM not found. Initiating full environment setup...${NC}"
    # Run the main install script which chains everything (nvm -> node -> tools)
    bash "$SCRIPT_DIR/install_nvm.sh"
else
    echo -e "${BLUE}NVM found. Ensuring npm globals are installed...${NC}"
    # Just ensure tools are installed
    bash "$SCRIPT_DIR/setup_npm_globals.sh"
fi
