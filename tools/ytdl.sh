#!/bin/bash

# YouTube 下载增强脚本 (基于 yt-dlp)
# 交互模式 + 命令行模式

# 颜色定义
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 默认配置
DEFAULT_DOWNLOAD_DIR="$HOME/Downloads/Youtube"

# 检查依赖
if ! command -v yt-dlp &> /dev/null; then
    echo "错误: 未找到 yt-dlp，请先安装。"
    exit 1
fi

show_help() {
    echo "用法: ytdl [选项] <URL>"
    echo "选项: mp3, video, list, help"
    echo "提示: 直接运行 'ytdl' 进入交互模式"
}

# 交互函数
interactive_mode() {
    echo -e "${BLUE}=== YouTube 交互下载模式 ===${NC}"
    
    # 1. 输入 URL
    read -p "请输入 YouTube URL: " url
    if [[ -z "$url" ]]; then
        echo "URL 不能为空。"
        exit 1
    fi

    # 2. 输入目录
    read -p "请输入存储目录 (默认: $DEFAULT_DOWNLOAD_DIR): " input_dir
    DOWNLOAD_DIR=${input_dir:-$DEFAULT_DOWNLOAD_DIR}
    mkdir -p "$DOWNLOAD_DIR"
    echo -e "${GREEN}存储目录: $DOWNLOAD_DIR${NC}"

    # 3. 选择类型
    echo -e "${YELLOW}请选择下载类型:${NC}"
    echo "1) MP3 (最高音质 + 封面)"
    echo "2) Video (最高画质 MP4)"
    echo "3) Playlist (整个列表转 MP3)"
    read -p "请选择 (1/2/3): " choice

    case "$choice" in
        1) download_mp3 "$url" "$DOWNLOAD_DIR" ;;
        2) download_video "$url" "$DOWNLOAD_DIR" ;;
        3) download_list "$url" "$DOWNLOAD_DIR" ;;
        *) echo "无效选择"; exit 1 ;;
    esac
}

download_mp3() {
    local url=$1
    local dir=$2
    echo -e "${BLUE}🎵 正在下载 MP3 到 $dir...${NC}"
    yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata \
        -o "$dir/%(title)s.%(ext)s" "$url"
}

download_video() {
    local url=$1
    local dir=$2
    echo -e "${BLUE}🎬 正在下载最高画质视频到 $dir...${NC}"
    yt-dlp -f "bestvideo+bestaudio/best" --merge-output-format mp4 \
        -o "$dir/%(title)s.%(ext)s" "$url"
}

download_list() {
    local url=$1
    local dir=$2
    echo -e "${BLUE}📂 正在下载播放列表到 $dir...${NC}"
    yt-dlp -x --audio-format mp3 --audio-quality 0 --embed-thumbnail --add-metadata \
        -o "$dir/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" "$url"
}

# 主逻辑
if [[ -z "$1" ]]; then
    interactive_mode
else
    # 命令行模式兼容原有 Alias
    case "$1" in
        mp3) download_mp3 "$2" "$DEFAULT_DOWNLOAD_DIR" ;;
        video) download_video "$2" "$DEFAULT_DOWNLOAD_DIR" ;;
        list) download_list "$2" "$DEFAULT_DOWNLOAD_DIR" ;;
        help) show_help ;;
        *) interactive_mode ;;
    esac
fi

if [ $? -eq 0 ]; then
    echo -e "\n${GREEN}✅ 下载完成！${NC}"
else
    echo -e "\n${RED}❌ 下载失败。${NC}"
fi
