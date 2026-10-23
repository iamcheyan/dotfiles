> 摘要：ls、cd、cp、mv、rm、mkdir、ln 等文件与目录操作的常用法，以及 eza 接管后的别名差异。

# 文件与目录

## ls 与 eza

`ls` 列出目录内容。本机检测到 `eza` 时会定义三个别名，覆盖 `ls` 的日常使用：

| 别名 | 展开 | 效果 |
|---|---|---|
| `l` | `eza --icons --group-directories-first --sort=modified --reverse` | 最近修改的排最上 |
| `ll` | `eza -lh --icons --group-directories-first --git --sort=modified --reverse` | 长格式 + Git 状态 |
| `la` | `eza -a ...` | 包含隐藏文件 |

没装 eza 时这些别名不存在，直接用系统 `ls`：

```bash
ls -lah            # 长格式、人类可读大小、含隐藏文件
ls -lt             # 按时间排序，最新在前
ls -R              # 递归列出子目录
ls -d */           # 只列目录
```

`eza` 独有但常用的：

```bash
eza -T --level=2   # 两层树状视图
eza -lh --git      # 看每个文件的 Git 状态
eza --sort=size -l # 按大小排
```

## cd 与目录跳转

```bash
cd /path           # 绝对路径
cd ..              # 上一级
cd -               # 回上一个目录（OLDPWD）
cd ~               # 回家，~ 就是 $HOME
cd                 # 不带参数也是回家
```

本机装了 **zoxide**（`z` 命令），记住你去过的目录，按频率跳转：

```bash
z dotfiles        # 跳到 ~/dotfiles（匹配路径任意一段）
z dev cindy       # 多关键词，匹配 ~/development/cindy
zi                # 交互式选择（fzf 列表）
zr                 # zoxide 数据库里删掉已不存在的目录
```

`z` 和 `cd` 混用没问题，zoxide 也会记录 `cd` 过的目录。

## mkdir

```bash
mkdir newdir                  # 建一个目录
mkdir -p a/b/c                # 递归建，已存在不报错（最常用）
mkdir -m 700 secret           # 建的时候直接设权限
```

`-p` 是日常必备：没有它，`a/b/c` 里 `a` 不存在就失败。

## touch

```bash
touch file.txt        # 文件不存在则创建空文件；存在则更新修改时间
touch -d '2026-01-01' file   # 把时间戳改成指定时间
```

本机常用场景：`.keep` 占位文件、触发文件监视（如让 Vite 重载）、清空文件的另一种思路是 `: > file`。

## cp

```bash
cp src dst                   # 复制文件
cp -r dir/ dest/             # 复制目录（-r 必需）
cp -a dir/ dest/             # 归档模式：保留权限、时间戳、符号链接
cp -i file dest              # 覆盖前询问
cp -n file dest              # 不覆盖已存在的文件
cp -u file dest              # 只在源比目标新时复制（增量）
```

跨机器复制用 `rsync` 或 `scp`，见[网络与传输](network.html)。`cp -a` 是备份配置目录的首选，等价于保留一切元数据。

## mv

```bash
mv old new          # 移动或重命名（同一个命令）
mv -i a b           # 覆盖前询问
mv *.log logs/      # 移动一批
```

`mv` 跨文件系统时是"复制+删除"，大目录跨分区移动中途断电可能丢数据，重要数据先 `cp` 再删。

## rm

```bash
rm file             # 删文件
rm -i file          # 询问确认
rm -r dir/          # 递归删目录
rm -rf dir/         # 强制递归删（没有确认，慎用）
```

本机 Zsh 的安全习惯：`rm` 前先 `ls` 一遍通配符展开的结果。Zsh 展开 `*.log` 时如果没匹配到文件会直接报错（不像 Bash 把 `*.log` 原样传给 `rm`），这层保护省过很多事故。

**删掉的文件不进回收站。** 误删后唯一的恢复途径是 ext4 的 `extundelete`（要立即停止写入该分区），日常靠备份：本仓库有每日备份 cron，`~/development` 的仓库靠 Git。

## ln 符号链接

```bash
ln -s /path/to/target linkname      # 建软链接（最常用）
ln -sfn /new/target linkname        # 覆盖已存在的链接（-f 强制，-n 把链接当文件）
ls -l linkname                      # 看链接指向哪里
readlink -f linkname                # 解析到最终真实路径
```

这套 dotfiles 的部署核心就是软链接：`scripts/dotlink` 把仓库里的配置文件链接到 `~/.config/` 等位置。改动配置时先 `readlink -f` 确认你编辑的是仓库里的真身，而不是某个已经断掉的旧链接。

**排错：`too many levels of symbolic links`** — 链接形成了环，用 `ls -l` 顺着指向上看几层就能找到。

## stat 与 file

```bash
stat file          # 看大小、权限、inode、三个时间戳（mtime/atime/ctime）
file archive.unk   # 靠内容判断文件类型，不看扩展名
file -i archive    # 连 MIME 类型一起输出
```

`stat` 的 ctime 是"元数据修改时间"，`chmod` 也会更新它；`touch` 改的是 mtime。

## 权限速查

```bash
ls -l file         # -rw-r--r--：所有者/组/其他人 的读写执行位
chmod +x script.sh # 加执行权限
chmod 600 key      # 仅本人可读写（私钥、凭据文件用这个）
```

详见[权限与提权](permissions.html)。
