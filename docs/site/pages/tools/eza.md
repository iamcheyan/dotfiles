> 摘要：eza 是 ls 的现代替代，本仓库用它实现 l、ll、la 三个列表别名。

# eza

## 用途

`eza` 是 `ls` 的替代品：彩色输出、文件类型图标、Git 状态列、树状视图、更合理的默认排序。本仓库不安装它（由系统包管理器提供），但检测到之后会定义三个别名。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器，仓库不安装 |
| 检测 | `aliases.conf` 里用 `command -v eza` 判断 |
| 缺失影响 | `l`/`ll`/`la` 三个别名不定义，其它功能不受影响 |

```bash
# Debian / Ubuntu
sudo apt install eza
# Arch
sudo pacman -S eza
# macOS
brew install eza
```

Debian 12 的软件源里没有 eza，需要添加第三方源或用 cargo 安装。装不上就继续用系统 `ls`，本仓库不会因此报错。

## 本仓库定义的别名

```zsh
if command -v eza >/dev/null 2>&1; then
    alias l="eza --icons --group-directories-first --sort=modified --reverse"
    alias ll="eza -lh --icons --group-directories-first --git --sort=modified --reverse"
    alias la="eza -a --icons --group-directories-first --sort=modified --reverse"
fi
```

| 别名 | 展开 |
|---|---|
| `l` | 图标 + 目录优先 + 按修改时间倒序 |
| `ll` | 同上 + 长格式（权限、大小）+ Git 状态 |
| `la` | 同上 + 包含隐藏文件 |

三个都用了 `--sort=modified --reverse`，即**最近修改的排在最上面**。这和 `ls` 默认按名字排序不同，是为了让刚编辑过的文件浮到顶部。

`--group-directories-first` 让目录始终在文件之前，即使文件更新。

## 常用参数

| 参数 | 作用 |
|---|---|
| `-l` | 长格式 |
| `-h` | 人类可读的大小（1K、2M） |
| `-a` | 包含隐藏文件 |
| `-T` / `--tree` | 树状视图 |
| `--level=N` | 树状视图的深度 |
| `--git` | 显示 Git 状态列 |
| `--icons` | 显示文件类型图标 |
| `--group-directories-first` | 目录排在最前 |
| `-s modified` | 按修改时间排序 |
| `-r` | 反转排序 |
| `--time-style=long-iso` | 时间格式 |
| `-1` | 每行一个文件（fzf-tab 预览用这个） |

## 实用例子

```bash
eza -lh --git                      # 长格式 + Git 状态
eza -T --level=2                   # 两层树状
eza -la --time-style=long-iso      # 带完整时间戳
eza --sort=size -l                 # 按大小排序
eza -1 --color=always              # 单列，供 fzf 预览
```

`-1 --color=always` 是 fzf-tab 的 `cd` 预览命令，`--color=always` 不能省，否则管道输出没有颜色。

## 与本仓库其它部分的联动

- `plugins/zsh-plugins.zsh` 里 fzf-tab 的 `cd` 和 `z` 补全预览用 `eza -1 --color=always`，没有 eza 时回退到 `ls -1`。
- fzf-tab 的 `zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}` 依赖 `LS_COLORS`，与 eza 无关，两者可以共存。

## 排错

**`l` 命令不存在**：`command -v eza` 无输出，说明没装。装好后 `exec zsh`。

**图标显示成方框**：终端字体不是 Nerd Font。装 Meslo 后重新选字体。

**`--git` 列不显示**：不在 Git 仓库内，或者 eza 版本太旧不支持该参数。

**排序和预期不符**：`--sort=modified --reverse` 是最近的在前。想要最旧的在前，去掉 `--reverse`。

<!-- lang:en -->
> Summary: eza is a modern ls replacement; this repo uses it to implement the l, ll, and la listing aliases.

# eza

## Purpose

`eza` is a replacement for `ls`: colored output, file type icons, a Git status column, tree views, and more sensible default sorting. This repo does not install it (it comes from the system package manager), but once detected it defines three aliases.

## Source and installation

| Item | Description |
|---|---|
| Source | System package manager; the repo does not install it |
| Detection | `aliases.conf` checks with `command -v eza` |
| Impact when missing | The `l`/`ll`/`la` aliases are not defined; everything else is unaffected |

```bash
# Debian / Ubuntu
sudo apt install eza
# Arch
sudo pacman -S eza
# macOS
brew install eza
```

eza is not in the Debian 12 repositories; you need to add a third-party repo or install via cargo. If it cannot be installed, keep using the system `ls` — this repo will not error out because of it.

## Aliases defined in this repo

```zsh
if command -v eza >/dev/null 2>&1; then
    alias l="eza --icons --group-directories-first --sort=modified --reverse"
    alias ll="eza -lh --icons --group-directories-first --git --sort=modified --reverse"
    alias la="eza -a --icons --group-directories-first --sort=modified --reverse"
fi
```

| Alias | Expansion |
|---|---|
| `l` | Icons + directories first + by modification time, newest shown via reverse order |
| `ll` | Same as above + long format (permissions, size) + Git status |
| `la` | Same as above + hidden files included |

All three use `--sort=modified --reverse`, i.e. **the most recently modified appear at the top**. This differs from `ls`'s default name sorting and exists so recently edited files float to the top.

`--group-directories-first` keeps directories always before files, even when a file is newer.

## Common options

| Option | Action |
|---|---|
| `-l` | Long format |
| `-h` | Human-readable sizes (1K, 2M) |
| `-a` | Include hidden files |
| `-T` / `--tree` | Tree view |
| `--level=N` | Depth of the tree view |
| `--git` | Show the Git status column |
| `--icons` | Show file type icons |
| `--group-directories-first` | Directories listed first |
| `-s modified` | Sort by modification time |
| `-r` | Reverse sort order |
| `--time-style=long-iso` | Time format |
| `-1` | One file per line (used for the fzf-tab preview) |

## Practical examples

```bash
eza -lh --git                      # 长格式 + Git 状态
eza -T --level=2                   # 两层树状
eza -la --time-style=long-iso      # 带完整时间戳
eza --sort=size -l                 # 按大小排序
eza -1 --color=always              # 单列，供 fzf 预览
```

`-1 --color=always` is the fzf-tab `cd` preview command; `--color=always` must not be omitted, otherwise piped output has no color.

## Interaction with other parts of this repo

- In `plugins/zsh-plugins.zsh`, the fzf-tab `cd` and `z` completion previews use `eza -1 --color=always`, falling back to `ls -1` when eza is absent.
- fzf-tab's `zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}` depends on `LS_COLORS` and is unrelated to eza; the two coexist fine.

## Troubleshooting

**`l` command does not exist**: `command -v eza` produced no output, meaning it is not installed. After installing, run `exec zsh`.

**Icons show as boxes**: the terminal font is not a Nerd Font. Install Meslo and reselect the font.

**`--git` column missing**: you are not inside a Git repository, or the eza version is too old to support the flag.

**Sorting does not match expectations**: `--sort=modified --reverse` puts the newest first. For oldest first, drop `--reverse`.

<!-- lang:ja -->
> 要約：eza は ls の現代的な代替で、本リポジトリでは l・ll・la の 3 つのリスト別名の実装に使っています。

# eza

## 用途

`eza` は `ls` の代替です。カラー出力、ファイルタイプのアイコン、Git ステータス列、ツリービュー、より合理的なデフォルトソートを備えます。本リポジトリではインストールせず（システムのパッケージマネージャが提供）、検出できた場合に 3 つの別名を定義します。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | システムのパッケージマネージャ。リポジトリではインストールしない |
| 検出 | `aliases.conf` で `command -v eza` により判定 |
| 欠落時の影響 | `l`/`ll`/`la` の 3 つの別名が定義されない。他の機能には影響なし |

```bash
# Debian / Ubuntu
sudo apt install eza
# Arch
sudo pacman -S eza
# macOS
brew install eza
```

Debian 12 のリポジトリには eza がないため、サードパーティのリポジトリを追加するか cargo でインストールする必要があります。インストールできない場合はシステムの `ls` を使い続けてください。本リポジトリはそれでエラーになりません。

## 本リポジトリが定義する別名

```zsh
if command -v eza >/dev/null 2>&1; then
    alias l="eza --icons --group-directories-first --sort=modified --reverse"
    alias ll="eza -lh --icons --group-directories-first --git --sort=modified --reverse"
    alias la="eza -a --icons --group-directories-first --sort=modified --reverse"
fi
```

| 別名 | 展開 |
|---|---|
| `l` | アイコン + ディレクトリ優先 + 更新時刻の降順 |
| `ll` | 上記 + 長形式（権限・サイズ）+ Git ステータス |
| `la` | 上記 + 隠しファイルを含む |

3 つとも `--sort=modified --reverse` を使っており、**最近変更したものが一番上に来ます**。`ls` のデフォルトである名前順とは異なり、編集したばかりのファイルを上部に浮かせるためです。

`--group-directories-first` は、ファイルの方が新しくても、ディレクトリを常にファイルより前に表示します。

## よく使うオプション

| オプション | 動作 |
|---|---|
| `-l` | 長形式 |
| `-h` | 人間が読みやすいサイズ（1K、2M） |
| `-a` | 隠しファイルを含む |
| `-T` / `--tree` | ツリービュー |
| `--level=N` | ツリービューの深さ |
| `--git` | Git ステータス列を表示 |
| `--icons` | ファイルタイプのアイコンを表示 |
| `--group-directories-first` | ディレクトリを先頭に |
| `-s modified` | 更新時刻でソート |
| `-r` | ソート順を反転 |
| `--time-style=long-iso` | 時刻の書式 |
| `-1` | 1 行に 1 ファイル（fzf-tab のプレビューで使用） |

## 実用的な例

```bash
eza -lh --git                      # 长格式 + Git 状态
eza -T --level=2                   # 两层树状
eza -la --time-style=long-iso      # 带完整时间戳
eza --sort=size -l                 # 按大小排序
eza -1 --color=always              # 单列，供 fzf 预览
```

`-1 --color=always` は fzf-tab の `cd` プレビューコマンドです。`--color=always` は省略できません。省略するとパイプ出力に色が付きません。

## 本リポジトリの他の部分との連携

- `plugins/zsh-plugins.zsh` では、fzf-tab の `cd` と `z` の補完プレビューが `eza -1 --color=always` を使い、eza がない場合は `ls -1` にフォールバックします。
- fzf-tab の `zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}` は `LS_COLORS` に依存しており、eza とは無関係です。両者は共存できます。

## トラブルシューティング

**`l` コマンドが存在しない**：`command -v eza` に出力がない、つまり未インストールです。インストール後に `exec zsh` してください。

**アイコンが四角で表示される**：ターミナルのフォントが Nerd Font ではありません。Meslo をインストールしてフォントを選び直してください。

**`--git` 列が表示されない**：Git リポジトリ内にいないか、eza のバージョンが古くてこのオプションに対応していません。

**ソートが期待と異なる**：`--sort=modified --reverse` は新しいものが先です。古いものを先にしたい場合は `--reverse` を外してください。
