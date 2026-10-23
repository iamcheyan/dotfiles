> 摘要：Fresh 是终端文本编辑器，本仓库用 fr 别名启动，init.sh 按平台安装。

# Fresh

## 用途

Fresh 是一个终端里的文本编辑器，特点是有多光标、内置插件系统和 TS 配置。它和 Neovim 定位重叠，但交互更接近现代编辑器。

本仓库把它作为可选编辑器：`init.sh` 按平台安装，`aliases.conf` 提供 `fr` 别名。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | init.sh 的 `install_fresh` 步骤 |
| Linux/WSL | 官方 universal installer |
| macOS | Homebrew |
| Windows | winget |
| NixOS | 由系统配置的 `fresh-editor` 包管理 |

```zsh
alias fr="fresh"
```

## 基本用法

```bash
fr                    # 打开空缓冲区
fr file.txt           # 打开文件
fr file.txt:42        # 跳到第 42 行
fr file.txt:42:8      # 跳到第 42 行第 8 列
fr .                  # 打开目录
```

位置参数支持 `文件:行:列` 语法，方便从编译器错误输出直接跳转。

## 常用参数

| 参数 | 作用 |
|---|---|
| `--config <PATH>` | 指定配置文件 |
| `--no-init` | 不加载 `~/.config/fresh/init.ts` |
| `--no-plugins` | 禁用所有插件 |
| `--safe` | 安全模式：不加载 init 和插件，用于从错误配置中恢复 |
| `--stdin` | 从标准输入读取内容 |
| `-a` / `--attach [NAME]` | 连接到守护进程 |
| `--locale <CODE>` | 界面语言，如 `zh-CN`、`ja` |
| `--skill[=TOPIC]` | 显示操作指南 |

## 配置文件

主配置在 `~/.config/fresh/init.ts`，用 TypeScript 写：

```typescript
// 示例
export default {
  theme: "dark",
  lineNumbers: true,
  tabSize: 2,
};
```

本仓库**没有**提供 Fresh 配置文件——它属于可选工具，配置因人而异。

`--safe` 在配置写坏时救命：

```bash
fr --safe
```

跳过 init 和插件，直接进编辑器，然后修配置。

## 守护进程模式

```bash
fr -a                 # 连接到当前目录的守护进程
fr -a myproject       # 连接到命名守护进程
fr --cmd daemon list  # 列出运行中的守护进程
fr --cmd daemon kill  # 结束
```

守护进程模式让多个窗口共享同一个编辑器实例，打开文件更快。

## 界面语言

```bash
fr --locale zh-CN
fr --locale ja
fr --locale en
```

## 学习指南

```bash
fr --skill            # 交互式指南
fr --skill=tour       # 功能巡览
fr --skill=plugin     # 插件开发
```

这比读文档快——直接在编辑器里演示功能。

## 与 Neovim 的关系

| | Neovim | Fresh |
|---|---|---|
| 配置 | Lua | TypeScript |
| 生态 | 极大 | 小 |
| 键位 | Vim 模式 | 现代编辑器键位 |
| 多光标 | 需插件 | 内置 |
| 定位 | 主力编辑器 | 备选/轻量场景 |

本仓库的主力编辑器是 Neovim。Fresh 是「想换个手感」或「Neovim 出问题时」的备选。

## 排错

**`fr: command not found`**：init.sh 的 `install_fresh` 失败，或不在 PATH。检查 `~/.local/bin/fresh`。

**启动报配置错误**：`fr --safe` 进入安全模式，然后修 `init.ts`。

**界面是英文**：加 `--locale zh-CN`，或在配置里设默认语言。

**插件不加载**：`--no-plugins` 是否被误用？或插件目录损坏，试 `fr --safe`。

**NixOS 上找不到**：NixOS 不执行独立安装，需要在系统配置里加 `fresh-editor` 包。

<!-- lang:en -->

> Summary: Fresh is a terminal text editor; this repo launches it with the fr alias and init.sh installs it per platform.

# Fresh

## Purpose

Fresh is a text editor in the terminal, characterized by multiple cursors, a built-in plugin system, and TypeScript configuration. It overlaps with Neovim in positioning, but its interaction is closer to modern editors.

This repo treats it as an optional editor: `init.sh` installs it per platform, and `aliases.conf` provides the `fr` alias.

## Source and Installation

| Item | Description |
|---|---|
| Source | The `install_fresh` step of init.sh |
| Linux/WSL | Official universal installer |
| macOS | Homebrew |
| Windows | winget |
| NixOS | Managed by the `fresh-editor` package in the system configuration |

```zsh
alias fr="fresh"
```

## Basic usage

```bash
fr                    # 打开空缓冲区
fr file.txt           # 打开文件
fr file.txt:42        # 跳到第 42 行
fr file.txt:42:8      # 跳到第 42 行第 8 列
fr .                  # 打开目录
```

Positional arguments support the `file:line:column` syntax, making it easy to jump straight from compiler error output.

## Common options

| Option | Purpose |
|---|---|
| `--config <PATH>` | Specify a config file |
| `--no-init` | Do not load `~/.config/fresh/init.ts` |
| `--no-plugins` | Disable all plugins |
| `--safe` | Safe mode: load no init or plugins, for recovering from a broken config |
| `--stdin` | Read content from standard input |
| `-a` / `--attach [NAME]` | Attach to a daemon |
| `--locale <CODE>` | UI language, e.g. `zh-CN`, `ja` |
| `--skill[=TOPIC]` | Show operation guides |

## Config file

The main configuration is `~/.config/fresh/init.ts`, written in TypeScript:

```typescript
// 示例
export default {
  theme: "dark",
  lineNumbers: true,
  tabSize: 2,
};
```

This repo does **not** ship a Fresh config file — it is an optional tool and configuration is a personal matter.

`--safe` saves you when the config is broken:

```bash
fr --safe
```

It skips init and plugins and opens the editor directly; then you fix the config.

## Daemon mode

```bash
fr -a                 # 连接到当前目录的守护进程
fr -a myproject       # 连接到命名守护进程
fr --cmd daemon list  # 列出运行中的守护进程
fr --cmd daemon kill  # 结束
```

Daemon mode lets multiple windows share a single editor instance, so files open faster.

## UI language

```bash
fr --locale zh-CN
fr --locale ja
fr --locale en
```

## Learning guides

```bash
fr --skill            # 交互式指南
fr --skill=tour       # 功能巡览
fr --skill=plugin     # 插件开发
```

This is faster than reading docs — the features are demonstrated right inside the editor.

## Relationship with Neovim

| | Neovim | Fresh |
|---|---|---|
| Config | Lua | TypeScript |
| Ecosystem | Very large | Small |
| Keybindings | Vim mode | Modern editor keybindings |
| Multiple cursors | Plugin required | Built-in |
| Positioning | Primary editor | Backup / lightweight scenarios |

This repo's primary editor is Neovim. Fresh is the fallback for "when you want a different feel" or "when Neovim is misbehaving."

## Troubleshooting

**`fr: command not found`**: init.sh's `install_fresh` failed, or it is not in PATH. Check `~/.local/bin/fresh`.

**A config error appears on startup**: enter safe mode with `fr --safe`, then fix `init.ts`.

**The UI is in English**: add `--locale zh-CN`, or set the default language in the config.

**Plugins do not load**: is `--no-plugins` being used by mistake? Or the plugin directory is broken — try `fr --safe`.

**Not found on NixOS**: NixOS does not perform a standalone install; you need to add the `fresh-editor` package in the system configuration.

<!-- lang:ja -->

> 要約：Fresh はターミナルのテキストエディタで、本リポジトリでは fr エイリアスで起動し、init.sh がプラットフォームごとにインストールします。

# Fresh

## 用途

Fresh はターミナル上のテキストエディタで、マルチカーソル、組み込みプラグインシステム、TS 設定が特徴です。Neovim と立ち位置は重なりますが、操作感はモダンなエディタに近いものです。

本リポジトリではオプションのエディタとして扱います。`init.sh` がプラットフォームごとにインストールし、`aliases.conf` が `fr` エイリアスを提供します。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | init.sh の `install_fresh` ステップ |
| Linux/WSL | 公式 universal installer |
| macOS | Homebrew |
| Windows | winget |
| NixOS | システム設定の `fresh-editor` パッケージで管理 |

```zsh
alias fr="fresh"
```

## 基本的な使い方

```bash
fr                    # 打开空缓冲区
fr file.txt           # 打开文件
fr file.txt:42        # 跳到第 42 行
fr file.txt:42:8      # 跳到第 42 行第 8 列
fr .                  # 打开目录
```

位置引数は `ファイル:行:列` 構文に対応しており、コンパイラのエラー出力から直接ジャンプするのに便利です。

## よく使うオプション

| オプション | 役割 |
|---|---|
| `--config <PATH>` | 設定ファイルを指定 |
| `--no-init` | `~/.config/fresh/init.ts` を読み込まない |
| `--no-plugins` | すべてのプラグインを無効化 |
| `--safe` | セーフモード。init とプラグインを読み込まず、壊れた設定からの復旧に使う |
| `--stdin` | 標準入力から内容を読む |
| `-a` / `--attach [NAME]` | デーモンに接続 |
| `--locale <CODE>` | UI 言語。例：`zh-CN`、`ja` |
| `--skill[=TOPIC]` | 操作ガイドを表示 |

## 設定ファイル

メインの設定は `~/.config/fresh/init.ts` で、TypeScript で書きます：

```typescript
// 示例
export default {
  theme: "dark",
  lineNumbers: true,
  tabSize: 2,
};
```

本リポジトリは Fresh の設定ファイルを提供**していません**。オプションのツールであり、設定は人それぞれだからです。

設定を壊したときの命綱が `--safe` です：

```bash
fr --safe
```

init とプラグインをスキップしてエディタに入り、その後で設定を直します。

## デーモンモード

```bash
fr -a                 # 连接到当前目录的守护进程
fr -a myproject       # 连接到命名守护进程
fr --cmd daemon list  # 列出运行中的守护进程
fr --cmd daemon kill  # 结束
```

デーモンモードでは複数のウィンドウが同じエディタインスタンスを共有し、ファイルを開くのが速くなります。

## UI 言語

```bash
fr --locale zh-CN
fr --locale ja
fr --locale en
```

## 学習ガイド

```bash
fr --skill            # 交互式指南
fr --skill=tour       # 功能巡览
fr --skill=plugin     # 插件开发
```

ドキュメントを読むより速い方法です。機能をエディタ内で直接デモしてくれます。

## Neovim との関係

| | Neovim | Fresh |
|---|---|---|
| 設定 | Lua | TypeScript |
| エコシステム | 非常に大きい | 小さい |
| キーバインド | Vim モード | モダンエディタ方式 |
| マルチカーソル | プラグインが必要 | 組み込み |
| 立ち位置 | メインエディタ | 予備/軽量用途 |

本リポジトリのメインエディタは Neovim です。Fresh は「気分を変えたいとき」や「Neovim が不調なとき」の予備です。

## トラブルシューティング

**`fr: command not found`**：init.sh の `install_fresh` が失敗したか、PATH にありません。`~/.local/bin/fresh` を確認してください。

**起動時に設定エラーが出る**：`fr --safe` でセーフモードに入り、その後 `init.ts` を修正します。

**UI が英語のままである**：`--locale zh-CN` を付けるか、設定でデフォルト言語を指定します。

**プラグインが読み込まれない**：`--no-plugins` を誤用していませんか？それともプラグインディレクトリが壊れています。`fr --safe` を試してください。

**NixOS で見つからない**：NixOS では単独インストールを行わず、システム設定に `fresh-editor` パッケージを追加する必要があります。
