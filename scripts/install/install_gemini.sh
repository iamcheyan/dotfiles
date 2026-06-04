#!/bin/bash
set -e

# 颜色定义
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo -e "${BLUE}Checking environment for Gemini installation...${NC}"

# Check if fnm is installed
export FNM_DIR="${FNM_DIR:-$HOME/.fnm}"
export PATH="$FNM_DIR:$FNM_DIR/bin:$HOME/.local/share/fnm:$HOME/.local/bin:$PATH"
if ! command -v fnm >/dev/null 2>&1; then
    echo -e "${BLUE}fnm not found. Initiating full environment setup...${NC}"
    # Run the main install script which chains everything (fnm -> node -> tools)
    bash "$SCRIPT_DIR/install_nvm.sh"
else
    echo -e "${BLUE}fnm found. Ensuring npm globals are installed...${NC}"
    # Just ensure tools are installed
    bash "$SCRIPT_DIR/setup_npm_globals.sh"
fi
