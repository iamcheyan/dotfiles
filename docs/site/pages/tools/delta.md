> 摘要：delta 是 git diff 的语法高亮分页器，diffnav 的渲染引擎。本仓库不直接配置它，由 diffnav 调用。

# delta

## 用途

`delta` 是 git diff 的语法高亮分页器：按语言高亮 diff、行内显示增删、side-by-side 布局、行号。它本身在管道里工作，输出 ANSI。

本仓库不直接把 delta 当主力工具——它是 [diffnav](diffnav.html) 的渲染引擎。想单独用 delta 时（脚本、管道、cron 输出）直接调命令即可。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `dandavison/delta`（Rust，MIT） |
| 安装器 | `scripts/install/install_delta.sh` |
| 二进制 | `~/.local/bin/delta` |
| 注意 | Debian apt 里的 delta 版本号是 2006 年的伪版本，不要用 apt 装 |

```bash
bash scripts/install/install_delta.sh
```

安装器从 GitHub Release 下载 tarball 装到 `~/.local/bin`；下载失败时回退 apt。

## 基本用法

```bash
git diff | delta                 # 管道高亮
git diff | delta -s              # side-by-side
git -c core.pager=delta diff     # 单次使用
```

## 设为 git 分页器

```bash
git config --global core.pager delta
```

用 diffnav 时不需要这一步（diffnav 自己接管 `pager.diff`）。

<!-- lang:en -->

> Summary: delta is a syntax-highlighting pager for git diffs and the render engine behind diffnav. This repo does not configure it directly; diffnav invokes it.

# delta

## Purpose

`delta` is a syntax-highlighting pager for git diffs: language-aware highlighting, inline add/remove markers, side-by-side layout, line numbers. It works in pipes and emits ANSI.

This repo does not use delta as a primary tool — it is the render engine for [diffnav](diffnav.html). Call it directly when you want delta alone (scripts, pipes, cron output).

## Source and install

| Item | Notes |
|---|---|
| Repository | `dandavison/delta` (Rust, MIT) |
| Installer | `scripts/install/install_delta.sh` |
| Binary | `~/.local/bin/delta` |
| Note | Debian's apt delta package carries a bogus 2006 version string; do not install it via apt |

```bash
bash scripts/install/install_delta.sh
```

The installer downloads the tarball from GitHub Releases into `~/.local/bin`; it falls back to apt if the download fails.

## Basic usage

```bash
git diff | delta                 # piped highlighting
git diff | delta -s              # side-by-side
git -c core.pager=delta diff     # one-off
```

## Set as the git pager

```bash
git config --global core.pager delta
```

Not needed when using diffnav (diffnav takes over `pager.diff` itself).

<!-- lang:ja -->

> Summary: delta は git diff 用のシンタックスハイライトページャーで、diffnav の描画エンジンです。このリポジトリでは直接設定せず、diffnav から呼ばれます。

# delta

## 役割

`delta` は git diff 用のシンタックスハイライトページャーです。言語ごとのハイライト、行内の追加/削除マーク、side-by-side レイアウト、行番号に対応し、パイプで動いて ANSI を出力します。

このリポジトリでは delta を主力ツールとしては使いません。[diffnav](diffnav.html) の描画エンジンとして位置づけます。単体で使いたいとき（スクリプト、パイプ、cron 出力）は直接コマンドを呼びます。

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `dandavison/delta`（Rust、MIT） |
| インストーラ | `scripts/install/install_delta.sh` |
| バイナリ | `~/.local/bin/delta` |
| 注意 | Debian の apt パッケージは 2006 年の偽バージョン番号なので apt では入れない |

```bash
bash scripts/install/install_delta.sh
```

インストーラは GitHub Release から tarball を取得して `~/.local/bin` に置きます。ダウンロードに失敗した場合は apt にフォールバックします。

## 基本的な使い方

```bash
git diff | delta                 # パイプでハイライト
git diff | delta -s              # side-by-side
git -c core.pager=delta diff     # 単発
```

## git ページャーに設定する

```bash
git config --global core.pager delta
```

diffnav を使う場合は不要です（diffnav 自身が `pager.diff` を引き受けます）。
