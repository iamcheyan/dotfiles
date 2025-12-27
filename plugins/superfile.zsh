# ============================================
# superfile (spf) 自动安装和配置
# ============================================

# spf 函数：如果不存在则自动安装
spf() {
    local spf_bin="$HOME/.local/bin/spf"
    
    # 首先检查 ~/.local/bin/spf 是否存在（直接检查文件，避免递归）
    if [[ -x "$spf_bin" ]]; then
        "$spf_bin" "$@"
        return
    fi
    
    # 检查系统 PATH 中是否有 spf 二进制文件（使用 whence -p 只查找可执行文件，不查找函数）
    local cmd_path
    if cmd_path=$(whence -p spf 2>/dev/null); then
        if [[ -x "$cmd_path" ]]; then
            "$cmd_path" "$@"
            return
        fi
    fi

    # 如果不存在，提示并安装
    echo "superfile (spf) 未安装，正在自动安装..."
    
    # 创建本地 bin 目录（如果不存在）
    mkdir -p ~/.local/bin
    
    # 确保 PATH 包含 ~/.local/bin（只在不存在时添加）
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # 下载并安装 superfile
    if curl -fsSL https://superfile.netlify.app/install.sh | bash; then
        echo "superfile (spf) 安装成功！"
        # 直接使用完整路径执行，避免递归
        if [[ -x "$spf_bin" ]]; then
            "$spf_bin" "$@"
        else
            echo "安装完成，但无法找到 spf 命令" >&2
            return 1
        fi
    else
        echo "superfile 安装失败，请手动安装：" >&2
        echo "  bash -c \"\$(curl -sLo- https://superfile.netlify.app/install.sh)\"" >&2
        return 1
    fi
}

# 添加别名（向后兼容和拼写容错）
alias superfile=spf
alias superfiles=spf

