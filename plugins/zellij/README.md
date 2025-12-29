# Zellij 使用指南

一个比 tmux 更友好的终端复用工具。

## 目录

- [简介](#简介)
- [安装](#安装)
- [基本概念](#基本概念)
- [基本操作](#基本操作)
- [快捷键](#快捷键)
- [配置文件](#配置文件)
- [高级用法](#高级用法)
- [自定义布局](#自定义布局)

---

## 简介

Zellij 是一个终端复用器（terminal multiplexer），类似于 tmux，但提供了更友好的界面和更容易理解的键位设置。

### 主要特点

- **友好的界面**：比 tmux 更直观的用户界面
- **易于理解的键位**：不需要复杂的 prefix 键组合
- **详细文档**：提供详尽的使用文档
- **会话恢复**：支持恢复已关闭的会话（tmux 需要插件）

---

## 安装

### 使用包管理器

```bash
# Debian/Ubuntu
sudo apt install zellij

# Arch Linux
sudo pacman -S zellij

# macOS (Homebrew)
brew install zellij
```

### 使用 Cargo（Rust）

```bash
cargo install zellij
```

### 使用安装脚本

```bash
install:zellij --method cargo   # 使用 cargo 安装
install:zellij --method binary  # 下载二进制文件安装
```

---

## 基本概念

Zellij 采用了与 tmux 相似的层级结构：

1. **会话（Session）**：可以同时运行多个会话，各个会话之间相互独立
2. **标签（Tab）**：每个会话下可以有多个标签（相当于 tmux 的窗口）
3. **窗格（Pane）**：每个标签下可以有多个窗格

### 界面说明

默认界面包含：
- **上方状态栏**：显示当前会话名称和标签
- **下方状态栏**：显示可用的按键绑定
- **中间区域**：终端内容

---

## 基本操作

### 启动 Zellij

```bash
zellij                    # 启动新会话
zellij attach <name>      # 连接到指定会话
zellij list-sessions      # 列出所有会话
```

### 会话管理

- `Ctrl+o` - 进入 session 模式
  - `d` - 断开连接（会话在后台继续运行）
  - `w` - 打开会话管理器

### 标签管理

- `Ctrl+t` - 进入 tab 模式
  - `n` - 创建新标签
  - `x` - 关闭当前标签
  - `r` - 重命名当前标签
  - `h/l` - 在不同标签之间切换
  - `数字键` - 切换到对应序号的标签
  - `b` - 将当前窗格转移到新标签
  - `[` / `]` - 将当前窗格在不同标签之间移动
  - `s` - 进入 sync 模式（所有窗格同步输入）

### 窗格管理

- `Ctrl+p` - 进入 pane 模式
  - `n` - 新建窗格
  - `x` - 关闭当前窗格
  - `c` - 重命名当前窗格
  - `h/j/k/l` 或方向键 - 在窗格之间移动
  - `z` - 切换窗格边框显示

**快速操作（无需进入 pane 模式）：**
- `Alt+n` - 创建新窗格
- `Alt+h/j/k/l` 或方向键 - 在窗格之间移动
- `Alt+[` / `Alt+]` - 切换预设布局
- `Alt++` / `Alt+-` - 调整窗格横向尺寸

### 调整窗格尺寸

- `Alt++` / `Alt+-` - 调整横向尺寸
- `Ctrl+n` - 进入 resize 模式，使用 `h/j/k/l` 精细调整

### 查看终端历史

- `Ctrl+s` - 进入 search 模式
  - `j/k` - 上下滚动
  - `d/u` - 翻页
  - `e` - 使用默认编辑器浏览历史

### 其他模式

- `Ctrl+g` - 进入 locked 模式（禁用所有 prefix 键，避免快捷键冲突）
- `Ctrl+b` - 进入 tmux 模式（tmux 兼容快捷键）

---

## 快捷键

### 默认快捷键总结

| 快捷键 | 功能 |
|--------|------|
| `Ctrl+p` | 进入 pane 模式 |
| `Ctrl+t` | 进入 tab 模式 |
| `Ctrl+o` | 进入 session 模式 |
| `Ctrl+s` | 进入 search 模式 |
| `Ctrl+g` | 进入 locked 模式 |
| `Ctrl+b` | 进入 tmux 模式 |
| `Ctrl+n` | 进入 resize 模式 |
| `Alt+n` | 快速创建新窗格 |
| `Alt+h/j/k/l` | 快速在窗格间移动 |
| `Alt+[` / `Alt+]` | 切换预设布局 |
| `Alt++` / `Alt+-` | 调整窗格横向尺寸 |

---

## 配置文件

Zellij 的配置文件位于 `~/.config/zellij/config.kdl`（KDL 格式）。

### 生成默认配置

```bash
zellij setup --dump-config > ~/.config/zellij/config.kdl
```

### 配置文件结构

配置文件包含三个部分：
1. **默认键位**：快捷键绑定
2. **内置插件**：插件配置
3. **功能选项**：各种功能开关

### 常用配置

#### 修改默认模式

将 locked 模式设为默认（避免快捷键冲突）：

```kdl
default_mode "locked"
```

#### 修改快捷键修饰键

将所有 prefix 键从 `Ctrl` 改为 `Alt`（避免与终端程序冲突）：

```kdl
keybinds clear-defaults=true {
    // 将 Ctrl 改为 Alt
}
```

#### 外观定制

**选择主题：**
```kdl
theme "gruvbox-dark"
```

**自定义主题：**
```kdl
themes {
    gruvbox-dark {
        fg 213 196 161
        bg 40 40 40
        black 60 56 54
        red 204 36 29
        green 152 151 26
        yellow 215 153 33
        blue 69 133 136
        magenta 177 98 134
        cyan 104 157 106
        white 251 241 199
        orange 214 93 14
    }
}
```

**其他外观选项：**
```kdl
default_layout "compact"    # 使用简洁布局
pane_frames false           # 禁用窗格边框
```

#### 功能选项

```kdl
session_serialization true   # 启用会话恢复（默认 true）
scroll_buffer_size 10000     # 回滚历史行数（默认 10000）
copy_on_select false         # 鼠标选中后自动复制（默认 true）
scrollback_editor "nvim"     # 历史查看编辑器（默认使用 $EDITOR）
mouse_mode true              # 启用鼠标支持（默认 true）
```

---

## 高级用法

### 跟随终端启动

#### Bash

在 `~/.bashrc` 中添加：

```bash
eval "$(zellij setup --generate-auto-start bash)"
```

#### Zsh

在 `~/.zshrc` 中添加：

```zsh
eval "$(zellij setup --generate-auto-start zsh)"
```

#### 环境变量

- `ZELLIJ_AUTO_ATTACH=true` - 自动连接到最近的会话
- `ZELLIJ_AUTO_EXIT=true` - 退出 Zellij 时一起退出终端

**注意**：自动启动可能导致终端无法打开（如果 Zellij 崩溃），建议使用快捷键绑定方式：

```bash
# 在窗口管理器或终端配置中绑定快捷键
foot zellij attach -c my_zellij_session
```

### 使用简洁布局

```bash
zellij -l compact    # 使用 compact 布局
```

compact 布局特点：
- 去掉快捷键提示状态栏
- 将顶部标签栏移到下方
- 界面更简洁

### 切换窗格边框

在 pane 模式下按 `z` 可以切换窗格边框显示。

要使此设置持久化，在配置文件中设置：

```kdl
pane_frames false
```

---

## 自定义布局

Zellij 支持自定义布局文件，位于 `~/.config/zellij/layouts/` 目录。

### 创建布局目录

```bash
mkdir -p ~/.config/zellij/layouts
```

### 示例：compact + htop 布局

创建 `~/.config/zellij/layouts/compact_htop.kdl`：

```kdl
default_tab_template {
    children
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }
    pane split_direction="vertical" {
        pane
        pane command="htop"
    }
}
```

### 使用自定义布局

```bash
zellij -l compact_htop
```

---

## 参考资源

- [Zellij 官方文档](https://zellij.dev/)
- [Zellij GitHub](https://github.com/zellij-org/zellij)
- [KDL 格式文档](https://kdl.dev/)

---

## 常见问题

### Q: 快捷键冲突怎么办？

A: 使用 `Ctrl+g` 进入 locked 模式，或修改配置文件将所有 prefix 键改为 `Alt`。

### Q: 如何恢复已关闭的会话？

A: 在 session 模式下按 `w` 打开会话管理器，切换到第三个标签查看已关闭的会话。

### Q: 如何让窗格边框默认关闭？

A: 在配置文件中设置 `pane_frames false`。

### Q: 如何修改回滚历史行数？

A: 在配置文件中设置 `scroll_buffer_size <行数>`。

---

**最后更新**：2024-12-29
