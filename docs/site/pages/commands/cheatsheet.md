> 摘要：按任务组织的命令速查表：日常高频组合、管道模式、危险命令清单。

# 速查表

## 日常高频 Top 20

```bash
l / ll / la                      # eza 列表（本机 l 不是 ls）
z 目录名                          # zoxide 跳转
f 关键词                          # 搜文件并打开
fd 名称 / rg 内容                 # 找文件 / 搜内容
bat 文件                          # 带高亮看文件
cd -                             # 回上一个目录
sudo !!                          # sudo 重跑上一条
tail -f 日志                      # 跟踪日志
Ctrl+R                           # 历史搜索（Atuin）
Ctrl+T                           # fzf 选文件插到命令行
htop / btop                      # 看资源
df -h && du -sh 目录              # 空间二连
ss -ltnp | rg 端口                # 查端口占用
kill PID / kill -9 PID            # 杀进程
curl -w '%{http_code}' URL        # 探活
tar --zstd -cf a.tar.zst dir/     # 打包
rsync -av src/ dst/               # 同步
git status && git log --oneline -5
tmux a -t main                    # 接回会话
systemctl --user status 服务       # 看服务
```

## 管道组合模式

```bash
# 频率统计（日志分析万能公式）
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# 找大文件 Top 10
du -h ~/* 2>/dev/null | sort -rh | head

# 交互式删除候选（先看不删）
rg -l TODO ~/dev | fzf

# 搜索结果直接编辑
rg -l 'pattern' | fzf | xargs nvim

# 监控命令输出变化
watch -d -n 2 'ss -ltn'

# JSON 处理链
gh pr list --json number,title | jq -r '.[] | "\(.number)\t\(.title)"'

# 批量重命名（sd 版）
ls *.txt | while read f; do sd 'old' 'new' <<< "$f"; done

# 一行 for 循环
for d in ~/development/*/; do git -C "$d" pull --ff-only -q; done
```

## 权限速查

```bash
chmod +x f        # 可执行
chmod 600 f       # 私密文件 / 私钥
chmod 644 f       # 普通文件
chmod 755 d       # 可进入目录
chmod -R u=rwX,go= dir/   # 目录归自己
chown user:grp f  # 改归属
sudo !!           # 忘了 sudo
```

## 进程三连

```bash
pgrep -af 名字     # 找
ss -ltnp | rg 端口 # 占
kill PID           # 杀（先 TERM 后 -9）
```

## 危险命令清单（执行前停三秒）

| 命令 | 危险点 |
|---|---|
| `rm -rf 路径` | 没有回收站；路径变量为空时 `rm -rf $VAR/` 会变成 `rm -rf /` |
| `mkfs.* /dev/sdX` | 设备名错一位 = 数据全没 |
| `dd if=... of=/dev/sdX` | 同上，且写错不提示 |
| `rsync --delete` 方向反了 | 把备份删成源的样子 |
| `chmod -R 777 /` | 系统性破坏 |
| `usermod -G` 漏 `-a` | 把人从所有组删掉 |
| `pkill -f python` / `pkill node` | 误杀 gateway 和 agent |
| `docker compose down -v` | 删卷，生产数据没了 |
| `pacman -Sy 包名` | Arch 局部升级，官方明令禁止 |
| `: > /dev/sda` | 直接写块设备 |

## 网络诊断顺序

```bash
ip -br addr                  # 1. 我有地址吗
ip route                     # 2. 网关通吗
ping -c4 网关                 # 3. 内网通吗
dig 域名                      # 4. DNS 对吗
curl -w '%{http_code}' URL   # 5. 服务通吗
ss -ltnp                     # 6. 端口在听吗
tailscale status             # 7. 远程入口在吗
```

## 日志三连

```bash
systemctl status 服务名
journalctl -u 服务名 -n 100
journalctl -u 服务名 -p err -b
```

## 本机专属

```bash
export GH_CONFIG_DIR=~/.config/gh     # gh 认证目录（cron/脚本必带）
free -h                                # 起任务前看内存
tmux a -t main || tmux new -s main     # 会话接回
webdesktop status                      # 无头桌面
docker compose -C ~/<项目> logs -f      # 容器日志
```

## 一屏命令速查卡（打印贴墙）

```
文件    l ll la · z 目录 · cd - · mkdir -p · cp -a · ln -sfn
文本    cat less head tail · rg pattern · sd old new · awk '{print $1}' · jq .
查找    fd 名 · fd -e py · which · type -a · fzf (Ctrl+T)
进程    btop · pgrep -af · kill PID · jobs · nohup cmd & · nice -n 10
权限    chmod +x/600/644/755 · sudo !! · umask 077
磁盘    df -h · du -sh · ncdu · lsblk · mount -a
网络    ip -br addr · ss -ltnp · curl -w '%{http_code}' · ssh -L · rsync -av
系统    hostnamectl · free -h · dmesg -T · journalctl -u · systemctl --user
打包    tar --zstd -cf/xf · zip -r · unzip -l · 7z x
```

<!-- lang:en -->

> Summary: A task-oriented command cheatsheet: everyday high-frequency combinations, pipeline patterns, and a list of dangerous commands.

# Cheatsheet

## Everyday Top 20

```bash
l / ll / la                      # eza 列表（本机 l 不是 ls）
z 目录名                          # zoxide 跳转
f 关键词                          # 搜文件并打开
fd 名称 / rg 内容                 # 找文件 / 搜内容
bat 文件                          # 带高亮看文件
cd -                             # 回上一个目录
sudo !!                          # sudo 重跑上一条
tail -f 日志                      # 跟踪日志
Ctrl+R                           # 历史搜索（Atuin）
Ctrl+T                           # fzf 选文件插到命令行
htop / btop                      # 看资源
df -h && du -sh 目录              # 空间二连
ss -ltnp | rg 端口                # 查端口占用
kill PID / kill -9 PID            # 杀进程
curl -w '%{http_code}' URL        # 探活
tar --zstd -cf a.tar.zst dir/     # 打包
rsync -av src/ dst/               # 同步
git status && git log --oneline -5
tmux a -t main                    # 接回会话
systemctl --user status 服务       # 看服务
```

## Pipeline patterns

```bash
# 频率统计（日志分析万能公式）
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# 找大文件 Top 10
du -h ~/* 2>/dev/null | sort -rh | head

# 交互式删除候选（先看不删）
rg -l TODO ~/dev | fzf

# 搜索结果直接编辑
rg -l 'pattern' | fzf | xargs nvim

# 监控命令输出变化
watch -d -n 2 'ss -ltn'

# JSON 处理链
gh pr list --json number,title | jq -r '.[] | "\(.number)\t\(.title)"'

# 批量重命名（sd 版）
ls *.txt | while read f; do sd 'old' 'new' <<< "$f"; done

# 一行 for 循环
for d in ~/development/*/; do git -C "$d" pull --ff-only -q; done
```

## Permissions cheatsheet

```bash
chmod +x f        # 可执行
chmod 600 f       # 私密文件 / 私钥
chmod 644 f       # 普通文件
chmod 755 d       # 可进入目录
chmod -R u=rwX,go= dir/   # 目录归自己
chown user:grp f  # 改归属
sudo !!           # 忘了 sudo
```

## The process trio

```bash
pgrep -af 名字     # 找
ss -ltnp | rg 端口 # 占
kill PID           # 杀（先 TERM 后 -9）
```

## Dangerous commands (pause three seconds before running)

| Command | Danger |
|---|---|
| `rm -rf 路径` | No trash can; if the path variable is empty, `rm -rf $VAR/` becomes `rm -rf /` |
| `mkfs.* /dev/sdX` | One character off in the device name = all data gone |
| `dd if=... of=/dev/sdX` | Same as above, and a wrong target is written without prompting |
| `rsync --delete` with the direction reversed | Deletes the backup into the shape of the source |
| `chmod -R 777 /` | Systemic destruction |
| `usermod -G` missing `-a` | Removes the user from all groups |
| `pkill -f python` / `pkill node` | Kills the gateway and agents by mistake |
| `docker compose down -v` | Deletes volumes; production data is gone |
| `pacman -Sy 包名` | Partial upgrade on Arch, officially forbidden |
| `: > /dev/sda` | Writes directly to a block device |

## Network diagnosis order

```bash
ip -br addr                  # 1. 我有地址吗
ip route                     # 2. 网关通吗
ping -c4 网关                 # 3. 内网通吗
dig 域名                      # 4. DNS 对吗
curl -w '%{http_code}' URL   # 5. 服务通吗
ss -ltnp                     # 6. 端口在听吗
tailscale status             # 7. 远程入口在吗
```

## The log trio

```bash
systemctl status 服务名
journalctl -u 服务名 -n 100
journalctl -u 服务名 -p err -b
```

## Machine-specific

```bash
export GH_CONFIG_DIR=~/.config/gh     # gh 认证目录（cron/脚本必带）
free -h                                # 起任务前看内存
tmux a -t main || tmux new -s main     # 会话接回
webdesktop status                      # 无头桌面
docker compose -C ~/<项目> logs -f      # 容器日志
```

## One-screen command card (print and stick on the wall)

```
文件    l ll la · z 目录 · cd - · mkdir -p · cp -a · ln -sfn
文本    cat less head tail · rg pattern · sd old new · awk '{print $1}' · jq .
查找    fd 名 · fd -e py · which · type -a · fzf (Ctrl+T)
进程    btop · pgrep -af · kill PID · jobs · nohup cmd & · nice -n 10
权限    chmod +x/600/644/755 · sudo !! · umask 077
磁盘    df -h · du -sh · ncdu · lsblk · mount -a
网络    ip -br addr · ss -ltnp · curl -w '%{http_code}' · ssh -L · rsync -av
系统    hostnamectl · free -h · dmesg -T · journalctl -u · systemctl --user
打包    tar --zstd -cf/xf · zip -r · unzip -l · 7z x
```

<!-- lang:ja -->

> 摘要：タスク別に整理したコマンド速査表：日常の高頻度組み合わせ、パイプラインパターン、危険なコマンド一覧。

# 速査表（チートシート）

## 日常の高頻度 Top 20

```bash
l / ll / la                      # eza 列表（本机 l 不是 ls）
z 目录名                          # zoxide 跳转
f 关键词                          # 搜文件并打开
fd 名称 / rg 内容                 # 找文件 / 搜内容
bat 文件                          # 带高亮看文件
cd -                             # 回上一个目录
sudo !!                          # sudo 重跑上一条
tail -f 日志                      # 跟踪日志
Ctrl+R                           # 历史搜索（Atuin）
Ctrl+T                           # fzf 选文件插到命令行
htop / btop                      # 看资源
df -h && du -sh 目录              # 空间二连
ss -ltnp | rg 端口                # 查端口占用
kill PID / kill -9 PID            # 杀进程
curl -w '%{http_code}' URL        # 探活
tar --zstd -cf a.tar.zst dir/     # 打包
rsync -av src/ dst/               # 同步
git status && git log --oneline -5
tmux a -t main                    # 接回会话
systemctl --user status 服务       # 看服务
```

## パイプラインの定番パターン

```bash
# 频率统计（日志分析万能公式）
awk '{print $1}' access.log | sort | uniq -c | sort -rn | head

# 找大文件 Top 10
du -h ~/* 2>/dev/null | sort -rh | head

# 交互式删除候选（先看不删）
rg -l TODO ~/dev | fzf

# 搜索结果直接编辑
rg -l 'pattern' | fzf | xargs nvim

# 监控命令输出变化
watch -d -n 2 'ss -ltn'

# JSON 处理链
gh pr list --json number,title | jq -r '.[] | "\(.number)\t\(.title)"'

# 批量重命名（sd 版）
ls *.txt | while read f; do sd 'old' 'new' <<< "$f"; done

# 一行 for 循环
for d in ~/development/*/; do git -C "$d" pull --ff-only -q; done
```

## パーミッション速査

```bash
chmod +x f        # 可执行
chmod 600 f       # 私密文件 / 私钥
chmod 644 f       # 普通文件
chmod 755 d       # 可进入目录
chmod -R u=rwX,go= dir/   # 目录归自己
chown user:grp f  # 改归属
sudo !!           # 忘了 sudo
```

## プロセス三連

```bash
pgrep -af 名字     # 找
ss -ltnp | rg 端口 # 占
kill PID           # 杀（先 TERM 后 -9）
```

## 危険なコマンド一覧（実行前に 3 秒立ち止まる）

| コマンド | 危険ポイント |
|---|---|
| `rm -rf 路径` | ゴミ箱はない。パス変数が空だと `rm -rf $VAR/` が `rm -rf /` になる |
| `mkfs.* /dev/sdX` | デバイス名が 1 文字ずれる = データ全損 |
| `dd if=... of=/dev/sdX` | 同上。しかも誤書き込みは警告なし |
| `rsync --delete` の向きを逆に | バックアップをソースの形に削り替える |
| `chmod -R 777 /` | システム全体の破壊 |
| `usermod -G` に `-a` を付け忘れ | ユーザーを全グループから外す |
| `pkill -f python` / `pkill node` | gateway や agent を誤殺 |
| `docker compose down -v` | ボリューム削除、本番データ消失 |
| `pacman -Sy 包名` | Arch の部分アップグレード、公式が明確に禁止 |
| `: > /dev/sda` | ブロックデバイスへ直接書き込み |

## ネットワーク診断の順序

```bash
ip -br addr                  # 1. 我有地址吗
ip route                     # 2. 网关通吗
ping -c4 网关                 # 3. 内网通吗
dig 域名                      # 4. DNS 对吗
curl -w '%{http_code}' URL   # 5. 服务通吗
ss -ltnp                     # 6. 端口在听吗
tailscale status             # 7. 远程入口在吗
```

## ログ三連

```bash
systemctl status 服务名
journalctl -u 服务名 -n 100
journalctl -u 服务名 -p err -b
```

## 本機固有

```bash
export GH_CONFIG_DIR=~/.config/gh     # gh 认证目录（cron/脚本必带）
free -h                                # 起任务前看内存
tmux a -t main || tmux new -s main     # 会话接回
webdesktop status                      # 无头桌面
docker compose -C ~/<项目> logs -f      # 容器日志
```

## 一画面コマンドカード（印刷して壁に貼る）

```
文件    l ll la · z 目录 · cd - · mkdir -p · cp -a · ln -sfn
文本    cat less head tail · rg pattern · sd old new · awk '{print $1}' · jq .
查找    fd 名 · fd -e py · which · type -a · fzf (Ctrl+T)
进程    btop · pgrep -af · kill PID · jobs · nohup cmd & · nice -n 10
权限    chmod +x/600/644/755 · sudo !! · umask 077
磁盘    df -h · du -sh · ncdu · lsblk · mount -a
网络    ip -br addr · ss -ltnp · curl -w '%{http_code}' · ssh -L · rsync -av
系统    hostnamectl · free -h · dmesg -T · journalctl -u · systemctl --user
打包    tar --zstd -cf/xf · zip -r · unzip -l · 7z x
```
