> 摘要：Ctrl+X Ctrl+E 把当前命令行交给 Neovim，Ctrl+O 在命令行中插入换行。

# 长命令编辑

日常最常用的两个入口：

| 按键 | 模式 | 行为 |
|---|---|---|
| `Ctrl+X`、`Ctrl+E` | Insert / Emacs | 把当前命令行放进 `$VISUAL` / `$EDITOR`（本仓库是 Neovim） |
| `Ctrl+O` | Insert / Emacs | 在光标处插入真正的换行，不立即执行命令 |

适合 Docker、`kubectl`、`aws`、`curl`、多行 `for` / `if` 或函数定义。短命令直接在命令行改；长命令按 `Ctrl+X Ctrl+E` 进入 Neovim，保存退出后命令回到 ZLE 输入行，按 Enter 才执行。

## 实现位置

widget 定义在 `plugins/zle/zle.zsh`：

```zsh
autoload -Uz edit-command-line
zle -N edit-command-line

function insert-newline() {
    LBUFFER+=$'\n'
}
zle -N insert-newline

bindkey -M emacs '^X^E' edit-command-line
bindkey -M emacs '^O' insert-newline
bindkey -M viins '^X^E' edit-command-line
bindkey -M viins '^O' insert-newline
```

`zshrc` 在加载 `zsh-vi-mode` **之前** source 这个文件，保证 widget 已经注册。`zsh-vi-mode` 会在初始化时重置 vi 键位，所以 `plugins/zsh-plugins.zsh` 的 `zvm_after_init` 里再补一次：

```zsh
function zvm_after_init() {
  zvm_bindkey viins '^X^E' edit-command-line
  zvm_bindkey viins '^O' insert-newline
}
```

## 用法

编辑一条长命令：

```text
docker run --rm -it -v "$PWD:/app" -e NODE_ENV=production --network host my-image sh
```

按 `Ctrl+X`、`Ctrl+E`，Neovim 打开这条命令。自由换行、修改后保存退出，命令回到输入行等待确认。

插入换行：

```text
for f in *.log; Ctrl+O
  echo "$f"; Ctrl+O
done
```

`Ctrl+O` 插入的是实际换行符，不会执行。普通命令的参数之间仍然不能随意用换行代替空格；需要续行时使用 `\`。

## 验证与排错

检查当前绑定：

```zsh
bindkey -M emacs '^X^E'
bindkey -M emacs '^O'
bindkey -M viins '^X^E'
bindkey -M viins '^O'
```

应显示 `edit-command-line` 和 `insert-newline`。

**Ctrl+O 没反应**：确认当前是 Insert 模式。`zsh-vi-mode` 在 Normal 模式使用 `^X` 等按键，编辑长命令前先按 `i` 回到 Insert。Atuin 搜索窗口里的 `Ctrl+O` 是 Atuin 自己的过滤模式切换，不受 ZLE 绑定影响。

**Ctrl+X Ctrl+E 打开的不是 Neovim**：检查 `echo "$VISUAL" "$EDITOR"`。本仓库优先使用 `nvim`，其次 `vim`，最后 `vi`。

**Shift+Enter / Alt+Enter**：没有默认绑定。不同终端和键盘协议发送的转义序列不同，`Ctrl+O` 是跨终端更可靠的选择。

**`fc` 的区别**：`fc` 会把编辑后的命令直接执行；`Ctrl+X Ctrl+E` 只是把命令放回输入行，仍可检查再执行。

<!-- lang:en -->
> Summary: Ctrl+X Ctrl+E sends the current command line to Neovim; Ctrl+O inserts a newline.

# Editing Long Commands

Two shortcuts cover most long-command editing:

| Key | Mode | Action |
|---|---|---|
| `Ctrl+X`, `Ctrl+E` | Insert / Emacs | Open the current command line in `$VISUAL` / `$EDITOR` (Neovim here) |
| `Ctrl+O` | Insert / Emacs | Insert a real newline at the cursor without running the command |

This is useful for Docker, `kubectl`, `aws`, `curl`, multi-line `for` / `if` blocks, and function definitions. For short commands, edit inline; for long commands press `Ctrl+X Ctrl+E`, edit in Neovim, save and quit, then press Enter to run.

## Where it lives

The widgets are defined in `plugins/zle/zle.zsh`:

```zsh
autoload -Uz edit-command-line
zle -N edit-command-line

function insert-newline() {
    LBUFFER+=$'\n'
}
zle -N insert-newline

bindkey -M emacs '^X^E' edit-command-line
bindkey -M emacs '^O' insert-newline
bindkey -M viins '^X^E' edit-command-line
bindkey -M viins '^O' insert-newline
```

`zshrc` sources this file **before** loading `zsh-vi-mode`, so the widgets exist first. Because `zsh-vi-mode` resets the vi keymaps during initialisation, `zvm_after_init` in `plugins/zsh-plugins.zsh` binds them again:

```zsh
function zvm_after_init() {
  zvm_bindkey viins '^X^E' edit-command-line
  zvm_bindkey viins '^O' insert-newline
}
```

## Usage

Edit a long command:

```text
docker run --rm -it -v "$PWD:/app" -e NODE_ENV=production --network host my-image sh
```

Press `Ctrl+X`, then `Ctrl+E`. Neovim opens the command. Edit, save and quit; the command returns to the ZLE buffer for confirmation.

Insert a newline:

```text
for f in *.log; Ctrl+O
  echo "$f"; Ctrl+O
done
```

`Ctrl+O` inserts a literal newline and does not execute. In normal commands, a newline still separates commands; use `\` when you need a continuation line.

## Verification and troubleshooting

Check the bindings:

```zsh
bindkey -M emacs '^X^E'
bindkey -M emacs '^O'
bindkey -M viins '^X^E'
bindkey -M viins '^O'
```

They should show `edit-command-line` and `insert-newline`.

**Ctrl+O does nothing**: make sure you are in Insert mode. `zsh-vi-mode` uses `^X` and other keys in Normal mode; press `i` first. The `Ctrl+O` inside the Atuin search UI switches Atuin filter modes and is unrelated to the ZLE binding.

**Ctrl+X Ctrl+E doesn't open Neovim**: check `echo "$VISUAL" "$EDITOR"`. This repo prefers `nvim`, then `vim`, then `vi`.

**Shift+Enter / Alt+Enter**: not bound by default. Terminal keyboard protocols encode these differently; `Ctrl+O` is the portable choice.

**Difference from `fc`**: `fc` executes the edited command directly; `Ctrl+X Ctrl+E` only returns it to the prompt for review.

<!-- lang:ja -->
> 要約：Ctrl+X Ctrl+E で現在のコマンドラインを Neovim に渡し、Ctrl+O で改行を挿入します。

# 長いコマンドの編集

長いコマンド編集は主に 2 つのキーで扱えます：

| キー | モード | 動作 |
|---|---|---|
| `Ctrl+X`、`Ctrl+E` | Insert / Emacs | 現在のコマンドラインを `$VISUAL` / `$EDITOR`（本リポジトリでは Neovim）で開く |
| `Ctrl+O` | Insert / Emacs | コマンドを実行せず、カーソル位置に実際の改行を挿入する |

Docker、`kubectl`、`aws`、`curl`、複数行の `for` / `if`、関数定義などに向いています。短いコマンドはそのまま編集し、長い場合は `Ctrl+X Ctrl+E` で Neovim に移り、保存して終了した後に Enter で実行します。

## 実装場所

widget は `plugins/zle/zle.zsh` にあります：

```zsh
autoload -Uz edit-command-line
zle -N edit-command-line

function insert-newline() {
    LBUFFER+=$'\n'
}
zle -N insert-newline

bindkey -M emacs '^X^E' edit-command-line
bindkey -M emacs '^O' insert-newline
bindkey -M viins '^X^E' edit-command-line
bindkey -M viins '^O' insert-newline
```

`zshrc` は `zsh-vi-mode` を読み込む**前に**このファイルを source し、widget を先に登録します。`zsh-vi-mode` は初期化時に vi キーマップをリセットするため、`plugins/zsh-plugins.zsh` の `zvm_after_init` でもう一度バインドします：

```zsh
function zvm_after_init() {
  zvm_bindkey viins '^X^E' edit-command-line
  zvm_bindkey viins '^O' insert-newline
}
```

## 使い方

長いコマンドを編集：

```text
docker run --rm -it -v "$PWD:/app" -e NODE_ENV=production --network host my-image sh
```

`Ctrl+X` の後に `Ctrl+E` を押すと Neovim が開きます。編集して保存終了するとコマンドが入力行に戻り、Enter で実行できます。

改行を挿入：

```text
for f in *.log; Ctrl+O
  echo "$f"; Ctrl+O
done
```

`Ctrl+O` は実際の改行を挿入し、実行はしません。通常のコマンドでは改行はコマンド区切りなので、継続行には `\` を使います。

## 確認とトラブルシュート

現在のバインドを確認：

```zsh
bindkey -M emacs '^X^E'
bindkey -M emacs '^O'
bindkey -M viins '^X^E'
bindkey -M viins '^O'
```

`edit-command-line` と `insert-newline` が表示されれば設定済みです。

**Ctrl+O が効かない**：Insert モードか確認してください。`zsh-vi-mode` の Normal モードでは `^X` などが使われるため、先に `i` を押します。Atuin 検索画面内の `Ctrl+O` は Atuin のフィルタ切り替えで、ZLE のバインドとは無関係です。

**Ctrl+X Ctrl+E で Neovim が開かない**：`echo "$VISUAL" "$EDITOR"` を確認してください。本リポジトリは `nvim`、`vim`、`vi` の順に優先します。

**Shift+Enter / Alt+Enter**：デフォルトではバインドしていません。端末のキーボードプロトコルによって送られるシーケンスが異なるため、`Ctrl+O` の方が移植性の高い選択です。

**`fc` との違い**：`fc` は編集後のコマンドを直接実行します。`Ctrl+X Ctrl+E` は入力行に戻すだけで、確認してから実行できます。
