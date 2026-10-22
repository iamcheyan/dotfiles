> 摘要：delta 是 diff 阅读器，能给 Git 的 diff 加语法高亮、并排视图和更好的排版。

# delta

## 用途

`delta` 读取 unified diff 文本，输出带语法高亮、行号、文件头的可读版本。它通常作为 Git 的 pager 使用，替代 `less`。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 特殊处理 | Release 包内二进制在 `delta-<version>/` 子目录 |

```zsh
zinit ice as"command" from"gh-r" pick"delta-*/delta"
zinit light dandavison/delta
```

`pick"delta-*/delta"` 匹配子目录里的二进制，因为 delta 的 release 包结构和其它工具不同。

## 基本用法

```bash
delta file1 file2             # 比较两个文件（等价 diff -u | delta）
git diff | delta              # 管道输入
delta --help                  # 完整参数
```

## 作为 Git pager

```bash
git config --global core.pager "delta"
```

或者只对 diff 生效：

```bash
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictStyle "diff3"
git config --global diff.colorMoved "default"
```

本仓库**没有**自动设置这些，因为它会改变全局 Git 行为。需要时手动配置。

## 常用参数

| 参数 | 作用 |
|---|---|
| `--side-by-side` | 并排显示旧/新 |
| `--line-numbers` | 显示行号 |
| `--navigate` | 用 `n`/`N` 在变更块之间跳转（需 pager 配合） |
| `--dark` / `--light` | 适配背景色 |
| `--syntax-theme` | 指定语法高亮主题 |
| `--width` | 输出宽度 |
| `--file-style` | 文件头的样式 |
| `--hunk-header-style` | hunk 头样式 |
| `--color-only` | 只输出颜色，不改结构 |
| `--paging=never` | 不分页 |
| `--blame-format` | 自定义 blame 输出格式 |

## 并排视图

```bash
git diff | delta --side-by-side
```

左侧旧代码、右侧新代码，中间有分隔线。宽度不够时会自动退化回单栏。

## 与 bat 的分工

| | bat | delta |
|---|---|---|
| 输入 | 普通文件 | diff 文本 |
| 输出 | 高亮文件内容 | 高亮 diff 的增删行 |
| 典型用途 | `bat file`、fzf 预览 | `git diff` pager |

两者可以共存，也可以在 lazygit 里把 pager 设为 delta：

```yaml
git:
  paging:
    pager: delta --dark --paging=never
```

## 排错

**颜色丢失**：pager 输出到管道时，Git 默认关掉颜色。需要 `colorArg: always` 或 `--color-only`。

**并排视图错位**：终端宽度不足。调 `--width` 或加宽窗口。

**`n` 跳转无效**：`--navigate` 需要 delta 作为 pager 且终端支持。检查 Git 的 pager 配置。

**中文对齐错乱**：并排视图按字符宽度计算，CJK 字符宽度为 2。某些版本的 delta 处理不完美，可关掉并排。

**`delta: command not found`**：Zinit 的 `pick` 路径没匹配上。检查 `~/.zinit/plugins/dandavison---delta/` 下的目录结构。
