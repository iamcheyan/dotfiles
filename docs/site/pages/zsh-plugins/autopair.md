> 摘要：zsh-autopair 自动补全成对的括号和引号，并支持成对删除。

# zsh-autopair

## 用途

输入 `(` 自动补 `)`，输入 `"` 自动补 `"`。光标停在中间，继续输入内容。在已补全的右括号前按退格，会把两个一起删掉。

它只作用于**命令行**，不影响编辑器里的文本。

## 加载方式

```zsh
zinit light hlissner/zsh-autopair
```

无参数，无配置项。

## 支持的配对

| 输入 | 自动补 |
|---|---|
| `(` | `)` |
| `[` | `]` |
| `{` | `}` |
| `"` | `"` |
| `'` | `'` |
| `` ` `` | `` ` `` |

## 行为细节

### 自动跳过

如果光标右边已经是同一个右括号，再输入它时不会重复插入，而是直接跳过：

```text
输入: echo (|
按键: )
结果: echo ()|        ← 光标在右括号之后，没有变成 ())
```

### 成对删除

```text
状态: echo ()|        ← 光标在括号之间
按键: Backspace
结果: echo |          ← 两个括号一起删掉
```

### 在已有字符前输入

```text
状态: echo foo|bar
按键: (
结果: echo foo(|bar   ← 只在光标处插入左括号，不自动补右括号
```

最后一种情况是刻意设计：光标后面已有内容时，自动补右括号往往不是用户想要的。

## 与 vi-mode 的交互

普通模式下：

| 键 | 行为 |
|---|---|
| `x` | 删除字符，不触发配对 |
| `dd` | 删除行 |
| `i` 后输入 `(` | 触发自动配对 |

配对只在插入模式生效。

## 与 autosuggestions 的关系

两者都在插入模式工作，但不冲突：

| | autopair | autosuggestions |
|---|---|---|
| 触发 | 输入特定字符 | 输入任意字符后 |
| 影响 | 插入配对字符 | 显示灰色建议 |
| 接受键 | 自动 | `→` |

一个改变缓冲区内容，一个只显示提示。

## 什么时候会觉得碍事

| 场景 | 现象 |
|---|---|
| 粘贴含括号的文本 | 不会触发（粘贴不逐字符模拟按键） |
| 想输入单个 `(` | 需要按两次，或先输入再删 |
| 在某些 TUI 程序里 | 程序自己处理括号时可能重复 |

如果想关闭某一对：

```zsh
# 在 local/custom.zsh 里
ZSH_AUTOPAIR_DISABLE_SINGLE_QUOTE=1
```

具体变量名依上游版本而定，可用 `set | grep AUTOPAIR` 查看。

## 完全关闭

```zsh
# 注释掉 zsh-plugins.zsh 里那一行
# zinit light hlissner/zsh-autopair
```

或在自己的 `local/` 里 `unfunction` 相关 widget（较麻烦，不推荐）。

## 排错

**输入括号没有自动补全**：插件没加载。`zinit list | grep autopair` 确认。

**成对删除不工作**：光标不在配对之间，或右括号后面还有字符。

**和某个程序冲突**：某些交互式程序（如 `psql`、`python` REPL）自己处理括号。可以临时 `exec zsh -f` 启动无配置 shell。

**中文输入法下异常**：输入法在组合状态时不会触发按键事件，属预期行为。

<!-- lang:en -->

> Summary: zsh-autopair automatically completes paired brackets and quotes, and supports deleting them as a pair.

# zsh-autopair

## Purpose

Type `(` and `)` is completed automatically; type `"` and `"` is completed. The cursor stays in the middle so you can keep typing. Pressing Backspace before an already-completed closing bracket deletes both.

It only applies to the **command line**; it does not affect text in editors.

## Loading

```zsh
zinit light hlissner/zsh-autopair
```

No arguments, no configuration options.

## Supported pairs

| Input | Auto-completes |
|---|---|
| `(` | `)` |
| `[` | `]` |
| `{` | `}` |
| `"` | `"` |
| `'` | `'` |
| `` ` `` | `` ` `` |

## Behavior details

### Auto-skipping

If the character to the right of the cursor is already the same closing bracket, typing it again does not insert a duplicate — the cursor simply skips over it:

```text
输入: echo (|
按键: )
结果: echo ()|        ← 光标在右括号之后，没有变成 ())
```

### Paired deletion

```text
状态: echo ()|        ← 光标在括号之间
按键: Backspace
结果: echo |          ← 两个括号一起删掉
```

### Typing before existing characters

```text
状态: echo foo|bar
按键: (
结果: echo foo(|bar   ← 只在光标处插入左括号，不自动补右括号
```

The last case is intentional: when there is already content after the cursor, auto-completing the closing bracket is usually not what the user wants.

## Interaction with vi-mode

In normal mode:

| Key | Behavior |
|---|---|
| `x` | Deletes a character, does not trigger pairing |
| `dd` | Deletes the line |
| Typing `(` after `i` | Triggers auto-pairing |

Pairing only takes effect in insert mode.

## Relationship with autosuggestions

Both work in insert mode, but they do not conflict:

| | autopair | autosuggestions |
|---|---|---|
| Trigger | Typing specific characters | After typing any character |
| Effect | Inserts paired characters | Shows a gray suggestion |
| Accept key | Automatic | `→` |

One changes the buffer contents; the other only shows a hint.

## When it gets in the way

| Scenario | Symptom |
|---|---|
| Pasting text containing brackets | Not triggered (pasting does not simulate keystrokes character by character) |
| Wanting to type a single `(` | You need to press twice, or type first and delete after |
| Inside some TUI programs | May duplicate when the program handles brackets itself |

If you want to disable a specific pair:

```zsh
# 在 local/custom.zsh 里
ZSH_AUTOPAIR_DISABLE_SINGLE_QUOTE=1
```

The exact variable name depends on the upstream version; use `set | grep AUTOPAIR` to check.

## Disabling entirely

```zsh
# 注释掉 zsh-plugins.zsh 里那一行
# zinit light hlissner/zsh-autopair
```

Or `unfunction` the relevant widgets in your own `local/` (cumbersome, not recommended).

## Troubleshooting

**Typing a bracket does not auto-complete**: the plugin is not loaded. Confirm with `zinit list | grep autopair`.

**Paired deletion does not work**: the cursor is not between a pair, or there are characters after the closing bracket.

**Conflicts with a certain program**: some interactive programs (such as `psql` or the `python` REPL) handle brackets themselves. You can temporarily start a configuration-free shell with `exec zsh -f`.

**Misbehaving under a Chinese input method**: the input method does not emit key events while in composition state; this is expected behavior.

<!-- lang:ja -->

> 要約：zsh-autopair は対になる括弧や引用符を自動補完し、対での削除にも対応します。

# zsh-autopair

## 用途

`(` を入力すると `)` が自動で補完され、`"` を入力すると `"` が補完されます。カーソルは真ん中に止まるので、そのまま入力を続けられます。補完済みの閉じ括弧の前でバックスペースを押すと、両方まとめて削除されます。

コマンドラインのみに作用し、エディタ内のテキストには影響しません。

## 読み込み方法

```zsh
zinit light hlissner/zsh-autopair
```

引数も設定項目もありません。

## 対応するペア

| 入力 | 自動補完 |
|---|---|
| `(` | `)` |
| `[` | `]` |
| `{` | `}` |
| `"` | `"` |
| `'` | `'` |
| `` ` `` | `` ` `` |

## 動作の詳細

### 自動スキップ

カーソルの右側に同じ閉じ括弧がすでにある場合、それを入力しても重複挿入されず、そのままスキップします：

```text
输入: echo (|
按键: )
结果: echo ()|        ← 光标在右括号之后，没有变成 ())
```

### 対での削除

```text
状态: echo ()|        ← 光标在括号之间
按键: Backspace
结果: echo |          ← 两个括号一起删掉
```

### 既存の文字の前での入力

```text
状态: echo foo|bar
按键: (
结果: echo foo(|bar   ← 只在光标处插入左括号，不自动补右括号
```

最後のケースは意図的な設計です：カーソルの後ろに既に内容がある場合、閉じ括弧の自動補完は多くの場合ユーザーの望む動作ではありません。

## vi-mode との相互作用

ノーマルモードでは：

| キー | 動作 |
|---|---|
| `x` | 1文字削除。ペアリングは発動しない |
| `dd` | 行削除 |
| `i` の後に `(` を入力 | 自動ペアリングが発動 |

ペアリングは挿入モードでのみ有効です。

## autosuggestions との関係

両者とも挿入モードで動きますが、衝突しません：

| | autopair | autosuggestions |
|---|---|---|
| 発動 | 特定の文字を入力 | 任意の文字を入力した後 |
| 影響 | ペア文字を挿入 | グレーの候補を表示 |
| 受理キー | 自動 | `→` |

片方はバッファの内容を変更し、もう片方はヒントを表示するだけです。

## 邪魔に感じるとき

| シナリオ | 現象 |
|---|---|
| 括弧を含むテキストの貼り付け | 発動しない（貼り付けはキー入力を1文字ずつ模倣しないため） |
| 単独の `(` を入力したい | 2回押すか、入力してから削除する必要がある |
| 一部の TUI プログラム内 | プログラム自身が括弧を処理する場合に重複することがある |

特定のペアを無効化したい場合：

```zsh
# 在 local/custom.zsh 里
ZSH_AUTOPAIR_DISABLE_SINGLE_QUOTE=1
```

正確な変数名は上流のバージョンによります。`set | grep AUTOPAIR` で確認できます。

## 完全に無効化

```zsh
# 注释掉 zsh-plugins.zsh 里那一行
# zinit light hlissner/zsh-autopair
```

または自分の `local/` で関連ウィジェットを `unfunction` します（手間がかかるため非推奨）。

## トラブルシューティング

**括弧を入力しても自動補完されない**：プラグインが読み込まれていません。`zinit list | grep autopair` で確認します。

**対での削除が動作しない**：カーソルがペアの間にないか、閉じ括弧の後ろに文字があります。

**特定のプログラムと衝突する**：一部のインタラクティブなプログラム（`psql` や `python` REPL など）は自身で括弧を処理します。`exec zsh -f` で設定なしのシェルを一時的に起動して切り分けられます。

**中国語入力メソッドでの異常動作**：入力メソッドは変換状態ではキーイベントを発行しないため、これは想定内の動作です。
