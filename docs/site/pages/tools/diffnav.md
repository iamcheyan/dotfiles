> 摘要：diffnav 是基于 delta 的 git diff 分页器，带 GitHub 风格的文件树、按 hunk 折叠和 PR 视图。本仓库把它作为 delta 之上的图形层。

# diffnav

## 用途

`diffnav` 是一个 git diff 分页器，底层用 `delta` 渲染 diff，在上面加了 GitHub 风格的交互层：

- **文件树** — 左侧列出本次变更的文件，按状态着色，`e` 折叠/展开。
- **按文件浏览** — 在文件树里跳转，不用在长 diff 里翻页。
- **搜索** — 内置搜索面板，跨全部变更内容。
- **PR 支持** — 可以直接接 `gh pr diff` 的输出。

本仓库把它作为 `delta` 的图形层：需要按文件浏览大 diff 时用 `diffnav`，纯管道场景仍用 `delta`。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `dlvhdr/diffnav`（Go，MIT） |
| 安装器 | `scripts/install/install_diffnav.sh` |
| 依赖 | `delta`（渲染引擎，由 `install_delta.sh` 安装） |
| 字体 | 图标需要 Nerd Font（init.sh 已装 Meslo Nerd Font） |
| 二进制 | `~/.local/bin/diffnav`，安装时校验 SHA-256 |

```bash
# 一键安装（含依赖检查）
bash scripts/install/install_diffnav.sh

# 或 Homebrew
brew install dlvhdr/formulae/diffnav
```

安装器从 GitHub Release 下载对应平台的 tarball，校验 SHA-256 后装到 `~/.local/bin`。

## 基本用法

```bash
git diff | diffnav                    # 工作区改动
gh pr diff <url> | diffnav            # PR diff
git diff | diffnav --unified          # 强制单栏视图
git diff | diffnav -s                 # 强制双栏视图
```

## 设为 git diff 分页器

```bash
git config --global pager.diff diffnav
```

设置后 `git diff`、`git show` 的输出都会进 diffnav。想回退时 `git config --global --unset pager.diff`。

## Watch 模式

```bash
diffnav --watch                          # 每 2s 重跑 git diff
diffnav --watch-cmd "git diff --cached" --watch-interval 5s
diffnav --watch-cmd "git diff main..."
```

编辑代码时保持打开，改动自动刷新。

## 常用键位

| 键 | 作用 |
|---|---|
| `↑` / `↓` | 移动 |
| `e` | 折叠 / 展开文件树 |
| `/` | 搜索 |
| `Tab` / `Shift+Tab` | 下一个 / 上一个文件 |
| `-` / `+` | 减少 / 增加上下文行 |
| `q` | 退出 |

## 命令行参数

| 参数 | 作用 |
|---|---|
| `-s` / `--side-by-side` | 强制双栏 |
| `-u` / `--unified` | 强制单栏 |
| `-w` / `--watch` | watch 模式 |
| `--watch-cmd` | watch 模式执行的命令（默认 `git diff`） |
| `--watch-interval` | 刷新间隔（默认 `2s`） |

## 本仓库的配置

仓库不写 diffnav 的配置文件，保持默认（tokyo_night 主题、双栏、文件树展开）。需要定制时写 `~/.config/diffnav/config.yml`：

```yaml
ui:
  sideBySide: true
  fileTreeWidth: 26
  icons: nerd-fonts-status
  theme: tokyo_night
```

## 排错

**图标显示为方块**：终端字体不是 Nerd Font。切到 Meslo Nerd Font（init.sh 已装）。

**启动即报 FATA / 闪退**：`delta` 缺失。运行 `bash scripts/install/install_delta.sh`。

**`git diff` 没进 diffnav**：`pager.diff` 没设。`git config --global pager.diff diffnav`。

**颜色不对**：diffnav 的主题与终端配色不一致时，用 `T` 键在 TUI 里切换主题，或改配置文件里的 `ui.theme`。

<!-- lang:en -->

> Summary: diffnav is a git diff pager built on delta with a GitHub-style file tree, per-hunk folding and PR support. This repo uses it as the graphical layer above delta.

# diffnav

## Purpose

`diffnav` is a git diff pager: `delta` renders the diff underneath, and on top it adds a GitHub-style interaction layer:

- **File tree** — changed files listed on the left, coloured by status, collapsible with `e`.
- **Per-file browsing** — jump between files from the tree instead of paging through one long diff.
- **Search** — a built-in search panel across all changed content.
- **PR support** — pipes straight from `gh pr diff`.

This repo treats it as the graphical layer over `delta`: use `diffnav` when you need to navigate a large diff by file, and plain `delta` for pipe scenarios.

## Source and install

| Item | Notes |
|---|---|
| Repository | `dlvhdr/diffnav` (Go, MIT) |
| Installer | `scripts/install/install_diffnav.sh` |
| Dependency | `delta` (render engine, installed by `install_delta.sh`) |
| Font | icons need a Nerd Font (init.sh installs Meslo Nerd Font) |
| Binary | `~/.local/bin/diffnav`, SHA-256 verified on install |

```bash
# one-shot install (checks dependencies)
bash scripts/install/install_diffnav.sh

# or Homebrew
brew install dlvhdr/formulae/diffnav
```

The installer downloads the platform tarball from GitHub Releases, verifies SHA-256 and installs into `~/.local/bin`.

## Basic usage

```bash
git diff | diffnav                    # working-tree changes
gh pr diff <url> | diffnav            # a PR diff
git diff | diffnav --unified          # force unified view
git diff | diffnav -s                 # force side-by-side
```

## Set as the git diff pager

```bash
git config --global pager.diff diffnav
```

After this, `git diff` and `git show` output goes through diffnav. To undo: `git config --global --unset pager.diff`.

## Watch mode

```bash
diffnav --watch                          # re-run git diff every 2s
diffnav --watch-cmd "git diff --cached" --watch-interval 5s
diffnav --watch-cmd "git diff main..."
```

Keep it open while editing; the display refreshes as you work.

## Keys

| Key | Effect |
|---|---|
| `↑` / `↓` | move |
| `e` | collapse / expand the file tree |
| `/` | search |
| `Tab` / `Shift+Tab` | next / previous file |
| `-` / `+` | less / more context lines |
| `q` | quit |

## Flags

| Flag | Effect |
|---|---|
| `-s` / `--side-by-side` | force side-by-side |
| `-u` / `--unified` | force unified |
| `-w` / `--watch` | watch mode |
| `--watch-cmd` | command to run in watch mode (default `git diff`) |
| `--watch-interval` | refresh interval (default `2s`) |

## Configuration in this repo

The repo ships no diffnav config; defaults hold (tokyo_night theme, side-by-side, file tree open). To customise, write `~/.config/diffnav/config.yml`:

```yaml
ui:
  sideBySide: true
  fileTreeWidth: 26
  icons: nerd-fonts-status
  theme: tokyo_night
```

## Troubleshooting

**Icons show as boxes**: the terminal font is not a Nerd Font. Switch to Meslo Nerd Font (installed by init.sh).

**FATA on launch / instant exit**: `delta` is missing. Run `bash scripts/install/install_delta.sh`.

**`git diff` does not go through diffnav**: `pager.diff` is not set. `git config --global pager.diff diffnav`.

**Colours look wrong**: the diffnav theme does not match your terminal palette. Press `T` inside the TUI to switch themes, or change `ui.theme` in the config file.

<!-- lang:ja -->

> Summary: diffnav は delta を土台にした git diff ページャーで、GitHub 風のファイルツリー・hunk 単位の折りたたみ・PR 対応を持ちます。このリポジトリでは delta の上のグラフィカル層として使います。

# diffnav

## 役割

`diffnav` は git diff ページャーです。下層の `delta` が diff を描画し、その上に GitHub 風の操作層を重ねます：

- **ファイルツリー** — 変更ファイルを左側に一覧。ステータスで色分けされ、`e` で開閉。
- **ファイル単位の閲覧** — 長い diff をページ送りする代わりに、ツリーからファイルへ移動。
- **検索** — 変更内容全体を横断する検索パネルを内蔵。
- **PR 対応** — `gh pr diff` の出力をそのまま受け取れます。

このリポジトリでは delta のグラフィカル層として位置づけます。大きな diff をファイル単位で見たいときは `diffnav`、パイプ処理では従来どおり `delta` を使います。

## 入手とインストール

| 項目 | 説明 |
|---|---|
| リポジトリ | `dlvhdr/diffnav`（Go、MIT） |
| インストーラ | `scripts/install/install_diffnav.sh` |
| 依存 | `delta`（描画エンジン。`install_delta.sh` で導入） |
| フォント | アイコンには Nerd Font が必要（init.sh が Meslo Nerd Font を導入） |
| バイナリ | `~/.local/bin/diffnav`。導入時に SHA-256 検証 |

```bash
# ワンショットインストール（依存チェック付き）
bash scripts/install/install_diffnav.sh

# または Homebrew
brew install dlvhdr/formulae/diffnav
```

インストーラは GitHub Release からプラットフォーム向け tarball を取得し、SHA-256 を検証して `~/.local/bin` に置きます。

## 基本的な使い方

```bash
git diff | diffnav                    # 作業ツリーの変更
gh pr diff <url> | diffnav            # PR の diff
git diff | diffnav --unified          # 統合ビューを強制
git diff | diffnav -s                 # 左右分割を強制
```

## git diff ページャーに設定する

```bash
git config --global pager.diff diffnav
```

設定後は `git diff` や `git show` の出力が diffnav を経由します。戻すには `git config --global --unset pager.diff`。

## Watch モード

```bash
diffnav --watch                          # 2 秒ごとに git diff を再実行
diffnav --watch-cmd "git diff --cached" --watch-interval 5s
diffnav --watch-cmd "git diff main..."
```

編集中に開いたままにしておくと、変更に合わせて表示が更新されます。

## キー

| キー | 効果 |
|---|---|
| `↑` / `↓` | 移動 |
| `e` | ファイルツリーの開閉 |
| `/` | 検索 |
| `Tab` / `Shift+Tab` | 次 / 前のファイル |
| `-` / `+` | コンテキスト行を減らす / 増やす |
| `q` | 終了 |

## フラグ

| フラグ | 効果 |
|---|---|
| `-s` / `--side-by-side` | 左右分割を強制 |
| `-u` / `--unified` | 統合ビューを強制 |
| `-w` / `--watch` | watch モード |
| `--watch-cmd` | watch モードで実行するコマンド（既定 `git diff`） |
| `--watch-interval` | 更新間隔（既定 `2s`） |

## このリポジトリでの設定

リポジトリは diffnav の設定ファイルを配布しません。既定値（tokyo_night テーマ、左右分割、ツリー展開）のまま使います。カスタマイズするなら `~/.config/diffnav/config.yml` に書きます：

```yaml
ui:
  sideBySide: true
  fileTreeWidth: 26
  icons: nerd-fonts-status
  theme: tokyo_night
```

## トラブルシュート

**アイコンが四角になる**：ターミナルのフォントが Nerd Font ではない。Meslo Nerd Font（init.sh が導入済み）に切り替えてください。

**起動時に FATA / 即終了**：`delta` が無い。`bash scripts/install/install_delta.sh` を実行してください。

**`git diff` が diffnav を通らない**：`pager.diff` 未設定。`git config --global pager.diff diffnav` を実行してください。

**色が合わない**：diffnav のテーマとターミナルの配色が不一致。TUI 内で `T` キーでテーマを切り替えるか、設定ファイルの `ui.theme` を変更してください。
