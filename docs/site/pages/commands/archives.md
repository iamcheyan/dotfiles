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
