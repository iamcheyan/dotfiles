> 摘要：本章收录常用 Linux 命令的用法，并逐条说明它们在这台 Debian 13 工作机和这套 dotfiles 配置下实际怎么用。

# Linux 命令手册

## 这份手册解决什么问题

网上的命令教程默认你用的是原生 Bash、系统 `ls`/`cat`/`grep`、刚装好的发行版。这套环境不是：

- 发行版是 **Debian 13（trixie）**，跑在 PVE 的虚拟机里，没有物理显示器，桌面是 Xvnc + Xfce 的远程会话。
- Shell 是 **Zsh**，加载 zinit、补全、fzf 和一套别名；很多命令的行为被这套配置改过（`l` 不是 `ls`，`f` 不是 `find`）。
- 大量 GNU 工具被现代替代品接管：`eza` 替代 `ls`、`fd` 替代 `find`、`ripgrep` 替代 `grep`、`bat` 替代 `cat`、`zoxide` 替代 `cd`、`btop` 替代 `top`。
- 另一台常打交道的机器是 **NixOS**（HX90），包管理和服务命令和 Debian 完全不同。

所以本手册每条命令都回答三个问题：**这个命令干什么**、**常用法是什么**、**在这套环境下有什么不同**。

## 阅读方式

| 你的需求 | 去读 |
|---|---|
| 复制、移动、删除、看文件 | [文件与目录](files.html) |
| 看内容、改文本、统计 | [文本处理](text.html) |
| 找文件、搜内容 | [查找](search.html) |
| 看进程、杀进程、后台任务 | [进程与作业](process.html) |
| chmod、sudo、文件归属 | [权限与提权](permissions.html) |
| 磁盘满了、挂载 NAS | [磁盘与挂载](disk.html) |
| IP、端口、下载、传文件 | [网络与传输](network.html) |
| 看系统状态、查日志 | [系统信息与日志](system.html) |
| 装软件（apt / pacman / nix） | [软件包管理](packages.html) |
| tar、zip、压缩 | [压缩与归档](archives.html) |
| 本机特有的操作（gh、tmux、桌面） | [本机环境实战](our-environment.html) |
| 忘了参数，快速查 | [速查表](cheatsheet.html) |

## 三条通用习惯

**1. 先看帮助再动手。** `命令 --help` 是速查，`man 命令` 是完整手册。本机 `man` 分页器是 `less`，`/关键词` 搜索，`q` 退出。

**2. 管道是 Linux 的灵魂。** 一个命令的输出是下一个命令的输入：

```bash
rg -l 'TODO' ~/dotfiles | head -5        # 找含 TODO 的文件，看前 5 个
```

**3. 破坏性操作先确认路径。** `rm -rf`、`dd`、`mkfs`、`chmod -R` 这类命令执行前没有第二次机会。本手册在每篇的排错小节里标注了本机踩过的坑。

## 命令在哪个 shell 里跑

| 场景 | 说明 |
|---|---|
| 普通终端 | Zsh，本手册所有别名和函数都在这里生效 |
| tmux 内 | 同一个 Zsh，但剪贴板走 OSC 52，见 [本机环境实战](our-environment.html) |
| SSH 登录 | 同样加载 Zsh 配置（登录 shell 读 `.zshrc`） |
| 远程工作区 | 命令在远端机器上执行，本机别名不一定存在 |
| 脚本里（`#!/bin/bash`） | 没有别名，必须写完整命令 |

最后一条经常咬人：`init.sh` 和 cron 里的脚本是 `#!/usr/bin/env bash`，**别名不生效**。写脚本时不要依赖 `l`、`ll`、`f` 这些别名。

<!-- lang:en -->

> Summary: This chapter collects the usage of common Linux commands and explains, command by command, how they are actually used on this Debian 13 workstation with this dotfiles setup.

# Linux Command Handbook

## What this handbook solves

Command tutorials on the web assume you are on stock Bash, the system's `ls`/`cat`/`grep`, and a freshly installed distro. This environment is not that:

- The distro is **Debian 13 (trixie)**, running as a PVE VM with no physical display; the desktop is a remote Xvnc + Xfce session.
- The shell is **Zsh**, loading zinit, completions, fzf, and a set of aliases; the behavior of many commands has been changed by this setup (`l` is not `ls`, `f` is not `find`).
- Many GNU tools have been taken over by modern replacements: `eza` replaces `ls`, `fd` replaces `find`, `ripgrep` replaces `grep`, `bat` replaces `cat`, `zoxide` replaces `cd`, `btop` replaces `top`.
- The other machine we deal with often is **NixOS** (HX90), whose package management and service commands differ completely from Debian.

So for every command, this handbook answers three questions: **what the command does**, **what the common usage is**, and **what differs in this environment**.

## How to read this

| What you need | Go read |
|---|---|
| Copy, move, delete, view files | [Files and Directories](files.html) |
| View, edit, count text | [Text Processing](text.html) |
| Find files, search content | [Search](search.html) |
| View/kill processes, background jobs | [Processes and Jobs](process.html) |
| chmod, sudo, file ownership | [Permissions and Privilege Escalation](permissions.html) |
| Disk full, mounting the NAS | [Disks and Mounting](disk.html) |
| IP, ports, downloads, file transfer | [Network and Transfer](network.html) |
| System status, logs | [System Info and Logs](system.html) |
| Install software (apt / pacman / nix) | [Package Management](packages.html) |
| tar, zip, compression | [Compression and Archiving](archives.html) |
| Machine-specific operations (gh, tmux, desktop) | [Our Environment in Practice](our-environment.html) |
| Forgot the flags, quick lookup | [Cheatsheet](cheatsheet.html) |

## Three universal habits

**1. Read the help before acting.** `command --help` is the quick reference; `man command` is the full manual. On this machine the `man` pager is `less`: `/keyword` to search, `q` to quit.

**2. Pipes are the soul of Linux.** One command's output is the next command's input:

```bash
rg -l 'TODO' ~/dotfiles | head -5        # 找含 TODO 的文件，看前 5 个
```

**3. Confirm the path before destructive operations.** Commands like `rm -rf`, `dd`, `mkfs`, and `chmod -R` offer no second chance. The troubleshooting section of each page notes the pitfalls this machine has actually hit.

## Which shell a command runs in

| Scenario | Notes |
|---|---|
| Normal terminal | Zsh; all the aliases and functions in this handbook apply here |
| Inside tmux | Same Zsh, but the clipboard goes through OSC 52; see [Our Environment in Practice](our-environment.html) |
| SSH login | The Zsh config is loaded as well (login shells read `.zshrc`) |
| Remote workspace | Commands execute on the remote machine; local aliases may not exist |
| In scripts (`#!/bin/bash`) | No aliases; write the full commands |

The last row bites often: the scripts in `init.sh` and cron are `#!/usr/bin/env bash`, so **aliases do not work**. Do not rely on aliases like `l`, `ll`, or `f` when writing scripts.

<!-- lang:ja -->

> 摘要：本章ではよく使う Linux コマンドの使い方を集め、この Debian 13 ワークステーションとこの dotfiles 構成のもとで実際にどう使うかを 1 つずつ説明します。

# Linux コマンドハンドブック

## このハンドブックが解決すること

ウェブ上のコマンドチュートリアルは、素の Bash・システム標準の `ls`/`cat`/`grep`・インストールしたてのディストロを想定しています。この環境は違います：

- ディストロは **Debian 13（trixie）**。PVE の仮想マシンで動き、物理ディスプレイはなく、デスクトップは Xvnc + Xfce のリモートセッションです。
- シェルは **Zsh**。zinit、補完、fzf、一式のエイリアスを読み込みます。多くのコマンドの挙動がこの設定で変更されています（`l` は `ls` ではない、`f` は `find` ではない）。
- 多くの GNU ツールはモダンな代替に置き換えられています：`eza` が `ls` を、`fd` が `find` を、`ripgrep` が `grep` を、`bat` が `cat` を、`zoxide` が `cd` を、`btop` が `top` を置き換えます。
- よく一緒に使うもう 1 台のマシンは **NixOS**（HX90）で、パッケージ管理やサービスのコマンドは Debian とまったく違います。

そこでこのハンドブックは、すべてのコマンドに対して 3 つの問いに答えます：**このコマンドは何をするか**、**定番の使い方は何か**、**この環境では何が違うか**。

## 読み方

| やりたいこと | 参照先 |
|---|---|
| コピー・移動・削除・ファイル表示 | [ファイルとディレクトリ](files.html) |
| 表示・編集・集計 | [テキスト処理](text.html) |
| ファイル検索・内容検索 | [検索](search.html) |
| プロセス表示・終了・バックグラウンドジョブ | [プロセスとジョブ](process.html) |
| chmod・sudo・ファイル所有権 | [パーミッションと権限昇格](permissions.html) |
| ディスク満杯・NAS マウント | [ディスクとマウント](disk.html) |
| IP・ポート・ダウンロード・ファイル転送 | [ネットワークと転送](network.html) |
| システム状態・ログ | [システム情報とログ](system.html) |
| ソフトウェア導入（apt / pacman / nix） | [パッケージ管理](packages.html) |
| tar・zip・圧縮 | [圧縮とアーカイブ](archives.html) |
| 本機固有の操作（gh・tmux・デスクトップ） | [本機環境の実践](our-environment.html) |
| オプションを忘れた、手早く調べたい | [速査表](cheatsheet.html) |

## 三つの普遍的な習慣

**1. 手を動かす前にヘルプを読む。** `コマンド --help` が速査、`man コマンド` が完全なマニュアルです。本機の `man` ページャは `less` で、`/キーワード` で検索、`q` で終了します。

**2. パイプは Linux の魂です。** あるコマンドの出力が次のコマンドの入力になります：

```bash
rg -l 'TODO' ~/dotfiles | head -5        # 找含 TODO 的文件，看前 5 个
```

**3. 破壊的操作の前にパスを確認する。** `rm -rf`、`dd`、`mkfs`、`chmod -R` といったコマンドに 2 度目のチャンスはありません。各ページのトラブルシューティング節には、本機が実際に踏んだ落とし穴を記録してあります。

## コマンドはどのシェルで動くか

| シナリオ | 説明 |
|---|---|
| 普通のターミナル | Zsh。このハンドブックのすべてのエイリアスと関数はここで有効 |
| tmux 内 | 同じ Zsh。ただしクリップボードは OSC 52 経由。[本機環境の実践](our-environment.html) を参照 |
| SSH ログイン | 同様に Zsh 設定を読み込む（ログインシェルは `.zshrc` を読む） |
| リモートワークスペース | コマンドは遠隔マシンで実行され、ローカルのエイリアスは存在しないことも |
| スクリプト内（`#!/bin/bash`） | エイリアスなし。完全なコマンドを書くこと |

最後の行はよく人を咬みます：`init.sh` や cron 内のスクリプトは `#!/usr/bin/env bash` で、**エイリアスは効きません**。スクリプトを書くときは `l`、`ll`、`f` といったエイリアスに頼らないでください。
