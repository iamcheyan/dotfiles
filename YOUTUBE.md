# 📺 YouTube 下载增强工具指南

本工具基于 `yt-dlp` 和 `ffmpeg`，提供了一套高度自动化的音视频下载与处理方案。

## 1. 核心功能
- **MP3 提取**：自动选择最高音质，转码为 MP3。
- **封面注入**：自动将 YouTube 视频封面嵌入到 MP3 文件的 ID3 标签中。
- **元数据同步**：自动填充歌名、歌手、播放列表索引等信息。
- **自动化分类**：文件默认保存在 `~/Downloads/Youtube` 目录下。

## 2. 快捷命令 (Aliases)

| 命令 | 用法 | 说明 |
| :--- | :--- | :--- |
| **`y:mp3 <URL>`** | `y:mp3 https://...` | 下载最高音质 MP3 (带封面) |
| **`y:video <URL>`** | `y:video https://...` | 下载最高画质 MP4 视频 |
| **`y:list <URL>`** | `y:list https://...` | 下载整个播放列表为 MP3 |
| **`ytdl help`** | `ytdl help` | 查看脚本原始帮助信息 |

## 3. 安装与依赖
本工具已集成在 `init.sh` 自动化安装流程中。

### 核心依赖：
- **`yt-dlp`**：负责绕过限制、解析 URL 与高速下载。
- **`ffmpeg`**：负责音频提取、视频合并以及封面注入。

### 多平台适配：
- **macOS**: `brew install yt-dlp ffmpeg`
- **Debian/Ubuntu**: `sudo apt install ffmpeg` + `pip install yt-dlp` (建议用 pip 以获取最新版本)
- **Arch**: `sudo pacman -S yt-dlp ffmpeg`

## 4. 自定义配置
如需修改下载保存目录，请编辑以下文件：
`~/.dotfiles/tools/ytdl.sh` 中的 `DOWNLOAD_DIR` 变量。

---
*提示：请尊重内容版权，本工具仅供个人学习与离线收藏使用。*
