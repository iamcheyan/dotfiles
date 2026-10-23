> 摘要：df、du、mount、lsblk 等磁盘命令，含 NAS 挂载、空间清理的本机做法。

# 磁盘与挂载

## 看空间

```bash
df -h                  # 各文件系统用量（人类可读）
df -h /                # 只看根分区
df -i                  # 看 inode 用量（小文件爆炸时 inode 先满）
```

本机装了 **duf**（`df` 的现代替代，对齐表格、彩色、按类型过滤）：

```bash
duf                   # 一张表看完所有挂载点
duf /data             # 只看某个路径所在文件系统
duf --only local      # 只看本地盘（排除 NAS、网络挂载）
```

**找谁占了空间**：

```bash
du -sh ~/*            # home 各目录大小汇总
du -sh ~/development/*| sort -rh | head   # 最大的几个项目
du -h --max-depth=1 / | sort -rh | head
ncdu ~                # 交互式扫描（本机可装）：方向键钻取，del 标记删除
```

`ncdu` 是清理磁盘的神器：先扫，再逐层下钻，删之前看清楚。比 `du | sort` 直观得多。

```bash
# 找大于 500M 的大文件
fd -t f . ~ -x du -h 2>/dev/null | rg '^\d+(\.\d+)?[GM]' | sort -rh | head
```

**本机实战：日志和缓存是两大户**。`~/.cache`、`~/development/*/node_modules`、Docker 的 `/var/lib/docker`、pnpm store 是常见嫌疑。清理前先确认没有正在跑的任务依赖它们。

## 挂载点与块设备

```bash
lsblk                # 树状列出所有块设备（磁盘、分区、挂载点）
lsblk -f             # 连文件系统类型和 UUID 一起显示
blkid                # 设备 UUID、类型、标签（sudo 看全）
findmnt              # 当前挂载表（比 mount 输出好读）
findmnt /data        # 查某个路径挂在哪个设备上
```

插U盘/移动硬盘后的标准检查流程：`lsblk` 看设备名 → `findmnt` 确认没自动挂载 → 手动挂载 → 用完 `umount`。

## mount / umount

```bash
mount                          # 列出当前挂载
sudo mount /dev/sdb1 /mnt/usb  # 挂U盘
sudo mount -o remount,rw /     # 重新以读写挂载（只读根救援时用）
sudo umount /mnt/usb           # 卸载（不是 umount 拼写错误）
sudo umount -l /mnt/busy       # 目标忙时懒卸载（断开连接，清引用后真正卸载）
```

**`target is busy`**：有进程开着该目录里的文件或 cd 在里面。`lsof +D /mnt/usb` 找出凶手，或 `fuser -mv /mnt/usb`。

## NAS 挂载（本机核心场景）

本机的数据在 NAS 上，通过 CIFS/SMB 挂载到 `/data`：

```bash
# /etc/fstab 里一条记录 = 开机自动挂载
//nas-addr/share  /data/share  cifs  credentials=/home/tetsuya/.smbcredentials,iocharset=utf8,uid=tetsuya,gid=tetsuya,file_mode=0664,dir_mode=0775  0  0

sudo mount -a                  # 不重启挂载 fstab 里所有条目（改完 fstab 先这个测试）
sudo mount /data/share         # 只挂某一条
```

凭据单独放 `~/.smbcredentials`（权限 600），**不写在 fstab 里**。文件只有两行，第一行用户名、第二行口令，值替换成自己的：

```text
username=<NAS 用户名>
口令=<NAS 口令>
```

排错：

```bash
dmesg | tail                    # 挂载失败看内核怎么说
mount | rg cifs                 # 确认挂载参数
```

- **`Permission denied`**：凭据错、NAS 的 SMB 协议版本不匹配（加 `vers=3.0`）。
- **文件名乱码**：`iocharset=utf8` 漏了。
- **写入是 root 属主**：`uid/gid` 没指定，默认归 root。

**挂载前先确认 NAS 可达**：`ping` 通、`smbclient -L //nas-addr -U user` 能列共享，再 mount，省得把机器卡在启动项上。

## 分区与格式化（高风险）

```bash
sudo fdisk -l                  # 看分区表
sudo parted -l                 # 跨平台分区工具
sudo mkfs.ext4 /dev/sdb1       # 格式化！（数据全没，执行前三次确认设备名）
sudo wipefs -a /dev/sdb1       # 清掉文件系统签名（重分区前）
```

`mkfs` 之前的标准动作：`lsblk` 确认设备 → `mount | rg sd` 确认没挂载 → 确认里面没有要的数据。**设备名错一位就是灾难**，本机规则：重要操作前把 `lsblk` 输出完整看一遍。

## SMART 健康

```bash
sudo smartctl -a /dev/sda      # 硬盘健康全景（装 smartmontools）
sudo smartctl -t short /dev/sda  # 跑快速自检
```

NAS 和本地盘的寿命监控靠它，`Reallocated_Sector_Count` 上涨就是该备份该换盘的信号。

## 排错

**`df` 和 `du` 差很多**：文件被删但进程还持有句柄（`lsof +L1` 找），或 du 权限不够看不到别的用户的目录。

**inode 满**：`df -i` 看，海量小文件导致。找出目录：`for d in ~/*; do echo $(find "$d" | wc -l) "$d"; done | sort -rn | head`。

**NAS 卡住整个系统**：网络挂载的进程在 `D` 状态会拖死一切。挂载选项加 `soft,timeo=30` 或systemd 的 `x-systemd.device-timeout=`；应急时 `umount -l`。

**`umount: not mounted`**：`findmnt /path` 看真实挂载点，可能是嵌套挂载，从最深的开始卸。

<!-- lang:en -->

> Summary: Disk commands such as df, du, mount, and lsblk, including this machine's approach to NAS mounts and freeing space.

# Disks and Mounting

## Checking space

```bash
df -h                  # 各文件系统用量（人类可读）
df -h /                # 只看根分区
df -i                  # 看 inode 用量（小文件爆炸时 inode 先满）
```

This machine has **duf** installed (a modern replacement for `df`: aligned tables, colors, filtering by type):

```bash
duf                   # 一张表看完所有挂载点
duf /data             # 只看某个路径所在文件系统
duf --only local      # 只看本地盘（排除 NAS、网络挂载）
```

**Finding what is eating space**:

```bash
du -sh ~/*            # home 各目录大小汇总
du -sh ~/development/*| sort -rh | head   # 最大的几个项目
du -h --max-depth=1 / | sort -rh | head
ncdu ~                # 交互式扫描（本机可装）：方向键钻取，del 标记删除
```

`ncdu` is the go-to tool for cleaning disk: scan first, then drill down level by level, and look carefully before deleting. Far more intuitive than `du | sort`.

```bash
# 找大于 500M 的大文件
fd -t f . ~ -x du -h 2>/dev/null | rg '^\d+(\.\d+)?[GM]' | sort -rh | head
```

**On this machine, logs and caches are the two biggest offenders.** `~/.cache`, `~/development/*/node_modules`, Docker's `/var/lib/docker`, and the pnpm store are the usual suspects. Before cleaning, confirm no running tasks depend on them.

## Mount points and block devices

```bash
lsblk                # 树状列出所有块设备（磁盘、分区、挂载点）
lsblk -f             # 连文件系统类型和 UUID 一起显示
blkid                # 设备 UUID、类型、标签（sudo 看全）
findmnt              # 当前挂载表（比 mount 输出好读）
findmnt /data        # 查某个路径挂在哪个设备上
```

Standard check flow after plugging in a USB stick or external drive: `lsblk` to see the device name → `findmnt` to confirm it did not auto-mount → mount manually → `umount` when done.

## mount / umount

```bash
mount                          # 列出当前挂载
sudo mount /dev/sdb1 /mnt/usb  # 挂U盘
sudo mount -o remount,rw /     # 重新以读写挂载（只读根救援时用）
sudo umount /mnt/usb           # 卸载（不是 umount 拼写错误）
sudo umount -l /mnt/busy       # 目标忙时懒卸载（断开连接，清引用后真正卸载）
```

**`target is busy`**: a process has files open in that directory or is cd-ed into it. Use `lsof +D /mnt/usb` to find the culprit, or `fuser -mv /mnt/usb`.

## NAS mounts (the core scenario on this machine)

This machine's data lives on a NAS, mounted at `/data` via CIFS/SMB:

```bash
# /etc/fstab 里一条记录 = 开机自动挂载
//nas-addr/share  /data/share  cifs  credentials=/home/tetsuya/.smbcredentials,iocharset=utf8,uid=tetsuya,gid=tetsuya,file_mode=0664,dir_mode=0775  0  0

sudo mount -a                  # 不重启挂载 fstab 里所有条目（改完 fstab 先这个测试）
sudo mount /data/share         # 只挂某一条
```

Credentials live separately in `~/.smbcredentials` (permissions 600), **not written in fstab**. The file has exactly two lines — username first, password second; substitute your own values:

```text
username=<NAS 用户名>
口令=<NAS 口令>
```

Troubleshooting:

```bash
dmesg | tail                    # 挂载失败看内核怎么说
mount | rg cifs                 # 确认挂载参数
```

- **`Permission denied`**: wrong credentials, or the NAS's SMB protocol version does not match (add `vers=3.0`).
- **Garbled file names**: `iocharset=utf8` is missing.
- **Files owned by root**: `uid/gid` not specified; the default owner is root.

**Confirm the NAS is reachable before mounting**: ping succeeds and `smbclient -L //nas-addr -U user` lists shares — only then mount, so the machine doesn't hang on a boot entry.

## Partitioning and formatting (high risk)

```bash
sudo fdisk -l                  # 看分区表
sudo parted -l                 # 跨平台分区工具
sudo mkfs.ext4 /dev/sdb1       # 格式化！（数据全没，执行前三次确认设备名）
sudo wipefs -a /dev/sdb1       # 清掉文件系统签名（重分区前）
```

The standard routine before `mkfs`: `lsblk` to confirm the device → `mount | rg sd` to confirm it is not mounted → confirm there is no data you need on it. **One character off in the device name is a disaster.** Local rule: read the full `lsblk` output carefully before any important operation.

## SMART health

```bash
sudo smartctl -a /dev/sda      # 硬盘健康全景（装 smartmontools）
sudo smartctl -t short /dev/sda  # 跑快速自检
```

This is how you monitor the lifespan of the NAS and local disks; a rising `Reallocated_Sector_Count` is the signal to back up and replace the drive.

## Troubleshooting

**`df` and `du` disagree by a lot**: a file was deleted but a process still holds its handle (find with `lsof +L1`), or du lacks permission to see other users' directories.

**Inodes exhausted**: check with `df -i`; caused by huge numbers of tiny files. Find the directory: `for d in ~/*; do echo $(find "$d" | wc -l) "$d"; done | sort -rn | head`.

**A NAS mount freezes the whole system**: processes stuck in `D` state on a network mount drag everything down. Add `soft,timeo=30` to the mount options or systemd's `x-systemd.device-timeout=`; in an emergency, `umount -l`.

**`umount: not mounted`**: use `findmnt /path` to see the real mount point; it may be a nested mount — unmount from the deepest one.

<!-- lang:ja -->

> 摘要：df・du・mount・lsblk などのディスクコマンド、NAS マウントと空き容量確保の本機流のやり方。

# ディスクとマウント

## 空き容量の確認

```bash
df -h                  # 各文件系统用量（人类可读）
df -h /                # 只看根分区
df -i                  # 看 inode 用量（小文件爆炸时 inode 先满）
```

本機には **duf** が入っています（`df` のモダンな代替：整列された表、カラー、タイプ別フィルタ）：

```bash
duf                   # 一张表看完所有挂载点
duf /data             # 只看某个路径所在文件系统
duf --only local      # 只看本地盘（排除 NAS、网络挂载）
```

**容量を食っている犯人探し**：

```bash
du -sh ~/*            # home 各目录大小汇总
du -sh ~/development/*| sort -rh | head   # 最大的几个项目
du -h --max-depth=1 / | sort -rh | head
ncdu ~                # 交互式扫描（本机可装）：方向键钻取，del 标记删除
```

`ncdu` はディスク掃除の必殺ツールです：まずスキャンし、階層ごとに掘り下げ、削除前によく確認します。`du | sort` よりはるかに直感的です。

```bash
# 找大于 500M 的大文件
fd -t f . ~ -x du -h 2>/dev/null | rg '^\d+(\.\d+)?[GM]' | sort -rh | head
```

**本機の実戦では、ログとキャッシュが二大巨頭です**。`~/.cache`、`~/development/*/node_modules`、Docker の `/var/lib/docker`、pnpm store がよくある容疑者。掃除の前に、実行中のタスクが依存していないか確認します。

## マウントポイントとブロックデバイス

```bash
lsblk                # 树状列出所有块设备（磁盘、分区、挂载点）
lsblk -f             # 连文件系统类型和 UUID 一起显示
blkid                # 设备 UUID、类型、标签（sudo 看全）
findmnt              # 当前挂载表（比 mount 输出好读）
findmnt /data        # 查某个路径挂在哪个设备上
```

USB メモリや外付けディスクを挿した後の標準チェック手順：`lsblk` でデバイス名を確認 → `findmnt` で自動マウントされていないことを確認 → 手動マウント → 使い終わったら `umount`。

## mount / umount

```bash
mount                          # 列出当前挂载
sudo mount /dev/sdb1 /mnt/usb  # 挂U盘
sudo mount -o remount,rw /     # 重新以读写挂载（只读根救援时用）
sudo umount /mnt/usb           # 卸载（不是 umount 拼写错误）
sudo umount -l /mnt/busy       # 目标忙时懒卸载（断开连接，清引用后真正卸载）
```

**`target is busy`**：そのディレクトリ内のファイルをプロセスが開いているか、そこへ cd しています。`lsof +D /mnt/usb` で犯人を特定するか、`fuser -mv /mnt/usb` を使います。

## NAS マウント（本機の中核シナリオ）

本機のデータは NAS 上にあり、CIFS/SMB で `/data` にマウントされます：

```bash
# /etc/fstab 里一条记录 = 开机自动挂载
//nas-addr/share  /data/share  cifs  credentials=/home/tetsuya/.smbcredentials,iocharset=utf8,uid=tetsuya,gid=tetsuya,file_mode=0664,dir_mode=0775  0  0

sudo mount -a                  # 不重启挂载 fstab 里所有条目（改完 fstab 先这个测试）
sudo mount /data/share         # 只挂某一条
```

資格情報は別ファイル `~/.smbcredentials`（権限 600）に置き、**fstab には書きません**。ファイルは 2 行だけ、1 行目がユーザー名、2 行目がパスワードです。値は自分のものに置き換えてください：

```text
username=<NAS 用户名>
口令=<NAS 口令>
```

トラブルシューティング：

```bash
dmesg | tail                    # 挂载失败看内核怎么说
mount | rg cifs                 # 确认挂载参数
```

- **`Permission denied`**：資格情報の誤り、または NAS の SMB プロトコルバージョン不一致（`vers=3.0` を追加）。
- **ファイル名の文字化け**：`iocharset=utf8` が抜けている。
- **書き込みが root 所有になる**：`uid/gid` 未指定。デフォルトでは root 所有になります。

**マウント前に NAS への到達性を確認**：`ping` が通り、`smbclient -L //nas-addr -U user` で共有一覧が取れることを確認してからマウントします。起動エントリでマシンが固まないためです。

## パーティショニングとフォーマット（高リスク）

```bash
sudo fdisk -l                  # 看分区表
sudo parted -l                 # 跨平台分区工具
sudo mkfs.ext4 /dev/sdb1       # 格式化！（数据全没，执行前三次确认设备名）
sudo wipefs -a /dev/sdb1       # 清掉文件系统签名（重分区前）
```

`mkfs` の前の標準手順：`lsblk` でデバイスを確認 → `mount | rg sd` で未マウントを確認 → 中に必要なデータがないことを確認。**デバイス名が 1 文字ずれただけで大惨事です**。本機ルール：重要な操作の前に `lsblk` の出力を全文よく読みます。

## SMART ヘルス

```bash
sudo smartctl -a /dev/sda      # 硬盘健康全景（装 smartmontools）
sudo smartctl -t short /dev/sda  # 跑快速自检
```

NAS やローカルディスクの寿命管理はこれに頼ります。`Reallocated_Sector_Count` が上がったら、バックアップしてディスク交換すべき合図です。

## トラブルシューティング

**`df` と `du` が大きく食い違う**：ファイルは削除済みだがプロセスがハンドルを掴んだまま（`lsof +L1` で特定）、または du に権限がなく他ユーザーのディレクトリが見えない。

**inode 枯渇**：`df -i` で確認。膨大な小ファイルが原因。犯人のディレクトリを特定：`for d in ~/*; do echo $(find "$d" | wc -l) "$d"; done | sort -rn | head`。

**NAS マウントでシステム全体が固まる**：ネットワークマウント上の `D` 状態プロセスが全体を巻き込みます。マウントオプションに `soft,timeo=30` か systemd の `x-systemd.device-timeout=` を追加。緊急時は `umount -l`。

**`umount: not mounted`**：`findmnt /path` で実際のマウントポイントを確認。ネストしたマウントの可能性があるので、最も深いものから外します。
