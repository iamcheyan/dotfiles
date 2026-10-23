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

- `docs/ZSH-CLI-TOOLS.md`：forgit、navi、Pet 的详细说明。
- `docs/site/`：本站的源文件（Markdown + 构建脚本 + CSS/JS）。
- `config/nvim/docs/`：Neovim 自己的文档，子模块内。

<!-- lang:en -->

> 摘要：What each repository directory owns — sources, build artifacts and submodules.

# Repository layout

## Top level

```text
dotfiles/
├── zshrc                 # Zsh entry point; derives the repo root from its own path
├── aliases.conf          # shared aliases, the ra function, dotfiles management commands
├── init.sh               # cross-platform bootstrap (11 steps + extras)
├── pull.sh               # pull helper
├── dotlink/              # home-grown symlink manager
├── plugins/              # Zsh plugins, CLI tools, completion, prompt
├── scripts/              # installers, updaters, runtime setup, tests
├── tools/                # standalone small tool scripts
├── config/               # per-app configs
├── docs/                 # documentation and this site's sources
├── local/                # private overrides (only the README is tracked)
├── aliases/              # separate repository for private aliases
└── chezmoi              # symlink into the private chezmoi repository
```

## plugins/

```text
plugins/
├── zinit/zinit.zsh       # Zinit init + the zz directory picker
├── zsh-plugins.zsh       # all Zsh plugins and the three-stage loader
├── tools/tools.zsh       # Zinit-managed CLI tools + install:httpie
├── completion/completion.zsh  # compinit, PATH ordering, fzf-tab config
├── prompt/prompt.zsh     # Starship download and init
├── fzf/fzf.zsh           # f / ffd functions and FZF_DEFAULT_OPTS
└── sshfs/                # vssh and vifm-sshfs
```

`zsh-plugins.zsh` is the only place to touch Zsh plugins; `tools.zsh` deals only with tool binaries.

## scripts/

```text
scripts/
├── install/              # install_font / install_nvim / install_httpie / install_zellij
├── setup/setup_fnm.sh    # fnm lazy-load wrapper
├── tests/                # nvim_update_test.sh
└── update_nvim.sh        # the nvim-update implementation
```

## config/

```text
config/
├── nvim/          # git submodule -> iamcheyan/nvim
├── vim/vimrc      # shared Vim config
├── gvim/gvimrc    # GVim-specific appearance
├── ranger/        # rc.conf, rifle.conf, two plugin submodules
├── vifm/          # vifmrc, colors, scripts
├── tmux/          # tmux.conf
├── starship/      # starship.toml
├── atuin/         # config.toml
├── ghostty/       # config (not in dotlink)
├── herdr/         # config.toml
└── nano/          # nanorc
```

## What is generated

| Path | Nature |
|---|---|
| `config/nvim` | git submodule; content lives in another repository |
| `config/ranger/plugins/archives` | git submodule |
| `config/ranger/plugins/ranger_devicons` | git submodule |
| `build/site/` | this site's build output, ignored via `.gitignore` |
| `config/nvim/lazy-lock.json` | ignored; machine-local |

Changes in these places are not tracked here. To change the Neovim config, work in the `iamcheyan/nvim` repository.

## What not to touch

`local/` is ignored except for its README — it is where your private config goes. `aliases/` is a separate repository with its own history. `chezmoi` is a symlink into the private orchestration layer.

## Where the docs live

- `docs/ZSH-CLI-TOOLS.md`: detailed notes on forgit, navi and Pet.
- `docs/site/`: this site's sources (Markdown + build script + CSS/JS).
- `config/nvim/docs/`: Neovim's own docs, inside the submodule.

<!-- lang:ja -->

> 摘要：リポジトリの各ディレクトリの担当 — ソース、生成物、サブモジュール。

# ディレクトリ構成

## 最上位

```text
dotfiles/
├── zshrc                 # Zsh の入口。自身のパスからリポジトリルートを導出
├── aliases.conf          # 共通エイリアス、ra 関数、dotfiles 管理コマンド
├── init.sh               # クロスプラットフォーム初期化（11 ステップ + 追加）
├── pull.sh               # pull 補助スクリプト
├── dotlink/              # 自作のシンボリックリンク管理ツール
├── plugins/              # Zsh プラグイン、CLI ツール、補完、プロンプト
├── scripts/              # インストーラ、アップデータ、実行時セットアップ、テスト
├── tools/                # 単独の小ツールスクリプト
├── config/               # アプリごとの設定
├── docs/                 # ドキュメントと本サイトのソース
├── local/                # プライベートな上書き（README のみ追跡）
├── aliases/              # プライベートエイリアスの独立リポジトリ
└── chezmoi              # プライベート chezmoi リポジトリへのシンボリックリンク
```

## plugins/

```text
plugins/
├── zinit/zinit.zsh       # Zinit 初期化 + zz ディレクトリ選択関数
├── zsh-plugins.zsh       # Zsh プラグイン群と 3 段階ローダー
├── tools/tools.zsh       # Zinit 管理の CLI ツール + install:httpie
├── completion/completion.zsh  # compinit、PATH 整理、fzf-tab 設定
├── prompt/prompt.zsh     # Starship のダウンロードと初期化
├── fzf/fzf.zsh           # f / ffd 関数と FZF_DEFAULT_OPTS
└── sshfs/                # vssh と vifm-sshfs
```

Zsh プラグインを変更する場所は `zsh-plugins.zsh` だけです。`tools.zsh` はツールのバイナリのみを扱います。

## scripts/

```text
scripts/
├── install/              # install_font / install_nvim / install_httpie / install_zellij
├── setup/setup_fnm.sh    # fnm 遅延ロードラッパー
├── tests/                # nvim_update_test.sh
└── update_nvim.sh        # nvim-update の実装
```

## config/

```text
config/
├── nvim/          # git サブモジュール -> iamcheyan/nvim
├── vim/vimrc      # Vim 共通設定
├── gvim/gvimrc    # GVim 専用の外観
├── ranger/        # rc.conf、rifle.conf、2 つのプラグインサブモジュール
├── vifm/          # vifmrc、colors、scripts
├── tmux/          # tmux.conf
├── starship/      # starship.toml
├── atuin/         # config.toml
├── ghostty/       # config（dotlink 対象外）
├── herdr/         # config.toml
└── nano/          # nanorc
```

## 生成物

| パス | 性質 |
|---|---|
| `config/nvim` | git サブモジュール。中身は別リポジトリ |
| `config/ranger/plugins/archives` | git サブモジュール |
| `config/ranger/plugins/ranger_devicons` | git サブモジュール |
| `build/site/` | 本サイトのビルド产物。`.gitignore` 対象 |
| `config/nvim/lazy-lock.json` | 除外。マシンローカル |

ここへの変更は本リポジトリでは追跡されません。Neovim 設定を変えるなら `iamcheyan/nvim` リポジトリで作業してください。

## 触らないもの

`local/` は README 以外すべて無視され、プライベート設定の置き場所です。`aliases/` は独自の履歴を持つ独立リポジトリ。`chezmoi` はプライベートな編成層へのシンボリックリンクです。

## ドキュメントの場所

- `docs/ZSH-CLI-TOOLS.md`：forgit、navi、Pet の詳細。
- `docs/site/`：本サイトのソース（Markdown + ビルドスクリプト + CSS/JS）。
- `config/nvim/docs/`：Neovim 自身のドキュメント。サブモジュール内。
