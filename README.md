# dotfiles

基于 Zsh + Zinit + 自管 Neovim/lazy.nvim 的终端配置方案，追求快速启动与可控的开发体验。

## 快速开始

### 第一步：克隆仓库

```bash
git clone https://github.com/iamcheyan/dotfiles ~/dotfiles
cd ~/dotfiles
```

### 第二步：运行初始化脚本

```bash
bash init.sh              # 完整安装（推荐）
bash init.sh --minimal    # 轻量安装（跳过字体、Neovim 等）
bash init.sh --repair     # 修复损坏的 zinit 插件
```

初始化脚本会自动完成以下操作：
- 安装 Zsh 并设置为默认 Shell
- 安装所有必备工具（git, curl, ripgrep, fd, bat, lsd, zoxide 等）
- 安装 zinit 插件管理器
- 安装 pyenv（Python 版本管理）
- 安装 fnm（Fast Node Manager）
- 安装 fzf（模糊搜索）
- 安装 direnv（目录级环境变量）
- 创建配置文件符号链接
- 安装 Neovim + lazy.nvim 自管配置
- 安装 Nerd Font 字体
- 初始化 Yazi 文件管理器配置
- 安装 Zellij、Codex、Opencode 等额外工具

### 第三步：启动 Zsh

```bash
zsh
```

首次启动会自动安装 Starship 主题和所有插件。

## 核心组件

| 组件 | 说明 |
|------|------|
| **Shell** | Zsh + Starship |
| **插件管理** | Zinit（异步加载，极速启动） |
| **Vim 模式** | zsh-vi-mode |
| **历史搜索** | Atuin（Ctrl+R） |
| **编辑器** | Neovim（lazy.nvim，自管配置） |
| **文件管理** | Yazi |
| **终端多路复用** | Zellij |
| **终端模拟器** | Kitty / Ghostty |

## 工具链替换

我们用更现代的工具替换了传统命令：

| 原命令 | 替换工具 | 说明 |
|--------|----------|------|
| `ls` | eza | 带颜色和图标的目录列表 |
| `cat` | bat | 带语法高亮的文件查看 |
| `find` | fd | 更快的文件查找 |
| `du` | dust | 更直观的磁盘使用分析 |
| `grep` | ripgrep | 极速文本搜索 |
| `top` | btop | 美化的系统监控 |
| `ps` | procs | 更友好的进程查看 |
| `cd` | zoxide | 智能目录跳转（记住历史路径） |

## AI Agent 集成

我们提供了一键切换 AI Agent 账户的脚本，支持多个 AI 编码助手：

### cc 脚本（Claude Code 启动器）

Claude Code 的封装脚本，支持多 provider/model 切换、会话恢复、非交互模式等。

```bash
cc                          # 启动 Claude Code
cc <provider>               # 使用指定 provider
cc <provider> <model>       # 使用指定 provider + model
cc -s                       # 交互式选择 model
cc -c                       # 继续上次对话
cc -r                       # 恢复历史对话
cc -p "prompt"              # 非交互模式
```

### cx 脚本（通用 Agent 切换）

```bash
cx              # 切换 Agent 账户
cx --list       # 列出所有配置的账户
```

### 支持的 Agent

| Agent | 说明 |
|-------|------|
| `app:claude-code` | Claude Code |
| `app:opencode` | OpenCode |
| `app:codex` | Codex |

所有 Agent 通过统一的 API 接入，使用独立的 Node.js 版本隔离运行。

## Neovim 插件列表

Neovim 配置现在直接基于 `lazy.nvim`，不再导入 LazyVim 发行版。保留的 LazyVim 风格快捷键已经迁移到本仓库的本地配置中。

| 插件 | 功能 |
|------|------|
| **aerial** | 代码大纲/导航（类似 VS Code 面包屑） |
| **auto-session** | 自动保存/恢复会话 |
| **blink.cmp** | 自动补全 |
| **bufferline** | 顶部标签栏 |
| **ccc** | 颜色预览/编辑器 |
| **diffview** | Git diff 与文件历史 |
| **dashboard** | 启动页面 |
| **dev-visual** | 开发可视化工具 |
| **disable-diagnostics** | 禁用诊断显示 |
| **fidget** | LSP 进度提示 |
| **flash** | 快速跳转（类似 Hop/Sneak） |
| **gitsigns** | Git 增删改标记和 hunk 操作 |
| **grug-far** | 全局搜索替换 |
| **heirline** | 状态栏/窗口栏 |
| **hlslens** | 搜索结果高亮和数量提示 |
| **icons** | 图标支持 |
| **indent-blankline** | 缩进引导线 |
| **lsp-keymaps** | LSP 快捷键 |
| **mason / mason-lspconfig** | LSP server 和 CLI 工具安装 |
| **mini.ai / mini.pairs** | 文本对象和成对符号 |
| **neo-tree** | 文件浏览器 |
| **oil** | 文件浏览器（轻量） |
| **snacks** | picker、dashboard、terminal、toggle 等 UI 工具 |
| **telescope** | 模糊搜索 |
| **treesitter / treesitter-textobjects** | 语法高亮、折叠、缩进和语法对象 |
| **vim-visual-multi** | 多光标编辑 |
| **vimquest** | 英语单词拼写与记忆小游戏插件 |
| **which-key** | 快捷键提示 |
| **yanky** | 复制/粘贴增强 |

## 目录结构

```
dotfiles/
├── zshrc                 # Zsh 主配置
├── aliases.conf          # 命令别名
├── init.sh               # 初始化脚本
├── dotlink/              # 符号链接管理
│   ├── dotlink           # 链接创建/管理
│   ├── dotsync           # 同步编排
│   └── dotlinkrc         # 链接配置
├── plugins/              # Zinit 插件配置
│   ├── zinit/            # Zinit 管理器
│   ├── prompt/           # Powerlevel10k 主题
│   ├── tools/            # CLI 工具
│   ├── completion/       # 补全配置
│   ├── yazi/             # Yazi 集成
│   ├── fzf/              # fzf 配置
│   ├── zellij/           # Zellij 集成
│   └── zsh-vi-mode/      # Vim 模式
├── config/               # 应用配置
│   ├── nvim/             # Neovim (lazy.nvim self-managed)
│   ├── yazi/             # Yazi
│   ├── kitty/            # Kitty 终端
│   ├── ghostty/          # Ghostty 终端
│   ├── zellij/           # Zellij
│   └── atuin/            # Atuin 历史搜索
├── scripts/              # 自动化脚本
│   ├── install/          # 安装脚本
│   ├── dev/              # 开发工具
│   └── system/           # 系统工具
├── tools/                # 独立工具脚本
├── agent/                # Agent 脚本（cc/cx/opencode 等）
├── documents/            # 文档/笔记
└── rime/                 # Rime 输入法配置
```

## 日常命令

| 命令 | 说明 |
|------|------|
| `dotlink` | 链接配置文件到 $HOME |
| `dotsync` | 同步配置（备份/推送/恢复） |
| `dp` | 推送 dotfiles 到远程 |
| `reload` | 重载 zsh 配置 |

## 常用快捷键

### Zsh（Vim 模式）

| 按键 | 说明 |
|------|------|
| `Ctrl+R` | 历史命令搜索（Atuin） |
| `;;` | 切换输入法（SBZR） |
| `j/k` | 历史命令搜索（上/下） |

### Neovim

| 按键 | 说明 |
|------|------|
| `<leader>e` | 文件浏览器 |
| `<leader>ff` | 模糊搜索文件 |
| `<leader>fg` | 模糊搜索内容 |
| `<leader>gg` | Git 状态 |
| `<leader>xx` | 诊断列表 |
| `gcc` | 注释/取消注释行 |
| `gc` | 注释/取消注释选中区域 |

## 自定义配置

### 添加新插件

在 `~/.config/nvim/lua/plugins/` 目录下创建新的 `.lua` 文件：

```lua
return {
  {
    "author/plugin-name",
    config = function()
      -- 插件配置
    end,
  },
}
```

### 修改别名

编辑 `~/dotfiles/aliases.conf`，添加你的自定义别名：

```bash
alias mycommand="original-command"
```

然后运行 `reload` 使配置生效。

## 故障排除

### Zinit 插件损坏

```bash
bash init.sh --repair
```

### 重新创建符号链接

```bash
dotlink link
```

### 重置 Neovim 配置

```bash
rm -rf ~/.config/nvim
dotlink link
```

## 许可证

MIT License
