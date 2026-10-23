> 摘要：dekit 是一个面向开发和生产的进程管理器：在配置文件里定义任务（服务器、数据库、worker），它负责依赖关系、崩溃处理和重启；带 TUI，也提供面向 agent 的 CLI。

# dekit

## 用途

[dekit](https://github.com/pvolok/dekit)（Rust）是一个进程管理器，宣传语是「for dev and prod」。你在一个配置文件里声明项目需要的任务——dev server、数据库、worker——dekit 负责按依赖顺序启动、崩溃后按需重启、不需要时停掉。它有一个附着到任务屏幕的 TUI 控制台，也有一套完整的子命令 CLI（`--json` 输出机器可读结果），因此人和 agent 都能操作。

在本仓库的角色：本地多进程项目的统一启动入口。一个 `dekit up` 替代「开 N 个终端分别起 server 和数据库」。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | [pvolok/dekit](https://github.com/pvolok/dekit)（Rust） |
| 安装器 | `scripts/install/install_dekit.sh`（转调上游 https://dekit.run/install.sh） |
| 二进制 | `~/.local/bin/dekit` |
| 版本 | 0.10.2（本机实测） |

```bash
bash scripts/install/install_dekit.sh
dekit --version    # dekit 0.10.2
```

安装器脚本会先检查 `dekit` 是否已存在，避免重复安装；上游安装器失败时会提示 `npm install -g @dekit/cli` 作为替代。

## 基本用法

```bash
# 在项目根目录初始化配置
dekit init

# 开发：按配置启动全部任务并附着到控制台
dekit dev

# 启动 runner 与已保存/自启的任务（后台常驻）
dekit up
dekit down        # 停 runner，任务保留给下次 up

# 任务管理
dekit ls                      # 列出任务
dekit start <target>          # 启动匹配的任务
dekit stop <target>           # 停止；仍被依赖时会自动重启
dekit veto <target>           # 停止并保持停止，直到再次 start
dekit restart <target>        # 重启
dekit rm <target>             # 移除任务（运行中的会被杀掉）

# 观测
dekit status                  # 运行状态
dekit logs                    # 日志
dekit why <target>            # 解释任务为什么（不）在运行
dekit screen <target>         # 打印任务当前屏幕内容

# 一次性前台任务
dekit run <command>           # 作为任务在前台运行，退出即移除

# agent / 脚本
dekit --json ls               # 机器可读 JSON 输出
dekit attach                  # 把终端附着到任务屏幕（默认是控制台）
```

`<target>` 的语法见 `dekit help targets`；各子命令的详细说明用 `dekit help <command>` 查看。

## 常用命令或键位

### 子命令（来自 `dekit --help`）

| 命令 | 作用 |
|---|---|
| `attach` | 把终端附着到某个任务的屏幕（默认：控制台） |
| `up` | 按需启动 runner，以及已保存和自启的任务 |
| `down` | 停止 runner，任务保留待下次 `up` |
| `spawn` | 在某个路径添加任务并启动 |
| `run` | 前台运行一条命令作为任务；退出即移除 |
| `ls` | 列出任务 |
| `start` | 启动匹配目标的任务 |
| `stop` | 解除固定并停止；仍被依赖的任务会重启 |
| `kill` | 类似 `stop`，但立即硬杀 |
| `veto` | 停止并保持停止，直到再次 start |
| `restart` | 重启匹配目标的任务 |
| `rm` | 移除任务，运行中的会被杀 |
| `why` | 解释任务为什么（不）在运行 |
| `screen` | 打印任务的当前屏幕 |
| `runner` | 管理独立 runner |
| `kernel` | 检查 kernel 选择、管理用户默认值 |
| `update` | 更新 dekit 及运行它的 runner |
| `mprocs` | 运行旧版 mprocs CLI（mprocs.yaml、`--ctl` 等） |
| `help` | 显示文档主题或主题索引 |

### 全局选项

| 选项 | 作用 |
|---|---|
| `-C` / `--chdir` | 显式指定项目根目录（默认：最近的 dekit.yaml、git 仓库或 package.json） |
| `--json` | 输出机器可读 JSON 而不是文本 |

## 本仓库的配置

- 安装通过 `scripts/install/install_dekit.sh`，仓库内不维护 dekit 配置文件本身；每个项目的任务定义（dekit.yaml 等）随项目走，配置写法用 `dekit init` 生成骨架后按上游文档修改。
- 项目根的判定规则：从当前目录向上找最近的 `dekit.yaml`、git 仓库或 `package.json`；嵌套环境里用 `-C` 显式指定。
- `dekit update` 可同时更新 dekit 和它的 runner，不必重跑安装脚本。

## 排错

**`dekit dev` 报找不到项目根**：当前目录向上没有 `dekit.yaml`、git 仓库或 `package.json`。先 `dekit init`，或用 `dekit -C /path/to/project`。

**`stop` 之后任务又自己起来了**：这是设计行为——别的任务还依赖它就会重启。要真正停住用 `veto`。

**任务反复崩溃重启**：先看 `dekit logs` 和 `dekit why`；`why` 会给出任务不在运行（或被拉起）的原因。

**attach 后终端显示错乱**：TUI 程序在 attach 状态下退出不干净所致，`reset` 终端即可。

**装不上**：上游安装器（https://dekit.run/install.sh）需要网络；脚本失败时会提示改用 `npm install -g @dekit/cli`。

<!-- lang:en -->

> Summary: dekit is a process manager for dev and prod: you define tasks (servers, databases, workers) in a config file, and it handles dependencies, crash handling and restarts. It has a TUI plus an agent-friendly CLI.

# dekit

## Purpose

[dekit](https://github.com/pvolok/dekit) (Rust) is a process manager, "for dev and prod". You declare the tasks a project needs — dev server, database, workers — in a config file, and dekit starts them in dependency order, restarts them on crash as needed, and stops them when nothing requires them. It ships a TUI console you can attach to a task's screen, and a full subcommand CLI (with `--json` machine-readable output), so both humans and agents can drive it.

Role in this repository: the single entry point for starting multi-process local projects. One `dekit up` replaces "open N terminals and start the server and the database separately".

## Source and install

| Item | Notes |
|---|---|
| Repository | [pvolok/dekit](https://github.com/pvolok/dekit) (Rust) |
| Installer | `scripts/install/install_dekit.sh` (delegates to the upstream https://dekit.run/install.sh) |
| Binary | `~/.local/bin/dekit` |
| Version | 0.10.2 (verified on this machine) |

```bash
bash scripts/install/install_dekit.sh
dekit --version    # dekit 0.10.2
```

The installer script checks whether `dekit` already exists to avoid reinstalling; if the upstream installer fails, it suggests `npm install -g @dekit/cli` as a fallback.

## Basic usage

```bash
# scaffold the config in a project root
dekit init

# development: start every task from the config and attach to the console
dekit dev

# start the runner plus saved/autostart tasks (stays in the background)
dekit up
dekit down        # stop the runner, keeping tasks for the next up

# task management
dekit ls                      # list tasks
dekit start <target>          # start tasks matching the target
dekit stop <target>           # stop; tasks still needed restart automatically
dekit veto <target>           # stop and keep stopped until started again
dekit restart <target>        # restart
dekit rm <target>             # remove tasks (running ones are killed)

# observation
dekit status                  # runtime status
dekit logs                    # logs
dekit why <target>            # explain why a task is (not) running
dekit screen <target>         # print the task's current screen

# one-off foreground task
dekit run <command>           # run a command as a foreground task; removed on exit

# agents / scripts
dekit --json ls               # machine-readable JSON output
dekit attach                  # attach the terminal to a task's screen (default: console)
```

The `<target>` syntax is documented under `dekit help targets`; each subcommand has a page via `dekit help <command>`.

## Common commands and options

### Subcommands (from `dekit --help`)

| Command | Effect |
|---|---|
| `attach` | attach the terminal to a task's screen (default: the console) |
| `up` | start the runner if needed, plus saved and autostart tasks |
| `down` | stop the runner, keeping tasks for the next `up` |
| `spawn` | add a task at a path and start it |
| `run` | run a command as a foreground task; removed when it exits |
| `ls` | list tasks |
| `start` | start tasks matching a target |
| `stop` | unpin and stop; each restarts if something still needs it |
| `kill` | like `stop`, but with an immediate hard kill |
| `veto` | stop and keep stopped until started again |
| `restart` | restart tasks matching a target |
| `rm` | remove tasks, killing running ones |
| `why` | explain why a task is (not) running |
| `screen` | print the current screen of a task |
| `runner` | manage independent runners |
| `kernel` | inspect kernel selection and manage the user default |
| `update` | update dekit and the runners that run it |
| `mprocs` | run the legacy mprocs CLI (mprocs.yaml, `--ctl`, etc.) |
| `help` | show a documentation topic, or the index of topics |

### Global options

| Option | Effect |
|---|---|
| `-C` / `--chdir` | explicit project root (default: nearest dekit.yaml, git repo, or package.json) |
| `--json` | emit machine-readable JSON instead of text |

## Configuration in this repository

- Installation goes through `scripts/install/install_dekit.sh`; the repo itself keeps no dekit config. Each project's task definitions (dekit.yaml and friends) live with the project — generate a skeleton with `dekit init` and adjust it per upstream docs.
- Project-root detection walks up from the current directory looking for the nearest `dekit.yaml`, git repo, or `package.json`; in nested setups pass `-C` explicitly.
- `dekit update` updates dekit and its runners together, no need to rerun the install script.

## Troubleshooting

**`dekit dev` says no project root found**: nothing upward matches `dekit.yaml`, a git repo, or `package.json`. Run `dekit init` first, or pass `dekit -C /path/to/project`.

**A task restarts right after `stop`**: by design — something still depends on it. Use `veto` to keep it stopped.

**A task keeps crash-looping**: check `dekit logs` and `dekit why`; `why` states why the task is not running (or was pulled back up).

**Terminal is garbled after attach**: a TUI program exited while attached without cleaning up. `reset` the terminal.

**Installation fails**: the upstream installer (https://dekit.run/install.sh) needs network access; on failure the script suggests `npm install -g @dekit/cli`.

<!-- lang:ja -->

> 要約：dekit は開発と本番の両方向けプロセスマネージャです。設定ファイルにタスク（サーバ、データベース、ワーカー）を定義すると、依存関係・クラッシュ処理・再起動を任せられます。TUI を備え、エージェント向けの CLI も提供します。

# dekit

## 役割

[dekit](https://github.com/pvolok/dekit)（Rust）は「for dev and prod」を掲げるプロセスマネージャです。プロジェクトに必要なタスク——開発サーバ、データベース、ワーカー——を設定ファイルに宣言すると、dekit が依存順に起動し、クラッシュ時は必要に応じて再起動し、不要になったら停止します。タスクの画面にアタッチできる TUI コンソールと、`--json` で機械可読出力できる完全なサブコマンド CLI を備えており、人間にもエージェントにも扱えます。

このリポジトリでの役割：マルチプロセスのローカルプロジェクトを統一的に起動する入り口です。「ターミナルを N 個開いてサーバと DB を個別に起動」が `dekit up` 1 回に置き換わります。

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | [pvolok/dekit](https://github.com/pvolok/dekit)（Rust） |
| インストーラ | `scripts/install/install_dekit.sh`（上流 https://dekit.run/install.sh へ委譲） |
| バイナリ | `~/.local/bin/dekit` |
| バージョン | 0.10.2（このマシンで確認） |

```bash
bash scripts/install/install_dekit.sh
dekit --version    # dekit 0.10.2
```

インストーラは `dekit` が既にあるかを先に確認し、重複インストールを避けます。上流インストーラが失敗した場合は `npm install -g @dekit/cli` を代替として案内します。

## 基本的な使い方

```bash
# プロジェクトルートで設定の雛形を作る
dekit init

# 開発：設定どおりに全タスクを起動し、コンソールにアタッチ
dekit dev

# runner と保存済み／自動起動タスクを起動（バックグラウンドで常駐）
dekit up
dekit down        # runner を停止。タスクは次の up のために保持

# タスク管理
dekit ls                      # タスク一覧
dekit start <target>          # 対象に一致するタスクを起動
dekit stop <target>           # 停止。まだ必要とされていれば自動で再起動
dekit veto <target>           # 停止し、再度 start するまで停止を維持
dekit restart <target>        # 再起動
dekit rm <target>             # タスクを削除（実行中なら kill）

# 観測
dekit status                  # 実行状態
dekit logs                    # ログ
dekit why <target>            # タスクが（まだ）動いていない理由を説明
dekit screen <target>         # タスクの現在の画面内容を出力

# 前台での一時タスク
dekit run <command>           # コマンドをフォアグラウンドのタスクとして実行。終了で削除

# エージェント／スクリプト向け
dekit --json ls               # 機械可読な JSON 出力
dekit attach                  # 端末をタスクの画面にアタッチ（既定はコンソール）
```

`<target>` の書式は `dekit help targets`、各サブコマンドの詳細は `dekit help <command>` を参照。

## よく使うコマンドとオプション

### サブコマンド（`dekit --help` より）

| コマンド | 効果 |
|---|---|
| `attach` | 端末をタスクの画面にアタッチ（既定：コンソール） |
| `up` | 必要なら runner を起動し、保存済み・自動起動タスクも起動 |
| `down` | runner を停止。タスクは次の `up` のために保持 |
| `spawn` | パスを指定してタスクを追加し、起動 |
| `run` | コマンドをフォアグラウンドのタスクとして実行。終了で削除 |
| `ls` | タスク一覧 |
| `start` | 対象に一致するタスクを起動 |
| `stop` | 固定を解除して停止。必要とされ続けるタスクは再起動 |
| `kill` | `stop` と同様だが即座にハードキル |
| `veto` | 停止し、再度 start されるまで停止を維持 |
| `restart` | 対象に一致するタスクを再起動 |
| `rm` | タスクを削除。実行中のものは kill |
| `why` | タスクが（まだ）動いていない理由を説明 |
| `screen` | タスクの現在の画面を出力 |
| `runner` | 独立した runner を管理 |
| `kernel` | kernel 選択の確認とユーザーデフォルトの管理 |
| `update` | dekit とそれを動かす runner を更新 |
| `mprocs` | 旧 mprocs CLI を実行（mprocs.yaml、`--ctl` など） |
| `help` | ドキュメントトピックまたはトピック索引を表示 |

### グローバルオプション

| オプション | 効果 |
|---|---|
| `-C` / `--chdir` | プロジェクトルートを明示（既定：直近の dekit.yaml、git リポジトリ、package.json） |
| `--json` | テキストの代わりに機械可読な JSON を出力 |

## このリポジトリでの設定

- インストールは `scripts/install/install_dekit.sh` 経由で、リポジトリ側は dekit の設定ファイル自体を管理しません。各プロジェクトのタスク定義（dekit.yaml など）はプロジェクト側に置きます。`dekit init` で雛形を作り、上流ドキュメントに従って編集します。
- プロジェクトルートの判定は、カレントディレクトリから上へ向かって直近の `dekit.yaml`、git リポジトリ、`package.json` を探します。入れ子環境では `-C` で明示してください。
- `dekit update` で dekit と runner をまとめて更新でき、インストールスクリプトを再実行する必要はありません。

## トラブルシュート

**`dekit dev` がプロジェクトルートが見つからないと警告**：上方向に `dekit.yaml`、git リポジトリ、`package.json` のいずれもない状態です。先に `dekit init` を実行するか、`dekit -C /path/to/project` を指定します。

**`stop` したのにタスクが勝手に復活する**：仕様どおりの動作です。他のタスクがまだ依存していれば再起動されます。本当に止めたい場合は `veto` を使います。

**タスクがクラッシュを繰り返す**：まず `dekit logs` と `dekit why` を見ます。`why` がタスクが動いていない（または持ち上げられた）理由を示します。

**attach の後、端末表示が崩れた**：アタッチ中の TUI プログラムが後片付けせず終了したためです。端末を `reset` すれば戻ります。

**インストールできない**：上流インストーラ（https://dekit.run/install.sh）にはネットワークが必要です。失敗時はスクリプトが `npm install -g @dekit/cli` を案内します。
