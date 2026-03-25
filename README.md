# Dotfiles

```text
   ___  ____  ________   _____  ____ __
  / _ \/ __ \/_  __/ /  /  _/ |/ / //_/
 / // / /_/ / / / / /___/ //    / ,<   
/____/\____/ /_/ /____/___/_/|_/_/|_|  
```

**一键完备的终端开发环境：零配置，即刻上手。**
注重**极致开箱体验**的个人配置方案。

只需运行一行安装脚本，您将**直接获得**一套精心调校、配置完美的开发环境：
- ⚡️ **Zsh + Powerlevel10k**：补全、高亮、自动建议一应俱全，集成 Atuin 历史搜索。
- 🚀 **Neovim (LazyVim)**：功能强大的现代化终端 IDE，预装主流语言支持与 AI 辅助（Avante）。
- 🛠 **现代化工具链**：自动集成 Rust 生态的命令行工具（bat, rg, fzf, yazi, zellij...）。
- 🌍 **多环境兼容**：支持原生 Linux (LMDE/Debian) 与 WSL，自动处理路径与环境差异。

## 安装

```bash
# 克隆仓库
git clone https://github.com/iamcheyan/Dotfiles.git ~/Dotfiles

# 或使用 SSH
git clone git@github.com:iamcheyan/Dotfiles.git ~/Dotfiles

cd ~/Dotfiles
bash init.sh
```

提示：
- **智能备份**：`init.sh` 会自动检测并备份冲突的现有配置。
- **Vim 交互**：Zsh 默认启用 `zsh-vi-mode`，按 `ESC` 切换模式。
- **历史搜索**：在插入模式下按 `↑` 键即可唤起 Atuin 强大的历史命令搜索界面。

## 特性

### Zsh 交互体验
- **Atuin**：全屏、可筛选的交互式命令历史记录，支持跨机器同步。
- **Fzf-tab**：使用 fzf 替换传统的补全菜单，支持预览文件与目录内容。
- **Vi-mode**: 完美集成的 Vi 模式，且在插入模式下保留了直观的方向键历史搜索。
- **Forgit**: 利用 fzf 提供的交互式 Git 增强工具（预览、搜索、回滚）。
- **Autopair**: 像现代 IDE 一样自动配对括号和引号。

### Neovim (LazyVim)

- **AI 赋能**：集成 `avante.nvim` (类似 Cursor) 提供智能编码建议。
- **语言支持**：预配置 Python (pyenv 兼容)、Rust、Node.js、Go 等主流开发环境。
- **增强插件**：`aerial` (大纲)、`telescope` (模糊搜索)、`bookmarks` (书签)、`neo-tree` (文件树)、`flash` (快速跳转)。

### 现代 Rust 工具链
已集成并自动安装：
- **文件管理**: `yazi` (极速文件管理器), `superfile` (sf)
- **多路复用**: `zellij` (现代化的终端复用器)
- **搜索增强**: `ripgrep` (rg), `fd`, `fzf`
- **系统监控**: `btm` (bottom), `duf`, `dust`, `procs`
- **内容查看**: `bat` (支持语法高亮的 cat), `glow` (Markdown 预览)

## Zsh 插件清单 (Zinit 管理)
- `zsh-vi-mode`: 高性能的 Zsh Vi 模式实现
- `zsh-autosuggestions`: 基于历史记录的自动建议
- `zsh-syntax-highlighting`: 实时命令语法高亮
- `fzf-tab`: 强大的 fzf 补全选择菜单
- `atuin`: 全新定义的 shell 历史管理
- `zsh-history-substring-search`: 历史子字符串搜索
- `zsh-you-should-use`: 提醒你可以使用的 Alias
- `zsh-extract`: 一个命令解压所有格式
- `git-open`: 在浏览器中快速打开仓库地址

## Neovim 插件亮点
- **核心**: `LazyVim`, `lazy.nvim`, `snacks.nvim`
- **UI**: `heirline.nvim`, `bufferline.nvim`, `catppuccin`, `noice.nvim`
- **AI**: `avante.nvim`, `sbzr.nvim.im` (输入法集成)
- **效率**: `telescope.nvim`, `which-key.nvim`, `grug-far.nvim`, `vim-visual-multi`
- **辅助**: `translator-panel.nvim` (翻译面板), `aerial.nvim` (代码结构)

## 维护与自定义
- **本地配置**: 机器特定的设置可以放在 `~/.dotfiles/plugins/local/local.zsh` 中。
- **别名管理**: 常用 Alias 集中在 `aliases.conf`，支持 pyenv 的动态加载检查。

## 使用技巧

### Git 增强 (forgit)
使用了 `forgit` 插件，你可以通过以下命令获得极佳的交互体验：
- `ga`: 交互式 `git add`，使用 fzf 选择文件，支持实时 diff 预览。
- `glo`: 交互式 `git log`，支持搜索 commit 并预览详细改动。
- `gd`: 交互式 `git diff`，快速查看当前工作区的修改。
- `grh`: 交互式 `git reset HEAD`，选择性撤销暂存。

### 历史搜索 (Atuin)
- **插入模式下按 `↑`**: 唤起 Atuin 搜索界面。
- **Ctrl + R**: 也可以唤起 Atuin 搜索。
- 支持按时间、退出码、目录等多种维度筛选历史。

### 自动补全 (fzf-tab)
- 在输入命令参数时按 `Tab`，可以使用 fzf 菜单选择补全项，支持预览文件内容、目录结构甚至是环境变量。

## License
MIT
