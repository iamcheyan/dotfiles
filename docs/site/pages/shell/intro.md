> 摘要：shell 环境由哪些文件组成，为什么按这个顺序读。

# 本章导读

## 组成

Zsh 环境由四层叠起来：

1. **`zshrc`** — 入口。设置选项、推导仓库路径、按顺序 source 其它文件。
2. **`plugins/zsh-plugins.zsh`** — 插件层。Zinit 加载补全、fzf-tab、vi-mode、autosuggestions、forgit、语法高亮。
3. **`plugins/tools/tools.zsh`** — 工具层。用 Zinit 从 GitHub Release 下载 CLI 二进制，并初始化 direnv/atuin。
4. **`plugins/fzf/fzf.zsh`** — 交互层。`f`、`ffd` 两个函数和 `FZF_DEFAULT_OPTS`。

提示符（`plugins/prompt/prompt.zsh`）和补全（`plugins/completion/completion.zsh`）各自独立，在 `zshrc` 里按位置插入。

## 为什么顺序重要

Zsh 插件对加载时机敏感：

- `zsh-completions` 必须在 `compinit` **之前**加载，否则补全定义不生效。
- `fzf-tab` 必须在 `compinit` **之后**加载，否则它拿不到补全系统。
- `zsh-syntax-highlighting` 必须**最后**加载，否则它的 hook 会被后续插件覆盖。
- `zsh-vi-mode` 必须在 `zsh-autosuggestions` 之前，避免按键绑定冲突。

`zsh-plugins.zsh` 用三个函数把这些约束显式化：`zsh_plugins_load_pre_compinit`、`zsh_plugins_load_post_compinit`、`zsh_plugins_load_main`。`zshrc` 在正确的位置调用它们。

## 阅读顺序建议

| 想解决的问题 | 读哪篇 |
|---|---|
| 启动报错、某个命令没定义 | [启动与加载顺序](loading.html) |
| 历史搜索、vi 模式、按键 | [历史与命令行编辑](history.html) |
| Tab 补全不好用 | [补全系统](completion.html) |
| 想加/删插件 | [交互插件](plugins.html) |
| `f` 或 `ffd` 行为不符预期 | [f 与 ffd 函数](fzf-functions.html) |
| Node 版本、npm 命令异常 | [fnm 与 Node 工具链](fnm-node.html) |
| 提示符、终端、tmux | [终端与提示符](terminal.html) |

## 一个原则

shell 配置只做「探测后加载」：几乎所有可选集成都先用 `command -v` 判断命令是否存在。某个工具没装，shell 仍然能正常启动。这条规则在 `plugins/zsh-plugins.zsh` 的 `zsh_plugins_load_shell_tools` 里最明显。
<!-- lang:en -->
> Summary: Which files make up the shell environment, and why they are read in this order.

# Guide to This Chapter

## Composition

The Zsh environment is stacked from four layers:

1. **`zshrc`** — the entry point. Sets options, derives the repo path, and sources the other files in order.
2. **`plugins/zsh-plugins.zsh`** — the plugin layer. Zinit loads completions, fzf-tab, vi-mode, autosuggestions, forgit, and syntax highlighting.
3. **`plugins/tools/tools.zsh`** — the tool layer. Uses Zinit to download CLI binaries from GitHub Releases and initializes direnv/atuin.
4. **`plugins/fzf/fzf.zsh`** — the interactive layer. The two functions `f` and `ffd`, plus `FZF_DEFAULT_OPTS`.

The prompt (`plugins/prompt/prompt.zsh`) and completions (`plugins/completion/completion.zsh`) are each independent and are inserted at their positions in `zshrc`.

## Why order matters

Zsh plugins are sensitive to load timing:

- `zsh-completions` must load **before** `compinit`, otherwise its completion definitions don't take effect.
- `fzf-tab` must load **after** `compinit`, otherwise it can't reach the completion system.
- `zsh-syntax-highlighting` must load **last**, otherwise its hooks get overwritten by later plugins.
- `zsh-vi-mode` must load before `zsh-autosuggestions`, to avoid key-binding conflicts.

`zsh-plugins.zsh` makes these constraints explicit with three functions: `zsh_plugins_load_pre_compinit`, `zsh_plugins_load_post_compinit`, and `zsh_plugins_load_main`. `zshrc` calls them at the right positions.

## Suggested reading order

| What you want to solve | Which page to read |
|---|---|
| Startup errors, a command not defined | [Startup and Load Order](loading.html) |
| History search, vi mode, key bindings | [History and Command-Line Editing](history.html) |
| Tab completion not working | [Completion System](completion.html) |
| Adding/removing plugins | [Interactive Plugins](plugins.html) |
| `f` or `ffd` behaving unexpectedly | [The f and ffd Functions](fzf-functions.html) |
| Node versions, npm command issues | [fnm and the Node Toolchain](fnm-node.html) |
| Prompt, terminal, tmux | [Terminal and Prompt](terminal.html) |

## One principle

The shell config only does "probe, then load": almost every optional integration first uses `command -v` to check whether the command exists. If a tool isn't installed, the shell still starts normally. This rule is most visible in `zsh_plugins_load_shell_tools` in `plugins/zsh-plugins.zsh`.
<!-- lang:ja -->
> 要約：shell 環境を構成するファイルと、その順序で読まれる理由。

# 本章の読み方

## 構成

Zsh 環境は 4 層が積み重なってできています：

1. **`zshrc`** — 入口。オプションの設定、リポジトリパスの導出、他のファイルの順番付き source を行います。
2. **`plugins/zsh-plugins.zsh`** — プラグイン層。Zinit が補完、fzf-tab、vi-mode、autosuggestions、forgit、シンタックスハイライトをロードします。
3. **`plugins/tools/tools.zsh`** — ツール層。Zinit で GitHub Release から CLI バイナリをダウンロードし、direnv/atuin を初期化します。
4. **`plugins/fzf/fzf.zsh`** — インタラクティブ層。`f`、`ffd` の 2 関数と `FZF_DEFAULT_OPTS`。

プロンプト（`plugins/prompt/prompt.zsh`）と補完（`plugins/completion/completion.zsh`）はそれぞれ独立しており、`zshrc` 内の位置に応じて挿入されます。

## なぜ順序が重要か

Zsh プラグインはロードタイミングに敏感です：

- `zsh-completions` は `compinit` の**前**にロードする必要があります。そうしないと補完定義が有効になりません。
- `fzf-tab` は `compinit` の**後**にロードする必要があります。そうしないと補完システムにアクセスできません。
- `zsh-syntax-highlighting` は**最後**にロードする必要があります。そうしないと hook が後続のプラグインに上書きされます。
- `zsh-vi-mode` は `zsh-autosuggestions` の前にロードし、キーバインドの競合を避けます。

`zsh-plugins.zsh` はこれらの制約を 3 つの関数で明示化しています：`zsh_plugins_load_pre_compinit`、`zsh_plugins_load_post_compinit`、`zsh_plugins_load_main`。`zshrc` が正しい位置でそれらを呼び出します。

## 推奨する読む順序

| 解決したいこと | 読むページ |
|---|---|
| 起動時のエラー、コマンドが未定義 | [起動とロード順序](loading.html) |
| 履歴検索、vi モード、キーバインド | [履歴とコマンドライン編集](history.html) |
| Tab 補完が使いにくい | [補完システム](completion.html) |
| プラグインの追加/削除 | [インタラクティブプラグイン](plugins.html) |
| `f` や `ffd` の挙動が期待と違う | [f と ffd 関数](fzf-functions.html) |
| Node バージョン、npm コマンドの異常 | [fnm と Node ツールチェーン](fnm-node.html) |
| プロンプト、ターミナル、tmux | [ターミナルとプロンプト](terminal.html) |

## 一つの原則

shell 設定は「探してからロード」だけを行います。ほぼすべての任意の統合は、先に `command -v` でコマンドの存在を確認します。ツールがインストールされていなくても、shell は正常に起動します。このルールは `plugins/zsh-plugins.zsh` の `zsh_plugins_load_shell_tools` で最も分かりやすいでしょう。
