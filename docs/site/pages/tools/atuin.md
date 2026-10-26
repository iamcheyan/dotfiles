> 摘要：Atuin 用 SQLite 存储命令历史，提供增强搜索、统计和可选的跨机同步。

# Atuin

## 用途

Atuin 把 shell 历史从纯文本文件搬进 SQLite 数据库，带来四个能力：结构化查询、按目录/会话过滤、统计、跨机器同步。它同时替换上箭头的历史搜索体验。

本仓库用它作为主要的交互式历史搜索入口。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 优先系统包；系统没有时用 Zinit 下载 release |
| 加载位置 | `plugins/tools/tools.zsh` |
| 配置文件 | `config/atuin/config.toml` → `~/.config/atuin/` |
| 数据文件 | `~/.local/share/atuin/history.db` |

```zsh
# 系统没有 atuin 时的兜底
if ! command -v atuin >/dev/null 2>&1; then
  zinit ice as"command" from"gh-r" bpick"atuin-${atuin_arch}-unknown-linux-gnu.tar.gz" ...
  zinit light atuinsh/atuin
fi
```

优先用系统版本，因为它的更新跟着系统走，不会出现「Zinit 版本和系统版本打架」。

## 初始化

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
```

`atuin init zsh` 注入一个 `precmd` hook，每条命令执行后写入数据库，并绑定上箭头。

## 本仓库的配置

`config/atuin/config.toml` 里显式设置的三项：

```toml
auto_sync = false
update_check = false
enter_accept = true
```

| 设置 | 含义 |
|---|---|
| `auto_sync = false` | 不自动同步到 Atuin 服务器 |
| `update_check = false` | 启动时不检查新版本 |
| `enter_accept = true` | 按 Enter 直接执行选中的命令 |

`auto_sync = false` 是隐私相关的默认值：历史里可能有 token、内部地址、临时命令，不主动上传。

其余配置项全部注释保留，方便按需开启。值得注意的几项：

```toml
# search_mode = "fuzzy"          # prefix / fulltext / fuzzy / skim
# filter_mode = "global"         # global / host / session / directory / workspace
# style = "auto"                 # auto / full / compact
# inline_height = 0              # 0 表示全屏
# secrets_filter = true          # 默认开启，过滤疑似密钥
```

## 基本用法

```bash
atuin search                 # 交互式搜索
atuin search git             # 带初始查询
atuin search --limit 50      # 限制条数
atuin search -i              # 只搜当前目录
atuin stats                  # 使用统计
atuin history list           # 列出全部历史
atuin history last           # 最后一条
atuin doctor                 # 诊断
```

## 搜索界面按键

| 键 | 作用 |
|---|---|
| `↑` / `↓` | 移动选择 |
| `Enter` | 执行（因为 `enter_accept = true`） |
| `Tab` | 把命令放回输入行，继续编辑 |
| `Ctrl+O` | 循环切换过滤模式 |
| `Ctrl+R` | 切换搜索模式 |
| `Esc` | 退出 |

**关键区别**：Enter 直接执行，Tab 才回到命令行。如果想先改再执行，养成按 Tab 的习惯。

## 过滤模式

| 模式 | 范围 |
|---|---|
| `global` | 全部历史 |
| `host` | 当前主机 |
| `session` | 当前 shell 会话 |
| `directory` | 当前目录 |
| `workspace` | 当前 Git 仓库树内 |

按 `Ctrl+O` 循环切换。在项目目录里用 `directory` 模式，能快速找回该项目相关命令。

## 同步（默认关闭）

想启用跨机同步：

```bash
atuin register -u <用户名> -e <邮箱> -p
atuin login -u <用户名> -p
atuin key                    # 打印加密密钥，用于其它机器
atuin sync
```

然后在配置里把 `auto_sync` 改为 `true`。同步是端到端加密的，密钥不上传，但**历史内容会上传到 Atuin 服务器**。启用前确认历史里没有敏感信息。

## 数据维护

```bash
atuin history prune          # 清理旧条目
atuin history delete         # 交互式删除
atuin import auto            # 从其它 shell 历史导入
atuin info                   # 显示数据文件位置和环境变量
```

## 与 Zsh 原生历史的关系

两套存储并存：

| | Zsh 原生 | Atuin |
|---|---|---|
| 文件 | `~/.zsh_history` | `history.db` |
| 写入 | `INC_APPEND_HISTORY` | precmd hook |
| 读取 | `history` 内建 | `atuin search` |

所以 `grep ~/.zsh_history` 找不到最近执行的命令，这是正常的。要导出 Atuin 历史：

```bash
atuin history list --format '{command}' > history.txt
```

## 排错

**上箭头行为不对**：`zvm_after_init` 里的 `zvm_bindkey viins '^[[A' atuin-up-search` 没生效。检查 zsh-vi-mode 是否加载，以及该函数是否被调用。

**`atuin doctor` 报数据库损坏**：备份后重建。`atuin info` 显示数据库路径，改名后重启 shell 会新建。

**`migration 20260224000100 was previously applied but is missing`**：通常是当前运行的 Atuin 版本比曾经打开该数据库的版本旧（例如系统回滚，或 PATH 中选中了旧版）。先检查实际二进制和版本：

```bash
type -a atuin
atuin --version
```

根治方式是升级/切换到包含该 migration 的新版 Atuin，并确保所有 shell 都使用同一个新版本；不要在数据库已被新版升级后回退到旧版。Atuin 18.13.6 及之后版本包含该 migration。若无法升级且需要先恢复 shell，可先备份后移走 `history.db`，再重开 shell让 Atuin 重建。此操作会让原历史暂时不可用，备份保留了恢复机会；不要删除整个 `~/.local/share/atuin` 目录。Atuin 的 shell hook 每条命令都会调用客户端，因此用配置开关自动删除数据库风险较高，本仓库不做无备份的自动重置。

**历史没记录**：precmd hook 没安装。`atuin init zsh` 是否成功执行？`_evalcache` 的缓存文件可能过期，删掉缓存目录重试。

**同步冲突**：多机同时写入时会有冲突。`atuin status` 查看状态，必要时 `atuin sync --force`。

**搜索很慢**：数据库太大。`atuin history prune` 清理，或在配置里限制保留时间。

<!-- lang:en -->
> Summary: Atuin stores command history in SQLite, offering enhanced search, statistics, and optional cross-machine sync.

# Atuin

## Purpose

Atuin moves shell history from plain-text files into a SQLite database, bringing four capabilities: structured queries, filtering by directory/session, statistics, and cross-machine sync. It also replaces the up-arrow history search experience.

This repo uses it as the main interactive history search entry point.

## Source and installation

| Item | Description |
|---|---|
| Source | Prefer the system package; when absent, use Zinit to download a release |
| Load location | `plugins/tools/tools.zsh` |
| Config file | `config/atuin/config.toml` → `~/.config/atuin/` |
| Data file | `~/.local/share/atuin/history.db` |

```zsh
# 系统没有 atuin 时的兜底
if ! command -v atuin >/dev/null 2>&1; then
  zinit ice as"command" from"gh-r" bpick"atuin-${atuin_arch}-unknown-linux-gnu.tar.gz" ...
  zinit light atuinsh/atuin
fi
```

Prefer the system version, because its updates follow the system and the "Zinit version fighting the system version" problem never appears.

## Initialization

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
```

`atuin init zsh` injects a `precmd` hook that writes every executed command into the database and binds the up arrow.

## Configuration in this repo

The three settings explicitly set in `config/atuin/config.toml`:

```toml
auto_sync = false
update_check = false
enter_accept = true
```

| Setting | Meaning |
|---|---|
| `auto_sync = false` | Do not sync automatically to the Atuin server |
| `update_check = false` | Do not check for new versions at startup |
| `enter_accept = true` | Pressing Enter directly executes the selected command |

`auto_sync = false` is a privacy-related default: history may contain tokens, internal addresses, or temporary commands, so nothing is uploaded proactively.

All other settings are kept as comments for easy opt-in. Notable ones:

```toml
# search_mode = "fuzzy"          # prefix / fulltext / fuzzy / skim
# filter_mode = "global"         # global / host / session / directory / workspace
# style = "auto"                 # auto / full / compact
# inline_height = 0              # 0 表示全屏
# secrets_filter = true          # 默认开启，过滤疑似密钥
```

## Basic usage

```bash
atuin search                 # 交互式搜索
atuin search git             # 带初始查询
atuin search --limit 50      # 限制条数
atuin search -i              # 只搜当前目录
atuin stats                  # 使用统计
atuin history list           # 列出全部历史
atuin history last           # 最后一条
atuin doctor                 # 诊断
```

## Keys in the search UI

| Key | Action |
|---|---|
| `↑` / `↓` | Move the selection |
| `Enter` | Execute (because `enter_accept = true`) |
| `Tab` | Put the command back on the input line for further editing |
| `Ctrl+O` | Cycle through filter modes |
| `Ctrl+R` | Switch search mode |
| `Esc` | Quit |

**Key difference**: Enter executes directly; only Tab returns to the command line. If you want to edit before running, build the habit of pressing Tab.

## Filter modes

| Mode | Scope |
|---|---|
| `global` | All history |
| `host` | Current host |
| `session` | Current shell session |
| `directory` | Current directory |
| `workspace` | Inside the current Git repository tree |

Press `Ctrl+O` to cycle through them. Using the `directory` mode inside a project directory lets you quickly rediscover commands related to that project.

## Sync (disabled by default)

To enable cross-machine sync:

```bash
atuin register -u <用户名> -e <邮箱> -p
atuin login -u <用户名> -p
atuin key                    # 打印加密密钥，用于其它机器
atuin sync
```

Then set `auto_sync` to `true` in the config. Sync is end-to-end encrypted and the key is never uploaded, but **history content is uploaded to the Atuin server**. Before enabling it, make sure the history contains nothing sensitive.

## Data maintenance

```bash
atuin history prune          # 清理旧条目
atuin history delete         # 交互式删除
atuin import auto            # 从其它 shell 历史导入
atuin info                   # 显示数据文件位置和环境变量
```

## Relationship with native Zsh history

Two stores coexist:

| | Zsh native | Atuin |
|---|---|---|
| File | `~/.zsh_history` | `history.db` |
| Writes | `INC_APPEND_HISTORY` | precmd hook |
| Reads | `history` builtin | `atuin search` |

So `grep ~/.zsh_history` not finding recently executed commands is normal. To export Atuin history:

```bash
atuin history list --format '{command}' > history.txt
```

## Troubleshooting

**Up-arrow behaves incorrectly**: the `zvm_bindkey viins '^[[A' atuin-up-search` in `zvm_after_init` did not take effect. Check whether zsh-vi-mode is loaded and whether that function is being called.

**`atuin doctor` reports database corruption**: back up and rebuild. `atuin info` shows the database path; rename it and restart the shell to create a new one.

**`migration 20260224000100 was previously applied but is missing`**: this usually means the running Atuin binary is older than the version that previously opened the database (for example, after a system rollback or when PATH selects an older copy). Check the selected binary and version first:

```bash
type -a atuin
atuin --version
```

The durable fix is to upgrade or switch to an Atuin build that includes the migration and make sure every shell uses that same newer version; do not roll back after a newer version has migrated the database. Atuin 18.13.6 and later include this migration. If you cannot upgrade and need to restore the shell, back up and move `history.db`, then open a new shell so Atuin can recreate it. This makes the old history temporarily unavailable; keeping the backup gives you a way to recover it. Do not remove the entire `~/.local/share/atuin` directory. Atuin's shell hook invokes the client for every command, so this repository does not automatically reset the database without a backup.

**History not recorded**: the precmd hook is not installed. Did `atuin init zsh` run successfully? The `_evalcache` cache file may be stale; delete the cache directory and retry.

**Sync conflicts**: multiple machines writing at the same time cause conflicts. Check the state with `atuin status` and use `atuin sync --force` if necessary.

**Search is slow**: the database is too large. Run `atuin history prune` to clean it, or limit the retention period in the config.

<!-- lang:ja -->
> 要約：Atuin はコマンド履歴を SQLite に保存し、強力な検索・統計・オプションのマシン間同期を提供します。

# Atuin

## 用途

Atuin はシェル履歴をプレーンテキストファイルから SQLite データベースへ移し、構造化クエリ・ディレクトリ/セッション単位のフィルタリング・統計・マシン間同期という 4 つの機能をもたらします。上矢印の履歴検索体験も同時に置き換えます。

本リポジトリでは、メインの対話型履歴検索の入口として使用しています。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | 基本はシステムパッケージ。ない場合は Zinit で release をダウンロード |
| 読み込み場所 | `plugins/tools/tools.zsh` |
| 設定ファイル | `config/atuin/config.toml` → `~/.config/atuin/` |
| データファイル | `~/.local/share/atuin/history.db` |

```zsh
# 系统没有 atuin 时的兜底
if ! command -v atuin >/dev/null 2>&1; then
  zinit ice as"command" from"gh-r" bpick"atuin-${atuin_arch}-unknown-linux-gnu.tar.gz" ...
  zinit light atuinsh/atuin
fi
```

システム版を優先します。更新がシステムに追従し、「Zinit 版とシステム版が競合する」事態が起きないためです。

## 初期化

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi
```

`atuin init zsh` は `precmd` フックを注入し、実行された各コマンドをデータベースに書き込み、上矢印をバインドします。

## 本リポジトリの設定

`config/atuin/config.toml` で明示的に設定している 3 項目：

```toml
auto_sync = false
update_check = false
enter_accept = true
```

| 設定 | 意味 |
|---|---|
| `auto_sync = false` | Atuin サーバーへ自動同期しない |
| `update_check = false` | 起動時に新バージョンをチェックしない |
| `enter_accept = true` | Enter で選択したコマンドをそのまま実行する |

`auto_sync = false` はプライバシーに関わるデフォルト値です。履歴にはトークン・内部アドレス・一時的なコマンドが含まれる可能性があるため、自発的にはアップロードしません。

その他の設定項目はすべてコメントのまま保持し、必要に応じて有効化できます。注目すべき項目：

```toml
# search_mode = "fuzzy"          # prefix / fulltext / fuzzy / skim
# filter_mode = "global"         # global / host / session / directory / workspace
# style = "auto"                 # auto / full / compact
# inline_height = 0              # 0 表示全屏
# secrets_filter = true          # 默认开启，过滤疑似密钥
```

## 基本的な使い方

```bash
atuin search                 # 交互式搜索
atuin search git             # 带初始查询
atuin search --limit 50      # 限制条数
atuin search -i              # 只搜当前目录
atuin stats                  # 使用统计
atuin history list           # 列出全部历史
atuin history last           # 最后一条
atuin doctor                 # 诊断
```

## 検索画面のキー操作

| キー | 動作 |
|---|---|
| `↑` / `↓` | 選択を移動 |
| `Enter` | 実行（`enter_accept = true` のため） |
| `Tab` | コマンドを入力行に戻して編集を続ける |
| `Ctrl+O` | フィルタモードを順に切り替え |
| `Ctrl+R` | 検索モードを切り替え |
| `Esc` | 終了 |

**重要な違い**：Enter はそのまま実行し、Tab のときだけコマンドラインに戻ります。実行前に編集したい場合は、Tab を押す習慣をつけてください。

## フィルタモード

| モード | 範囲 |
|---|---|
| `global` | 全履歴 |
| `host` | 現在のホスト |
| `session` | 現在のシェルセッション |
| `directory` | 現在のディレクトリ |
| `workspace` | 現在の Git リポジトリツリー内 |

`Ctrl+O` で順に切り替わります。プロジェクトのディレクトリでは `directory` モードを使うと、そのプロジェクト関連のコマンドを素早く見つけ直せます。

## 同期（デフォルトは無効）

マシン間同期を有効にするには：

```bash
atuin register -u <用户名> -e <邮箱> -p
atuin login -u <用户名> -p
atuin key                    # 打印加密密钥，用于其它机器
atuin sync
```

その後、設定で `auto_sync` を `true` に変更します。同期はエンドツーエンドで暗号化され、鍵はアップロードされませんが、**履歴の内容は Atuin サーバーにアップロードされます**。有効化する前に、履歴に機密情報が含まれていないか確認してください。

## データのメンテナンス

```bash
atuin history prune          # 清理旧条目
atuin history delete         # 交互式删除
atuin import auto            # 从其它 shell 历史导入
atuin info                   # 显示数据文件位置和环境变量
```

## Zsh ネイティブ履歴との関係

2 つのストレージが併存します：

| | Zsh ネイティブ | Atuin |
|---|---|---|
| ファイル | `~/.zsh_history` | `history.db` |
| 書き込み | `INC_APPEND_HISTORY` | precmd フック |
| 読み取り | `history` ビルトイン | `atuin search` |

そのため、`grep ~/.zsh_history` で最近実行したコマンドが見つからないのは正常です。Atuin の履歴をエクスポートするには：

```bash
atuin history list --format '{command}' > history.txt
```

## トラブルシューティング

**上矢印の挙動がおかしい**：`zvm_after_init` 内の `zvm_bindkey viins '^[[A' atuin-up-search` が効いていません。zsh-vi-mode が読み込まれているか、その関数が呼び出されているか確認してください。

**`atuin doctor` がデータベース破損を報告**：バックアップしてから再構築します。`atuin info` でデータベースのパスが表示され、リネームしてシェルを再起動すると新しく作成されます。

**履歴が記録されない**：precmd フックがインストールされていません。`atuin init zsh` は正常に実行されましたか？ `_evalcache` のキャッシュファイルが古くなっている可能性があるため、キャッシュディレクトリを削除して再試行してください。

**同期の競合**：複数マシンから同時に書き込むと競合が発生します。`atuin status` で状態を確認し、必要に応じて `atuin sync --force` を使います。

**検索が遅い**：データベースが大きすぎます。`atuin history prune` で整理するか、設定で保持期間を制限してください。
