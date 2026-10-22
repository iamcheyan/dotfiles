> 摘要：f 与 ffd 两个文件搜索函数的完整行为、按键、回退逻辑和实现细节。

# f 与 ffd 函数

两个函数都在 `plugins/fzf/fzf.zsh`，共用一套 fzf 选项和剪贴板逻辑。

## f：当前目录选择器

```zsh
f              # 列当前目录
ls | f         # 消费管道输入
```

### 行为

1. 如果没有管道输入，用 `ls` 生成候选列表。
2. 弹出 fzf，右侧预览：目录用 `ls -F --color=always`，文件用 `bat --style=numbers --line-range :300`。
3. 根据选择执行动作：

| 选择 | 动作 |
|---|---|
| 文件 | `nvim <file>` |
| 目录 | `ra <dir>`（Ranger） |
| 按 `Alt+Enter` | 强制交给 Ranger，文件用 `ra --selectfile` |

### 按键

| 键 | 动作 |
|---|---|
| `Enter` | 打开（文件进 nvim，目录进 ranger） |
| `Alt+Enter` | 强制用 Ranger 打开 |
| `Alt+C` | 复制当前选中路径到剪贴板 |
| `Tab` / `Shift+Tab` | 下移 / 上移 |
| `Alt+J` / `Alt+K` | 同上（大小写两套） |
| `Alt+U` / `Alt+D` | 半页上 / 下 |
| `Alt+G` | 跳到顶部 |

fzf 顶部的 header 会实时显示这些提示。

### 实现细节

函数用 `--print-query` 和 `--expect=alt-enter`，fzf 的返回值是三段：

```text
第 1 行：query
第 2 行：按下的特殊键
第 3 行：选中的条目
```

代码里分别读 `sed -n '1p'`、`'2p'`、`'3p'`，再按「有没有特殊键」「是文件还是目录」分支处理。

复制路径用的 `_fzf_copy_path_cmd` 会把剪贴板命令序列化成字符串传给 fzf 的 `execute-silent`，因为 fzf 的 bind 动作在子 shell 里执行，不能直接调用父 shell 的函数。

## ffd：按文件名搜索

```zsh
ffd                       # 在 $HOME 下搜索
ffd bundle.mjs            # 在 $HOME 下搜索 bundle.mjs
ffd . main.py             # 在当前目录搜索
ffd /some/path '*.lua'    # 在指定目录搜索
ffd ~/work config         # 在 ~/work 搜索
```

### 参数解析

第一个参数可以是：

| 形式 | 含义 |
|---|---|
| 省略 | 起始目录 `$HOME`，无搜索模式 |
| `.` | 起始目录为当前目录 |
| `~` | 起始目录为 `$HOME` |
| `~/xxx` | 起始目录为 `~/xxx` |
| 已存在的目录路径 | 用该目录 |
| 其它 | 视为搜索模式 |

后续参数全部合并成一个模式字符串（`"$*"`）。

### 搜索后端

按优先级：

1. `fd`（如果可用且 `fd --version` 成功）
2. `fdfind`（Debian 的包名）
3. `plocate`（如果有索引数据库）
4. 最后回退到 `find`

### 选中后的动作

与 `f` 相同：文件进 Neovim，目录进 Ranger。

### noglob

```zsh
alias ffd='noglob ffd'
```

没有这行，`ffd '*.lua'` 会先被 Zsh 展开成当前目录的文件列表，函数收到的就不是模式了。`noglob` 让 Zsh 跳过通配符展开，把原始字符串交给 fd。

## 共用的 fzf 默认值

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

| 选项 | 作用 |
|---|---|
| `--hidden --follow` | 包含隐藏文件，跟随软链接 |
| `--exclude .git` | 不枚举 `.git` 目录 |
| `--height 90%` | 占用 90% 终端高度 |
| `--layout=reverse` | 提示行在顶部，符合直觉 |
| `--preview-window=right:40%` | 预览占右侧 40% |
| `--line-range :300` | bat 只渲染前 300 行，避免大文件卡顿 |

没有 bat 时 `FZF_DEFAULT_OPTS` 会退化成只有目录预览的版本。

## 排错

**`f` 没定义**：`plugins/fzf/fzf.zsh` 没被 source。检查 `zshrc` 里那行是否在。

**预览空白**：`bat` 或 `ls` 不可用。`command -v bat ls` 确认。

**`ffd` 报「not a directory」**：第一个参数被当成目录但不存在。检查是否多打了空格。

**`ffd '*.lua'` 结果不对**：`noglob` 别名没生效。用 `type ffd` 确认它是别名而不是函数。
