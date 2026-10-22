> 摘要：逐项说明自研安装器、版本更新器、软链管理器、fzf 函数和辅助脚本的入口与参数。

# 自定义脚本

## dotlink：管理符号链接

`dotlink/dotlink` 读取 `dotlink/dotlinkrc`，把 `[link]` 中的源路径映射到目标路径。参数支持 `link`、`backups`、`backups_by_path`，不带参数则处理完整配置；查看映射用 `list`。

```bash
bash dotlink/dotlink list
bash dotlink/dotlink link
bash dotlink/dotlink backups
```

规则格式为 `源路径:目标路径`，支持 `$HOME` 和目录通配符。创建链接前会备份目标位置已有的普通文件/目录，再删除目标并建立链接；指向错误位置的旧链接会被替换。先检查配置文件再运行 `link`。

## init.sh：跨平台初始化

```bash
bash init.sh
bash init.sh --minimal
bash init.sh --repair
```

完整模式检查/准备 Zsh、基础命令、子模块、Zinit、fnm、Inshellisense、Fresh、fzf、Neovim、字体、Ranger 插件和额外工具，然后调用 dotlink。`--minimal` 跳过字体、Neovim 和部分大型额外组件；`--repair` 检查/修复损坏的 Zinit 插件。NixOS 系统包由声明式配置管理。

脚本倒数后继续执行，多数安装步骤失败时输出 warning 并继续。完成后检查所需命令及链接。

## Neovim 安装和升级

| 入口 | 用途 | 参数 |
|---|---|---|
| `scripts/install/install_nvim.sh` | init.sh 调用的 Neovim 检查/安装器 | `--version VERSION`、`--force` |
| `nvim-update` / `scripts/update_nvim.sh` | 安装 GitHub 最新稳定版到用户目录 | `--help` |
| `scripts/tests/nvim_update_test.sh` | 本地 fixture 更新流程测试 | `bash scripts/tests/nvim_update_test.sh` |

`nvim-update` 安装到 `~/.local/opt/neovim/<version>`，验证 GitHub release 的 SHA-256、二进制版本和 runtime，再原子更新 `~/.local/bin/nvim`。它不会替换系统包；NixOS 上会拒绝绕过系统配置。

## 字体安装器

`install_font.sh` 没有 `install:font` 别名，直接运行脚本：

```bash
bash scripts/install/install_font.sh
bash scripts/install/install_font.sh --meslo
bash scripts/install/install_font.sh --noto
bash scripts/install/install_font.sh --all --force
```

未指定字体类型时默认安装 Meslo Nerd Font。支持 `--meslo/-m`、`--noto/-n`、`--all/-a`、`--force/-f`。Noto Serif CJK 下载包括日文与简体中文字体文件。

## HTTPie 安装器

`plugins/tools/tools.zsh` 定义 `install:httpie` 函数：

```zsh
install:httpie --method package
install:httpie --method pipx
install:httpie --method pip
install:httpie --force
```

默认顺序是系统包管理器、pipx、pip 用户安装。已经有 `http` 命令时跳过安装，`--force` 可要求重装。

## Zellij 安装器

```bash
bash scripts/install/install_zellij.sh
bash scripts/install/install_zellij.sh --method binary
bash scripts/install/install_zellij.sh --method cargo --force
```

`auto` 在 Cargo 可用时优先源码安装，否则选择 Linux release binary。选项是 `--method cargo|binary` 与 `--force`。若重装失败但原命令仍在，脚本保留旧版本并给出提示。

## fzf 函数 `f` 和 `ffd`

`f` 列当前目录，或消费管道列表；Enter 用 Neovim 打开文件、用 Ranger 打开目录，Alt+Enter 强制 Ranger，Alt+C 复制路径。

```zsh
f
ls | f
```

`ffd` 先按文件名搜索，再交给 fzf。首个参数可以指定目录，后续合并为搜索模式：

```zsh
ffd
ffd bundle.mjs
ffd . main.py
ffd ~/work '*.lua'
```

它为通配符配置了 `noglob`，防止 Zsh 提前展开。实现在 [plugins/fzf/fzf.zsh](https://github.com/iamcheyan/dotfiles/blob/main/plugins/fzf/fzf.zsh)。

## SSH 和 SSHFS

```zsh
vssh
vssh build-box -p 2222 -u deploy
```

`plugins/sshfs/vssh.sh` 从 SSH config 读取 Host alias；有 fzf 时提供 `ssh -G` 参数及短超时 uptime 预览。`plugins/sshfs/vifm-sshfs.sh` 是 SSHFS 挂载版：

```bash
bash plugins/sshfs/vifm-sshfs.sh build-box -p 2222 -d ~/project
```

它依赖 sshfs，挂载位置为 `~/.sshfs/`，随后打开 Vifm；未给 `-d` 时使用远端登录目录。

## 文件和归档工具

| 脚本/命令 | 行为 |
|---|---|
| `packtar 名称` | 当前目录的归档放到父目录，文件名为 `名称.tar.gz` |
| `packtar --day 7 名称` | 选择最近 7 天有变化的文件；不是完整备份 |
| `unzip:here` | 递归找 zip，在归档所在目录解压且不覆盖已有文件 |
| `tools/unzip_all.sh` | 每个 zip 解压到同名子目录 |
| `tools/open_windows_folder.sh [路径]` | WSL 中打开 Windows Explorer |
| `vifm-copy 文本` | 选择可用剪贴板后端复制文本 |

`packtar` 在 Git 仓库中结合 `.gitignore` 过滤文件，并默认只收集最近一天有变化的文件。传 `--day N` 调整时间范围。不要把它误当完整仓库备份。

## 高影响脚本

`tools/clear.sh` 是 WSL 清理脚本，会用 sudo 清理 Cargo/Pip/apt 缓存、日志并删除 `/tmp/*`，之后列出大文件和目录用量。运行前阅读完整脚本，确认机器和清理范围。

`tools/winetricks.sh` 在 Silverblue/Kinoite 通过 Toolbox 中的 Wine 转发；其他系统会探测或安装 winetricks，再执行传入参数。
