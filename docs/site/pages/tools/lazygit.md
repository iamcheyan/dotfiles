> 摘要：lazygit 是终端里的 Git 全功能界面，适合连续做多个操作。

# lazygit

## 用途

lazygit 把 Git 的常见操作组织成可键盘导航的面板：文件状态、分支、提交历史、stash。它不替代 Git，而是给你一个看得见全局的界面。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 加载位置 | `plugins/tools/tools.zsh` |

```zsh
zi_cmd jesseduffield/lazygit lazygit
```

## 启动

```bash
lazygit                # 在当前仓库打开
lazygit -p ~/project   # 指定仓库路径
lazygit log            # 启动时聚焦到 log 面板
lazygit branch         # 聚焦分支面板
lazygit status         # 聚焦状态面板
lazygit stash          # 聚焦 stash 面板
```

位置参数可以是 `status`、`branch`、`log`、`stash`，决定打开后光标停在哪。

## 面板结构

```text
┌─ Status ─┬─ Files ──────┬─ Diff ─────────────┐
│          │ M file1.lua  │ - old line         │
│          │ ?? file2.md  │ + new line         │
├──────────┴──────────────┴────────────────────┤
│ Branches / Commits / Stash                   │
└──────────────────────────────────────────────┘
```

左侧是仓库状态（分支、ahead/behind、stash 数），中间是文件列表，右侧是 diff。下方可切换分支、提交、stash 视图。

## 常用按键

| 键 | 作用 |
|---|---|
| `1`–`5` | 切换面板 |
| `↑` / `↓` 或 `j` / `k` | 移动 |
| `Space` | 暂存/取消暂存当前文件 |
| `a` | 暂存全部 |
| `c` | 提交 |
| `A` | 修改最后一次提交 |
| `P` | push |
| `p` | pull |
| `d` | 查看 diff |
| `Enter` | 进入详情 |
| `?` | 帮助（完整键位表） |
| `q` | 退出 |

`?` 是这里最重要的键——lazygit 的键位很多，帮助面板按上下文显示当前可用的操作。

## 常用流程

### 提交一部分改动

1. 在 Files 面板选中文件
2. 按 `Enter` 进入，用 `Space` 逐行/逐块暂存
3. 返回，按 `c` 提交

### 修改最后一次提交

```text
A → 编辑提交信息 → 确认
```

适合「刚提交完发现漏了一个文件」的场景。

### 交互式 rebase

在 Commits 面板选中某个提交，按 `e` 进入 rebase 编辑模式，可 squash、reword、drop。

## 配置文件

```bash
lazygit -c            # 打印默认配置
lazygit -cd           # 打印配置目录路径
```

默认位置：`~/.config/lazygit/config.yml`（Linux）。本仓库没有提供该文件，用上游默认值。

常用自定义：

```yaml
gui:
  theme:
    lightTheme: false
  nerdFontsVersion: "3"
```

## 与 forgit 的分工

| | forgit | lazygit |
|---|---|---|
| 形态 | shell 函数，单个操作 | 独立 TUI，全局视图 |
| 退出后 | 回到 shell | 回到 shell |
| 适合 | 快速 add 一个文件 | 整理提交历史、解决冲突 |

两者都装，按场景选。

## 排错

**`lazygit: command not found`**：Zinit 未下载。`zinit list | grep lazygit` 确认。

**界面乱码**：终端字体不是 Nerd Font，或 `$TERM` 不支持。装 Meslo 并检查 tmux 的 `default-terminal`。

**diff 颜色丢失**：lazygit 调用 `git diff` 时用了 `--color=never`。检查 `git.paging.colorArg` 配置。

**大仓库很慢**：lazygit 要扫描状态。可以在配置里关掉某些自动刷新，或对超大仓库改用 `git status` + forgit。

**在 tmux 里按键冲突**：tmux 的 prefix 可能拦截某些键。用 `Ctrl+B` 后按 `:` 临时发送，或改 tmux 键位。


<!-- lang:en -->

> Summary: lazygit is a full-featured Git interface in the terminal, suited for running several operations in a row.

# lazygit

## Purpose

lazygit organizes Git's common operations into keyboard-navigable panels: file status, branches, commit history, stash. It doesn't replace Git; it gives you an interface where you can see the whole picture.

## Source and install

| Item | Notes |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Loaded in | `plugins/tools/tools.zsh` |

```zsh
zi_cmd jesseduffield/lazygit lazygit
```

## Starting it

```bash
lazygit                # 在当前仓库打开
lazygit -p ~/project   # 指定仓库路径
lazygit log            # 启动时聚焦到 log 面板
lazygit branch         # 聚焦分支面板
lazygit status         # 聚焦状态面板
lazygit stash          # 聚焦 stash 面板
```

The positional argument can be `status`, `branch`, `log` or `stash`, and decides which panel the cursor lands in after startup.

## Panel layout

```text
┌─ Status ─┬─ Files ──────┬─ Diff ─────────────┐
│          │ M file1.lua  │ - old line         │
│          │ ?? file2.md  │ + new line         │
├──────────┴──────────────┴────────────────────┤
│ Branches / Commits / Stash                   │
└──────────────────────────────────────────────┘
```

The left side shows the repository state (branch, ahead/behind, stash count), the middle is the file list, and the right is the diff. The bottom switches between the branch, commit and stash views.

## Key bindings

| Key | Effect |
|---|---|
| `1`–`5` | switch panels |
| `↑` / `↓` or `j` / `k` | move |
| `Space` | stage/unstage the current file |
| `a` | stage everything |
| `c` | commit |
| `A` | amend the last commit |
| `P` | push |
| `p` | pull |
| `d` | view the diff |
| `Enter` | open details |
| `?` | help (full key table) |
| `q` | quit |

`?` is the most important key here — lazygit has a lot of key bindings, and the help panel shows the actions currently available in context.

## Common workflows

### Committing part of the changes

1. Select a file in the Files panel
2. Press `Enter` to enter it, use `Space` to stage line by line / hunk by hunk
3. Go back and press `c` to commit

### Amending the last commit

```text
A → 编辑提交信息 → 确认
```

This fits the scenario of realizing right after committing that you missed a file.

### Interactive rebase

Select a commit in the Commits panel and press `e` to enter rebase edit mode, where you can squash, reword and drop.

## Configuration file

```bash
lazygit -c            # 打印默认配置
lazygit -cd           # 打印配置目录路径
```

Default location: `~/.config/lazygit/config.yml` (Linux). This repository doesn't provide that file; upstream defaults are used.

Common customizations:

```yaml
gui:
  theme:
    lightTheme: false
  nerdFontsVersion: "3"
```

## Division of labor with forgit

| | forgit | lazygit |
|---|---|---|
| Form | shell function, one operation at a time | standalone TUI, global view |
| After quitting | back to the shell | back to the shell |
| Good for | quickly staging a file | tidying commit history, resolving conflicts |

Install both and pick by situation.

## Troubleshooting

**`lazygit: command not found`** — Zinit hasn't downloaded it. Confirm with `zinit list | grep lazygit`.

**Garbled UI** — the terminal font is not a Nerd Font, or `$TERM` isn't supported. Install Meslo and check tmux's `default-terminal`.

**Diff colors missing** — lazygit invokes `git diff` with `--color=never`. Check the `git.paging.colorArg` setting.

**Slow on large repositories** — lazygit has to scan the state. You can turn off some auto-refresh in the config, or use `git status` + forgit for huge repositories.

**Key conflicts inside tmux** — tmux's prefix may intercept some keys. Press `Ctrl+B` then `:` to send them temporarily, or change the tmux bindings.

<!-- lang:ja -->

> 要約：lazygit はターミナルで動く Git のフル機能インターフェースで、複数の操作を続けて行うのに向いています。

# lazygit

## 用途

lazygit は Git のよく使う操作を、キーボードで操作できるペインに整理したものです。扱うのはファイルの状態、ブランチ、コミット履歴、stash です。Git を置き換えるのではなく、全体が見えるインターフェースを提供します。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |
| 読み込み場所 | `plugins/tools/tools.zsh` |

```zsh
zi_cmd jesseduffield/lazygit lazygit
```

## 起動

```bash
lazygit                # 在当前仓库打开
lazygit -p ~/project   # 指定仓库路径
lazygit log            # 启动时聚焦到 log 面板
lazygit branch         # 聚焦分支面板
lazygit status         # 聚焦状态面板
lazygit stash          # 聚焦 stash 面板
```

位置引数には `status`、`branch`、`log`、`stash` を指定でき、起動直後にカーソルがどのペインに置かれるかを決めます。

## ペイン構成

```text
┌─ Status ─┬─ Files ──────┬─ Diff ─────────────┐
│          │ M file1.lua  │ - old line         │
│          │ ?? file2.md  │ + new line         │
├──────────┴──────────────┴────────────────────┤
│ Branches / Commits / Stash                   │
└──────────────────────────────────────────────┘
```

左側はリポジトリの状態（ブランチ、ahead/behind、stash 数）、中央がファイル一覧、右側が diff です。下段ではブランチ・コミット・stash のビューを切り替えられます。

## よく使うキー

| キー | 効果 |
|---|---|
| `1`–`5` | ペインの切り替え |
| `↑` / `↓` または `j` / `k` | 移動 |
| `Space` | 現在のファイルをステージ/アンステージ |
| `a` | すべてステージ |
| `c` | コミット |
| `A` | 直前のコミットを修正 |
| `P` | push |
| `p` | pull |
| `d` | diff を表示 |
| `Enter` | 詳細へ入る |
| `?` | ヘルプ（完全なキー一覧） |
| `q` | 終了 |

`?` はここで最も重要なキーです。lazygit のキーは非常に多く、ヘルプペインはその場のコンテキストで使える操作を表示してくれます。

## よく使うワークフロー

### 変更の一部だけコミットする

1. Files ペインでファイルを選ぶ
2. `Enter` で中に入り、`Space` で行単位/ブロック単位にステージする
3. 戻って `c` でコミットする

### 直前のコミットを修正する

```text
A → 编辑提交信息 → 确认
```

「コミットした直後にファイルを入れ忘れたことに気づいた」という場面に向いています。

### インタラクティブ rebase

Commits ペインでコミットを選び、`e` を押すと rebase の編集モードに入り、squash・reword・drop ができます。

## 設定ファイル

```bash
lazygit -c            # 打印默认配置
lazygit -cd           # 打印配置目录路径
```

デフォルトの場所は `~/.config/lazygit/config.yml`（Linux）です。本リポジトリはこのファイルを提供しておらず、上流のデフォルト値を使います。

よくあるカスタマイズ：

```yaml
gui:
  theme:
    lightTheme: false
  nerdFontsVersion: "3"
```

## forgit との使い分け

| | forgit | lazygit |
|---|---|---|
| 形態 | シェル関数、単発の操作 | 独立した TUI、全体ビュー |
| 終了後 | シェルに戻る | シェルに戻る |
| 向いている場面 | ファイルを手早く add する | コミット履歴の整理、コンフリクト解消 |

両方インストールしておき、場面で選びます。

## トラブルシュート

**`lazygit: command not found`**：Zinit が未ダウンロードです。`zinit list | grep lazygit` で確認します。

**画面が文字化けする**：ターミナルのフォントが Nerd Font でないか、`$TERM` が非対応です。Meslo をインストールし、tmux の `default-terminal` を確認します。

**diff の色が消える**：lazygit が `git diff` を `--color=never` 付きで呼んでいます。`git.paging.colorArg` の設定を確認します。

**大きなリポジトリで遅い**：lazygit は状態をスキャンする必要があります。設定で一部の自動リフレッシュを切るか、超大規模なリポジトリでは `git status` + forgit に切り替えます。

**tmux 内でキーが競合する**：tmux の prefix が一部のキーを横取りすることがあります。`Ctrl+B` の後に `:` で一時的に送るか、tmux のキー設定を変えます。
