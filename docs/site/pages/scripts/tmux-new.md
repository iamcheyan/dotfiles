> 摘要：tmux-new 启动或连接 tmux 会话，并只在确认服务器已僵死时尝试恢复。

# tmux-new

## 用途

`scripts/tmux-new` 解决一个具体问题：tmux 服务器进程僵死（socket 文件还在，但服务器不响应协议）时，普通 `tmux` 命令会一直报错，无法新建会话。

这个脚本先判断是不是真的僵死，确认没有客户端连接、监听进程确实是 tmux server，才清理 socket 并重建。

## 状态

**当前未跟踪**（`git status` 显示 `?? scripts/tmux-new`）。它是本地新增的脚本，尚未提交。

## 用法

```bash
tmux-new                      # 连接或新建名为 main 的会话
tmux-new new -s work          # 新建命名会话
tmux-new new-session -s dev
tmux-new attach -t work       # 其它 tmux 子命令透传
tmux-new -V                   # 选项透传
```

## 参数透传规则

```bash
if [[ $# -eq 0 ]]; then
    exec /usr/bin/tmux new-session -A -s main
fi

if [[ "$1" == "new" || "$1" == "new-session" ]]; then
    shift
    exec /usr/bin/tmux new-session -A "$@"
fi

if [[ "$1" == -* ]]; then
    exec /usr/bin/tmux new-session -A "$@"
fi

exec /usr/bin/tmux "$@"
```

| 输入 | 实际执行 |
|---|---|
| 无参数 | `tmux new-session -A -s main` |
| `new -s work` | `tmux new-session -A -s work` |
| `-V` | `tmux new-session -A -V` |
| `attach -t work` | `tmux attach -t work` |
| `list-sessions` | `tmux list-sessions` |

`-A` 表示「存在则连接，不存在则新建」，所以重复执行不会创建多个会话。

## 僵死检测逻辑

```bash
socket_dir="${TMUX_TMPDIR:-/tmp}/tmux-$(id -u)"
socket="$socket_dir/default"

if [[ -S "$socket" ]] && ! tmux -S "$socket" list-sessions >/dev/null 2>&1; then
```

两个条件同时满足才进入恢复流程：

1. socket 文件存在
2. 通过该 socket 执行 `list-sessions` 失败

## 三重安全验证

### 验证 1：监听进程是 tmux

```bash
listener="$(ss -xlpn 2>/dev/null | awk -v path="$socket" '$5 == path { if (match($0, /pid=[0-9]+/)) { print substr($0, RSTART + 4, RLENGTH - 4); exit } }')"

if [[ "$listener" =~ ^[0-9]+$ ]] \
    && [[ "$(cat "/proc/$listener/comm" 2>/dev/null)" == "tmux: server" ]]; then
```

确认占用该 socket 的进程名是 `tmux: server`，不是别的程序。

### 验证 2：没有客户端连接

```bash
clients="$(ps -eo pid=,comm=,args= | awk -v server="$listener" '$2 == "tmux:" && $3 == "client" { print $1 }')"

if [[ -z "$clients" ]]; then
    # 可以安全清理
else
    echo "tmux recovery skipped: server $listener has connected clients ($clients)" >&2
    exit 1
fi
```

**有客户端连接时绝不清理**。这条规则防止「杀掉正在工作的服务器」。

### 验证 3：socket 确实是孤儿

```bash
if [[ ! -S "$socket" ]] || ss -xlpn 2>/dev/null | awk -v path="$socket" '$5 == path { found = 1 } END { exit !found }'; then
    echo "tmux recovery skipped: socket listener could not be safely identified" >&2
    exit 1
fi
```

清理前再确认一次：socket 文件在，但内核里没有对应的监听。

## 清理与重建

```bash
kill -KILL "$listener" 2>/dev/null || true
for _ in {1..20}; do
    kill -0 "$listener" 2>/dev/null || break
    sleep 0.05
done
if kill -0 "$listener" 2>/dev/null; then
    echo "tmux recovery failed: stale server $listener is still running" >&2
    exit 1
fi

rm -f -- "$socket"
if [[ -e "$socket" || -S "$socket" ]]; then
    echo "tmux recovery failed: could not remove orphaned socket $socket" >&2
    exit 1
fi
```

流程：

1. `kill -KILL` 强杀僵死进程
2. 最多等 1 秒（20 × 50ms）确认退出
3. 删除孤儿 socket 文件
4. 确认删除成功

任何一步失败都明确报错并退出，不继续执行 tmux 命令。

## 设计原则

这个脚本的核心是**只在确证安全时才动手**：

| 检查 | 目的 |
|---|---|
| socket 存在但协议不响应 | 区分「僵死」和「正常」 |
| 监听进程是 tmux server | 排除 socket 被别的程序占用 |
| 无客户端连接 | 不打断正在工作的会话 |
| socket 无内核监听 | 确认是孤儿文件 |

四条全过才清理。这比「`pkill tmux` 然后重来」安全得多。

## 排错

**`tmux recovery skipped: has connected clients`**：有客户端连着。先关掉那些终端，或手动 `tmux kill-server`（会丢掉会话）。

**`could not be safely identified`**：`ss` 输出格式和预期不符。手动检查：

```bash
ss -xlpn | grep tmux
ls -l /tmp/tmux-$(id -u)/default
```

**`stale server is still running`**：`kill -KILL` 后进程仍未退出（可能处于 D 状态）。检查 `ps -o stat= -p <pid>`。

**脚本不存在**：它还没提交。确认 `ls -l ~/dotfiles/scripts/tmux-new`。

**`/usr/bin/tmux` 路径不对**：脚本硬编码了这个路径。tmux 装在别处时需要改。
