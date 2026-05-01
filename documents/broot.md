# broot

`broot` 是一个交互式目录浏览工具，可以理解成：

“在终端里用搜索 + 树状结构快速找到文件或目录，然后直接进入或操作”

它比 `tree`、`find`、`cd` 组合更偏交互式，尤其适合：

- 不记得目录完整路径，只记得一部分名字
- 想边看目录结构边搜索
- 想从搜索结果里直接 `cd` 到目标目录

## 安装

本仓库提供两种接入方式：

```bash
install:broot
install:broot --method binary
install:broot --method package
install:broot --method cargo
```

说明：

- `package`: 走系统仓库
- `binary`: 直接下载 GitHub Releases 预编译二进制
- `cargo`: 本地编译安装
- `auto`: 默认顺序为 `package -> binary -> cargo`

或者直接加载 Zsh 配置，让 `plugins/tools/tools.zsh` 通过 Zinit 自动下载 release 包。

## 初始化

为了让 `broot` 在退出后真正切换当前 shell 目录，需要 `br` shell function。

本仓库会在加载 `plugins/broot/broot.zsh` 时自动完成：

- 生成 `~/.config/broot/launcher/br`
- 同步 `~/dotfiles/config/broot/verbs.hjson` 到 `~/.config/broot/verbs.hjson`
- `source` 这个 launcher
- 让 `Alt+Enter` 后能够把当前 shell `cd` 到选中的目录

另外，默认编辑器已固定为：

```bash
nvim
```

也就是直接打开你当前的 LazyVim 配置。

如果要手动重建：

```bash
bash ~/dotfiles/config/broot/init.sh
source ~/.zshrc
```

## 常用命令

```bash
broot
br
br -s
```

说明：

- `broot`: 直接启动
- `br`: 启动带 shell integration 的入口
- `br -s`: 以更适合总览目录大小和层级的方式打开

## 常用操作

- 直接输入关键字：过滤文件和目录
- `Enter`：进入选中目录或打开文件
- 文本文件上按 `Enter`：退出 broot，切到文件所在目录，再用 LazyVim 打开
- `Alt+Enter`：退出并把当前 shell 切到选中目录
- `:q`：在这套配置里被改成 `:cd`，用于退出并停留在当前目录
- `Esc`：清空搜索或返回上一步
- `?`：查看帮助

## 使用建议

- 把 `br` 当成交互式 `cd`
- 把 `br -s` 当成更好用的目录概览器
- 配合 `rg` / `fd` 用于“先定位大概区域，再进去精确操作”

## 相关文件

- `plugins/broot/broot.zsh`
- `plugins/broot/README.md`
- `config/broot/init.sh`
- `scripts/install/install_broot.sh`
