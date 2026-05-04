# dotfiles

基于 Zsh + Zinit 的终端配置方案，追求极致的启动速度与沉浸式体验。

## 核心组件

| 组件 | 说明 |
|------|------|
| **Shell** | Zsh + Powerlevel10k |
| **插件管理** | Zinit (异步加载) |
| **Vim 模式** | zsh-vi-mode |
| **历史搜索** | Atuin (Ctrl+R) |
| **编辑器** | Neovim (LazyVim) |
| **文件管理** | Yazi |
| **终端多路复用** | Zellij |
| **终端模拟器** | Kitty / Ghostty |

## 工具链

| 原命令 | 替换 |
|--------|------|
| `ls` | eza |
| `cat` | bat |
| `find` | fd |
| `du` | dust |
| `grep` | ripgrep |
| `top` | btop |
| `ps` | procs |
| `cd` | zoxide |

## 目录结构

```
dotfiles/
├── aliases.conf      # 命令别名
├── zshrc           # Zsh 主配置
├── init.sh         # 初始化脚本
├── plugins/       # 插件配置
│   ├── zinit/     # Zinit 管理器
│   ├── prompt/    # Powerlevel10k
│   ├── tools/     # CLI 工具
│   ├── completion/# 补全配置
│   └── yazi/     # Yazi 配置
├── config/        # 工具配置
│   ├── nvim/      # Neovim (LazyVim)
│   ├── yazi/      # Yazi
│   ├── kitty/     # Kitty
│   ├── ghostty/   # Ghostty
│   ├── starship/  # Starship
│   ├── zellij/    # Zellij
│   └── rime/      # Rime 输入法
├── scripts/       # 自动化脚本
├── agents/        # AI Agent 配置
├── tools/         # 实用工具脚本
└── rime/         # Rime 配置
```

## 安装

首次克隆后运行初始化脚本：

```bash
git clone https://github.com/yourname/dotfiles ~/dotfiles
bash init.sh
```

日常同步：

```bash
dotlink     # 链接配置
dotsync    # 同步配置
dp         # 推送 dotfiles 到远程
reload     # 重载配置
```

## 常用别名

```bash
dotlink     # 链接配置
dotsync    # 同步配置
dp         # 推送 dotfiles 到远程
reload     # 重载配置
```

## 快捷键

- `Ctrl+R` - Atuin 历史搜索
- `Ctrl+T` / `Alt+C` - fzf 找文件/目录
- `bd <dir>` - 跳回父目录

---

基于 [Zinit](https://github.com/zdharma-continuum/zinit) 和 [LazyVim](https://github.com/LazyVim/LazyVim) 构建。