#!/bin/bash
# 定义dotfiles相关目录
export DOTFILES_DIR="$HOME/.dotfiles"
export DOTFILES_SCRIPT_DIR="$DOTFILES_DIR/Scripts"

echo "当前dotfiles所在的绝对路径：$(readlink -f "$0")"

# 询问用户是否要启用 chronyc
read -p "是否要启用 chronyc 时间同步服务? (y/n) " chronyc_answer
if [[ $chronyc_answer =~ ^[Yy]$ ]]; then
    echo "正在启用 chronyc 服务..."
    sudo bash $DOTFILES_SCRIPT_DIR/enable_chronyc.sh
else
    echo "跳过启用 chronyc 服务"
fi

echo "当前位于：$(pwd)"
echo "将当前目录 rsync 到 $HOME/.dotfiles/"
# echo "rsync -avz --delete $(dirname $(readlink -f "$0"))/  $HOME/.dotfiles/"

# 定义需要同步的目录列表
SYNC_DIRS=(
    ".dotfiles" 
    "Documents"
    "ピクチャ"
    "Applications"
    ".fonts"
    "Development"
    "VirtualMachines"
)

# 遍历目录列表进行同步
echo ""
echo "请复制执行以下命令进行数据同步:"
for dir in "${SYNC_DIRS[@]}"; do
    # echo "rsync -avz --delete $(dirname $(dirname $(readlink -f "$0")))/$dir/  $HOME/$dir"
    if [ "$dir" = "VirtualMachines" ]; then
        # VirtualMachines 同步到 /var/lib/libvirt/images/
        echo "sudo rsync -avz --delete \"$(dirname $(dirname $(readlink -f "$0")))/$dir/\" \"/var/lib/libvirt/images/\""
    else
        echo "rsync -avz --delete \"$(dirname $(dirname $(readlink -f "$0")))/$dir/\" \"$HOME/$dir/\""
    fi
done



# 检查是否为 Silverblue 系统
if command -v rpm-ostree &> /dev/null; then
    echo "检测到 Silverblue 系统"

    # 检查 WPS Office RPM 包是否存在
    WPS_RPM="$HOME/Applications/wps/安装包/wps-office-12.1.0.17885-1.x86_64.rpm"
    if [ -f "$WPS_RPM" ]; then
        echo "检测到 WPS Office 安装包，准备安装..."
        read -p "是否要安装 WPS Office? (y/n) " wps_answer
        if [[ $wps_answer =~ ^[Yy]$ ]]; then
            echo "开始安装 WPS Office..."
            sudo rpm-ostree install "$WPS_RPM"
            echo "WPS Office 安装完成。系统需要重启才能生效。"
        else
            echo "跳过 WPS Office 安装"
        fi
    fi

    # 打印将要执行的命令
    # 定义要安装的软件包列表
    PACKAGES=(
        "catfish"
        "freerdp"
        "gnome-tweaks"
        "libvirt"
        "qemu-kvm"
        "rsync"
        "sshfs"
        "vim"
        "virt-manager"
        "zsh"
        "zenity"
    )

    """
      LayeredPackages: akmod-nvidia catfish gnome-tweaks libvirt qemu-kvm vim virt-manager zenity zsh
            LocalPackages: kmod-nvidia-6.11.10-300.fc41.x86_64-3:565.57.01-1.fc41.x86_64
                           wps-office-12.1.0.17885-1.x86_64
    """
    # 构建显示命令
    echo "将执行以下命令:"
    echo "sudo rpm-ostree install \\"
    for pkg in "${PACKAGES[@]}"; do
        echo "    $pkg \\"
    done

    read -p "是否要安装必要软件包? (y/n) " answer
    if [[ $answer =~ ^[Yy]$ ]]; then
        echo "开始安装必要软件包..."
        
        # 执行安装命令
        sudo rpm-ostree install "${PACKAGES[@]}"
    else
        echo "跳过软件包安装"
    fi

    # 询问是否安装 RPM Fusion 仓库
    read -p "是否要安装 RPM Fusion 仓库? (y/n) " rpmfusion_answer
    if [[ $rpmfusion_answer =~ ^[Yy]$ ]]; then
        echo "开始安装 RPM Fusion 仓库..."
        sudo rpm-ostree install \
            https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
            https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        echo "RPM Fusion 仓库安装完成。系统需要重启才能生效。"
        read -p "是否现在重启系统? (y/n) " reboot_answer
        if [[ $reboot_answer =~ ^[Yy]$ ]]; then
            sudo systemctl reboot
        fi
    else
        echo "跳过 RPM Fusion 仓库安装"
    fi

    # 询问是否安装 NVIDIA 驱动
    read -p "是否要安装 NVIDIA 驱动? (y/n) " nvidia_answer
    if [[ $nvidia_answer =~ ^[Yy]$ ]]; then
        echo "开始安装 NVIDIA 驱动..."
        rpm-ostree install \
            akmod-nvidia \
            xorg-x11-drv-nvidia \
            xorg-x11-drv-nvidia-cuda
        rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1
    else
        echo "跳过 NVIDIA 驱动安装"
    fi
    
else
    echo "非 Silverblue 系统，跳过相关软件包安装"
fi

read -p "是否要安装 Miniconda3? (y/n) " miniconda3_answer
if [[ $miniconda3_answer =~ ^[Yy]$ ]]; then
    echo "开始安装 Miniconda3..."
    bash $DOTFILES_SCRIPT_DIR/install/miniconda3.sh
else
    echo "跳过 Miniconda3 安装"
fi

chmod 600 $HOME/.ssh/id_rsa
chmod 700 $HOME/.ssh

# 启动并启用 libvirtd 服务
sudo systemctl start libvirtd
sudo systemctl enable libvirtd
sudo systemctl status libvirtd

sudo virsh autostart win11        # 启动 win11 虚拟机
sudo virsh list --autostart
