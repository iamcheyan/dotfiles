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

<!-- lang:en -->
> Summary: `tmux-new` starts or attaches to a tmux session and attempts recovery only after confirming that the server is stale.

# tmux-new

## Purpose

`scripts/tmux-new` addresses a specific problem: when the tmux server process is stale (the socket file remains, but the server does not respond to the protocol), ordinary `tmux` commands keep failing and cannot create a session.

The script first checks that the server is truly stale, confirms there are no connected clients and that the listener is a tmux server, and only then removes the socket and recreates the session.

## Status

**Currently untracked** (`git status` shows `?? scripts/tmux-new`). This is a newly added local script that has not been committed.

## Usage

## Argument Forwarding Rules

`-A` means “attach if it exists, create it otherwise,” so repeated runs do not create multiple sessions.

| Input | Command actually run |
|---|---|
| No arguments | `tmux new-session -A -s main` |
| `new -s work` | `tmux new-session -A -s work` |
| `-V` | `tmux new-session -A -V` |
| `attach -t work` | `tmux attach -t work` |
| `list-sessions` | `tmux list-sessions` |

## Stale Server Detection

Both conditions must hold before recovery begins:

1. The socket file exists.
2. Running `list-sessions` through that socket fails.

## Three Safety Checks

### Check 1: The Listener Is tmux

Confirm that the process using the socket is named `tmux: server`, not another program.

### Check 2: No Clients Are Connected

**Never clean up while clients are connected.** This prevents killing a server that is in use.

### Check 3: The Socket Is Truly Orphaned

Before cleanup, confirm again that the socket file exists but the kernel has no corresponding listener.

## Cleanup and Restart

The process is:

1. Force-kill the stale process with `kill -KILL`.
2. Wait up to 1 second (20 × 50ms) for it to exit.
3. Remove the orphaned socket file.
4. Confirm removal succeeded.

Any failure produces an explicit error and exits without continuing to a tmux command.

## Design Principle

The key principle is to act **only after safety is confirmed**:

| Check | Purpose |
|---|---|
| Socket exists but the protocol does not respond | Distinguish a stale server from a healthy one |
| Listener process is a tmux server | Ensure another program is not using the socket |
| No connected clients | Avoid interrupting an active session |
| No kernel listener for the socket | Confirm it is an orphaned file |

Cleanup occurs only if all four checks pass. This is much safer than running `pkill tmux` and starting over.

## Troubleshooting

**`tmux recovery skipped: has connected clients`**: Clients are connected. Close those terminals first, or run `tmux kill-server` manually (this will lose the sessions).

**`could not be safely identified`**: The `ss` output format differs from what is expected. Inspect it manually.

**`stale server is still running`**: The process did not exit after `kill -KILL` (it may be in state D). Check `ps -o stat= -p <pid>`.

**Script not found**: It has not been committed yet. Check `ls -l ~/dotfiles/scripts/tmux-new`.

**`/usr/bin/tmux` path is wrong**: The script hardcodes this path. Change it if tmux is installed elsewhere.

<!-- lang:ja -->
> 要約：`tmux-new` は tmux セッションを開始または接続し、サーバーが応答不能だと確認できた場合に限って復旧を試みます。

# tmux-new

## 用途

`scripts/tmux-new` は、tmux サーバープロセスが応答不能になった場合の問題に対処します。ソケットファイルは残っていてもサーバーがプロトコルに応答しないため、通常の `tmux` コマンドが失敗し、セッションを作成できなくなります。

このスクリプトは、サーバーが本当に応答不能であること、接続中のクライアントがないこと、待受プロセスが tmux server であることを確認してから、ソケットを削除してセッションを作り直します。

## 状態

**現在は未追跡です**（`git status` に `?? scripts/tmux-new` と表示されます）。ローカルで追加されたばかりで、まだ commit されていないスクリプトです。

## 使い方

## 引数の引き渡し規則

`-A` は「存在する場合は接続し、存在しない場合は作成する」という意味です。そのため、繰り返し実行してもセッションが複数作られません。

| 入力 | 実際に実行されるコマンド |
|---|---|
| 引数なし | `tmux new-session -A -s main` |
| `new -s work` | `tmux new-session -A -s work` |
| `-V` | `tmux new-session -A -V` |
| `attach -t work` | `tmux attach -t work` |
| `list-sessions` | `tmux list-sessions` |

## 応答不能サーバーの検出

復旧を始めるには、次の 2 条件を両方満たす必要があります。

1. ソケットファイルが存在すること。
2. そのソケット経由で `list-sessions` を実行すると失敗すること。

## 3 段階の安全確認

### 確認 1：待受プロセスが tmux であること

ソケットを使用しているプロセス名が `tmux: server` であり、別のプログラムではないことを確認します。

### 確認 2：クライアントが接続していないこと

**クライアントが接続中の場合は、決してクリーンアップしません。** 使用中のサーバーを終了させないためです。

### 確認 3：ソケットが本当に孤立していること

クリーンアップの直前に、ソケットファイルは存在する一方で、カーネルには対応する待受がないことを再確認します。

## クリーンアップと再起動

処理は次のとおりです。

1. `kill -KILL` で応答不能なプロセスを強制終了します。
2. 終了を最大 1 秒（20 × 50ms）待ちます。
3. 孤立したソケットファイルを削除します。
4. 削除できたことを確認します。

どの段階でも失敗した場合は明確なエラーを表示して終了し、tmux コマンドの実行には進みません。

## 設計原則

このスクリプトの中心となる考え方は、**安全だと確認できた場合にだけ操作すること**です。

| 確認項目 | 目的 |
|---|---|
| ソケットが存在するがプロトコルに応答しない | 応答不能と正常な状態を区別します |
| 待受プロセスが tmux server | 別のプログラムがソケットを使っていないことを確認します |
| 接続中のクライアントがいない | 使用中のセッションを中断しないようにします |
| ソケットに対応するカーネル待受がない | 孤立したファイルであることを確認します |

4 項目すべてを満たした場合だけ削除します。`pkill tmux` で終了してやり直す方法より安全です。

## トラブルシューティング

**`tmux recovery skipped: has connected clients`**：クライアントが接続中です。該当する端末を閉じるか、手動で `tmux kill-server` を実行してください（セッションは失われます）。

**`could not be safely identified`**：`ss` の出力形式が想定と異なります。手動で確認してください。

**`stale server is still running`**：`kill -KILL` の後もプロセスが終了していません（D 状態の可能性があります）。`ps -o stat= -p <pid>` を確認してください。

**スクリプトが見つからない**：まだ commit されていません。`ls -l ~/dotfiles/scripts/tmux-new` で確認してください。

**`/usr/bin/tmux` のパスが違う**：スクリプトでこのパスを固定しています。tmux が別の場所にある場合は変更が必要です。
