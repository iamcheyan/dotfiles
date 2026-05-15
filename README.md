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
| **文件管理** | Yazi / superfile |
| **终端多路复用** | Zellij |
| **终端模拟器** | Kitty / Ghostty |
| **配置管理** | Chezmoi |

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
├── aliases.conf          # 命令别名
├── zshrc                 # Zsh 主配置
├── init.sh               # 初始化脚本（首次安装）
├── dotlink/              # 链接/同步管理
│   ├── dotlink           # 符号链接管理
│   ├── dotsync           # 同步编排
│   └── dotlinkrc         # 链接配置
├── chezmoi/              # Chezmoi 托管配置
├── plugins/              # Zinit 插件配置
│   ├── zinit/            # Zinit 管理器
│   ├── prompt/           # Powerlevel10k
│   ├── tools/            # CLI 工具
│   ├── completion/       # 补全配置
│   ├── yazi/             # Yazi 集成
│   ├── fzf/              # fzf 配置
│   ├── zellij/           # Zellij 集成
│   ├── zsh-vi-mode/      # Vim 模式
│   └── ...
├── config/               # 应用配置
│   ├── nvim/             # Neovim (LazyVim)
│   ├── yazi/             # Yazi
│   ├── kitty/            # Kitty
│   ├── ghostty/          # Ghostty
│   ├── starship/         # Starship
│   ├── zellij/           # Zellij
│   ├── atuin/            # Atuin
│   ├── p10k/             # Powerlevel10k 主题
│   ├── superfile/        # superfile
│   ├── nano/             # Nano
│   └── vim/              # Vim
├── rime/                 # Rime 输入法配置
├── agents/               # AI Agent 启动器
│   ├── opencode/
│   ├── claude-code/
│   ├── codex/
│   └── cline/
├── scripts/              # 自动化脚本
│   ├── install/          # 安装脚本
│   ├── dev/              # 开发工具
│   ├── system/           # 系统工具
│   └── utils/            # 实用工具
├── tools/                # 独立工具脚本
├── documents/            # 文档/笔记
├── aws/                  # AWS 配置
└── omnyssh/              # SSH 管理
```

## 安装

```bash
git clone https://github.com/yourname/dotfiles ~/dotfiles
bash init.sh              # 完整安装
bash init.sh --minimal    # 跳过字体/Neovim 等大件
bash init.sh --repair     # 修复损坏的插件
```

## 日常命令

| 命令 | 说明 |
|------|------|
| `dotlink` | 链接配置文件到 $HOME |
| `dotsync` | 同步配置（备份/推送/恢复） |
| `dp` | 推送 dotfiles + chezmoi 到远程 |
| `reload` | 重载配置（chezmoi + exec zsh） |

## AI Agents

所有 Agent 通过 MiMo API 统一接入，使用独立的 Node.js 版本隔离运行：

```bash
app:opencode     # OpenCode
app:claude-code  # Claude Code
app:codex        # Codex
app:cline        # Cline
```

---

基于 [Zinit](https://github.com/zdharma-continuum/zinit) 和 [LazyVim](https://github.com/LazyVim/LazyVim) 构建。
