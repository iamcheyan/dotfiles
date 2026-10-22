> 摘要：zoxide 按访问频率记录目录，用 z 跳转、zi 交互选择、za/zr 维护数据库。

# zoxide

## 用途

`zoxide` 记录你访问过的目录及其频率，用短关键字跳转。输入 `z proj` 就能跳到最常访问的、路径里含 `proj` 的目录，不需要写完整路径。

本仓库用它替代 `cd` 的长路径输入，并把它和 fzf 结合成 `zi`。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |
| 数据文件 | 默认在系统数据目录（Linux: `~/.local/share/zoxide/db.zo`） |

```zsh
zi_cmd ajeetdsouza/zoxide zoxide
```

## 初始化与别名

```zsh
if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'      # 交互式选择
  alias za='z -a'      # 添加目录
  alias zr='z -r'      # 移除目录
fi
```

`_evalcache` 把 `zoxide init zsh` 的输出缓存，避免每次启动都执行。它注入的是 `z` 和 `zi` 两个 shell 函数，不是别名——因为需要在当前 shell 里真正 `cd`。

## 基本用法

```bash
z project           # 跳到最匹配 project 的目录
z proj doc          # 多个关键字，全部匹配
z ~/work            # 给绝对路径时直接 cd（退化为普通 cd）
z -                 # 回到上一个目录（类似 cd -）
zi                  # 交互式选择
```

匹配规则：关键字可以出现在路径的任意位置，按「访问频率 × 时间衰减」排序。刚访问过的目录权重更高。

## 子命令

| 命令 | 作用 |
|---|---|
| `zoxide add <path>` | 手动增加路径权重 |
| `zoxide remove <path>` | 从数据库移除 |
| `zoxide query <keyword>` | 查询匹配路径，不跳转 |
| `zoxide query -l` | 列出全部记录的路径 |
| `zoxide query -s` | 显示每个路径的分数 |
| `zoxide edit` | 打开数据库编辑器 |
| `zoxide import` | 从 autojump / z / fasd 导入 |
| `zoxide init <shell>` | 生成 shell 集成代码 |

## 本仓库的别名

| 别名 | 展开 | 用途 |
|---|---|---|
| `zi` | `z -i` | 交互式：用 fzf 从匹配项里选 |
| `za` | `z -a` | 添加当前目录到数据库 |
| `zr` | `z -r` | 移除指定目录 |

`zi` 是最常用的：当 `z` 的关键字匹配到多个目录时，`zi` 会弹出 fzf 让你选。它复用 `FZF_DEFAULT_OPTS`，所以也有预览窗口。

## 环境变量

| 变量 | 作用 |
|---|---|
| `_ZO_DATA_DIR` | 数据文件目录 |
| `_ZO_ECHO` | 设为 1 时跳转前打印目标路径 |
| `_ZO_EXCLUDE_DIRS` | 排除的目录 glob 列表 |
| `_ZO_FZF_OPTS` | 传给 `zi` 的 fzf 参数 |
| `_ZO_MAXAGE` | 条目总权重上限，超过后淘汰旧条目 |
| `_ZO_RESOLVE_SYMLINKS` | 存储时解析软链接 |

常用配置示例（放在 `local/`）：

```zsh
export _ZO_EXCLUDE_DIRS="$HOME:/tmp:/var/tmp"
export _ZO_FZF_OPTS="--height 60% --reverse --border"
```

## 与 fzf 的关系

`zoxide init zsh` 注入的 `zi` 函数内部调用 fzf。所以：

- 没有 fzf 时 `zi` 不可用，但 `z` 仍工作。
- `zi` 的预览由 zoxide 自己的默认值决定，可用 `_ZO_FZF_OPTS` 覆盖。
- 本仓库的 `alias zi='z -i'` 是把 `z` 的交互开关暴露出来，等价于内置的 `zi`。

## 与 fzf-tab 的联动

`plugins/zsh-plugins.zsh` 里配置了：

```zsh
zstyle ':fzf-tab:complete:z:*' fzf-preview 'eza -1 --color=always $realpath'
```

所以用 Tab 补全 `z` 的参数时，也会显示目标目录的内容预览。

## 排错

**`z` 命令不存在**：zoxide 没初始化。检查 `zshrc` 里那行 `_evalcache zoxide init zsh`。

**`z` 跳不到想要的目录**：数据库里还没有它。先进去一次（`cd`），zoxide 会自动记录；或 `za` 手动添加。

**跳到了错误目录**：用 `zi` 手动选，或用 `zoxide query -s` 看分数，用 `zr` 移除错误项。

**数据库太大**：`_ZO_MAXAGE` 控制上限，默认会自动淘汰。也可以 `zoxide edit` 手动清理。

**多个终端共享数据库**：这是设计行为。zoxide 用文件锁保证并发安全。
