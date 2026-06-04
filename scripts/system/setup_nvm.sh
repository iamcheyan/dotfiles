#!/usr/bin/env zsh
#
# NVM 懒加载脚本
# 用法: zinit snippet
#

export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
NVM_INSTALL_URL="https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh"

# 颜色定义
autoload -U colors && colors

check_nvm_installed() {
    [[ -s "$NVM_DIR/nvm.sh" ]]
}

load_nvm() {
    export NVM_DIR
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
}

get_latest_lts_version() {
    # 使用 nvm ls-remote 获取最新 LTS 版本
    nvm ls-remote --lts 2>/dev/null | grep -o 'v[0-9]\+\.[0-9]\+\.[0-9]\+' | tail -1
}

# 首次安装 nvm
install_nvm() {
    echo "[NVM] 未检测到 NVM，开始安装..."
    
    # 清理旧的 nvm 目录
    [[ -d "$NVM_DIR" ]] && rm -rf "$NVM_DIR"
    
    # 安装 nvm
    curl -o- "$NVM_INSTALL_URL" | bash
    
    # 加载 nvm
    load_nvm
    echo "[NVM] 安装完成: $(nvm --version)"
}

# 安装并切换到最新 LTS Node
install_and_use_latest_node() {
    echo "[NVM] 获取最新 LTS Node 版本..."
    
    local latest_lts
    latest_lts=$(get_latest_lts_version)
    
    if [[ -z "$latest_lts" ]]; then
        echo "[NVM] 警告: 无法获取最新版本，将使用 nvm install --lts"
        nvm install --lts
        nvm alias default 'lts/*'
        return
    fi
    
    echo "[NVM] 最新 LTS 版本: $latest_lts"
    
    # 安装（如果不存在）
    if ! nvm ls "$latest_lts" &>/dev/null; then
        echo "[NVM] 安装 $latest_lts..."
        nvm install "$latest_lts"
    fi
    
    # 切换并设为默认
    nvm use "$latest_lts"
    nvm alias default "$latest_lts"
    
    echo "[NVM] 当前 Node: $(node --version)"
}

# 切换到已安装的最新版本
switch_to_latest_installed() {
    local latest_local
    latest_local=$(ls -1 "$NVM_DIR"/versions/node 2>/dev/null | grep -E '^v[0-9]+\.[0-9]+\.[0-9]+$' | sort -V | tail -1)
    
    if [[ -n "$latest_local" ]]; then
        nvm use "$latest_local" 2>/dev/null || nvm use 'lts/*' 2>/dev/null || true
    else
        # 没有安装任何版本，安装最新的
        install_and_use_latest_node
    fi
}

__nvm_lazy_load() {
    if [[ "${__NVM_LAZY_LOADED:-0}" == "1" ]]; then
        return 0
    fi

    if check_nvm_installed; then
        load_nvm
        switch_to_latest_installed
    else
        install_nvm
        install_and_use_latest_node
    fi

    export __NVM_LAZY_LOADED=1
}

__nvm_lazy_dispatch() {
    local command_name="$1"
    shift

    __nvm_lazy_load || return $?
    unfunction node npm npx corepack 2>/dev/null || true
    hash -r 2>/dev/null || true

    command "$command_name" "$@"
}

nvm() {
    unfunction nvm 2>/dev/null || true
    __nvm_lazy_load || return $?
    nvm "$@"
}

node() {
    __nvm_lazy_dispatch node "$@"
}

npm() {
    __nvm_lazy_dispatch npm "$@"
}

npx() {
    __nvm_lazy_dispatch npx "$@"
}

corepack() {
    __nvm_lazy_dispatch corepack "$@"
}
