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

<!-- lang:en -->

> Summary: zsh-autosuggestions shows gray suggestion text after the cursor, drawn from history and completion results.

# zsh-autosuggestions

## Purpose

As you type a command, it displays "the full command you probably want to type" in gray after the cursor. Press the accept key to take it, or keep typing to overwrite it.

It differs from fzf history search: fzf actively opens a search interface, while autosuggestions passively keeps showing hints.

## Loading

```zsh
zinit light zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

It must be loaded after zsh-vi-mode.

## The four configuration options

### STRATEGY

```zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
```

Two sources are tried in order:

| Value | Source |
|---|---|
| `history` | Finds prefix matches in the command history |
| `completion` | Finds matches in the Zsh completion system |
| `match_prev_cmd` | Matches "the command that followed the previous command" |

This repo tries history first, then completion. History is closer to personal habits; completion covers commands that were never executed.

To be smarter, add a third:

```zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
```

`match_prev_cmd` takes the previous command into account — for example, right after a `cd`, it suggests `ls` first.

### HIGHLIGHT_STYLE

```zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
```

`fg=8` is color number 8 in the terminal's 256-color palette (usually bright gray). The suggestion text is gray so it does not grab attention visually.

Try `fg=240` for a fainter look, or `fg=245` for something more visible.

### BUFFER_MAX_SIZE

```zsh
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
```

Suggestions are no longer generated once the command line exceeds 100 characters.

Reason: computing suggestions for long commands is expensive and rarely needed in practice. When pasting large blocks of text, this limit avoids noticeable lag.

### USE_ASYNC

```zsh
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

Suggestions are computed asynchronously without blocking typing. The trade-off is a very short delay before suggestions appear.

## Keys for accepting a suggestion

The default is `→` (right arrow). Some configurations also have:

| Key | Behavior |
|---|---|
| `→` | Accept the whole suggestion |
| `Ctrl+→` | Accept one word |
| `End` | Accept the whole suggestion (some terminals) |

To change it to `Ctrl+Space`:

```zsh
bindkey '^ ' autosuggest-accept
```

Put it in `local/` to override.

## Working with vi-mode

In normal mode:

| Key | Behavior |
|---|---|
| `→` | Accept the suggestion (switches to insert mode) |
| `w` | Move by word, no suggestion triggered |
| `$` | Jump to end of line |

Suggestions only display in insert mode. You cannot see the gray text in normal mode — that is expected behavior.

## Difference from fzf history search

| | autosuggestions | fzf `Ctrl+R` |
|---|---|---|
| Trigger | Automatic, continuous | Manual keypress |
| Interface | Gray text after the cursor | Full/half-screen selector |
| Matching | Prefix | Fuzzy |
| Best for | Repeating similar commands | Finding commands from long ago |

The two can coexist and complement each other.

## When suggestions are inaccurate

**The suggestion is an old command**: the `history` strategy matches by prefix and picks the most recent one. Add `match_prev_cmd` to make it smarter.

**It suggests what it shouldn't**: sensitive commands exist in the history. Enable Atuin's `history_filter`, or clean up the history.

**Suggestions flicker frequently**: the order in which async results return is unstable. You can turn off `USE_ASYNC` (at the cost of possible typing lag).

## Troubleshooting

**No gray suggestions**: the plugin is not loaded, or the `HIGHLIGHT_STYLE` color is too close to the background. Try `fg=240`.

**`→` does nothing**: the key is taken by vi-mode or another plugin. Use `bindkey '^[[C'` to check the current binding.

**Suggestions appear but slowly**: `USE_ASYNC` is off, or the history file is too large. Check `HISTSIZE`.

**Lag when pasting**: `BUFFER_MAX_SIZE` is set too high. Lower it below 100.

**Conflict with fzf-tab**: both use Tab-adjacent keys but with different responsibilities. If Tab behaves oddly, first confirm `menu no` is in effect.

<!-- lang:ja -->

> 要約：zsh-autosuggestions は履歴と補完結果をもとに、カーソルの後ろにグレーの候補テキストを表示します。

# zsh-autosuggestions

## 用途

コマンドを入力している最中に、「入力しようとしているであろう完全なコマンド」をカーソルの後ろにグレーで表示します。受け入れキーでそのまま採用するか、入力を続けて上書きします。

fzf の履歴検索との違いは、fzf が能動的に検索画面を開くのに対し、autosuggestions は受動的にヒントを表示し続ける点です。

## 読み込み方法

```zsh
zinit light zsh-users/zsh-autosuggestions

ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

zsh-vi-mode の**後**に読み込む必要があります。

## 4つの設定項目

### STRATEGY

```zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
```

2つのソースを順番に試します：

| 値 | ソース |
|---|---|
| `history` | コマンド履歴から前方一致を探す |
| `completion` | Zsh 補完システムから探す |
| `match_prev_cmd` | 「前のコマンドの後に打たれたコマンド」を一致させる |

本リポジトリでは履歴を先に、次に補完を試します。履歴は個人の習慣に近く、補完は実行したことのないコマンドもカバーします。

もっと賢くしたい場合は3つ目を追加します：

```zsh
ZSH_AUTOSUGGEST_STRATEGY=(history completion match_prev_cmd)
```

`match_prev_cmd` は前のコマンドを参考にします。たとえば直前に `cd` していれば、`ls` を優先的に候補にします。

### HIGHLIGHT_STYLE

```zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
```

`fg=8` はターミナルの256色パレットの8番（通常は明るいグレー）です。候補テキストがグレーなので、視覚的に注意を奪いません。

もっと薄くしたければ `fg=240` を、もっと目立たせたければ `fg=245` を試します。

### BUFFER_MAX_SIZE

```zsh
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=100
```

コマンドラインが100文字を超えると候補を生成しなくなります。

理由：長いコマンドの候補計算はコストが高く、実際の場面ではほとんど必要ないためです。長いテキストを貼り付ける際、この制限が顕著な遅延を防ぎます。

### USE_ASYNC

```zsh
ZSH_AUTOSUGGEST_USE_ASYNC=1
```

候補を非同期で計算し、入力をブロックしません。代償として、候補の表示にごく短い遅延が生じます。

## 候補を受け入れるキー

デフォルトは `→`（右矢印キー）です。一部の設定では次のキーもあります：

| キー | 動作 |
|---|---|
| `→` | 候補全体を受け入れる |
| `Ctrl+→` | 1単語を受け入れる |
| `End` | 全体を受け入れる（一部の端末） |

`Ctrl+Space` に変更したい場合：

```zsh
bindkey '^ ' autosuggest-accept
```

`local/` に置いて上書きします。

## vi-mode との連携

ノーマルモードでは：

| キー | 動作 |
|---|---|
| `→` | 候補を受け入れる（挿入モードへ切り替え） |
| `w` | 単語単位で移動。候補は発動しない |
| `$` | 行末へ移動 |

候補は挿入モードでのみ表示されます。ノーマルモードではグレーのテキストは見えません。これは想定内の動作です。

## fzf 履歴検索との違い

| | autosuggestions | fzf `Ctrl+R` |
|---|---|---|
| 発動 | 自動・継続的 | 手動でキー入力 |
| インターフェース | カーソル後のグレーテキスト | 全画面/半画面のセレクター |
| 一致 | 前方一致 | あいまい |
| 向いている場面 | 似たコマンドの繰り返し実行 | 昔のコマンドを探す |

両者は共存でき、補い合います。

## 候補が不正確なとき

**古いコマンドが候補になる**：`history` 戦略は前方一致で最新の1件を取ります。より賢くしたい場合は `match_prev_cmd` を追加します。

**候補にするべきでないものが出る**：履歴に機密性の高いコマンドが残っています。Atuin の `history_filter` を有効にするか、履歴を整理します。

**候補が頻繁にちらつく**：非同期計算の結果の返却順が不安定です。`USE_ASYNC` を無効にできます（入力が固まる可能性という代償があります）。

## トラブルシューティング

**グレーの候補が見えない**：プラグインが読み込まれていないか、`HIGHLIGHT_STYLE` の色が背景に近すぎます。`fg=240` を試します。

**`→` が反応しない**：キーが vi-mode や他のプラグインに奪われています。`bindkey '^[[C'` で現在のバインドを確認します。

**候補は出るが遅い**：`USE_ASYNC` が無効か、履歴ファイルが大きすぎます。`HISTSIZE` を確認します。

**貼り付け時に固まる**：`BUFFER_MAX_SIZE` が高すぎます。100 未満に下げます。

**fzf-tab と衝突する**：両者とも Tab 近辺のキーを使いますが、担当範囲が異なります。Tab の動作が異常な場合は、まず `menu no` が効いているか確認します。
