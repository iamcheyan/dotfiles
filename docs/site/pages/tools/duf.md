> 摘要：duf 用表格显示所有挂载点的容量、使用率和类型。

# duf

## 用途

`duf`（Disk Usage/Free）替代 `df -h`：彩色表格、按挂载点分组、可过滤本地/网络/虚拟文件系统、支持 JSON 输出。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |

```zsh
zi_cmd muesli/duf duf
```

## 基本用法

```bash
duf                    # 全部挂载点
duf --only local       # 只看本地磁盘
duf --hide loops       # 隐藏 loop 设备
duf -json              # JSON 输出
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-all` | 包含伪文件系统、重复、不可访问的挂载点 |
| `-only` | 只显示指定类别：`local`、`network`、`fuse`、`special`、`loops`、`binds` |
| `-hide` | 隐藏指定类别，取值同上 |
| `-only-fs` | 按文件系统类型筛选 |
| `-hide-fs` | 按类型隐藏 |
| `-only-mp` | 按挂载点筛选，支持通配符 |
| `-hide-mp` | 按挂载点隐藏 |
| `-inodes` | 显示 inode 使用而非块使用 |
| `-output` | 指定输出列：`mountpoint`、`size`、`used`、`avail`、`usage`、`type`、`filesystem` |
| `-sort` | 排序列，默认 `mountpoint` |
| `-theme` | `dark`、`light`、`ansi` |
| `-style` | `unicode` 或 `ascii` |
| `-width` | 最大输出宽度 |
| `-json` | JSON 格式 |
| `-usage-threshold` | 使用率告警阈值，默认 `0.5,0.9` |
| `-avail-threshold` | 剩余空间告警阈值，默认 `10G,1G` |

## 实用例子

```bash
duf -only local                    # 只看真实磁盘
duf -hide loops,binds              # 隐藏 loop 和 bind mount
duf -sort size                     # 按容量排序
duf -output mountpoint,size,usage  # 只留三列
duf -json | jq '.[].mountpoint'    # 脚本处理
duf -inodes                        # inode 是否耗尽
```

`duf -inodes` 是排查「磁盘还有空间但写不进去」的关键命令——inode 用尽时 `df -h` 显示有空间，实际无法创建新文件。

## 与 df 的差异

| | df | duf |
|---|---|---|
| 默认过滤 | 显示全部，含 loop | 默认隐藏部分伪文件系统 |
| 颜色 | 无 | 有 |
| 排序 | 无 | `-sort` |
| JSON | 无 | `-json` |
| 阈值告警 | 无 | 内置颜色阈值 |

## 排错

**输出里有很多 loop 设备**：默认已经隐藏一部分，仍多余就加 `-hide loops`。

**容量数字和 `df` 不一致**：duf 默认按 1024 进制换算，`df -h` 可能用 1000 进制。这是显示差异，不是数据错误。

**网络挂载卡住**：NFS/SMB 无响应时 duf 会等待。用 `-hide network` 跳过。

**颜色在管道里丢失**：`-json` 或重定向时不输出颜色，这是预期行为。

**`duf: command not found`**：Zinit 未下载。`zinit list | grep duf` 确认。
