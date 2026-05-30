# このファイルはマシン固有の設定用です
# 必要に応じて編集してください

# ============================================
# 清理残留的 ZELLIJ 环境变量
# 当 zellij 客户端崩溃、异常断开，或通过中间工具（如 Kimi Code）
# 启动 shell 时，环境变量可能残留但进程树中已无 zellij。
# ============================================
cleanup_zellij_env() {
    # 如果不在 zellij 进程树中，清理残留的环境变量
    local has_zellij=false
    local pid=$$
    while [[ -n "$pid" && "$pid" -ne 1 ]]; do
        if ps -p "$pid" -o comm= 2>/dev/null | grep -q zellij; then
            has_zellij=true
            break
        fi
        pid=$(ps -p "$pid" -o ppid= 2>/dev/null | tr -d ' ')
    done

    if [[ "$has_zellij" == false ]]; then
        unset ZELLIJ ZELLIJ_SESSION_NAME ZELLIJ_PANE_ID ZELLIJ_SOCKET_DIR 2>/dev/null
    fi
}

# 交互式 shell 启动时执行清理
if [[ -o interactive ]]; then
    cleanup_zellij_env
fi

# ============================================
# zellij 启动分流：SSH 用干净布局，本地用 zjstatus
# ============================================
zj() {
    local layout="compact-zjstatus"
    local session=""
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        layout="clean"
        session="ssh"
    fi
    if [[ -n "$session" ]]; then
        command zellij --layout "$layout" --session "$session" "$@"
    else
        command zellij --layout "$layout" "$@"
    fi
}

# ============================================
# 字体安装功能
# ============================================

# 移除可能存在的别名（避免与函数定义冲突）
unalias install:font 2>/dev/null || true

# 字体安装函数（可通过命令调用）
# 不在 shell 启动期间自动提示，避免和 p10k instant prompt 冲突。
install:font() {
    bash "$HOME/dotfiles/scripts/install/install_font.sh" "$@"
}

# nvm 使用 zshrc 中定义的惰性加载，不在这里同步 source。

# nvim 启动分流：
#   nvim          -> 保持原始启动行为
#   nvim .        -> 打开当前目录
#   nvim <path>   -> 路径存在时直接打开
#   nvim <query>  -> 路径不存在时，用 snacks files picker 预填 query
nvim() {
    # 非交互式输入（管道、重定向）直接转交原生 nvim
    if [[ ! -t 0 ]]; then
        command nvim "$@"
        return
    fi

    # 没有参数 → 正常启动
    if [[ $# -eq 0 ]]; then
        command nvim
        return
    fi

    # 多参数 → 直接交给原生 nvim（保持兼容）
    if [[ $# -ne 1 ]]; then
        command nvim "$@"
        return
    fi

    local target="$1"

    case "$target" in
        ".")
            command nvim .
            ;;
        -|-*|+*)
            command nvim "$target"
            ;;
        *)
            if [[ -e "$target" ]]; then
                command nvim "$target"
            else
                # 文件不存在，询问是创建还是搜索
                while true; do
                    read -r "choice?File '$target' does not exist. Create it (Enter/y) or search for it (n)? [Enter/y/n] "
                    case "$choice" in
                        ""|[Yy]*)
                            command touch "$target"
                            command nvim "$target"
                            break
                            ;;
                        [Nn]*)
                            NVIM_PICKER_FILE_QUERY="$target" command nvim \
                                --cmd 'let g:started_with_stdin = 1' \
                                +'lua vim.schedule(function() local q = vim.env.NVIM_PICKER_FILE_QUERY; if q and q ~= "" then require("snacks").picker.files({ search = q }) end end)'
                            break
                            ;;
                        *)
                            echo "Please answer y (create) or n (search)."
                            ;;
                    esac
                done
            fi
            ;;
    esac
}
