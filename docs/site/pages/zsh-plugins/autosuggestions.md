> 摘要：zsh-autosuggestions 在光标后显示灰色建议文本，来自历史与补全结果。

# zsh-autosuggestions

## 用途

输入命令时，它把「你可能想输入的完整命令」以灰色显示在光标后面。按接受键直接采纳，或继续输入覆盖。

它和 fzf 历史搜索不同：fzf 是**主动打开**搜索界面，autosuggestions 是**持续被动**提示。

## 加载方式

```zsh
zinit light zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

必须在 zsh-vi-mode **之后**加载。

## 四个配置项

### STRATEGY

```zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
```

按顺序尝试两种来源：

| 值 | 来源 |
|---|---|
| `history` | 命令历史里找前缀匹配 |
| `completion` | Zsh 补全系统里找 |
| `match_prev_cmd` | 匹配「上一条命令之后的命令」 |

本仓库先历史、后补全。历史更贴近个人习惯，补全覆盖没执行过的命令。

想更聪明可以加第三个：

```zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
```

`match_prev_cmd` 会参考上一条命令，比如刚 `cd` 过，就优先建议 `ls`。

### HIGHLIGHT_STYLE

```zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
```

`fg=8` 是终端 256 色板的第 8 号色（通常是亮灰）。建议文字用灰色，视觉上不抢注意力。

想更淡可以试 `fg=240`，想更明显用 `fg=245`。

### BUFFER_MAX_SIZE

```zsh
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
```

命令行超过 100 字符时不再生成建议。

原因：长命令的建议计算成本高，且实际场景里很少需要。粘贴大段文本时这个限制能避免明显延迟。

### USE_ASYNC

```zsh
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

异步计算建议，不阻塞输入。代价是建议出现有极短延迟。

## 接受建议的键

默认是 `→`（右方向键）。部分配置里还有：

| 键 | 行为 |
|---|---|
| `→` | 接受整条建议 |
| `Ctrl+→` | 接受一个词 |
| `End` | 接受整条（部分终端） |

想改成 `Ctrl+Space`：

```zsh
bindkey '^ ' autosuggest-accept
```

放在 `local/` 里覆盖。

## 与 vi-mode 的配合

普通模式下：

| 键 | 行为 |
|---|---|
| `→` | 接受建议（切到插入模式） |
| `w` | 按词移动，不触发建议 |
| `$` | 跳到行尾 |

建议只在插入模式显示。普通模式下看不到灰色文字，这是预期行为。

## 与 fzf 历史搜索的区别

| | autosuggestions | fzf `Ctrl+R` |
|---|---|---|
| 触发 | 自动，持续 | 手动按键 |
| 界面 | 光标后灰色文字 | 全屏/半屏选择器 |
| 匹配 | 前缀 | 模糊 |
| 适合 | 重复执行相似命令 | 找很久以前的命令 |

两者可以共存，互补。

## 建议不准时

**建议的是旧命令**：`history` 策略按前缀匹配，取最近一条。想让它更智能，加 `match_prev_cmd`。

**建议了不该建议的**：历史里有过敏感命令。启用 Atuin 的 `history_filter`，或清理历史。

**建议频繁闪烁**：异步计算的结果返回顺序不稳定。可以关掉 `USE_ASYNC`（代价是输入可能卡顿）。

## 排错

**看不到灰色建议**：插件没加载，或 `HIGHLIGHT_STYLE` 的颜色和背景太接近。改成 `fg=240` 试试。

**按 `→` 没反应**：键位被 vi-mode 或其它插件占用。`bindkey '^[[C'` 查看当前绑定。

**建议出现但很慢**：`USE_ASYNC` 没开，或历史文件太大。检查 `HISTSIZE`。

**粘贴时卡顿**：`BUFFER_MAX_SIZE` 设得太高。降到 100 以下。

**和 fzf-tab 冲突**：两者都用 Tab 相关键，但职责不同。如果 Tab 行为异常，先确认 `menu no` 是否生效。
