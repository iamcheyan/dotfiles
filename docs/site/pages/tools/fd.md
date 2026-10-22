> 摘要：fd 按文件名查找，是 fzf 和 ffd 的默认枚举器，也是 f 的兜底方案。

# fd

## 用途

`fd` 是 `find` 的现代替代：语法更短、默认并行、默认忽略 `.gitignore` 和隐藏文件、输出彩色。本仓库用它做两件事：fzf 的默认文件枚举，以及 `ffd` 的搜索后端。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 特殊处理 | Release 包里的二进制在子目录中，需要 `mv` 和 `sbin` |

```zsh
zinit ice as"command" from"gh-r" mv"fd-*/fd -> fd" pick"fd" sbin"fd"
zinit light sharkdp/fd
```

`mv"fd-*/fd -> fd"` 把压缩包内 `fd-v10.2.0-x86_64-unknown-linux-gnu/fd` 这类路径扁平化成 `fd`。`sbin"fd"` 把二进制放进 Zinit 的 bin 目录，让它进入 PATH。

Debian 系统包里的可执行名是 `fdfind`（因为 `fd` 名字冲突），本仓库的 `fzf.zsh` 有兼容处理：如果找不到 `fd` 但找得到 `fdfind`，会建一个 `~/.local/bin/fd` 软链接。

## 基本用法

```bash
fd                          # 列出当前目录所有文件（递归）
fd pattern                  # 按文件名匹配
fd pattern /some/path       # 在指定目录搜索
fd -e py                    # 按扩展名
fd -t f                     # 只要文件
fd -t d                     # 只要目录
fd -x rm                    # 对每个结果执行命令
fd -X rm                    # 所有结果一次性传给命令
```

`pattern` 默认是**正则表达式**（不是 glob）。想用 glob 加 `--glob`。

## 常用参数

| 参数 | 作用 |
|---|---|
| `-H` / `--hidden` | 包含隐藏文件 |
| `-I` / `--no-ignore` | 忽略 `.gitignore` 等规则 |
| `--no-ignore-vcs` | 只忽略 VCS 规则 |
| `-e` / `--extension` | 按扩展名筛选，可重复 |
| `-t` / `--type` | `f` 文件、`d` 目录、`l` 软链接、`x` 可执行 |
| `-d` / `--max-depth` | 最大递归深度 |
| `-x` / `--exec` | 对每个结果执行命令（并行） |
| `-X` / `--exec-batch` | 所有结果一次传给命令 |
| `-g` / `--glob` | 用 glob 而不是正则 |
| `-F` / `--fixed-strings` | 按字面字符串匹配 |
| `-0` / `--print0` | NUL 分隔，配合 `xargs -0` |
| `-c` / `--color` | `auto`/`always`/`never` |
| `--follow` | 跟随软链接 |
| `--exclude` | 排除匹配项 |

## 实用例子

```bash
fd -e lua                          # 所有 .lua 文件
fd -e lua -e md                    # .lua 或 .md
fd -t d -d 1                       # 只看当前目录的直接子目录
fd -H -I '\.env'                   # 含隐藏文件和被忽略文件
fd -x wc -l                        # 统计每个文件行数
fd -e png -X rm                    # 删除所有 png
fd --changed-within 1d             # 最近一天修改过
fd --size +10M                     # 大于 10MB
```

## 本仓库里的用法

### fzf 默认命令

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
```

| 选项 | 原因 |
|---|---|
| `--hidden` | 想搜到 `.env`、`.github` 这类文件 |
| `--follow` | 跟随软链接，仓库里有 `chezmoi` 这样的软链接 |
| `--exclude .git` | 不枚举 Git 内部对象，数量巨大且无用 |

### f 的兜底

`f` 函数本身用 `ls` 枚举，但 `FZF_DEFAULT_COMMAND` 会影响 fzf 的 `Ctrl+T` 行为。

### ffd 的后端

```zsh
if command -v fd >/dev/null 2>&1 && fd --version >/dev/null 2>&1; then
    fd_cmd="fd"
    [[ -n "$pattern" ]] && search_cmd=(fd "$pattern" "$base") || search_cmd=(fd . "$base")
elif command -v fdfind >/dev/null 2>&1; then
    ...
fi
```

注意 `fd --version` 这个额外检查：不仅要求命令存在，还要求它能正常执行。这能捕获「软链接指向了不存在的目标」这类损坏状态。

## 和 find 的对照

| 需求 | find | fd |
|---|---|---|
| 按名查找 | `find . -name '*.lua'` | `fd -e lua` |
| 忽略 gitignore | 手动 `-not -path` | 默认忽略 |
| 含隐藏文件 | 默认包含 | `-H` |
| 执行命令 | `-exec cmd {} \;` | `-x cmd` |
| 并行 | 无 | 默认并行 |

## 排错

**`fd: command not found`**：Zinit 未下载。`zinit list | grep fd` 确认，重启 Zsh。

**找不到被忽略的文件**：默认遵守 `.gitignore`。加 `-I`。

**找不到隐藏文件**：加 `-H`。

**`fdfind` 和 `fd` 都在**：`command -v fd` 应指向 Zinit 目录。如果指向 `~/.local/bin/fd` 且是坏软链接，删掉它让 Zinit 版本生效。
