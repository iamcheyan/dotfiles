# zsh-completions: 额外的补全定义集
zinit ice blockf
zinit light zsh-users/zsh-completions

vendor_completions_dir="/usr/share/zsh/vendor-completions"
if [[ -L $vendor_completions_dir && ! -e $vendor_completions_dir ]]; then
  fpath=("${(@)fpath:#$vendor_completions_dir}")
fi

autoload -Uz compinit
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
{ compinit -C -u -d "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump" } 2>/dev/null

# fzf-tab: 用 fzf 替换 zsh 的默认补全选择菜单
# 必须在 compinit 之后加载，但在 zsh-autosuggestions 之前加载
zinit light Aloxaf/fzf-tab

# 禁用某些命令的排序（如 git checkout）
zstyle ':completion:*:git-checkout:*' sort false

# 设置描述格式以启用分组支持
zstyle ':completion:*:descriptions' format '[%d]'

# 设置列表颜色以启用文件名着色
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# 强制 zsh 不显示补全菜单，允许 fzf-tab 捕获明确的前缀
zstyle ':completion:*' menu no

# 预览目录内容（使用 eza，如果可用则使用 eza，否则使用 ls）
if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*' fzf-preview 'ls -1 --color=always $realpath'
fi

# 使用 < 和 > 切换分组
zstyle ':fzf-tab:*' switch-group '<' '>'

# 添加本地 bin 目录到 PATH（用于手动安装的工具，如 superfile）
# 只在 PATH 中不存在时添加，避免重复
if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
export PATH="$HOME/.local/bin:$PATH"
fi

# 添加 Neovim 到 PATH（如果已安装）
# 按照新的安装方法，Neovim 安装在 ~/.local/nvim/bin
if [[ -d "$HOME/.local/nvim/bin" ]] && [[ ":$PATH:" != *":$HOME/.local/nvim/bin:"* ]]; then
    export PATH="$HOME/.local/nvim/bin:$PATH"
fi

# 添加 Rust cargo bin 目录到 PATH（如果已安装 Rust）
# 用于安装 tree-sitter-cli 等工具（解决 GLIBC 版本问题）
# 注意：放在 npm-global 之前，确保 cargo 编译的版本优先
if [[ -d "$HOME/.cargo/bin" ]] && [[ ":$PATH:" != *":$HOME/.cargo/bin:"* ]]; then
    export PATH="$HOME/.cargo/bin:$PATH"
fi

# 添加 npm 全局包路径到 PATH（如果已配置）
# 避免 npm 全局安装时的权限问题
# 注意：放在 cargo 之后，避免与 cargo 编译的工具冲突
if [[ -d "$HOME/.npm-global/bin" ]] && [[ ":$PATH:" != *":$HOME/.npm-global/bin:"* ]]; then
    export PATH="$HOME/.npm-global/bin:$PATH"
fi

# 添加 zinit 管理的工具目录到 PATH
# 注意：zinit 使用 sbin 时会将工具安装到 $ZPFX/bin
# 对于使用 as"command" 的工具，它们会被安装到插件目录
if [[ -n "$ZPFX" ]] && [[ -d "$ZPFX/bin" ]] && [[ ":$PATH:" != *":$ZPFX/bin:"* ]]; then
    export PATH="$ZPFX/bin:$PATH"
fi

# 添加 zinit 插件目录到 PATH（用于 as"command" 安装的工具）
# 优化：只查找 bin 子目录，避免递归遍历
typeset -A added_paths
add_to_path_if_new() {
    local path_to_add="${1%/}"
    [[ -z "${added_paths[$path_to_add]}" ]] && [[ ":$PATH:" != *":$path_to_add:"* ]] && {
        export PATH="$path_to_add:$PATH"
        added_paths[$path_to_add]=1
    }
}

for plugin_dir in ~/.zinit/plugins/*/bin(N); do
    add_to_path_if_new "$plugin_dir"
done
for plugin_dir in ~/.zinit/plugins/*/; do
    [[ -d "$plugin_dir/bin" ]] && add_to_path_if_new "$plugin_dir/bin"
done

# 清理 PATH 中的重复条目（可选函数）
clean_path() {
    local -A seen
    local new_path=""
    local path
    local count=0
    local old_ifs="$IFS"
    
    # 设置 IFS 为冒号，用于拆分 PATH
    IFS=':'
    
    # 使用更兼容的方法拆分 PATH
    local temp_path="$PATH"
    local -a paths
    
    # 手动拆分 PATH（处理边界情况）
    while [[ -n "$temp_path" ]]; do
        if [[ "$temp_path" == *:* ]]; then
            path="${temp_path%%:*}"
            temp_path="${temp_path#*:}"
        else
            path="$temp_path"
            temp_path=""
        fi
        # 规范化路径（去除尾随斜杠）
        path="${path%/}"
        # 跳过空路径
        [[ -n "$path" ]] && paths+=("$path")
    done
    
    # 遍历并去重
    for path in "${paths[@]}"; do
        # 规范化路径（去除尾随斜杠）
        path="${path%/}"
        # 跳过空路径
        [[ -z "$path" ]] && continue
        # 如果未见过，添加到新 PATH
        if [[ -z "${seen[$path]}" ]]; then
            seen[$path]=1
            ((count++))
            if [[ -z "$new_path" ]]; then
                new_path="$path"
            else
                new_path="$new_path:$path"
            fi
        fi
    done
    
    # 恢复 IFS
    IFS="$old_ifs"
    
    if [[ $count -eq 0 ]]; then
        echo "警告: 清理后 PATH 为空，保留原 PATH"
        export PATH="$original_path"
        return 1
    fi
    
    export PATH="$new_path"
    local original_count=${#paths[@]}
    echo "PATH 已清理，从 $original_count 个路径减少到 $count 个唯一路径"
}

# zinit 插件目录管理和 PATH 清理函数已定义
