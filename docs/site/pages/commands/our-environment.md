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
