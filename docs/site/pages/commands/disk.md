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
