> 摘要：fzf-tab 用 fzf 替换 Zsh 的补全菜单，支持模糊搜索、分组切换和目录预览。

# fzf-tab

## 用途

Zsh 原生补全是一个方向键选择的菜单。fzf-tab 把它换成 fzf 界面：可模糊搜索、可预览、可用 `<` `>` 切换候选组。

它不产生补全候选——候选来自 `zsh-completions` 和 Zsh 内建补全。它只接管**显示和选择**。

## 加载方式

```zsh
zsh_plugins_load_post_compinit() {
  zinit light Aloxaf/fzf-tab

  zstyle ':completion:*:git-checkout:*' sort false
  zstyle ':completion:*:descriptions' format '[%d]'
  zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
  zstyle ':completion:*' menu no

  if command -v eza >/dev/null 2>&1; then
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
  else
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always $realpath'
    zstyle ':fzf-tab:complete:z:*'  fzf-preview 'ls -1 --color=always $realpath'
  fi

  zstyle ':fzf-tab:*' switch-group '<' '>'
}
```

## 本仓库的 zstyle 逐条解释

### `menu no`

```zsh
zstyle ':completion:*' menu no
```

关闭 Zsh 原生补全菜单。不关的话，fzf-tab 和原生菜单会同时出现，视觉上互相干扰。

### `format '[%d]'`

```zsh
zstyle ':completion:*:descriptions' format '[%d]'
```

补全候选会按类型分组（命令、别名、函数、文件、目录）。`%d` 是分组描述，加方括号后显示成 `[command]`、`[alias]` 这样。

### `list-colors`

```zsh
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
```

用 `LS_COLORS` 给候选上色。`(s.:.)` 是 zsh 的切分语法，把 `LS_COLORS` 按冒号切成数组。

没有 `LS_COLORS` 时这条不生效，候选是纯色。

### `git-checkout sort false`

```zsh
zstyle ':completion:*:git-checkout:*' sort false
```

Git 分支补全不按字母排序，保持 `git branch` 的输出顺序（通常是最近提交优先）。找常用分支更快。

### 预览

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

补全 `cd` 和 `z` 的参数时，右侧显示目标目录的内容。

`$realpath` 是 fzf-tab 提供的变量，指向当前候选的完整路径。`--color=always` 必须加，因为输出到管道时默认关色。

没有 eza 时退回 `ls -1`。

### 分组切换

```zsh
zstyle ':fzf-tab:*' switch-group '<' '>'
```

用 `<` 和 `>` 在候选组之间切换。默认是 `Tab`/`Shift+Tab`，但 `Tab` 在 fzf 里已经被多选占用。

## 界面内按键

| 键 | 作用 |
|---|---|
| `Tab` | 选中并继续补全下一段 |
| `Shift+Tab` | 反向 |
| `<` / `>` | 切换候选组 |
| `Ctrl+/` | 打开 fzf 的额外操作菜单 |
| `Enter` | 确认 |
| `Esc` | 取消 |

## 效果示例

```text
$ docker <Tab>
┌─ [docker] ────────────────────────┐
│ container                         │
│ image                             │
│ network                           │
│ compose                           │
└───────────────────────────────────┘
```

输入 `cont` 会模糊过滤到 `container`。

## 与 fzf 全局选项的关系

fzf-tab 使用 fzf，但**不读** `FZF_DEFAULT_OPTS`。它的外观由 `zstyle ':fzf-tab:*'` 控制。

想改 fzf-tab 的高度/布局：

```zsh
zstyle ':fzf-tab:*' fzf-flags --height=60% --layout=reverse
```

## 与 fzf 补全脚本的区别

容易混淆的两件事：

| | fzf-tab | fzf 的 key-bindings |
|---|---|---|
| 触发 | `Tab` 补全 | `Ctrl+T` / `Ctrl+R` / `Alt+C` |
| 作用 | 筛选补全候选 | 选文件、选历史、切目录 |
| 来源 | Zinit 插件 | 上游 snippet |

两者都依赖 fzf 二进制，但功能不重叠。

## 排错

**Tab 还是原生菜单**：fzf-tab 没加载，或 `menu no` 没设。`zinit list | grep fzf-tab` 确认。

**候选是空的**：`compinit` 没运行，或者 `zsh-completions` 没在 compinit 前加载。

**预览区空白**：`eza` / `ls` 不可用，或 `$realpath` 为空。用 `cd` 到有内容的目录测试。

**候选没有颜色**：`LS_COLORS` 为空。检查 `dircolors` 是否执行。

**`<` `>` 不起作用**：被别的 zstyle 覆盖。`zstyle -L ':fzf-tab:*'` 查看当前设置。

**在大目录里补全很慢**：预览命令遍历了整个目录。可以给 `eza` 加 `--level=1` 限制深度，或去掉该条 `zstyle`。
