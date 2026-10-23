> 摘要：topgrade 一条命令升级所有东西：检测 apt、snap、flatpak、npm、pipx、cargo、rustup、brew 等包管理器并逐一执行升级；本仓库用它做定期全量更新。默认会跑 `sudo apt upgrade`，先试 `--dry-run`。

# topgrade

## 用途

[topgrade](https://github.com/topgrade-rs/topgrade)（Rust）的口号是「Upgrade all the things」。它检测系统里存在的包管理器和工具——apt、snap、flatpak、npm、pipx、cargo、rustup、brew 等——然后在一个会话里依次对每一个执行升级，省去逐个手跑的麻烦。检测不到的步骤自动跳过；`--only`/`--disable` 可以精确圈定范围。

在本仓库的角色：定期全系统更新。与文档站的 maintenance 章节配合，作为「把本机所有东西升到最新」的标准入口。也可以用 `--only dotfiles` 之类的用法把本仓库自身的更新纳入同一次流程。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | [topgrade-rs/topgrade](https://github.com/topgrade-rs/topgrade)（Rust） |
| 安装器 | `scripts/install/install_topgrade.sh`（从 GitHub Releases 下载预编译包） |
| 二进制 | `~/.local/bin/topgrade` |
| 版本 | 17.14.1（本机实测） |

```bash
bash scripts/install/install_topgrade.sh
topgrade --version    # topgrade 17.14.1
```

安装器按 uname 判断 x86_64/aarch64，查询 GitHub Releases 最新 tag 后下载对应的 `topgrade-<版本>-<arch>-unknown-linux-gnu.tar.gz`，解出二进制放进 `~/.local/bin`。

## 基本用法

```bash
# 第一次先看它会做什么（强烈建议）
topgrade --dry-run

# 全量升级（会跑 sudo apt upgrade 等，需要输密码）
topgrade

# 只跑指定步骤 / 排除指定步骤
topgrade --only system snap flatpak
topgrade --disable brew_cask gem

# 对确认提示一律回答 yes（脚本化）
topgrade -y

# 干完后顺便清理临时/旧文件
topgrade --cleanup

# 编辑配置文件 / 查看配置参考
topgrade --edit-config
topgrade --config-reference

# 在 tmux 里跑，断开 SSH 也不中断
topgrade -t
```

## 常用命令或键位

### 常用选项（来自 `topgrade --help`）

| 选项 | 作用 |
|---|---|
| `-n` / `--dry-run` | 只打印将执行的命令，不实际执行 |
| `--only <STEP>...` | 只执行指定步骤（如 `system`、`snap`、`flatpak`、`npm`、`pipx`、`cargo`、`rustup`、`node`、`dotfiles` 用 `yadm`、`git_repos` 等） |
| `--disable <STEP>...` | 跳过指定步骤 |
| `-y` / `--yes [STEP]...` | 对包管理器的确认提示自动回答 yes |
| `-c` / `--cleanup` | 清理临时或旧文件 |
| `--edit-config` | 编辑配置文件 |
| `--config <PATH>` | 使用替代配置文件 |
| `--config-reference` | 显示配置项参考 |
| `-t` / `--tmux` | 在 tmux 里运行 |
| `--no-tmux` | 不在 tmux 里运行 |
| `-r` / `--run-type <TYPE>` | `dry` 只打印、`wet` 实际执行、`damp` 边打印边执行 |
| `--auto-retry <COUNT>` | 失败步骤自动重试至多 COUNT 次 |
| `--no-ask-retry` | 步骤失败后不再询问怎么处理 |
| `--show-skipped` | 显示被跳过步骤的原因 |
| `-v` / `--verbose` | 输出调试日志（等价 `--log-filter debug`） |
| `--sudoloop` | 周期性 `sudo -v`，避免长时间升级中反复要密码 |
| `--no-self-update` | 不更新 topgrade 自身 |
| `-k` / `--keep` | 退出前等一次按键 |

完整的步骤清单运行 `topgrade --help` 查看（`--only`/`--disable` 的 possible values 一节）。

## 本仓库的配置

- 配置文件位于 `~/.config/topgrade/topgrade.toml`（上游默认路径），用 `topgrade --edit-config` 编辑，`topgrade --config-reference` 查看全部可配置项。
- 安装脚本只放二进制，不写配置；配置按需自己维护。
- 与 maintenance 章节配合：把 `topgrade` 放进定期维护流程，机器上所有包管理器一次跑完。
- ⚠️ 默认行为包含 `sudo apt upgrade`：全量 `topgrade` 会真的升级系统包。第一次跑、或在不方便重启服务的时段，先 `topgrade --dry-run` 看清单，或用 `--only`/`--disable` 圈定范围。

## 排错

**跑了很久、要多次输密码**：长会话中 sudo 凭据会过期。加 `--sudoloop`（默认每 240 秒 `sudo -v` 一次），或用 `-t` 放进 tmux 跑。

**某个步骤反复失败拖慢整体**：失败后 topgrade 默认会问怎么处理，无人值守时很烦。用 `--no-ask-retry` 跳过询问，或 `--disable <STEP>` 把坏步骤摘出去修好再加回来。

**某个工具明明装了却被跳过**：可能是检测条件不满足。`--show-skipped` 会打印每个被跳过步骤的原因。

**SSH 里跑一半断线**：长升级别在前台裸跑。`topgrade -t` 在 tmux 里执行，断线后 `tmux attach` 继续。

**dry-run 清单里有不想要的东西**：把对应步骤加进配置文件的 `disable` 列表（`~/.config/topgrade/topgrade.toml`），或每次调用时带 `--disable`。

<!-- lang:en -->

> Summary: topgrade upgrades everything in one command: it detects apt, snap, flatpak, npm, pipx, cargo, rustup, brew and other package managers, and runs their upgrades in a single pass. This repo uses it for periodic full-system updates. It runs `sudo apt upgrade` by default — try `--dry-run` first.

# topgrade

## Purpose

[topgrade](https://github.com/topgrade-rs/topgrade) (Rust) calls itself "Upgrade all the things". It detects the package managers and tools present on the system — apt, snap, flatpak, npm, pipx, cargo, rustup, brew and more — and upgrades each of them in one session, instead of running them by hand one at a time. Steps whose tooling is missing are skipped automatically; `--only`/`--disable` narrow the scope precisely.

Role in this repository: periodic full-system updates. It pairs with the site's maintenance chapter as the standard entry point for "bring everything on this machine up to date". Steps like `--only dotfiles` can also fold this repository's own updates into the same run.

## Source and install

| Item | Notes |
|---|---|
| Repository | [topgrade-rs/topgrade](https://github.com/topgrade-rs/topgrade) (Rust) |
| Installer | `scripts/install/install_topgrade.sh` (downloads a prebuilt binary from GitHub Releases) |
| Binary | `~/.local/bin/topgrade` |
| Version | 17.14.1 (verified on this machine) |

```bash
bash scripts/install/install_topgrade.sh
topgrade --version    # topgrade 17.14.1
```

The installer detects x86_64/aarch64 via uname, queries the latest GitHub Releases tag, downloads the matching `topgrade-<version>-<arch>-unknown-linux-gnu.tar.gz`, and installs the binary into `~/.local/bin`.

## Basic usage

```bash
# see what it would do first (strongly recommended)
topgrade --dry-run

# upgrade everything (runs sudo apt upgrade etc., will ask for a password)
topgrade

# run only certain steps / exclude certain steps
topgrade --only system snap flatpak
topgrade --disable brew_cask gem

# answer yes to every confirmation prompt (for scripts)
topgrade -y

# clean up temporary/old files afterwards
topgrade --cleanup

# edit the config file / show the config reference
topgrade --edit-config
topgrade --config-reference

# run inside tmux so a dropped SSH session doesn't abort it
topgrade -t
```

## Common options

### Common flags (from `topgrade --help`)

| Flag | Effect |
|---|---|
| `-n` / `--dry-run` | print the commands that would run, without executing |
| `--only <STEP>...` | run only the given steps (`system`, `snap`, `flatpak`, `npm`, `pipx`, `cargo`, `rustup`, `node`, `dotfiles` via `yadm`, `git_repos`, ...) |
| `--disable <STEP>...` | skip the given steps |
| `-y` / `--yes [STEP]...` | answer yes to the package managers' prompts |
| `-c` / `--cleanup` | clean up temporary or old files |
| `--edit-config` | edit the configuration file |
| `--config <PATH>` | use an alternative config file |
| `--config-reference` | show the config reference |
| `-t` / `--tmux` | run inside tmux |
| `--no-tmux` | don't run inside tmux |
| `-r` / `--run-type <TYPE>` | `dry` prints only, `wet` executes, `damp` prints and executes |
| `--auto-retry <COUNT>` | retry failed steps up to COUNT times |
| `--no-ask-retry` | don't ask what to do after a step fails |
| `--show-skipped` | show why steps were skipped |
| `-v` / `--verbose` | debug logging (alias for `--log-filter debug`) |
| `--sudoloop` | periodically run `sudo -v` to avoid re-prompts during long updates |
| `--no-self-update` | don't update topgrade itself |
| `-k` / `--keep` | wait for a key press before exiting |

The full step list is in `topgrade --help` (the possible values of `--only`/`--disable`).

## Configuration in this repository

- The config file lives at `~/.config/topgrade/topgrade.toml` (the upstream default); edit it with `topgrade --edit-config` and consult `topgrade --config-reference` for every option.
- The install script only places the binary and writes no config; maintain the config yourself as needed.
- Pairs with the maintenance chapter: put `topgrade` into the periodic maintenance routine so every package manager on the machine is covered in one pass.
- ⚠️ `sudo apt upgrade` runs by default: a full `topgrade` really upgrades system packages. On a first run, or at a time when service restarts are inconvenient, preview with `topgrade --dry-run` first, or scope the run with `--only`/`--disable`.

## Troubleshooting

**It runs forever and asks for the password repeatedly**: sudo credentials expire during a long session. Add `--sudoloop` (refreshes with `sudo -v` every 240 seconds by default), or run it inside tmux with `-t`.

**One failing step keeps stalling the run**: after a failure topgrade asks what to do by default, which is painful unattended. Use `--no-ask-retry` to skip the prompt, or pull the broken step out with `--disable <STEP>` and re-add it once fixed.

**A tool is installed but its step is skipped**: its detection condition probably didn't hold. `--show-skipped` prints the reason for every skipped step.

**The SSH connection dropped mid-upgrade**: don't run long upgrades bare in the foreground. `topgrade -t` runs inside tmux; reattach with `tmux attach` after a disconnect.

**The dry-run list shows things I don't want**: add the corresponding steps to the `disable` list in the config file (`~/.config/topgrade/topgrade.toml`), or pass `--disable` on each invocation.

<!-- lang:ja -->

> 要約：topgrade は 1 コマンドで全部をアップグレードします。apt、snap、flatpak、npm、pipx、cargo、rustup、brew などのパッケージマネージャを検出し、1 回の実行で順にアップグレードします。このリポジトリでは定期の全システム更新に使います。既定で `sudo apt upgrade` が走るので、まず `--dry-run` で確認してください。

# topgrade

## 役割

[topgrade](https://github.com/topgrade-rs/topgrade)（Rust）は「Upgrade all the things」が標榜するツールです。システムに存在するパッケージマネージャやツール——apt、snap、flatpak、npm、pipx、cargo、rustup、brew など——を検出し、1 つのセッションで順番にアップグレードを実行します。手作業で一つずつ回す必要がありません。存在しないツールのステップは自動的にスキップされ、`--only`／`--disable` で範囲を正確に絞れます。

このリポジトリでの役割：定期的な全システム更新です。メンテナンス章と組み合わせ、「このマシンをすべて最新にする」標準的な入り口として使います。`--only dotfiles` のようにすれば、このリポジトリ自身の更新も同じ実行に含められます。

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | [topgrade-rs/topgrade](https://github.com/topgrade-rs/topgrade)（Rust） |
| インストーラ | `scripts/install/install_topgrade.sh`（GitHub Releases からビルド済みバイナリを取得） |
| バイナリ | `~/.local/bin/topgrade` |
| バージョン | 17.14.1（このマシンで確認） |

```bash
bash scripts/install/install_topgrade.sh
topgrade --version    # topgrade 17.14.1
```

インストーラは uname で x86_64／aarch64 を判別し、GitHub Releases の最新タグを照会して対応する `topgrade-<バージョン>-<arch>-unknown-linux-gnu.tar.gz` をダウンロードし、バイナリを `~/.local/bin` に置きます。

## 基本的な使い方

```bash
# まず何が行われるか確認（強く推奨）
topgrade --dry-run

# 全体をアップグレード（sudo apt upgrade などが走り、パスワードを要求）
topgrade

# 特定ステップだけ実行／特定ステップを除外
topgrade --only system snap flatpak
topgrade --disable brew_cask gem

# 確認プロンプトにすべて yes（スクリプト向け）
topgrade -y

# 実行後に一時・旧ファイルを清掃
topgrade --cleanup

# 設定ファイルを編集／設定リファレンスを表示
topgrade --edit-config
topgrade --config-reference

# tmux 内で実行し、SSH が切れても中断しない
topgrade -t
```

## よく使うオプション

### 主要フラグ（`topgrade --help` より）

| フラグ | 効果 |
|---|---|
| `-n` / `--dry-run` | 実行せず、実行されるコマンドを表示 |
| `--only <STEP>...` | 指定ステップのみ実行（`system`、`snap`、`flatpak`、`npm`、`pipx`、`cargo`、`rustup`、`node`、`dotfiles`（yadm 経由）、`git_repos` など） |
| `--disable <STEP>...` | 指定ステップをスキップ |
| `-y` / `--yes [STEP]...` | パッケージマネージャの確認に自動で yes |
| `-c` / `--cleanup` | 一時ファイルや旧ファイルを清掃 |
| `--edit-config` | 設定ファイルを編集 |
| `--config <PATH>` | 代替設定ファイルを使用 |
| `--config-reference` | 設定リファレンスを表示 |
| `-t` / `--tmux` | tmux 内で実行 |
| `--no-tmux` | tmux 内で実行しない |
| `-r` / `--run-type <TYPE>` | `dry` は表示のみ、`wet` は実行、`damp` は表示しつつ実行 |
| `--auto-retry <COUNT>` | 失敗ステップを最大 COUNT 回自動リトライ |
| `--no-ask-retry` | ステップ失敗後の対応を尋ねない |
| `--show-skipped` | スキップされたステップの理由を表示 |
| `-v` / `--verbose` | デバッグログ出力（`--log-filter debug` の別名） |
| `--sudoloop` | 定期的に `sudo -v` を実行し、長時間の更新中の再入力を回避 |
| `--no-self-update` | topgrade 自身を更新しない |
| `-k` / `--keep` | 終了前にキー入力を待つ |

ステップの全一覧は `topgrade --help` を参照（`--only`／`--disable` の possible values の項）。

## このリポジトリでの設定

- 設定ファイルは `~/.config/topgrade/topgrade.toml`（上流の既定パス）。編集は `topgrade --edit-config`、全設定項目は `topgrade --config-reference` で確認できます。
- インストーラはバイナリを置くだけで設定は書きません。設定は必要に応じて自分で管理します。
- メンテナンス章と組み合わせ、定期メンテナンスの手順に `topgrade` を組み込み、マシン上の全パッケージマネージャを 1 回でカバーします。
- ⚠️ 既定で `sudo apt upgrade` が走ります。フル実行の `topgrade` はシステムパッケージを実際にアップグレードします。初回や、サービス再起動が都合の悪い時間帯は、まず `topgrade --dry-run` で一覧を確認するか、`--only`／`--disable` で範囲を絞ってください。

## トラブルシュート

**実行が長く、パスワードを何度も求められる**：長いセッションでは sudo 資格が失効します。`--sudoloop` を付けます（既定で 240 秒ごとに `sudo -v`）。または `-t` で tmux 内で実行します。

**失敗するステップが毎回引っかかる**：失敗後、既定では対応を尋ねられるため、無人実行では邪魔です。`--no-ask-retry` で確認を飛ばすか、`--disable <STEP>` で外して直してから戻します。

**インストール済みなのにステップがスキップされる**：検出条件が満たされていない可能性があります。`--show-skipped` が各スキップの理由を出します。

**SSH の途中で切れた**：長時間の更新をフォアグラウンドで素実行しないでください。`topgrade -t` なら tmux 内で動くので、切断後は `tmux attach` で再開できます。

**dry-run の一覧に要らないものがある**：設定ファイル（`~/.config/topgrade/topgrade.toml`）の `disable` リストに該当ステップを追加するか、実行のたびに `--disable` を渡します。
