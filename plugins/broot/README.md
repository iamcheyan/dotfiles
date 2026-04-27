# Broot 插件配置

## 简介

本目录负责把 `broot` 接入当前 dotfiles：

- `plugins/tools/tools.zsh` 负责安装 `broot` 二进制
- `plugins/broot/broot.zsh` 负责加载 `br` shell function
- `config/broot/init.sh` 负责首次初始化 shell integration

`broot` 本身是交互式目录浏览工具，而真正能在退出后把当前 shell 切到目标目录的是 `br` 这个 shell function。

## 文件说明

### `broot.zsh`

作用：

- 检查 `broot` 命令是否可用
- 检查 `~/.config/broot/launcher/br` 是否已生成
- 在首次使用时调用 `config/broot/init.sh`
- `source` 官方生成的 `br` shell function

### `config/broot/init.sh`

作用：

- 调用 `broot --print-shell-function zsh`
- 同步仓库里的 `config/broot/verbs.hjson` 到 `~/.config/broot/verbs.hjson`
- 把生成结果写入 `~/.config/broot/launcher/br`
- 调用 `broot --set-install-state installed`
- 写入初始化标记，避免每次 shell 启动都重复生成

### `config/broot/verbs.hjson`

作用：

- 把 `:e` 固定为 `nvim +{line} {file}`
- 把文本文件上的 `Enter` 也绑定到同一个 `nvim` 打开动作
- 把 `create` 固定为 `nvim {directory}/{subpath}`
- 把 `:q` 改成 `:cd`，避免依赖某些终端里不稳定的 `Alt+Enter`
- 因为当前 Neovim 配置就是 LazyVim，所以这里等价于“用 LazyVim 打开”

## 使用方式

```bash
broot
br
br -s
```

常见操作：

- 输入关键字过滤目录和文件
- `Enter` 进入目录
- `Alt+Enter` 退出并让当前 shell `cd` 到选中目录
- `:q` 退出
- `?` 打开帮助

## 安装方式

```bash
install:broot
install:broot --force
install:broot --method binary
install:broot --method package
install:broot --method cargo
```

说明：

- `auto`: 先尝试系统包管理器，再尝试 GitHub release 二进制，最后才回退到 `cargo` 编译
- `binary`: 直接从 GitHub Releases 下载对应平台的预编译包
- `cargo`: 本地编译，最慢，但兼容性最好

如果只是加载 Zsh 配置，`tools.zsh` 也会通过 Zinit 自动下载 `broot` 的 release 包。

## 相关文件

- `doc/broot.md` - 用户视角的使用说明
- `scripts/install/install_broot.sh` - 独立安装脚本
- `plugins/tools/tools.zsh` - 工具安装入口
