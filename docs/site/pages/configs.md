> 摘要：按 dotlink 实际映射说明 Vim、Ranger、Vifm、Starship、Atuin、Ghostty 和 tmux 配置。

# 应用配置

## dotlink 实际映射

| 源 | 目标 | 功能 |
|---|---|---|
| `zshrc` | `~/.zshrc` | Shell 入口 |
| `config/starship/starship.toml` | `~/.config/starship.toml` | Starship 主题 |
| `config/atuin` | `~/.config/atuin` | Atuin 配置 |
| `config/nano/nanorc` | `~/.nanorc` | Nano 设置 |
| `config/gvim/gvimrc` | `~/.gvimrc` | GVim GUI 外观 |
| `config/vim/vimrc` | `~/.vimrc` | Vim 通用配置 |
| `config/nvim` | `~/.config/nvim` | Neovim 子模块；维护者机器可优先链接 `~/nvim` |
| `config/ranger` | `~/.config/ranger` | Ranger 配置与插件 |
| `config/vifm/vifmrc` | `~/.config/vifm/vifmrc` | Vifm 主配置 |
| `config/vifm/colors` | `~/.config/vifm/colors` | 颜色方案 |
| `config/vifm/scripts` | `~/.config/vifm/scripts` | 剪贴板脚本 |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr 配置 |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | 通用 tmux 设置 |

准确映射以 [dotlinkrc](https://github.com/iamcheyan/dotfiles/blob/main/dotlink/dotlinkrc) 为准。Ghostty 与 Yazi 配置虽然在仓库里，但没有列入当前 dotlink 映射；它们不随标准链接命令自动部署。

## Starship

提示符分两行显示目录、Git 分支/状态、Python、Node、Rust、Go、Java、package 版本、Docker/Kubernetes/AWS/Terraform context 和时间；右侧显示命令退出状态、耗时和后台任务。配置文件是 `config/starship/starship.toml`。用 `starship explain` 查看当前提示符模块来源。

## Atuin

`config/atuin/config.toml` 把 `auto_sync` 和 `update_check` 设为关闭，数据库及密钥路径沿用 Atuin 默认。Zsh 加载 Atuin shell 集成；历史数据保存在用户数据目录。需要同步时，先了解 Atuin 的账户和同步服务，再显式修改配置。

## tmux

配置打开真彩色 RGB、鼠标和焦点事件；copy mode 使用 vi 键位。window/pane 从 1 开始并自动重编号，新 window 继承当前目录。历史保留 200000 行，H/J/K/L 调整 pane，X 确认后结束 session。

TPM 管理 sensible、persist、continuum、yank、vim-tmux-navigator 和 tmux-fzf。Vim/Neovim 恢复策略设为 session。机器私有选项可由 `~/.config/tmux/private.conf` 与 `private-after.conf` 接入，不写入公开仓库。

## Ranger

`config/ranger/rc.conf` 开启图像预览、边框、隐藏文件、文件预览和 devicons。Archives 插件注册 `:extract`、`:compress`，快捷键 `ex`、`ec`。`rifle.conf` 使用 `${VISUAL:-$EDITOR}` 打开文件。

## Vifm

Vifm 使用 `papercolor-dark`，Neovim 为文件编辑器，开启 trash、隐藏文件、行号、递增搜索和文件类型图标。主要映射：

| 按键 | 动作 |
|---|---|
| `.` | 显示/隐藏 dotfiles |
| `a`、`r` | 新建、重命名 |
| `d`、`D` | 移入 trash、直接删除 |
| `Tab`、`Shift-Tab` | 前后切换 tab |
| `Space p` | 单栏/双栏切换 |
| `cc`、`cf`、`cd`、`cn` | 复制完整路径、文件名、父目录、无扩展名文件名 |

`vifm-copy` 按 Wayland、X11、macOS、WSL 顺序探测剪贴板；找不到后端会返回错误。

## Vim、GVim 和 Ghostty

Vim 设置 UTF-8 编码候选、Blue 主题、相对行号、鼠标和常见 buffer/window 快捷键。GVim 文件只在 GUI 模式隐藏工具栏及滚动条并指定 Nerd Font。

Ghostty 使用 Meslo Nerd Font Mono、暗底浅字、选中复制到 clipboard、窗口留白和 F11 全屏。它目前未被 dotlink 映射，需手动放到 Ghostty 配置路径或建立链接。

## Neovim 独立配置

Neovim 源码在 `iamcheyan/nvim`，dotfiles 子模块固定分发版本。详见 [Neovim 站点](https://nvim.iamcheyan.com)、[插件目录](https://nvim.iamcheyan.com/plugins.html) 和 [安装页](https://nvim.iamcheyan.com/install.html)。
