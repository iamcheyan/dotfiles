> 摘要：ripgrep 按内容搜索，是 Neovim 的 grepprg，也是本仓库唯一的内容检索工具。

# ripgrep

## 用途

`ripgrep`（命令名 `rg`）在目录树里按**内容**搜索，速度远超 `grep -r`。它默认遵守 `.gitignore`、跳过二进制文件、并行搜索、自动检测编码。

本仓库在三个地方用到它：

1. 手动搜索内容。
2. Neovim 的 `grepprg`（`config/nvim` 里设为 `rg --vimgrep`）。
3. `packtar.sh` 里检测 `tar --help` 是否支持某个参数（用 `rg -q` 代替 grep）。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 特殊处理 | Release 包内二进制在子目录，需要扁平化 |

```zsh
zinit ice as"command" from"gh-r" mv"ripgrep-*/rg -> rg" pick"rg" sbin"rg"
zinit light BurntSushi/ripgrep
```

## 基本用法

```bash
rg pattern                  # 当前目录递归搜索
rg pattern path/            # 指定目录
rg -i pattern               # 忽略大小写
rg -w pattern               # 全词匹配
rg -F pattern               # 字面匹配，不当正则
rg -l pattern               # 只列文件名
rg -c pattern               # 只计数
rg --files                  # 列出会被搜索的文件（不搜内容）
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-i` / `--ignore-case` | 忽略大小写 |
| `-S` / `--smart-case` | 全小写时忽略大小写，含大写时区分 |
| `-w` / `--word-regexp` | 全词匹配 |
| `-F` / `--fixed-strings` | 按字面串匹配 |
| `-l` / `--files-with-matches` | 只输出文件名 |
| `-c` / `--count` | 每个文件的匹配数 |
| `-n` / `--line-number` | 显示行号（默认开启） |
| `-A/-B/-C N` | 匹配行后/前/前后 N 行 |
| `-t` / `--type` | 按文件类型过滤，如 `-t py` |
| `-g` / `--glob` | 按 glob 包含/排除 |
| `-U` / `--multiline` | 允许多行匹配 |
| `-P` / `--pcre2` | 用 PCRE2 正则（支持后行断言等） |
| `--hidden` | 搜索隐藏文件 |
| `--no-ignore` | 忽略 `.gitignore` |
| `--vimgrep` | 输出 `file:line:col:match` 格式 |
| `--json` | 结构化输出，配合 jq |

## 实用例子

```bash
rg -t lua 'vim\.keymap'              # 只在 lua 文件里搜
rg -g '*.md' -g '!CHANGELOG*' TODO   # 排除特定文件
rg -C 3 'function M\.'               # 带三行上下文
rg -l 'FIXME' | xargs wc -l          # 列出含 FIXME 的文件并统计行数
rg --files -g '*.cob'                # 只列 cobol 文件
rg -U 'BEGIN.*?END' -P               # 多行 + PCRE2
rg --json 'error' | jq '.data.path.text'  # 结构化处理
```

## 本仓库里的用法

### Neovim grepprg

Neovim 配置里：

```vim
if executable("rg")
  let &grepprg = "rg --vimgrep"
  set grepformat=%f:%l:%c:%m
endif
```

这让 `:grep` 用 rg，结果带列号，可以直接跳转。Neovim 里的 Telescope/Snacks picker 也优先用 rg 做 live grep。

### packtar 里的探测

```bash
if command -v rg >/dev/null 2>&1; then
    TAR_HELP_MATCHER=(rg -q --)
else
    TAR_HELP_MATCHER=(grep -q --)
fi
```

用 `rg -q` 检查 `tar --help` 输出里有没有某参数。有 rg 就用 rg，没有就退回 grep——这是本仓库「优先现代工具、保留 fallback」模式的典型写法。

## 与 grep 的差异

| 行为 | grep | ripgrep |
|---|---|---|
| 默认递归 | 否 | 是 |
| 遵守 .gitignore | 否 | 是 |
| 跳过二进制 | 需 `-I` | 默认 |
| 隐藏文件 | 默认搜 | 默认跳过 |
| 并行 | 否 | 是 |
| 正则引擎 | BRE/ERE | Rust regex（近似 PCRE） |

**最容易踩的差异**：`rg` 默认不搜隐藏文件和被 gitignore 的文件。想全搜要显式 `--hidden --no-ignore`。

## 排错

**搜不到 `.env` 或 `node_modules` 里的内容**：默认被忽略。用 `rg --hidden --no-ignore`。

**正则写法不兼容**：Rust regex 不支持后行断言（lookbehind）。需要时加 `-P` 用 PCRE2。

**`rg: command not found`**：Zinit 未下载。`zinit list | grep ripgrep` 确认。

**输出太多**：先 `-l` 只列文件，再针对单个文件搜索。
