#!/bin/bash

# 检查是否安装了 Flatpak 版本的 Wine
is_flatpak_wine_installed() {
    flatpak list | grep -q "org.winehq.Wine"
}

# 检查是否为 Silverblue/Kinoite
is_silverblue_kinoite() {
    grep -q "silverblue\|kinoite" /etc/os-release
}

# 安装 Wine
install_wine() {
    echo "Wine 未安装，正在安装..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y wine
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y wine
    else
        echo "不支持的系统类型，请手动安装 wine"
        exit 1
    fi
}
# 主函数
main() {
    if [ $# -eq 0 ]; then
        echo "请提供要运行的 Wine 程序作为参数"
        exit 1
    fi
    # 从参数中提取.exe文件名
    exe_name=$(basename "$1")
    
    # 检查并杀死已存在的 Photoshop.exe 进程
    if ps aux | grep "$exe_name" | grep -v "grep" | grep -v "$$" > /dev/null 2>&1; then
        echo "发现正在运行的 $exe_name 进程, 正在终止..."
        pkill -9 -f "$exe_name"
        echo "$exe_name 进程已终止"

        if is_flatpak_wine_installed; then
            flatpak run org.winehq.Wine "$@"
        elif is_silverblue_kinoite; then
            toolbox run --container wine wine "$@"
        elif command -v wine &> /dev/null; then
            wine "$@"
        else
            install_wine
            if command -v wine &> /dev/null; then
                wine "$@"
            else
                echo "Wine 安装失败，无法运行程序"
                exit 1
            fi
        fi
    else
        echo "没有发现正在运行的 $exe_name 进程"
    fi

    if is_flatpak_wine_installed; then
        flatpak run org.winehq.Wine "$@"
    elif is_silverblue_kinoite; then
        toolbox run --container wine wine "$@"
    elif command -v wine &> /dev/null; then
        wine "$@"
    else
        install_wine
        if command -v wine &> /dev/null; then
            wine "$@"
        else
            echo "Wine 安装失败，无法运行程序"
            exit 1
        fi
    fi
}

main "$@"