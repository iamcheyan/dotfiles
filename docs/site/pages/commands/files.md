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

`eza` 独有但常用的别名与参数：

```bash
lt                 # 完整树状视图（eza --tree）
lt1 / lt2 / lt3    # 限制递归层级的树状视图（--level=1/2/3）
lsd                # 简洁时间视图（隐藏权限与属主，相对时间）
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
wt                 # 交互式选择并切换 Git worktree（基于 fzf）
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

<!-- lang:en -->

> Summary: Common usage of files and directories — ls, cd, cp, mv, rm, mkdir, ln, and more — plus how the aliases differ once eza takes over.

# Files and Directories

## ls and eza

`ls` lists directory contents. On this machine, when `eza` is detected, three aliases are defined that take over everyday use of `ls`:

| Alias | Expands to | Effect |
|---|---|---|
| `l` | `eza --icons --group-directories-first --sort=modified --reverse` | Most recently modified on top |
| `ll` | `eza -lh --icons --group-directories-first --git --sort=modified --reverse` | Long format + Git status |
| `la` | `eza -a ...` | Includes hidden files |

Without eza installed these aliases do not exist; you get the system `ls` directly:

```bash
ls -lah            # 长格式、人类可读大小、含隐藏文件
ls -lt             # 按时间排序，最新在前
ls -R              # 递归列出子目录
ls -d */           # 只列目录
```

`eza`-only aliases and common options:

```bash
lt                 # Full recursive tree view (eza --tree)
lt1 / lt2 / lt3    # Level-restricted tree views (--level=1/2/3)
lsd                # Concise relative-time view without permissions/owner
eza -lh --git      # See each file's Git status
eza --sort=size -l # Sort by size
```

## cd and jumping between directories

```bash
cd /path           # 绝对路径
cd ..              # 上一级
cd -               # 回上一个目录（OLDPWD）
cd ~               # 回家，~ 就是 $HOME
cd                 # 不带参数也是回家
```

This machine has **zoxide** installed (the `z` command), which remembers the directories you have visited and jumps by frequency:

```bash
z dotfiles        # 跳到 ~/dotfiles（匹配路径任意一段）
z dev cindy       # 多关键词，匹配 ~/development/cindy
zi                # 交互式选择（fzf 列表）
zr                 # zoxide 数据库里删掉已不存在的目录
wt                 # 交互式选择并切换 Git worktree（基于 fzf）
```

Mixing `z` and `cd` is fine — zoxide also records directories reached via `cd`.

## mkdir

```bash
mkdir newdir                  # 建一个目录
mkdir -p a/b/c                # 递归建，已存在不报错（最常用）
mkdir -m 700 secret           # 建的时候直接设权限
```

`-p` is an everyday essential: without it, `a/b/c` fails if `a` does not exist.

## touch

```bash
touch file.txt        # 文件不存在则创建空文件；存在则更新修改时间
touch -d '2026-01-01' file   # 把时间戳改成指定时间
```

Common uses on this machine: `.keep` placeholder files, triggering file watchers (e.g. making Vite reload); another way to empty a file is `: > file`.

## cp

```bash
cp src dst                   # 复制文件
cp -r dir/ dest/             # 复制目录（-r 必需）
cp -a dir/ dest/             # 归档模式：保留权限、时间戳、符号链接
cp -i file dest              # 覆盖前询问
cp -n file dest              # 不覆盖已存在的文件
cp -u file dest              # 只在源比目标新时复制（增量）
```

For copying across machines use `rsync` or `scp`; see [Network and Transfer](network.html). `cp -a` is the first choice for backing up config directories — it preserves all metadata.

## mv

```bash
mv old new          # 移动或重命名（同一个命令）
mv -i a b           # 覆盖前询问
mv *.log logs/      # 移动一批
```

Across filesystems, `mv` is "copy + delete"; a power loss mid-move of a large directory across partitions can lose data. For important data, `cp` first and delete after.

## rm

```bash
rm file             # 删文件
rm -i file          # 询问确认
rm -r dir/          # 递归删目录
rm -rf dir/         # 强制递归删（没有确认，慎用）
```

Local Zsh safety habit: run `ls` on the glob expansion before `rm`. When Zsh expands `*.log` and nothing matches, it errors out immediately (unlike Bash, which passes the literal `*.log` to `rm`) — this layer of protection has prevented many accidents.

**Deleted files do not go to a trash can.** After accidental deletion, the only recovery path is ext4's `extundelete` (stop writing to that partition immediately); day to day, rely on backups: this repo has a daily backup cron, and the repos under `~/development` rely on Git.

## ln symbolic links

```bash
ln -s /path/to/target linkname      # 建软链接（最常用）
ln -sfn /new/target linkname        # 覆盖已存在的链接（-f 强制，-n 把链接当文件）
ls -l linkname                      # 看链接指向哪里
readlink -f linkname                # 解析到最终真实路径
```

The deployment core of these dotfiles is symlinks: `scripts/dotlink` links the config files in the repo to `~/.config/` and similar locations. When editing config, run `readlink -f` first to confirm you are editing the real file in the repo, not some stale broken link.

**Troubleshooting: `too many levels of symbolic links`** — the links form a loop; follow them with `ls -l` a few levels up and you will find it.

## stat and file

```bash
stat file          # 看大小、权限、inode、三个时间戳（mtime/atime/ctime）
file archive.unk   # 靠内容判断文件类型，不看扩展名
file -i archive    # 连 MIME 类型一起输出
```

`stat`'s ctime is the "metadata change time"; `chmod` also updates it. `touch` changes the mtime.

## Permissions cheatsheet

```bash
ls -l file         # -rw-r--r--：所有者/组/其他人 的读写执行位
chmod +x script.sh # 加执行权限
chmod 600 key      # 仅本人可读写（私钥、凭据文件用这个）
```

See [Permissions and Privilege Escalation](permissions.html) for details.

<!-- lang:ja -->

> 摘要：ls・cd・cp・mv・rm・mkdir・ln などのファイルとディレクトリ操作の定番の使い方と、eza 導入後のエイリアスの違い。

# ファイルとディレクトリ

## ls と eza

`ls` はディレクトリ内容を一覧表示します。本機では `eza` が検出されると 3 つのエイリアスが定義され、日常の `ls` を置き換えます：

| エイリアス | 展開 | 効果 |
|---|---|---|
| `l` | `eza --icons --group-directories-first --sort=modified --reverse` | 最近変更したものが上に |
| `ll` | `eza -lh --icons --group-directories-first --git --sort=modified --reverse` | 長形式 + Git 状態 |
| `la` | `eza -a ...` | 隠しファイルも含む |

eza が入っていなければこれらのエイリアスは存在せず、システムの `ls` をそのまま使います：

```bash
ls -lah            # 长格式、人类可读大小、含隐藏文件
ls -lt             # 按时间排序，最新在前
ls -R              # 递归列出子目录
ls -d */           # 只列目录
```

`eza` 固有の別名とよく使うオプション：

```bash
lt                 # ツリービュー全体（eza --tree）
lt1 / lt2 / lt3    # 階層を制限したツリービュー（--level=1/2/3）
lsd                # 簡潔表示（権限・所有者を省き、相対時間を表示）
eza -lh --git      # 各ファイルの Git ステータスを確認
eza --sort=size -l # サイズ順にソート
```

## cd とディレクトリ移動

```bash
cd /path           # 绝对路径
cd ..              # 上一级
cd -               # 回上一个目录（OLDPWD）
cd ~               # 回家，~ 就是 $HOME
cd                 # 不带参数也是回家
```

本機には **zoxide**（`z` コマンド）が入っており、訪れたディレクトリを記憶して頻度に応じてジャンプします：

```bash
z dotfiles        # 跳到 ~/dotfiles（匹配路径任意一段）
z dev cindy       # 多关键词，匹配 ~/development/cindy
zi                # 交互式选择（fzf 列表）
zr                 # zoxide 数据库里删掉已不存在的目录
wt                 # 交互式选择并切换 Git worktree（基于 fzf）
```

`z` と `cd` の混用は問題ありません。zoxide は `cd` で移動したディレクトリも記録します。

## mkdir

```bash
mkdir newdir                  # 建一个目录
mkdir -p a/b/c                # 递归建，已存在不报错（最常用）
mkdir -m 700 secret           # 建的时候直接设权限
```

`-p` は日常必須です。付けないと、`a/b/c` は `a` が存在しない時点で失敗します。

## touch

```bash
touch file.txt        # 文件不存在则创建空文件；存在则更新修改时间
touch -d '2026-01-01' file   # 把时间戳改成指定时间
```

本機でのよくある使い道：`.keep` のプレースホルダファイル、ファイル監視の発火（例：Vite のリロード）。ファイルを空にする別の方法は `: > file` です。

## cp

```bash
cp src dst                   # 复制文件
cp -r dir/ dest/             # 复制目录（-r 必需）
cp -a dir/ dest/             # 归档模式：保留权限、时间戳、符号链接
cp -i file dest              # 覆盖前询问
cp -n file dest              # 不覆盖已存在的文件
cp -u file dest              # 只在源比目标新时复制（增量）
```

マシン間のコピーには `rsync` か `scp` を使います。[ネットワークと転送](network.html) を参照。`cp -a` は設定ディレクトリのバックアップの第一候補で、すべてのメタデータを保持します。

## mv

```bash
mv old new          # 移动或重命名（同一个命令）
mv -i a b           # 覆盖前询问
mv *.log logs/      # 移动一批
```

ファイルシステムをまたぐ `mv` は「コピー + 削除」です。大きなディレクトリをパーティション越しに移動中に電源が落ちるとデータを失うことがあります。大事なデータは先に `cp` してから消します。

## rm

```bash
rm file             # 删文件
rm -i file          # 询问确认
rm -r dir/          # 递归删目录
rm -rf dir/         # 强制递归删（没有确认，慎用）
```

本機の Zsh の安全習慣：`rm` の前にグロブ展開の結果を `ls` で一度確認します。Zsh は `*.log` が何にもマッチしないと即エラーになります（Bash はリテラルの `*.log` をそのまま `rm` に渡します）。この保護層が多くの事故を防いできました。

**削除したファイルはゴミ箱に入りません。** 誤って消した後の唯一の復旧手段は ext4 の `extundelete`（ただちにそのパーティションへの書き込みを止めること）。日常はバックアップに頼ります：このリポジトリには毎日バックアップする cron があり、`~/development` 配下のリポジトリは Git に頼ります。

## ln シンボリックリンク

```bash
ln -s /path/to/target linkname      # 建软链接（最常用）
ln -sfn /new/target linkname        # 覆盖已存在的链接（-f 强制，-n 把链接当文件）
ls -l linkname                      # 看链接指向哪里
readlink -f linkname                # 解析到最终真实路径
```

この dotfiles のデプロイの中核はシンボリックリンクです：`scripts/dotlink` がリポジトリ内の設定ファイルを `~/.config/` などへリンクします。設定を編集するときは先に `readlink -f` で、リポジトリ内の実物を編集しているのか、切れた古いリンクではないのかを確認します。

**トラブルシューティング：`too many levels of symbolic links`** — リンクがループになっています。`ls -l` で指し先を何段階か辿れば見つかります。

## stat と file

```bash
stat file          # 看大小、权限、inode、三个时间戳（mtime/atime/ctime）
file archive.unk   # 靠内容判断文件类型，不看扩展名
file -i archive    # 连 MIME 类型一起输出
```

`stat` の ctime は「メタデータ変更時刻」で、`chmod` でも更新されます。`touch` が変えるのは mtime です。

## パーミッション速査

```bash
ls -l file         # -rw-r--r--：所有者/组/其他人 的读写执行位
chmod +x script.sh # 加执行权限
chmod 600 key      # 仅本人可读写（私钥、凭据文件用这个）
```

詳細は [パーミッションと権限昇格](permissions.html) を参照。
