> 摘要：tar、gzip、zstd、zip、7z 等压缩归档命令的常用组合，以及解压未知文件的套路。

# 压缩与归档

## tar（Linux 世界的主力）

`tar` 本身不压缩，只打包；压缩交给 `-z`（gzip）、`-J`（xz）、`--zstd` 等选项。记一个模板就够：

```bash
tar -czf 归档.tar.gz 目录/     # 打包 + gzip 压缩（最通用）
tar -xzf 归档.tar.gz           # 解压
tar -xzf 归档.tar.gz -C 目标/   # 解压到指定目录
tar -tzf 归档.tar.gz           # 只看内容清单，不解压（先看再解！）
```

`--zstd` 是本机推荐（速度快、压缩比好）：

```bash
tar --zstd -cf a.tar.zst dir/
tar --zstd -df a.tar.zst       # 解压
tar --zstd -tf a.tar.zst       # 列清单
```

**常用附加选项**：

```bash
tar -czvf a.tar.gz dir/        # -v 显示处理的文件
tar -xzf a.tar.gz --strip-components=1  # 去掉一层目录（解压后不想要外层文件夹时）
tar -czf a.tar.gz --exclude='.git' --exclude='node_modules' dir/
tar -czf a.tar.gz -C /path/to dir/    # -C 先切目录，归档里不含绝对路径
tar -tzf a.tar.gz | head -20   # 解压前必做：看清单，防路径遍历和目录炸弹
```

**安全习惯**：解压陌生压缩包前 `tar -tzf` 看清单——里面如果有 `../../etc/passwd` 这种绝对路径或上层路径，就是恶意包，别解。

## 各压缩格式对照

| 格式 | 压缩 | 解压 | 特点 |
|---|---|---|---|
| gzip | `gzip file` | `gunzip file.gz` | 快，兼容性最好，只压单文件 |
| bzip2 | `bzip2 file` | `bunzip2 file.bz2` | 比 gzip 强，慢 |
| xz | `xz file` | `unxz file.xz` | 压缩比最好，最慢 |
| zstd | `zstd file` | `unzstd file.zst` | 又快又好，本机首选 |
| zip | `zip -r a.zip dir/` | `unzip a.zip` | 跨平台（Windows 兼容） |
| 7z | `7z a a.7z dir/` | `7z x a.7z` | 压缩比高，Windows 上也常见 |

```bash
gzip -k file        # 保留原文件（默认会删）
gzip -9 file        # 最大压缩
zstd -19 file       # zstd 高压缩
xz -T0 file         # 用所有核并行（大文件必备）
```

`gzip` 默认压缩后删原文件，`-k` 保留。批量压缩：`gzip -k *.log`。

## zip 与 unzip

```bash
zip -r a.zip dir/              # 递归打包
zip -r a.zip dir/ -x '*.git*'  # 排除
zip -e a.zip file              # 加密（会交互要密码）
unzip a.zip                    # 解压
unzip -l a.zip                 # 列清单（先看！）
unzip -o a.zip -d 目标/        # 覆盖解压到指定目录
unzip -P 密码 a.zip             # 带密码（密码会进 shell history，慎用）
```

跨机器传文件（尤其给 Windows 用户）用 zip，内部归档用 `tar --zstd`。

## 7z

```bash
7z a a.7z dir/        # 压缩
7z x a.7z             # 解压（保留目录结构，解压万能）
7z l a.7z             # 列清单
7z t a.7z             # 测试完整性
```

`7z x` 号称万能解压，格式支持最全。本机解压来路不明的压缩包：先 `7z l` 看清单，再 `7z x` 到临时目录。

## 本站的解压脚本

这套 dotfiles 自带三个解压辅助脚本（`scripts/` 下），一个命令按后缀选解压器，见[归档工具](../scripts/archives.html)。日常在 Zsh 里直接用脚本名，不用记 tar 参数。

## 实战场景

```bash
# 打包项目发给别人，排除垃圾
tar --zstd -cf proj.tar.zst --exclude='.git' --exclude='node_modules' --exclude='.venv' proj/

# 备份配置目录，保留权限
tar --zstd -cpf ~/backups/config-$(date +%F).tar.zst -C ~/.config ghostty tmux

# 看一个压缩包多大、里面啥结构
tar --zstd -tf big.tar.zst | head -30

# 增量备份思路：先全量，之后用 rsync 同步目录（比反复 tar 聪明）
rsync -a --delete src/ backup/
```

## 排错

**`tar: Error is not recoverable`**：文件损坏或格式不匹配（比如把 `.tar.xz` 当 `.tar.gz`）。`file 包名` 确认真实类型再选参数。

**解压后一屏乱码文件名**：Windows 打包的 zip 用了 GBK，`unzip -O gbk a.zip` 指定编码。

**`gzip: stdin: not in gzip format`**：文件不是 gzip，`file` 看一下；可能下载到的是 HTML 错误页。

**解压把当前目录搞乱**：养成 `-C 目标目录` 或先 cd 到干净目录再解压的习惯；解压前 `ls` 一眼。

**压缩包几十 G 解压占满盘**：先 `df -h`，`tar -tf` 看总大小估算，空间不够先清。

<!-- lang:en -->

> Summary: Common combinations of compression and archiving commands such as tar, gzip, zstd, zip, and 7z, plus the routine for extracting unknown files.

# Compression and Archiving

## tar (the workhorse of the Linux world)

`tar` itself does not compress; it only packs. Compression is delegated to options such as `-z` (gzip), `-J` (xz), and `--zstd`. One template is all you need:

```bash
tar -czf 归档.tar.gz 目录/     # 打包 + gzip 压缩（最通用）
tar -xzf 归档.tar.gz           # 解压
tar -xzf 归档.tar.gz -C 目标/   # 解压到指定目录
tar -tzf 归档.tar.gz           # 只看内容清单，不解压（先看再解！）
```

`--zstd` is the recommended choice on this machine (fast, good compression ratio):

```bash
tar --zstd -cf a.tar.zst dir/
tar --zstd -df a.tar.zst       # extract
tar --zstd -tf a.tar.zst       # list contents
```

**Common extra options**:

```bash
tar -czvf a.tar.gz dir/        # -v 显示处理的文件
tar -xzf a.tar.gz --strip-components=1  # 去掉一层目录（解压后不想要外层文件夹时）
tar -czf a.tar.gz --exclude='.git' --exclude='node_modules' dir/
tar -czf a.tar.gz -C /path/to dir/    # -C 先切目录，归档里不含绝对路径
tar -tzf a.tar.gz | head -20   # 解压前必做：看清单，防路径遍历和目录炸弹
```

**Safe habit**: before extracting an unfamiliar archive, run `tar -tzf` to view the listing — if it contains absolute or parent paths like `../../etc/passwd`, it is a malicious archive; don't extract it.

## Compression format comparison

| Format | Compress | Extract | Notes |
|---|---|---|---|
| gzip | `gzip file` | `gunzip file.gz` | Fast, best compatibility, single files only |
| bzip2 | `bzip2 file` | `bunzip2 file.bz2` | Better than gzip, slower |
| xz | `xz file` | `unxz file.xz` | Best compression ratio, slowest |
| zstd | `zstd file` | `unzstd file.zst` | Fast and good; first choice on this machine |
| zip | `zip -r a.zip dir/` | `unzip a.zip` | Cross-platform (Windows compatible) |
| 7z | `7z a a.7z dir/` | `7z x a.7z` | High compression ratio, also common on Windows |

```bash
gzip -k file        # keep the original file (deleted by default)
gzip -9 file        # maximum compression
zstd -19 file       # high compression with zstd
xz -T0 file         # parallel across all cores (a must for large files)
```

`gzip` deletes the original file after compressing by default; `-k` keeps it. Batch compression: `gzip -k *.log`.

## zip and unzip

```bash
zip -r a.zip dir/              # 递归打包
zip -r a.zip dir/ -x '*.git*'  # 排除
zip -e a.zip file              # 加密（会交互要密码）
unzip a.zip                    # 解压
unzip -l a.zip                 # 列清单（先看！）
unzip -o a.zip -d 目标/        # 覆盖解压到指定目录
unzip -P 密码 a.zip             # 带密码（密码会进 shell history，慎用）
```

Use zip when transferring files across machines (especially to Windows users); use `tar --zstd` for internal archives.

## 7z

```bash
7z a a.7z dir/        # compress
7z x a.7z             # extract (keeps the directory structure; the universal extractor)
7z l a.7z             # list contents
7z t a.7z             # test integrity
```

`7z x` is billed as the universal extractor with the broadest format support. On this machine, for archives of unknown origin: run `7z l` to view the listing first, then `7z x` into a temp directory.

## Extraction scripts on this site

These dotfiles ship with three extraction helper scripts (under `scripts/`); a single command picks the extractor based on the file extension — see [Archive tools](../scripts/archives.html). Day to day, just use the script names in Zsh instead of memorizing tar flags.

## Real-world scenarios

```bash
# Pack a project to send to someone else, excluding junk
tar --zstd -cf proj.tar.zst --exclude='.git' --exclude='node_modules' --exclude='.venv' proj/

# Back up config directories, preserving permissions
tar --zstd -cpf ~/backups/config-$(date +%F).tar.zst -C ~/.config ghostty tmux

# See how big an archive is and what its structure looks like
tar --zstd -tf big.tar.zst | head -30

# Incremental backup idea: full backup first, then rsync the directory (smarter than repeated tar)
rsync -a --delete src/ backup/
```

## Troubleshooting

**`tar: Error is not recoverable`**: the file is corrupt or the format does not match (e.g. treating a `.tar.xz` as `.tar.gz`). Run `file 包名` to confirm the real type, then pick your flags.

**A screen of garbled file names after extraction**: the zip was packed on Windows with GBK; use `unzip -O gbk a.zip` to specify the encoding.

**`gzip: stdin: not in gzip format`**: the file is not gzip; check with `file` — you may have downloaded an HTML error page.

**Extraction wrecks the current directory**: build the habit of using `-C 目标目录` or cd-ing into a clean directory before extracting; glance at `ls` before you extract.

**A tens-of-GBs archive fills the disk when extracted**: run `df -h` first and use `tar -tf` to estimate the total size; if space is short, clean up first.

<!-- lang:ja -->

> 摘要：tar・gzip・zstd・zip・7z などの圧縮・アーカイブコマンドの定番の組み合わせと、未知のファイルを展開する際の定型手順。

# 圧縮とアーカイブ

## tar（Linux 世界の主力）

`tar` 自体は圧縮を行わず、パックのみを行います。圧縮は `-z`（gzip）、`-J`（xz）、`--zstd` などのオプションに任せます。テンプレートを 1 つ覚えれば十分です：

```bash
tar -czf 归档.tar.gz 目录/     # 打包 + gzip 压缩（最通用）
tar -xzf 归档.tar.gz           # 解压
tar -xzf 归档.tar.gz -C 目标/   # 解压到指定目录
tar -tzf 归档.tar.gz           # 只看内容清单，不解压（先看再解！）
```

`--zstd` は本機で推奨（高速で圧縮率も良好）：

```bash
tar --zstd -cf a.tar.zst dir/
tar --zstd -df a.tar.zst       # 展開
tar --zstd -tf a.tar.zst       # 一覧表示
```

**よく使う追加オプション**：

```bash
tar -czvf a.tar.gz dir/        # -v 显示处理的文件
tar -xzf a.tar.gz --strip-components=1  # 去掉一层目录（解压后不想要外层文件夹时）
tar -czf a.tar.gz --exclude='.git' --exclude='node_modules' dir/
tar -czf a.tar.gz -C /path/to dir/    # -C 先切目录，归档里不含绝对路径
tar -tzf a.tar.gz | head -20   # 解压前必做：看清单，防路径遍历和目录炸弹
```

**安全な習慣**：見知らぬアーカイブを展開する前に `tar -tzf` で一覧を確認します。`../../etc/passwd` のような絶対パスや上位パスが含まれていれば悪意あるアーカイブなので、展開しないでください。

## 圧縮形式の比較

| 形式 | 圧縮 | 展開 | 特徴 |
|---|---|---|---|
| gzip | `gzip file` | `gunzip file.gz` | 高速、互換性最良、単一ファイルのみ |
| bzip2 | `bzip2 file` | `bunzip2 file.bz2` | gzip より高圧縮、低速 |
| xz | `xz file` | `unxz file.xz` | 圧縮率最高、最も遅い |
| zstd | `zstd file` | `unzstd file.zst` | 高速かつ高圧縮、本機の第一候補 |
| zip | `zip -r a.zip dir/` | `unzip a.zip` | クロスプラットフォーム（Windows 互換） |
| 7z | `7z a a.7z dir/` | `7z x a.7z` | 圧縮率が高く、Windows でも一般的 |

```bash
gzip -k file        # 元ファイルを残す（デフォルトでは削除される）
gzip -9 file        # 最大圧縮
zstd -19 file       # zstd の高圧縮
xz -T0 file         # 全コアで並列（大きなファイルには必須）
```

`gzip` はデフォルトで圧縮後に元ファイルを削除します。`-k` で残せます。一括圧縮：`gzip -k *.log`。

## zip と unzip

```bash
zip -r a.zip dir/              # 递归打包
zip -r a.zip dir/ -x '*.git*'  # 排除
zip -e a.zip file              # 加密（会交互要密码）
unzip a.zip                    # 解压
unzip -l a.zip                 # 列清单（先看！）
unzip -o a.zip -d 目标/        # 覆盖解压到指定目录
unzip -P 密码 a.zip             # 带密码（密码会进 shell history，慎用）
```

マシン間でファイルを渡すとき（特に Windows ユーザーへ）は zip を、内部アーカイブには `tar --zstd` を使います。

## 7z

```bash
7z a a.7z dir/        # 圧縮
7z x a.7z             # 展開（ディレクトリ構造を保持、万能な展開）
7z l a.7z             # 一覧表示
7z t a.7z             # 完全性テスト
```

`7z x` は万能展開と呼ばれ、対応形式が最も広い。本機で出所不明のアーカイブを展開するときは：まず `7z l` で一覧を確認し、次に `7z x` で一時ディレクトリへ展開します。

## 本サイトの展開スクリプト

この dotfiles には展開補助スクリプトが 3 つ同梱されています（`scripts/` 配下）。コマンド 1 つで拡張子に応じて展開ツールを選択します。[アーカイブツール](../scripts/archives.html) を参照。日常的には Zsh でスクリプト名をそのまま使い、tar のオプションを覚える必要はありません。

## 実践シナリオ

```bash
# ゴミを除外してプロジェクトをパックして渡す
tar --zstd -cf proj.tar.zst --exclude='.git' --exclude='node_modules' --exclude='.venv' proj/

# 権限を保ったまま設定ディレクトリをバックアップ
tar --zstd -cpf ~/backups/config-$(date +%F).tar.zst -C ~/.config ghostty tmux

# アーカイブの大きさと内部構造を確認
tar --zstd -tf big.tar.zst | head -30

# 増分バックアップの考え方：まずフルバックアップし、以後は rsync で同期（tar の繰り返しより賢い）
rsync -a --delete src/ backup/
```

## トラブルシューティング

**`tar: Error is not recoverable`**：ファイルが破損しているか、形式が一致していません（例：`.tar.xz` を `.tar.gz` として扱う）。`file 包名` で実際の形式を確認してからオプションを選びます。

**展開後にファイル名が文字化けして一画面に並ぶ**：Windows で作成された zip は GBK の可能性があります。`unzip -O gbk a.zip` でエンコーディングを指定します。

**`gzip: stdin: not in gzip format`**：ファイルは gzip ではありません。`file` で確認してください。HTML エラーページをダウンロードしている可能性があります。

**展開でカレントディレクトリが散らかってしまう**：`-C 目标目录` を付ける、または先にクリーンなディレクトリへ cd してから展開する習慣を。展開前に `ls` で一瞥します。

**数十 GB のアーカイブでディスクが満杯になる**：まず `df -h`、`tar -tf` で合計サイズを見積もり、空きが足りなければ先に掃除します。
