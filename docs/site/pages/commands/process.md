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
