#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}正在安装 Codex CLI...${NC}"
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
if command -v codex &> /dev/null; then
    echo -e "${YELLOW}⚠ Codex 已安装，版本信息：${NC}"
    codex --version 2>/dev/null || echo "  无法获取版本信息"
    echo ""
    read -p "是否重新安装？(y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${GREEN}已取消安装${NC}"
        exit 0
    fi
    echo -e "${BLUE}正在卸载旧版本...${NC}"
    npm uninstall -g @openai/codex 2>/dev/null || true
fi

echo -e "${BLUE}1. 正在安装 Codex CLI...${NC}"
npm install -g @openai/codex

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Codex 安装成功！${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}📋 使用说明：${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo "首次运行需要登录："
    echo "  codex login"
    echo ""
    echo "使用示例："
    echo "  codex \"帮我写一个 Python 函数\""
    echo "  codex --help"
    echo ""
    echo -e "${YELLOW}💡 提示：${NC}"
    echo "  建议使用 ChatGPT 账户登录以充分利用功能"
    echo "  更多信息: https://github.com/openai/codex"
    echo ""
else
    echo ""
    echo -e "${RED}❌ 安装失败${NC}"
    echo -e "${YELLOW}如果遇到权限问题，请尝试：${NC}"
    echo "  sudo npm install -g @openai/codex"
    exit 1
fi

