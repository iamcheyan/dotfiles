> 摘要：uname、lscpu、free、journalctl、systemctl 等系统信息与服务管理命令，日志排查的标准流程。

# 系统信息与日志

## 系统身份

```bash
hostnamectl                    # 主机名、内核、操作系统一屏总览
uname -a                       # 内核版本 + 架构（经典）
uname -r                       # 只要内核版本号
cat /etc/os-release            # 发行版信息（脚本里判断 Debian/Arch 用它）
cat /etc/debian_version        # Debian 专属版本号
lsb_release -a                 # LSB 标准格式（可能没装）
```

本机是 Debian 13（trixie），VM 跑在 PVE 上。另一台常管的机器是 NixOS，两边的命令差异见[软件包管理](packages.html)。

## 硬件信息

```bash
lscpu                          # CPU 型号、核数、架构
lscpu | rg -i 'model name|core|thread'   # 只要关键行
free -h                        # 内存
lsmem                          # 内存条布局
lsusb                          # USB 设备
lspci                          # PCI 设备（显卡、网卡）
sensors                        # 温度（装 lm-sensors）
```

本机是 16GiB / 4 核，**内存是首要约束**：`free -h` 的 available 低于 2GiB 就不要起新的重任务了。

## 运行状态

```bash
uptime                         # 开机时长 + 1/5/15 分钟负载
uptime -p                      # 只要"up 3 days"这种
w                              # 谁登录了、在干什么
last                           # 登录历史
lastb                          # 失败登录（root 才看得到）
who                            # 当前登录会话
```

负载数字的含义：4 核机器上 load 4.0 是满负荷，持续高于核数说明有东西在吃 CPU。

## 内核与模块

```bash
dmesg                          # 内核环形缓冲区（启动日志、硬件事件）
dmesg -T                       # 带人类可读时间戳
dmesg -l err,warn              # 只要错误和警告
dmesg -w                       # 实时跟踪（等价 tail -f /dev/kmsg）
lsmod                          # 已加载内核模块
modinfo 模块名                  # 模块信息
```

**本机排障第一现场**：USB 设备识别、磁盘 I/O 错误、OOM killer 记录、网卡 up/down，全在 `dmesg` 里。OOM 的记录长这样：`Out of memory: Killed process 1234 (node) ...`——看到这行就知道刚才为什么进程消失了。

## systemd 与服务

```bash
systemctl status nginx         # 服务状态（最近日志也一起显示）
systemctl start/stop/restart nginx
systemctl enable nginx         # 开机自启
systemctl disable nginx
systemctl is-active nginx      # 只要 active/inactive（脚本用）
systemctl is-enabled nginx
systemctl --failed             # 所有启动失败的服务
systemctl list-units --type=service --state=running
systemctl daemon-reload        # 改过 unit 文件后重载
```

**用户级服务**（本机大量使用，hermes gateway、桌面、定时任务都是用户服务）：

```bash
systemctl --user status hermes-gateway
systemctl --user restart webdesktop
systemctl --user list-units --type=service --all | rg -i 'hermes|gateway'
```

用户服务在**没有图形登录会话时默认不启动**，本机开了 linger 才保证注销后继续跑：`loginctl show-user tetsuya | rg Linger`。

**定时任务**：

```bash
systemctl list-timers          # 所有 systemd 定时器及下次触发
systemctl --user list-timers
crontab -l                     # 当前用户 cron
crontab -e                     # 编辑
```

## journalctl 日志

```bash
journalctl -u nginx            # 某服务的日志
journalctl -u nginx -f         # 实时跟踪
journalctl -u nginx --since today
journalctl -u nginx --since '1 hour ago'
journalctl -p err -b           # 本次启动以来的错误
journalctl -k                  # 内核日志（不用 dmesg 的另一种方式）
journalctl --disk-usage        # 日志占多少空间
sudo journalctl --vacuum-size=200M   # 清理到 200M
```

日志排障三板斧：

```bash
systemctl status 服务名         # 1. 状态 + 最近日志
journalctl -u 服务名 -n 100     # 2. 最近 100 条完整日志
journalctl -u 服务名 -p err -b  # 3. 只看错误
```

## 本机服务排查套路

本机服务分几层，排查时先定位：

| 层 | 查看方式 |
|---|---|
| 用户级 systemd 服务 | `systemctl --user status <name>` |
| root 级 systemd 服务 | `systemctl status <name>` |
| Docker 容器 | `docker ps -a`、`docker logs <容器>` |
| PVE 层（宿主机） | **本机管不到**，是 VM 客户端 |

排查顺序：进程在不在（`pgrep -af`）→ 端口通不通（`ss -ltnp`）→ HTTP 响应正不正常（`curl -w '%{http_code}'`）→ 日志说什么（`journalctl -u` / `docker logs`）。

**"进程还在"不等于"功能正常"**——本机判定服务健康的终点永远是真实请求：`curl` 一次接口、看一次真实响应。

## 排错

**`systemctl status` 显示 `activating` 不动**：看日志 `journalctl -u xxx -f`，常见是 ExecStart 命令路径错或配置语法错。

**改了 unit 文件不生效**：`systemctl daemon-reload` 后 restart。

**用户服务没开机自启**：`systemctl --user enable xxx` + 确认 linger 开着。

**`dmesg` 要 root**：普通用户看不了内核日志，`sudo dmesg`；或者用 `journalctl -k`（如果用户在 systemd-journal 组）。

**日志把磁盘写满**：`journalctl --disk-usage` 看，`--vacuum-size` 清。日志暴涨的服务先修服务再清日志。
