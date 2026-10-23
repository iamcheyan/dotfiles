> 摘要：这套配置由什么组成，为什么分成六章，以及每一章解决什么问题。

# 本章导读

## 这套配置解决什么问题

它把一台新机器变成可用的终端工作环境：Zsh 作为登录 shell，Zinit 管插件和命令行工具，fzf 系列函数负责文件与目录选择，Starship 画提示符，tmux 管会话，Neovim 作为编辑器。所有可公开复用的部分放在一个仓库里，用 `dotlink` 建立软链接，用 `init.sh` 做初始化。

三个仓库分工明确：

| 仓库 | 负责 |
|---|---|
| `iamcheyan/dotfiles` | 公开的 Zsh、CLI、应用配置、脚本和 dotlink |
| `iamcheyan/nvim` | Neovim 配置本体，作为 `config/nvim` 子模块固定版本 |
| 私有配置（未公开） | 系统包、机器专属编排、Agent、凭据 |

## 六章各自回答什么

1. **开始使用** — 怎么装，装完怎么确认没装坏。
2. **Zsh 与终端** — shell 启动时到底按什么顺序加载了什么。
3. **工具目录** — 每个工具单独一篇：干什么、怎么用、参数、仓库里的配置。
4. **自定义脚本** — 自研的 `dotlink`、`init.sh`、`nvim-update` 等。
5. **应用配置** — 每个配置文件管什么、有哪些键位。
6. **维护与边界** — 更新、检查、私人覆盖，以及什么内容不该进这个仓库。

## 怎么读

想装机器：按 01 章顺序读完，再跳到 04 章看 `dotlink` 的备份行为。

想查某个命令：直接去 03 章，每个工具一篇，左侧侧栏可跳转。

想改配置：先看 02 章的加载顺序，再看 05 章的映射清单，确认改动会在什么时候生效。

## 一条重要的前提

本站所有命令都以仓库里已跟踪的文件为依据。当文档和代码不一致时，以代码为准；发现不一致请在仓库提 issue，而不是照着旧文档操作。

<!-- lang:en -->

> 摘要：What this setup consists of, why it is split into six chapters, and what each chapter answers.

# Chapter guide

## What this setup solves

It turns a fresh machine into a working terminal environment: Zsh as the login shell, Zinit managing plugins and CLI tools, the fzf function family handling file and directory selection, Starship drawing the prompt, tmux managing sessions, and Neovim as the editor. Everything reusable in public lives in one repository, linked into place by `dotlink` and bootstrapped by `init.sh`.

Three repositories divide the work:

| Repository | Owns |
|---|---|
| `iamcheyan/dotfiles` | Public Zsh, CLI, app configs, scripts and dotlink |
| `iamcheyan/nvim` | The Neovim configuration itself, pinned as the `config/nvim` submodule |
| Private setup (unpublished) | System packages, machine-specific orchestration, agents, credentials |

## What each chapter answers

1. **Getting started** — how to install, and how to confirm the install is not broken.
2. **Zsh & terminal** — what actually loads, in what order, when the shell starts.
3. **Tools** — one page per tool: what it does, how to use it, its flags, and how this repo configures it.
4. **Custom scripts** — home-grown `dotlink`, `init.sh`, `nvim-update` and friends.
5. **App configs** — what each config file governs and which keys it binds.
6. **Maintenance & boundaries** — updates, checks, private overrides, and what must never enter this repository.

## How to read this

Setting up a machine: read chapter 01 in order, then jump to chapter 04 for `dotlink`'s backup behaviour.

Looking up a command: go straight to chapter 03; each tool has one page and the left sidebar navigates between them.

Changing a configuration: read the load order in chapter 02 first, then the mapping list in chapter 05, so you know when your change takes effect.

## One important premise

Every command on this site is grounded in files tracked by the repository. When the docs and the code disagree, the code wins; if you spot a mismatch, open an issue instead of following stale docs.

<!-- lang:ja -->

> 摘要：この構成の中身、6 章構成の理由、各章が答える問い。

# 章のガイド

## この構成が解決すること

新しいマシンをそのまま使えるターミナル環境に変えます。Zsh をログインシェルとし、Zinit がプラグインと CLI ツールを管理し、fzf 系関数がファイル・ディレクトリ選択を担い、Starship がプロンプトを描き、tmux がセッションを管理し、Neovim がエディタです。公開して再利用できる部分はすべて 1 つのリポジトリにまとめ、`dotlink` がシンボリックリンクを張り、`init.sh` が初期化します。

3 つのリポジトリで役割を分担します：

| リポジトリ | 担当 |
|---|---|
| `iamcheyan/dotfiles` | 公開する Zsh・CLI・アプリ設定・スクリプト・dotlink |
| `iamcheyan/nvim` | Neovim 設定本体。`config/nvim` サブモジュールとしてバージョン固定 |
| プライベート設定（非公開） | システムパッケージ、マシン固有の編成、エージェント、資格情報 |

## 各章が答えること

1. **はじめに** — インストール方法と、壊れていないことの確認。
2. **Zsh とターミナル** — シェル起動時に何がどの順で読み込まれるか。
3. **ツール** — ツールごとに 1 ページ：役割・使い方・フラグ・このリポジトリでの設定。
4. **自作スクリプト** — 自作の `dotlink`、`init.sh`、`nvim-update` など。
5. **アプリ設定** — 各設定ファイルの管理範囲とキーバインド。
6. **メンテナンス** — 更新・確認・プライベートな上書きと、このリポジトリに入れてはいけないもの。

## 読み方

マシンをセットアップする：01 章を順に読み、04 章で `dotlink` のバックアップ挙動を確認します。

コマンドを調べる：03 章へ直接。ツールごとに 1 ページで、左サイドバーで移動できます。

設定を変える：02 章の読み込み順 → 05 章のマッピング一覧の順に読み、変更がいつ効くかを確認します。

## 大切な前提

このサイトのすべてのコマンドは、リポジトリで追跡されているファイルに基づきます。ドキュメントとコードが食い違う場合はコードが正です。不一致を見つけたら古いドキュメントに従うのではなく、issue を立ててください。
