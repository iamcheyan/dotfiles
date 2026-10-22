> 摘要：Pay Respects 在命令失败后给出修正建议，本仓库用 f 别名触发。

# Pay Respects

## 用途

命令打错、参数不对、权限不足时，shell 只给你一行错误。Pay Respects 读取失败的命令，给出候选修正，让你确认后重试。

它的名字来自「pay respects」（致敬），因为你要先「失败」一次。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| shell 集成 | `plugins/zsh-plugins.zsh` |
| 触发 | `f` 别名 + 命令未找到处理 |

```zsh
zi_cmd iffse/pay-respects pay-respects
```

## shell 集成

```zsh
if command -v pay-respects >/dev/null 2>&1; then
  eval "$(pay-respects zsh --alias)"
fi
```

`--alias` 会做两件事：

1. 定义 `f` 别名，用于对最后一条失败命令求修正建议
2. 注册 `command_not_found_handler`，命令找不到时自动触发

## 基本用法

```bash
gti status          # 打错字
f                   # 求建议
```

输出类似：

```text
$ gti status
→ git status
```

确认后执行。

## 典型场景

| 失败类型 | 例子 |
|---|---|
| 拼写错误 | `gti` → `git` |
| 参数顺序 | `tar -xvf file.tar` vs `tar -xf file.tar -v` |
| 权限不足 | 提示加 `sudo` |
| 路径不存在 | 提示相近路径 |
| 命令不存在 | 提示相似命令名 |

## 规则系统

Pay Respects 用规则匹配失败模式。内置规则覆盖常见命令：

```bash
pay-respects --help              # 查看可用选项
pay-respects --list-rules        # 列出规则（部分版本）
```

自定义规则放在配置目录，格式参考上游文档。

## 安全注意

**确认后再执行。** Pay Respects 的建议由规则生成，不是万能的。涉及以下操作时尤其要检查：

- `sudo` 提权
- `rm`、`mv` 等破坏性操作
- 覆盖文件的命令
- 远程操作（`git push --force`、`ssh`）

它给的是「可能的修正」，不是「正确的答案」。

## 与 shell 内建的关系

`command_not_found_handler` 是 Zsh 的钩子：命令找不到时调用。Pay Respects 接管它，所以：

- 输入不存在的命令时，可能直接弹出建议
- 不想用这个行为时，可以在 `local/` 里覆盖 `command_not_found_handler`

## 与其它工具的分工

| 工具 | 时机 |
|---|---|
| Pay Respects | 命令失败后 |
| tldr | 不知道命令怎么用时 |
| navi / Pet | 记不住自己的常用命令时 |
| `--help` | 查参数 |

## 排错

**`f` 命令不存在**：集成没加载。`type f` 确认，检查 `zsh_plugins_load_shell_tools` 是否被调用。

**`f` 没有输出**：没有「最后一条失败命令」可参考。先执行一条会失败的命令。

**建议不对**：规则没覆盖该命令。这是正常限制，不要盲从建议。

**和已有别名冲突**：`f` 在某些配置里是别的意思。可以在 `local/` 里改绑定。

**中文错误信息识别不了**：Pay Respects 主要按英文错误模式匹配，本地化环境下效果可能下降。
