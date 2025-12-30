#!/bin/bash
# ============================================
# Yazi Flavors 更新脚本
# 从 yazi-rs/flavors 仓库克隆/更新所有主题到 ~/.dotfiles/config/yazi/flavors
# ============================================

set -e

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
FLAVORS_REPO="https://github.com/yazi-rs/flavors.git"
TARGET_DIR="$HOME/.dotfiles/config/yazi/flavors"
TEMP_DIR=$(mktemp -d)
REPO_DIR="$TEMP_DIR/flavors"

# 额外的主题仓库（格式：仓库URL|目标目录名）
EXTRA_FLAVORS=(
    "https://github.com/dangooddd/kanagawa.yazi.git|kanagawa.yazi"
    "https://github.com/gosxrgxx/flexoki-dark.yazi.git|flexoki-dark.yazi"
    "https://github.com/Miuzarte/synthwave84.yazi.git|synthwave84.yazi"
)

# 清理函数
cleanup() {
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
    fi
}

# 注册清理函数
trap cleanup EXIT

# 打印信息
info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

success() {
    echo -e "${GREEN}✓${NC} $1"
}

warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

error() {
    echo -e "${RED}✗${NC} $1"
}

# 检查 git 是否安装
if ! command -v git &> /dev/null; then
    error "git 未安装，请先安装 git"
    exit 1
fi

# 创建目标目录
if [ ! -d "$TARGET_DIR" ]; then
    info "创建目标目录: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# 克隆仓库到临时目录
info "正在从 GitHub 克隆 flavors 仓库..."
if ! git clone --depth 1 "$FLAVORS_REPO" "$REPO_DIR" 2>/dev/null; then
    error "仓库克隆失败，请检查网络连接"
    exit 1
fi
success "仓库克隆成功"

# 查找所有 .yazi 目录
info "正在查找所有 flavor 主题..."
FLAVOR_DIRS=$(find "$REPO_DIR" -maxdepth 1 -type d -name "*.yazi" | sort)

if [ -z "$FLAVOR_DIRS" ]; then
    warning "未找到任何 flavor 主题"
    exit 0
fi

# 统计信息
TOTAL=0
UPDATED=0
NEW=0

# 复制每个 flavor（从 yazi-rs/flavors 仓库）
while IFS= read -r flavor_dir; do
    if [ -z "$flavor_dir" ]; then
        continue
    fi
    
    TOTAL=$((TOTAL + 1))
    flavor_name=$(basename "$flavor_dir")
    target_flavor_dir="$TARGET_DIR/$flavor_name"
    
    # 检查是否已存在
    if [ -d "$target_flavor_dir" ]; then
        info "更新主题: $flavor_name"
        rm -rf "$target_flavor_dir"
        UPDATED=$((UPDATED + 1))
    else
        info "安装新主题: $flavor_name"
        NEW=$((NEW + 1))
    fi
    
    # 复制 flavor 目录
    cp -r "$flavor_dir" "$target_flavor_dir"
    success "  $flavor_name"
done <<< "$FLAVOR_DIRS"

# 安装额外的主题仓库
if [ ${#EXTRA_FLAVORS[@]} -gt 0 ]; then
    echo ""
    info "正在安装额外的主题仓库..."
    
    for flavor_entry in "${EXTRA_FLAVORS[@]}"; do
        # 使用 | 作为分隔符，避免与 URL 中的 : 冲突
        repo_url="${flavor_entry%%|*}"
        target_name="${flavor_entry##*|}"
        
        if [ -z "$repo_url" ] || [ -z "$target_name" ] || [ "$repo_url" = "$flavor_entry" ]; then
            warning "跳过无效的主题条目: $flavor_entry"
            continue
        fi
        
        TOTAL=$((TOTAL + 1))
        temp_repo_dir="$TEMP_DIR/$(basename "$repo_url" .git)"
        target_flavor_dir="$TARGET_DIR/$target_name"
        
        # 克隆仓库
        info "正在克隆: $target_name"
        if ! git clone --depth 1 "$repo_url" "$temp_repo_dir" 2>/dev/null; then
            error "  克隆失败: $target_name"
            TOTAL=$((TOTAL - 1))
            continue
        fi
        
        # 检查是否已存在
        if [ -d "$target_flavor_dir" ]; then
            info "更新主题: $target_name"
            rm -rf "$target_flavor_dir"
            UPDATED=$((UPDATED + 1))
        else
            info "安装新主题: $target_name"
            NEW=$((NEW + 1))
        fi
        
        # 复制整个仓库内容到目标目录（这些仓库本身就是 flavor 目录）
        cp -r "$temp_repo_dir" "$target_flavor_dir"
        success "  $target_name"
        
        # 清理临时仓库
        rm -rf "$temp_repo_dir"
    done
fi

# 显示统计信息
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Yazi Flavors 更新完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
success "总计: $TOTAL 个主题"
if [ $NEW -gt 0 ]; then
    success "新增: $NEW 个主题"
fi
if [ $UPDATED -gt 0 ]; then
    success "更新: $UPDATED 个主题"
fi
echo ""
info "主题已安装到: $TARGET_DIR"
info "使用 'y' 命令启动 yazi 查看效果"
echo ""

