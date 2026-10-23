
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
# 系统安装的 fzf 在 /usr/share/fzf/shell/，zinit snippet 也有备份
if [[ -e /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
elif [[ -e /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -e /usr/share/fzf/shell/completion.zsh ]]; then
    source /usr/share/fzf/shell/completion.zsh
elif [[ -e /usr/share/fzf/completion.zsh ]]; then
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
    printf '%s' 'target="$1"; if [[ -z "$target" ]]; then exit 1; elif command -v wl-copy >/dev/null 2>&1; then printf "%s" "$target" | wl-copy; elif command -v pbcopy >/dev/null 2>&1; then printf "%s" "$target" | pbcopy; elif command -v xclip >/dev/null 2>&1; then printf "%s" "$target" | xclip -selection clipboard; elif command -v xsel >/dev/null 2>&1; then printf "%s" "$target" | xsel --clipboard --input; else exit 1; fi'
}

_fzf_file_opts() {
    local copy_target="${1:-{}}"
    local copy_cmd="$2"
    local header="$3"

    printf '%s\n' \
        --print-query \
        --expect=alt-enter \
        --bind tab:down \
        --bind btab:up \
        --bind alt-j:down \
        --bind alt-k:up \
        --bind alt-J:down \
        --bind alt-K:up \
        --bind alt-d:half-page-down \
        --bind alt-u:half-page-up \
        --bind alt-g:first \
        --bind "alt-c:execute-silent(zsh -c '$copy_cmd' -- $copy_target)+change-header(Copied)" \
        --header "$header" \
        --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
        --preview-window=right:40%
}

# 从一行候选里解析真实路径。
# 支持纯路径，以及 grep -n / rg 的 "path:line[:col]:text" 形式。
_fzf_line_path() {
    local line="$1" rest
    [[ -z "$line" ]] && return 1
    rest="$line"
    while [[ "$rest" == *:* ]]; do
        [[ -e "$rest" ]] && { print -r -- "$rest"; return 0; }
        rest="${rest%:*}"
    done
    [[ -e "$rest" ]] && { print -r -- "$rest"; return 0; }
    return 1
}

# 从 "path:line..." 里取行号；没有行号时输出空。
_fzf_line_number() {
    local line="$1" file="$2" tail
    tail="${line#"$file"}"
    [[ "$tail" == :<->* ]] || return 0
    tail="${tail#:}"
    print -r -- "${tail%%:*}"
}

# 管道模式的预览命令：先剥掉 :line:col:text，再按文件/目录预览。
_fzf_pipe_preview_cmd() {
    printf '%s' 'p={}; while :; do if [ -d "$p" ]; then ls -F --color=always "$p" | head -n 300; break; fi; if [ -f "$p" ]; then if command -v bat >/dev/null 2>&1; then bat --style=numbers --color=always --line-range :300 "$p"; else sed -n "1,300p" "$p"; fi; break; fi; case "$p" in *:*) p=${p%:*};; *) printf "No preview for: %s\n" "$p"; break;; esac; done'
}

# 管道模式复用交互模式的按键与剪贴板设置，只替换预览与提示。
_fzf_pipe_opts() {
    local copy_cmd="$1"
    local header="$2"

    printf '%s\n' \
        --print-query \
        --expect=alt-enter \
        --bind tab:down \
        --bind btab:up \
        --bind alt-j:down \
        --bind alt-k:up \
        --bind alt-J:down \
        --bind alt-K:up \
        --bind alt-d:half-page-down \
        --bind alt-u:half-page-up \
        --bind alt-g:first \
        --bind "alt-c:execute-silent(zsh -c '$copy_cmd' -- {})+change-header(Copied)" \
        --header "$header" \
        --preview "$(_fzf_pipe_preview_cmd)" \
        --preview-window=right:40%
}

# f
# 无参数：弹出当前目录列表，回车用 nvim 打开文件、进入 ranger 浏览目录
# 管道：`find ... | f`、`grep -n ... | f` 等，回车打开文件（带行号）或 cd 到目录
# Alt+Enter 强制用 ranger 打开，Alt+C 复制路径
f() {
    local out query key target header copy_cmd target_path line_no piped
    local -a fzf_opts

    copy_cmd="$(_fzf_copy_path_cmd)"
    piped=0
    [[ -t 0 ]] || piped=1

    if [[ $piped -eq 1 ]]; then
        header='Enter: file=nvim, dir=cd | Alt-Enter=ranger | C=copy path'
        fzf_opts=("${(@f)$(_fzf_pipe_opts "$copy_cmd" "$header")}")
        out=$(command fzf "$@" "${fzf_opts[@]}") || return
    else
        header='Alt: Enter=ranger, j/k or Shift-j/k=move, U/D=half-page, G=top, C=copy path'
        fzf_opts=("${(@f)$(_fzf_file_opts '{}' "$copy_cmd" "$header")}")
        out=$(ls | command fzf "$@" "${fzf_opts[@]}") || return
    fi

    query=$(printf '%s\n' "$out" | sed -n '1p')
    key=$(printf '%s\n' "$out" | sed -n '2p')
    target=$(printf '%s\n' "$out" | sed -n '3p')

    if [[ -z "$target" ]]; then
        target="$key"
        key=""
    fi
    [[ -z "$target" ]] && return

    if [[ $piped -eq 1 ]]; then
        target_path="$(_fzf_line_path "$target")"
        if [[ -z "$target_path" ]]; then
            printf '%s\n' "$target"
            return
        fi
        line_no="$(_fzf_line_number "$target" "$target_path")"

        if [[ "$key" == "alt-enter" ]]; then
            if [[ -d "$target_path" ]]; then
                ra "$target_path"
            else
                ra --selectfile "$target_path"
            fi
        elif [[ -d "$target_path" ]]; then
            cd "$target_path"
        elif [[ -n "$line_no" ]]; then
            nvim "+$line_no" "$target_path"
        else
            nvim "$target_path"
        fi
        return
    fi

    if [[ "$key" == "alt-enter" ]]; then
        if [[ -d "$target" ]]; then
            ra "$target"
        else
            ra --selectfile "$target"
        fi
    elif [[ -f "$target" ]]; then
        nvim "$target"
    elif [[ -d "$target" ]]; then
        ra "$target"
    elif [[ -n "$target" ]]; then
        printf '%s\n' "$target"
    fi
}

# ffd: 使用 fd/plocate 先按文件名搜索，再交给 fzf 选择
# - ffd: 在 home 目录下进入 fzf 后搜索
# - ffd bundle.mjs: 在 home 目录下用 fd/plocate 搜索 bundle.mjs
# - ffd ~ bundle.mjs: 在 home 目录下用 fd/plocate 搜索 bundle.mjs
# - ffd . bundle.mjs: 在当前目录下用 fd/plocate 搜索 bundle.mjs
# - ffd /some/path bundle.mjs: 在指定目录下用 fd/plocate 搜索 bundle.mjs
# - 选中文件用 nvim 打开，选中目录用 ranger 打开
unalias ffd 2>/dev/null
ffd() {
    if [[ -t 0 ]]; then
        local out query key target header copy_cmd base base_abs pattern fd_cmd
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

        base_abs="$(cd "$base" && pwd -P)"

        if command -v fd >/dev/null 2>&1 && fd --version >/dev/null 2>&1; then
            fd_cmd="fd"
            if [[ -n "$pattern" ]]; then
                search_cmd=(fd "$pattern" "$base")
            else
                search_cmd=(fd . "$base")
            fi
        elif command -v fdfind >/dev/null 2>&1 && fdfind --version >/dev/null 2>&1; then
            fd_cmd="fdfind"
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
            header='Alt: Enter=ranger, j/k or Shift-j/k=move, U/D=half-page, G=top, C=copy path'

            out=$(
                {
                    if [[ -n "$pattern" ]] && command -v plocate >/dev/null 2>&1; then
                        "$fd_cmd" --absolute-path "$pattern" "$base" 2>/dev/null
                        plocate -- "$pattern" 2>/dev/null | while IFS= read -r path; do
                            [[ -e "$path" ]] || continue
                            if [[ "$path" == "$base_abs" || "$path" == "$base_abs"/* ]]; then
                                printf '%s\n' "$path"
                            fi
                        done
                    else
                        "${search_cmd[@]}" 2>/dev/null
                    fi
                } | awk '!seen[$0]++' | command fzf \
                "${(@f)$(_fzf_file_opts '{}' "$copy_cmd" "$header")}" \
                --query "$query" \
            ) || return
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
                        ra "$target"
                    else
                        ra --selectfile "$target"
                    fi
                elif [[ -f "$target" ]]; then
                    nvim "$target"
                elif [[ -d "$target" ]]; then
                    ra "$target"
                fi
            fi
            return
        done
    else
        command fzf "$@"
    fi
}
alias ffd='noglob ffd'
