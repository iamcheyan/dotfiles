> 摘要：compinit、zsh-completions、fzf-tab 的三阶段加载，以及 PATH 整理和缓存。

# 补全系统

## 三个阶段的由来

Zsh 的补全系统要求 `compinit` 在正确时机运行：它扫描 `$fpath` 收集补全定义，生成 `~/.zcompdump`。之后加载的补全文件需要重新 `rehash` 才生效。所以：

1. **`zsh_plugins_load_pre_compinit`** — 加载 `zsh-users/zsh-completions`，把额外补全定义放进 `$fpath`。
2. **`plugins/completion/completion.zsh`** — 运行 `compinit`，设置缓存和匹配规则。
3. **`zsh_plugins_load_post_compinit`** — 加载 `Aloxaf/fzf-tab`，它会替换补全菜单的显示方式。

顺序颠倒会出现「补全候选里没有 docker 子命令」或「fzf-tab 不生效」这类问题。

## completion.zsh 做了什么

```zsh
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
```

| 设置 | 作用 |
|---|---|
| `use-cache on` | 把补全结果缓存到磁盘，加快重复补全 |
| `matcher-list` 第一条 | 大小写不敏感匹配 |
| 第二条 | `foo-bar` 可以只输入 `fb` 匹配 |
| 第三条 | 任意位置模糊匹配 |

缓存目录放在 `~/.cache/zsh/zcompcache`，符合 XDG 规范，不会污染 home 目录。

这个文件还做 PATH 整理：把 zinit 安装的工具目录加进 PATH，并去重、清理不存在的路径。这部分逻辑在 `clean_path` 和 `add_to_path_if_new` 两个函数里。

## fzf-tab

```zsh
zinit light Aloxaf/fzf-tab

zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' menu no
zstyle ':completion:*' git-checkout:*' sort false
```

| 配置 | 效果 |
|---|---|
| `format '[%d]'` | 候选分组标题带方括号 |
| `list-colors` | 用 `LS_COLORS` 给候选上色 |
| `menu no` | 关闭 Zsh 原生菜单，交给 fzf |
| `git-checkout sort false` | 分支按仓库顺序而非字母序 |

预览配置：

```zsh
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
zstyle ':fzf-tab:complete:z:*'  fzf-preview 'eza -1 --color=always $realpath'
```

`cd` 和 `z` 的补全会在右侧预览目录内容。没有 eza 时回退到 `ls -1`。

## fzf-tab 内的按键

| 键 | 动作 |
|---|---|
| `Tab` | 选中并继续补全 |
| `Shift+Tab` | 反向 |
| `<` / `>` | 切换候选组（本仓库显式绑定） |
| `Ctrl+/` | 触发 fzf 的额外操作菜单 |

## 常见问题

**补全候选为空**：`compinit` 没运行。检查 `plugins/completion/completion.zsh` 是否被 source。

**新装的命令没有补全**：补全定义在 `$fpath` 里但 `zcompdump` 是旧的。删缓存重建：

```zsh
rm -f ~/.zcompdump*
exec zsh
```

**fzf-tab 生效但样式乱**：`LS_COLORS` 没设置。检查 `dircolors` 或主题是否导出了它。

**`cd` 补全很慢**：预览命令在大目录下会遍历很多文件。可以把该条 `zstyle` 注释掉，或改用 `--max-depth`。
