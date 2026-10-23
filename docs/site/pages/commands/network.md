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

<!-- lang:en -->

> Summary: Network commands such as ip, ss, curl, ssh, rsync, and tailscale, including the actual paths for remote access on this machine.

# Networking and Transfer

## Checking network status

```bash
ip addr                 # 网卡与 IP（取代 ifconfig）
ip -br addr             # 精简表格，日常看这个
ip route                # 路由表（默认网关）
ip link                 # 链路状态（up/down）
```

`ip` is the modern unified replacement for `net-tools` (`ifconfig`/`route`/`arp`), and Debian 13 ships only `ip` by default. Remembering three subcommands is enough: `addr`, `route`, `link`.

## Ports and connections

```bash
ss -ltn                  # 监听中的 TCP 端口（-l listen -t tcp -n 数字）
ss -ltnp                 # 连进程名一起显示（sudo 才看得到别人的进程）
ss -ltnp | rg 8645       # 查某端口被谁占（本机常用）
ss -s                    # 汇总统计
ss -tn state established dst:1.1.1.1   # 到某目标的已建立连接
```

**Troubleshooting an occupied port** (when starting a service reports `address already in use`):

```bash
ss -ltnp | rg ':端口号'
# 找到 PID，再 ps -p PID 看是什么程序，决定杀掉还是换端口
```

This machine runs many services (the dashboard, web projects, proxies), so check ports before starting a new service. On the firewall side you can also inspect rules with `sudo nft list ruleset` (nftables), but this machine mainly relies on the PVE host and Tailscale as its boundary, so in-system rules are minimal.

## Connectivity tests

```bash
ping host               # ICPM 探测（Ctrl+C 停）
ping -c 4 host          # 发 4 个包自动停（脚本里必须加 -c）
```

This machine has **gping** installed for multi-target latency curves:

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

DNS troubleshooting order: check the resolution with `dig` → compare the nameserver in `/etc/resolv.conf` → `systemctl status systemd-resolved`.

## curl and wget

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

This machine also has **HTTPie** (the `http` command), which is more human-friendly:

```bash
http GET example.com/api
http POST example.com/api name=test   # 表单
http --json POST example.com/api a:=1 # JSON
```

The `curl -w '%{http_code}'` combination is the standard pattern for cron health checks on this machine: only a 200 counts as up.

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

Memory aid for the common options: `-N` no shell, `-f` background, `-C` compression (useful on slow links).

**Keeping long-lived connections** (so editing remote files doesn't drop): in `~/.ssh/config`:

```ssh
Host *
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

**Keys**: generate with `ssh-keygen -t ed25519 -C "comment"`, and install the public key on the remote with `ssh-copy-id host`. Private key permissions must be 600.

SSH access to the NAS on this machine goes through the wrapper script `vssh`; see [SSH and SSHFS](../scripts/ssh.html).

## SCP and rsync

```bash
scp file user@host:/path/           # 上传
scp user@host:/path/file .          # 下载
scp -r dir user@host:/path/         # 递归目录
scp -P 2222 file user@host:         # -P 指定端口（和 ssh 的 -p 大小写不同！）
```

**rsync is the tool for real work**: incremental, resumable, verifiable:

```bash
rsync -av src/ user@host:/dst/          # 归档模式同步（-a 保留权限时间）
rsync -avz src/ user@host:/dst/         # 压缩传输
rsync -av --delete src/ /backup/dst/    # 镜像：删掉目标里多出的（先 dry-run！）
rsync -avn src/ dst/                    # -n 干跑，只看会传什么
rsync -av --exclude='.git' --exclude='node_modules' src/ dst/
rsync -av -e ssh --bwlimit=2000 src/ user@host:/dst/  # 限速 2MB/s
```

**Mandatory before `--delete`**: run `rsync -avn --delete src/ dst/` to review the list and confirm nothing will be wrongly deleted. A reversed sync direction (dst→src) combined with `--delete` is the classic data-extinction accident.

The standard combination for NAS backups and repository syncs on this machine: `rsync -av --delete --exclude=.git 源/ 目标/`.

## Tailscale

This machine forms a virtual internal network through Tailscale, so remote access never crosses the public internet:

```bash
tailscale status            # 看节点列表和在线状态
tailscale ip -4             # 本节点地址
tailscale ping host         # 测延迟（走 DERP 的话延迟会高）
tailscale up               # 启动/重连
tailscale down             # 断开（保留登录）
```

This machine exposes services via its Tailscale IP with HTTPS terminated by `tailscale serve`; browsers access it directly by MagicDNS name, and no public ports are opened.

## Troubleshooting

**`ssh: Connection refused`**: the target sshd is not running or the port is wrong; `Connection timed out` is a firewall/routing problem; `Permission denied (publickey)` is a key problem — use `ssh -v` to inspect the authentication process.

**`scp` reports `lost connection` on large files**: switch to `rsync -avz --partial`, which can resume transfers.

**Accidental deletion by `rsync --delete`**: stop all further operations immediately and restore from backup; without a backup, accept the loss. That is why dry-run is a mandatory step.

**Slow DNS resolution**: measure response time with `dig`, consider switching to a faster resolver in `/etc/resolv.conf`, or run systemd-resolved locally for caching.

**`curl` hangs**: add `--max-time`. Every curl in scripts on this machine carries a timeout; otherwise network jitter will hang cron jobs.

<!-- lang:ja -->

> 要約：ip、ss、curl、ssh、rsync、tailscale などのネットワークコマンド。本機でのリモートアクセスの実際の経路も含みます。

# ネットワークと転送

## ネットワーク状態の確認

```bash
ip addr                 # 网卡与 IP（取代 ifconfig）
ip -br addr             # 精简表格，日常看这个
ip route                # 路由表（默认网关）
ip link                 # 链路状态（up/down）
```

`ip` は現代的な `net-tools`（`ifconfig`/`route`/`arp`）の統合代替ツールで、Debian 13 はデフォルトで `ip` のみを同梱しています。覚える必要があるのは `addr`、`route`、`link` の 3 つのサブコマンドだけです。

## ポートと接続

```bash
ss -ltn                  # 监听中的 TCP 端口（-l listen -t tcp -n 数字）
ss -ltnp                 # 连进程名一起显示（sudo 才看得到别人的进程）
ss -ltnp | rg 8645       # 查某端口被谁占（本机常用）
ss -s                    # 汇总统计
ss -tn state established dst:1.1.1.1   # 到某目标的已建立连接
```

**ポートが占有されているときの調査**（サービス起動時に `address already in use` が出たとき）：

```bash
ss -ltnp | rg ':端口号'
# 找到 PID，再 ps -p PID 看是什么程序，决定杀掉还是换端口
```

本機ではサービスが多い（ダッシュボード、Web プロジェクト、プロキシ）ため、新しいサービスを起動する前にポートを確認します。ファイアウォール側は `sudo nft list ruleset`（nftables）でルールを確認できますが、本機は主に PVE ホストと Tailscale を境界としており、システム内のルールはごく薄いものです。

## 接続テスト

```bash
ping host               # ICPM 探测（Ctrl+C 停）
ping -c 4 host          # 发 4 个包自动停（脚本里必须加 -c）
```

本機には **gping** が入っており、複数ターゲットのレイテンシ曲線を描けます：

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

DNS 問題の調査順序：`dig` で名前解決結果を確認 → `/etc/resolv.conf` の nameserver と比較 → `systemctl status systemd-resolved`。

## curl と wget

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

本機にはより人間に優しい **HTTPie**（`http` コマンド）もあります：

```bash
http GET example.com/api
http POST example.com/api name=test   # 表单
http --json POST example.com/api a:=1 # JSON
```

`curl -w '%{http_code}'` の組み合わせは、本機の cron ヘルスチェックの標準的な書き方です。200 が返ってきて初めて正常と判断します。

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

よく使うオプションの覚え方：`-N` はシェルを開かない、`-f` はバックグラウンド、`-C` は圧縮（遅い回線で有用）。

**長時間接続を維持する**（リモートのファイル編集中に切断されないようにする）：`~/.ssh/config` に：

```ssh
Host *
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

**鍵**：`ssh-keygen -t ed25519 -C "comment"` で生成し、公開鍵は `ssh-copy-id host` でリモートに設置します。秘密鍵のパーミッションは必ず 600 にします。

本機から NAS への SSH アクセスはラッパースクリプト `vssh` を使います。詳細は [SSH と SSHFS](../scripts/ssh.html) を参照してください。

## SCP と rsync

```bash
scp file user@host:/path/           # 上传
scp user@host:/path/file .          # 下载
scp -r dir user@host:/path/         # 递归目录
scp -P 2222 file user@host:         # -P 指定端口（和 ssh 的 -p 大小写不同！）
```

**本業に使うのは rsync です**：差分転送・中断からの再開・検証に対応します：

```bash
rsync -av src/ user@host:/dst/          # 归档模式同步（-a 保留权限时间）
rsync -avz src/ user@host:/dst/         # 压缩传输
rsync -av --delete src/ /backup/dst/    # 镜像：删掉目标里多出的（先 dry-run！）
rsync -avn src/ dst/                    # -n 干跑，只看会传什么
rsync -av --exclude='.git' --exclude='node_modules' src/ dst/
rsync -av -e ssh --bwlimit=2000 src/ user@host:/dst/  # 限速 2MB/s
```

**`--delete` の前に必ず行うこと**：`rsync -avn --delete src/ dst/` でリストを確認し、誤って削除されるものがないか確かめます。同期方向を逆（dst→src）にして `--delete` を付けるのは、典型的なデータ全滅事故です。

本機の NAS バックアップやリポジトリ同期の標準的な組み合わせは `rsync -av --delete --exclude=.git 源/ 目标/` です。

## Tailscale

本機は Tailscale で仮想内部ネットワークを構成しており、遠隔アクセスは公網を経由しません：

```bash
tailscale status            # 看节点列表和在线状态
tailscale ip -4             # 本节点地址
tailscale ping host         # 测延迟（走 DERP 的话延迟会高）
tailscale up               # 启动/重连
tailscale down             # 断开（保留登录）
```

本機が外部にサービスを提供する経路は、Tailscale IP + HTTPS を終端する `tailscale serve` です。ブラウザからは MagicDNS 名で直接アクセスし、公網ポートは開きません。

## トラブルシューティング

**`ssh: Connection refused`**：接続先の sshd が起動していないかポートが間違っています。`Connection timed out` はファイアウォール/ルーティングの問題、`Permission denied (publickey)` は鍵の問題です。`ssh -v` で認証過程を確認します。

**大容量ファイル転送中に `scp` が `lost connection` を出す**：`rsync -avz --partial` に切り替えると中断から再開できます。

**`rsync --delete` で誤削除した場合**：直ちに後続の操作を止め、バックアップから復元します。バックアップがなければ諦めるしかありません。だからこそ dry-run は必須のステップなのです。

**DNS 解決が遅い**：`dig` で応答時間を測り、`/etc/resolv.conf` を高速な resolver に変えるか、ローカルで systemd-resolved のキャッシュを使うことを検討します。

**`curl` が固まる**：`--max-time` を付けます。本機のスクリプト内の curl はすべてタイムアウト付きです。付けないとネットワークの揺らぎで cron ジョブが固まってしまいます。
