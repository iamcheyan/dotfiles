> 摘要：Yazi 是现代文件管理器，本仓库只保存它的 Kanagawa 配色 flavor。

# Yazi

## 用途

Yazi 是 Rust 写的终端文件管理器，特点是异步 IO、快速预览（图片、视频缩略图、PDF、压缩包内容）、插件系统用 Lua。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包或官方安装脚本，**本仓库不安装** |
| 仓库内内容 | `config/yazi/flavors/kanagawa.yazi/` |
| 是否自动部署 | 否，未列入 dotlink |

```bash
# 官方安装
cargo install --locked yazi-fm yazi-cli
# 或
brew install yazi
# Arch
pacman -S yazi
```

## 仓库里有什么

只有一个 flavor：

```text
config/yazi/flavors/kanagawa.yazi/
├── flavor.toml
├── tmtheme.xml
├── LICENSE
├── LICENSE-tmtheme
└── preview.png
```

`kanagawa.yazi` 是 Kanagawa 配色的 Yazi 主题。它本身是一个独立 git 仓库，被嵌套在这里。

**主配置不在这里**：`yazi.toml`、`keymap.toml`、`theme.toml` 属于私有配置边界，不在公开仓库中。

## 手动使用这个 flavor

```bash
mkdir -p ~/.config/yazi/flavors
ln -s ~/dotfiles/config/yazi/flavors/kanagawa.yazi ~/.config/yazi/flavors/kanagawa.yazi
```

然后在 `~/.config/yazi/theme.toml` 里引用：

```toml
[flavor]
dark = "kanagawa"
light = "kanagawa"
```

## 为什么只放 flavor

Yazi 的主配置通常包含个人路径、常用目录、私有预览命令，不适合公开。而 flavor 是纯样式文件，可以安全分享。

这体现了本仓库的边界原则：**能公开复用的部分进公开仓库，机器专属的进私有配置**。

## Yazi 基本用法

```bash
yazi                    # 从当前目录
yazi /path/to/dir       # 指定目录
y                    # 如果用 yazi 的 shell 包装器（本仓库未配）
```

| 键 | 作用 |
|---|---|
| `hjkl` | 移动 |
| `Enter` | 打开 |
| `Space` | 选中 |
| `y` | 复制 |
| `x` | 剪切 |
| `p` | 粘贴 |
| `d` | 删除到回收站 |
| `a` | 新建 |
| `r` | 重命名 |
| `.` | 显示隐藏文件 |
| `z` | 跳转（zoxide 集成） |
| `q` | 退出 |

## 与 Ranger / Vifm 的对比

| | Yazi | Ranger | Vifm |
|---|---|---|---|
| 语言 | Rust | Python | C |
| 异步 | 是 | 否 | 否 |
| 图片预览 | 强 | 中 | 弱 |
| 插件 | Lua | Python | VimL |
| 启动速度 | 快 | 慢 | 快 |

Yazi 在预览能力和速度上占优，但配置体系和本仓库的其它工具不同，所以没有深度集成。

## 排错

**`yazi: command not found`**：本仓库不安装它，需要自己装。

**flavor 不生效**：确认软链接存在，且 `theme.toml` 里 `[flavor]` 段引用了正确名字。

**图片不预览**：需要终端支持图像协议（Kitty、iTerm2、sixel）。普通终端只能看文本。

**配置文件在哪**：`~/.config/yazi/`。本仓库不提供，用 `yazi --help` 查看默认路径。

**和 Ranger/Vifm 冲突**：三者可以共存，命令名不同。
