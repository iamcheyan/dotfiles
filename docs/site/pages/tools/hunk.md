> 摘要：hunk 是面向代码评审的交互式终端 diff 查看器，带多文件侧栏、AI/Agent 行内批注和 GitHub PR 直连。本仓库用它评审 agent 产出的改动集。

# hunk

## 用途

`hunk` 是一个交互式终端 diff 查看器（基于 OpenTUI），把 diff 从「读」升级成「评审」：

- **多文件评审流** — 侧栏在多个变更文件之间导航，split / unified / 自适应 auto 三种布局。
- **Agent 行内批注** — `a` 键显示 agent 留在代码旁的评审意见；配套 `hunk skill` 供 coding agent 调用。
- **GitHub 直连** — 内置 `hunk gh pr`，不需要装 GitHub CLI 就能开 PR、commit、compare。
- **watch 模式** — 工作区变化时自动重载，适合盯着 agent 干活。
- **鼠标支持** — TUI 里可以直接点击。

本仓库的定位：agent（Hermes、Claude Code、Codex）改完代码后，用 `hunk diff` 评审改动集；diffnav 负责日常 diff 分页，hunk 负责评审会话。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `modem-dev/hunk`（MIT），官网 [hunk.dev](https://www.hunk.dev) |
| 安装器 | `scripts/install/install_hunk.sh`（委托上游 install.sh，SHA-256 校验） |
| 二进制 | `~/.hunk/bin/hunk`（独立二进制，不需要 Node.js） |
| 更新 | `hunk update`（0.20+ 自带自更新） |

```bash
# 一键安装（委托上游 installer）
bash scripts/install/install_hunk.sh

# 或 Homebrew / npm
brew install hunk
npm i -g hunkdiff
```

注意：npm 包名是 `hunkdiff`，不是 `hunk`。npm 安装和独立二进制安装会互相冲突，上游 installer 检测到会要求先移除另一个（`--force` 可跳过）。

## 基本用法

```bash
hunk diff                    # 评审工作区改动（含未跟踪文件）
hunk diff --staged           # 评审已暂存改动
hunk diff --watch            # 工作区变化时自动重载
hunk show                    # 评审最近一次提交
hunk show HEAD~1             # 评审更早的提交
hunk log                     # 交互式历史浏览（管道里输出纯文本）
hunk status                  # 工作区状态与兄弟 worktree（只读）
hunk open README.md          # 完整查看单个文件（带语法高亮）
git diff --no-color | hunk patch -   # 从 stdin 评审 patch
```

## GitHub 集成

```bash
hunk gh pr                   # 打开当前分支对应的 PR
hunk gh pr 123               # 从 origin 推断仓库
hunk gh commit a1b2c3d --repo modem-dev/hunk
hunk gh compare main...feature --repo modem-dev/hunk
```

公开仓库匿名可用；私有仓库需要设置 `GH_TOKEN`（或 `GITHUB_TOKEN`）。

## 与 agent 协作

1. 安装评审 skill：`npx skills add modem-dev/hunk -g --skill hunk-review`。
2. 另一个终端里 `hunk diff` 打开评审会话。
3. 让 agent 用 hunk-review skill 对着这个会话写意见。
4. 在 hunk 里按 `a` 查看 agent 批注（默认隐藏）。

没有 skill 体系的 agent 可以直接运行 `hunk skill show` 按输出操作。

## 设为 git 分页器

```bash
git config --global core.pager "hunk pager"
```

`hunk pager` 是通用 git pager 包装器，遇到 diff 时用 hunk 渲染，其他输出原样透传。

## 常用键位

| 键 | 作用 |
|---|---|
| `a` | 显示 / 隐藏 agent 批注 |
| `Tab` | 切换焦点（侧栏 / diff） |
| `v` | 选择提交范围（log 视图） |
| `i` | 显示隐藏 / gitignore 的条目（open 视图） |
| `e` | 用 `$EDITOR` 编辑当前文件 |
| `q` | 退出 |

## 本仓库的配置

仓库不分发 hunk 配置，保持默认。需要定制时写 `~/.config/hunk/config.toml`：

```toml
theme = "github-dark-default"
mode = "auto"               # auto, split, unified
line_numbers = true
```

## 排错

**`hunk` 命令还是旧版**：系统里可能有 npm 装的旧 `hunkdiff`。`command -v hunk` 确认路径；独立二进制装在 `~/.hunk/bin/hunk`，用 `hunk update` 升级。

**上游 installer 报 conflicting install**：npm 版和二进制版并存。`npm rm -g hunkdiff` 移除 npm 版后重跑 installer（或 installer `--force`）。

**私有仓库打不开**：设置 `GH_TOKEN` 环境变量。

**颜色异常**：`~/.config/hunk/config.toml` 里换 theme，如 `github-dark-default`。

<!-- lang:en -->

> Summary: hunk is an interactive terminal diff viewer for code review, with a multi-file sidebar, inline AI/agent annotations and direct GitHub PR support. This repo uses it to review agent-authored changesets.

# hunk

## Purpose

`hunk` is an interactive terminal diff viewer (built on OpenTUI) that upgrades diffs from reading to reviewing:

- **Multi-file review stream** — a sidebar navigates between changed files; split, unified and responsive auto layouts.
- **Inline agent annotations** — press `a` to show review notes an agent left beside the code; a bundled `hunk skill` lets coding agents participate.
- **Direct GitHub support** — built-in `hunk gh pr` opens PRs, commits and compares without the GitHub CLI.
- **Watch mode** — auto-reloads as the workspace changes, for watching an agent work.
- **Mouse support** — clickable inside the TUI.

Its role in this repo: after an agent (Hermes, Claude Code, Codex) changes code, review the changeset with `hunk diff`; diffnav handles everyday diff paging, hunk handles review sessions.

## Source and install

| Item | Notes |
|---|---|
| Repository | `modem-dev/hunk` (MIT), site [hunk.dev](https://www.hunk.dev) |
| Installer | `scripts/install/install_hunk.sh` (delegates to the upstream install.sh, SHA-256 verified) |
| Binary | `~/.hunk/bin/hunk` (standalone, no Node.js required) |
| Update | `hunk update` (built in since 0.20+) |

```bash
# one-shot install (delegates to the upstream installer)
bash scripts/install/install_hunk.sh

# or Homebrew / npm
brew install hunk
npm i -g hunkdiff
```

Note: the npm package is `hunkdiff`, not `hunk`. An npm install and the standalone binary conflict; the upstream installer detects this and asks to remove the other one first (`--force` skips the check).

## Basic usage

```bash
hunk diff                    # review working-tree changes (incl. untracked files)
hunk diff --staged           # review staged changes
hunk diff --watch            # auto-reload as the working tree changes
hunk show                    # review the latest commit
hunk show HEAD~1             # review an earlier commit
hunk log                     # interactive history (plain text when piped)
hunk status                  # workspace status and sibling worktrees (read-only)
hunk open README.md          # view a single file fully rendered
git diff --no-color | hunk patch -   # review a patch from stdin
```

## GitHub integration

```bash
hunk gh pr                   # open the PR for the current branch
hunk gh pr 123               # infers the repository from origin
hunk gh commit a1b2c3d --repo modem-dev/hunk
hunk gh compare main...feature --repo modem-dev/hunk
```

Public repositories work anonymously; private ones need `GH_TOKEN` (or `GITHUB_TOKEN`).

## Working with agents

1. Install the review skill: `npx skills add modem-dev/hunk -g --skill hunk-review`.
2. Open a review session in another terminal with `hunk diff`.
3. Ask your agent to use the hunk-review skill against that session.
4. Press `a` in hunk to see the agent's notes (hidden by default).

Agents without a skill system can run `hunk skill show` and follow the output.

## Set as the git pager

```bash
git config --global core.pager "hunk pager"
```

`hunk pager` is a general git pager wrapper: diffs render in hunk, everything else passes through.

## Keys

| Key | Effect |
|---|---|
| `a` | show / hide agent annotations |
| `Tab` | switch focus (sidebar / diff) |
| `v` | select a commit range (log view) |
| `i` | show hidden / git-ignored entries (open view) |
| `e` | edit the current file in `$EDITOR` |
| `q` | quit |

## Configuration in this repo

The repo ships no hunk config; defaults hold. To customise, write `~/.config/hunk/config.toml`:

```toml
theme = "github-dark-default"
mode = "auto"               # auto, split, unified
line_numbers = true
```

## Troubleshooting

**`hunk` is an old version**: an npm-installed `hunkdiff` may still shadow it. `command -v hunk` shows which one wins; the standalone binary lives at `~/.hunk/bin/hunk`, upgrade with `hunk update`.

**Upstream installer reports a conflicting install**: the npm and binary copies coexist. `npm rm -g hunkdiff`, then rerun the installer (or pass `--force`).

**Private repositories fail to open**: set the `GH_TOKEN` environment variable.

**Colours look off**: change `theme` in `~/.config/hunk/config.toml`, e.g. `github-dark-default`.

<!-- lang:ja -->

> Summary: hunk はコードレビュー向けの対話型ターミナル diff ビューアー。マルチファイルのサイドバー、AI/エージェントのインライン注釈、GitHub PR への直接対応を持ちます。このリポジトリではエージェントが書いた変更asetのレビューに使います。

# hunk

## 役割

`hunk` は対話型のターミナル diff ビューアー（OpenTUI ベース）で、diff を「読む」から「レビューする」へ引き上げます：

- **マルチファイルのレビューストリーム** — サイドバーで変更ファイル間を移動。split / unified / 自動の auto レイアウト。
- **エージェントのインライン注釈** — `a` キーでエージェントがコード脇に残したレビューコメントを表示。`hunk skill` で coding agent からも利用可能。
- **GitHub 直接入力** — 内蔵の `hunk gh pr` で GitHub CLI なしに PR・コミット・compare を開けます。
- **watch モード** — ワークスペースの変化を自動リロード。エージェントの作業を見張るのに便利。
- **マウス対応** — TUI 内をクリック操作できます。

このリポジトリでの位置づけ：エージェント（Hermes、Claude Code、Codex）がコードを変更したあと、`hunk diff` で変更asetをレビューします。日常の diff ページングは diffnav、レビューセッションは hunk が担います。

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `modem-dev/hunk`（MIT）。公式サイト [hunk.dev](https://www.hunk.dev) |
| インストーラ | `scripts/install/install_hunk.sh`（上流 install.sh に委譲、SHA-256 検証） |
| バイナリ | `~/.hunk/bin/hunk`（スタンドアロン。Node.js 不要） |
| 更新 | `hunk update`（0.20+ で内蔵） |

```bash
# ワンショットインストール（上流 installer に委譲）
bash scripts/install/install_hunk.sh

# または Homebrew / npm
brew install hunk
npm i -g hunkdiff
```

注意：npm パッケージ名は `hunk` ではなく `hunkdiff` です。npm 版とスタンドアロン版は競合するため、上流 installer は検出すると先に片方の削除を求めます（`--force` でスキップ可）。

## 基本的な使い方

```bash
hunk diff                    # 作業ツリーの変更をレビュー（未追跡ファイル込み）
hunk diff --staged           # ステージ済みの変更をレビュー
hunk diff --watch            # 作業ツリーの変化を自動リロード
hunk show                    # 直近のコミットをレビュー
hunk show HEAD~1             # 過去のコミットをレビュー
hunk log                     # 対話式ヒストリ（パイプではテキスト出力）
hunk status                  # ワークスペース状態と兄弟 worktree（読み取り専用）
hunk open README.md          # 1 ファイルを全文表示（シンタックスハイライト付き）
git diff --no-color | hunk patch -   # stdin から patch をレビュー
```

## GitHub 連携

```bash
hunk gh pr                   # 現在のブランチに対応する PR を開く
hunk gh pr 123               # origin からリポジトリを推定
hunk gh commit a1b2c3d --repo modem-dev/hunk
hunk gh compare main...feature --repo modem-dev/hunk
```

公開リポジトリは匿名で利用可能。プライベートは `GH_TOKEN`（または `GITHUB_TOKEN`）が必要です。

## エージェントとの協働

1. レビュー skill を導入：`npx skills add modem-dev/hunk -g --skill hunk-review`。
2. 別ターミナルで `hunk diff` を開いてレビューセッションを作る。
3. エージェントに hunk-review skill を使ってそのセッションへ意見を書かせる。
4. hunk 内で `a` を押すとエージェントの注釈が見える（既定は非表示）。

skill 仕組みのないエージェントは `hunk skill show` の出力に従えば動きます。

## git ページャーに設定する

```bash
git config --global core.pager "hunk pager"
```

`hunk pager` は汎用 git pager ラッパーで、diff だけ hunk が描画し、それ以外は素通しします。

## キー

| キー | 効果 |
|---|---|
| `a` | エージェント注釈の表示 / 非表示 |
| `Tab` | フォーカス切り替え（サイドバー / diff） |
| `v` | コミット範囲を選択（log ビュー） |
| `i` | 隠し / gitignore 対象の表示（open ビュー） |
| `e` | 現在のファイルを `$EDITOR` で編集 |
| `q` | 終了 |

## このリポジトリでの設定

リポジトリは hunk の設定を配布しません。既定値のまま使います。カスタマイズするなら `~/.config/hunk/config.toml` に書きます：

```toml
theme = "github-dark-default"
mode = "auto"               # auto, split, unified
line_numbers = true
```

## トラブルシュート

**`hunk` が古いまま**：npm 版の `hunkdiff` が残っている可能性。`command -v hunk` で実体を確認してください。スタンドアロン版は `~/.hunk/bin/hunk` にあり、`hunk update` で更新します。

**上流 installer が conflicting install を報告**：npm 版とバイナリ版の併存です。`npm rm -g hunkdiff` で npm 版を消してから installer を再実行（または `--force`）。

**プライベートリポジトリが開けない**：`GH_TOKEN` 環境変数を設定してください。

**色が合わない**：`~/.config/hunk/config.toml` で `theme` を変更（例：`github-dark-default`）。
