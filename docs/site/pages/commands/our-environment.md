> 摘要：这台机器的实际环境、工作流和专属命令：Zsh 配置、tmux OSC 52、gh 环境变量、无头桌面、内存纪律。

# 本机环境实战

这篇不讲通用命令，讲**这台机器特有的操作**。网上教程不会告诉你这些，但在这台机器上每天都会用到。

## 机器画像

| 项目 | 值 |
|---|---|
| 发行版 | Debian 13（trixie） |
| 形态 | PVE 上的虚拟机，无物理显示器 |
| 桌面 | Xvnc + Xfce，浏览器经 noVNC 访问 |
| 资源 | 16GiB 内存 / 4 核，**内存是首要约束** |
| 用户 | tetsuya（sudo 免密） |
| 远程入口 | Telegram Bot（最高优先级）、Tailscale |

## 内存纪律（最重要的一条）

16GiB 听着不少，但常驻大户很多：agent 进程池（每 worker 约 0.6GiB）、专用 Chrome（约 1GiB）、tmux 里的长任务、hermes gateway（上限 2.44G）。

**起任何重任务前**：

```bash
free -h        # 看 available，低于 2GiB 先等等或先清理
```

系统有 earlyoom 兜底（内存低于 10% 时按分数杀进程，gateway 分数最高）。**OOM 时 gateway 先死，表现就是 Telegram 断联**。所以看到 available 见底时主动收手，比等系统杀强。

日常清理对象：`~/.cache`、pnpm store、旧的 tmux 会话（`tmux kill-session`）、跑完的 Docker。

## Zsh 环境

登录后是 Zsh，不是 Bash。别名的定义在 `aliases.conf` 和 `aliases/`，**脚本里（`#!/bin/bash`）一律不生效**。

```bash
exec zsh                  # 改完 zshrc/别名后重载
type -a ll                # 看 ll 到底是别名还是命令
alias                     # 列出所有别名
```

本机没有原生 `ls`/`cat`/`grep` 体验：`l`/`ll`/`la` 是 eza，`f`/`ffd` 是 fzf 函数，`z` 是 zoxide，`v` 是 vifm，`ra` 是 ranger，`br` 是 broot。完整清单见[工具目录](../tools/intro.html)。

## tmux 与剪贴板（OSC 52）

tmux 会话是本机跑长任务的标准方式：断线重连、窗口复用、会话保持。

```bash
tmux new -s work          # 新建会话
tmux ls                   # 会话列表
tmux a -t work            # 接回会话
tmux kill-session -t old  # 清理不用的会话（省内存）
tmux-new                  # 本站的脚本版新建命令
```

**复制粘贴走 OSC 52**：在 tmux 里选中即复制，内容通过终端转义序列写进本地剪贴板，不依赖 X11。SSH 远程、noVNC 网页里都能用。条件是终端本身支持 OSC 52（Ghostty、Xfce terminal 都支持）。今天改的就是这条链，细节见 [tmux 插件 - tmux-yank](../tmux-plugins/yank.html)。

## gh（GitHub CLI）的正确打开方式

本机 `gh` 的认证目录和默认不同，直接敲会假报未登录：

```bash
export GH_CONFIG_DIR="$HOME/.config/gh"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
gh auth status
```

cron 和脚本里用 gh，第一行必须是这两个 export，否则认证挂起或报错。这两行的来历见 [GitHub CLI](../tools/gh.html)。

```bash
gh pr list --author @me
gh search prs --author iamcheyan --state open
gh api graphql -f query='...'    # GraphQL 查询（审阅线程等高级操作）
```

## 无头桌面环境

本机没有显示器，图形程序全在虚拟显示上：

```bash
echo $DISPLAY             # 当前会话的显示（Xvnc :20，Bot 自己的桌面 :21）
webdesktop status         # 本站脚本：桌面状态
webdesktop restart        # 重启（配置变更后）
```

跑 GUI 程序前先确认有会话；没有 DISPLAY 的命令会直接报 `cannot open display`。截图、浏览器自动化都走这套。

## Docker 项目

本机的服务（照片、音乐、文档、下载）都是 Docker Compose：

```bash
docker ps -a                        # 看容器
docker compose -C ~/immich ps       # 各项目自己的目录
docker compose -C ~/immich logs -f --tail=50
```

**规矩**：动生产卷之前 `docker inspect` 看清映射，备份优先，绝不 `compose down -v`。

## Node 工具链

```bash
node -v                  # fnm 管的版本
corepack pnpm -v         # pnpm 走 corepack，版本跟仓库的 packageManager
bun --version            # bun 在 ~/.bun/bin
```

跑任何仓库的 pnpm 命令前先 `corepack pnpm ...`，用系统全局 pnpm 会版本不一致。

## 服务端口速查

本机自己跑的服务（排查冲突时用 `ss -ltnp` 对照）：

```bash
ss -ltnp | rg 'LISTEN'   # 所有监听端口 + 进程
```

主要服务：服务面板、媒体与照片、音乐、文档、Webmail、下载管理等，各自目录的 `docker-compose.yml` 或 systemd unit 定义端口。新增服务前先查端口占用。

## 目录约定

```bash
~/dotfiles        # 本站配置（公开）
~/development     # 所有开发项目（42+ 个仓库）
~/wiki            # 知识库（公开，发布前脱敏）
~/.hermes         # agent 数据、脚本、cron（私有）
/data             # NAS 挂载点（生产数据，谨慎）
```

**源码目录 vs 运行目录**：`~/development` 是源码；生成物、日志、数据库不是源码，改之前先确认自己在哪一层。

## 每天真的在用的命令（作者自用）

```bash
# 一天的标准开场
tmux a -t main || tmux new -s main     # 接回主会话
z dotfiles && git pull                # 更新配置
free -h                                # 确认内存

# 查 PR 状态
export GH_CONFIG_DIR=~/.config/gh
gh pr list --author @me

# 看服务健康
curl -sS -w '\n%{http_code}\n' http://127.0.0.1/ | tail -1

# 找大文件
ncdu ~ --exclude ~/.cache

# 看 agent 在跑什么
pgrep -af 'hermes|tmux' | head
```

## 排错

**`gh` 报未登录**：缺两个环境变量，见上文。

**GUI 程序打不开**：没有 DISPLAY 或 Xvnc 会话没起，`webdesktop status`。

**Telegram Bot 不回**：先 `pgrep -af hermes`、`systemctl --user status hermes-gateway`、`free -h`——按这个顺序，内存把 gateway 杀了是最常见原因。

**tmux 里复制失灵**：终端不支持 OSC 52，或嵌套 tmux 时转义被吞。Ghostty + 单层 tmux 是验证过的组合。

**命令在 tmux 里和外面行为不同**：环境变量差异。`env | sort > /tmp/env.inside`，外面同样存一份，`diff` 看差在哪。

<!-- lang:en -->

> Summary: The actual environment, workflows, and machine-specific commands of this box: Zsh config, tmux OSC 52, gh environment variables, the headless desktop, and memory discipline.

# This Machine's Environment in Practice

This page is not about generic commands; it covers **operations specific to this machine**. Online tutorials won't tell you these, but you use them every day on this box.

## Machine profile

| 项目 | 值 |
|---|---|
| 发行版 | Debian 13（trixie） |
| 形态 | PVE 上的虚拟机，无物理显示器 |
| 桌面 | Xvnc + Xfce，浏览器经 noVNC 访问 |
| 资源 | 16GiB 内存 / 4 核，**内存是首要约束** |
| 用户 | tetsuya（sudo 免密） |
| 远程入口 | Telegram Bot（最高优先级）、Tailscale |

## Memory discipline (the most important rule)

16GiB sounds like a lot, but there are many long-running heavyweights: the agent process pool (about 0.6GiB per worker), a dedicated Chrome (about 1GiB), long tasks inside tmux, and the hermes gateway (capped at 2.44G).

**Before starting any heavy task**:

```bash
free -h        # 看 available，低于 2GiB 先等等或先清理
```

The system has earlyoom as a safety net (when memory drops below 10%, it kills processes by score, and the gateway has the highest score). **During OOM the gateway dies first, and the symptom is Telegram going silent**. So when available is running low, back off proactively rather than waiting for the system to kill things.

Everyday cleanup targets: `~/.cache`, the pnpm store, old tmux sessions (`tmux kill-session`), finished Docker runs.

## Zsh environment

After login you get Zsh, not Bash. Aliases are defined in `aliases.conf` and `aliases/`, and they **never take effect inside scripts (`#!/bin/bash`)**.

```bash
exec zsh                  # 改完 zshrc/别名后重载
type -a ll                # 看 ll 到底是别名还是命令
alias                     # 列出所有别名
```

This machine doesn't give you a stock `ls`/`cat`/`grep` experience: `l`/`ll`/`la` are eza, `f`/`ffd` are fzf functions, `z` is zoxide, `v` is vifm, `ra` is ranger, and `br` is broot. See the full list in [Tool catalog](../tools/intro.html).

## tmux and the clipboard (OSC 52)

tmux sessions are the standard way to run long tasks on this machine: reconnect after disconnects, reuse windows, keep sessions alive.

```bash
tmux new -s work          # 新建会话
tmux ls                   # 会话列表
tmux a -t work            # 接回会话
tmux kill-session -t old  # 清理不用的会话（省内存）
tmux-new                  # 本站的脚本版新建命令
```

**Copy/paste goes through OSC 52**: selecting text inside tmux copies it immediately, and the content is written to your local clipboard via terminal escape sequences, without depending on X11. It works over SSH and inside the noVNC web page. The requirement is a terminal that supports OSC 52 itself (both Ghostty and Xfce terminal do). Today's change was exactly to this chain; details in [tmux plugin - tmux-yank](../tmux-plugins/yank.html).

## gh (GitHub CLI) done right

This machine's `gh` auth directory differs from the default, so invoking it directly falsely reports that you're not logged in:

```bash
export GH_CONFIG_DIR="$HOME/.config/gh"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
gh auth status
```

When using gh in cron or scripts, these two exports must be the first lines; otherwise authentication hangs or errors. Where these lines come from is explained in [GitHub CLI](../tools/gh.html).

```bash
gh pr list --author @me
gh search prs --author iamcheyan --state open
gh api graphql -f query='...'    # GraphQL 查询（审阅线程等高级操作）
```

## Headless desktop environment

This machine has no monitor; graphical programs all run on virtual displays:

```bash
echo $DISPLAY             # 当前会话的显示（Xvnc :20，Bot 自己的桌面 :21）
webdesktop status         # 本站脚本：桌面状态
webdesktop restart        # 重启（配置变更后）
```

Before running GUI programs, confirm a session exists; commands without a DISPLAY fail outright with `cannot open display`. Screenshots and browser automation all go through this setup.

## Docker projects

The services on this machine (photos, music, documents, downloads) are all Docker Compose:

```bash
docker ps -a                        # 看容器
docker compose -C ~/immich ps       # 各项目自己的目录
docker compose -C ~/immich logs -f --tail=50
```

**The rule**: before touching production volumes, inspect the mappings with `docker inspect`, back up first, and never run `compose down -v`.

## Node toolchain

```bash
node -v                  # fnm 管的版本
corepack pnpm -v         # pnpm 走 corepack，版本跟仓库的 packageManager
bun --version            # bun 在 ~/.bun/bin
```

Before running any repository's pnpm commands, use `corepack pnpm ...`; using a system-global pnpm leads to version mismatches.

## Service port quick reference

Services that this machine itself runs (compare against `ss -ltnp` when troubleshooting conflicts):

```bash
ss -ltnp | rg 'LISTEN'   # 所有监听端口 + 进程
```

Main services: the service dashboard, media and photos, music, documents, webmail, download management, etc.; each is defined by the `docker-compose.yml` or systemd unit in its own directory. Check port usage before adding a new service.

## Directory conventions

```bash
~/dotfiles        # 本站配置（公开）
~/development     # 所有开发项目（42+ 个仓库）
~/wiki            # 知识库（公开，发布前脱敏）
~/.hermes         # agent 数据、脚本、cron（私有）
/data             # NAS 挂载点（生产数据，谨慎）
```

**Source directories vs runtime directories**: `~/development` is source code; build artifacts, logs, and databases are not source. Before changing anything, confirm which layer you are in.

## Commands I genuinely use every day (the author's own)

```bash
# 一天的标准开场
tmux a -t main || tmux new -s main     # 接回主会话
z dotfiles && git pull                # 更新配置
free -h                                # 确认内存

# 查 PR 状态
export GH_CONFIG_DIR=~/.config/gh
gh pr list --author @me

# 看服务健康
curl -sS -w '\n%{http_code}\n' http://127.0.0.1/ | tail -1

# 找大文件
ncdu ~ --exclude ~/.cache

# 看 agent 在跑什么
pgrep -af 'hermes|tmux' | head
```

## Troubleshooting

**`gh` reports not logged in**: two environment variables are missing; see above.

**GUI programs won't open**: no DISPLAY, or the Xvnc session isn't running — check `webdesktop status`.

**The Telegram Bot doesn't reply**: start with `pgrep -af hermes`, `systemctl --user status hermes-gateway`, and `free -h` — in that order; OOM killing the gateway is the most common cause.

**Copying inside tmux stops working**: the terminal doesn't support OSC 52, or escape sequences get swallowed in nested tmux. Ghostty plus a single tmux layer is the verified combination.

**A command behaves differently inside tmux vs outside**: environment variable differences. Save `env | sort > /tmp/env.inside` inside, save the same outside, and `diff` the two to see where they diverge.

<!-- lang:ja -->

> 要約：このマシンの実際の環境、ワークフロー、専用コマンド。Zsh 設定、tmux OSC 52、gh の環境変数、ヘッドレスデスクトップ、メモリ規律。

# 本機環境の実践

このページは一般的なコマンドの話ではなく、**このマシン特有の操作**について扱います。ネットのチュートリアルでは教えてくれませんが、このマシンでは毎日使うものばかりです。

## マシンのプロファイル

| 项目 | 值 |
|---|---|
| 发行版 | Debian 13（trixie） |
| 形态 | PVE 上的虚拟机，无物理显示器 |
| 桌面 | Xvnc + Xfce，浏览器经 noVNC 访问 |
| 资源 | 16GiB 内存 / 4 核，**内存是首要约束** |
| 用户 | tetsuya（sudo 免密） |
| 远程入口 | Telegram Bot（最高优先级）、Tailscale |

## メモリ規律（最重要ルール）

16GiB は多く聞こえますが、常駐する大口がたくさんあります：エージェントのプロセスプール（worker 1 個あたり約 0.6GiB）、専用 Chrome（約 1GiB）、tmux 内の長時間タスク、hermes gateway（上限 2.44G）。

**重いタスクを起動する前に**：

```bash
free -h        # 看 available，低于 2GiB 先等等或先清理
```

システムには earlyoom のセーフティネットがあります（メモリが 10% を下回るとスコア順にプロセスを kill し、gateway のスコアが最も高い）。**OOM 時には gateway が最初に死に、症状は Telegram の無反応です**。だから available が少なくなってきたら、システムに殺されるのを待つのではなく、自ら手を引く方が得策です。

日常のクリーンアップ対象：`~/.cache`、pnpm store、古い tmux セッション（`tmux kill-session`）、終わった Docker。

## Zsh 環境

ログイン後のシェルは Zsh で、Bash ではありません。エイリアスは `aliases.conf` と `aliases/` で定義されていますが、**スクリプト（`#!/bin/bash`）内では一切効きません**。

```bash
exec zsh                  # 改完 zshrc/别名后重载
type -a ll                # 看 ll 到底是别名还是命令
alias                     # 列出所有别名
```

本機には素の `ls`/`cat`/`grep` の体験はありません：`l`/`ll`/`la` は eza、`f`/`ffd` は fzf 関数、`z` は zoxide、`v` は vifm、`ra` は ranger、`br` は broot です。完全なリストは[ツールカタログ](../tools/intro.html)を見てください。

## tmux とクリップボード（OSC 52）

tmux セッションは本機で長時間タスクを走らせる標準的な方法です：切断後の再接続、ウィンドウの再利用、セッションの維持。

```bash
tmux new -s work          # 新建会话
tmux ls                   # 会话列表
tmux a -t work            # 接回会话
tmux kill-session -t old  # 清理不用的会话（省内存）
tmux-new                  # 本站的脚本版新建命令
```

**コピペは OSC 52 を使います**：tmux 内でテキストを選択するだけで即コピーされ、内容は端末のエスケープシーケンス経由でローカルのクリップボードに書き込まれ、X11 に依存しません。SSH 越しでも noVNC のブラウザ内でも使えます。条件は端末自体が OSC 52 に対応していること（Ghostty も Xfce terminal も対応済み）。今日変更したのはまさにこの経路で、詳細は [tmux プラグイン - tmux-yank](../tmux-plugins/yank.html) を参照してください。

## gh（GitHub CLI）の正しい使い方

本機の `gh` の認証ディレクトリはデフォルトと異なるため、そのまま叩くとログインしていないと誤判定されます：

```bash
export GH_CONFIG_DIR="$HOME/.config/gh"
export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$(id -u)/bus"
gh auth status
```

cron やスクリプトで gh を使うときは、この 2 行の export が必ず最初に必要です。なければ認証がハングしたりエラーになったりします。この 2 行の経緯は [GitHub CLI](../tools/gh.html) に書かれています。

```bash
gh pr list --author @me
gh search prs --author iamcheyan --state open
gh api graphql -f query='...'    # GraphQL 查询（审阅线程等高级操作）
```

## ヘッドレスデスクトップ環境

本機にはモニタがなく、GUI プログラムはすべて仮想ディスプレイ上で動きます：

```bash
echo $DISPLAY             # 当前会话的显示（Xvnc :20，Bot 自己的桌面 :21）
webdesktop status         # 本站脚本：桌面状态
webdesktop restart        # 重启（配置变更后）
```

GUI プログラムを起動する前にセッションの有無を確認します。DISPLAY がないコマンドは `cannot open display` で即座に失敗します。スクリーンショットもブラウザ自動化もこの仕組みを使います。

## Docker プロジェクト

本機のサービス（写真、音楽、ドキュメント、ダウンロード）はすべて Docker Compose です：

```bash
docker ps -a                        # 看容器
docker compose -C ~/immich ps       # 各项目自己的目录
docker compose -C ~/immich logs -f --tail=50
```

**ルール**：本番ボリュームに手を入れる前に `docker inspect` でマッピングを確認し、バックアップを優先し、`compose down -v` は絶対にしない。

## Node ツールチェーン

```bash
node -v                  # fnm 管的版本
corepack pnpm -v         # pnpm 走 corepack，版本跟仓库的 packageManager
bun --version            # bun 在 ~/.bun/bin
```

どのリポジトリでも pnpm コマンドを実行する前に `corepack pnpm ...` を使います。システムグローバルの pnpm を使うとバージョン不整合が起きます。

## サービスポート早見表

本機自身が走らせているサービス（競合調査時は `ss -ltnp` と突き合わせます）：

```bash
ss -ltnp | rg 'LISTEN'   # 所有监听端口 + 进程
```

主なサービス：サービスダッシュボード、メディアと写真、音楽、ドキュメント、Webmail、ダウンロード管理など。ポートはそれぞれのディレクトリの `docker-compose.yml` か systemd unit で定義されています。新しいサービスを追加する前にポート占有を確認します。

## ディレクトリの約束事

```bash
~/dotfiles        # 本站配置（公开）
~/development     # 所有开发项目（42+ 个仓库）
~/wiki            # 知识库（公开，发布前脱敏）
~/.hermes         # agent 数据、脚本、cron（私有）
/data             # NAS 挂载点（生产数据，谨慎）
```

**ソースディレクトリとランタイムディレクトリ**：`~/development` がソースです。生成物、ログ、データベースはソースではありません。変更する前に自分がどの層にいるのか確認します。

## 毎日本当に使っているコマンド（作者自用）

```bash
# 一天的标准开场
tmux a -t main || tmux new -s main     # 接回主会话
z dotfiles && git pull                # 更新配置
free -h                                # 确认内存

# 查 PR 状态
export GH_CONFIG_DIR=~/.config/gh
gh pr list --author @me

# 看服务健康
curl -sS -w '\n%{http_code}\n' http://127.0.0.1/ | tail -1

# 找大文件
ncdu ~ --exclude ~/.cache

# 看 agent 在跑什么
pgrep -af 'hermes|tmux' | head
```

## トラブルシューティング

**`gh` が未ログインと報告する**：2 つの環境変数が欠けています。上記を参照。

**GUI プログラムが開かない**：DISPLAY がないか Xvnc セッションが動いていません。`webdesktop status` を確認。

**Telegram Bot が返信しない**：まず `pgrep -af hermes`、`systemctl --user status hermes-gateway`、`free -h` の順で確認します。メモリ不足で gateway が殺されるのが最もよくある原因です。

**tmux 内でコピーが効かない**：端末が OSC 52 非対応か、ネストした tmux でエスケープが飲まれています。Ghostty + 単一層 tmux が検証済みの組み合わせです。

**コマンドの挙動が tmux 内外で違う**：環境変数の違いです。tmux 内で `env | sort > /tmp/env.inside`、外でも同じように保存し、`diff` で差分を見ます。
