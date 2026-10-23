> 摘要：本章收录常用 Linux 命令的用法，并逐条说明它们在这台 Debian 13 工作机和这套 dotfiles 配置下实际怎么用。

# Linux 命令手册

## 这份手册解决什么问题

网上的命令教程默认你用的是原生 Bash、系统 `ls`/`cat`/`grep`、刚装好的发行版。这套环境不是：

- 发行版是 **Debian 13（trixie）**，跑在 PVE 的虚拟机里，没有物理显示器，桌面是 Xvnc + Xfce 的远程会话。
- Shell 是 **Zsh**，加载 zinit、补全、fzf 和一套别名；很多命令的行为被这套配置改过（`l` 不是 `ls`，`f` 不是 `find`）。
- 大量 GNU 工具被现代替代品接管：`eza` 替代 `ls`、`fd` 替代 `find`、`ripgrep` 替代 `grep`、`bat` 替代 `cat`、`zoxide` 替代 `cd`、`btop` 替代 `top`。
- 另一台常打交道的机器是 **NixOS**（HX90），包管理和服务命令和 Debian 完全不同。

所以本手册每条命令都回答三个问题：**这个命令干什么**、**常用法是什么**、**在这套环境下有什么不同**。

## 阅读方式

| 你的需求 | 去读 |
|---|---|
| 复制、移动、删除、看文件 | [文件与目录](files.html) |
| 看内容、改文本、统计 | [文本处理](text.html) |
| 找文件、搜内容 | [查找](search.html) |
| 看进程、杀进程、后台任务 | [进程与作业](process.html) |
| chmod、sudo、文件归属 | [权限与提权](permissions.html) |
| 磁盘满了、挂载 NAS | [磁盘与挂载](disk.html) |
| IP、端口、下载、传文件 | [网络与传输](network.html) |
| 看系统状态、查日志 | [系统信息与日志](system.html) |
| 装软件（apt / pacman / nix） | [软件包管理](packages.html) |
| tar、zip、压缩 | [压缩与归档](archives.html) |
| 本机特有的操作（gh、tmux、桌面） | [本机环境实战](our-environment.html) |
| 忘了参数，快速查 | [速查表](cheatsheet.html) |

## 三条通用习惯

**1. 先看帮助再动手。** `命令 --help` 是速查，`man 命令` 是完整手册。本机 `man` 分页器是 `less`，`/关键词` 搜索，`q` 退出。

**2. 管道是 Linux 的灵魂。** 一个命令的输出是下一个命令的输入：

```bash
rg -l 'TODO' ~/dotfiles | head -5        # 找含 TODO 的文件，看前 5 个
```

**3. 破坏性操作先确认路径。** `rm -rf`、`dd`、`mkfs`、`chmod -R` 这类命令执行前没有第二次机会。本手册在每篇的排错小节里标注了本机踩过的坑。

## 命令在哪个 shell 里跑

| 场景 | 说明 |
|---|---|
| 普通终端 | Zsh，本手册所有别名和函数都在这里生效 |
| tmux 内 | 同一个 Zsh，但剪贴板走 OSC 52，见 [本机环境实战](our-environment.html) |
| SSH 登录 | 同样加载 Zsh 配置（登录 shell 读 `.zshrc`） |
| 远程工作区 | 命令在远端机器上执行，本机别名不一定存在 |
| 脚本里（`#!/bin/bash`） | 没有别名，必须写完整命令 |

最后一条经常咬人：`init.sh` 和 cron 里的脚本是 `#!/usr/bin/env bash`，**别名不生效**。写脚本时不要依赖 `l`、`ll`、`f` 这些别名。
