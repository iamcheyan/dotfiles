> 摘要：chmod、chown、sudo、pkexec 等权限命令，含数字权限记法、私钥保护和本机提权路径。

# 权限与提权

## 权限模型速成

Linux 每个文件有三组权限位：**所有者（u）**、**所属组（g）**、**其他人（o）**，每组有读（r=4）、写（w=2）、执行（x=1）。

```bash
ls -l script.sh
# -rwxr-xr--
#  -| 所有者 | 组 | 其他
#  文件类型：- 普通文件，d 目录，l 符号链接
```

读法：`rwx r-x r--` = 所有者全部权限、组能读能执行、其他人只读。

## chmod

**符号记法**（直观，适合小改动）：

```bash
chmod +x script.sh        # 三类用户都加执行
chmod u+x script.sh       # 只给所有者加
chmod go-w file           # 去掉组和其他的写权限
chmod a=r file            # 所有人只读
chmod u=rwx,go=rx file    # 精确设置
chmod -R u=rwX,go= dir/   # 递归；大写 X 只给目录加执行，不动文件
```

**数字记法**（常用值背下来）：

```bash
chmod 600 file    # rw-------  仅本人可读写（私钥、凭据、.env）
chmod 644 file    # rw-r--r--  本人可写，其他人可读（普通文件）
chmod 700 dir     # rwx------  仅本人可进（私密目录）
chmod 755 dir     # rwxr-xr-x  本人全权，其他人可读可进（可执行目录）
chmod 400 key     # r--------  只读（SSH 私钥最严）
chmod 666 file    # rw-rw-rw-  所有人可写（共享暂存，尽量少用）
```

记法：三位数字分别是 u、g、o，每位 = 4+2+1 的组合。

**常用场景对照**：

| 场景 | 命令 |
|---|---|
| 脚本加执行权限 | `chmod +x script.sh` |
| SSH 私钥 | `chmod 600 ~/.ssh/id_*` |
| 公开站点文件 | `chmod 644 *.html`、`chmod 755 目录` |
| 整个配置目录归自己 | `chmod -R u=rwX,go= ~/.config/xxx` |
| 修 `bad interpreter` | 先 `chmod +x`，还报就 `tr -d '\r'` |

**排错：`Permission denied` 跑脚本** — `ls -l` 看有没有 x 位，没有就 `chmod +x`。

**排错：chmod 后目录进不去了** — 对目录来说 x 是"可进入"，`chmod -x dir` 后里面文件还能列（r）但打不开。修：`chmod u+x dir`。

## chown 与 chgrp

```bash
chown user file            # 改所有者
chown user:group file      # 同时改组和组
chown -R user:group dir/   # 递归
chgrp group file           # 只改组
```

普通用户不能把文件"送"给别人（只有 root 能），但可以把自己拥有的文件改组（自己所在的组）。常见用途：把文件纳入共享组，例如 `chown :docker ~/.docker` 之类。日常用得多的是反过来的排查：`ls -l` 发现文件 owner 是 root，说明当年命令带了 `sudo`。

## umask

新文件的默认权限由 umask 决定（从 666/777 里减掉掩码）：

```bash
umask           # 查看（通常 0022 或 0002）
umask 077       # 新文件只有本人能访问（临时处理敏感文件前先设）
umask 022       # 恢复常见默认
```

在 Zsh 里对单个命令设置：`(umask 077 && touch secret)` 子 shell 里生效，不影响当前会话。

## sudo

```bash
sudo command              # 以 root 执行
sudo -i                   # 切换 root 登录 shell
sudo -u user command      # 以指定用户执行
sudo !!                   # 用 sudo 重跑上一条命令（忘了加 sudo 时神器）
sudo -v                   # 续期凭据缓存（不用重复输密码）
```

`sudo !!` 值得背下来：提示 `Permission denied` 之后直接敲它。

本机是 sudo 免密用户（tetsuya 在 sudoers NOPASSWD 组），但**免密不等于可以乱来**——`sudo rm -rf /` 没有第二次确认。涉及系统级操作前先想备份，见[维护与边界](../maintenance/boundaries.html)。

**日志**：sudo 执行记录在 `/var/log/auth.log`，出安全相关问题时 `sudo grep sudo /var/log/auth.log | tail`。

## su 与用户切换

```bash
su - user         # 切换用户并加载其登录环境（- 不能省）
su -              # 切 root
exit              # 切回去
```

服务账号排查时用，例如 `su - tetsuya` 从 root 回到本人验证权限问题。

## pkexec

图形会话里弹出的提权对话框走 polkit：

```bash
pkexec command    # 以 root 执行，弹图形认证框
pkexec bash       # root shell（不推荐日常用）
```

本机的桌面环境（Xvnc 会话）里，需要 root 的 GUI 操作（如包管理器）会走这条路。**审查自定义 polkit 规则是安全纪律**：规则文件在 `/usr/share/polkit-1/rules.d/` 和 `/etc/polkit-1/rules.d/`，新增规则要看清它给谁授权、授权范围多大。规则写宽了（比如对任何含 `mount.cifs` 的命令直接放行）等于开后门。

## 组与身份

```bash
id                 # 当前 uid/gid/所属组
id user            # 查别人
groups             # 我所在的组
getent group docker  # 看组成员（确认加组是否生效）
newgrp docker      # 临时切换到附加组（不用重新登录）
```

**改组成员要重新登录才生效**（或 `newgrp`）。`usermod -aG group user` 的 `-a` 是 append，**漏了 -a 会把人从所有其它组删掉**——这是经典事故。

## 排错

**`sudo: command not found`**：sudo 语境下 PATH 不含用户目录，用完整路径 `sudo /full/path/cmd`。

**私钥权限太松 SSH 拒绝**：`Permissions 0644 for 'id_ed25519' are too open`，`chmod 600` 它。

**文件 owner 是 root 改不动**：`sudo chown tetsuya:tetsuya file`。

**`sudo` 免密突然失效**：NOPASSWD 规则被组变更影响，`id` 确认自己还在 sudo 组。

<!-- lang:en -->

> Summary: Permission commands such as chmod, chown, sudo, and pkexec, including numeric permission notation, private key protection, and privilege-escalation paths on this machine.

# Permissions and Privilege Escalation

## Permission model crash course

Every Linux file has three sets of permission bits: **owner (u)**, **group (g)**, and **others (o)**; each set has read (r=4), write (w=2), and execute (x=1).

```bash
ls -l script.sh
# -rwxr-xr--
#  -| 所有者 | 组 | 其他
#  文件类型：- 普通文件，d 目录，l 符号链接
```

How to read it: `rwx r-x r--` = the owner has full permissions, the group can read and execute, others can only read.

## chmod

**Symbolic notation** (intuitive, good for small changes):

```bash
chmod +x script.sh        # 三类用户都加执行
chmod u+x script.sh       # 只给所有者加
chmod go-w file           # 去掉组和其他的写权限
chmod a=r file            # 所有人只读
chmod u=rwx,go=rx file    # 精确设置
chmod -R u=rwX,go= dir/   # 递归；大写 X 只给目录加执行，不动文件
```

**Numeric notation** (memorize the common values):

```bash
chmod 600 file    # rw-------  仅本人可读写（私钥、凭据、.env）
chmod 644 file    # rw-r--r--  本人可写，其他人可读（普通文件）
chmod 700 dir     # rwx------  仅本人可进（私密目录）
chmod 755 dir     # rwxr-xr-x  本人全权，其他人可读可进（可执行目录）
chmod 400 key     # r--------  只读（SSH 私钥最严）
chmod 666 file    # rw-rw-rw-  所有人可写（共享暂存，尽量少用）
```

The notation: the three digits are u, g, and o respectively, and each digit is a combination of 4+2+1.

**Common scenarios at a glance**:

| 场景 | 命令 |
|---|---|
| 脚本加执行权限 | `chmod +x script.sh` |
| SSH 私钥 | `chmod 600 ~/.ssh/id_*` |
| 公开站点文件 | `chmod 644 *.html`、`chmod 755 目录` |
| 整个配置目录归自己 | `chmod -R u=rwX,go= ~/.config/xxx` |
| 修 `bad interpreter` | 先 `chmod +x`，还报就 `tr -d '\r'` |

**Troubleshooting: `Permission denied` when running a script** — check with `ls -l` whether the x bit exists; if not, `chmod +x`.

**Troubleshooting: can't enter a directory after chmod** — for directories, x means "can enter"; after `chmod -x dir` you can still list the files inside (r) but can't open them. Fix with `chmod u+x dir`.

## chown and chgrp

```bash
chown user file            # 改所有者
chown user:group file      # 同时改组和组
chown -R user:group dir/   # 递归
chgrp group file           # 只改组
```

A normal user cannot "give" a file to someone else (only root can), but can change the group of a file they own (to a group they belong to). A common use: put a file into a shared group, e.g. something like `chown :docker ~/.docker`. The more common daily use is the reverse diagnosis: `ls -l` shows a file's owner is root, meaning the original command ran with `sudo`.

## umask

The default permissions of new files are decided by the umask (subtracted from 666/777):

```bash
umask           # 查看（通常 0022 或 0002）
umask 077       # 新文件只有本人能访问（临时处理敏感文件前先设）
umask 022       # 恢复常见默认
```

In Zsh, to set it for a single command: `(umask 077 && touch secret)` takes effect inside a subshell and doesn't affect the current session.

## sudo

```bash
sudo command              # 以 root 执行
sudo -i                   # 切换 root 登录 shell
sudo -u user command      # 以指定用户执行
sudo !!                   # 用 sudo 重跑上一条命令（忘了加 sudo 时神器）
sudo -v                   # 续期凭据缓存（不用重复输密码）
```

`sudo !!` is worth memorizing: after a `Permission denied` prompt, just type it.

This machine is a passwordless-sudo user (tetsuya is in the sudoers NOPASSWD group), but **passwordless does not mean reckless** — `sudo rm -rf /` has no second confirmation. Think about backups before any system-level operation; see [Maintenance and boundaries](../maintenance/boundaries.html).

**Logs**: sudo executions are recorded in `/var/log/auth.log`; for security-related issues, run `sudo grep sudo /var/log/auth.log | tail`.

## su and switching users

```bash
su - user         # 切换用户并加载其登录环境（- 不能省）
su -              # 切 root
exit              # 切回去
```

Used when investigating service accounts, e.g. `su - tetsuya` from root back to yourself to verify permission problems.

## pkexec

Privilege-escalation dialogs in graphical sessions go through polkit:

```bash
pkexec command    # 以 root 执行，弹图形认证框
pkexec bash       # root shell（不推荐日常用）
```

Inside this machine's desktop environment (the Xvnc session), GUI operations that need root (such as a package manager) go this route. **Reviewing custom polkit rules is a security discipline**: rule files live in `/usr/share/polkit-1/rules.d/` and `/etc/polkit-1/rules.d/`; when adding a rule, look carefully at whom it authorizes and how broad the scope is. A rule written too loosely (for example, allowing any command containing `mount.cifs`) is equivalent to opening a backdoor.

## Groups and identity

```bash
id                 # 当前 uid/gid/所属组
id user            # 查别人
groups             # 我所在的组
getent group docker  # 看组成员（确认加组是否生效）
newgrp docker      # 临时切换到附加组（不用重新登录）
```

**Group membership changes require re-login to take effect** (or `newgrp`). In `usermod -aG group user`, `-a` means append — **omitting -a removes the user from all other groups**, a classic accident.

## Troubleshooting

**`sudo: command not found`**: the PATH under sudo doesn't include user directories; use the full path `sudo /full/path/cmd`.

**SSH rejects a private key with loose permissions**: `Permissions 0644 for 'id_ed25519' are too open`; run `chmod 600` on it.

**Can't modify a file owned by root**: `sudo chown tetsuya:tetsuya file`.

**Passwordless `sudo` suddenly stops working**: the NOPASSWD rule was affected by a group change; use `id` to confirm you're still in the sudo group.

<!-- lang:ja -->

> 要約：chmod、chown、sudo、pkexec などの権限コマンド。数値パーミッションの記法、秘密鍵の保護、本機での権限昇格の経路も含みます。

# 権限と昇格

## 権限モデル入門

Linux の各ファイルには 3 組の権限ビットがあります：**所有者（u）**、**グループ（g）**、**その他（o）**で、各組に読み取り（r=4）、書き込み（w=2）、実行（x=1）があります。

```bash
ls -l script.sh
# -rwxr-xr--
#  -| 所有者 | 组 | 其他
#  文件类型：- 普通文件，d 目录，l 符号链接
```

読み方：`rwx r-x r--` は、所有者が全権限、グループは読み取りと実行が可能、その他は読み取りのみを意味します。

## chmod

**シンボリック記法**（直感的で、小さな変更に向きます）：

```bash
chmod +x script.sh        # 三类用户都加执行
chmod u+x script.sh       # 只给所有者加
chmod go-w file           # 去掉组和其他的写权限
chmod a=r file            # 所有人只读
chmod u=rwx,go=rx file    # 精确设置
chmod -R u=rwX,go= dir/   # 递归；大写 X 只给目录加执行，不动文件
```

**数値記法**（よく使う値は暗記しましょう）：

```bash
chmod 600 file    # rw-------  仅本人可读写（私钥、凭据、.env）
chmod 644 file    # rw-r--r--  本人可写，其他人可读（普通文件）
chmod 700 dir     # rwx------  仅本人可进（私密目录）
chmod 755 dir     # rwxr-xr-x  本人全权，其他人可读可进（可执行目录）
chmod 400 key     # r--------  只读（SSH 私钥最严）
chmod 666 file    # rw-rw-rw-  所有人可写（共享暂存，尽量少用）
```

覚え方：3 桁の数字はそれぞれ u、g、o で、各桁は 4+2+1 の組み合わせです。

**よくあるシナリオの一覧**：

| 场景 | 命令 |
|---|---|
| 脚本加执行权限 | `chmod +x script.sh` |
| SSH 私钥 | `chmod 600 ~/.ssh/id_*` |
| 公开站点文件 | `chmod 644 *.html`、`chmod 755 目录` |
| 整个配置目录归自己 | `chmod -R u=rwX,go= ~/.config/xxx` |
| 修 `bad interpreter` | 先 `chmod +x`，还报就 `tr -d '\r'` |

**トラブル：スクリプト実行時の `Permission denied`** — `ls -l` で x ビットがあるか確認し、なければ `chmod +x` します。

**トラブル：chmod 後にディレクトリに入れない** — ディレクトリにとって x は「入れる」の意味です。`chmod -x dir` の後でも中のファイルは一覧できます（r）が、開けません。修正は `chmod u+x dir`。

## chown と chgrp

```bash
chown user file            # 改所有者
chown user:group file      # 同时改组和组
chown -R user:group dir/   # 递归
chgrp group file           # 只改组
```

一般ユーザーはファイルを他人に「譲る」ことはできません（root だけができます）が、自分の所有するファイルのグループを（自分が属するグループに）変更することはできます。よくある用途は、ファイルを共有グループに入れること、例えば `chown :docker ~/.docker` のようなものです。日常でよく使うのはむしろ逆の調査で、`ls -l` でファイルの owner が root なら、当時コマンドに `sudo` を付けたことを意味します。

## umask

新規ファイルのデフォルト権限は umask で決まります（666/777 からマスクを引きます）：

```bash
umask           # 查看（通常 0022 或 0002）
umask 077       # 新文件只有本人能访问（临时处理敏感文件前先设）
umask 022       # 恢复常见默认
```

Zsh で単一コマンドに対して設定するには：`(umask 077 && touch secret)` のようにサブシェル内で有効にし、現在のセッションには影響させません。

## sudo

```bash
sudo command              # 以 root 执行
sudo -i                   # 切换 root 登录 shell
sudo -u user command      # 以指定用户执行
sudo !!                   # 用 sudo 重跑上一条命令（忘了加 sudo 时神器）
sudo -v                   # 续期凭据缓存（不用重复输密码）
```

`sudo !!` は暗記する価値があります：`Permission denied` と出た直後にそのまま叩けばいいのです。

本機は sudo パスワードなしのユーザーです（tetsuya は sudoers の NOPASSWD グループ）が、**パスワードなしだからといって好き勝手してよいわけではありません** — `sudo rm -rf /` には 2 度目の確認はありません。システムレベルの操作の前には必ずバックアップを考えます。[メンテナンスと境界](../maintenance/boundaries.html)を参照してください。

**ログ**：sudo の実行記録は `/var/log/auth.log` にあります。セキュリティ関連の問題が出たら `sudo grep sudo /var/log/auth.log | tail` を実行します。

## su とユーザー切り替え

```bash
su - user         # 切换用户并加载其登录环境（- 不能省）
su -              # 切 root
exit              # 切回去
```

サービスアカウントの調査時に使います。例えば root から `su - tetsuya` で本人に戻り、権限の問題を検証します。

## pkexec

グラフィカルセッションで出る昇格ダイアログは polkit を経由します：

```bash
pkexec command    # 以 root 执行，弹图形认证框
pkexec bash       # root shell（不推荐日常用）
```

本機のデスクトップ環境（Xvnc セッション）では、root が必要な GUI 操作（パッケージマネージャーなど）はこの経路を使います。**カスタム polkit ルールのレビューはセキュリティ規律です**：ルールファイルは `/usr/share/polkit-1/rules.d/` と `/etc/polkit-1/rules.d/` にあり、新しいルールを追加するときは誰にどの範囲の権限を与えるのかをよく確認します。ルールを広く書きすぎると（例えば `mount.cifs` を含むすべてのコマンドを無条件に許可するなど）バックドアを開けるのと同じです。

## グループと身元

```bash
id                 # 当前 uid/gid/所属组
id user            # 查别人
groups             # 我所在的组
getent group docker  # 看组成员（确认加组是否生效）
newgrp docker      # 临时切换到附加组（不用重新登录）
```

**グループの変更は再ログインして初めて有効になります**（または `newgrp`）。`usermod -aG group user` の `-a` は append の意味で、**-a を忘れるとユーザーは他のすべてのグループから外されます** — 典型的な事故です。

## トラブルシューティング

**`sudo: command not found`**：sudo 環境下の PATH にはユーザーディレクトリが含まれないので、フルパスで `sudo /full/path/cmd` とします。

**秘密鍵の権限が緩くて SSH に拒否される**：`Permissions 0644 for 'id_ed25519' are too open`。`chmod 600` を実行します。

**owner が root のファイルが変更できない**：`sudo chown tetsuya:tetsuya file`。

**`sudo` のパスワードなし化が突然効かなくなる**：NOPASSWD ルールがグループ変更の影響を受けています。`id` で自分がまだ sudo グループにいるか確認します。
