> 摘要：zsh-vi-mode 让命令行拥有 Vim 的普通/可视模式，并默认以插入模式启动。

# zsh-vi-mode

## 用途

Zsh 自带 `bindkey -v` 的 vi 模式，但功能有限。`jeffreytse/zsh-vi-mode` 提供完整实现：文本对象、寄存器、可视模式、可配置的模式指示器。

本仓库用它把命令行编辑变成 Vim 手感：`Esc` 进入普通模式，然后 `w`、`b`、`dd`、`ciw` 都能用。

## 加载方式

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

### lucid 的作用

`lucid` 让插件加载时不立刻绑定键位。原因是 zsh-vi-mode 会重置整个键位表，如果它先执行，后面插件的 `bindkey` 可能被覆盖。

加了 `lucid` 后，实际初始化推迟到 `zshrc` 加载完毕，此时其它插件已经设置好键位。

### ZVM_LINE_INIT_MODE

默认情况下 vi-mode 启动后是普通模式，每次开终端都要先按 `i`。这个变量改成 Insert 模式，符合日常输入习惯。

### zvm_after_init

插件提供的 hook，在所有初始化完成后调用。本仓库在这里把上箭头绑给 Atuin：

```zsh
zvm_bindkey viins '^[[A' atuin-up-search
zvm_bindkey viins '^[OA' atuin-up-search
```

两种转义序列对应不同终端的上箭头编码，两个都要绑。

## 模式

| 模式 | 进入方式 | 提示符 |
|---|---|---|
| Insert | 默认，或 `i`、`a`、`I`、`A` | 正常 |
| Normal | `Esc` | 光标变方块 |
| Visual | 普通模式下 `v` | 选区高亮 |
| Visual-line | 普通模式下 `V` | 整行选区 |

## 常用键位

### 移动

| 键 | 动作 |
|---|---|
| `h` / `l` | 左 / 右一个字符 |
| `w` / `b` | 下一个 / 上一个词首 |
| `e` | 词尾 |
| `0` / `$` | 行首 / 行尾 |
| `^` | 第一个非空字符 |
| `f<char>` / `F<char>` | 行内向后 / 向前跳到字符 |
| `t<char>` / `T<char>` | 跳到字符前 |

### 编辑

| 键 | 动作 |
|---|---|
| `x` | 删除光标处字符 |
| `dd` | 删除整行 |
| `dw` | 删除一个词 |
| `D` | 删到行尾 |
| `cw` | 改一个词 |
| `cc` | 改整行 |
| `r<char>` | 替换一个字符 |
| `~` | 切换大小写 |

### 文本对象

| 键 | 动作 |
|---|---|
| `ciw` | 改词内 |
| `caw` | 改一个词（含空格） |
| `ci"` | 改双引号内 |
| `ci'` | 改单引号内 |
| `ci(` / `ci)` | 改括号内 |
| `di{` | 删花括号内 |

### 可视模式

| 键 | 动作 |
|---|---|
| `v` | 进入字符可视 |
| `V` | 进入行可视 |
| `y` | 复制选区 |
| `d` | 删除选区 |
| `c` | 改选区 |
| `>` / `<` | 缩进 |

### 历史

| 键 | 动作 |
|---|---|
| `k` / `j`（普通模式） | 上一条 / 下一条历史 |
| `↑` / `↓`（插入模式） | 交给 Atuin（本仓库配置） |
| `/` | 反向搜索历史 |
| `?` | 正向搜索历史 |

## 模式指示器

插件可以在提示符里显示当前模式。本仓库没启用，靠 Starship 的 `vimcmd_symbol` 间接提示：

```toml
[character]
vimcmd_symbol = "[❯](bold yellow)"
```

普通模式下提示符变黄，是一个轻量的模式提示。

想用插件自带的指示器：

```zsh
ZVM_MODE_INDICATOR=1
```

## 与 autosuggestions 的顺序

vi-mode 必须在 zsh-autosuggestions **之前**加载。

原因：autosuggestions 会在 `zle` 里插入建议文本，vi-mode 会重设键位表。如果顺序反了，建议文本的接受键（默认 `→`）可能失效。

本仓库的顺序是对的：

```zsh
zinit light jeffreytse/zsh-vi-mode
...
zinit light zsh-users/zsh-autosuggestions
```

## 排错

**启动是普通模式**：`ZVM_LINE_INIT_MODE` 没设，或设在了插件加载之后。必须在 `zinit light` 之前 `export`。

**上箭头不搜索历史**：`zvm_after_init` 没被调用，或 Atuin 没装。检查：

```zsh
bindkey '^[[A'
```

**`Esc` 没反应**：可能被终端或 tmux 拦截。在 tmux 里检查 `escape-time`。

**键位被别的插件覆盖**：检查 vi-mode 是否在其它插件之前加载。`lucid` 参数是必需的。

**`ciw` 之类文本对象不工作**：这些是 vi-mode 提供的，如果失效说明插件没真正初始化。`zinit list | grep vi-mode` 确认。

<!-- lang:en -->

> Summary: zsh-vi-mode brings Vim's normal/visual modes to the command line, and starts in insert mode by default.

# zsh-vi-mode

## Purpose

Zsh has a built-in vi mode via `bindkey -v`, but it is limited. `jeffreytse/zsh-vi-mode` provides a full implementation: text objects, registers, visual mode, and a configurable mode indicator.

This repository uses it to give command-line editing a Vim feel: `Esc` enters normal mode, after which `w`, `b`, `dd`, `ciw` all work.

## How It Loads

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

### What lucid Does

`lucid` prevents the plugin from binding keys immediately upon load. The reason is that zsh-vi-mode resets the entire keymaps; if it runs first, the `bindkey` calls of later plugins may be overwritten.

With `lucid`, the actual initialization is deferred until `zshrc` has finished loading, by which time the other plugins have already set up their keybindings.

### ZVM_LINE_INIT_MODE

By default vi-mode starts in normal mode, so every new terminal requires pressing `i` first. This variable switches it to Insert mode, matching everyday typing habits.

### zvm_after_init

A hook provided by the plugin, called after all initialization completes. This repository binds the up arrow to Atuin here:

```zsh
zvm_bindkey viins '^[[A' atuin-up-search
zvm_bindkey viins '^[OA' atuin-up-search
```

The two escape sequences correspond to different terminals' up-arrow encodings; both must be bound.

## Modes

| Mode | How to enter | Prompt |
|---|---|---|
| Insert | Default, or `i`, `a`, `I`, `A` | Normal |
| Normal | `Esc` | Cursor becomes a block |
| Visual | `v` in normal mode | Selection highlighted |
| Visual-line | `V` in normal mode | Whole line selected |

## Common Keybindings

### Motion

| Key | Action |
|---|---|
| `h` / `l` | One character left / right |
| `w` / `b` | Start of next / previous word |
| `e` | End of word |
| `0` / `$` | Beginning / end of line |
| `^` | First non-blank character |
| `f<char>` / `F<char>` | Jump to character forward / backward within the line |
| `t<char>` / `T<char>` | Jump up to the character |

### Editing

| Key | Action |
|---|---|
| `x` | Delete character under cursor |
| `dd` | Delete whole line |
| `dw` | Delete a word |
| `D` | Delete to end of line |
| `cw` | Change a word |
| `cc` | Change whole line |
| `r<char>` | Replace one character |
| `~` | Toggle case |

### Text Objects

| Key | Action |
|---|---|
| `ciw` | Change inner word |
| `caw` | Change a word (including whitespace) |
| `ci"` | Change inside double quotes |
| `ci'` | Change inside single quotes |
| `ci(` / `ci)` | Change inside brackets |
| `di{` | Delete inside braces |

### Visual Mode

| Key | Action |
|---|---|
| `v` | Enter character-wise visual mode |
| `V` | Enter line-wise visual mode |
| `y` | Copy selection |
| `d` | Delete selection |
| `c` | Change selection |
| `>` / `<` | Indent |

### History

| Key | Action |
|---|---|
| `k` / `j` (normal mode) | Previous / next history entry |
| `↑` / `↓` (insert mode) | Handed to Atuin (this repo's configuration) |
| `/` | Search history backward |
| `?` | Search history forward |

## Mode Indicator

The plugin can show the current mode in the prompt. This repository does not enable it, relying instead on Starship's `vimcmd_symbol` as an indirect hint:

```toml
[character]
vimcmd_symbol = "[❯](bold yellow)"
```

In normal mode the prompt turns yellow, which is a lightweight mode hint.

To use the plugin's own indicator:

```zsh
ZVM_MODE_INDICATOR=1
```

## Ordering with autosuggestions

vi-mode must load **before** zsh-autosuggestions.

Reason: autosuggestions inserts suggestion text inside `zle`, and vi-mode resets the keymaps. If the order is reversed, the key that accepts the suggestion (default `→`) may stop working.

This repository's order is correct:

```zsh
zinit light jeffreytse/zsh-vi-mode
...
zinit light zsh-users/zsh-autosuggestions
```

## Troubleshooting

**Starts in normal mode**: `ZVM_LINE_INIT_MODE` is not set, or is set after the plugin loads. It must be `export`ed before `zinit light`.

**Up arrow does not search history**: `zvm_after_init` was not called, or Atuin is not installed. Check with:

```zsh
bindkey '^[[A'
```

**`Esc` does nothing**: it may be intercepted by the terminal or tmux. Inside tmux, check `escape-time`.

**Keybindings overwritten by another plugin**: check whether vi-mode loads before the other plugins. The `lucid` parameter is required.

**Text objects like `ciw` do not work**: these come from vi-mode; if they fail, the plugin was not really initialized. Confirm with `zinit list | grep vi-mode`.

<!-- lang:ja -->

> 要約：zsh-vi-mode はコマンドラインに Vim のノーマル/ビジュアルモードをもたらし、既定では挿入モードで起動します。

# zsh-vi-mode

## 用途

Zsh には `bindkey -v` による vi モードが組み込まれていますが、機能は限定的です。`jeffreytse/zsh-vi-mode` は完全な実装を提供します。テキストオブジェクト、レジスタ、ビジュアルモード、設定可能なモードインジケーターです。

本リポジトリではこれを使ってコマンドライン編集を Vim の手触りにします。`Esc` でノーマルモードに入り、その後は `w`・`b`・`dd`・`ciw` がすべて使えます。

## 読み込み方法

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode

export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT

function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

### lucid の役割

`lucid` は、プラグインの読み込み時にすぐキーバインドしないようにします。理由は、zsh-vi-mode がキーマップ全体をリセットするためです。先に実行されると、後続のプラグインの `bindkey` が上書きされる可能性があります。

`lucid` を付けると実際の初期化は `zshrc` の読み込み完了まで延期され、その時点では他のプラグインがすでにキーバインドを設定し終えています。

### ZVM_LINE_INIT_MODE

既定では vi-mode の起動時はノーマルモードなので、ターミナルを開くたびにまず `i` を押す必要があります。この変数で挿入モードに変更し、日常の入力習慣に合わせます。

### zvm_after_init

プラグインが提供する hook で、すべての初期化が完了した後に呼ばれます。本リポジトリではここで上矢印を Atuin にバインドしています：

```zsh
zvm_bindkey viins '^[[A' atuin-up-search
zvm_bindkey viins '^[OA' atuin-up-search
```

二つのエスケープシーケンスはターミナルごとに異なる上矢印の符号化に対応しており、両方バインドする必要があります。

## モード

| モード | 入り方 | プロンプト |
|---|---|---|
| Insert | 既定、または `i`・`a`・`I`・`A` | 通常 |
| Normal | `Esc` | カーソルがブロックになる |
| Visual | ノーマルモードで `v` | 選択範囲がハイライト |
| Visual-line | ノーマルモードで `V` | 行全体を選択 |

## よく使うキーバインド

### 移動

| キー | 動作 |
|---|---|
| `h` / `l` | 左 / 右に一文字 |
| `w` / `b` | 次 / 前の単語の先頭 |
| `e` | 単語の末尾 |
| `0` / `$` | 行頭 / 行末 |
| `^` | 最初の非空白文字 |
| `f<char>` / `F<char>` | 行内で後方 / 前方の文字へジャンプ |
| `t<char>` / `T<char>` | 文字の手前までジャンプ |

### 編集

| キー | 動作 |
|---|---|
| `x` | カーソル位置の文字を削除 |
| `dd` | 行全体を削除 |
| `dw` | 一単語を削除 |
| `D` | 行末まで削除 |
| `cw` | 一単語を変更 |
| `cc` | 行全体を変更 |
| `r<char>` | 一文字を置き換え |
| `~` | 大文字小文字を切り替え |

### テキストオブジェクト

| キー | 動作 |
|---|---|
| `ciw` | 単語内を変更 |
| `caw` | 一単語を変更（空白込み） |
| `ci"` | ダブルクォート内を変更 |
| `ci'` | シングルクォート内を変更 |
| `ci(` / `ci)` | 括弧内を変更 |
| `di{` | 波括弧内を削除 |

### ビジュアルモード

| キー | 動作 |
|---|---|
| `v` | 文字単位のビジュアルモードに入る |
| `V` | 行単位のビジュアルモードに入る |
| `y` | 選択範囲をコピー |
| `d` | 選択範囲を削除 |
| `c` | 選択範囲を変更 |
| `>` / `<` | インデント |

### 履歴

| キー | 動作 |
|---|---|
| `k` / `j`（ノーマルモード） | 前 / 次の履歴 |
| `↑` / `↓`（挿入モード） | Atuin に任せる（本リポジトリの設定） |
| `/` | 履歴を後方検索 |
| `?` | 履歴を前方検索 |

## モードインジケーター

プラグインはプロンプトに現在のモードを表示できます。本リポジトリでは無効化しており、Starship の `vimcmd_symbol` で間接的に示しています：

```toml
[character]
vimcmd_symbol = "[❯](bold yellow)"
```

ノーマルモードではプロンプトが黄色になり、軽量なモードのヒントになります。

プラグイン独自のインジケーターを使いたい場合：

```zsh
ZVM_MODE_INDICATOR=1
```

## autosuggestions との順序

vi-mode は zsh-autosuggestions の**前**に読み込む必要があります。

理由：autosuggestions は `zle` 内で候補テキストを挿入し、vi-mode はキーマップを再設定します。順序が逆だと、候補を受け入れるキー（既定は `→`）が効かなくなることがあります。

本リポジトリの順序は正しいです：

```zsh
zinit light jeffreytse/zsh-vi-mode
...
zinit light zsh-users/zsh-autosuggestions
```

## トラブルシューティング

**起動時にノーマルモードになる**：`ZVM_LINE_INIT_MODE` が未設定か、プラグインの読み込み後に設定されています。`zinit light` の前に `export` する必要があります。

**上矢印で履歴を検索しない**：`zvm_after_init` が呼ばれていないか、Atuin が入っていません。次で確認します：

```zsh
bindkey '^[[A'
```

**`Esc` が反応しない**：ターミナルや tmux に横取りされている可能性があります。tmux 内では `escape-time` を確認します。

**キーバインドが他のプラグインに上書きされる**：vi-mode が他のプラグインより先に読み込まれているか確認します。`lucid` パラメータは必須です。

**`ciw` などのテキストオブジェクトが動かない**：これらは vi-mode が提供するものです。効かない場合はプラグインが本当に初期化されていません。`zinit list | grep vi-mode` で確認します。
