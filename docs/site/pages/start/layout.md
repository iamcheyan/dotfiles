> 摘要：仓库每个目录负责什么，哪些是源文件、哪些是生成物、哪些是子模块。

# 目录结构

## 顶层

```text
dotfiles/
├── zshrc                 # Zsh 主入口，从自身位置推导仓库根
├── aliases.conf          # 通用别名、ra 函数、dotfiles 管理命令
├── init.sh               # 跨平台初始化（11 步 + 额外组件）
├── pull.sh               # 拉取辅助脚本
├── dotlink/              # 自研软链接管理器
├── plugins/              # Zsh 插件、CLI 工具、补全、提示符
├── scripts/              # 安装器、更新器、运行时 setup、测试
├── tools/                # 独立小工具脚本
├── config/               # 各应用配置
├── docs/                 # 文档与本站源文件
├── local/                # 用户私人覆盖（只跟踪 README）
├── aliases/              # 独立子仓库，私有别名
└── chezmoi              # 指向私有 chezmoi 仓库的软链接
```

## plugins/

```text
plugins/
├── zinit/zinit.zsh       # Zinit 初始化 + zz 目录选择函数
├── zsh-plugins.zsh       # 全部 Zsh 插件与三阶段加载函数
├── tools/tools.zsh       # Zinit 管理的 CLI 工具 + install:httpie
├── completion/completion.zsh  # compinit、PATH 整理、fzf-tab 配置
├── prompt/prompt.zsh     # Starship 下载与初始化
├── fzf/fzf.zsh           # f / ffd 函数与 FZF_DEFAULT_OPTS
└── sshfs/                # vssh 与 vifm-sshfs
```

`zsh-plugins.zsh` 是唯一需要改 Zsh 插件的地方；`tools.zsh` 只管工具二进制。

## scripts/

```text
scripts/
├── install/              # install_font / install_nvim / install_httpie / install_zellij
├── setup/setup_fnm.sh    # fnm 惰性加载包装器
├── tests/                # nvim_update_test.sh
└── update_nvim.sh        # nvim-update 的实现
```

## config/

```text
config/
├── nvim/          # git 子模块 -> iamcheyan/nvim
├── vim/vimrc      # Vim 通用配置
├── gvim/gvimrc    # GVim 专属外观
├── ranger/        # rc.conf、rifle.conf、两个插件子模块
├── vifm/          # vifmrc、colors、scripts
├── tmux/          # tmux.conf
├── starship/      # starship.toml
├── atuin/         # config.toml
├── ghostty/       # config（未纳入 dotlink）
├── yazi/          # flavors（未纳入 dotlink）
├── herdr/         # config.toml
└── nano/          # nanorc
```

## 哪些是生成物

| 路径 | 性质 |
|---|---|
| `config/nvim` | git 子模块，内容来自另一个仓库 |
| `config/ranger/plugins/archives` | git 子模块 |
| `config/ranger/plugins/ranger_devicons` | git 子模块 |
| `build/site/` | 本站构建产物，被 `.gitignore` 忽略 |
| `config/nvim/lazy-lock.json` | 被忽略，机器本地保存 |

修改这些位置的内容不会被本仓库跟踪。要改 Neovim 配置，去 `iamcheyan/nvim` 仓库。

## 哪些不要动

`local/` 除 README 外全部被忽略，是给你放私人配置的。`aliases/` 是独立仓库，有自己的提交历史。`chezmoi` 是软链接，指向私有编排层。

## 文档位置

- `docs/ZSH-CLI-TOOLS.md`：forgit、navi、Pay Respects、Pet、Inshellisense 的详细说明。
- `docs/site/`：本站的源文件（Markdown + 构建脚本 + CSS/JS）。
- `config/nvim/docs/`：Neovim 自己的文档，子模块内。
