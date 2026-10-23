> 摘要：zsh-abbr 管的是“输入缩写、展开成完整命令”，比 alias 更适合保留可读的命令历史。

# zsh-abbr

## 它解决什么问题

`alias` 会在命令进入历史之前就替换掉它，事后回看历史时只剩一个短名字。zsh-abbr 的缩写则是在命令行里**可见地展开**：

```text
gco[Space]  →  git checkout
```

完整命令留在输入行，确认后再执行，历史里记录的也是展开后的命令。它适合 Docker、Git、kubectl、ssh 这类又长又重复的命令。

和 `alias` 的区别：

| | alias | abbreviation |
|---|---|---|
| 展开时机 | 解析阶段，用户看不见 | 输入 Space / Enter 时在命令行展开 |
| 历史记录 | 记录短名字 | 记录完整命令 |
| 多词缩写 | 不支持 | 支持，如 `git cp` |
| 临时绕过 | 不适用 | `Ctrl+Space` / `;` |

## 安装与加载

本仓库用 Zinit 加载，并在 clone 后初始化子模块：

```zsh
export ABBR_DEFAULT_BINDINGS=0
export ABBR_USER_ABBREVIATIONS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-abbr/user-abbreviations"

zinit ice atclone"git submodule update --init --recursive" atpull"%atclone"
zinit light olets/zsh-abbr
```

zsh-abbr 的源码依赖 `zsh-job-queue` 子模块，Zinit 默认不会递归拉取，所以必须有 `atclone`。如果看到 “There was a problem finishing installing dependencies”，先检查：

```zsh
git -C ~/.zinit/plugins/olets---zsh-abbr submodule status
```

应该能看到 `zsh-job-queue` 的提交，而不是以 `-` 开头的缺失状态。

`ABBR_DEFAULT_BINDINGS=0` 是有意的：`zsh-vi-mode` 会重置键位表，如果依赖插件默认绑定，缩写键位会被覆盖。本仓库改为显式绑定。

## 键位

| 按键 | 行为 |
|---|---|
| `Space` | 如果光标前是缩写，展开并插入空格 |
| `Enter` | 如果光标前是缩写，展开后执行 |
| `Ctrl+Space` | 不展开，插入一个普通空格 |
| `;` + `Enter` | 绕过展开并执行（适合 `abbr` 命令本身） |

Emacs 键位在 `plugins/abbr/abbr.zsh` 中绑定；viins 键位在 `plugins/zsh-plugins.zsh` 的 `zvm_after_init` 中绑定：

```zsh
zvm_bindkey viins ' ' abbr-expand-and-insert
zvm_bindkey viins '^ ' magic-space
zvm_bindkey viins '^M' abbr-expand-and-accept
```

在 Normal 模式下缩写不展开，先按 `i` 回到 Insert。

## 常用命令

```zsh
# 新增用户级普通缩写（默认作用域）
abbr gco="git checkout"
abbr k="kubectl"
abbr dc="docker compose"

# 多词缩写
abbr "git cp"="git cherry-pick"

# 全局缩写：在命令行任何位置都展开
abbr -g lg="| lazygit"

# 只在当前 shell 生效
abbr -S tmpdir="cd /tmp"

# 查看、展开、删除、重命名
abbr list-abbreviations
abbr expand gco
abbr erase gco
abbr rename gco gch
abbr list-commands

# 重新加载用户缩写文件
abbr load
```

常用参数：

| 参数 | 含义 |
|---|---|
| `-S`, `--session` | 只对当前 shell 生效，退出即消失 |
| `-U`, `--user` | 写入用户文件，所有会话可用（默认） |
| `-g`, `--global` | 不要求出现在命令位置 |
| `-f`, `--force` | 覆盖同名缩写或命令 |
| `--dry-run` | 只显示结果，不写入 |

**注意**：缩写本身不能包含 `!`，这是上游 v6 的限制。

## 作用域与优先级

缩写有四种独立作用域：

1. regular session
2. regular user
3. global session
4. global user

同名时按上面的顺序优先。日常最常用的是 regular user：写在文件里，所有终端共享，但只在命令位置展开。

## 存储与手动编辑

本仓库把用户缩写放在：

```text
~/.config/zsh-abbr/user-abbreviations
```

文件由 `abbr add` / `abbr erase` 维护，也可以手动编辑。格式是每行一个 `abbreviation=expansion`：

```text
gco=git checkout
k=kubectl
dc=docker compose
```

修改后运行 `abbr load`，或新开终端。`ABBR_AUTOLOAD=1` 是默认值，`abbr` 命令执行前会自动检查文件更新。

## 实际例子

```zsh
abbr gc="git commit -m"
abbr gca="git commit --amend --no-edit"
abbr gst="git status --short --branch"
abbr gco="git checkout"
abbr gp="git push"
abbr gpl="git pull --rebase"

abbr dcu="docker compose up -d"
abbr dcd="docker compose down"
abbr dcl="docker compose logs -f"

abbr k="kubectl"
abbr kgp="kubectl get pods -A"
abbr kd="kubectl describe"

abbr tf="terraform"
abbr tfa="terraform apply"
```

组合使用：

```text
gco[Space]main[Enter]     → git checkout main
git cp[Space]abc123       → git cherry-pick abc123
dcu[Space][Enter]         → docker compose up -d
```

## 与历史、长命令编辑的配合

默认历史记录的是展开后的完整命令，这是 zsh-abbr 相对 alias 的主要优势。也可以在初始化前设置：

```zsh
# 展开时把缩写本身也写进历史（默认 0）
ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
# Enter 展开并执行时，额外记录展开前的整行（默认 0）
ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
```

配合本仓库的长命令编辑：

1. 输入缩写并按 `Space` 展开成完整命令；
2. 如果命令太长，按 `Ctrl+X Ctrl+E` 进入 Neovim 继续编辑；
3. 保存退出后回到输入行，确认再按 `Enter`。

不想展开时用 `Ctrl+Space` 代替 `Space`。

## 光标位置

如果希望展开后光标停在参数位置，可以开启：

```zsh
ABBR_SET_EXPANSION_CURSOR=1
```

然后在 expansion 里用 `%` 标记光标：

```zsh
abbr gco="git checkout %"
```

输入 `gco` 再按空格，光标会停在 `git checkout ` 后面。

## 导入已有配置

```zsh
abbr import-aliases        # 把当前 shell alias 导入为缩写
abbr import-git-aliases    # 把 git config alias 导入为缩写
abbr import-fish FILE      # 导入 fish 的 abbr 文件
```

导入前先加 `--dry-run` 检查，避免把已有命令或缩写覆盖。

## 排错

**`abbr: command not found`**：Zinit 没有成功加载。检查 `~/.zinit/plugins/olets---zsh-abbr` 是否存在，以及子模块是否初始化；必要时执行 `zinit update olets/zsh-abbr`。

**Space 不展开**：检查当前模式和绑定：

```zsh
bindkey -M viins ' '
bindkey -M emacs ' '
```

应显示 `abbr-expand-and-insert`。Normal 模式先按 `i`。

**Enter 直接执行了没展开的命令**：检查 `bindkey -M viins '^M'` 是否为 `abbr-expand-and-accept`。

**新缩写对其它终端不生效**：默认 `abbr add` 是用户级，应该会落盘；如果你用了 `-S`，它只在当前 shell 生效。

**补全里看不到 `abbr`**：本仓库的 `plugins/abbr/abbr-completion.zsh` 会在 compinit 后注册 `_abbr`。检查：

```zsh
echo ${_comps[abbr]}
```

应输出 `_abbr`。

## 性能与语法高亮

zsh-abbr 首屏启动开销约 8ms，并随缩写数量线性增加；日常几十条缩写可以忽略。它默认不会像 alias 一样给缩写着色。上游提供 zsh-syntax-highlighting 的正则高亮方案，但对多词缩写和正则元字符有已知限制，本仓库没有默认启用。

<!-- lang:en -->
> Summary: zsh-abbr manages visible, auto-expanding abbreviations—better than aliases when you want readable history.

# zsh-abbr

## What it solves

An `alias` is replaced before the command reaches history, so the history only contains the short name. zsh-abbr expands the abbreviation visibly on the command line:

```text
gco[Space]  →  git checkout
```

The full command stays in the buffer for confirmation, and history records the expanded command. It is a good fit for Docker, Git, kubectl, ssh, and other long, repetitive commands.

| | alias | abbreviation |
|---|---|---|
| When it expands | During parsing, invisibly | On Space / Enter, visibly |
| History | Stores the short name | Stores the full command |
| Multi-word names | No | Yes, e.g. `git cp` |
| Bypass | N/A | `Ctrl+Space` / `;` |

## Install and load

This repo installs it with Zinit and initializes its submodule after cloning:

```zsh
export ABBR_DEFAULT_BINDINGS=0
export ABBR_USER_ABBREVIATIONS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-abbr/user-abbreviations"

zinit ice atclone"git submodule update --init --recursive" atpull"%atclone"
zinit light olets/zsh-abbr
```

zsh-abbr depends on the `zsh-job-queue` submodule, which Zinit does not fetch recursively by default. That is why `atclone` is required. If you see “There was a problem finishing installing dependencies”:

```zsh
git -C ~/.zinit/plugins/olets---zsh-abbr submodule status
```

The `zsh-job-queue` line should show a commit, not a missing entry beginning with `-`.

`ABBR_DEFAULT_BINDINGS=0` is intentional: `zsh-vi-mode` resets the keymaps, so default bindings would be lost. This repo binds the widgets explicitly.

## Keys

| Key | Action |
|---|---|
| `Space` | Expand an abbreviation and insert a space |
| `Enter` | Expand an abbreviation and accept the line |
| `Ctrl+Space` | Do not expand; insert a normal space |
| `;` + `Enter` | Bypass expansion and accept (useful for `abbr` itself) |

Emacs bindings live in `plugins/abbr/abbr.zsh`; viins bindings are registered in `zvm_after_init`:

```zsh
zvm_bindkey viins ' ' abbr-expand-and-insert
zvm_bindkey viins '^ ' magic-space
zvm_bindkey viins '^M' abbr-expand-and-accept
```

Abbreviations do not expand in Normal mode; press `i` first.

## Common commands

```zsh
abbr gco="git checkout"
abbr k="kubectl"
abbr dc="docker compose"
abbr "git cp"="git cherry-pick"
abbr -g lg="| lazygit"
abbr -S tmpdir="cd /tmp"

abbr list-abbreviations
abbr expand gco
abbr erase gco
abbr rename gco gch
abbr list-commands
abbr load
```

| Flag | Meaning |
|---|---|
| `-S`, `--session` | Current shell only |
| `-U`, `--user` | Persist to the user file (default) |
| `-g`, `--global` | Expand outside command position |
| `-f`, `--force` | Override an existing abbreviation/command |
| `--dry-run` | Show the result without writing |

Abbreviations cannot contain `!` in upstream v6.

## Scope and precedence

1. regular session
2. regular user
3. global session
4. global user

Regular user abbreviations are the usual choice: shared across terminals, expanded only in command position.

## Storage

This repo uses:

```text
~/.config/zsh-abbr/user-abbreviations
```

The file is maintained by `abbr add` / `abbr erase`, but you can edit it manually:

```text
gco=git checkout
k=kubectl
dc=docker compose
```

Run `abbr load` after editing. `ABBR_AUTOLOAD=1` (the default) also reloads before `abbr` commands.

## Examples

```zsh
abbr gc="git commit -m"
abbr gca="git commit --amend --no-edit"
abbr gst="git status --short --branch"
abbr gco="git checkout"
abbr gp="git push"
abbr gpl="git pull --rebase"

abbr dcu="docker compose up -d"
abbr dcd="docker compose down"
abbr dcl="docker compose logs -f"

abbr k="kubectl"
abbr kgp="kubectl get pods -A"
abbr kd="kubectl describe"

abbr tf="terraform"
abbr tfa="terraform apply"
```

```text
gco[Space]main[Enter]     → git checkout main
git cp[Space]abc123       → git cherry-pick abc123
dcu[Space][Enter]         → docker compose up -d
```

## History and long-command editing

History records the expanded command by default—the main advantage over aliases. Optional settings:

```zsh
ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
```

With this repo's long-command editing:

1. Type the abbreviation and press `Space` to expand it.
2. Press `Ctrl+X Ctrl+E` to continue editing in Neovim if needed.
3. Save and quit, then press `Enter` to run.

Use `Ctrl+Space` instead of `Space` to bypass expansion.

## Cursor placement

```zsh
ABBR_SET_EXPANSION_CURSOR=1
abbr gco="git checkout %"
```

After expanding `gco`, the cursor is placed where `%` appeared.

## Import

```zsh
abbr import-aliases
abbr import-git-aliases
abbr import-fish FILE
```

Use `--dry-run` first to avoid overwriting commands or abbreviations.

## Troubleshooting

**`abbr: command not found`**: Zinit didn't load it. Check `~/.zinit/plugins/olets---zsh-abbr` and its submodule; run `zinit update olets/zsh-abbr`.

**Space doesn't expand**: check the active mode and bindings:

```zsh
bindkey -M viins ' '
bindkey -M emacs ' '
```

They should show `abbr-expand-and-insert`. Press `i` in Normal mode.

**Enter runs without expanding**: check `bindkey -M viins '^M'`; it should be `abbr-expand-and-accept`.

**New abbreviation is missing in other terminals**: default `abbr add` is user scope and persists; `-S` is session-only.

**No `abbr` completion**: this repo registers it in `plugins/abbr/abbr-completion.zsh` after compinit:

```zsh
echo ${_comps[abbr]}
```

It should print `_abbr`.

## Performance and highlighting

First-prompt overhead is roughly 8ms plus <=0.4ms per abbreviation. zsh-abbr does not color abbreviations like aliases by default. Upstream documents a zsh-syntax-highlighting regexp integration, but it has limitations for multi-word abbreviations and regex metacharacters; this repo does not enable it by default.

<!-- lang:ja -->
> 要約：zsh-abbr は「短く入力して、コマンドライン上で展開する」略語を管理します。履歴に完全なコマンドを残せるため、alias より読みやすくなります。

# zsh-abbr

## 解決する問題

`alias` は履歴に残る前に短い名前に置き換わるため、後から履歴を見ても元のコマンドが分かりません。zsh-abbr はコマンドライン上で**見える形で展開**します：

```text
gco[Space]  →  git checkout
```

展開後の完全なコマンドが入力行に残り、確認してから実行できます。履歴にも展開後のコマンドが記録されます。Docker、Git、kubectl、ssh など、長くて繰り返すコマンドに向いています。

| | alias | abbreviation |
|---|---|---|
| 展開タイミング | 解析時に見えずに置換 | Space / Enter で入力行上に展開 |
| 履歴 | 短い名前 | 完全なコマンド |
| 複数語の名前 | 不可 | 可能（`git cp` など） |
| 一時的な回避 | なし | `Ctrl+Space` / `;` |

## インストールと読み込み

本リポジトリでは Zinit で読み込み、clone 後にサブモジュールを初期化します：

```zsh
export ABBR_DEFAULT_BINDINGS=0
export ABBR_USER_ABBREVIATIONS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/zsh-abbr/user-abbreviations"

zinit ice atclone"git submodule update --init --recursive" atpull"%atclone"
zinit light olets/zsh-abbr
```

zsh-abbr は `zsh-job-queue` サブモジュールに依存しますが、Zinit は既定で再帰的に取得しません。そのため `atclone` が必要です。“There was a problem finishing installing dependencies” が出た場合：

```zsh
git -C ~/.zinit/plugins/olets---zsh-abbr submodule status
```

`zsh-job-queue` の行にコミットが表示され、`-` で始まる欠落状態になっていないことを確認します。

`ABBR_DEFAULT_BINDINGS=0` は意図的です。`zsh-vi-mode` がキーマップをリセットするため、既定のキーバインドは上書きされます。本リポジトリでは明示的にバインドします。

## キー

| キー | 動作 |
|---|---|
| `Space` | 略語を展開してスペースを挿入 |
| `Enter` | 略語を展開して行を実行 |
| `Ctrl+Space` | 展開せず通常のスペースを挿入 |
| `;` + `Enter` | 展開を回避して実行 |

Emacs のバインドは `plugins/abbr/abbr.zsh`、viins のバインドは `zvm_after_init` にあります：

```zsh
zvm_bindkey viins ' ' abbr-expand-and-insert
zvm_bindkey viins '^ ' magic-space
zvm_bindkey viins '^M' abbr-expand-and-accept
```

Normal モードでは展開されないため、先に `i` を押します。

## 主なコマンド

```zsh
abbr gco="git checkout"
abbr k="kubectl"
abbr dc="docker compose"
abbr "git cp"="git cherry-pick"
abbr -g lg="| lazygit"
abbr -S tmpdir="cd /tmp"

abbr list-abbreviations
abbr expand gco
abbr erase gco
abbr rename gco gch
abbr list-commands
abbr load
```

| オプション | 意味 |
|---|---|
| `-S`, `--session` | 現在のシェルだけ |
| `-U`, `--user` | ユーザーファイルに保存（既定） |
| `-g`, `--global` | コマンド位置以外でも展開 |
| `-f`, `--force` | 既存の略語・コマンドを上書き |
| `--dry-run` | 書き込まずに結果を表示 |

上流 v6 では略語に `!` を含められません。

## スコープと優先順位

1. regular session
2. regular user
3. global session
4. global user

通常は regular user を使います。全ターミナルで共有され、コマンド位置だけで展開されます。

## 保存場所

本リポジトリでは次を使います：

```text
~/.config/zsh-abbr/user-abbreviations
```

`abbr add` / `abbr erase` で管理できますが、手動編集も可能です：

```text
gco=git checkout
k=kubectl
dc=docker compose
```

編集後は `abbr load` を実行するか、新しいターミナルを開きます。`ABBR_AUTOLOAD=1` が既定で、`abbr` コマンド前にも自動再読み込みされます。

## 例

```zsh
abbr gc="git commit -m"
abbr gca="git commit --amend --no-edit"
abbr gst="git status --short --branch"
abbr gco="git checkout"
abbr gp="git push"
abbr gpl="git pull --rebase"

abbr dcu="docker compose up -d"
abbr dcd="docker compose down"
abbr dcl="docker compose logs -f"

abbr k="kubectl"
abbr kgp="kubectl get pods -A"
abbr kd="kubectl describe"

abbr tf="terraform"
abbr tfa="terraform apply"
```

```text
gco[Space]main[Enter]     → git checkout main
git cp[Space]abc123       → git cherry-pick abc123
dcu[Space][Enter]         → docker compose up -d
```

## 履歴と長いコマンド編集

既定では展開後の完全なコマンドが履歴に残ります。必要なら次を設定します：

```zsh
ABBR_EXPAND_PUSH_ABBREVIATION_TO_HISTORY=1
ABBR_EXPAND_AND_ACCEPT_PUSH_ABBREVIATED_LINE_TO_HISTORY=1
```

本リポジトリの長いコマンド編集と組み合わせる場合：

1. 略語を入力して `Space` で展開；
2. 長ければ `Ctrl+X Ctrl+E` で Neovim に移る；
3. 保存終了後、入力行に戻って `Enter` で実行。

展開したくないときは `Space` の代わりに `Ctrl+Space` を使います。

## カーソル位置

```zsh
ABBR_SET_EXPANSION_CURSOR=1
abbr gco="git checkout %"
```

`gco` を展開すると `%` の位置にカーソルが置かれます。

## インポート

```zsh
abbr import-aliases
abbr import-git-aliases
abbr import-fish FILE
```

上書きを避けるため、まず `--dry-run` で確認します。

## トラブルシュート

**`abbr: command not found`**：Zinit が読み込めていません。`~/.zinit/plugins/olets---zsh-abbr` とサブモジュールを確認し、`zinit update olets/zsh-abbr` を実行します。

**Space で展開しない**：モードとバインドを確認します：

```zsh
bindkey -M viins ' '
bindkey -M emacs ' '
```

`abbr-expand-and-insert` が表示される必要があります。Normal モードでは `i` を押します。

**Enter で展開されずに実行される**：`bindkey -M viins '^M'` が `abbr-expand-and-accept` か確認します。

**他のターミナルで新しい略語が見えない**：既定の `abbr add` はユーザースコープで保存されます。`-S` は現在のシェルだけです。

**`abbr` の補完が出ない**：本リポジトリでは compinit 後に `plugins/abbr/abbr-completion.zsh` で登録します：

```zsh
echo ${_comps[abbr]}
```

`_abbr` が表示されれば登録済みです。

## 性能とハイライト

最初のプロンプトへの追加コストは約 8ms＋略語ごとに 0.4ms 以下です。zsh-abbr は alias のように略語を色分けしません。上流には zsh-syntax-highlighting の regexp 連携がありますが、複数語の略語や正規表現メタ文字に制限があるため、本リポジトリでは既定で有効にしていません。
