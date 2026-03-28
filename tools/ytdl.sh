#!/bin/bash

# YouTube 下载增强脚本 (基于 yt-dlp)
# 支持自动提取 MP3、封面注入、多线程下载

# 配置
DOWNLOAD_DIR="$HOME/Downloads/Youtube"
mkdir -p "$DOWNLOAD_DIR"

# 检查依赖
if ! command -v yt-dlp &> /dev/null; then
    echo "错误: 未找到 yt-dlp，请先安装。"
    exit 1
fi

if ! command -v ffmpeg &> /dev/null; then
    echo "警告: 未找到 ffmpeg，音频转码和封面注入可能失败。"
fi

show_help() {
    echo "用法: ytdl [选项] <URL>"
    echo ""
    echo "选项:"
    echo "  mp3      下载最高质量音频并转为 MP3 (包含封面和元数据)"
    echo "  video    下载最高画质视频 (自动合并音视频)"
    echo "  list     下载整个播放列表并转为 MP3"
    echo "  help     显示此帮助"
}

case "$1" in
    mp3)
        echo "🎵 正在下载 MP3..."
        yt-dlp -x \
            --audio-format mp3 \
            --audio-quality 0 \
            --embed-thumbnail \
            --add-metadata \
            --parse-metadata "playlist_index:%(track_number)s" \
            -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
            "$2"
        ;;
    video)
        echo "🎬 正在下载最高画质视频..."
        yt-dlp -f "bestvideo+bestaudio/best" \
            --merge-output-format mp4 \
            -o "$DOWNLOAD_DIR/%(title)s.%(ext)s" \
            "$2"
        ;;
    list)
        echo "📂 正在下载播放列表 (MP3)..."
        yt-dlp -x \
            --audio-format mp3 \
            --audio-quality 0 \
            --embed-thumbnail \
            --add-metadata \
            -o "$DOWNLOAD_DIR/%(playlist_title)s/%(playlist_index)s - %(title)s.%(ext)s" \
            "$2"
        ;;
    *)
        show_help
        exit 1
        ;;
esac

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 下载完成！文件保存在: $DOWNLOAD_DIR"
else
    echo ""
    echo "❌ 下载失败，请检查网络或 URL。"
fi
