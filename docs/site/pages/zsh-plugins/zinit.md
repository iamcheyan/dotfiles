> 摘要：Zinit 是本仓库的 Zsh 插件管理器，负责下载、缓存、加载插件和 CLI 二进制。

# Zinit

## 用途

Zinit 管理三类东西：

| 类型 | 例子 | 加载方式 |
|---|---|---|
| Zsh 插件 | fzf-tab、zsh-autosuggestions | `zinit light` |
| 远程脚本 | fzf 的 key-bindings | `zinit snippet` |
| CLI 二进制 | fd、bat、jq | `zinit ice from"gh-r"` + `zinit light` |

它把这些东西缓存到 `~/.zinit/`，之后启动时直接 source，不再联网。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `zdharma-continuum/zinit` |
| 安装位置 | `~/.zinit/bin` |
| 自动安装 | `plugins/zinit/zinit.zsh` 检测不到时自动 clone |

```zsh
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh
```

这段在 `zshrc` 里最先执行，因为后面所有插件都依赖它。

## 核心概念

### ice

`zinit ice` 设置「下一个 `zinit light` 的加载参数」。它只影响紧随其后的一条命令。

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode
```

`lucid` 表示延迟生效，避免插件在加载瞬间改键位。

### light

```zsh
zinit light owner/repo
```

克隆（首次）并 source 插件。这是最常用的形式。

### snippet

```zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

下载单个文件并 source，不需要整个仓库。适合上游提供的独立脚本。

## 本仓库用到的 ice 参数

| 参数 | 作用 | 用在哪 |
|---|---|---|
| `lucid` | 延迟生效，不立即改键位 | zsh-vi-mode |
| `blockf` | 阻止插件把自己的目录加进 `fpath` | zsh-completions |
| `as"completion"` | 声明这是补全脚本 | fzf snippet |
| `as"command"` | 声明这是可执行文件 | 所有 CLI 工具 |
| `from"gh-r"` | 从 GitHub Release 下载 | 所有 CLI 工具 |
| `pick"name"` | 指定解压后取哪个文件 | fd、bat、jq 等 |
| `sbin"name"` | 把二进制放进 Zinit 的 bin 目录 | direnv、fd |
| `mv"src -> dst"` | 解压后重命名/移动 | fd、ripgrep |
| `bpick"pattern"` | 按模式选择 Release 资产 | starship、gitui |

## 本仓库的封装

`plugins/tools/tools.zsh` 顶部定义了一个辅助函数：

```zsh
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}
```

把「下载 GitHub Release 二进制并指定可执行名」压缩成一行：

```zsh
zi_cmd sharkdp/bat bat
```

等价于：

```zsh
zinit ice as"command" from"gh-r" pick"bat"
zinit light sharkdp/bat
```

需要特殊处理（子目录、重命名、多架构）的工具就不用这个封装，直接写完整的 `zinit ice`。

## 常用命令

```zsh
zinit list                  # 已安装的插件和工具
zinit report                # 更详细的状态
zinit update                # 更新全部
zinit update sharkdp/fd     # 更新单个
zinit delete <plugin>       # 删除
zinit self-update           # 更新 Zinit 本体
zinit times                 # 各插件加载耗时
```

`zinit times` 是排查启动慢的入口——它按耗时排序显示每个插件。

## 目录结构

```text
~/.zinit/
├── bin/                    # Zinit 本体
├── plugins/                # 插件与工具
│   ├── zsh-users---zsh-autosuggestions/
│   ├── sharkdp---bat/
│   └── ...
└── snippets/               # snippet 下载的文件
```

目录名把 `owner/repo` 的斜杠换成三个连字符。

## 加载顺序的实际控制

Zinit 本身不保证顺序，顺序由 `zshrc` 里 source 的顺序决定：

```zsh
source plugins/zinit/zinit.zsh
source plugins/zsh-plugins.zsh      # 只定义函数，不加载
source plugins/tools/tools.zsh      # 加载 CLI 工具
zsh_plugins_load_pre_compinit       # zsh-completions
source plugins/completion/completion.zsh
zsh_plugins_load_post_compinit      # fzf-tab
source scripts/setup/setup_fnm.sh
zsh_plugins_load_main               # 其余插件，语法高亮最后
```

`zsh-plugins.zsh` 在第二个位置被 source，但它只定义三个函数，真正加载发生在后面调用函数时。这个设计让「文件位置」和「加载时机」解耦。

## 排错

**`zinit: command not found`**：`~/.zinit/bin/zinit.zsh` 不存在。重新跑 `bash init.sh` 或手动 clone。

**插件没下载**：首次启动需要网络。`zinit list` 看有没有该条目；没有就重启 Zsh 触发。

**更新后命令消失**：上游改了 Release 资产名。`zinit delete <plugin>` 后重新 `zinit light`。

**启动很慢**：`zinit times` 找耗时项。常见是某个插件在同步 clone。

**`--repair` 什么时候用**：插件目录存在但内容不完整（比如 atuin、broot 下载中断）。`bash init.sh --repair` 会重新拉取。

<!-- lang:en -->

> Summary: Zinit is this repository's Zsh plugin manager, responsible for downloading, caching, and loading plugins and CLI binaries.

# Zinit

## Purpose

Zinit manages three kinds of things:

| Type | Examples | How it loads |
|---|---|---|
| Zsh plugins | fzf-tab, zsh-autosuggestions | `zinit light` |
| Remote scripts | fzf's key-bindings | `zinit snippet` |
| CLI binaries | fd, bat, jq | `zinit ice from"gh-r"` + `zinit light` |

It caches these under `~/.zinit/` and afterwards sources them directly at startup, without going online again.

## Origin and Installation

| Item | Details |
|---|---|
| Repository | `zdharma-continuum/zinit` |
| Install location | `~/.zinit/bin` |
| Auto-install | `plugins/zinit/zinit.zsh` clones it automatically when not detected |

```zsh
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh
```

This runs first in `zshrc`, because every plugin afterwards depends on it.

## Core Concepts

### ice

`zinit ice` sets "the load parameters for the next `zinit light`". It only affects the single command immediately after it.

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode
```

`lucid` means deferred effect, preventing the plugin from changing keybindings at the moment it loads.

### light

```zsh
zinit light owner/repo
```

Clones (on first use) and sources the plugin. This is the most common form.

### snippet

```zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

Downloads and sources a single file instead of the whole repository. Suited to standalone scripts provided upstream.

## ice Parameters Used in This Repository

| Parameter | Effect | Used for |
|---|---|---|
| `lucid` | Deferred effect; does not change keybindings immediately | zsh-vi-mode |
| `blockf` | Prevents the plugin from adding its own directory to `fpath` | zsh-completions |
| `as"completion"` | Declares this is a completion script | fzf snippet |
| `as"command"` | Declares this is an executable | All CLI tools |
| `from"gh-r"` | Downloads from a GitHub Release | All CLI tools |
| `pick"name"` | Picks which file to take after extraction | fd, bat, jq, etc. |
| `sbin"name"` | Puts the binary into Zinit's bin directory | direnv, fd |
| `mv"src -> dst"` | Renames/moves after extraction | fd, ripgrep |
| `bpick"pattern"` | Selects Release assets by pattern | starship, gitui |

## This Repository's Wrapper

`plugins/tools/tools.zsh` defines a helper function at the top:

```zsh
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}
```

It compresses "download a GitHub Release binary and assign its executable name" into one line:

```zsh
zi_cmd sharkdp/bat bat
```

which is equivalent to:

```zsh
zinit ice as"command" from"gh-r" pick"bat"
zinit light sharkdp/bat
```

Tools that need special handling (subdirectories, renaming, multi-architecture) do not use this wrapper; write the full `zinit ice` directly.

## Common Commands

```zsh
zinit list                  # 已安装的插件和工具
zinit report                # 更详细的状态
zinit update                # 更新全部
zinit update sharkdp/fd     # 更新单个
zinit delete <plugin>       # 删除
zinit self-update           # 更新 Zinit 本体
zinit times                 # 各插件加载耗时
```

`zinit times` is the entry point for diagnosing slow startup — it lists each plugin sorted by load time.

## Directory Layout

```text
~/.zinit/
├── bin/                    # Zinit 本体
├── plugins/                # 插件与工具
│   ├── zsh-users---zsh-autosuggestions/
│   ├── sharkdp---bat/
│   └── ...
└── snippets/               # snippet 下载的文件
```

Directory names replace the slash in `owner/repo` with three hyphens.

## Actual Control of Load Order

Zinit itself does not guarantee order; the order is determined by the sequence of sources in `zshrc`:

```zsh
source plugins/zinit/zinit.zsh
source plugins/zsh-plugins.zsh      # 只定义函数，不加载
source plugins/tools/tools.zsh      # 加载 CLI 工具
zsh_plugins_load_pre_compinit       # zsh-completions
source plugins/completion/completion.zsh
zsh_plugins_load_post_compinit      # fzf-tab
source scripts/setup/setup_fnm.sh
zsh_plugins_load_main               # 其余插件，语法高亮最后
```

`zsh-plugins.zsh` is sourced in the second position, but it only defines three functions; the actual loading happens later when the functions are called. This design decouples "file position" from "load timing".

## Troubleshooting

**`zinit: command not found`**: `~/.zinit/bin/zinit.zsh` does not exist. Re-run `bash init.sh` or clone it manually.

**A plugin was not downloaded**: first startup requires network. Check `zinit list` for the entry; if absent, restart Zsh to trigger it.

**Commands disappear after an update**: upstream renamed the Release assets. After `zinit delete <plugin>`, run `zinit light` again.

**Startup is very slow**: use `zinit times` to find the slow items. A common cause is some plugin cloning synchronously.

**When to use `--repair`**: the plugin directory exists but its contents are incomplete (e.g. atuin or broot downloads were interrupted). `bash init.sh --repair` re-fetches them.

<!-- lang:ja -->

> 要約：Zinit は本リポジトリの Zsh プラグインマネージャーで、プラグインと CLI バイナリのダウンロード・キャッシュ・読み込みを担当します。

# Zinit

## 用途

Zinit が管理するのは三種類です：

| 種類 | 例 | 読み込み方法 |
|---|---|---|
| Zsh プラグイン | fzf-tab、zsh-autosuggestions | `zinit light` |
| リモートスクリプト | fzf の key-bindings | `zinit snippet` |
| CLI バイナリ | fd、bat、jq | `zinit ice from"gh-r"` + `zinit light` |

これらを `~/.zinit/` にキャッシュし、以降の起動では直接 source して、再びネットワークに取りに行きません。

## 出所とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `zdharma-continuum/zinit` |
| インストール先 | `~/.zinit/bin` |
| 自動インストール | `plugins/zinit/zinit.zsh` が検出できなければ自動で clone |

```zsh
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh
```

この部分は `zshrc` 内で最初に実行されます。後続のすべてのプラグインがこれに依存しているためです。

## 基本概念

### ice

`zinit ice` は「次の `zinit light` の読み込みパラメータ」を設定します。直後の 1 コマンドにのみ影響します。

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode
```

`lucid` は効果の発現を遅らせ、プラグインが読み込まれた瞬間にキーバインドを変更しないようにします。

### light

```zsh
zinit light owner/repo
```

クローン（初回）してプラグインを source します。最もよく使う形式です。

### snippet

```zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

単一ファイルをダウンロードして source します。リポジトリ全体は不要です。上流が提供する独立したスクリプトに向いています。

## 本リポジトリで使っている ice パラメータ

| パラメータ | 効果 | 使い先 |
|---|---|---|
| `lucid` | 効果を遅らせ、すぐにキーバインドを変えない | zsh-vi-mode |
| `blockf` | プラグインが自分のディレクトリを `fpath` に加えるのを防ぐ | zsh-completions |
| `as"completion"` | 補完スクリプトであると宣言 | fzf snippet |
| `as"command"` | 実行ファイルであると宣言 | すべての CLI ツール |
| `from"gh-r"` | GitHub Release からダウンロード | すべての CLI ツール |
| `pick"name"` | 展開後にどのファイルを取るか指定 | fd、bat、jq など |
| `sbin"name"` | バイナリを Zinit の bin ディレクトリに置く | direnv、fd |
| `mv"src -> dst"` | 展開後にリネーム/移動 | fd、ripgrep |
| `bpick"pattern"` | パターンで Release アセットを選ぶ | starship、gitui |

## 本リポジトリのラッパー

`plugins/tools/tools.zsh` の先頭で補助関数を定義しています：

```zsh
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}
```

「GitHub Release のバイナリをダウンロードして実行名を指定する」処理を 1 行に圧縮します：

```zsh
zi_cmd sharkdp/bat bat
```

これは次と等価です：

```zsh
zinit ice as"command" from"gh-r" pick"bat"
zinit light sharkdp/bat
```

特殊な処理（サブディレクトリ、リネーム、マルチアーキテクチャ）が必要なツールはこのラッパーを使わず、完全な `zinit ice` を直接書きます。

## よく使うコマンド

```zsh
zinit list                  # 已安装的插件和工具
zinit report                # 更详细的状态
zinit update                # 更新全部
zinit update sharkdp/fd     # 更新单个
zinit delete <plugin>       # 删除
zinit self-update           # 更新 Zinit 本体
zinit times                 # 各插件加载耗时
```

`zinit times` は起動が遅い問題の入り口です。読み込み時間でソートして各プラグインを表示します。

## ディレクトリ構成

```text
~/.zinit/
├── bin/                    # Zinit 本体
├── plugins/                # 插件与工具
│   ├── zsh-users---zsh-autosuggestions/
│   ├── sharkdp---bat/
│   └── ...
└── snippets/               # snippet 下载的文件
```

ディレクトリ名は `owner/repo` のスラッシュを三つのハイフンに置き換えたものです。

## 読み込み順序の実際の制御

Zinit 自体は順序を保証しません。順序は `zshrc` 内で source する順番で決まります：

```zsh
source plugins/zinit/zinit.zsh
source plugins/zsh-plugins.zsh      # 只定义函数，不加载
source plugins/tools/tools.zsh      # 加载 CLI 工具
zsh_plugins_load_pre_compinit       # zsh-completions
source plugins/completion/completion.zsh
zsh_plugins_load_post_compinit      # fzf-tab
source scripts/setup/setup_fnm.sh
zsh_plugins_load_main               # 其余插件，语法高亮最后
```

`zsh-plugins.zsh` は 2 番目の位置で source されますが、関数を三つ定義するだけで、実際の読み込みは後で関数を呼ぶときに起こります。この設計により「ファイルの位置」と「読み込みのタイミング」が分離されています。

## トラブルシューティング

**`zinit: command not found`**：`~/.zinit/bin/zinit.zsh` が存在しません。`bash init.sh` を再実行するか、手動で clone します。

**プラグインがダウンロードされない**：初回起動にはネットワークが必要です。`zinit list` で該当エントリを確認し、なければ Zsh を再起動して発生させます。

**更新後にコマンドが消えた**：上流が Release アセット名を変えています。`zinit delete <plugin>` の後、`zinit light` をやり直します。

**起動がとても遅い**：`zinit times` で時間のかかる項目を探します。あるプラグインが同期 clone しているのが定番の原因です。

**`--repair` を使うとき**：プラグインディレクトリはあるが中身が不完全な場合（たとえば atuin や broot のダウンロード中断）。`bash init.sh --repair` が再取得します。
