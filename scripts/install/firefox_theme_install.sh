# 安装 Firefox GNOME 主题
echo "正在安装 Firefox GNOME 主题..."

# 克隆仓库到 $HOME/.cache 目录
git_repo="https://github.com/rafaelmardojai/firefox-gnome-theme.git"
clone_dir="$HOME/.cache/firefox-gnome-theme"

if [ -d "$clone_dir" ]; then
    echo "Firefox GNOME 主题仓库已存在，正在更新..."
    cd "$clone_dir"
    git pull
else
    echo "正在克隆 Firefox GNOME 主题仓库..."
    git clone "$git_repo" "$clone_dir"
fi

# 进入仓库目录并运行安装脚本
if [ -d "$clone_dir" ]; then
    cd "$clone_dir"
    bash ./scripts/auto-install.sh
    echo "Firefox GNOME 主题安装完成"
else
    echo "无法找到 Firefox GNOME 主题仓库，安装失败"
fi