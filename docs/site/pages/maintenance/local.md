> 摘要：local/ 目录与 aliases 子仓库的正确用法，以及它们与公开配置的边界。

# 私人覆盖

## 三种覆盖机制

| 机制 | 位置 | 被 Git 跟踪 |
|---|---|---|
| `local/` | `~/dotfiles/local/` | 只有 README |
| `~/.config/aliases.conf` | 用户配置目录 | 否（在仓库外） |
| `aliases/` | `~/dotfiles/aliases/` | 独立子仓库 |

## local/

### 加载机制

`zshrc` 末尾：

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
unset dotfiles_local_file
```

`(N.D.)` 是 zsh 通配限定符：

| 限定符 | 含义 |
|---|---|
| `N` | 无匹配时不报错 |
| `D` | 包含以点开头的文件 |
| `.` | 只匹配普通文件（不含目录） |

所以 `local/` 下所有普通文件（含隐藏文件）都会被 source，README.md 除外。

### Git 忽略

`.gitignore`：

```text
/local/
!/local/
/local/*
!/local/README.md
```

效果：

| 路径 | 状态 |
|---|---|
| `local/` | 目录被跟踪 |
| `local/README.md` | 被跟踪 |
| `local/custom.zsh` | 被忽略 |
| `local/.secret` | 被忽略 |

### 用法

```bash
mkdir -p ~/dotfiles/local
$EDITOR ~/dotfiles/local/custom.zsh
```

内容示例：

```zsh
# 个人 alias
alias work='cd ~/projects/work'
alias deploy='./scripts/deploy.sh'

# 环境变量
export PROJECTS_DIR="$HOME/projects"
export EDITOR=nvim

# 覆盖公开配置
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 60%"
bindkey '^R' fzf-history-widget
```

### 为什么最后加载

`local/` 在 `zshrc` 最末尾 source，所以：

- 可以覆盖前面所有 `alias`
- 可以覆盖 `bindkey`
- 可以覆盖 `export` 的变量
- 可以重定义函数

这是有意设计的：私人配置优先级最高。

### 不要放什么

| 内容 | 原因 |
|---|---|
| 密钥、token | 明文文件，容易被误备份/截图 |
| 大段脚本 | 放 `~/.local/bin/` 更合适 |
| 需要版本控制的内容 | 它在 `.gitignore` 里，`git pull` 不会保护它 |

密钥应该放系统钥匙串、密码管理器，或至少 `chmod 600` 的独立文件。

## ~/.config/aliases.conf

### 加载机制

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f "$dotfiles_root/aliases.conf" ]] && source "$dotfiles_root/aliases.conf"
```

顺序：先加载私有的 `~/.config/aliases.conf`，再加载公开的 `aliases.conf`。

**注意顺序**：公开配置在后，会覆盖同名的私有定义。想覆盖公开别名，应该用 `local/`（它最后加载）。

### 为什么存在这个机制

Chezmoi 会创建 `~/.config/aliases.conf` 作为私有扩展点。这样私有内容可以放在 chezmoi 仓库里，通过 chezmoi 部署，不需要污染 dotfiles。

### 与 local/ 的分工

| | `~/.config/aliases.conf` | `local/` |
|---|---|---|
| 位置 | 仓库外 | 仓库内 |
| 管理 | Chezmoi 或手动 | 手动 |
| 加载顺序 | 中 | 最后 |
| 适合 | 私有别名 | 覆盖任何配置 |

## aliases/ 子仓库

### 是什么

`~/dotfiles/aliases/` 是一个**独立的 git 仓库**，有自己的 `.git`。

```bash
cd ~/dotfiles/aliases
git status
git remote -v
```

### 内容

```text
aliases/
├── dev.conf
├── dotfiles.conf
├── git.conf
├── morph.conf
├── rime.conf
├── rsync.conf
├── system.conf
├── tools.conf
├── yazi.conf
├── z.conf
├── zellij.conf
└── scripts/
```

这些是更细分的别名集合，包括一些带个人环境的脚本（比如 `morph.conf` 里的部署脚本、`scripts/claude2kimi/.env`）。

### 重要边界

**`aliases/` 里有 `.env` 文件**：

```text
aliases/scripts/claude2kimi/.env
```

它有独立的 `.gitignore`，且属于私有配置。**不要把这个子仓库的内容复制到公开仓库**，也不要在公开文档里展开它的内容。

### 是否被 zshrc 加载

`zshrc` **不加载** `aliases/` 目录。它只 source：

1. `~/.config/aliases.conf`
2. `$dotfiles_root/aliases.conf`

`aliases/` 需要手动 source，或在 `local/` 里 source：

```zsh
# local/custom.zsh
for f in ~/dotfiles/aliases/*.conf; do
    source "$f"
done
```

## 三种机制的选择

| 需求 | 用哪个 |
|---|---|
| 加个人别名 | `local/custom.zsh` |
| 覆盖公开配置 | `local/` |
| 由 Chezmoi 管理 | `~/.config/aliases.conf` |
| 分主题的大量别名 | `aliases/` + 在 `local/` 里 source |
| 密钥 | 都不用，用密码管理器 |

## 排错

**`local/` 里的配置没生效**：文件名是 `.md`？或者放在了子目录里（`(.)` 只匹配普通文件，不递归）。

**私有别名被覆盖**：`aliases.conf`（公开）在 `~/.config/aliases.conf`（私有）之后加载。用 `local/` 覆盖。

**`aliases/` 里的内容没生效**：它不会被自动加载，需要手动 source。

**`git status` 显示 `local/` 有新文件**：不应该。检查 `.gitignore` 是否完整。

**误把密钥放进 `local/`**：虽然被 Git 忽略，但文件在磁盘明文。移到密码管理器或加密存储。

<!-- lang:en -->

> Summary: The correct use of the local/ directory and the aliases sub-repository, and where their boundary with the public configuration lies.

# Private Overrides

## Three Override Mechanisms

| Mechanism | Location | Tracked by Git |
|---|---|---|
| `local/` | `~/dotfiles/local/` | Only the README |
| `~/.config/aliases.conf` | User configuration directory | No (outside the repository) |
| `aliases/` | `~/dotfiles/aliases/` | Separate sub-repository |

## local/

### Loading mechanism

At the end of `zshrc`:

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
unset dotfiles_local_file
```

`(N.D.)` is a zsh glob qualifier:

| Qualifier | Meaning |
|---|---|
| `N` | No error when there are no matches |
| `D` | Include files starting with a dot |
| `.` | Match only regular files (not directories) |

So every regular file under `local/` (including hidden files) is sourced, except README.md.

### Git ignoring

`.gitignore`:

```text
/local/
!/local/
/local/*
!/local/README.md
```

Effect:

| Path | Status |
|---|---|
| `local/` | Directory is tracked |
| `local/README.md` | Tracked |
| `local/custom.zsh` | Ignored |
| `local/.secret` | Ignored |

### Usage

```bash
mkdir -p ~/dotfiles/local
$EDITOR ~/dotfiles/local/custom.zsh
```

Example content:

```zsh
# 个人 alias
alias work='cd ~/projects/work'
alias deploy='./scripts/deploy.sh'

# 环境变量
export PROJECTS_DIR="$HOME/projects"
export EDITOR=nvim

# 覆盖公开配置
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 60%"
bindkey '^R' fzf-history-widget
```

### Why it is loaded last

`local/` is sourced at the very end of `zshrc`, so:

- It can override every earlier `alias`
- It can override `bindkey`
- It can override variables set with `export`
- It can redefine functions

This is deliberate design: private configuration has the highest priority.

### What not to put there

| Content | Reason |
|---|---|
| Keys, tokens | Plain-text files, easily caught in backups/screenshots |
| Large scripts | `~/.local/bin/` is a better place |
| Content that needs version control | It is in `.gitignore`; `git pull` will not protect it |

Keys should go into the system keychain, a password manager, or at least a separate file with `chmod 600`.

## ~/.config/aliases.conf

### Loading mechanism

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f "$dotfiles_root/aliases.conf" ]] && source "$dotfiles_root/aliases.conf"
```

Order: the private `~/.config/aliases.conf` is loaded first, then the public `aliases.conf`.

**Note the order**: because the public configuration comes second, it overrides private definitions of the same name. To override a public alias, use `local/` (which is loaded last).

### Why this mechanism exists

Chezmoi creates `~/.config/aliases.conf` as a private extension point. This way private content can live in the chezmoi repository, deployed via chezmoi, without polluting dotfiles.

### Division of labor with local/

| | `~/.config/aliases.conf` | `local/` |
|---|---|---|
| Location | Outside the repository | Inside the repository |
| Management | Chezmoi or manual | Manual |
| Load order | Middle | Last |
| Suited for | Private aliases | Overriding anything |

## The aliases/ Sub-Repository

### What it is

`~/dotfiles/aliases/` is an **independent git repository** with its own `.git`.

```bash
cd ~/dotfiles/aliases
git status
git remote -v
```

### Contents

```text
aliases/
├── dev.conf
├── dotfiles.conf
├── git.conf
├── morph.conf
├── rime.conf
├── rsync.conf
├── system.conf
├── tools.conf
├── yazi.conf
├── z.conf
├── zellij.conf
└── scripts/
```

These are more finely divided alias collections, including some scripts tied to the personal environment (for example the deployment scripts in `morph.conf` and `scripts/claude2kimi/.env`).

### An important boundary

**There is a `.env` file in `aliases/`**:

```text
aliases/scripts/claude2kimi/.env
```

It has its own `.gitignore` and belongs to the private configuration. **Do not copy the contents of this sub-repository into the public repository**, and do not expand its contents in public documentation.

### Whether zshrc loads it

`zshrc` **does not load** the `aliases/` directory. It only sources:

1. `~/.config/aliases.conf`
2. `$dotfiles_root/aliases.conf`

`aliases/` must be sourced manually, or sourced from `local/`:

```zsh
# local/custom.zsh
for f in ~/dotfiles/aliases/*.conf; do
    source "$f"
done
```

## Choosing Among the Three Mechanisms

| Need | Which to use |
|---|---|
| Add personal aliases | `local/custom.zsh` |
| Override public configuration | `local/` |
| Managed by Chezmoi | `~/.config/aliases.conf` |
| Many aliases organized by topic | `aliases/` + source it from `local/` |
| Keys | None of these; use a password manager |

## Troubleshooting

**Configuration in `local/` has no effect**: is the filename `.md`? Or was it placed in a subdirectory (`(.)` matches only regular files and does not recurse).

**A private alias gets overridden**: `aliases.conf` (public) is loaded after `~/.config/aliases.conf` (private). Use `local/` to override.

**Content in `aliases/` has no effect**: it is not loaded automatically; you need to source it manually.

**`git status` shows new files in `local/`**: it should not. Check that `.gitignore` is complete.

**Keys were accidentally put in `local/`**: although Git ignores them, the files are plain text on disk. Move them to a password manager or encrypted storage.

<!-- lang:ja -->

> 要約：local/ ディレクトリと aliases サブリポジトリの正しい使い方、および公開設定との境界。

# プライベートな上書き

## 3 つの上書きメカニズム

| メカニズム | 場所 | Git が追跡 |
|---|---|---|
| `local/` | `~/dotfiles/local/` | README のみ |
| `~/.config/aliases.conf` | ユーザー設定ディレクトリ | いいえ（リポジトリ外） |
| `aliases/` | `~/dotfiles/aliases/` | 独立したサブリポジトリ |

## local/

### 読み込みメカニズム

`zshrc` の末尾：

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
unset dotfiles_local_file
```

`(N.D.)` は zsh のグロブ修飾子です：

| 修飾子 | 意味 |
|---|---|
| `N` | マッチがなくてもエラーにしない |
| `D` | ドットで始まるファイルを含める |
| `.` | 通常のファイルのみにマッチ（ディレクトリを除く） |

したがって `local/` 以下のすべての通常ファイル（隠しファイルを含む）が README.md を除いて source されます。

### Git による無視

`.gitignore`：

```text
/local/
!/local/
/local/*
!/local/README.md
```

効果：

| パス | 状態 |
|---|---|
| `local/` | ディレクトリは追跡される |
| `local/README.md` | 追跡される |
| `local/custom.zsh` | 無視される |
| `local/.secret` | 無視される |

### 使い方

```bash
mkdir -p ~/dotfiles/local
$EDITOR ~/dotfiles/local/custom.zsh
```

内容の例：

```zsh
# 个人 alias
alias work='cd ~/projects/work'
alias deploy='./scripts/deploy.sh'

# 环境变量
export PROJECTS_DIR="$HOME/projects"
export EDITOR=nvim

# 覆盖公开配置
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --height 60%"
bindkey '^R' fzf-history-widget
```

### 最後に読み込まれる理由

`local/` は `zshrc` の最も末尾で source されるため：

- それ以前のすべての `alias` を上書きできます
- `bindkey` を上書きできます
- `export` された変数を上書きできます
- 関数を再定義できます

これは意図的な設計です：プライベート設定の優先度が最も高くなります。

### 置くべきでないもの

| 内容 | 理由 |
|---|---|
| 鍵、トークン | 平文ファイルで、誤ってバックアップやスクリーンショットに写りやすい |
| 長いスクリプト | `~/.local/bin/` の方が適切 |
| バージョン管理が必要な内容 | `.gitignore` にあるため、`git pull` はそれを保護しない |

鍵はシステムのキーチェーンやパスワードマネージャー、少なくとも `chmod 600` した独立したファイルに置くべきです。

## ~/.config/aliases.conf

### 読み込みメカニズム

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
[[ -f "$dotfiles_root/aliases.conf" ]] && source "$dotfiles_root/aliases.conf"
```

順序：まずプライベートの `~/.config/aliases.conf` を読み込み、次に公開の `aliases.conf` を読み込みます。

**順序に注意**：公開設定が後なので、同名のプライベートな定義を上書きします。公開エイリアスを上書きしたい場合は `local/`（最後に読み込まれる）を使います。

### このメカニズムが存在する理由

Chezmoi はプライベートな拡張ポイントとして `~/.config/aliases.conf` を作成します。これにより、プライベートな内容を chezmoi リポジトリに置き、chezmoi 経由でデプロイでき、dotfiles を汚染しません。

### local/ との役割分担

| | `~/.config/aliases.conf` | `local/` |
|---|---|---|
| 場所 | リポジトリ外 | リポジトリ内 |
| 管理 | Chezmoi または手動 | 手動 |
| 読み込み順序 | 中 | 最後 |
| 適した用途 | プライベートなエイリアス | あらゆる設定の上書き |

## aliases/ サブリポジトリ

### これは何か

`~/dotfiles/aliases/` は独自の `.git` を持つ**独立した git リポジトリ**です。

```bash
cd ~/dotfiles/aliases
git status
git remote -v
```

### 内容

```text
aliases/
├── dev.conf
├── dotfiles.conf
├── git.conf
├── morph.conf
├── rime.conf
├── rsync.conf
├── system.conf
├── tools.conf
├── yazi.conf
├── z.conf
├── zellij.conf
└── scripts/
```

これらはより細かく分かれたエイリアスのコレクションで、個人環境に紐づくスクリプト（`morph.conf` のデプロイスクリプトや `scripts/claude2kimi/.env` など）を含みます。

### 重要な境界

**`aliases/` には `.env` ファイルがあります**：

```text
aliases/scripts/claude2kimi/.env
```

独立した `.gitignore` があり、プライベート設定に属します。**このサブリポジトリの内容を公開リポジトリにコピーしないでください**。また、公開ドキュメントでその内容を展開しないでください。

### zshrc に読み込まれるか

`zshrc` は `aliases/` ディレクトリを読み込み**ません**。source するのは次の 2 つだけです：

1. `~/.config/aliases.conf`
2. `$dotfiles_root/aliases.conf`

`aliases/` は手動で source するか、`local/` 内で source します：

```zsh
# local/custom.zsh
for f in ~/dotfiles/aliases/*.conf; do
    source "$f"
done
```

## 3 つのメカニズムの選び方

| ニーズ | どれを使うか |
|---|---|
| 個人エイリアスを追加 | `local/custom.zsh` |
| 公開設定を上書き | `local/` |
| Chezmoi で管理 | `~/.config/aliases.conf` |
| テーマ別の大量のエイリアス | `aliases/` + `local/` で source |
| 鍵 | どれも使わず、パスワードマネージャー |

## トラブルシューティング

**`local/` の設定が効かない**：ファイル名が `.md` になっていませんか？またはサブディレクトリに置いていませんか（`.` は通常ファイルのみにマッチし、再帰しません）。

**プライベートなエイリアスが上書きされる**：`aliases.conf`（公開）は `~/.config/aliases.conf`（プライベート）の後に読み込まれます。上書きには `local/` を使います。

**`aliases/` の内容が効かない**：自動では読み込まれません。手動で source する必要があります。

**`git status` で `local/` に新規ファイルが表示される**：あってはなりません。`.gitignore` が完全か確認してください。

**誤って鍵を `local/` に入れた**：Git は無視しますが、ファイルはディスク上に平文であります。パスワードマネージャーか暗号化されたストレージに移動してください。
