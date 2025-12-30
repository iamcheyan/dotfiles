#!/bin/bash
set -e

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}  Setting up Node.js Environment                    ${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

export NVM_DIR="$HOME/.nvm"

# 尝试加载 nvm
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
else
    echo -e "${RED}✗ nvm not found. Please run install_nvm.sh first.${NC}"
    exit 1
fi

NODE_VERSION="20" # 使用主要版本号，nvm 会自动选择最新的 LTS

echo -e "${BLUE}Installing Node.js $NODE_VERSION...${NC}"
nvm install "$NODE_VERSION"

echo -e "${BLUE}Setting default version to $NODE_VERSION...${NC}"
nvm alias default "$NODE_VERSION"
nvm use default

echo ""
echo -e "${GREEN}✓ Node.js $(node -v) is ready.${NC}"
echo -e "${GREEN}✓ npm $(npm -v) is ready.${NC}"
