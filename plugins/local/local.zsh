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
# zellij 启动分流：SSH 用 zjn，本地用默认布局
# ============================================
zj() {
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        zjn --session ssh "$@"
    else
        command zellij --layout "default" "$@"
    fi
}

# 原生 zellij：不加载任何自定义配置，只加 session 模式按键（SSH 也用这个）
zjn() {
    local tmpdir=$(mktemp -d)
    cat > "$tmpdir/config.kdl" <<'EOF'
themes {
    ssh {
        fg "#ffd7af"
        bg "#1c1008"
        black "#3e2a14"
        red "#ff4444"
        green "#ffa500"
        yellow "#ffcc00"
        blue "#ff8c42"
        magenta "#e06040"
        cyan "#ffb347"
        white "#ffe4c4"
        orange "#ff6600"

        frame_unselected {
            base "#3e1a00"
            emphasis_0 "#5a2800"
            emphasis_1 "#5a2800"
            emphasis_2 "#5a2800"
            emphasis_3 "#5a2800"
        }
        frame_selected {
            base "#ff4400"
            emphasis_0 "#ff6600"
            emphasis_1 "#ff6600"
            emphasis_2 "#ff6600"
            emphasis_3 "#ff6600"
        }
        frame_highlight {
            base "#ffcc00"
            emphasis_0 "#ffcc00"
            emphasis_1 "#ffcc00"
            emphasis_2 "#ffcc00"
            emphasis_3 "#ffcc00"
        }

        ribbon_selected {
            base "#000000"
            background "#ff4400"
            emphasis_0 "#000000"
            emphasis_1 "#000000"
            emphasis_2 "#000000"
            emphasis_3 "#000000"
        }
        ribbon_unselected {
            base "#000000"
            background "#ff8c00"
            emphasis_0 "#000000"
            emphasis_1 "#000000"
            emphasis_2 "#000000"
            emphasis_3 "#000000"
        }

        text_unselected {
            base "#ff4400"
            background "#000000"
            emphasis_0 "#ff4400"
            emphasis_1 "#ff4400"
            emphasis_2 "#ff4400"
            emphasis_3 "#ff4400"
        }
    }
}

theme "ssh"
pane_frames true
mouse_mode true
simplified_ui false
show_startup_tips false

keybindings {
    session {
        bind "Ctrl o" { SwitchToMode "Normal"; }
        bind "d" { Detach; }
        bind "x" { Quit; }
    }
}
EOF
    command zellij --config-dir "$tmpdir" "$@"
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

# fnm 使用 zshrc 中定义的惰性加载，不在这里同步 source。

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
