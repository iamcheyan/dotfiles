> 摘要：ps、top、kill、jobs、nohup 等进程与作业控制命令，含本机 16GiB 内存约束下的实战做法。

# 进程与作业

## 看进程

```bash
ps                      # 当前终端的进程
ps aux                  # 系统所有进程（经典组合）
ps -ef --forest         # 树状显示父子关系
ps u --forest -g $(id -u tetsuya)   # 本用户进程树
```

本机装了 **procs**（`ps` 的现代替代，彩色 + 更好看的列）：

```bash
procs                  # 默认表格，CPU/内存/端口一目了然
procs node             # 按名字过滤
procs --tree           # 树状
procs --sortd cpu      # 按 CPU 占用排序
```

**交互式监视**：

```bash
top          # 经典，每台机器都有
htop         # 彩色 + 鼠标操作 + 树状（本机有 btop 时优先 btop）
btop         # 本机主力：图形化资源图，支持鼠标
```

btop 的常用操作：`/` 搜索进程，`t` 树状，`k`  kill，`q` 退出。内存是这台机器的首要约束，**长任务起前先看 `free -h` 的 available**，低于 2GiB 时先想想再启动。

## 按名字找进程

```bash
pgrep -af node          # 按名字找，-a 显示完整命令行，-f 匹配全命令行
pgrep -af 'tmux|hermes' # 多个候选
pidof node             # 只输出 PID（适合脚本）
```

本机常用（查看 agent 相关进程是否重复启动）：

```bash
pgrep -af 'hermes|telegram|codex'
```

## kill 与信号

```bash
kill PID                # 发 SIGTERM（15），礼貌请求退出
kill -9 PID             # SIGKILL，强杀，不给清理机会
kill -TERM PID          # 同上，显式写法
kill -HUP PID           # 挂起信号，很多程序用它重载配置
kill -STOP PID          # 暂停进程（不停在调试时有用）
kill -CONT PID          # 恢复被 STOP 的进程
pkill -f 'pattern'      # 按命令行模式杀（比 kill 危险，先 pgrep 确认）
killall node            # 按精确进程名杀
```

**杀进程的次序**：先 `kill`（TERM）等几秒，让目标自己 flush 和清理；不退出再 `kill -9`。直接 `-9` 可能丢数据（数据库、正在写的文件）。

本机血泪规则：**不要 `pkill -f python`、`pkill node` 这种大范围模式**——会误杀 hermes gateway 和其它 agent 进程。先 `pgrep -af` 看清 PID 再精确 `kill`。

## 前台与后台

```bash
command &               # 丢后台运行
Ctrl+Z                  # 暂停前台任务并转到后台（stopped 状态）
bg                      # 把暂停的任务放后台继续跑
fg                      # 把后台任务调回前台
fg %2                   # 按作业号调回（jobs 里看的编号）
```

`jobs` 列出当前 shell 的后台作业：`[1]+ Running`。注意作业只在当前 shell 会话有效，关掉终端后台任务会收到 SIGHUP。

## nohup 与 disown

让任务在退出终端后继续活：

```bash
nohup command &         # 忽略挂起信号，输出进 nohup.out
nohup command > out.log 2>&1 &   # 输出重定向到指定文件
disown %1               # 把已有作业从 shell 的任务表摘掉（另一种办法）
```

本机跑长任务（构建、同步）的标准姿势：

```bash
cd ~/development/somerepo
nohup make build > /tmp/build.log 2>&1 &
# 记下 PID，之后 tail -f /tmp/build.log 看进度
```

更结构化的方式是用 tmux：任务在会话里跑，随时断连重连，见[本机环境实战](our-environment.html)。

## 优先级与资源限制

```bash
nice -n 10 command     # 以较低优先级启动（数字越大越谦让）
renice 10 -p PID       # 改已运行进程的优先级
timeout 60 command     # 60 秒后自动杀掉（跑不停命令的保险）
timeout --signal=KILL 30s cmd   # 到点强杀
watch -n 5 'command'   # 每 5 秒重复执行并全屏显示
watch -d -n 1 'ss -ltn'  # -d 高亮变化部分
```

本机跑耗资源的批量任务（截图、转码、测试）时加 `nice`，避免把 gateway 挤到 OOM。

## 内存视角

```bash
free -h                # 内存总览（本机 16GiB）
free -h -w             # 分开显示 buff/cache
ps aux --sort=-%mem | head    # 按内存占用排前 10
smem -r -p             # 按 PSS 统计（更真实，需装 smem）
cat /proc/pressure/memory  # PSI 内存压力（stall 越高越卡）
```

本机的常驻内存大户要心里有数：mapviewer 进程池（每 worker 约 0.6GiB）、一个专用 Chrome（约 1GiB）、tmux agent 会话、hermes gateway（上限 2.44G）。earlyoom 在系统内存低于 10% 时按 oom_score_adj 高的先杀，gateway 的分数最高——**全局 OOM 时它先死，表现就是 Telegram 断联**。所以起新任务前看 `free -h` 是纪律不是可选。

## 排错

**进程杀不掉**：`kill -9` 都不行，看状态是不是 `D`（不可中断睡眠，通常在等 I/O），只能等或重启。僵尸进程 `Z` 需要父进程回收，`kill` 无效。

**后台任务退出终端就消失**：没用 `nohup`/`disown`/`tmux`。

**`pkill` 误杀**：模式太宽泛。永远先 `pgrep -af 'pattern'` 再动手。

**CPU 飙高但找不到进程**：`top` 里按 `P` 排序，或 `procs --sortd cpu`；内核线程在 `ps` 里是方括号名字。

<!-- lang:en -->

> Summary: Process and job control commands such as ps, top, kill, jobs, and nohup, including practical practice under this machine's 16GiB memory constraint.

# Processes and Jobs

## Viewing processes

```bash
ps                      # 当前终端的进程
ps aux                  # 系统所有进程（经典组合）
ps -ef --forest         # 树状显示父子关系
ps u --forest -g $(id -u tetsuya)   # 本用户进程树
```

This machine has **procs** installed (a modern `ps` replacement, colored with nicer columns):

```bash
procs                  # 默认表格，CPU/内存/端口一目了然
procs node             # 按名字过滤
procs --tree           # 树状
procs --sortd cpu      # 按 CPU 占用排序
```

**Interactive monitoring**:

```bash
top          # 经典，每台机器都有
htop         # 彩色 + 鼠标操作 + 树状（本机有 btop 时优先 btop）
btop         # 本机主力：图形化资源图，支持鼠标
```

Common btop keys: `/` to search processes, `t` for tree view, `k` to kill, `q` to quit. Memory is this machine's primary constraint, so **check `free -h` available before starting any long task**; below 2GiB, think twice before launching.

## Finding processes by name

```bash
pgrep -af node          # 按名字找，-a 显示完整命令行，-f 匹配全命令行
pgrep -af 'tmux|hermes' # 多个候选
pidof node             # 只输出 PID（适合脚本）
```

Common on this machine (checking whether agent-related processes were started twice):

```bash
pgrep -af 'hermes|telegram|codex'
```

## kill and signals

```bash
kill PID                # 发 SIGTERM（15），礼貌请求退出
kill -9 PID             # SIGKILL，强杀，不给清理机会
kill -TERM PID          # 同上，显式写法
kill -HUP PID           # 挂起信号，很多程序用它重载配置
kill -STOP PID          # 暂停进程（不停在调试时有用）
kill -CONT PID          # 恢复被 STOP 的进程
pkill -f 'pattern'      # 按命令行模式杀（比 kill 危险，先 pgrep 确认）
killall node            # 按精确进程名杀
```

**The order for killing processes**: first `kill` (TERM) and wait a few seconds so the target can flush and clean up; if it doesn't exit, then `kill -9`. Going straight to `-9` can lose data (databases, files being written).

This machine's rule learned the hard way: **never use broad patterns like `pkill -f python` or `pkill node`** — they will wrongly kill the hermes gateway and other agent processes. Always `pgrep -af` first to identify PIDs, then `kill` precisely.

## Foreground and background

```bash
command &               # 丢后台运行
Ctrl+Z                  # 暂停前台任务并转到后台（stopped 状态）
bg                      # 把暂停的任务放后台继续跑
fg                      # 把后台任务调回前台
fg %2                   # 按作业号调回（jobs 里看的编号）
```

`jobs` lists the current shell's background jobs: `[1]+ Running`. Note that jobs are only valid within the current shell session; closing the terminal sends SIGHUP to background tasks.

## nohup and disown

Keeping tasks alive after you exit the terminal:

```bash
nohup command &         # 忽略挂起信号，输出进 nohup.out
nohup command > out.log 2>&1 &   # 输出重定向到指定文件
disown %1               # 把已有作业从 shell 的任务表摘掉（另一种办法）
```

The standard way to run long tasks (builds, syncs) on this machine:

```bash
cd ~/development/somerepo
nohup make build > /tmp/build.log 2>&1 &
# 记下 PID，之后 tail -f /tmp/build.log 看进度
```

A more structured approach is tmux: the task runs inside a session, and you can disconnect and reconnect at any time — see [This Machine's Environment in Practice](our-environment.html).

## Priority and resource limits

```bash
nice -n 10 command     # 以较低优先级启动（数字越大越谦让）
renice 10 -p PID       # 改已运行进程的优先级
timeout 60 command     # 60 秒后自动杀掉（跑不停命令的保险）
timeout --signal=KILL 30s cmd   # 到点强杀
watch -n 5 'command'   # 每 5 秒重复执行并全屏显示
watch -d -n 1 'ss -ltn'  # -d 高亮变化部分
```

When running resource-hungry batch jobs on this machine (screenshots, transcoding, tests), add `nice` to avoid squeezing the gateway into OOM.

## A memory perspective

```bash
free -h                # 内存总览（本机 16GiB）
free -h -w             # 分开显示 buff/cache
ps aux --sort=-%mem | head    # 按内存占用排前 10
smem -r -p             # 按 PSS 统计（更真实，需装 smem）
cat /proc/pressure/memory  # PSI 内存压力（stall 越高越卡）
```

Know this machine's resident memory heavyweights by heart: the mapviewer process pool (about 0.6GiB per worker), one dedicated Chrome (about 1GiB), tmux agent sessions, and the hermes gateway (capped at 2.44G). earlyoom kills processes with higher oom_score_adj first once system memory drops below 10%, and the gateway has the highest score — **during a global OOM it dies first, and the symptom is Telegram going silent**. So checking `free -h` before starting a new task is discipline, not optional.

## Troubleshooting

**A process won't die**: even `kill -9` fails — check whether the state is `D` (uninterruptible sleep, usually waiting on I/O); you can only wait or reboot. Zombie processes (`Z`) need their parent to reap them; `kill` has no effect.

**A background task disappears when you exit the terminal**: you didn't use `nohup`/`disown`/`tmux`.

**`pkill` killed the wrong things**: the pattern was too broad. Always run `pgrep -af 'pattern'` before acting.

**CPU is spiking but you can't find the process**: sort by `P` in `top`, or use `procs --sortd cpu`; kernel threads appear with bracketed names in `ps`.

<!-- lang:ja -->

> 要約：ps、top、kill、jobs、nohup などのプロセスとジョブ制御のコマンド。本機の 16GiB メモリ制約下での実践的なやり方も含みます。

# プロセスとジョブ

## プロセスを見る

```bash
ps                      # 当前终端的进程
ps aux                  # 系统所有进程（经典组合）
ps -ef --forest         # 树状显示父子关系
ps u --forest -g $(id -u tetsuya)   # 本用户进程树
```

本機には **procs** が入っています（`ps` のモダンな代替で、カラフルで列も見やすい）：

```bash
procs                  # 默认表格，CPU/内存/端口一目了然
procs node             # 按名字过滤
procs --tree           # 树状
procs --sortd cpu      # 按 CPU 占用排序
```

**対話型の監視**：

```bash
top          # 经典，每台机器都有
htop         # 彩色 + 鼠标操作 + 树状（本机有 btop 时优先 btop）
btop         # 本机主力：图形化资源图，支持鼠标
```

btop のよく使う操作：`/` でプロセス検索、`t` でツリー表示、`k` で kill、`q` で終了。メモリはこのマシンの最重要制約なので、**長時間タスクを起動する前に必ず `free -h` の available を確認**します。2GiB を下回っていたら、立ち上げる前に一呼吸考えましょう。

## 名前でプロセスを探す

```bash
pgrep -af node          # 按名字找，-a 显示完整命令行，-f 匹配全命令行
pgrep -af 'tmux|hermes' # 多个候选
pidof node             # 只输出 PID（适合脚本）
```

本機でよく使うコマンド（エージェント関連のプロセスが重複起動していないか確認）：

```bash
pgrep -af 'hermes|telegram|codex'
```

## kill とシグナル

```bash
kill PID                # 发 SIGTERM（15），礼貌请求退出
kill -9 PID             # SIGKILL，强杀，不给清理机会
kill -TERM PID          # 同上，显式写法
kill -HUP PID           # 挂起信号，很多程序用它重载配置
kill -STOP PID          # 暂停进程（不停在调试时有用）
kill -CONT PID          # 恢复被 STOP 的进程
pkill -f 'pattern'      # 按命令行模式杀（比 kill 危险，先 pgrep 确认）
killall node            # 按精确进程名杀
```

**プロセスを殺す順序**：まず `kill`（TERM）で数秒待ち、相手が flush とクリーンアップを行う時間を与えます。終了しなければ `kill -9`。いきなり `-9` にするとデータを失うことがあります（データベース、書き込み中のファイル）。

本機の血の教訓ルール：**`pkill -f python` や `pkill node` のような広範囲パターンは使わない** — hermes gateway や他のエージェントプロセスを誤殺します。必ず先に `pgrep -af` で PID を確認し、精密に `kill` します。

## フォアグラウンドとバックグラウンド

```bash
command &               # 丢后台运行
Ctrl+Z                  # 暂停前台任务并转到后台（stopped 状态）
bg                      # 把暂停的任务放后台继续跑
fg                      # 把后台任务调回前台
fg %2                   # 按作业号调回（jobs 里看的编号）
```

`jobs` は現在のシェルのバックグラウンドジョブを一覧します：`[1]+ Running`。ジョブは現在のシェルセッション内でのみ有効で、端末を閉じるとバックグラウンドタスクは SIGHUP を受ける点に注意してください。

## nohup と disown

端末を退出した後もタスクを生かし続ける方法：

```bash
nohup command &         # 忽略挂起信号，输出进 nohup.out
nohup command > out.log 2>&1 &   # 输出重定向到指定文件
disown %1               # 把已有作业从 shell 的任务表摘掉（另一种办法）
```

本機で長時間タスク（ビルド、同期）を走らせる標準的な形：

```bash
cd ~/development/somerepo
nohup make build > /tmp/build.log 2>&1 &
# 记下 PID，之后 tail -f /tmp/build.log 看进度
```

より構造化した方法は tmux です。タスクはセッション内で走り、いつでも切断・再接続できます。[本機環境の実践](our-environment.html)を参照してください。

## 優先度とリソース制限

```bash
nice -n 10 command     # 以较低优先级启动（数字越大越谦让）
renice 10 -p PID       # 改已运行进程的优先级
timeout 60 command     # 60 秒后自动杀掉（跑不停命令的保险）
timeout --signal=KILL 30s cmd   # 到点强杀
watch -n 5 'command'   # 每 5 秒重复执行并全屏显示
watch -d -n 1 'ss -ltn'  # -d 高亮变化部分
```

本機でリソースを食うバッチ処理（スクリーンショット、トランスコード、テスト）を走らせるときは `nice` を付けて、gateway が OOM に追い込まれないようにします。

## メモリの視点

```bash
free -h                # 内存总览（本机 16GiB）
free -h -w             # 分开显示 buff/cache
ps aux --sort=-%mem | head    # 按内存占用排前 10
smem -r -p             # 按 PSS 统计（更真实，需装 smem）
cat /proc/pressure/memory  # PSI 内存压力（stall 越高越卡）
```

本機の常駐メモリの大口は把握しておくべきです：mapviewer のプロセスプール（worker 1 個あたり約 0.6GiB）、専用 Chrome 1 個（約 1GiB）、tmux のエージェントセッション、hermes gateway（上限 2.44G）。earlyoom はシステムメモリが 10% を下回ると oom_score_adj の高い順に kill し、gateway のスコアが最も高い — **全体 OOM の時は最初に死に、症状は Telegram の無反応です**。だから新しいタスクを起動する前に `free -h` を見るのは規律であって、任意ではありません。

## トラブルシューティング

**プロセスが殺せない**：`kill -9` でも駄目な場合は、状態が `D`（割り込み不可能なスリープ、通常は I/O 待ち）になっていないか見ます。待つか再起動するしかありません。ゾンビプロセス（`Z`）は親プロセスが回収する必要があり、`kill` は無効です。

**バックグラウンドタスクが端末を退出すると消える**：`nohup`/`disown`/`tmux` を使っていないからです。

**`pkill` で誤殺した**：パターンが広すぎました。必ず先に `pgrep -af 'pattern'` を実行してから手を動かします。

**CPU が跳ね上がっているのにプロセスが見つからない**：`top` で `P` キーでソートするか、`procs --sortd cpu` を使います。カーネルスレッドは `ps` では角括弧付きの名前で表示されます。
