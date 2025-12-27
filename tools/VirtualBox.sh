#!/bin/bash

# 确保使用tetsuya用户运行VBoxManage命令
VBOXMANAGE="sudo -u tetsuya VBoxManage"

# 函数：显示帮助信息
show_help() {
    echo "用法: $0 [选项]"
    echo "选项:"
    echo "  start     启动Windows 11虚拟机"
    echo "  export    导出所有虚拟机"
    echo "  save      保存所有运行中虚拟机的状态"
    echo "  close     关闭Oracle VirtualBox管理器"
    echo "  help      显示此帮助信息"
}

# 函数：启动Windows 11虚拟机
start_windows11() {
    running_vms=$($VBOXMANAGE list runningvms)
    if ! echo "$running_vms" | grep -q "f324dccc-ceae-4a0a-aa8c-6d31d8cca2d7"; then
        echo "正在启动 Windows 11 虚拟机..."
        if $VBOXMANAGE startvm "windows 11" --type headless; then
            echo "Windows 11 虚拟机已成功启动"
        else
            echo "启动 Windows 11 虚拟机失败"
            # 检查是否是内存不足错误
            if echo "$($VBOXMANAGE --nologo showvminfo "windows 11" --machinereadable)" | grep -q "VERR_NO_LOW_MEMORY"; then
                echo "检测到内存不足错误，尝试清理系统内存..."
                # 清理系统缓存
                sudo sync && sudo echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null
                sleep 2
                # 重试启动虚拟机
                if $VBOXMANAGE startvm "windows 11" --type headless; then
                    echo "Windows 11 虚拟机已成功启动"
                else
                    echo "重试启动仍然失败，请检查系统资源"
                    exit 1
                fi
            else
                echo "启动失败，错误原因未知"
                exit 1
            fi
        fi
    else
        echo "Windows 11 虚拟机已经在运行中"
    fi
}

# 函数：导出所有虚拟机
export_vms() {
    echo "开始导出虚拟机..."
    export_path="/var/home/tetsuya/VirtualBox VMs"
    if [ ! -d "$export_path" ]; then
        mkdir -p "$export_path"
    fi
    
    vms=$($VBOXMANAGE list vms)
    running_vms=$($VBOXMANAGE list runningvms)
    
    echo "$vms" | while read -r vm; do
        vm_name=$(echo "$vm" | cut -d '"' -f 2)
        
        if echo "$running_vms" | grep -q "$vm_name"; then
            echo "正在关闭虚拟机 '$vm_name'..."
            if $VBOXMANAGE controlvm "$vm_name" poweroff; then
                echo "虚拟机 '$vm_name' 已成功关闭"
                sleep 5
            else
                echo "关闭虚拟机 '$vm_name' 时出错"
                continue
            fi
        fi

        echo "正在导出虚拟机 '$vm_name'..."
        export_file="$export_path/${vm_name}.ova"
        
        if $VBOXMANAGE export "$vm_name" -o "$export_file"; then
            echo "虚拟机 '$vm_name' 已成功导出到 $export_file"
        else
            echo "导出虚拟机 '$vm_name' 时出错"
        fi
    done
    echo "虚拟机导出完成"
}

# 函数：保存所有运行中虚拟机的状态
save_vms() {
    running_vms=$($VBOXMANAGE list runningvms)
    if [ -n "$running_vms" ]; then
        echo "$running_vms" | while read -r vm; do
            vm_name=$(echo "$vm" | cut -d '"' -f 2)
            echo "正在保存虚拟机 '$vm_name' 的状态..."
            if $VBOXMANAGE controlvm "$vm_name" savestate; then
                echo "虚拟机 '$vm_name' 的状态已成功保存。"
            else
                echo "保存虚拟机 '$vm_name' 的状态时出错。"
            fi
        done
        echo "所有正在运行的虚拟机状态已保存。"
    else
        echo "没有正在运行的虚拟机。"
    fi
}

# 函数：关闭Oracle VirtualBox管理器
close_virtualbox() {
    echo "正在关闭 Oracle VirtualBox 管理器..."
    if pgrep -f "/usr/lib64/virtualbox/VirtualBox" > /dev/null; then
        pkill -f "/usr/lib64/virtualbox/VirtualBox"
        echo "Oracle VirtualBox 管理器已成功关闭。"
    else
        echo "Oracle VirtualBox 管理器未运行。"
    fi
}

# 主程序
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

case "$1" in
    start)
        start_windows11
        ;;
    export)
        export_vms
        ;;
    save)
        save_vms
        ;;
    close)
        close_virtualbox
        ;;
    help)
        show_help
        ;;
    *)
        echo "无效的选项: $1"
        show_help
        exit 1
        ;;
esac