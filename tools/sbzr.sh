#!/bin/bash
# sbzr 命令：初始化/同步 Rime 配置并更新日语词库
# 功能：
#   1. 检查 Rime 配置目录是否为空
#   2. 如果为空，从 GitHub 拉取配置
#   3. 更新日语词库（jaroomaji）

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Rime 配置目录
RIME_DIR="$HOME/.dotfiles/config/rime"
GIT_REPO_URL="https://github.com/iamcheyan/rime.git"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}sbzr: Rime 配置初始化/同步工具${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# 检查目录是否存在
if [ ! -d "$RIME_DIR" ]; then
    echo -e "${YELLOW}创建 Rime 配置目录: $RIME_DIR${NC}"
    mkdir -p "$RIME_DIR"
fi

# 检查目录是否为空
# 判断标准：目录不存在、为空、或者只有 .git/.gitignore 文件
IS_EMPTY=true

# 检查是否有实际内容（排除 .git 和 .gitignore）
if [ -d "$RIME_DIR" ]; then
    # 查找除了 .git 和 .gitignore 之外的文件/目录
    # 使用 find 查找，排除隐藏的 .git 目录和 .gitignore 文件
    CONTENT_COUNT=$(find "$RIME_DIR" -mindepth 1 -maxdepth 1 \
        ! -name '.git' \
        ! -name '.gitignore' \
        ! -name '.DS_Store' \
        2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$CONTENT_COUNT" -gt 0 ]; then
        IS_EMPTY=false
    fi
fi

# 如果目录为空，从 GitHub 拉取
if [ "$IS_EMPTY" = true ]; then
    echo -e "${YELLOW}检测到 Rime 配置目录为空${NC}"
    echo -e "${CYAN}从 GitHub 拉取配置: $GIT_REPO_URL${NC}"
    echo ""
    
    cd "$RIME_DIR"
    
    # 如果已经有 .git 目录，先删除
    if [ -d ".git" ]; then
        echo -e "${YELLOW}清理现有的 .git 目录...${NC}"
        rm -rf .git
    fi
    
    # 从 GitHub 克隆
    echo -e "${YELLOW}正在克隆仓库...${NC}"
    if git clone "$GIT_REPO_URL" . 2>&1; then
        echo -e "${GREEN}✓ 配置已从 GitHub 拉取完成${NC}"
    else
        echo -e "${RED}✗ 从 GitHub 拉取失败${NC}"
        echo -e "${YELLOW}请检查网络连接或稍后重试${NC}"
        exit 1
    fi
    
    echo ""
else
    echo -e "${GREEN}✓ Rime 配置目录已有内容，跳过初始化${NC}"
    echo ""
    
    # 如果已经有 .git，可以选择更新
    if [ -d "$RIME_DIR/.git" ]; then
        echo -e "${YELLOW}检测到 Git 仓库，是否更新配置？ (y/n):${NC}"
        read -t 5 UPDATE_CHOICE || UPDATE_CHOICE="n"
        
        if [ "$UPDATE_CHOICE" = "y" ] || [ "$UPDATE_CHOICE" = "Y" ]; then
            echo -e "${CYAN}正在更新配置...${NC}"
            cd "$RIME_DIR"
            if git pull 2>&1; then
                echo -e "${GREEN}✓ 配置已更新${NC}"
            else
                echo -e "${YELLOW}⚠ 更新失败，继续执行...${NC}"
            fi
            echo ""
        fi
    fi
fi

# 更新日语词库
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}更新日语词库 (jaroomaji)${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

JAROOMAJI_SCRIPT="$RIME_DIR/scripts/manage_jaroomaji.sh"

if [ -f "$JAROOMAJI_SCRIPT" ]; then
    echo -e "${CYAN}运行 jaroomaji 管理脚本...${NC}"
    echo ""
    
    # 切换到 Rime 目录执行脚本
    cd "$RIME_DIR"
    bash "$JAROOMAJI_SCRIPT"
    
    echo ""
    echo -e "${GREEN}✓ 日语词库更新完成${NC}"
else
    echo -e "${YELLOW}⚠ 未找到 jaroomaji 管理脚本: $JAROOMAJI_SCRIPT${NC}"
    echo -e "${YELLOW}跳过日语词库更新${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}sbzr 执行完成！${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}提示：${NC}"
echo -e "${CYAN}  1. 如果配置已更新，请重新部署 Rime 配置${NC}"
echo -e "${CYAN}  2. macOS: 在系统设置 > 键盘 > 输入法中重新部署${NC}"
echo -e "${CYAN}  3. Linux: 运行 ./scripts/rebuild.sh 或 rime_deployer --build${NC}"

