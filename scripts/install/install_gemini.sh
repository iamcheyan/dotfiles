#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}正在安装 Gemini CLI...${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# 检查 Node.js 和 npm
if ! command -v node &> /dev/null; then
    echo -e "${RED}❌ 错误：未找到 Node.js${NC}"
    echo -e "${YELLOW}请先安装 Node.js：${NC}"
    echo "  sudo apt install nodejs npm"
    echo "  或访问: https://nodejs.org/"
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ 错误：未找到 npm${NC}"
    echo -e "${YELLOW}请先安装 npm${NC}"
    exit 1
fi

echo -e "${BLUE}✓ Node.js 版本: $(node -v)${NC}"
echo -e "${BLUE}✓ npm 版本: $(npm -v)${NC}"
echo ""

# 检查是否已安装
if command -v gemini &> /dev/null; then
    echo -e "${YELLOW}⚠ Gemini 已安装，版本信息：${NC}"
    gemini --version 2>/dev/null || echo "  无法获取版本信息"
    echo ""
    read -p "是否重新安装？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}已取消安装${NC}"
        exit 0
    fi
    echo -e "${BLUE}正在卸载旧版本...${NC}"
    npm uninstall -g @google/gemini-cli 2>/dev/null || true
fi

echo -e "${BLUE}1. 正在安装 Gemini CLI...${NC}"
npm install -g @google/gemini-cli

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Gemini 安装成功！${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📋 使用说明：${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "首次运行需要登录："
    echo "  gemini login"
    echo ""
    echo "使用示例："
    echo "  gemini \"帮我写一个 React 组件\""
    echo "  gemini --help"
    echo ""
    echo -e "${YELLOW}💡 提示：${NC}"
    echo "  需要 Google 账户和 API 密钥"
    echo "  更多信息: https://geminicli.me/"
    echo ""
else
    echo ""
    echo -e "${RED}❌ 安装失败${NC}"
    echo -e "${YELLOW}如果遇到权限问题，请尝试：${NC}"
    echo "  sudo npm install -g @google/gemini-cli"
    exit 1
fi

