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

<!-- lang:en -->
> Summary: duf shows capacity, usage, and type of all mount points in a table.

# duf

## Purpose

`duf` (Disk Usage/Free) replaces `df -h`: colorful tables, grouped by mount point, with filtering for local/network/virtual filesystems and JSON output support.

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |

```zsh
zi_cmd muesli/duf duf
```

## Basic usage

```bash
duf                    # 全部挂载点
duf --only local       # 只看本地磁盘
duf --hide loops       # 隐藏 loop 设备
duf -json              # JSON 输出
```

## Common options

| Option | Action |
|---|---|
| `-all` | Include pseudo, duplicate, and inaccessible mount points |
| `-only` | Show only the given categories: `local`, `network`, `fuse`, `special`, `loops`, `binds` |
| `-hide` | Hide the given categories, same values as above |
| `-only-fs` | Filter by filesystem type |
| `-hide-fs` | Hide by type |
| `-only-mp` | Filter by mount point, wildcards supported |
| `-hide-mp` | Hide by mount point |
| `-inodes` | Show inode usage instead of block usage |
| `-output` | Choose output columns: `mountpoint`, `size`, `used`, `avail`, `usage`, `type`, `filesystem` |
| `-sort` | Sort column, default `mountpoint` |
| `-theme` | `dark`, `light`, `ansi` |
| `-style` | `unicode` or `ascii` |
| `-width` | Maximum output width |
| `-json` | JSON format |
| `-usage-threshold` | Usage warning thresholds, default `0.5,0.9` |
| `-avail-threshold` | Free-space warning thresholds, default `10G,1G` |

## Practical examples

```bash
duf -only local                    # 只看真实磁盘
duf -hide loops,binds              # 隐藏 loop 和 bind mount
duf -sort size                     # 按容量排序
duf -output mountpoint,size,usage  # 只留三列
duf -json | jq '.[].mountpoint'    # 脚本处理
duf -inodes                        # inode 是否耗尽
```

`duf -inodes` is the key command for diagnosing "the disk has space but writes fail" — when inodes are exhausted, `df -h` still shows free space, but new files cannot actually be created.

## Differences from df

| | df | duf |
|---|---|---|
| Default filtering | Shows everything, including loop | Hides some pseudo filesystems by default |
| Color | None | Yes |
| Sorting | None | `-sort` |
| JSON | None | `-json` |
| Threshold warnings | None | Built-in color thresholds |

## Troubleshooting

**Lots of loop devices in the output**: some are already hidden by default; if there are still too many, add `-hide loops`.

**Capacity numbers differ from `df`**: duf converts with a base of 1024 by default, while `df -h` may use 1000. This is a display difference, not a data error.

**Network mounts hang**: duf waits when NFS/SMB is unresponsive. Use `-hide network` to skip them.

**Color lost in pipes**: no color is output for `-json` or redirection; this is expected behavior.

**`duf: command not found`**: Zinit has not downloaded it. Confirm with `zinit list | grep duf`.

<!-- lang:ja -->
> 要約：duf はすべてのマウントポイントの容量・使用率・種類を表形式で表示します。

# duf

## 用途

`duf`（Disk Usage/Free）は `df -h` の代替です。カラフルな表、マウントポイントごとのグループ化、ローカル/ネットワーク/仮想ファイルシステムのフィルタリング、JSON 出力に対応しています。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |

```zsh
zi_cmd muesli/duf duf
```

## 基本的な使い方

```bash
duf                    # 全部挂载点
duf --only local       # 只看本地磁盘
duf --hide loops       # 隐藏 loop 设备
duf -json              # JSON 输出
```

## よく使うオプション

| オプション | 動作 |
|---|---|
| `-all` | 疑似ファイルシステム・重複・アクセス不可のマウントポイントを含める |
| `-only` | 指定カテゴリのみ表示：`local`、`network`、`fuse`、`special`、`loops`、`binds` |
| `-hide` | 指定カテゴリを非表示。値は上と同じ |
| `-only-fs` | ファイルシステムの種類でフィルタ |
| `-hide-fs` | 種類で非表示 |
| `-only-mp` | マウントポイントでフィルタ。ワイルドカード対応 |
| `-hide-mp` | マウントポイントで非表示 |
| `-inodes` | ブロック使用量の代わりに inode 使用量を表示 |
| `-output` | 出力列を指定：`mountpoint`、`size`、`used`、`avail`、`usage`、`type`、`filesystem` |
| `-sort` | ソート列。デフォルトは `mountpoint` |
| `-theme` | `dark`、`light`、`ansi` |
| `-style` | `unicode` または `ascii` |
| `-width` | 出力の最大幅 |
| `-json` | JSON 形式 |
| `-usage-threshold` | 使用率の警告しきい値。デフォルト `0.5,0.9` |
| `-avail-threshold` | 空き容量の警告しきい値。デフォルト `10G,1G` |

## 実用的な例

```bash
duf -only local                    # 只看真实磁盘
duf -hide loops,binds              # 隐藏 loop 和 bind mount
duf -sort size                     # 按容量排序
duf -output mountpoint,size,usage  # 只留三列
duf -json | jq '.[].mountpoint'    # 脚本处理
duf -inodes                        # inode 是否耗尽
```

`duf -inodes` は「ディスクに空きがあるのに書き込めない」問題を切り分けるための重要なコマンドです。inode が使い切られると、`df -h` では空きが表示されていても、実際には新しいファイルを作成できません。

## df との違い

| | df | duf |
|---|---|---|
| デフォルトのフィルタ | 全部表示（loop 含む） | 一部の疑似ファイルシステムをデフォルトで非表示 |
| 色 | なし | あり |
| ソート | なし | `-sort` |
| JSON | なし | `-json` |
| しきい値警告 | なし | 組み込みの色分けしきい値 |

## トラブルシューティング

**出力に loop デバイスが多い**：デフォルトで一部は非表示になっています。それでも多ければ `-hide loops` を追加してください。

**容量の数値が `df` と一致しない**：duf はデフォルトで 1024 進換算、`df -h` は 1000 進の場合があります。表示上の違いであり、データの誤りではありません。

**ネットワークマウントで固まる**：NFS/SMB が応答しないと duf は待機します。`-hide network` でスキップしてください。

**パイプで色が消える**：`-json` やリダイレクト時は色を出力しません。想定された挙動です。

**`duf: command not found`**：Zinit がダウンロードしていません。`zinit list | grep duf` で確認してください。
