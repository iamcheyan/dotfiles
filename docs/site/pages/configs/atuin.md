> 摘要：atuin/config.toml 关闭自动同步与更新检查，其余用默认值。

# Atuin 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/atuin/config.toml` |
| 部署目标 | `~/.config/atuin/`（整个目录） |
| 是否自动链接 | 是 |
| 数据文件 | `~/.local/share/atuin/history.db` |

注意部署的是**整个目录**，不是单个文件。所以目录里如果有其它文件（比如 `atuin-receipt.json`），也会一起部署。

## 实际生效的设置

当前显式设置同步、更新检查、Enter 行为和 Blue 配色：

```toml
auto_sync = false
update_check = false
enter_accept = true

[theme]
name = "nostalgia-green"
```

| 设置 | 值 | 原因 |
|---|---|---|
| `auto_sync` | `false` | 不自动上传历史到 Atuin 服务器 |
| `update_check` | `false` | 启动时不检查新版本，减少网络请求 |
| `enter_accept` | `true` | 按 Enter 直接执行选中的命令 |

`auto_sync = false` 是隐私相关的默认：历史里可能有 token、内部地址、临时命令，不主动上传。

`enter_accept = true` 影响操作习惯：Enter 执行，Tab 才回到命令行编辑。

`nostalgia-green` 以 Starship 主绿 `#50fa7b` 为基色，搭配青、黄、红等提示色；主题只改前景，不覆盖终端背景。主题颜色见 `config/atuin/themes/nostalgia-green.toml`。

## 被注释的选项

文件保留了上游默认配置的完整注释，方便按需开启。几个值得注意的：

### 搜索行为

```toml
# search_mode = "fuzzy"
# filter_mode = "global"
# filter_mode_shell_up_key_binding = "global"
# search_mode_shell_up_key_binding = "fuzzy"
```

| 值 | 含义 |
|---|---|
| `prefix` | 前缀匹配 |
| `fulltext` | 全文匹配 |
| `fuzzy` | 模糊匹配 |
| `skim` | skim 风格 |

`filter_mode` 可选 `global`、`host`、`session`、`session-preload`、`directory`、`workspace`。

### 界面

```toml
# style = "auto"
# inline_height = 0
# invert = false
# show_preview = true
# show_help = true
# show_tabs = true
```

| 设置 | 说明 |
|---|---|
| `style` | `auto`、`full`、`compact` |
| `inline_height` | 0 表示全屏 |
| `invert` | 搜索框放底部 |
| `show_preview` | 长命令预览 |

### 隐私过滤

```toml
# history_filter = [
#   "^secret-cmd",
#   "^innocuous-cmd .*--secret=.+",
# ]

# cwd_filter = [
#   "^/very/secret/area",
# ]

# secrets_filter = true
```

`secrets_filter` 默认开启，会过滤疑似 AWS key、GitHub token、Slack token、Stripe key 的命令。

需要更严格时启用 `history_filter` 正则：

```toml
history_filter = [
  "^export .*TOKEN",
  "^curl .*Authorization",
]
```

### 存储位置

```toml
# db_path = "~/.history.db"
# key_path = "~/.key"
# session_path = "~/.session"
```

默认在系统数据目录，符合 XDG 规范。

## 同步配置

启用同步需要：

```toml
auto_sync = true
sync_address = "https://api.atuin.sh"
sync_frequency = "10m"
```

然后：

```bash
atuin register -u <user> -e <email> -p
atuin login -u <user> -p
atuin sync
```

**同步是端到端加密的**，密钥不上传。但历史内容会存到 Atuin 服务器。启用前确认历史里没有敏感信息。

## 验证

```bash
atuin info              # 显示配置和数据文件位置
atuin doctor            # 健康检查
atuin status            # 同步状态
atuin default-config    # 打印完整默认配置
```

`atuin info` 会显示实际生效的配置文件路径，用于确认是否读到了本仓库的配置。

## 排错

**配置没生效**：`atuin info` 看路径。可能链接没建立，或 Atuin 读的是别的路径。

**同步报错**：`auto_sync = false` 时不该有同步请求。如果看到同步错误，说明某处覆盖了配置。

**历史没记录**：`atuin init zsh` 的 hook 没生效。

**Enter 直接执行了不想执行的命令**：这是 `enter_accept = true` 的效果。改按 Tab，或把配置改成 `false`。

**敏感命令进了历史**：启用 `history_filter` 正则，或事后 `atuin history delete`。

**多机历史冲突**：`atuin status` 查看，必要时 `atuin sync --force`。

<!-- lang:en -->

> Summary: atuin/config.toml disables auto sync and update checks; everything else stays at the defaults.

# Atuin Configuration

## File Locations

| Item | Path |
|---|---|
| Repository source file | `config/atuin/config.toml` |
| Deployment target | `~/.config/atuin/` (the whole directory) |
| Auto-linked | Yes |
| Data file | `~/.local/share/atuin/history.db` |

Note that the **whole directory** is deployed, not a single file. Any other files in the directory (for example `atuin-receipt.json`) are deployed along with it.

## Effective Settings

The current file explicitly sets sync, update checks, Enter behavior, and the Blue color scheme:

```toml
auto_sync = false
update_check = false
enter_accept = true

[theme]
name = "nostalgia-green"
```

| Setting | Value | Reason |
|---|---|---|
| `auto_sync` | `false` | Do not automatically upload history to the Atuin server |
| `update_check` | `false` | No new-version check at startup, reducing network requests |
| `enter_accept` | `true` | Pressing Enter runs the selected command directly |

`auto_sync = false` is a privacy-related default: history may contain tokens, internal addresses, or temporary commands, so nothing is uploaded proactively.

`enter_accept = true` affects habits: Enter executes, and only Tab returns to command-line editing.

`nostalgia-green` uses Starship's primary green `#50fa7b`, with cyan, yellow, and red accents. It changes foreground colors only and keeps the terminal background. See `config/atuin/themes/nostalgia-green.toml` for the palette.

## Commented-Out Options

The file keeps the full comments from the upstream default configuration so you can enable options as needed. A few notable ones:

### Search Behavior

```toml
# search_mode = "fuzzy"
# filter_mode = "global"
# filter_mode_shell_up_key_binding = "global"
# search_mode_shell_up_key_binding = "fuzzy"
```

| Value | Meaning |
|---|---|
| `prefix` | Prefix matching |
| `fulltext` | Full-text matching |
| `fuzzy` | Fuzzy matching |
| `skim` | skim style |

`filter_mode` accepts `global`, `host`, `session`, `session-preload`, `directory`, and `workspace`.

### Interface

```toml
# style = "auto"
# inline_height = 0
# invert = false
# show_preview = true
# show_help = true
# show_tabs = true
```

| Setting | Description |
|---|---|
| `style` | `auto`, `full`, `compact` |
| `inline_height` | 0 means full screen |
| `invert` | Places the search box at the bottom |
| `show_preview` | Preview for long commands |

### Privacy Filtering

```toml
# history_filter = [
#   "^secret-cmd",
#   "^innocuous-cmd .*--secret=.+",
# ]

# cwd_filter = [
#   "^/very/secret/area",
# ]

# secrets_filter = true
```

`secrets_filter` is enabled by default and filters commands that look like AWS keys, GitHub tokens, Slack tokens, or Stripe keys.

For stricter control, enable `history_filter` regexes:

```toml
history_filter = [
  "^export .*TOKEN",
  "^curl .*Authorization",
]
```

### Storage Locations

```toml
# db_path = "~/.history.db"
# key_path = "~/.key"
# session_path = "~/.session"
```

By default they live in the system data directory, following the XDG specification.

## Sync Configuration

To enable sync:

```toml
auto_sync = true
sync_address = "https://api.atuin.sh"
sync_frequency = "10m"
```

Then:

```bash
atuin register -u <user> -e <email> -p
atuin login -u <user> -p
atuin sync
```

**Sync is end-to-end encrypted**; the key is not uploaded. However, the history content is stored on the Atuin server. Before enabling it, make sure the history contains no sensitive information.

## Verification

```bash
atuin info              # 显示配置和数据文件位置
atuin doctor            # 健康检查
atuin status            # 同步状态
atuin default-config    # 打印完整默认配置
```

`atuin info` shows the path of the configuration file actually in effect, so you can confirm whether it read this repository's configuration.

## Troubleshooting

**Configuration not taking effect**: check the path with `atuin info`. The link may not exist, or Atuin may be reading a different path.

**Sync errors**: with `auto_sync = false` there should be no sync requests. If you see sync errors, something is overriding the configuration.

**History not recorded**: the hook from `atuin init zsh` is not taking effect.

**Enter executed a command you did not want**: that is the effect of `enter_accept = true`. Press Tab instead, or set it to `false`.

**A sensitive command ended up in history**: enable `history_filter` regexes, or run `atuin history delete` afterwards.

**History conflicts across machines**: check with `atuin status`, and use `atuin sync --force` if necessary.

<!-- lang:ja -->

> 要約：atuin/config.toml は自動同期と更新チェックを無効化し、それ以外はデフォルト値を使います。

# Atuin の設定

## ファイルの場所

| 項目 | パス |
|---|---|
| リポジトリのソースファイル | `config/atuin/config.toml` |
| デプロイ先 | `~/.config/atuin/`（ディレクトリ全体） |
| 自動リンクの対象 | はい |
| データファイル | `~/.local/share/atuin/history.db` |

デプロイされるのは単一のファイルではなく**ディレクトリ全体**である点に注意してください。そのため、ディレクトリ内に他のファイル（例：`atuin-receipt.json`）があれば、それも一緒にデプロイされます。

## 実際に有効な設定

現在は同期・更新チェック・Enter の挙動・Blue カラースキームを明示的に設定しています：

```toml
auto_sync = false
update_check = false
enter_accept = true

[theme]
name = "nostalgia-green"
```

| 設定 | 値 | 理由 |
|---|---|---|
| `auto_sync` | `false` | 履歴を Atuin サーバーへ自動アップロードしない |
| `update_check` | `false` | 起動時に新バージョンを確認せず、ネットワークリクエストを減らす |
| `enter_accept` | `true` | Enter で選択中のコマンドをそのまま実行する |

`auto_sync = false` はプライバシーに関わるデフォルトです。履歴にはトークンや内部アドレス、一時的なコマンドが含まれる可能性があるため、自主的にアップロードしません。

`enter_accept = true` は操作習慣に影響します。Enter で実行し、Tab を押したときだけコマンドライン編集に戻ります。

`nostalgia-green` は Starship の基調色 `#50fa7b` にシアン・黄・赤を合わせたテーマです。前景色のみを変更し、端末の背景は維持します。配色は `config/atuin/themes/nostalgia-green.toml` を参照してください。

## コメントアウトされているオプション

ファイルには上流のデフォルト設定のコメントがそのまま残っており、必要に応じて有効化できます。注目すべきものをいくつか挙げます：

### 検索の挙動

```toml
# search_mode = "fuzzy"
# filter_mode = "global"
# filter_mode_shell_up_key_binding = "global"
# search_mode_shell_up_key_binding = "fuzzy"
```

| 値 | 意味 |
|---|---|
| `prefix` | 前方一致 |
| `fulltext` | 全文一致 |
| `fuzzy` | あいまい一致 |
| `skim` | skim 風 |

`filter_mode` には `global`・`host`・`session`・`session-preload`・`directory`・`workspace` を指定できます。

### インターフェース

```toml
# style = "auto"
# inline_height = 0
# invert = false
# show_preview = true
# show_help = true
# show_tabs = true
```

| 設定 | 説明 |
|---|---|
| `style` | `auto`・`full`・`compact` |
| `inline_height` | 0 は全画面を意味します |
| `invert` | 検索ボックスを下部に配置します |
| `show_preview` | 長いコマンドのプレビューを表示します |

### プライバシーフィルタリング

```toml
# history_filter = [
#   "^secret-cmd",
#   "^innocuous-cmd .*--secret=.+",
# ]

# cwd_filter = [
#   "^/very/secret/area",
# ]

# secrets_filter = true
```

`secrets_filter` はデフォルトで有効で、AWS キー・GitHub トークン・Slack トークン・Stripe キーと疑われるコマンドをフィルタします。

より厳格にしたい場合は `history_filter` の正規表現を有効にします：

```toml
history_filter = [
  "^export .*TOKEN",
  "^curl .*Authorization",
]
```

### 保存場所

```toml
# db_path = "~/.history.db"
# key_path = "~/.key"
# session_path = "~/.session"
```

デフォルトではシステムのデータディレクトリに置かれ、XDG 仕様に従います。

## 同期の設定

同期を有効にするには：

```toml
auto_sync = true
sync_address = "https://api.atuin.sh"
sync_frequency = "10m"
```

次に：

```bash
atuin register -u <user> -e <email> -p
atuin login -u <user> -p
atuin sync
```

**同期はエンドツーエンドで暗号化されます**。鍵はアップロードされません。ただし履歴の内容は Atuin サーバーに保存されます。有効化する前に、履歴に機密情報が含まれていないことを確認してください。

## 検証

```bash
atuin info              # 显示配置和数据文件位置
atuin doctor            # 健康检查
atuin status            # 同步状态
atuin default-config    # 打印完整默认配置
```

`atuin info` は実際に読み込まれた設定ファイルのパスを表示します。このリポジトリの設定が読み込まれているかの確認に使えます。

## トラブルシューティング

**設定が効かない**：`atuin info` でパスを確認します。リンクが張られていないか、Atuin が別のパスを読んでいる可能性があります。

**同期エラー**：`auto_sync = false` であれば同期リクエストは発生しないはずです。同期エラーが出ている場合、どこかで設定が上書きされています。

**履歴が記録されない**：`atuin init zsh` のフックが効いていません。

**実行したくないコマンドが Enter で実行された**：これは `enter_accept = true` の効果です。Tab を押すか、設定を `false` に変更してください。

**機密コマンドが履歴に入った**：`history_filter` の正規表現を有効にするか、後から `atuin history delete` を実行します。

**複数マシン間で履歴が衝突する**：`atuin status` で確認し、必要なら `atuin sync --force` を使います。
