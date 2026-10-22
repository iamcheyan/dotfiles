> 摘要：procs 是 ps 的现代替代，支持关键字逻辑组合、可配置列和树状视图。

# procs

## 用途

`procs` 替代 `ps aux | grep xxx`：输出彩色、支持多关键字与布尔组合、可配置显示列、支持树状视图、可正则匹配。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |

```zsh
zi_cmd dalance/procs procs
```

## 基本用法

```bash
procs                    # 列出所有进程
procs nvim               # 关键字搜索
procs nvim lua           # 多个关键字
procs --tree             # 树状视图
```

## 关键字逻辑

| 参数 | 逻辑 |
|---|---|
| 默认 | AND（所有关键字都要匹配） |
| `-a` / `--and` | 显式 AND |
| `-o` / `--or` | 任一匹配 |
| `-d` / `--nand` | 不全匹配 |
| `-r` / `--nor` | 全不匹配 |

例子：

```bash
procs -o nvim vim          # 名字含 nvim 或 vim
procs -r chrome firefox    # 既不是 chrome 也不是 firefox
procs --tree nvim          # 只看 nvim 的进程树
```

## 匹配模式

| 参数 | 模式 |
|---|---|
| `--text` | 纯文本（默认） |
| `--regex` | 正则表达式（单模式） |
| `--smart` | 自动判断是否用正则语法 |

## 列配置

```bash
procs -l                   # 列出所有可用列类型
```

默认列可以在配置文件里定义。配置位置：`~/.config/procs/config.toml`。

```toml
[[columns]]
kind = "Pid"
style = "BrightYellow"

[[columns]]
kind = "User"
style = "BrightGreen"

[[columns]]
kind = "Cpu"
style = "BrightCyan"

[[columns]]
kind = "Command"
style = "BrightWhite"
```

这是 procs 相对 `ps` 的最大优势：显示哪些列、什么颜色、什么顺序，全部可配。

## 常用参数

| 参数 | 作用 |
|---|---|
| `--tree` | 树状显示父子关系 |
| `-w` / `--watch` | 持续刷新 |
| `-i` / `--insert` | 在默认列前插入列 |
| `-c` / `--color` | 颜色模式 |
| `-l` / `--list` | 列出可用列类型 |

## 实用例子

```bash
procs --tree                        # 进程树
procs --watch                       # 类似 top 的持续刷新
procs -w node                       # 只看 node 进程并刷新
procs --regex '^python'             # 正则匹配
procs -r chrome firefox -w          # 排除两个浏览器并刷新
```

## 与 ps 的对照

| 需求 | ps | procs |
|---|---|---|
| 全部进程 | `ps aux` | `procs` |
| 按名搜索 | `ps aux \| grep x` | `procs x` |
| 排除 | `ps aux \| grep -v x` | `procs -r x` |
| 树状 | `ps auxf` | `procs --tree` |
| 自定义列 | `ps -o ...` | 配置文件 |
| 持续刷新 | `watch ps` | `procs -w` |

## 排错

**`procs: command not found`**：Zinit 未下载。`zinit list | grep procs` 确认。

**颜色丢失**：输出到管道时默认关色。加 `--color always`。

**列太多导致折行**：修改配置文件只保留需要的列，或加宽终端。

**搜索不到进程**：默认 AND 逻辑要求所有关键字都匹配。改用 `-o`。

**`--watch` 下按键无响应**：某些终端下需要先 `Ctrl+C` 退出。这是 procs 的实现限制。
