> 摘要：zsh-autosuggestions、autopair、you-should-use、forgit、syntax-highlighting 的加载与用法。

# 交互插件

所有插件集中声明在 `plugins/zsh-plugins.zsh` 的 `zsh_plugins_load_main` 里，加载顺序有意固定。

## zsh-autosuggestions

```zsh
zinit light zsh-users/zsh-autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

| 设置 | 效果 |
|---|---|
| `STRATEGY=(history completion)` | 先查历史，再查补全 |
| `HIGHLIGHT_STYLE='fg=8'` | 建议文字用灰色，不干扰视线 |
| `BUFFER_MAX_SIZE=100` | 超过 100 字符不再建议 |
| `USE_ASYNC=1` | 异步计算，避免卡顿 |

接受建议按 `→`（默认绑定），部分终端配置里是 `End`。

**为什么限制长度**：长命令的建议计算成本高，而且实际场景里很少需要。粘贴大段文本时这个限制能避免明显延迟。

## zsh-autopair

```zsh
zinit light hlissner/zsh-autopair
```

输入 `(` 自动补 `)`，输入 `"` 自动补 `"`，在已有配对前按退格会一起删除。它只作用于命令行，不影响普通文本编辑。

## zsh-you-should-use

```zsh
zinit light MichaelAquilina/zsh-you-should-use
```

当你输入的命令已有别名时，它会在执行后提示「你本可以用 `ll`」。默认只在命令结束后提示，不打断输入。

关掉提示：在 `local/` 里设 `export YSU_MESSAGE_POSITION="after"` 或按上游文档改 `YSU_MODE`。

## forgit

```zsh
zinit light wfxr/forgit
```

forgit 把 Git 的常见操作接到 fzf 选择器上。它要求 fzf 0.60.0 或更新。

| 命令 | 作用 |
|---|---|
| `ga` | 选择文件加入暂存区 |
| `gd` | 浏览文件 diff |
| `glo` | 浏览提交历史 |
| `gcb` | 切换分支 |
| `gsw` | 选择并切换分支 |
| `gss` | 浏览 stash |
| `gsp` | 选择文件创建 stash |
| `gcp` | 选择提交 cherry-pick |
| `grb` | 交互式 rebase |
| `gwt` | 浏览 worktree |
| `gi` | 生成 `.gitignore` 条目 |
| `gbd` | 删除分支 |
| `gclean` | 清理未跟踪文件 |
| `grh` | 从暂存区移除 |
| `grs` | 恢复文件 |

**这些命令直接执行 Git 操作**。`gbd`、`gclean`、`grh`、`grs`、rebase、cherry-pick 都会改变仓库状态，确认选择后再回车。

自定义 fzf 行为：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
```

与已有别名冲突时，可以设置 `FORGIT_NO_ALIASES=1` 禁用短别名，只用 `forgit::` 前缀的函数。

## zsh-syntax-highlighting

```zsh
zinit light zsh-users/zsh-syntax-highlighting
```

必须**最后**加载。它通过 `zle` hook 给命令行着色：存在的命令绿色、不存在的红色、字符串、变量、路径各有颜色。

如果它加载后颜色失效，通常是有插件在它之后又设置了 hook。检查 `zsh-plugins.zsh` 里它是否确实在最后一行。

## 可选工具的 shell 集成

`zsh_plugins_load_shell_tools` 处理三个「装了才启用」的工具：

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
if command -v pay-respects >/dev/null 2>&1; then
  eval "$(pay-respects zsh --alias)"
fi
if command -v pet >/dev/null 2>&1; then
  function pet-select() {
    BUFFER="$(pet search --query "$LBUFFER")"
    CURSOR=$#BUFFER
    zle redisplay
  }
  zle -N pet-select
  bindkey '^X^R' pet-select
fi
```

| 工具 | 集成效果 |
|---|---|
| navi | 注册 widget，可在命令行呼出 cheatsheet |
| pay-respects | 启用 `f` 别名和命令未找到处理 |
| Pet | `Ctrl+X` 再 `Ctrl+R` 把片段填进命令行 |

三者都缺失时，这段代码什么也不做，shell 照常启动。

## 加一个新插件

1. 在 `zsh_plugins_load_main`（或对应阶段）里加 `zinit light owner/repo`。
2. 把该插件的环境变量、`zstyle`、hook 紧挨着写在下面。
3. 检查顺序约束：补全类在 compinit 前后，语法高亮最后。
4. 验证：

```bash
zsh -d -n ./plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ./zshrc >/dev/null 2>&1; true'
```
