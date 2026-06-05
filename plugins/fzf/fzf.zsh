
# ============================================
# 工具 PATH 设置（zinit 管理的工具会自动添加到 PATH）
# ============================================
# 注意：fd, rg, bat, fzf 等工具已通过 zinit 在 tools.zsh 中管理
# 以下代码仅作为后备方案，兼容系统安装的工具

# fd 命令设置（后备：如果 zinit 未安装，尝试使用系统安装的 fdfind）
if ! command -v fd >/dev/null 2>&1; then
    if command -v fdfind >/dev/null 2>&1; then
        mkdir -p ~/.local/bin 2>/dev/null
        [[ ! -e ~/.local/bin/fd ]] && ln -sf "$(command -v fdfind)" ~/.local/bin/fd
        # 确保 PATH 包含 ~/.local/bin（只在不存在时添加）
        if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
            export PATH="$HOME/.local/bin:$PATH"
        fi
    fi
fi

# fzf PATH 设置（后备：如果 zinit 未安装，使用系统安装的 fzf）
if ! command -v fzf >/dev/null 2>&1 && [[ -d "$HOME/.fzf/bin" ]]; then
    if [[ ":$PATH:" != *":$HOME/.fzf/bin:"* ]]; then
    export PATH="$HOME/.fzf/bin:$PATH"
    fi
fi

# # 在 Zellij 里优先用浮动窗运行 fzf，外部环境保持原始行为。
# if [[ -x ~/dotfiles/plugins/zellij/fzf-zellij ]]; then
#     fzf-zellij() {
#         ~/dotfiles/plugins/zellij/fzf-zellij "$@"
#     }

#     fzf() {
#         case "$1" in
#             --bash|--zsh|--fish|--version|-h|--help|--man)
#                 command fzf "$@"
#                 ;;
#             *)
#                 if [[ -n "${ZELLIJ:-}" ]]; then
#                     fzf-zellij "$@"
#                 else
#                     command fzf "$@"
#                 fi
#                 ;;
#         esac
#     }
# fi

# ============================================
# fzf 基础设置
# ============================================

# 使用 fd 作为 fzf 的默认搜索命令（更快速）
# 如果 fd 不可用，提示安装 fd，然后回退到 find
if command -v fd >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
elif command -v fdfind >/dev/null 2>&1; then
    export FZF_DEFAULT_COMMAND='fdfind --hidden --follow --exclude .git'
else
    echo "提示: 建议安装 fd（https://github.com/sharkdp/fd），以加快 fzf 文件搜索速度。" >&2
    export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*" 2>/dev/null'
fi
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
    export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap --wrap-sign='' \
      --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
      --preview-window=right:40%"
else
    export FZF_DEFAULT_OPTS="--height 80% --layout=reverse --border --wrap --wrap-sign='' \
      --preview '([[ -d {} ]] && ls -F --color=always {})'"
fi

# ============================================
# 文件搜索和编辑函数
# ============================================

_fzf_copy_path() {
    local target="$1"
    [[ -z "$target" ]] && return 1

    if command -v wl-copy >/dev/null 2>&1; then
        printf '%s' "$target" | wl-copy
    elif command -v pbcopy >/dev/null 2>&1; then
        printf '%s' "$target" | pbcopy
    elif command -v xclip >/dev/null 2>&1; then
        printf '%s' "$target" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        printf '%s' "$target" | xsel --clipboard --input
    else
        return 1
    fi
}

_fzf_copy_path_cmd() {
    cat <<'EOF'
target="$1"
if [[ -z "$target" ]]; then
  exit 1
elif command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$target" | wl-copy
elif command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$target" | pbcopy
elif command -v xclip >/dev/null 2>&1; then
  printf '%s' "$target" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$target" | xsel --clipboard --input
else
  exit 1
fi
EOF
}

# ff: 使用 fzf 模糊搜索文件或目录，文件用 nvim 打开，目录用 ranger 打开
# - 支持以参数传递模糊搜索内容（支持空格、标点、多重空格等）
# - 结合 fd/fzf, 支持管道和交互调用
# - 包含隐藏文件，并忽略 .gitignore / .ignore / 全局 ignore 规则
# - 在结果列表按 Ctrl-Y 可在“打开文件”和“进入目录”模式间切换
# - 在结果列表按 Alt-C 可复制当前选中路径且不退出
ff() {
    # 交互式调用
    if [[ -t 0 ]]; then
        local out query key target header copy_cmd base
        local white gray reset
        local -a search_cmd
        copy_cmd="$(_fzf_copy_path_cmd)"
        white=$'\033[37m'
        gray=$'\033[90m'
        reset=$'\033[0m'
        base="$HOME"

        if [[ $# -gt 0 ]]; then
            if [[ "$1" == "." ]]; then
                base="$PWD"
                shift
            elif [[ "$1" == "~" ]]; then
                base="$HOME"
                shift
            elif [[ "$1" == ~/* ]]; then
                base="${HOME}/${1#~/}"
                shift
            elif [[ -d "$1" ]]; then
                base="$1"
                shift
            fi
        fi

        if [[ ! -d "$base" ]]; then
            echo "ff: not a directory: $base" >&2
            return 1
        fi
        
        # 确定搜索命令：优先使用 fd，其次 fdfind，最后使用 find
        # 使用 which 或 command -v 检查，并验证命令是否真的可执行
        if command -v fd >/dev/null 2>&1 && fd --version >/dev/null 2>&1; then
            search_cmd=(fd . "$base" --hidden --follow --exclude .git)
        elif command -v fdfind >/dev/null 2>&1 && fdfind --version >/dev/null 2>&1; then
            search_cmd=(fdfind . "$base" --hidden --follow --exclude .git)
        else
            # 回退到 find 命令
            search_cmd=(find "$base" \( -type f -o -type d \))
        fi
        
        if [[ $# -gt 0 ]]; then
            query="$*"
        else
            query=""
        fi

        while true; do
            header='Enter: open  Alt-Enter: ranger  Alt-J/K: move  Alt-U/D: half-page  Alt-G: top  Alt-C: copy path'

            out=$("${search_cmd[@]}" 2>/dev/null | while IFS= read -r path; do
                [[ -z "$path" ]] && continue
                if [[ -d "$path" ]]; then
                    printf 'dir\t%s%s%s\t%s\n' "$gray" "$path" "$reset" "$path"
                else
                    printf 'file\t%s%s%s\t%s\n' "$white" "$path" "$reset" "$path"
                fi
            done | command fzf --ansi --print-query --expect=alt-enter \
                --bind 'tab:down' \
                --bind 'btab:up' \
                --bind 'alt-j:down' \
                --bind 'alt-k:up' \
                --bind 'alt-d:half-page-down' \
                --bind 'alt-u:half-page-up' \
                --bind 'alt-g:first' \
                --bind "alt-c:execute-silent(zsh -c '$copy_cmd' -- {3})+change-header(Copied)+bg-transform-header(sleep 1; printf '%s' \"$header\")" \
                --header "$header" \
                --query "$query" \
                --delimiter=$'\t' \
                --with-nth=2 \
                --preview '([[ -d {3} ]] && ls -F --color=always {3}) || ([[ -f {3} ]] && bat --style=numbers --color=always --line-range :300 {3})' \
                --preview-window=right:40%) || return
            query=$(printf '%s\n' "$out" | sed -n '1p')
            key=$(printf '%s\n' "$out" | sed -n '2p')
            target=$(printf '%s\n' "$out" | sed -n '3p')

            if [[ -z "$target" ]]; then
                target="$key"
                key=""
            fi

            if [[ -n "$target" ]]; then
                target="${target##*$'\t'}"
                if [[ "$key" == "alt-enter" ]]; then
                    if [[ -d "$target" ]]; then
                        r "$target"
                    else
                        r --selectfile "$target"
                    fi
                elif [[ -f "$target" ]]; then
                    nvim "$target"
                elif [[ -d "$target" ]]; then
                    r "$target"
                fi
            fi
            return
        done
    else
        command fzf "$@"
    fi
}

# ffd: 使用 fd 先按文件名搜索，再交给 fzf 选择
# - ffd: 在 home 目录下进入 fzf 后搜索
# - ffd bundle.mjs: 在 home 目录下用 fd 搜索 bundle.mjs
# - ffd ~ bundle.mjs: 在 home 目录下用 fd 搜索 bundle.mjs
# - ffd . bundle.mjs: 在当前目录下用 fd 搜索 bundle.mjs
# - ffd /some/path bundle.mjs: 在指定目录下用 fd 搜索 bundle.mjs
# - 选中文件用 nvim 打开，选中目录用 ranger 打开
ffd() {
    if [[ -t 0 ]]; then
        local out query key target header copy_cmd base pattern
        local -a search_cmd
        copy_cmd="$(_fzf_copy_path_cmd)"
        base="$HOME"
        pattern=""

        if [[ $# -gt 0 ]]; then
            if [[ "$1" == "." ]]; then
                base="."
                shift
            elif [[ "$1" == "~" ]]; then
                base="$HOME"
                shift
            elif [[ "$1" == ~/* ]]; then
                base="${HOME}/${1#~/}"
                shift
            elif [[ -d "$1" ]]; then
                base="$1"
                shift
            fi
        fi

        if [[ ! -d "$base" ]]; then
            echo "ffd: not a directory: $base" >&2
            return 1
        fi

        if [[ $# -gt 0 ]]; then
            pattern="$*"
            query="$pattern"
        else
            query=""
        fi

        if command -v fd >/dev/null 2>&1 && fd --version >/dev/null 2>&1; then
            if [[ -n "$pattern" ]]; then
                search_cmd=(fd "$pattern" "$base")
            else
                search_cmd=(fd . "$base")
            fi
        elif command -v fdfind >/dev/null 2>&1 && fdfind --version >/dev/null 2>&1; then
            if [[ -n "$pattern" ]]; then
                search_cmd=(fdfind "$pattern" "$base")
            else
                search_cmd=(fdfind . "$base")
            fi
        else
            echo "ffd: fd is required" >&2
            return 1
        fi

        while true; do
            header='Alt: Enter=ranger, J/K=move, U/D=half-page, G=top, C=copy path'

            out=$("${search_cmd[@]}" 2>/dev/null | command fzf --print-query --expect=alt-enter \
                --bind 'tab:down' \
                --bind 'btab:up' \
                --bind 'alt-j:down' \
                --bind 'alt-k:up' \
                --bind 'alt-d:half-page-down' \
                --bind 'alt-u:half-page-up' \
                --bind 'alt-g:first' \
                --bind "alt-c:execute-silent(zsh -c '$copy_cmd' -- {})+change-header(Copied)+bg-transform-header(sleep 1; printf '%s' \"$header\")" \
                --header "$header" \
                --query "$query" \
                --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
                --preview-window=right:40%) || return
            query=$(printf '%s\n' "$out" | sed -n '1p')
            key=$(printf '%s\n' "$out" | sed -n '2p')
            target=$(printf '%s\n' "$out" | sed -n '3p')

            if [[ -z "$target" ]]; then
                target="$key"
                key=""
            fi

            if [[ -n "$target" ]]; then
                if [[ "$key" == "alt-enter" ]]; then
                    if [[ -d "$target" ]]; then
                        r "$target"
                    else
                        r --selectfile "$target"
                    fi
                elif [[ -f "$target" ]]; then
                    nvim "$target"
                elif [[ -d "$target" ]]; then
                    r "$target"
                fi
            fi
            return
        done
    else
        command fzf "$@"
    fi
}

# ============================================
# rf: 在当前目录中精确搜索内容，并实时预览，选中后用 nvim 打开并跳转到相应行
# - 支持以单一完整参数（包含空格、中文标点等）作为精确搜索关键字
# - 仅匹配含*整个*参数的行（整体匹配）
# - 包含隐藏文件，并忽略 .gitignore / .ignore / 全局 ignore 规则
# - 在结果列表按 Alt-Enter 可用 ranger 打开所在目录
# - 在结果列表按 Alt-C 可复制当前选中路径且不退出
rf() {
    local initial_query out key query sel file line vim_search header copy_cmd
    copy_cmd="$(_fzf_copy_path_cmd)"
    if [[ $# -gt 0 ]]; then
        # 将所有参数拼接为一个完整字符串，允许混合各种空格和标点
        initial_query="$*"
    else
        initial_query=""
    fi

    query="$initial_query"

    while true; do
        header='Enter: open  Alt-Enter: ranger  Alt-J/K: move  Alt-U/D: half-page  Alt-G: top  Alt-C: copy path'

        out=$(rg --hidden --no-ignore --glob '!.git' --glob '!.git/**' --line-number --no-heading --color=always \
            --colors 'path:fg:15' \
            --colors 'line:fg:8' \
            --colors 'column:fg:8' \
            --colors 'match:fg:15' \
            --colors 'match:bg:18' . | \
            command fzf --ansi --print-query --expect=alt-enter --bind "alt-c:execute-silent(zsh -c '$copy_cmd' -- {1})+change-header(Copied)+bg-transform-header(sleep 1; printf '%s' \"$header\")" --query "$query" \
                --bind 'tab:down' --bind 'btab:up' \
                --bind 'alt-j:down' --bind 'alt-k:up' \
                --bind 'alt-d:half-page-down' --bind 'alt-u:half-page-up' \
                --bind 'alt-g:first' \
                --delimiter ':' \
                --prompt "RG (cwd: $(pwd))> " \
                --header "$header" \
                --preview 'q={q}; f={1}; if [ -z "$f" ]; then exit 0; fi; if [ -n "$q" ]; then rg --hidden --no-ignore --glob "!.git" --glob "!.git/**" --smart-case --pretty --color=always --line-number --context=6 --colors "line:fg:8" --colors "path:none" --colors "match:fg:white" --colors "match:bg:94" -- "$q" "$f" | awk '\''{ hl="\033[38;5;15m\033[48;5;94m"; line=$0; plain=$0; gsub(/\033\[[0-9;]*m/, "", plain); if (plain ~ /^[0-9]+:/) { gsub(/\033\[0m/, "\033[0m" hl, line); sub(/^(\033\[[0-9;]*m)+/, "", line); print hl line "\033[0m"; } else print line }'\''; else bat --style=numbers --color=always "$f" --highlight-line {2}; fi' \
                --preview-window 'right:40%') || return

        query=$(printf '%s\n' "$out" | sed -n '1p')
        key=$(printf '%s\n' "$out" | sed -n '2p')
        sel=$(printf '%s\n' "$out" | sed -n '3p')
        if [[ -z "$sel" ]]; then
            sel="$key"
            key=""
        fi
        [[ -z "$sel" ]] && return

        file="${sel%%:*}"
        line="${sel#*:}"
        line="${line%%:*}"

        if [[ -n "$file" && -n "$line" ]]; then
            if [[ "$key" == "alt-enter" ]]; then
                r --selectfile "$file"
            elif [[ -n "$query" ]]; then
                vim_search="${query//\\/\\\\}"
                vim_search="${vim_search//\"/\\\"}"
                nvim +"$line" \
                    +"let @/=\"\\\\V${vim_search}\" | set hlsearch" \
                    +"redraw | sleep 120m | set nohlsearch | redraw | sleep 80m | set hlsearch | redraw | sleep 80m | set nohlsearch | redraw | sleep 80m | set hlsearch" \
                    "$file"
            else
                nvim +"$line" "$file"
            fi
        fi
        return
    done
}
