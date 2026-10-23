> 摘要：you-should-use 在输入的命令已有别名时提醒你，可配置提醒位置与忽略规则。

# you-should-use

## 用途

你输入 `git status`，但配置里有 `gs` 这个别名。执行后它会提示：

```text
Found alias defined for git status.
  - gs
```

目的是帮你养成用短别名的习惯。它只提醒，不阻止执行。

## 加载方式

```zsh
zinit light MichaelAquilina/zsh-you-should-use
```

无参数，行为由环境变量控制。

## 三种提醒模式

```zsh
export YSU_MODE=ALL          # 默认：别名 + 全局别名 + Git 别名
export YSU_MODE=SUGGEST      # 只提醒别名
export YSU_MODE=HARD         # 硬提醒：显示提示后阻止执行
```

| 模式 | 行为 |
|---|---|
| `SUGGEST` | 执行后提示 |
| `ALL` | 执行后提示（含更多类型） |
| `HARD` | 提示并**阻止**执行，要求确认 |

`HARD` 模式比较激进，日常不建议。

## 提醒位置

```zsh
export YSU_MESSAGE_POSITION=BEFORE   # 执行前提示
export YSU_MESSAGE_POSITION=AFTER    # 执行后提示（默认）
```

`AFTER` 更友好：不打断命令执行，提示出现在结果之后。

## 提醒内容可定制

```zsh
export YSU_MESSAGE_FORMAT='Use %alias instead of %command.'
```

| 占位符 | 含义 |
|---|---|
| `%alias` | 建议使用的别名 |
| `%command` | 实际输入的命令 |

## 本仓库的行为

本仓库没有设置任何 `YSU_*` 变量，所以用默认值：

| 项 | 值 |
|---|---|
| 模式 | `ALL` |
| 位置 | `AFTER` |
| 提示格式 | 默认文本 |

## 它检测哪些别名

| 类型 | 例子 |
|---|---|
| 普通别名 | `alias gs='git status'` |
| 全局别名 | `alias -g G='\| grep'` |
| Git 别名 | `git config alias.co checkout` |
| 后缀别名 | `alias -s md=nvim` |

本仓库的 `aliases.conf` 里定义了 `l`、`ll`、`la`、`ra`、`gc` 等，都会被检测。

## 忽略某些命令

```zsh
export YSU_IGNORED_ALIASES=("gst" "gco")
```

列出的别名不会被提醒。

或者忽略某类：

```zsh
export YSU_IGNORED_GLOBAL_ALIASES=("g")
```

## 关闭提醒

```zsh
export YSU_MODE=OFF
```

或在 `local/custom.zsh` 里把 `YSU_MODE` 设为空。

## 什么时候有用

| 场景 | 收益 |
|---|---|
| 刚开始用别人的 dotfiles | 快速发现有哪些别名 |
| 记不住自己定义的别名 | 每次用长命令时被提醒 |
| 团队共享配置 | 统一习惯 |

## 什么时候会烦

| 场景 | 建议 |
|---|---|
| 偶尔用长命令更清楚 | 加进 `YSU_IGNORED_ALIASES` |
| 脚本里 | 非交互环境不触发，无影响 |
| `HARD` 模式下反复被拦 | 改回 `AFTER` |

## 排错

**完全没提醒**：插件没加载，或 `YSU_MODE=OFF`。

**提醒了但不该提醒**：该命令没有对应别名，可能匹配到了相似别名。加进忽略列表。

**提示出现两次**：可能有别的插件也做类似提醒。`set | grep YSU` 检查变量。

**脚本里也出现提示**：不应该。检查是否在 `zshrc` 里用了 `setopt` 相关设置导致非交互也加载。

**提示文字乱码**：终端字体或 locale 问题。`echo $LANG` 确认是 UTF-8。
