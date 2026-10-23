> 摘要：ip、ss、curl、ssh、rsync、tailscale 等网络命令，含本机远程访问的实际路径。

# 网络与传输

## 看网络状态

```bash
ip addr                 # 网卡与 IP（取代 ifconfig）
ip -br addr             # 精简表格，日常看这个
ip route                # 路由表（默认网关）
ip link                 # 链路状态（up/down）
```

`ip` 是现代 `net-tools`（`ifconfig`/`route`/`arp`）的统一替代品，Debian 13 默认只带 `ip`。记三个子命令就够：`addr`、`route`、`link`。

## 端口与连接

```bash
ss -ltn                  # 监听中的 TCP 端口（-l listen -t tcp -n 数字）
ss -ltnp                 # 连进程名一起显示（sudo 才看得到别人的进程）
ss -ltnp | rg 8645       # 查某端口被谁占（本机常用）
ss -s                    # 汇总统计
ss -tn state established dst:1.1.1.1   # 到某目标的已建立连接
```

**端口被占的排查**（启动服务报 `address already in use` 时）：

```bash
ss -ltnp | rg ':端口号'
# 找到 PID，再 ps -p PID 看是什么程序，决定杀掉还是换端口
```

本机服务多（面板、Web 项目、代理），起新服务前先查端口。防火墙侧还有 `sudo nft list ruleset`（nftables）可看规则，但本机主要靠 PVE 宿主和 Tailscale 做边界，系统内规则很薄。

## 连通性测试

```bash
ping host               # ICPM 探测（Ctrl+C 停）
ping -c 4 host          # 发 4 个包自动停（脚本里必须加 -c）
```

本机装了 **gping**，多目标延迟曲线：

```bash
gping 1.1.1.1 8.8.8.8   # 同时测多个，图形化延迟变化
```

```bash
traceroute host         # 路径追踪（tracepath 不需要 root）
mtr host                # 实时版 traceroute，看每一跳丢包
dig domain             # DNS 查询（装 dnsutils）
dig +short domain A    # 只要 IP
nslookup domain        # 老牌工具，脚本里少用
host domain            # 简洁版
```

DNS 问题的排查顺序：`dig` 看解析结果 → 对比 `/etc/resolv.conf` 里的 nameserver → `systemctl status systemd-resolved`。

## curl 与 wget

```bash
curl https://api.github.com            # GET，输出到 stdout
curl -I https://example.com            # 只要响应头
curl -s https://api.github.com | jq .  # 静默 + JSON 格式化
curl -o file.zip URL                   # 下载到文件
curl -L URL                            # 跟随重定向（GitHub 下载必加）
curl -H "Authorization: token xxx" URL # 带头（脚本里注意别把 token 落进日志）
curl -X POST -d '{"a":1}' URL          # POST JSON
curl -w '%{http_code}\n' -o /dev/null -s URL   # 只要状态码（健康检查神器）
curl --max-time 10 URL                 # 超时保护
wget URL                               # 下载（保留原名）
wget -c URL                            # 断点续传
```

本机还有 **HTTPie**（`http` 命令），更人性化：

```bash
http GET example.com/api
http POST example.com/api name=test   # 表单
http --json POST example.com/api a:=1 # JSON
```

`curl -w '%{http_code}'` 组合是本机 cron 健康检查的标准写法：返回 200 才算通。

## SSH

```bash
ssh user@host                  # 登录
ssh -p 2222 user@host          # 指定端口
ssh -i ~/.ssh/id_ed25519 host  # 指定私钥
ssh -J jump@bastion user@internal   # 跳板机
ssh -L 8080:localhost:80 host  # 本地端口转发（把远端服务映射到本机）
ssh -R 9000:localhost:3000 host # 远程端口转发
ssh -N -f host                 # 只建隧道不执行命令，后台化
```

常用选项记忆：`-N` 不开 shell、`-f` 后台、`-C` 压缩（慢链路有用）。

**保持长连接**（编辑远端文件不断线）：`~/.ssh/config` 里

```ssh
Host *
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

**密钥**：`ssh-keygen -t ed25519 -C "comment"` 生成，公钥 `ssh-copy-id host` 装到远端。私钥权限必须 600。

本机对 NAS 的 SSH 访问用包装脚本 `vssh`，见 [SSH 与 SSHFS](../scripts/ssh.html)。

## SCP 与 rsync

```bash
scp file user@host:/path/           # 上传
scp user@host:/path/file .          # 下载
scp -r dir user@host:/path/         # 递归目录
scp -P 2222 file user@host:         # -P 指定端口（和 ssh 的 -p 大小写不同！）
```

**rsync 才是干正事的**：增量、可断点、可校验：

```bash
rsync -av src/ user@host:/dst/          # 归档模式同步（-a 保留权限时间）
rsync -avz src/ user@host:/dst/         # 压缩传输
rsync -av --delete src/ /backup/dst/    # 镜像：删掉目标里多出的（先 dry-run！）
rsync -avn src/ dst/                    # -n 干跑，只看会传什么
rsync -av --exclude='.git' --exclude='node_modules' src/ dst/
rsync -av -e ssh --bwlimit=2000 src/ user@host:/dst/  # 限速 2MB/s
```

**`--delete` 前必做**：`rsync -avn --delete src/ dst/` 看清单，确认没有会误删的。反了的同步方向（dst→src）加 `--delete` 是经典数据灭绝事故。

本机 NAS 备份、仓库同步的标准组合：`rsync -av --delete --exclude=.git 源/ 目标/`。

## Tailscale

本机通过 Tailscale 组成虚拟内网，异地访问不走公网：

```bash
tailscale status            # 看节点列表和在线状态
tailscale ip -4             # 本节点地址
tailscale ping host         # 测延迟（走 DERP 的话延迟会高）
tailscale up               # 启动/重连
tailscale down             # 断开（保留登录）
```

本机对外提供服务的路径是 Tailscale IP + `tailscale serve` 终止 HTTPS，浏览器直接用 MagicDNS 名字访问，不开公网端口。

## 排错

**`ssh: Connection refused`**：目标 sshd 没起或端口错；`Connection timed out` 是防火墙/路由问题；`Permission denied (publickey)` 是密钥问题，`ssh -v` 看认证过程。

**`scp` 报 `lost connection` 传大文件**：换 `rsync -avz --partial`，可断点续传。

**`rsync --delete` 误删**：立即停止后续操作，从备份恢复；没有备份就认了。所以 dry-run 是强制步骤。

**DNS 解析慢**：`dig` 测响应时间，考虑 `/etc/resolv.conf` 换快的 resolver，或本地跑 systemd-resolved 缓存。

**`curl` 卡住不动**：加 `--max-time`。本机脚本里的 curl 一律带超时，否则网络抖动会把 cron 任务挂死。
