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
