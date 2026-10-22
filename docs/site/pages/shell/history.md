> 摘要：vi-mode、Atuin、历史选项，以及如何确认当前 shell 到底绑定了什么键。

# 历史与命令行编辑

## zsh-vi-mode

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode
export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
```

`lucid` 让插件在加载时不立刻改变按键绑定，避免和后续插件冲突。默认以 Insert 模式启动，这样日常输入不需要先按 Esc。

| 模式 | 进入 | 能力 |
|---|---|---|
| Insert | 默认 / `i`、`a` | 正常输入 |
| Normal | `Esc` | `h`/`l` 移动、`w`/`b` 跳词、`dd` 删行、`cw` 改词、`0`/`$` 行首尾 |
| Visual | `v` | 选区操作 |

插件加载完后会调用 `zvm_after_init`，本仓库在这个 hook 里把上箭头绑到 Atuin：

```zsh
function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

两种转义序列分别对应不同终端的上箭头编码，都要绑。

## Atuin

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
```

Atuin 把历史存进 SQLite，而不是纯文本文件。这让它可以做结构化查询、统计、跨机器同步。

```bash
atuin search              # 交互式搜索
atuin search --limit 20   # 限制条数
atuin stats               # 使用统计
atuin history list        # 列出历史
atuin doctor              # 诊断配置问题
```

搜索界面里：`↑`/`↓` 选择，`Enter` 执行，`Tab` 把命令放回输入行继续编辑，`Ctrl+O` 切换过滤模式（全局/目录/会话）。

本仓库的 `config/atuin/config.toml` 关闭了自动同步和更新检查：

```toml
auto_sync = false
update_check = false
enter_accept = true
```

`enter_accept = true` 意味着按 Enter 直接执行选中的命令。想先编辑再执行，按 Tab 而不是 Enter。

## 两份历史并存

Atuin 和 Zsh 原生历史是两套存储：

| | Zsh 原生 | Atuin |
|---|---|---|
| 位置 | `~/.zsh_history` | `~/.local/share/atuin/history.db` |
| 格式 | 纯文本 | SQLite |
| 容量 | `HISTSIZE=100000` | 无硬上限 |
| 搜索 | `Ctrl+R`（可能被 fzf 或 Atuin 接管） | `↑` / `atuin search` |

Atuin 会导入 Zsh 的历史，但新命令写进 SQLite。所以 `grep ~/.zsh_history` 看不到最近执行的命令，这是正常的。

## Ctrl+R 到底归谁

`Ctrl+R` 可能被三方争夺：Zsh 原生 `history-incremental-search-backward`、fzf 的 key-bindings、Atuin 的 shell hook。加载顺序决定最终结果。

确认当前状态：

```zsh
bindkey '^R'
```

输出里如果是 `fzf-history-widget` 就是 fzf 接管；如果是 `atuin-search` 之类就是 Atuin。想明确指定，在 `local/` 里加自己的 `bindkey`，因为它最后加载。

## 历史相关的坑

**命令没进历史**：检查 `HISTFILE` 是否可写，以及是否在 `local/` 里误设了 `HISTSIZE=0`。

**重复命令太多**：`HIST_IGNORE_ALL_DUPS` 已经处理，但如果用 `atuin` 导入过旧数据，可能带进重复项，用 `atuin history prune` 或 `atuin history delete` 清理。

**多终端互相干扰**：`SHARE_HISTORY` + `INC_APPEND_HISTORY` 会让多个终端同时写同一文件。这是设计意图，但如果看到顺序混乱，先确认没有别的 shell（比如 bash）也在写 `~/.zsh_history`。
