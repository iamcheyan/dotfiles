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
<!-- lang:en -->
> Summary: vi-mode, Atuin, history options, and how to find out what the current shell actually binds to which keys.

# History and Command-Line Editing

## zsh-vi-mode

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode
export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
```

`lucid` keeps the plugin from immediately changing key bindings on load, avoiding conflicts with later plugins. It starts in Insert mode by default, so everyday typing doesn't require pressing Esc first.

| Mode | How to enter | Capabilities |
|---|---|---|
| Insert | Default / `i`, `a` | Normal typing |
| Normal | `Esc` | `h`/`l` move, `w`/`b` jump by word, `dd` delete line, `cw` change word, `0`/`$` line start/end |
| Visual | `v` | Selection operations |

After the plugin finishes loading it calls `zvm_after_init`; this repo uses that hook to bind the up arrow to Atuin:

```zsh
function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

The two escape sequences correspond to the up-arrow encoding of different terminals; both need to be bound.

## Atuin

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
```

Atuin stores history in SQLite rather than a plain-text file. That enables structured queries, statistics, and cross-machine sync.

```bash
atuin search              # 交互式搜索
atuin search --limit 20   # 限制条数
atuin stats               # 使用统计
atuin history list        # 列出历史
atuin doctor              # 诊断配置问题
```

In the search UI: `↑`/`↓` select, `Enter` executes, `Tab` puts the command back into the input line for further editing, `Ctrl+O` toggles the filter mode (global/directory/session).

This repo's `config/atuin/config.toml` disables automatic sync and update checks:

```toml
auto_sync = false
update_check = false
enter_accept = true
```

`enter_accept = true` means pressing Enter directly executes the selected command. To edit before running, press Tab instead of Enter.

## Two histories coexist

Atuin and Zsh's native history are two separate stores:

| | Zsh native | Atuin |
|---|---|---|
| Location | `~/.zsh_history` | `~/.local/share/atuin/history.db` |
| Format | Plain text | SQLite |
| Capacity | `HISTSIZE=100000` | No hard limit |
| Search | `Ctrl+R` (may be taken over by fzf or Atuin) | `↑` / `atuin search` |

Atuin imports Zsh's history, but new commands are written to SQLite. So `grep ~/.zsh_history` won't show recently executed commands — that's normal.

## Who actually owns Ctrl+R

`Ctrl+R` can be contested by three parties: Zsh's native `history-incremental-search-backward`, fzf's key-bindings, and Atuin's shell hook. Load order decides the final winner.

To check the current state:

```zsh
bindkey '^R'
```

If the output shows `fzf-history-widget`, fzf has taken over; if it shows something like `atuin-search`, it's Atuin. To specify explicitly, add your own `bindkey` in `local/`, because it loads last.

## History pitfalls

**Commands don't enter history**: check that `HISTFILE` is writable, and that you haven't accidentally set `HISTSIZE=0` in `local/`.

**Too many duplicate commands**: `HIST_IGNORE_ALL_DUPS` already handles this, but if you once imported old data with `atuin`, duplicates may have been brought in; clean them up with `atuin history prune` or `atuin history delete`.

**Terminals interfering with each other**: `SHARE_HISTORY` + `INC_APPEND_HISTORY` makes multiple terminals write to the same file at once. That's by design, but if the ordering looks scrambled, first confirm no other shell (say bash) is also writing `~/.zsh_history`.
<!-- lang:ja -->
> 要約：vi-mode、Atuin、履歴オプション、そして現在のシェルが実際にどのキーに何をバインドしているか確認する方法。

# 履歴とコマンドライン編集

## zsh-vi-mode

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode
export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
```

`lucid` により、プラグインはロード直後にキーバインドを変更しなくなり、後続のプラグインとの競合を避けられます。デフォルトでは Insert モードで起動するため、日常の入力で先に Esc を押す必要はありません。

| モード | 移行方法 | 能力 |
|---|---|---|
| Insert | デフォルト / `i`、`a` | 通常入力 |
| Normal | `Esc` | `h`/`l` 移動、`w`/`b` 単語ジャンプ、`dd` 行削除、`cw` 単語変更、`0`/`$` 行頭行末 |
| Visual | `v` | 選択範囲の操作 |

プラグインのロード完了後には `zvm_after_init` が呼ばれ、本リポジトリはこの hook で上矢印を Atuin にバインドしています：

```zsh
function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

2 つのエスケープシーケンスはターミナルごとに異なる上矢印のエンコーディングに対応するため、両方をバインドします。

## Atuin

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
```

Atuin は履歴をプレーンテキストではなく SQLite に保存します。これにより構造化クエリ、統計、マシン間同期が可能になります。

```bash
atuin search              # 交互式搜索
atuin search --limit 20   # 限制条数
atuin stats               # 使用统计
atuin history list        # 列出历史
atuin doctor              # 诊断配置问题
```

検索画面では：`↑`/`↓` で選択、`Enter` で実行、`Tab` でコマンドを入力行に戻して編集を続ける、`Ctrl+O` でフィルタモード（グローバル/ディレクトリ/セッション）を切り替えます。

本リポジトリの `config/atuin/config.toml` は自動同期と更新チェックを無効化しています：

```toml
auto_sync = false
update_check = false
enter_accept = true
```

`enter_accept = true` は、Enter を押すと選択したコマンドをそのまま実行することを意味します。実行前に編集したい場合は、Enter ではなく Tab を押してください。

## 2 つの履歴の共存

Atuin と Zsh 標準の履歴は別々のストレージです：

| | Zsh 標準 | Atuin |
|---|---|---|
| 場所 | `~/.zsh_history` | `~/.local/share/atuin/history.db` |
| 形式 | プレーンテキスト | SQLite |
| 容量 | `HISTSIZE=100000` | ハード上限なし |
| 検索 | `Ctrl+R`（fzf か Atuin に乗っ取られる場合あり） | `↑` / `atuin search` |

Atuin は Zsh の履歴を取り込みますが、新しいコマンドは SQLite に書き込まれます。そのため `grep ~/.zsh_history` では最近実行したコマンドが見えませんが、これは正常な動作です。

## Ctrl+R は結局誰のものか

`Ctrl+R` は 3 者で争われる可能性があります。Zsh 標準の `history-incremental-search-backward`、fzf の key-bindings、Atuin の shell hook です。ロード順序が最終結果を決めます。

現在の状態の確認：

```zsh
bindkey '^R'
```

出力が `fzf-history-widget` なら fzf が、`atuin-search` のような表示なら Atuin が引き受けています。明示的に指定したい場合は、`local/` に自分の `bindkey` を追加してください。最後にロードされるためです。

## 履歴まわりの落とし穴

**コマンドが履歴に入らない**：`HISTFILE` が書き込み可能か、`local/` で誤って `HISTSIZE=0` を設定していないか確認してください。

**重複コマンドが多すぎる**：`HIST_IGNORE_ALL_DUPS` が処理しますが、過去に `atuin` で旧データを取り込んでいると重複が持ち込まれることがあります。`atuin history prune` や `atuin history delete` で整理してください。

**複数ターミナルが互いに干渉する**：`SHARE_HISTORY` + `INC_APPEND_HISTORY` により、複数ターミナルが同じファイルに同時書き込みします。これは設計意図ですが、順序の乱れが見える場合は、他のシェル（bash など）も `~/.zsh_history` に書き込んでいないか先に確認してください。
