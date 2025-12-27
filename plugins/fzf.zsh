
# ============================================
# 工具 PATH 设置（zinit 管理的工具会自动添加到 PATH）
# ============================================
# 注意：fd, rg, bat, fzf 等工具已通过 zinit 在 tools.zsh 中管理
# 以下代码仅作为后备方案，兼容系统安装的工具

# fd 命令设置（后备：如果 zinit 未安装，尝试使用系统安装的 fdfind）
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    mkdir -p ~/.local/bin 2>/dev/null
    [[ ! -e ~/.local/bin/fd ]] && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
    # 确保 PATH 包含 ~/.local/bin（只在不存在时添加）
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        export PATH="$HOME/.local/bin:$PATH"
    fi
fi

# fzf PATH 设置（后备：如果 zinit 未安装，使用系统安装的 fzf）
if ! command -v fzf >/dev/null 2>&1 && [[ -d "$HOME/.fzf/bin" ]]; then
    if [[ ":$PATH:" != *":$HOME/.fzf/bin:"* ]]; then
        export PATH="$HOME/.fzf/bin:$PATH"
    fi
fi

# ============================================
# fzf 基础设置
# ============================================

# 使用 fd 作为 fzf 的默认搜索命令（更快速）
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# 启用 fzf 官方键绑定（Ctrl+T / Alt+C / Ctrl+R）
# 注意：这些会通过 zinit 从 GitHub 加载，但如果系统有安装也兼容
if [[ -e /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -e /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi

# ============================================
# fzf 预览设置（支持 bat 和目录预览）
# ============================================
if command -v bat >/dev/null 2>&1; then
    export FZF_DEFAULT_OPTS="--height 80% --layout=reverse --border \
      --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
      --preview-window=right:60%"
else
    export FZF_DEFAULT_OPTS="--height 80% --layout=reverse --border \
      --preview '([[ -d {} ]] && ls -F --color=always {})'"
fi

# ============================================
# 文件搜索和编辑函数
# ============================================

# ff: 使用 fzf 模糊搜索文件或目录，文件用 nvim 打开，目录用 yazi 打开
# - 支持以参数传递模糊搜索内容（支持空格、标点、多重空格等）
# - 结合 fd/fzf, 支持管道和交互调用
ff() {
    # 交互式调用
    if [[ -t 0 ]]; then
        local target
        if [[ $# -gt 0 ]]; then
            # 参数全部合并成字符串，直接作为查询内容传递（支持所有特殊字符）
            local query
            query="$*"
            target=$(fd -H . | command fzf --query="${query}")
        else
            target=$(fd -H . | command fzf)
        fi
        if [[ -n "$target" ]]; then
            if [[ -f "$target" ]]; then
                nvim "$target"
            elif [[ -d "$target" ]]; then
                y "$target"
            fi
        fi
    else
        command fzf "$@"
    fi
}

# ============================================
# rf: 在当前目录中精确搜索内容，并实时预览，选中后用 nvim 打开并跳转到相应行
# - 支持以单一完整参数（包含空格、中文标点等）作为精确搜索关键字
# - 仅匹配含*整个*参数的行（整体匹配）
rf() {
    local initial_query sel file line
    if [[ $# -gt 0 ]]; then
        # 将所有参数拼接为一个完整字符串，允许混合各种空格和标点
        initial_query="$*"
    else
        initial_query=""
    fi

    # 不对 initial_query 做任何拆分，直接整体传递给 rg
    if [[ -n "$initial_query" ]]; then
        sel=$(rg --line-number --no-heading --color=always -- "$initial_query" . | \
            command fzf --ansi \
                --delimiter ':' \
                --prompt "RG (cwd: $(pwd))> " \
                --preview 'bat --style=numbers --color=always {1} --highlight-line {2}' \
                --preview-window 'right:60%') || return
    else
        sel=$(rg --line-number --no-heading --color=always . | \
            command fzf --ansi \
                --delimiter ':' \
                --prompt "RG (cwd: $(pwd))> " \
                --preview 'bat --style=numbers --color=always {1} --highlight-line {2}' \
                --preview-window 'right:60%') || return
    fi

    file="${sel%%:*}"
    line="${sel#*:}"
    line="${line%%:*}"
    [[ -n "$file" && -n "$line" ]] && nvim +"$line" "$file"
}

# ============================================
# 其他工具函数
# ============================================

# 使用 zoxide 结合 fzf 交互式选择目录（不显示右侧预览）并切换
zd() {
    local dir
    dir=$(zoxide query -l | fzf --prompt="zoxide directory> " --no-preview)
    [[ -n "$dir" ]] && cd "$dir"
}

# 交互式选择并执行最近使用的命令（取代经典的 Ctrl+R 风格）
zc() {
    local cmd
    # 从历史中去重列出最近的命令，并用 fzf 交互选择（移除右侧的预览）
    cmd=$(
        fc -rl 1 | awk '{$1=""; print substr($0,2)}' | awk '!a[$0]++' |
        fzf --prompt="Recent Command> " --no-preview
    )
    [[ -n "$cmd" ]] && print -z -- "$cmd"
}

# 注: y() 函数已移动到 yazi.zsh 插件中

