> 摘要：从克隆到 exec zsh，按 init.sh 与 dotlink 的真实执行顺序走一遍安装。

# 安装流程

## 前置条件

`init.sh` 会自己检查或安装大部分依赖，但你至少需要一个可用的 shell、`git` 和网络。支持 Debian/Ubuntu、Arch、Fedora、Void、macOS、WSL；NixOS 只部署用户目录配置，系统包由声明式配置管理。

```bash
git --version
bash --version
```

## 四步安装

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule update --init --recursive
bash init.sh
```

前三步是纯粹的获取代码，不会改动你的配置。真正会改动系统的是 `bash init.sh`。

`git submodule update` 这一步不能省：`config/nvim` 是 gitlink，不初始化它，dotlink 会链接到一个空目录。

## init.sh 实际做了什么

脚本按固定顺序执行 11 个步骤，每一步失败时打印 warning 并继续，不会整体中断：

| 步骤 | 动作 |
|---|---|
| 1 | 定位 dotfiles 仓库目录 |
| 2 | 检查/安装 zsh |
| 3 | 安装基础工具（git、curl、build-essential 等） |
| 3.5 | 初始化 git 子模块 |
| 4 | 检查/安装 zinit |
| 5 | 检查/安装 fnm |
| 6 | 检查/安装 Fresh |
| 7 | 检查/安装 fzf |
| 8 | 调用 dotlink 建立软链接 |
| 8.5 | 检查 ranger 插件 |
| 9 | 创建 `~/.zshrc` 软链接 |

后面还有字体、Neovim、Docker、Zellij、gh-dash、Herdr 等额外组件。**注意顺序：软链接在字体和 Neovim 之前建立**，所以中途失败时链接可能已经生效，而依赖还没装好。

## 覆盖提示

`init.sh` 启动时会明确提示：会替换已有的配置文件，并倒数 3 秒。它不会静默覆盖。如果你想先看它会动哪些文件，先只运行链接部分：

```bash
bash dotlink/dotlink list
```

## 安装后必须做的一步

```bash
exec zsh
```

当前 shell 还是 bash 或旧配置，必须重新加载才能用上新的 `zshrc`。首次启动会触发 Zinit 下载插件和工具，可能需要几分钟，期间终端可能看起来卡住。

## 如果中途失败

按步骤名排查，而不是重跑整个脚本：

```bash
command -v zsh git fzf nvim fnm
zinit list
ls -l ~/.zshrc ~/.config/nvim
```

`--repair` 专门处理 Zinit 插件损坏（例如 atuin 目录不完整）：

```bash
bash init.sh --repair
```

## 与 Neovim 的关系

`init.sh` 会在 `config/nvim` 里调用 Neovim 仓库自己的 `init.sh --skip-plugins`，只检查/安装 Neovim 本体和依赖，插件留给首次启动的 lazy.nvim。Neovim 的安装细节见 [Neovim 安装器](../scripts/nvim-install.html)。

<!-- lang:en -->

> 摘要：From clone to exec zsh, following the real execution order of init.sh and dotlink.

# Installation walkthrough

## Prerequisites

`init.sh` checks or installs most dependencies itself, but you need at least a working shell, `git`, and network access. Debian/Ubuntu, Arch, Fedora, Void, macOS and WSL are supported; on NixOS only the user-directory configs are deployed — system packages belong to the declarative configuration.

```bash
git --version
bash --version
```

## Four steps

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule update --init --recursive
bash init.sh
```

The first three steps only fetch code and touch nothing of yours. The step that actually changes the system is `bash init.sh`.

Do not skip the submodule step: `config/nvim` is a gitlink, and without initializing it dotlink would link to an empty directory.

## What init.sh actually does

The script runs 11 steps in a fixed order; each failed step prints a warning and the run continues rather than aborting:

| Step | Action |
|---|---|
| 1 | Locate the dotfiles repository |
| 2 | Check/install zsh |
| 3 | Install base tools (git, curl, build-essential, …) |
| 3.5 | Initialize git submodules |
| 4 | Check/install zinit |
| 5 | Check/install fnm |
| 6 | Check/install Fresh |
| 7 | Check/install fzf |
| 8 | Run dotlink to create symlinks |
| 8.5 | Check ranger plugins |
| 9 | Create the `~/.zshrc` symlink |

Font, Neovim, Docker, Zellij, gh-dash, Herdr and other extras come after. **Mind the order: symlinks are created before fonts and Neovim**, so a mid-run failure can leave links live while dependencies are still missing.

## The overwrite prompt

On startup `init.sh` states plainly that existing config files will be replaced, then counts down from 3. Nothing is overwritten silently. To preview which files it would touch, run only the linking part:

```bash
bash dotlink/dotlink list
```

## The one mandatory post-install step

```bash
exec zsh
```

Your current shell is still bash (or the old config); it must be reloaded for the new `zshrc` to take over. The first launch triggers Zinit downloads of plugins and tools, which can take minutes and make the terminal look stuck.

## If it fails midway

Debug by step name instead of rerunning the whole script:

```bash
command -v zsh git fzf nvim fnm
zinit list
ls -l ~/.zshrc ~/.config/nvim
```

`--repair` exists for broken Zinit plugins (for example an incomplete atuin checkout):

```bash
bash init.sh --repair
```

## Relationship with Neovim

Inside `config/nvim`, `init.sh` calls the Neovim repository's own `init.sh --skip-plugins`, which installs only Neovim itself and its dependencies; plugins are left to lazy.nvim on first launch. See the [Neovim installer](../scripts/nvim-install.html) for details.

<!-- lang:ja -->

> 摘要：clone から exec zsh まで、init.sh と dotlink の実際の実行順でたどるインストール手順。

# インストール手順

## 前提条件

`init.sh` は依存関係の大半を自前で確認・インストールしますが、動くシェル・`git`・ネットワークは最低限必要です。Debian/Ubuntu、Arch、Fedora、Void、macOS、WSL に対応。NixOS ではユーザーディレクトリの設定のみ配置し、システムパッケージは宣言型設定の管轄です。

```bash
git --version
bash --version
```

## 4 ステップ

```bash
git clone https://github.com/iamcheyan/dotfiles.git ~/dotfiles
cd ~/dotfiles
git submodule update --init --recursive
bash init.sh
```

最初の 3 ステップはコードの取得だけで、既存の設定には触れません。システムを実際に変更するのは `bash init.sh` です。

サブモジュールのステップを省略しないでください。`config/nvim` は gitlink であり、初期化しないと dotlink が空ディレクトリへリンクしてしまいます。

## init.sh の実際の中身

スクリプトは 11 ステップを固定順で実行し、失敗したステップは warning を出して続行します：

| ステップ | 動作 |
|---|---|
| 1 | dotfiles リポジトリを特定 |
| 2 | zsh の確認／インストール |
| 3 | 基本ツールのインストール（git、curl、build-essential など） |
| 3.5 | git サブモジュールの初期化 |
| 4 | zinit の確認／インストール |
| 5 | fnm の確認／インストール |
| 6 | Fresh の確認／インストール |
| 7 | fzf の確認／インストール |
| 8 | dotlink によるシンボリックリンク作成 |
| 8.5 | ranger プラグインの確認 |
| 9 | `~/.zshrc` のシンボリックリンク作成 |

この後ろにフォント、Neovim、Docker、Zellij、gh-dash、Herdr などの追加コンポーネントが続きます。**順序に注意：シンボリックリンクはフォントや Neovim より先に作られます**。途中で失敗すると、リンクだけが生きたまま依存が揃っていない状態になり得ます。

## 上書きの警告

`init.sh` は起動時に「既存の設定ファイルを置き換える」と明示し、3 秒のカウントダウンを挟みます。黙って上書きすることはありません。どのファイルに触れるか先に確認したいなら、リンク部分だけを実行します：

```bash
bash dotlink/dotlink list
```

## インストール後に必須の一手

```bash
exec zsh
```

現在のシェルはまだ bash（または旧設定）のままなので、新しい `zshrc` を有効化するには再読み込みが必要です。初回起動時に Zinit がプラグインとツールをダウンロードするため数分かかり、ターミナルが固まったように見えることがあります。

## 途中で失敗したとき

スクリプト全体を再実行せず、ステップ名で切り分けます：

```bash
command -v zsh git fzf nvim fnm
zinit list
ls -l ~/.zshrc ~/.config/nvim
```

`--repair` は Zinit プラグインの破損（例：atuin のディレクトリが不完全）向けです：

```bash
bash init.sh --repair
```

## Neovim との関係

`init.sh` は `config/nvim` 内で Neovim リポジトリ自身の `init.sh --skip-plugins` を呼び、Neovim 本体と依存だけを確認・インストールします。プラグインは初回起動時の lazy.nvim に委ねられます。詳細は [Neovim インストーラ](../scripts/nvim-install.html) を参照してください。
