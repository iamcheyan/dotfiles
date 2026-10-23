> 摘要：forgit 把 Git 的常见操作接到 fzf 上，提供 ga、gd、glo、gcb 等一组交互命令。

# forgit

## 用途

forgit 是一个 Zsh 插件，把 Git 操作包装成 fzf 选择器。你不用记 `git add -p` 的交互流程，直接 `ga` 选文件；不用记 `git log --graph --oneline`，直接 `glo` 浏览。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit 插件，`plugins/zsh-plugins.zsh` |
| 依赖 | Git、fzf 0.60.0+ |
| 加载位置 | `zsh_plugins_load_main` 阶段 |

```zsh
zinit light wfxr/forgit
```

## 命令列表

### 暂存与撤销

| 命令 | 作用 | 底层 |
|---|---|---|
| `ga` | 选择文件加入暂存区 | `git add` |
| `grh` | 从暂存区移除 | `git reset HEAD` |
| `grs` | 恢复文件到某次提交 | `git checkout` |
| `gclean` | 清理未跟踪文件 | `git clean` |

### 查看

| 命令 | 作用 | 底层 |
|---|---|---|
| `gd` | 浏览文件 diff | `git diff` |
| `glo` | 浏览提交历史 | `git log` |
| `gss` | 浏览 stash 列表 | `git stash list` |

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
| `Enter` | 确认选择 |
| `?` | 显示/隐藏预览 |
| `Ctrl+/` | 切换预览窗口 |

## 危险命令

以下命令会改变仓库状态，回车即执行：

| 命令 | 风险 |
|---|---|
| `gbd` | 删除分支，未合并的提交可能丢失 |
| `gclean` | 删除未跟踪文件，无法恢复 |
| `grh` | 从暂存区移除 |
| `grs` | 覆盖工作区文件 |
| `grb` | rebase 可能产生冲突，改写历史 |
| `gcp` | cherry-pick 可能产生冲突 |

确认选择内容后再回车。forgit 不做二次确认，它信任你的选择。

## 自定义 fzf 行为

每个功能对应一个环境变量：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

命名规律：`FORGIT_<功能名>_FZF_OPTS`。

## 别名冲突

forgit 的短命令可能与你的别名冲突。两种处理：

```zsh
# 方案一：完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 方案二：加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

## 与 lazygit / gitui 的分工

| 工具 | 适合场景 |
|---|---|
| forgit | 单个操作，快进快出，留在当前 shell |
| lazygit | 需要连续做多个操作，看全局状态 |
| gitui | 同上，偏好 Rust 实现 |

forgit 不需要进入另一个界面，适合「只想 add 两个文件」这类小操作。

## 排错

**`ga` 等命令不存在**：forgit 没加载。`zinit list | grep forgit` 确认。

**报 fzf 版本太低**：需要 0.60.0+。`fzf --version` 检查，系统包太旧就用官方安装脚本。

**预览区空白**：预览依赖 `git diff` 和 bat/less。`command -v bat` 确认。

**在非 Git 目录里执行报错**：正常行为，forgit 需要仓库上下文。

**`gclean` 删了想要的文件**：无法恢复。这就是为什么它被列在危险命令里。日常用 `git status` 先看清楚。

<!-- lang:en -->

> Summary: forgit connects common Git operations to fzf, providing a set of interactive commands such as ga, gd, glo, and gcb.

# forgit

## Purpose

forgit is a Zsh plugin that wraps Git operations into fzf selectors. You do not need to memorize the interactive flow of `git add -p`; just run `ga` and pick files. You do not need to memorize `git log --graph --oneline`; just run `glo` and browse.

## Source and Installation

| Item | Description |
|---|---|
| Source | Zinit plugin, `plugins/zsh-plugins.zsh` |
| Dependencies | Git, fzf 0.60.0+ |
| Load point | The `zsh_plugins_load_main` stage |

```zsh
zinit light wfxr/forgit
```

## Command list

### Staging and unstaging

| Command | Action | Underlying |
|---|---|---|
| `ga` | Pick files to stage | `git add` |
| `grh` | Remove from the staging area | `git reset HEAD` |
| `grs` | Restore files to a commit | `git checkout` |
| `gclean` | Clean untracked files | `git clean` |

### Viewing

| Command | Action | Underlying |
|---|---|---|
| `gd` | Browse file diffs | `git diff` |
| `glo` | Browse commit history | `git log` |
| `gss` | Browse the stash list | `git stash list` |

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
| `Enter` | Confirm the selection |
| `?` | Show/hide the preview |
| `Ctrl+/` | Toggle the preview window |

## Dangerous commands

The following commands change repository state and execute the moment you press Enter:

| Command | Risk |
|---|---|
| `gbd` | Deletes branches; unmerged commits may be lost |
| `gclean` | Deletes untracked files; unrecoverable |
| `grh` | Removes from the staging area |
| `grs` | Overwrites working-tree files |
| `grb` | Rebase can cause conflicts and rewrites history |
| `gcp` | Cherry-pick can cause conflicts |

Check the selection before pressing Enter. forgit does not ask for confirmation; it trusts your choice.

## Customizing fzf behavior

Each feature maps to an environment variable:

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

The naming pattern is `FORGIT_<feature>_FZF_OPTS`.

## Alias conflicts

forgit's short commands may clash with your aliases. Two options:

```zsh
# 方案一：完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 方案二：加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

## Division of labor with lazygit / gitui

| Tool | Best for |
|---|---|
| forgit | Single operations, quick in and out, staying in the current shell |
| lazygit | Multiple consecutive operations, watching the global state |
| gitui | Same as above, if you prefer a Rust implementation |

forgit does not require entering another UI, which suits small operations like "just add two files."

## Troubleshooting

**Commands like `ga` do not exist**: forgit is not loaded. Confirm with `zinit list | grep forgit`.

**An error says the fzf version is too low**: 0.60.0+ is required. Check with `fzf --version`; if the system package is too old, use the official install script.

**Blank preview area**: the preview depends on `git diff` and bat/less. Confirm with `command -v bat`.

**Errors when run outside a Git directory**: expected behavior; forgit needs repository context.

**`gclean` deleted files you wanted**: unrecoverable. That is why it is listed under dangerous commands. In daily use, look carefully with `git status` first.

<!-- lang:ja -->

> 要約：forgit は Git のよく使う操作を fzf に接続し、ga、gd、glo、gcb などのインタラクティブコマンドを提供します。

# forgit

## 用途

forgit は Zsh プラグインで、Git 操作を fzf セレクターに包みます。`git add -p` のインタラクティブな流れを覚えなくても `ga` でファイルを選べ、`git log --graph --oneline` を覚えなくても `glo` で閲覧できます。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit プラグイン、`plugins/zsh-plugins.zsh` |
| 依存 | Git、fzf 0.60.0 以上 |
| ロード位置 | `zsh_plugins_load_main` ステージ |

```zsh
zinit light wfxr/forgit
```

## コマンド一覧

### ステージングと取り消し

| コマンド | 動作 | 基底コマンド |
|---|---|---|
| `ga` | ステージに入れるファイルを選択 | `git add` |
| `grh` | ステージから取り除く | `git reset HEAD` |
| `grs` | ファイルをあるコミットへ復元 | `git checkout` |
| `gclean` | 未追跡ファイルを整理 | `git clean` |

### 閲覧

| コマンド | 動作 | 基底コマンド |
|---|---|---|
| `gd` | ファイルの diff を閲覧 | `git diff` |
| `glo` | コミット履歴を閲覧 | `git log` |
| `gss` | stash 一覧を閲覧 | `git stash list` |

### ブランチ

| コマンド | 動作 |
|---|---|
| `gcb` | ブランチを切り替え |
| `gsw` | ブランチを選んで切り替え |
| `gbd` | ブランチを削除 |
| `grb` | 対話的 rebase |

### コミットとパッチ

| コマンド | 動作 |
|---|---|
| `gcp` | cherry-pick するコミットを選択 |
| `gsp` | stash を作るファイルを選択 |
| `gwt` | worktree を閲覧 |
| `gi` | `.gitignore` のエントリを生成 |

## UI 内のキー

| キー | 動作 |
|---|---|
| `Tab` | 複数エントリをマーク |
| `Enter` | 選択を確定 |
| `?` | プレビューの表示/非表示 |
| `Ctrl+/` | プレビューウィンドウの切り替え |

## 危険なコマンド

以下のコマンドはリポジトリの状態を変更し、Enter を押した瞬間に実行されます：

| コマンド | リスク |
|---|---|
| `gbd` | ブランチを削除。未マージのコミットが失われる可能性 |
| `gclean` | 未追跡ファイルを削除。復元不可 |
| `grh` | ステージから取り除く |
| `grs` | ワークツリーのファイルを上書き |
| `grb` | rebase は競合を起こす可能性があり、履歴を書き換える |
| `gcp` | cherry-pick は競合を起こす可能性 |

選択内容を確認してから Enter を押してください。forgit は二重確認をせず、あなたの選択を信頼します。

## fzf の動作カスタマイズ

各機能は環境変数に対応します：

```zsh
export FORGIT_LOG_FZF_OPTS='--height 80% --border'
export FORGIT_ADD_GIT_OPTS='--others --cached --modified'
export FORGIT_DIFF_FZF_OPTS='--preview-window=right:60%'
```

命名規則は `FORGIT_<機能名>_FZF_OPTS` です。

## エイリアスとの衝突

forgit の短いコマンドはあなたのエイリアスと衝突する可能性があります。二つの対処法：

```zsh
# 方案一：完全禁用短别名，只用 forgit:: 前缀
export FORGIT_NO_ALIASES=1

# 方案二：加载前改名
forgit_add=gadd
zinit light wfxr/forgit
```

## lazygit / gitui との使い分け

| ツール | 向いている場面 |
|---|---|
| forgit | 単発の操作。素早く入って出る。現在のシェルに留まる |
| lazygit | 連続した複数操作。全体状態を見たいとき |
| gitui | 同上。Rust 実装が好みの場合 |

forgit は別の画面に入る必要がなく、「ファイルを 2 つ add したいだけ」といった小さな操作に向いています。

## トラブルシューティング

**`ga` などのコマンドが存在しない**：forgit がロードされていません。`zinit list | grep forgit` で確認します。

**fzf のバージョンが低いというエラー**：0.60.0 以上が必要です。`fzf --version` で確認し、システムパッケージが古ければ公式インストールスクリプトを使います。

**プレビュー領域が空白**：プレビューは `git diff` と bat/less に依存します。`command -v bat` で確認します。

**Git ディレクトリ外で実行するとエラー**：正常な動作です。forgit にはリポジトリのコンテキストが必要です。

**`gclean` で必要なファイルを消した**：復元できません。危険なコマンドに挙げられているのはこのためです。日常ではまず `git status` でよく確認します。
