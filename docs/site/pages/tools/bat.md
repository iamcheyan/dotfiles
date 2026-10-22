> 摘要：bat 是带语法高亮的 cat，同时是 fzf 的文件预览器。

# bat

## 用途

`bat` 读取文件并语法高亮，附带行号、Git 变更标记和自动分页。本仓库用它做两件事：手动查看文件，以及作为 fzf 的预览渲染器。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 可执行名 | `bat`（Debian 系统包里叫 `batcat`，本仓库用 Zinit 版本，不受影响） |

```zsh
zi_cmd sharkdp/bat bat
```

`zi_cmd` 是 `tools.zsh` 里定义的辅助函数：

```zsh
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}
```

它把「从 GitHub Release 取二进制、指定可执行文件名」压缩成一行。首次启动 Zsh 时 Zinit 自动下载。

## 基本用法

```bash
bat file.txt              # 高亮显示
bat -n file.txt           # 只显示行号，不加头部信息
bat -p file.txt           # plain：不加行号和头部
bat file1 file2           # 连续显示多个文件
cat file | bat            # 从标准输入读
bat --list-languages      # 支持的语法
```

默认输出会带一个文件信息头部（文件名、大小、语言）和左侧行号栏，并自动调用 pager。想当 `cat` 用，用 `-p`：

```bash
alias cat='bat -p'        # 本仓库没有这样设，只是举例
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-n` / `--number` | 只显示行号，不显示头部 |
| `-p` / `--plain` | 不显示行号、头部、Git 标记 |
| `-A` / `--show-all` | 显示不可见字符（空格、Tab、换行） |
| `-l` / `--language` | 强制指定语法 |
| `--style` | 控制显示哪些组件：`numbers`、`grid`、`header`、`changes`、`snip` |
| `--line-range :300` | 只显示前 300 行 |
| `--theme` | 配色主题，`bat --list-themes` 查看 |
| `-d` / `--diff` | 只显示 Git 变更的行 |
| `--paging=never` | 不分页，直接输出 |

## 本仓库里的用法

fzf 的文件预览：

```zsh
--preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})'
```

三个关键点：

1. **`--color=always`** — fzf 预览通过管道输出，默认 `auto` 会检测到非终端而关闭颜色。
2. **`--line-range :300`** — 大文件只渲染前 300 行，避免预览卡顿。
3. **`--style=numbers`** — 只留行号，去掉头部和网格，预览区空间有限。

目录分支用 `ls -F --color=always`，因为 bat 不能列目录。

## 作为 Git pager

`bat` 可以替代 `less` 作为 Git 的分页器：

```bash
git config --global core.pager "bat --style=numbers --color=always"
```

本仓库没有自动设置这一项，因为 `delta` 承担了 diff 的渲染（见 [delta](delta.html)）。两者职责不同：delta 处理 diff，bat 处理普通文件。

## 排错

**`bat: command not found`**：Zinit 没下载成功。检查 `zinit list | grep bat`，或重启 Zsh 触发安装。

**预览区没有颜色**：漏了 `--color=always`。

**预览很慢**：大文件没加 `--line-range`。

**中文显示成方块**：终端字体缺少 CJK 字形。装 Noto Serif CJK（`install_font.sh --noto`）。

**和系统的 batcat 冲突**：本仓库用 Zinit 版本，可执行名是 `bat`；系统包是 `batcat`。两者可以共存，`command -v bat` 应指向 zinit 目录。
