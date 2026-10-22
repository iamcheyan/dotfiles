> 摘要：Atuin 用 SQLite 存储命令历史，提供增强搜索、统计和可选的跨机同步。

# Atuin

## 用途

Atuin 把 shell 历史从纯文本文件搬进 SQLite 数据库，带来四个能力：结构化查询、按目录/会话过滤、统计、跨机器同步。它同时替换上箭头的历史搜索体验。

本仓库用它作为主要的交互式历史搜索入口。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 优先系统包；系统没有时用 Zinit 下载 release |
| 加载位置 | `plugins/tools/tools.zsh` |
| 配置文件 | `config/atuin/config.toml` → `~/.config/atuin/` |
| 数据文件 | `~/.local/share/atuin/history.db` |

```zsh
# 系统没有 atuin 时的兜底
if ! command -v atuin >/dev/null 2>&1; then
  zinit ice as"command" from"gh-r" bpick"atuin-${atuin_arch}-unknown-linux-gnu.tar.gz" ...
  zinit light atuinsh/atuin
fi
```

优先用系统版本，因为它的更新跟着系统走，不会出现「Zinit 版本和系统版本打架」。

## 初始化

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
```

`atuin init zsh` 注入一个 `precmd` hook，每条命令执行后写入数据库，并绑定上箭头。

## 本仓库的配置

`config/atuin/config.toml` 里显式设置的三项：

```toml
auto_sync = false
update_check = false
enter_accept = true
```

| 设置 | 含义 |
|---|---|
| `auto_sync = false` | 不自动同步到 Atuin 服务器 |
| `update_check = false` | 启动时不检查新版本 |
| `enter_accept = true` | 按 Enter 直接执行选中的命令 |

`auto_sync = false` 是隐私相关的默认值：历史里可能有 token、内部地址、临时命令，不主动上传。

其余配置项全部注释保留，方便按需开启。值得注意的几项：

```toml
# search_mode = "fuzzy"          # prefix / fulltext / fuzzy / skim
# filter_mode = "global"         # global / host / session / directory / workspace
# style = "auto"                 # auto / full / compact
# inline_height = 0              # 0 表示全屏
# secrets_filter = true          # 默认开启，过滤疑似密钥
```

## 基本用法

```bash
atuin search                 # 交互式搜索
atuin search git             # 带初始查询
atuin search --limit 50      # 限制条数
atuin search -i              # 只搜当前目录
atuin stats                  # 使用统计
atuin history list           # 列出全部历史
atuin history last           # 最后一条
atuin doctor                 # 诊断
```

## 搜索界面按键

| 键 | 作用 |
|---|---|
| `↑` / `↓` | 移动选择 |
| `Enter` | 执行（因为 `enter_accept = true`） |
| `Tab` | 把命令放回输入行，继续编辑 |
| `Ctrl+O` | 循环切换过滤模式 |
| `Ctrl+R` | 切换搜索模式 |
| `Esc` | 退出 |

**关键区别**：Enter 直接执行，Tab 才回到命令行。如果想先改再执行，养成按 Tab 的习惯。

## 过滤模式

| 模式 | 范围 |
|---|---|
| `global` | 全部历史 |
| `host` | 当前主机 |
| `session` | 当前 shell 会话 |
| `directory` | 当前目录 |
| `workspace` | 当前 Git 仓库树内 |

按 `Ctrl+O` 循环切换。在项目目录里用 `directory` 模式，能快速找回该项目相关命令。

## 同步（默认关闭）

想启用跨机同步：

```bash
atuin register -u <用户名> -e <邮箱> -p
atuin login -u <用户名> -p
atuin key                    # 打印加密密钥，用于其它机器
atuin sync
```

然后在配置里把 `auto_sync` 改为 `true`。同步是端到端加密的，密钥不上传，但**历史内容会上传到 Atuin 服务器**。启用前确认历史里没有敏感信息。

## 数据维护

```bash
atuin history prune          # 清理旧条目
atuin history delete         # 交互式删除
atuin import auto            # 从其它 shell 历史导入
atuin info                   # 显示数据文件位置和环境变量
```

## 与 Zsh 原生历史的关系

两套存储并存：

| | Zsh 原生 | Atuin |
|---|---|---|
| 文件 | `~/.zsh_history` | `history.db` |
| 写入 | `INC_APPEND_HISTORY` | precmd hook |
| 读取 | `history` 内建 | `atuin search` |

所以 `grep ~/.zsh_history` 找不到最近执行的命令，这是正常的。要导出 Atuin 历史：

```bash
atuin history list --format '{command}' > history.txt
```

## 排错

**上箭头行为不对**：`zvm_after_init` 里的 `zvm_bindkey viins '^[[A' atuin-up-search` 没生效。检查 zsh-vi-mode 是否加载，以及该函数是否被调用。

**`atuin doctor` 报数据库损坏**：备份后重建。`atuin info` 显示数据库路径，改名后重启 shell 会新建。

**历史没记录**：precmd hook 没安装。`atuin init zsh` 是否成功执行？`_evalcache` 的缓存文件可能过期，删掉缓存目录重试。

**同步冲突**：多机同时写入时会有冲突。`atuin status` 查看状态，必要时 `atuin sync --force`。

**搜索很慢**：数据库太大。`atuin history prune` 清理，或在配置里限制保留时间。
