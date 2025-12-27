#!/bin/bash

# 检查是否为 Silverblue/Kinoite
is_silverblue_kinoite() {
    grep -q "silverblue\|kinoite" /etc/os-release
}

# 安装 winetricks
install_winetricks() {
    echo "winetricks 未安装，正在安装..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y winetricks
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y winetricks
    elif command -v pacman &> /dev/null; then
        sudo pacman -S --noconfirm winetricks
    else
        echo "不支持的系统类型，请手动安装 winetricks"
        exit 1
    fi
}

# 主函数
main() {
    if is_silverblue_kinoite; then
        toolbox run --container wine winetricks "$@"
        exit 0
    fi

    if ! command -v winetricks &> /dev/null; then
        install_winetricks
    fi

    if [ $# -eq 0 ]; then
        echo "请提供要运行的 winetricks 命令作为参数"
        exit 1
    fi

    # 确保 winetricks 已安装，然后运行命令
    if command -v winetricks &> /dev/null; then
        winetricks "$@"
    else
        echo "winetricks 安装失败，无法运行命令"
        exit 1
    fi
}

main "$@"
