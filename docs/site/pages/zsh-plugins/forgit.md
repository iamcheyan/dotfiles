> 摘要：forgit 把 Git 的常见操作包装成 fzf 选择器，本仓库用它的短别名做日常操作。

# forgit

## 用途

forgit 是一组 shell 函数，每个函数打开一个 fzf 选择器，选完直接执行对应的 Git 命令。它把「记参数」变成「选条目」。

## 加载方式

```zsh
zsh_plugins_load_main() {
  ...
  zinit light wfxr/forgit
  ...
}
```

在 main 阶段加载，位置在 autosuggestions 之后、syntax-highlighting 之前。

**依赖**：fzf 0.60.0 或更新。版本太旧时 forgit 会报错。

## 命令清单

### 暂存与撤销

| 命令 | 作用 | 底层 |
|---|---|---|
| `ga` | 选文件加入暂存区 | `git add` |
| `grh` | 从暂存区移除 | `git reset HEAD` |
| `grs` | 恢复文件到某次提交 | `git checkout` |
| `gclean` | 清理未跟踪文件 | `git clean` |

### 查看

| 命令 | 作用 |
|---|---|
| `gd` | 浏览文件 diff |
| `glo` | 浏览提交历史 |
| `gss` | 浏览 stash 列表 |

### 分支

| 命令 | 作用 |
|---|---|
| `gcb` | 切换分支 |
| `gsw` | 选择并切换分支 |
| `gbd` | 删除分支 |
| `grb` | 交互式 rebase |

### 提交与补丁

| 命令 | 作用 |
|---|---|
| `gcp` | 选择提交 cherry-pick |
| `gsp` | 选择文件创建 stash |
| `gwt` | 浏览 worktree |
| `gi` | 生成 `.gitignore` 条目 |

## 界面内按键

| 键 | 作用 |
|---|---|
| `Tab` | 标记多个条目 |
| `Enter` | 确认 |
| `?` | 显示/隐藏预览 |
| `Ctrl+/` | 切换预览窗口 |

## 危险命令

以下命令**回车即执行**，没有二次确认：

| 命令 | 风险 |
|---|---|
| `gbd` | 删除分支，未合并提交可能丢失 |
| `gclean` | 删除未跟踪文件，无法恢复 |
| `grs` | 覆盖工作区文件 |
| `grb` | rebase 改写历史，可能冲突 |
| `gcp` | cherry-pick 可能冲突 |
| `grh` | 从暂存区移除（可恢复） |

确认选择内容再按 Enter。

## 自定义 fzf 行为

每个功能有对应的环境变量：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

命名规律：`FORGIT_<功能名>_FZF_OPTS`。

放在 `local/custom.zsh` 里覆盖。

## 别名冲突

forgit 的短命令可能和你的别名撞。两种处理：

```zsh
# 完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 或加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

本仓库没有禁用，所以 `ga`、`gd` 等是生效的。

## 与 lazygit / gitui 的分工

| 工具 | 形态 | 适合 |
|---|---|---|
| forgit | shell 函数 + fzf | 单个操作，快进快出 |
| lazygit | 独立 TUI | 连续多个操作，看全局 |
| gitui | 独立 TUI | 同上，Rust 实现 |

「只想 add 两个文件」用 forgit 最快，「整理提交历史」用 lazygit。

## 实用流程

### 暂存部分文件

```text
$ ga
→ 勾选 file1.lua、file2.md（Tab 多选）
→ Enter
→ 两个文件进暂存区
```

### 查看某个提交改了什么

```text
$ glo
→ 浏览提交列表，右侧预览 diff
→ Enter 查看详情
```

### 从别的分支挑一个提交

```text
$ gcp
→ 选中提交
→ cherry-pick 到当前分支
```

## 排错

**`ga` 等命令不存在**：forgit 没加载。`zinit list | grep forgit` 确认。

**报 fzf 版本太低**：

```bash
fzf --version
```

低于 0.60.0 时用官方安装脚本升级，系统包往往太旧。

**预览空白**：预览依赖 `git diff` 和 bat/less。`command -v bat` 检查。

**在非 Git 目录执行报错**：预期行为，forgit 需要仓库上下文。

**`gclean` 删了想要的文件**：无法恢复。这就是为什么它列在危险命令里。日常先 `git status` 看清楚。

**中文路径显示异常**：fzf 的显示宽度计算问题，不影响实际操作。

<!-- lang:en -->

> Summary: forgit wraps common Git operations into fzf selectors; this repo uses its short aliases for everyday operations.

# forgit

## Purpose

forgit is a set of shell functions, each of which opens an fzf selector and, once you pick, directly runs the corresponding Git command. It turns "remembering arguments" into "picking entries".

## Loading

```zsh
zsh_plugins_load_main() {
  ...
  zinit light wfxr/forgit
  ...
}
```

Loaded in the main stage, after autosuggestions and before syntax-highlighting.

**Dependency**: fzf 0.60.0 or newer. forgit errors out when the version is too old.

## Command list

### Staging and undoing

| Command | Action | Underlying |
|---|---|---|
| `ga` | Pick files to add to the staging area | `git add` |
| `grh` | Remove from the staging area | `git reset HEAD` |
| `grs` | Restore files to a given commit | `git checkout` |
| `gclean` | Clean untracked files | `git clean` |

### Viewing

| Command | Action |
|---|---|
| `gd` | Browse file diffs |
| `glo` | Browse commit history |
| `gss` | Browse the stash list |

### Branches

| Command | Action |
|---|---|
| `gcb` | Switch branches |
| `gsw` | Pick and switch branches |
| `gbd` | Delete branches |
| `grb` | Interactive rebase |

### Commits and patches

| Command | Action |
|---|---|
| `gcp` | Pick commits to cherry-pick |
| `gsp` | Pick files to stash |
| `gwt` | Browse worktrees |
| `gi` | Generate `.gitignore` entries |

## Keys inside the UI

| Key | Action |
|---|---|
| `Tab` | Mark multiple entries |
| `Enter` | Confirm |
| `?` | Show/hide the preview |
| `Ctrl+/` | Toggle the preview window |

## Dangerous commands

The following commands **execute on Enter**, with no second confirmation:

| Command | Risk |
|---|---|
| `gbd` | Deletes branches; unmerged commits may be lost |
| `gclean` | Deletes untracked files, unrecoverable |
| `grs` | Overwrites working-tree files |
| `grb` | rebase rewrites history, may conflict |
| `gcp` | cherry-pick may conflict |
| `grh` | Removes from the staging area (recoverable) |

Confirm the selected entries before pressing Enter.

## Customizing fzf behavior

Each feature has a corresponding environment variable:

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

Naming pattern: `FORGIT_<feature>_FZF_OPTS`.

Put overrides in `local/custom.zsh`.

## Alias conflicts

forgit's short commands may collide with your own aliases. Two ways to handle it:

```zsh
# 完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 或加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

This repo does not disable them, so `ga`, `gd`, etc. are in effect.

## Division of labor with lazygit / gitui

| Tool | Form | Best for |
|---|---|---|
| forgit | shell functions + fzf | Single operations, quick in and out |
| lazygit | Standalone TUI | Multiple operations in a row, seeing the whole picture |
| gitui | Standalone TUI | Same as above, implemented in Rust |

"Just want to add two files" is fastest with forgit; "reorganize commit history" calls for lazygit.

## Practical flows

### Staging some files

```text
$ ga
→ 勾选 file1.lua、file2.md（Tab 多选）
→ Enter
→ 两个文件进暂存区
```

### Seeing what a commit changed

```text
$ glo
→ 浏览提交列表，右侧预览 diff
→ Enter 查看详情
```

### Picking a commit from another branch

```text
$ gcp
→ 选中提交
→ cherry-pick 到当前分支
```

## Troubleshooting

**Commands like `ga` do not exist**: forgit is not loaded. Confirm with `zinit list | grep forgit`.

**fzf version too low reported**:

```bash
fzf --version
```

If below 0.60.0, upgrade with the official install script; system packages are often too old.

**Empty preview**: the preview relies on `git diff` and bat/less. Check with `command -v bat`.

**Error when run outside a Git directory**: expected behavior; forgit needs repository context.

**`gclean` deleted files you wanted**: unrecoverable. That is exactly why it is listed under dangerous commands. Run `git status` first in daily use.

**Chinese paths display incorrectly**: a display-width calculation issue in fzf; actual operations are unaffected.

<!-- lang:ja -->

> 要約：forgit は Git のよく使う操作を fzf セレクターに包み、本リポジトリではその短いエイリアスを日常操作に使います。

# forgit

## 用途

forgit はシェル関数の集合で、各関数は fzf セレクターを開き、選び終えると対応する Git コマンドを直接実行します。「引数を覚える」を「項目を選ぶ」に変えます。

## 読み込み方法

```zsh
zsh_plugins_load_main() {
  ...
  zinit light wfxr/forgit
  ...
}
```

main 段階で読み込まれ、位置は autosuggestions の後、syntax-highlighting の前です。

**依存**：fzf 0.60.0 以降。バージョンが古すぎると forgit はエラーを出します。

## コマンド一覧

### ステージングと取り消し

| コマンド | 動作 | 実体 |
|---|---|---|
| `ga` | ファイルを選んでステージングエリアへ追加 | `git add` |
| `grh` | ステージングエリアから除去 | `git reset HEAD` |
| `grs` | ファイルをあるコミットへ復元 | `git checkout` |
| `gclean` | 未追跡ファイルの掃除 | `git clean` |

### 閲覧

| コマンド | 動作 |
|---|---|
| `gd` | ファイルの diff を閲覧 |
| `glo` | コミット履歴を閲覧 |
| `gss` | stash 一覧を閲覧 |

### ブランチ

| コマンド | 動作 |
|---|---|
| `gcb` | ブランチを切り替え |
| `gsw` | ブランチを選んで切り替え |
| `gbd` | ブランチを削除 |
| `grb` | インタラクティブ rebase |

### コミットとパッチ

| コマンド | 動作 |
|---|---|
| `gcp` | コミットを選んで cherry-pick |
| `gsp` | ファイルを選んで stash 作成 |
| `gwt` | worktree を閲覧 |
| `gi` | `.gitignore` のエントリを生成 |

## UI 内のキー

| キー | 動作 |
|---|---|
| `Tab` | 複数項目をマーク |
| `Enter` | 確定 |
| `?` | プレビューの表示/非表示 |
| `Ctrl+/` | プレビューウィンドウの切り替え |

## 危険なコマンド

次のコマンドは**Enter で即実行**され、二重確認はありません：

| コマンド | リスク |
|---|---|
| `gbd` | ブランチを削除。未マージのコミットが失われる可能性 |
| `gclean` | 未追跡ファイルを削除。復元不可能 |
| `grs` | 作業ツリーのファイルを上書き |
| `grb` | rebase は履歴を書き換え、衝突する可能性 |
| `gcp` | cherry-pick が衝突する可能性 |
| `grh` | ステージングエリアから除去（復元可能） |

選択内容を確認してから Enter を押してください。

## fzf 動作のカスタマイズ

各機能には対応する環境変数があります：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

命名の規則：`FORGIT_<機能名>_FZF_OPTS`。

`local/custom.zsh` に置いて上書きします。

## エイリアスの衝突

forgit の短いコマンドは自分のエイリアスと衝突することがあります。対処は2通り：

```zsh
# 完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 或加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

本リポジトリでは無効化していないため、`ga` や `gd` などが有効です。

## lazygit / gitui との分担

| ツール | 形態 | 向いている場面 |
|---|---|---|
| forgit | シェル関数 + fzf | 単発の操作。素早く入って素早く出る |
| lazygit | 単独 TUI | 連続した複数操作。全体を見る |
| gitui | 単独 TUI | 同上。Rust 実装 |

「2つのファイルを add したいだけ」なら forgit が最速、「コミット履歴を整理する」なら lazygit です。

## 実用的な流れ

### 一部のファイルをステージング

```text
$ ga
→ 勾选 file1.lua、file2.md（Tab 多选）
→ Enter
→ 两个文件进暂存区
```

### あるコミットが何を変えたか見る

```text
$ glo
→ 浏览提交列表，右侧预览 diff
→ Enter 查看详情
```

### 別ブランチからコミットを1つ拾う

```text
$ gcp
→ 选中提交
→ cherry-pick 到当前分支
```

## トラブルシューティング

**`ga` などのコマンドが存在しない**：forgit が読み込まれていません。`zinit list | grep forgit` で確認します。

**fzf のバージョンが古いというエラー**：

```bash
fzf --version
```

0.60.0 未満なら公式のインストールスクリプトでアップグレードします。システムパッケージは往々にして古すぎます。

**プレビューが空白**：プレビューは `git diff` と bat/less に依存します。`command -v bat` で確認します。

**Git ディレクトリ以外で実行するとエラー**：想定内の動作です。forgit にはリポジトリのコンテキストが必要です。

**`gclean` で必要なファイルを消した**：復元できません。危険なコマンドに載っているのはこのためです。日常的には先に `git status` でよく確認します。

**中国語パスの表示が乱れる**：fzf の表示幅計算の問題で、実際の操作には影響しません。
