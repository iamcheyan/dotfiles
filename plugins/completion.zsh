autoload -Uz compinit
compinit -C

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

# 添加 zinit 管理的工具目录到 PATH
# 注意：zinit 使用 sbin 时会将工具安装到 $ZPFX/bin
# 对于使用 as"command" 的工具，它们会被安装到插件目录
if [[ -n "$ZPFX" ]] && [[ -d "$ZPFX/bin" ]] && [[ ":$PATH:" != *":$ZPFX/bin:"* ]]; then
    export PATH="$ZPFX/bin:$PATH"
fi

# 添加 zinit 插件目录到 PATH（用于 as"command" 安装的工具）
# 工具文件可能在插件目录的子目录中，需要递归查找
# 使用 setopt nullglob 避免 glob 扩展错误
# 使用关联数组跟踪已添加的路径，避免重复（规范化路径，去除尾随斜杠）
setopt nullglob
typeset -A added_paths

# 辅助函数：规范化路径并检查是否已添加
add_to_path_if_new() {
    local path_to_add="$1"
    # 规范化路径（去除尾随斜杠，展开 ~）
    path_to_add="${path_to_add%/}"
    path_to_add="${path_to_add/#\~/$HOME}"
    
    # 转换为绝对路径（如果还不是绝对路径）
    if [[ "$path_to_add" != /* ]]; then
        # 尝试转换为绝对路径
        local abs_path
        if abs_path=$(cd "$path_to_add" 2>/dev/null && pwd); then
            path_to_add="$abs_path"
        else
            # 如果转换失败，跳过
            return 1
        fi
    fi
    
    # 检查是否已添加（检查带斜杠和不带斜杠的版本，以及规范化前后的版本）
    if [[ -z "${added_paths[$path_to_add]}" ]] && \
       [[ ":$PATH:" != *":$path_to_add:"* ]] && \
       [[ ":$PATH:" != *":$path_to_add/:"* ]]; then
        export PATH="$path_to_add:$PATH"
        added_paths[$path_to_add]=1
        # 同时标记带斜杠的版本，避免重复
        added_paths["$path_to_add/"]=1
        return 0
    fi
    return 1
}

for plugin_dir in ~/.zinit/plugins/*/; do
    if [[ -d "$plugin_dir" ]]; then
        # 添加插件根目录（工具可能直接在根目录）
        add_to_path_if_new "$plugin_dir"
        
        # 递归查找并添加包含可执行文件的子目录（最多查找 2 层深度）
        for subdir in "$plugin_dir"*/; do
            if [[ -d "$subdir" ]]; then
                # 检查子目录本身是否包含可执行文件
                if find "$subdir" -maxdepth 1 -type f -executable 2>/dev/null | grep -q .; then
                    add_to_path_if_new "$subdir"
                fi
                # 检查子目录的下一层（例如 bat-v10.3.0-aarch64-unknown-linux-gnu/bat）
                for subsubdir in "$subdir"*/; do
                    if [[ -d "$subsubdir" ]]; then
                        if find "$subsubdir" -maxdepth 1 -type f -executable 2>/dev/null | grep -q .; then
                            add_to_path_if_new "$subsubdir"
                        fi
                    fi
                done
            fi
        done
        # 特别处理 bin 子目录
        if [[ -d "$plugin_dir/bin" ]]; then
            add_to_path_if_new "$plugin_dir/bin"
        fi
    fi
done
unsetopt nullglob

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

# zoxide
eval "$(zoxide init zsh)"

