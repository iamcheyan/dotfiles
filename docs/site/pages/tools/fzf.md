> 摘要：fzf 是本仓库交互层的底座，f、ffd、forgit、fzf-tab、tmux-fzf 都建立在它之上。

# fzf

## 用途

`fzf` 是通用的模糊筛选器：从标准输入读一组行，让你用键盘快速缩小范围，输出选中的行。它本身不知道「文件」「分支」「命令」是什么——所有语义都由调用方赋予。

本仓库里五个地方用到它：

| 使用方 | 用途 |
|---|---|
| `f` / `ffd` | 文件与目录选择 |
| forgit | Git 分支、提交、stash 选择 |
| fzf-tab | Tab 补全候选筛选 |
| tmux-fzf | session/window/pane 选择 |
| vssh | SSH 主机选择 |

## 来源与安装

| 项目 | 说明 |
|---|---|
| 二进制 | init.sh 检查/安装；也可由系统包提供 |
| 补全与按键 | `plugins/tools/tools.zsh` 里用 Zinit snippet 加载上游脚本 |
| 版本要求 | forgit 需要 0.60.0+ |

```zsh
# 补全
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh
# 按键绑定
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`fzf.zsh` 里还有一层兜底：如果系统 `/usr/share/fzf/shell/key-bindings.zsh` 存在，也会 source 它。

## 基本用法

```bash
ls | fzf                    # 从管道选择
fzf < file.txt              # 从文件读
vim "$(fzf)"                # 选中后传给另一个命令
fzf --multi                 # 允许多选（Tab 标记）
fzf --preview 'cat {}'      # 右侧预览
```

`{}` 是当前选中项的占位符，在 `--preview`、`--bind` 里可用。

## 核心参数

### 搜索

| 参数 | 作用 |
|---|---|
| `-e` / `--exact` | 精确匹配而非模糊 |
| `-i` / `--ignore-case` | 忽略大小写 |
| `+i` | 区分大小写 |
| `--smart-case` | 全小写忽略、含大写区分（默认） |
| `-n` / `--nth` | 只在指定字段内搜索 |
| `--with-nth` | 只显示指定字段 |
| `--accept-nth` | 接受时只输出指定字段 |
| `-d` / `--delimiter` | 字段分隔符 |
| `+s` / `--no-sort` | 不按匹配度排序，保持输入顺序 |

### 布局

| 参数 | 作用 |
|---|---|
| `--height` | 占用多少高度，如 `90%` 或 `40` |
| `--layout=reverse` | 提示行在顶部，列表向下（更符合直觉） |
| `--border` | 画边框 |
| `--preview` | 预览命令 |
| `--preview-window` | 预览位置与大小，如 `right:40%` |
| `--header` | 顶部说明文字 |
| `--info` | 信息行样式 |

### 输入输出

| 参数 | 作用 |
|---|---|
| `--read0` | 输入用 NUL 分隔 |
| `--print0` | 输出用 NUL 分隔 |
| `--ansi` | 解析输入里的 ANSI 颜色 |
| `--print-query` | 输出里带上用户输入的查询 |
| `--expect=alt-enter` | 捕获特定按键，输出到第二行 |
| `--multi` | 多选 |

`--print-query` 和 `--expect` 的组合是本仓库 `f` 函数的核心，见 [f 与 ffd 函数](../shell/fzf-functions.html)。

## 本仓库的默认选项

```zsh
export FZF_DEFAULT_COMMAND='fd --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

拆开看：

- `--height 90%` — 占九成终端高度，保留一点上下文。
- `--layout=reverse` — 输入框在上，结果向下展开。
- `--border` — 画边框，视觉上区分于底层终端。
- `--wrap` — 长行折行，不横向滚动。
- `--preview` — 目录列内容，文件用 bat 高亮前 300 行。
- `--preview-window=right:40%` — 预览在右，占 40% 宽度。

没有 bat 时 `fzf.zsh` 会换成一个只有目录预览的版本。

## 官方按键绑定

| 键 | 作用 |
|---|---|
| `Ctrl+T` | 在当前命令行插入选中文件路径 |
| `Alt+C` | 选择目录并 `cd` |
| `Ctrl+R` | 搜索命令历史 |

`Ctrl+R` 可能被 Atuin 抢走，取决于加载顺序。

## 交互快捷键

在 fzf 界面内：

| 键 | 作用 |
|---|---|
| `Tab` / `Shift+Tab` | 多选标记 / 反向 |
| `Ctrl+J` / `Ctrl+K` | 下移 / 上移 |
| `Ctrl+N` / `Ctrl+P` | 同上 |
| `Enter` | 确认 |
| `Esc` / `Ctrl+C` | 取消 |
| `?` | 显示帮助 |
| `Ctrl+/` | 切换预览窗口 |
| `Alt+数字` | 多选时用数字键快速选中 |

## 在脚本里用

```bash
# 选中后删除
rm "$(ls | fzf)"

# 多选后批量处理
ls *.log | fzf --multi | xargs rm

# 带预览
git branch | fzf --preview 'git log --oneline -10 {}'

# 只输出第二列
printf 'a\t1\nb\t2\n' | fzf --delimiter='\t' --accept-nth=2
```

## 排错

**fzf 列表为空**：`FZF_DEFAULT_COMMAND` 指向的命令不存在。检查 `command -v fd`。

**预览空白**：预览命令里的工具缺失（bat、ls）。`command -v bat` 确认。

**预览有乱码**：终端不支持该字符，或字体缺字形。

**`Ctrl+T` 没反应**：key-bindings 没加载。检查 `plugins/tools/tools.zsh` 里那两个 snippet 是否成功。

**`Ctrl+R` 行为和预期不同**：Atuin 或 fzf 接管了。用 `bindkey '^R'` 确认当前绑定。

**forgit 报版本太低**：`fzf --version` 检查，需要 0.60.0+。系统包太旧时用官方安装脚本升级。
