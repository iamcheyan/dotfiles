> 摘要：通过 Zinit snippet 加载 fzf 官方的补全脚本与键绑定脚本，提供 Ctrl+T、Alt+C、Ctrl+R。

# fzf 补全与键绑定

## 用途

fzf 二进制本身只是一个筛选器，它不注册任何 shell 快捷键。`Ctrl+T`、`Alt+C`、`Ctrl+R` 来自两个官方脚本：

| 脚本 | 提供 |
|---|---|
| `completion.zsh` | `fzf` 命令本身的补全 |
| `key-bindings.zsh` | `Ctrl+T`、`Alt+C`、`Ctrl+R` |

## 加载方式

```zsh
# fzf（使用系统安装的 fzf，这里只加载补全和键绑定）
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh

zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`as"completion"` 告诉 Zinit：这是补全脚本，加载时不要当普通插件处理。

注意 fzf 二进制的安装被注释掉了：

```zsh
# zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
# zinit light junegunn/fzf
```

本仓库用系统包或 `init.sh` 安装的 fzf，Zinit 只负责加载这两个脚本。

## 三个快捷键

### Ctrl+T

把选中的文件路径插入当前命令行。

```text
$ vim <Ctrl+T>
→ 弹出 fzf 文件列表
→ 选中 file.txt
$ vim file.txt
```

支持多选，多个路径以空格分隔插入。

### Alt+C

选择目录并 `cd` 过去。

```text
$ <Alt+C>
→ 弹出目录选择器
→ 选中 ~/projects/foo
$ pwd
/home/user/projects/foo
```

只列目录，不列文件。

### Ctrl+R

搜索命令历史，选中后插入命令行。

```text
$ <Ctrl+R>
→ 弹出历史搜索
→ 输入 git
→ 选中 git status
$ git status
```

**注意**：本仓库的 `Ctrl+R` 可能被 Atuin 接管。用 `bindkey '^R'` 确认当前绑定。

## 兜底加载

`plugins/fzf/fzf.zsh` 里还有一层：

```zsh
if [[ -e /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
elif [[ -e /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -e /usr/share/fzf/shell/completion.zsh ]]; then
    source /usr/share/fzf/shell/completion.zsh
elif [[ -e /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi
```

系统包安装的 fzf 通常自带这些脚本。两层都加载不会冲突——后加载的覆盖同名 widget。

## 与 FZF_DEFAULT_OPTS 的关系

三个快捷键都会读 `FZF_DEFAULT_OPTS`：

```zsh
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

所以按 `Ctrl+T` 时也有右侧预览。

`FZF_CTRL_T_COMMAND` 控制 `Ctrl+T` 的候选来源：

```zsh
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
```

## 与 `f` / `ffd` 的区别

| | 快捷键 | `f` / `ffd` |
|---|---|---|
| 触发 | `Ctrl+T` 等 | 手动输入命令 |
| 行为 | 插入路径到命令行 | 直接打开文件/目录 |
| 定义位置 | 上游脚本 | `plugins/fzf/fzf.zsh` |
| 可定制性 | 低 | 高 |

快捷键适合「我已经在写命令，需要补一个路径」；`f` 适合「我要去某个文件」。

## 排错

**`Ctrl+T` 没反应**：key-bindings 没加载。检查 `zinit list` 里有没有 snippet 条目。

**`Ctrl+T` 插入路径但预览空白**：`bat` 不可用，或 `FZF_DEFAULT_OPTS` 里的预览命令失败。

**`Alt+C` 后目录没变**：某些终端把 `Alt+C` 解释成别的键。可以改用 `Alt+C` 的替代绑定：

```zsh
bindkey '^[c' fzf-cd-widget
```

**`Ctrl+R` 行为不是 fzf**：被 Atuin 接管了。`bindkey '^R'` 查看。

**snippet 下载失败**：Zinit 需要网络。首次启动时检查连接，或手动 `zinit update`。

**重复定义 widget 警告**：两个来源都加载了。通常无害，后加载的覆盖前面的。
