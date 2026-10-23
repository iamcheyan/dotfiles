> 摘要：Neovim 是本仓库的主力编辑器，源码在独立仓库，通过子模块固定版本。

# Neovim

## 用途

Neovim 是本仓库默认的编辑器：`$EDITOR`、`$VISUAL`、`vi` 函数、Ranger 的 `rifle.conf`、fzf 的选中动作，全部指向 `nvim`。

## 来源与版本

| 项目 | 说明 |
|---|---|
| 源码仓库 | `iamcheyan/nvim`（独立公开仓库） |
| 本仓库中的位置 | `config/nvim`，git 子模块 |
| 最低版本 | 0.12 |
| 安装 | `init.sh` 调用子模块的 `init.sh --skip-plugins` |

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

这个 gitlink 决定了你拿到哪一版 Neovim 配置。

## 为什么要独立仓库

Neovim 配置本身是一个完整项目：几十个插件、教程、百科、键位文档、自己的站点。放在 dotfiles 里会让主仓库变得难以维护。

所以拆成两个仓库：

```text
iamcheyan/dotfiles  ──子模块──▶  iamcheyan/nvim
      │                                │
      ├── zshrc                        ├── lua/plugins/
      ├── aliases.conf                 ├── docs/
      ├── dotlink/                     ├── site/
      └── scripts/                     └── init.sh
```

## 安装路径

`init.sh` 不会直接装 Neovim，而是调用子模块自己的安装器：

```bash
bash "$nvim_init" --skip-plugins
```

`--skip-plugins` 表示只准备 Neovim 本体和依赖，插件留给首次启动的 lazy.nvim。这样做是因为插件安装需要完整运行时，在安装脚本里做容易失败。

## 版本升级

本地稳定版用 `nvim-update`：

```bash
nvim-update
```

它会下载 GitHub 最新稳定 release，校验 SHA-256，安装到 `~/.local/opt/neovim/<version>`，再原子切换 `~/.local/bin/nvim`。详见 [nvim-update](../scripts/nvim-update.html)。

配置本身的升级靠子模块指针：

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

## 配置入口

| 文件 | 作用 |
|---|---|
| `config/nvim/init.lua` | 入口，只 require `config.lazy` |
| `config/nvim/lua/config/` | 选项、键位、lazy 引导、UI |
| `config/nvim/lua/plugins/` | 每个插件一个文件 |
| `config/nvim/after/` | filetype 覆盖 |

`lua/config/lazy.lua` 里设置了 leader 键（空格）和 `maplocalleader`（反斜杠），然后 `require("lazy").setup({ { import = "plugins" } })`。

## 关键设计

### 不用发行版

本配置直接基于 `lazy.nvim`，不是 LazyVim/AstroNvim 之类的发行版。好处是每个插件为什么存在、怎么配置都清楚；代价是要自己维护。

### 键位生成而非手写

站点上的键位表由运行时导出生成，不是手写的。这样键位和实际配置永远一致。

### 文档即站点

`config/nvim/docs/` 里的 Markdown 同时是 GitHub 文档和站点内容源，一份内容两处用。

## 与 dotfiles 的联动

| 位置 | 联动方式 |
|---|---|
| `dotlink/dotlinkrc` | `config/nvim` → `~/.config/nvim` |
| `aliases.conf` | `vi` 函数优先调 nvim，`$EDITOR` 设为 nvim |
| `config/ranger/rifle.conf` | 用 `$VISUAL` 打开文件 |
| `plugins/fzf/fzf.zsh` | 选中文件用 `nvim` 打开 |
| `config/vim/vimrc` | 尽量镜像 Neovim 的通用键位 |

## 维护者机器上的特例

`dotlink` 里有一段：

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

如果本机有 `~/nvim` 且它的 origin 是这个仓库，就优先链接它，而不是子模块。这样维护者可以直接在 `~/nvim` 开发，不用每次进子模块目录。

普通用户没有这个工作副本，走子模块路径。

## 完整文档

Neovim 配置有自己的站点，内容比这里详细得多：

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com) — 总入口
- [安装](https://nvim.iamcheyan.com/install.html) — 详细安装流程
- [插件目录](https://nvim.iamcheyan.com/plugins.html) — 每个插件的说明
- [教程](https://nvim.iamcheyan.com/tutorials.html) — 从 vi 历史讲起
- [百科](https://nvim.iamcheyan.com/wiki.html) — LSP、Treesitter、编码等概念
- [知识](https://nvim.iamcheyan.com/reference.html) — 选项、命令、术语表

## 排错

**`nvim` 版本低于 0.12**：走了系统包。`nvim-update` 建立用户级安装。

**打开是裸 Neovim**：`~/.config/nvim` 指向空目录。`git submodule update --init --recursive`。

**插件没装**：首次启动需要联网，lazy.nvim 会下载。检查 `:Lazy` 界面。

**键位和文档不符**：子模块版本落后。`git submodule update` 拉到最新。

**改了配置不生效**：确认改的是 `~/nvim`（维护者）或 `config/nvim`（普通用户），而不是软链接目标。

<!-- lang:en -->

> Summary: Neovim is this repository's main editor; the source lives in a separate repository with the version pinned by a submodule.

# Neovim

## Purpose

Neovim is this repository's default editor: `$EDITOR`, `$VISUAL`, the `vi` function, Ranger's `rifle.conf` and fzf's selection action all point at `nvim`.

## Source and version

| Item | Notes |
|---|---|
| Source repository | `iamcheyan/nvim` (standalone public repository) |
| Location in this repo | `config/nvim`, a git submodule |
| Minimum version | 0.12 |
| Install | `init.sh` calls the submodule's `init.sh --skip-plugins` |

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

This gitlink decides which version of the Neovim config you get.

## Why a separate repository

The Neovim config is a complete project in itself: dozens of plugins, tutorials, an encyclopedia, key documentation, its own website. Keeping it inside dotfiles would make the main repository hard to maintain.

So it is split into two repositories:

```text
iamcheyan/dotfiles  ──子模块──▶  iamcheyan/nvim
      │                                │
      ├── zshrc                        ├── lua/plugins/
      ├── aliases.conf                 ├── docs/
      ├── dotlink/                     ├── site/
      └── scripts/                     └── init.sh
```

## Install path

`init.sh` doesn't install Neovim directly; it calls the submodule's own installer:

```bash
bash "$nvim_init" --skip-plugins
```

`--skip-plugins` means only the Neovim binary and its dependencies are prepared; plugins are left to lazy.nvim on first launch. The reason is that plugin installation needs a full runtime, which is error-prone inside an install script.

## Version upgrades

For the local binary, use `nvim-update`:

```bash
nvim-update
```

It downloads the latest stable GitHub release, verifies the SHA-256, installs to `~/.local/opt/neovim/<version>`, then atomically switches `~/.local/bin/nvim`. See [nvim-update](../scripts/nvim-update.html) for details.

Upgrading the config itself is done through the submodule pointer:

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

## Config entry points

| File | Role |
|---|---|
| `config/nvim/init.lua` | entry point, only requires `config.lazy` |
| `config/nvim/lua/config/` | options, key maps, lazy bootstrap, UI |
| `config/nvim/lua/plugins/` | one file per plugin |
| `config/nvim/after/` | filetype overrides |

`lua/config/lazy.lua` sets the leader key (space) and `maplocalleader` (backslash), then calls `require("lazy").setup({ { import = "plugins" } })`.

## Key design decisions

### No distribution

This config is built directly on `lazy.nvim`, not on a distribution like LazyVim/AstroNvim. The benefit is that it's clear why every plugin exists and how it's configured; the cost is that you maintain it yourself.

### Generated key tables, not hand-written

The key tables on the website are generated from the runtime, not written by hand. That way the keys and the actual config are always in sync.

### Documentation as website

The Markdown in `config/nvim/docs/` serves both as GitHub documentation and as the website's content source — one body of content used in two places.

## Integration with dotfiles

| Location | How it connects |
|---|---|
| `dotlink/dotlinkrc` | `config/nvim` → `~/.config/nvim` |
| `aliases.conf` | the `vi` function prefers nvim, `$EDITOR` is set to nvim |
| `config/ranger/rifle.conf` | opens files with `$VISUAL` |
| `plugins/fzf/fzf.zsh` | opens selected files with `nvim` |
| `config/vim/vimrc` | mirrors Neovim's common key maps where practical |

## The maintainer's special case

`dotlink` contains this snippet:

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

If the machine has a `~/nvim` checkout whose origin is this repository, it is linked preferentially instead of the submodule. That lets the maintainer develop directly in `~/nvim` without entering the submodule directory each time.

Regular users don't have that working copy and go through the submodule path.

## Full documentation

The Neovim config has its own website with far more detail than here:

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com) — main entry
- [安装](https://nvim.iamcheyan.com/install.html) — detailed install process
- [插件目录](https://nvim.iamcheyan.com/plugins.html) — notes on every plugin
- [教程](https://nvim.iamcheyan.com/tutorials.html) — starting from the history of vi
- [百科](https://nvim.iamcheyan.com/wiki.html) — concepts like LSP, Treesitter, encoding
- [知识](https://nvim.iamcheyan.com/reference.html) — options, commands, glossary

## Troubleshooting

**`nvim` version below 0.12** — the system package was used. `nvim-update` sets up a user-level install.

**Opens as bare Neovim** — `~/.config/nvim` points at an empty directory. Run `git submodule update --init --recursive`.

**Plugins not installed** — first launch needs network access; lazy.nvim downloads them. Check the `:Lazy` UI.

**Key maps don't match the docs** — the submodule version is behind. Run `git submodule update` to pull the latest.

**Config changes not taking effect** — make sure you're editing `~/nvim` (maintainer) or `config/nvim` (regular user), not the symlink target.

<!-- lang:ja -->

> 要約：Neovim は本リポジトリの主力エディタで、ソースは独立したリポジトリにあり、サブモジュールでバージョンを固定しています。

# Neovim

## 用途

Neovim は本リポジトリのデフォルトエディタです。`$EDITOR`、`$VISUAL`、`vi` 関数、Ranger の `rifle.conf`、fzf の選択アクションが、すべて `nvim` を指しています。

## ソースとバージョン

| 項目 | 説明 |
|---|---|
| ソースリポジトリ | `iamcheyan/nvim`（独立した公開リポジトリ） |
| 本リポジトリ内の場所 | `config/nvim`、git サブモジュール |
| 最低バージョン | 0.12 |
| インストール | `init.sh` がサブモジュールの `init.sh --skip-plugins` を呼び出す |

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

この gitlink が、どのバージョンの Neovim 設定を手に入れるかを決めます。

## なぜ独立リポジトリなのか

Neovim の設定はそれ自体が完全なプロジェクトです。数十個のプラグイン、チュートリアル、百科事典、キーバインド文書、そして独自のサイトがあります。dotfiles の中に置くと、メインリポジトリの維持が難しくなります。

そこで 2 つのリポジトリに分けています：

```text
iamcheyan/dotfiles  ──子模块──▶  iamcheyan/nvim
      │                                │
      ├── zshrc                        ├── lua/plugins/
      ├── aliases.conf                 ├── docs/
      ├── dotlink/                     ├── site/
      └── scripts/                     └── init.sh
```

## インストールの経路

`init.sh` は Neovim を直接インストールせず、サブモジュール自身のインストーラを呼び出します：

```bash
bash "$nvim_init" --skip-plugins
```

`--skip-plugins` は Neovim 本体と依存だけを準備するという意味で、プラグインは初回起動時の lazy.nvim に任せます。プラグインのインストールは完全なランタイムを必要とするため、インストールスクリプトの中で行うと失敗しやすいからです。

## バージョンアップグレード

ローカルの安定版には `nvim-update` を使います：

```bash
nvim-update
```

GitHub の最新安定リリースをダウンロードし、SHA-256 を検証して `~/.local/opt/neovim/<version>` にインストールし、`~/.local/bin/nvim` を原子的に切り替えます。詳細は [nvim-update](../scripts/nvim-update.html) を参照してください。

設定自体のアップグレードはサブモジュールのポインタで行います：

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

## 設定の入り口

| ファイル | 役割 |
|---|---|
| `config/nvim/init.lua` | エントリポイント。`config.lazy` を require するだけ |
| `config/nvim/lua/config/` | オプション、キーマップ、lazy のブートストラップ、UI |
| `config/nvim/lua/plugins/` | プラグインごとに 1 ファイル |
| `config/nvim/after/` | filetype の上書き |

`lua/config/lazy.lua` で leader キー（スペース）と `maplocalleader`（バックスラッシュ）を設定し、`require("lazy").setup({ { import = "plugins" } })` を呼びます。

## 主要な設計

### ディストリビューションを使わない

この設定は LazyVim/AstroNvim のようなディストリビューションではなく、`lazy.nvim` を直接ベースにしています。メリットは各プラグインがなぜ存在し、どう設定されているかが明確なこと。代償は自分で維持することです。

### キーテーブルは生成、手書きではない

サイト上のキーテーブルはランタイムからエクスポートして生成したもので、手書きではありません。キーと実際の設定が常に一致します。

### ドキュメントがそのままサイト

`config/nvim/docs/` の Markdown は GitHub のドキュメントであると同時にサイトのコンテンツソースでもあり、1 つの内容を 2 箇所で使います。

## dotfiles との連携

| 場所 | 連携方法 |
|---|---|
| `dotlink/dotlinkrc` | `config/nvim` → `~/.config/nvim` |
| `aliases.conf` | `vi` 関数は nvim を優先、`$EDITOR` は nvim に設定 |
| `config/ranger/rifle.conf` | `$VISUAL` でファイルを開く |
| `plugins/fzf/fzf.zsh` | 選択したファイルを `nvim` で開く |
| `config/vim/vimrc` | 可能な範囲で Neovim の共通キーマップをミラー |

## メンテナのマシンでの特例

`dotlink` には次の部分があります：

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

このマシンに `~/nvim` があり、その origin がこのリポジトリなら、サブモジュールではなくそちらを優先してリンクします。これでメンテナはサブモジュールのディレクトリに入らずに `~/nvim` で直接開発できます。

通常のユーザーにはこの作業コピーがないので、サブモジュールの経路を使います。

## 完全なドキュメント

Neovim 設定には専用のサイトがあり、ここよりはるかに詳しい：

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com) — 総合入り口
- [安装](https://nvim.iamcheyan.com/install.html) — 詳細なインストール手順
- [插件目录](https://nvim.iamcheyan.com/plugins.html) — 各プラグインの説明
- [教程](https://nvim.iamcheyan.com/tutorials.html) — vi の歴史から始まる解説
- [百科](https://nvim.iamcheyan.com/wiki.html) — LSP、Treesitter、エンコーディングなどの概念
- [知识](https://nvim.iamcheyan.com/reference.html) — オプション、コマンド、用語集

## トラブルシュート

**`nvim` のバージョンが 0.12 未満**：システムパッケージを使っています。`nvim-update` がユーザーレベルのインストールを作ります。

**開くと素の Neovim になる**：`~/.config/nvim` が空のディレクトリを指しています。`git submodule update --init --recursive` を実行します。

**プラグインが入っていない**：初回起動はネットワークが必要で、lazy.nvim がダウンロードします。`:Lazy` 画面を確認します。

**キーマップがドキュメントと違う**：サブモジュールのバージョンが古いです。`git submodule update` で最新にします。

**設定を変えても効かない**：`~/nvim`（メンテナ）か `config/nvim`（通常ユーザー）を編集しているか確認します。シンボリックリンクの先を編集していないか注意してください。
