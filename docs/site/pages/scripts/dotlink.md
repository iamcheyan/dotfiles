> 摘要：dotlink 是本仓库自研的软链接管理器，读取 dotlinkrc 建立映射，覆盖前先备份。

# dotlink

## 用途

`dotlink` 把仓库里的配置文件链接到系统位置。它替代 Chezmoi、GNU Stow 这类工具，只用 bash，无外部依赖。

核心逻辑：读 `dotlink/dotlinkrc` 的 `[link]` 段，每条规则 `源路径:目标路径` 建立一个符号链接。

## 用法

```bash
bash dotlink/dotlink            # 处理全部配置段
bash dotlink/dotlink link       # 只处理 [link]
bash dotlink/dotlink backups    # 只处理 [backups]
bash dotlink/dotlink list       # 展开并显示映射（不修改）
```

`dotlink` 这个命令名由 `aliases.conf` 定义：

```zsh
alias dotlink="bash ${HOME}/dotfiles/dotlink/dotlink"
```

所以装好之后可以直接 `dotlink link`。

## 参数

| 参数 | 作用 |
|---|---|
| 无 | 按 dotlinkrc 里所有段依次处理 |
| `link` | 只建软链接 |
| `backups` | 只做备份 |
| `backups_by_path` | 按路径结构备份 |
| `list` | 列出展开后的映射，不修改任何文件 |
| 其它 | 报错「未知参数」，退出 |

注意 `list` 会实际执行路径展开（包括通配符），但不会创建链接。

## dotlinkrc 格式

```ini
[link]
$HOME/dotfiles/zshrc:$HOME/.zshrc	# zsh 配置文件
$HOME/dotfiles/config/starship/starship.toml:$HOME/.config/starship.toml
$HOME/dotfiles/config/nvim:$HOME/.config/nvim
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

| 部分 | 说明 |
|---|---|
| `[link]` | 段名，决定处理方式 |
| 冒号前 | 源路径，支持 `$HOME` 和通配符 |
| 冒号后 | 目标路径 |
| `#` 之后 | 注释，会被去掉 |

## 覆盖行为

这是最需要理解的部分。处理一条规则时：

```text
目标不存在
  └── 直接创建软链接

目标是软链接，且指向正确
  └── 跳过（幂等）

目标是软链接，但指向别处
  └── 删除旧链接，创建新链接（不备份，因为链接本身没内容）

目标是普通文件/目录
  └── 备份（如果设置了备份目录）→ 删除 → 创建软链接
```

「指向别处的软链接不备份」是合理的：软链接只是指针，删掉不丢数据。但**普通文件/目录会真的被移走**，所以备份机制很关键。

## 备份

```bash
backup_target() {
    local target="$1"
    if [ -n "$DOTLINK_BACKUP_DIR" ] && [ -e "$target" ] && [ ! -L "$target" ]; then
        local rel_path="${target#$HOME/}"
        ...
        cp -r "$target" "$backup_path"
        echo -e "  ${RED}[备份] $target -> $backup_path${NC}"
    fi
}
```

关键条件：`[ -n "$DOTLINK_BACKUP_DIR" ]`。**只有设置了 `DOTLINK_BACKUP_DIR` 环境变量才会备份。**

```bash
export DOTLINK_BACKUP_DIR="$HOME/dotfiles-backup"
bash dotlink/dotlink link
```

不设这个变量时，已有的普通文件/目录会被直接 `rm -rf`。这是首次使用前必须知道的事。

## 通配符规则

```ini
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

处理方式：

1. 取源路径的目录和通配部分
2. `find` 匹配该目录下所有符合的项
3. 对每一项，目标路径用相同文件名
4. 逐个建立链接

代码在 `process_wildcard_pattern` 里。

## Neovim 的特殊处理

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

如果本机有 `~/nvim` 且它的 origin 是这个仓库，就链接 `~/nvim` 而不是 `config/nvim` 子模块。这是给维护者用的：可以直接在 `~/nvim` 开发。

普通用户没有 `~/nvim`，走子模块。

## 子模块预检查

```bash
if [[ "${1:-}" == "link" && -f "$DOTFILES_DIR/.gitmodules" ]] &&
   git -C "$DOTFILES_DIR" config -f .gitmodules --get submodule.config/nvim.path >/dev/null 2>&1; then
    git -C "$DOTFILES_DIR" config submodule.recurse true
    git -C "$DOTFILES_DIR" config fetch.recurseSubmodules on-demand
    if [[ ! -f "$DOTFILES_DIR/config/nvim/init.lua" ]]; then
        git -C "$DOTFILES_DIR" submodule update --init --recursive -- config/nvim || exit 1
    fi
fi
```

执行 `link` 前先检查 `config/nvim/init.lua` 是否存在，不存在就自动初始化子模块。这避免了「链接到一个空目录」的经典问题。

## 安全使用流程

```bash
# 1. 先看会动哪些文件
bash dotlink/dotlink list

# 2. 设置备份目录
export DOTLINK_BACKUP_DIR="$HOME/dotfiles-backup"

# 3. 再执行
bash dotlink/dotlink link

# 4. 核对结果
ls -l ~/.zshrc ~/.config/nvim ~/.config/starship.toml
```

## 排错

**「未知参数」错误**：只接受 `link`、`backups`、`backups_by_path`、`list`，或无参数。

**目标文件被删了没备份**：忘了设 `DOTLINK_BACKUP_DIR`。这是最危险的误用。

**`~/.config/nvim` 是空目录**：子模块没初始化。`git submodule update --init --recursive`。

**通配符规则没生效**：源目录不存在时直接跳过，不报错。确认路径拼写。

**重复执行会怎样**：幂等。已正确的链接跳过，错误的修正。

**`dotlink` 命令找不到**：`aliases.conf` 没加载。用完整路径 `bash ~/dotfiles/dotlink/dotlink`。

<!-- lang:en -->

> Summary: dotlink is this repository's homegrown symlink manager. It reads dotlinkrc to build the mapping and backs up before overwriting.

# dotlink

## Purpose

`dotlink` links the config files in the repository to their system locations. It replaces tools like Chezmoi and GNU Stow, using nothing but bash with no external dependencies.

Core logic: it reads the `[link]` section of `dotlink/dotlinkrc` and creates one symlink per rule, in the form `source path:target path`.

## Usage

```bash
bash dotlink/dotlink            # 处理全部配置段
bash dotlink/dotlink link       # 只处理 [link]
bash dotlink/dotlink backups    # 只处理 [backups]
bash dotlink/dotlink list       # 展开并显示映射（不修改）
```

The `dotlink` command name is defined in `aliases.conf`:

```zsh
alias dotlink="bash ${HOME}/dotfiles/dotlink/dotlink"
```

So once installed, you can run `dotlink link` directly.

## Arguments

| Argument | Effect |
|---|---|
| none | Processes every section in dotlinkrc in order |
| `link` | Creates symlinks only |
| `backups` | Backs up only |
| `backups_by_path` | Backs up preserving the path structure |
| `list` | Expands and shows the mapping without modifying anything |
| anything else | Errors with "unknown argument" and exits |

Note that `list` does perform the actual path expansion (including wildcards), but creates no links.

## dotlinkrc Format

```ini
[link]
$HOME/dotfiles/zshrc:$HOME/.zshrc	# zsh 配置文件
$HOME/dotfiles/config/starship/starship.toml:$HOME/.config/starship.toml
$HOME/dotfiles/config/nvim:$HOME/.config/nvim
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

| Part | Description |
|---|---|
| `[link]` | Section name, which decides how it is processed |
| Before the colon | Source path; supports `$HOME` and wildcards |
| After the colon | Target path |
| After `#` | Comment, which is stripped |

## Overwrite Behavior

This is the part that most needs understanding. When a rule is processed:

```text
目标不存在
  └── 直接创建软链接

目标是软链接，且指向正确
  └── 跳过（幂等）

目标是软链接，但指向别处
  └── 删除旧链接，创建新链接（不备份，因为链接本身没内容）

目标是普通文件/目录
  └── 备份（如果设置了备份目录）→ 删除 → 创建软链接
```

"Not backing up symlinks that point elsewhere" is reasonable: a symlink is just a pointer, and deleting it loses no data. But **regular files/directories really are moved away**, which is why the backup mechanism matters.

## Backup

```bash
backup_target() {
    local target="$1"
    if [ -n "$DOTLINK_BACKUP_DIR" ] && [ -e "$target" ] && [ ! -L "$target" ]; then
        local rel_path="${target#$HOME/}"
        ...
        cp -r "$target" "$backup_path"
        echo -e "  ${RED}[备份] $target -> $backup_path${NC}"
    fi
}
```

The key condition is `[ -n "$DOTLINK_BACKUP_DIR" ]`. **Backups happen only when the `DOTLINK_BACKUP_DIR` environment variable is set.**

```bash
export DOTLINK_BACKUP_DIR="$HOME/dotfiles-backup"
bash dotlink/dotlink link
```

Without that variable, existing regular files/directories are straight-up `rm -rf`'d. This is the thing you must know before first use.

## Wildcard Rules

```ini
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

How it's handled:

1. Split the source path into directory and wildcard parts
2. `find` matches every matching entry under that directory
3. For each entry, the target path uses the same filename
4. Links are created one by one

The code lives in `process_wildcard_pattern`.

## Special Handling for Neovim

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

If the machine has `~/nvim` and its origin is this repository, it links `~/nvim` instead of the `config/nvim` submodule. This is for maintainers: you can develop directly in `~/nvim`.

Regular users don't have `~/nvim` and go through the submodule.

## Submodule Pre-check

```bash
if [[ "${1:-}" == "link" && -f "$DOTFILES_DIR/.gitmodules" ]] &&
   git -C "$DOTFILES_DIR" config -f .gitmodules --get submodule.config/nvim.path >/dev/null 2>&1; then
    git -C "$DOTFILES_DIR" config submodule.recurse true
    git -C "$DOTFILES_DIR" config fetch.recurseSubmodules on-demand
    if [[ ! -f "$DOTFILES_DIR/config/nvim/init.lua" ]]; then
        git -C "$DOTFILES_DIR" submodule update --init --recursive -- config/nvim || exit 1
    fi
fi
```

Before running `link`, it checks whether `config/nvim/init.lua` exists, and initializes the submodule automatically if not. This avoids the classic "symlinked to an empty directory" problem.

## Safe Usage Flow

```bash
# 1. 先看会动哪些文件
bash dotlink/dotlink list

# 2. 设置备份目录
export DOTLINK_BACKUP_DIR="$HOME/dotfiles-backup"

# 3. 再执行
bash dotlink/dotlink link

# 4. 核对结果
ls -l ~/.zshrc ~/.config/nvim ~/.config/starship.toml
```

## Troubleshooting

**"Unknown argument" error**: only `link`, `backups`, `backups_by_path`, `list`, or no argument is accepted.

**A target file was deleted without backup**: you forgot to set `DOTLINK_BACKUP_DIR`. This is the most dangerous misuse.

**`~/.config/nvim` is an empty directory**: the submodule wasn't initialized. Run `git submodule update --init --recursive`.

**A wildcard rule had no effect**: if the source directory doesn't exist, it's skipped silently without an error. Double-check the path spelling.

**What happens on repeated runs**: it's idempotent. Correct links are skipped; wrong ones are fixed.

**`dotlink` command not found**: `aliases.conf` isn't loaded. Use the full path `bash ~/dotfiles/dotlink/dotlink`.

<!-- lang:ja -->

> 要約：dotlink はこのリポジトリ自作のシンボリックリンクマネージャーです。dotlinkrc を読んでマッピングを組み立て、上書きの前にバックアップを取ります。

# dotlink

## 役割

`dotlink` はリポジトリ内の設定ファイルをシステム上の位置にリンクします。Chezmoi や GNU Stow などの道具の代わりになるもので、bash だけで動き外部依存はありません。

中心となるロジック：`dotlink/dotlinkrc` の `[link]` セクションを読み、`ソースパス:ターゲットパス` の 1 行ごとにシンボリックリンクを 1 つ作ります。

## 使い方

```bash
bash dotlink/dotlink            # 处理全部配置段
bash dotlink/dotlink link       # 只处理 [link]
bash dotlink/dotlink backups    # 只处理 [backups]
bash dotlink/dotlink list       # 展开并显示映射（不修改）
```

`dotlink` というコマンド名は `aliases.conf` で定義されています：

```zsh
alias dotlink="bash ${HOME}/dotfiles/dotlink/dotlink"
```

インストール後はそのまま `dotlink link` と打てます。

## 引数

| 引数 | 働き |
|---|---|
| なし | dotlinkrc の全セクションを順に処理 |
| `link` | シンボリックリンクだけ作成 |
| `backups` | バックアップだけ実行 |
| `backups_by_path` | パス構造を保ったままバックアップ |
| `list` | 展開後のマッピングを表示（変更はしない） |
| その他 | 「未知の引数」エラーで終了 |

`list` はパス展開（ワイルドカード含む）を実際に行いますが、リンクは作りません。

## dotlinkrc の形式

```ini
[link]
$HOME/dotfiles/zshrc:$HOME/.zshrc	# zsh 配置文件
$HOME/dotfiles/config/starship/starship.toml:$HOME/.config/starship.toml
$HOME/dotfiles/config/nvim:$HOME/.config/nvim
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

| 部分 | 説明 |
|---|---|
| `[link]` | セクション名。処理方法を決めます |
| コロンの前 | ソースパス。`$HOME` とワイルドカードに対応 |
| コロンの後 | ターゲットパス |
| `#` 以降 | コメント。取り除かれます |

## 上書きの動作

ここが最も理解が必要な部分です。1 つのルールを処理するとき：

```text
目标不存在
  └── 直接创建软链接

目标是软链接，且指向正确
  └── 跳过（幂等）

目标是软链接，但指向别处
  └── 删除旧链接，创建新链接（不备份，因为链接本身没内容）

目标是普通文件/目录
  └── 备份（如果设置了备份目录）→ 删除 → 创建软链接
```

「別の場所を指すシンボリックリンクをバックアップしない」のは合理的です。シンボリックリンクはポインタにすぎず、消してもデータは失われません。しかし**普通のファイルやディレクトリは本当に移動させられる**ので、バックアップ機構が重要になります。

## バックアップ

```bash
backup_target() {
    local target="$1"
    if [ -n "$DOTLINK_BACKUP_DIR" ] && [ -e "$target" ] && [ ! -L "$target" ]; then
        local rel_path="${target#$HOME/}"
        ...
        cp -r "$target" "$backup_path"
        echo -e "  ${RED}[备份] $target -> $backup_path${NC}"
    fi
}
```

ポイントは `[ -n "$DOTLINK_BACKUP_DIR" ]` という条件です。**`DOTLINK_BACKUP_DIR` 環境変数を設定したときだけバックアップされます。**

```bash
export DOTLINK_BACKUP_DIR="$HOME/dotfiles-backup"
bash dotlink/dotlink link
```

この変数を設定しないと、既存の普通のファイルやディレクトリはそのまま `rm -rf` されます。初めて使う前に知っておくべきことです。

## ワイルドカードのルール

```ini
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

処理の流れ：

1. ソースパスをディレクトリ部分とワイルドカード部分に分ける
2. `find` でそのディレクトリ下の一致する項目をすべて列挙する
3. 項目ごとに、ターゲットパスは同じファイル名を使う
4. 1 つずつリンクを作る

コードは `process_wildcard_pattern` にあります。

## Neovim の特殊処理

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

マシンに `~/nvim` があり、その origin がこのリポジトリなら、`config/nvim` サブモジュールの代わりに `~/nvim` へリンクします。メンテナー向けの仕組みで、`~/nvim` で直接開発できます。

普通のユーザーは `~/nvim` を持たないので、サブモジュール側に流れます。

## サブモジュールの事前チェック

```bash
if [[ "${1:-}" == "link" && -f "$DOTFILES_DIR/.gitmodules" ]] &&
   git -C "$DOTFILES_DIR" config -f .gitmodules --get submodule.config/nvim.path >/dev/null 2>&1; then
    git -C "$DOTFILES_DIR" config submodule.recurse true
    git -C "$DOTFILES_DIR" config fetch.recurseSubmodules on-demand
    if [[ ! -f "$DOTFILES_DIR/config/nvim/init.lua" ]]; then
        git -C "$DOTFILES_DIR" submodule update --init --recursive -- config/nvim || exit 1
    fi
fi
```

`link` を実行する前に `config/nvim/init.lua` があるか確認し、なければサブモジュールを自動で初期化します。「空のディレクトリにリンクしてしまう」古典的な問題を避けるためのものです。

## 安全に使う手順

```bash
# 1. 先看会动哪些文件
bash dotlink/dotlink list

# 2. 设置备份目录
export DOTLINK_BACKUP_DIR="$HOME/dotfiles-backup"

# 3. 再执行
bash dotlink/dotlink link

# 4. 核对结果
ls -l ~/.zshrc ~/.config/nvim ~/.config/starship.toml
```

## トラブルシューティング

**「未知の引数」エラー**：`link`、`backups`、`backups_by_path`、`list`、または引数なしのみ受け付けます。

**ターゲットのファイルがバックアップなしで消えた**：`DOTLINK_BACKUP_DIR` の設定を忘れています。最も危険な誤用です。

**`~/.config/nvim` が空のディレクトリ**：サブモジュールが未初期化です。`git submodule update --init --recursive` を実行します。

**ワイルドカードのルールが効かない**：ソースディレクトリが存在しないときは、エラーを出さずにスキップします。パスの綴りを確認してください。

**繰り返し実行するとどうなるか**：冪等です。正しいリンクはスキップし、間違っているものは修正します。

**`dotlink` コマンドが見つからない**：`aliases.conf` が読み込まれていません。フルパスの `bash ~/dotfiles/dotlink/dotlink` を使ってください。
