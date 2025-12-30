# Dotfiles

一个注重开箱即用的个人开发环境：一键安装、细节打磨、长期维护。
核心配置为 Zsh + Powerlevel10k、Neovim (LazyVim)，并配套 Rust 生态的现代命令行工具与常用开源字体。

## 安装

```bash
git clone https://github.com/iamcheyan/Dotfiles.git ~/Dotfiles
cd ~/Dotfiles
bash init.sh
```

安装完成后：
- 首次进入 `zsh` 会自动拉取 Powerlevel10k 与所有 Zsh 插件
- Neovim 配置已就绪（LazyVim），如需安装 Neovim 可运行 `install:nvim`
- 如需字体可运行 `install:font`

## 安装后续步骤与依赖

### Neovim
安装命令：
```bash
install:nvim
install:nvim --force
install:nvim --version 0.9.5
```

系统依赖（用于 Treesitter 等插件编译）：
- Debian/Ubuntu: `build-essential pkg-config cmake unzip clang libclang-dev`
- Fedora/RHEL: `gcc gcc-c++ make pkg-config cmake unzip`
- Arch: `base-devel pkg-config cmake unzip`
- macOS: `xcode-select --install` + `brew install pkg-config cmake`

### 字体
安装命令：
```bash
install:font
install:font --meslo
install:font --noto
install:font --all
install:font --force
```

说明：
- Meslo Nerd Font：用于终端与 P10k 图标
- Noto Serif CJK：中日文字体
- Linux 会自动刷新字体缓存（需要 `fc-cache`）

## 特性

### Zsh + Powerlevel10k
- 使用 Zinit 管理插件与工具
- P10k 采用 Nerd Font 模式，启动快、信息密度高

### Neovim (LazyVim)
- 基于 LazyVim 的现代化配置
- 插件列表见下方「Neovim 插件清单」

### Rust 开发的现代工具
已集成并自动安装的 Rust CLI：
- bat, fd, ripgrep (rg)
- eza, zoxide, zellij, yazi
- delta, dust, procs, bottom (btm)
- sd, choose, xh, atuin

### 常用开源字体
通过 `install:font` 一键安装：
- Meslo Nerd Font（P10k 推荐）
- Noto Serif CJK（中日文字体）

## Zsh 插件清单

已安装的 Zsh 插件如下（均由 Zinit 管理）：
- zsh-vi-mode
- zsh-autosuggestions
- zsh-syntax-highlighting
- fzf-tab
- zsh-you-should-use
- zsh-extract
- git-open
- zshcp
- OMZP::sudo
- OMZP::git
- OMZP::copypath
- OMZP::copyfile

## Neovim 插件清单

此列表基于 `config/nvim/PLUGINS.md`（由 `lazy-lock.json` 生成）。

核心框架与管理：
- LazyVim
- lazy.nvim
- snacks.nvim
- persistence.nvim

AI 辅助：
- avante.nvim
- dressing.nvim

代码智能与语言支持：
- nvim-lspconfig
- mason.nvim
- mason-lspconfig.nvim
- conform.nvim
- nvim-lint
- lazydev.nvim
- ts-comments.nvim

语法高亮与解析：
- nvim-treesitter
- nvim-treesitter-textobjects
- nvim-ts-autotag
- mini.ai
- mini.pairs

界面美化：
- catppuccin
- tokyonight.nvim
- lualine.nvim
- bufferline.nvim
- nui.nvim
- nvim-web-devicons
- mini.icons
- gitsigns.nvim
- which-key.nvim
- noice.nvim

导航与搜索：
- telescope.nvim
- plenary.nvim
- flash.nvim
- trouble.nvim
- todo-comments.nvim
- grug-far.nvim

自动补全：
- blink.cmp
- friendly-snippets

输入法：
- sbzr.nvim.im

## 使用说明与维护

- 每个插件的配置均附使用说明，集中整理在 `plugins/README.md` 与 `config/nvim/PLUGINS.md`
- 本仓库长期维护，欢迎 Issue/PR

## 目录结构概览

```text
~/Dotfiles
├── init.sh
├── zshrc
├── aliases.conf
├── config/
├── plugins/
├── scripts/
├── dotlink/
└── tools/
```

## License

MIT
