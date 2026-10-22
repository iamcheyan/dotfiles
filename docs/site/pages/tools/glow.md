> 摘要：glow 在终端里渲染 Markdown，支持目录浏览和分页。

# glow

## 用途

`glow` 读取 Markdown 文件，在终端里渲染成带标题、列表、代码块、链接的格式化输出。它还能把整个目录的 Markdown 当成文档库浏览。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 可执行名 | `glow` |

```zsh
zi_cmd charmbracelet/glow glow
```

## 基本用法

```bash
glow README.md                 # 渲染单个文件
glow .                         # 浏览当前目录的 Markdown（TUI）
glow /path/to/docs             # 浏览指定目录
cat file.md | glow             # 从标准输入
glow -                        # 同上
```

不带参数且不在 TTY 时，`glow` 会从标准输入读取。

## 常用参数

| 参数 | 作用 |
|---|---|
| `-p` / `--pager` | 用 pager 分页显示 |
| `-s` / `--style` | 样式名或 JSON 路径，默认 `auto` |
| `-w` / `--width` | 换行宽度，0 表示不换行 |
| `-l` / `--line-numbers` | 显示行号（TUI 模式） |
| `-a` / `--all` | 显示隐藏文件（TUI 模式） |
| `-n` / `--preserve-new-lines` | 保留原始换行 |
| `--config` | 指定配置文件 |

## 样式

```bash
glow -s dark README.md
glow -s light README.md
glow -s notty README.md        # 无颜色，适合管道
glow -s /path/to/custom.json README.md
```

`auto` 会根据终端背景自动选 dark 或 light。输出到管道时自动用 `notty`。

自定义样式：`glow config` 打开配置文件，或用 `-s` 指向 JSON。

## 目录浏览模式

```bash
glow .
```

进入一个 TUI：左侧文件列表，右侧渲染内容。适合浏览一个有多个 Markdown 的项目文档。

| 键 | 作用 |
|---|---|
| `↑` / `↓` 或 `j` / `k` | 移动 |
| `Enter` | 打开 |
| `Esc` / `q` | 返回/退出 |
| `/` | 搜索 |
| `?` | 帮助 |

## 实用场景

### 读项目文档

```bash
glow ~/dotfiles/docs
```

比逐个 `cat` 舒服得多。

### 管道渲染

```bash
curl -s https://raw.githubusercontent.com/.../README.md | glow -
```

### 在脚本里输出说明

```bash
glow -s notty <<'EOF'
# 部署完成

- 服务已重启
- 日志在 `/var/log/app.log`
EOF
```

`-s notty` 去掉颜色和边框，适合写进日志。

### 配合 fzf

```bash
fd -e md | fzf --preview 'glow -w 80 {}'
```

用 fzf 选 Markdown，右侧预览渲染结果。

## 与 bat 的分工

| | bat | glow |
|---|---|---|
| 输入 | 任意文本 | Markdown |
| 输出 | 语法高亮源码 | 渲染后的文档 |
| 用途 | 读代码 | 读文档 |

读 `.md` 想看渲染效果用 glow，想看源码用 bat。

## 排错

**`glow: command not found`**：Zinit 未下载。

**渲染乱码**：终端字体缺 CJK 或特殊符号。装 Noto Serif CJK。

**表格渲染错位**：glow 对宽表格支持有限。加 `-w` 调宽度，或改用浏览器。

**颜色丢失**：输出到管道时自动用 `notty`。想保留颜色加 `-s dark`。

**`glow .` 无反应**：需要交互式终端。在管道或脚本里不要用 TUI 模式。

**图片不显示**：glow 不渲染图片，只输出 Markdown 的图片链接文本。
