# ============================================
# superfile (spf) 自动安装和配置
# ============================================

# spf 函数：如果不存在则自动安装，退出后切换到最后的目录
spf() {
    local spf_bin="$HOME/.local/bin/spf"
    local lastdir_file=""
    
    # 确定 lastdir 文件路径（根据操作系统）
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        lastdir_file="$HOME/.local/state/superfile/lastdir"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        lastdir_file="$HOME/Library/Application Support/superfile/lastdir"
    else
        lastdir_file="$HOME/.local/state/superfile/lastdir"
    fi
    
    # 确保 lastdir 目录存在
    mkdir -p "$(dirname "$lastdir_file")"
    
    # 查找 spf 二进制文件
    local cmd_path=""
    if [[ -x "$spf_bin" ]]; then
        cmd_path="$spf_bin"
    elif cmd_path=$(whence -p spf 2>/dev/null); then
        if [[ ! -x "$cmd_path" ]]; then
            cmd_path=""
        fi
    fi

    # 如果不存在，提示并安装
    if [[ -z "$cmd_path" ]]; then
    echo "superfile (spf) 未安装，正在自动安装..."
    
    # 创建本地 bin 目录（如果不存在）
    mkdir -p ~/.local/bin
    
    # 确保 PATH 包含 ~/.local/bin（只在不存在时添加）
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    # 下载并安装 superfile
        if curl -fsSL https://superfile.dev/install.sh | bash; then
        echo "superfile (spf) 安装成功！"
        if [[ -x "$spf_bin" ]]; then
                cmd_path="$spf_bin"
        else
            echo "安装完成，但无法找到 spf 命令" >&2
            return 1
        fi
    else
        echo "superfile 安装失败，请手动安装：" >&2
            echo "  bash -c \"\$(curl -sLo- https://superfile.dev/install.sh)\"" >&2
        return 1
        fi
    fi
    
    # 如果指定了目录参数，先切换到该目录
    if [[ $# -gt 0 ]] && [[ -d "$1" ]]; then
        cd "$1"
    fi
    
    # 执行 superfile
    "$cmd_path" "$@"
    
    # 退出后读取 lastdir 文件并切换目录
    if [[ -f "$lastdir_file" ]]; then
        local lastdir
        lastdir=$(cat "$lastdir_file" 2>/dev/null)
        if [[ -n "$lastdir" ]] && [[ -d "$lastdir" ]]; then
            cd "$lastdir"
        fi
    fi
}

# 添加别名（向后兼容和拼写容错）
alias superfile=spf
alias superfiles=spf

