> 摘要：starship.toml 的两行布局、各模块触发条件和颜色配置。

# Starship 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/starship/starship.toml` |
| 部署目标 | `~/.config/starship.toml` |
| 是否自动链接 | 是 |

## 整体结构

```toml
add_newline = true
command_timeout = 2500

format = """
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character"""

right_format = """$status$cmd_duration$jobs"""
```

| 键 | 作用 |
|---|---|
| `add_newline` | 提示符前加一个空行，视觉上分隔命令 |
| `command_timeout` | 外部命令超时（毫秒） |
| `format` | 主行，分两行：信息行 + 字符行 |
| `right_format` | 右对齐部分 |

## 主行模块

路径、分支和 Git 状态色沿用 Neovim Blue / Nostalgia 的黄、青、绿、红色板。

### hostname

```toml
[hostname]
ssh_only = true
format = "[$hostname@ssh]($style) "
style = "bold red"
disabled = false
```

只在 SSH 会话显示，红色提示「你在远端」。

### directory

```toml
[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold #ffff55"
```

| 键 | 效果 |
|---|---|
| `truncation_length = 3` | 最多显示 3 层路径 |
| `truncate_to_repo = true` | 在 Git 仓库内只显示仓库相对路径 |

两者配合：`~/projects/very/deep/nested/path/src/lib` 在仓库根为 `path/` 时显示成 `path/src/lib`。

### git_branch

```toml
[git_branch]
symbol = " "
style = "bold #55ffff"
```

`symbol` 是 Nerd Font 的分支图标。

### git_status

```toml
[git_status]
style = "bold #ffff55"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
staged = "[+${count}](bold #00ff00)"
modified = "[~${count}](bold #ffff00)"
untracked = "[?${count}](bold #ff5555)"
deleted = "[-${count}](bold #ff5555)"
stashed = "[*${count}](bold #55ffff)"
```

| 符号 | 含义 | 颜色 |
|---|---|---|
| `+N` | 已暂存 N 个文件 | 绿 |
| `~N` | 已修改 N 个文件 | 黄 |
| `?N` | 未跟踪 N 个文件 | 红 |
| `-N` | 已删除 N 个文件 | 红 |
| `*N` | N 个 stash | 青 |
| `⇡N` | 领先远端 N 个提交 | — |
| `⇣N` | 落后远端 N 个提交 | — |

### 语言模块

```toml
[python]
symbol = " "
format = '[$symbol(${version} )(\($virtualenv\) )](bold yellow)'
detect_files = ["requirements.txt", "pyproject.toml", "setup.py", ".python-version", "Pipfile"]
detect_folders = [".venv", "venv"]

[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #00ff00"

[rust]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #ff5555"

[golang]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #55ffff"

[java]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #5555ff"
```

Python 的 `format` 里 `\($virtualenv\)` 会在激活虚拟环境时显示环境名。

### 云与基础设施

```toml
[docker_context]
symbol = " "
format = "[$symbol$context]($style) "
style = "bold #55ffff"

[kubernetes]
symbol = "󱃾 "
format = '[$symbol$context( \($namespace\))]($style) '
style = "bold #55ffff"
disabled = false

[aws]
symbol = " "
format = '[$symbol($profile )(\\($region\\) )]($style)'
style = "bold yellow"
disabled = false

[terraform]
symbol = "󱁢 "
format = "[$symbol$workspace]($style) "
style = "bold #ff00ff"
```

四个都显式 `disabled = false`，只要检测到对应配置就显示。不用这些工具时可以改成 `true` 减少提示符宽度。

### package 和 time

```toml
[package]
symbol = "󰏗 "
format = "[$symbol$version]($style) "
style = "bold #ffff00"

[time]
disabled = false
format = "at [$time]($style) "
time_format = "%H:%M"
style = "#ffffff"
```

`package` 显示当前项目版本（从 `package.json`、`Cargo.toml` 等读取）。`time` 显示当前时间。

## 右对齐部分

```toml
[status]
disabled = false
symbol = " "
style = "bold red"

[cmd_duration]
min_time = 2_000
format = "[$duration](bold yellow) "

[jobs]
symbol = "󰒋 "
style = "bold #55ffff"
```

| 模块 | 触发 |
|---|---|
| status | 上一条命令退出码非零 |
| cmd_duration | 耗时超过 2000ms |
| jobs | 有后台任务 |

## 字符行

```toml
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❯](bold yellow)"
```

`vimcmd_symbol` 在 vi 模式下的命令行模式显示黄色 `❯`。

## 调优建议

**提示符太长**：关掉不用的云模块：

```toml
[kubernetes]
disabled = true
```

**Git 状态慢**：大仓库里 `git_status` 会遍历所有变更。可以关掉：

```toml
[git_status]
disabled = true
```

**时间不需要**：`[time] disabled = true`。

**想改配色**：所有 `style` 都接受颜色名（`bold red`）或十六进制（例如主题黄 `bold #ffff55`）。

## 验证

```bash
starship explain          # 逐模块解释
starship timings          # 各模块耗时
starship module directory # 单独渲染
```

## 排错

**图标是方框**：字体不是 Nerd Font。

**提示符不显示 Python 版本**：`starship explain` 看原因，通常是没有触发文件。

**提示符有延迟**：`starship timings` 找慢模块。

**改了配置不生效**：确认改的是 `~/dotfiles/config/starship/starship.toml`（源文件），不是 `~/.config/starship.toml`（软链接）。

**时间显示不对**：`time_format` 用的是系统本地时区。

<!-- lang:en -->
> Summary: The two-line layout in `starship.toml`, module activation conditions, and color settings.

# Starship Configuration

## File Locations

| Item | Path |
|---|---|
| Repository source | `config/starship/starship.toml` |
| Deployment target | `~/.config/starship.toml` |
| Automatically linked | Yes |

## Overall Structure

```toml
add_newline = true
command_timeout = 2500

format = """
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character"""

right_format = """$status$cmd_duration$jobs"""
```

| Key | Effect |
|---|---|
| `add_newline` | Add a blank line before the prompt to visually separate commands |
| `command_timeout` | External command timeout (milliseconds) |
| `format` | Main line, split into two lines: information line + character line |
| `right_format` | Right-aligned section |

## Main-Line Modules

Path, branch, and Git status colors follow the yellow, cyan, green, and red palette of Neovim Blue / Nostalgia.

### hostname

```toml
[hostname]
ssh_only = true
format = "[$hostname@ssh]($style) "
style = "bold red"
disabled = false
```

Shown only in SSH sessions; red indicates “you are on a remote host.”

### directory

```toml
[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold #ffff55"
```

| Key | Effect |
|---|---|
| `truncation_length = 3` | Show at most 3 path components |
| `truncate_to_repo = true` | Inside a Git repository, show a path relative to the repository |

Together, if `~/projects/very/deep/nested/path/src/lib` is in a repository whose root is `path/`, it displays as `path/src/lib`.

### git_branch

```toml
[git_branch]
symbol = " "
style = "bold #55ffff"
```

`symbol` is the Nerd Font branch icon.

### git_status

```toml
[git_status]
style = "bold #ffff55"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
staged = "[+${count}](bold #00ff00)"
modified = "[~${count}](bold #ffff00)"
untracked = "[?${count}](bold #ff5555)"
deleted = "[-${count}](bold #ff5555)"
stashed = "[*${count}](bold #55ffff)"
```

| Symbol | Meaning | Color |
|---|---|---|
| `+N` | N files staged | Green |
| `~N` | N files modified | Yellow |
| `?N` | N untracked files | Red |
| `-N` | N files deleted | Red |
| `*N` | N stashes | Cyan |
| `⇡N` | N commits ahead of the remote | — |
| `⇣N` | N commits behind the remote | — |

### Language Modules

```toml
[python]
symbol = " "
format = '[$symbol(${version} )(\($virtualenv\) )](bold yellow)'
detect_files = ["requirements.txt", "pyproject.toml", "setup.py", ".python-version", "Pipfile"]
detect_folders = [".venv", "venv"]

[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #00ff00"

[rust]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #ff5555"

[golang]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #55ffff"

[java]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #5555ff"
```

In Python's `format`, `\($virtualenv\)` displays the environment name when a virtual environment is active.

### Cloud and Infrastructure

```toml
[docker_context]
symbol = " "
format = "[$symbol$context]($style) "
style = "bold #55ffff"

[kubernetes]
symbol = "󱃾 "
format = '[$symbol$context( \($namespace\))]($style) '
style = "bold #55ffff"
disabled = false

[aws]
symbol = " "
format = '[$symbol($profile )(\\($region\\) )]($style)'
style = "bold yellow"
disabled = false

[terraform]
symbol = "󱁢 "
format = "[$symbol$workspace]($style) "
style = "bold #ff00ff"
```

All four explicitly set `disabled = false`, so they appear when their corresponding configuration is detected. Set this to `true` for tools you do not use to reduce prompt width.

### package and time

```toml
[package]
symbol = "󰏗 "
format = "[$symbol$version]($style) "
style = "bold #ffff00"

[time]
disabled = false
format = "at [$time]($style) "
time_format = "%H:%M"
style = "#ffffff"
```

`package` displays the current project version (read from `package.json`, `Cargo.toml`, and similar files). `time` displays the current time.

## Right-Aligned Section

```toml
[status]
disabled = false
symbol = " "
style = "bold red"

[cmd_duration]
min_time = 2_000
format = "[$duration](bold yellow) "

[jobs]
symbol = "󰒋 "
style = "bold #55ffff"
```

| Module | Trigger |
|---|---|
| status | The previous command exited with a nonzero status |
| cmd_duration | Command took more than 2000ms |
| jobs | There are background jobs |

## Character Line

```toml
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❯](bold yellow)"
```

`vimcmd_symbol` displays a yellow `❯` for command-line mode in vi mode.

## Tuning Tips

**Prompt is too long**: Disable cloud modules you do not use:

```toml
[kubernetes]
disabled = true
```

**Git status is slow**: In large repositories, `git_status` scans every change. You can disable it:

```toml
[git_status]
disabled = true
```

**Do not need the time**: Set `[time] disabled = true`.

**Want to change the colors**: Every `style` accepts color names (`bold red`) or hex values (for example, theme yellow `bold #ffff55`).

## Verification

```bash
starship explain          # 逐模块解释
starship timings          # 各模块耗时
starship module directory # 单独渲染
```

## Troubleshooting

**Icons appear as boxes**: The font is not a Nerd Font.

**Python version does not appear in the prompt**: Check the reason with `starship explain`; usually no detection file triggered the module.

**Prompt is delayed**: Use `starship timings` to find the slow module.

**Changes to the configuration have no effect**: Confirm you edited `~/dotfiles/config/starship/starship.toml` (the source file), not `~/.config/starship.toml` (the symlink).

**Time is displayed incorrectly**: `time_format` uses the system's local time zone.

<!-- lang:ja -->
> 要約：`starship.toml` の 2 行レイアウト、各モジュールの表示条件、色設定について説明します。

# Starship の設定

## ファイルの場所

| 項目 | パス |
|---|---|
| リポジトリのソース | `config/starship/starship.toml` |
| 配置先 | `~/.config/starship.toml` |
| 自動リンク | はい |

## 全体構成

```toml
add_newline = true
command_timeout = 2500

format = """
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character"""

right_format = """$status$cmd_duration$jobs"""
```

| キー | 効果 |
|---|---|
| `add_newline` | プロンプトの前に空行を加え、コマンドを見分けやすくします |
| `command_timeout` | 外部コマンドのタイムアウト（ミリ秒） |
| `format` | メイン部分。情報行と文字行の 2 行です |
| `right_format` | 右寄せ部分 |

## メイン行のモジュール

パス、ブランチ、Git 状態の色には、Neovim Blue / Nostalgia の黄色、シアン、緑、赤を使います。

### hostname

```toml
[hostname]
ssh_only = true
format = "[$hostname@ssh]($style) "
style = "bold red"
disabled = false
```

SSH セッションでのみ表示し、赤色で「リモートに接続中」であることを示します。

### directory

```toml
[directory]
truncation_length = 3
truncate_to_repo = true
style = "bold #ffff55"
```

| キー | 効果 |
|---|---|
| `truncation_length = 3` | パスを最大 3 階層まで表示します |
| `truncate_to_repo = true` | Git リポジトリ内では、リポジトリからの相対パスを表示します |

この 2 つを組み合わせると、`~/projects/very/deep/nested/path/src/lib` が、ルート `path/` のリポジトリ内では `path/src/lib` と表示されます。

### git_branch

```toml
[git_branch]
symbol = " "
style = "bold #55ffff"
```

`symbol` は Nerd Font のブランチアイコンです。

### git_status

```toml
[git_status]
style = "bold #ffff55"
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
staged = "[+${count}](bold #00ff00)"
modified = "[~${count}](bold #ffff00)"
untracked = "[?${count}](bold #ff5555)"
deleted = "[-${count}](bold #ff5555)"
stashed = "[*${count}](bold #55ffff)"
```

| 記号 | 意味 | 色 |
|---|---|---|
| `+N` | N 個のファイルをステージ済み | 緑 |
| `~N` | N 個のファイルを変更済み | 黄 |
| `?N` | N 個の未追跡ファイル | 赤 |
| `-N` | N 個の削除済みファイル | 赤 |
| `*N` | N 個の stash | シアン |
| `⇡N` | リモートより N コミット先行 | — |
| `⇣N` | リモートより N コミット遅れ | — |

### 言語モジュール

```toml
[python]
symbol = " "
format = '[$symbol(${version} )(\($virtualenv\) )](bold yellow)'
detect_files = ["requirements.txt", "pyproject.toml", "setup.py", ".python-version", "Pipfile"]
detect_folders = [".venv", "venv"]

[nodejs]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #00ff00"

[rust]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #ff5555"

[golang]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #55ffff"

[java]
symbol = " "
format = "[$symbol($version )]($style)"
style = "bold #5555ff"
```

Python の `format` にある `\($virtualenv\)` は、仮想環境が有効なときに環境名を表示します。

### クラウドとインフラ

```toml
[docker_context]
symbol = " "
format = "[$symbol$context]($style) "
style = "bold #55ffff"

[kubernetes]
symbol = "󱃾 "
format = '[$symbol$context( \($namespace\))]($style) '
style = "bold #55ffff"
disabled = false

[aws]
symbol = " "
format = '[$symbol($profile )(\\($region\\) )]($style)'
style = "bold yellow"
disabled = false

[terraform]
symbol = "󱁢 "
format = "[$symbol$workspace]($style) "
style = "bold #ff00ff"
```

4 つとも `disabled = false` を明示しているため、対応する設定が検出されると表示します。使わないツールは `true` にすると、プロンプトの幅を抑えられます。

### package と time

```toml
[package]
symbol = "󰏗 "
format = "[$symbol$version]($style) "
style = "bold #ffff00"

[time]
disabled = false
format = "at [$time]($style) "
time_format = "%H:%M"
style = "#ffffff"
```

`package` は `package.json` や `Cargo.toml` などから現在のプロジェクトのバージョンを読み取って表示します。`time` は現在時刻を表示します。

## 右寄せ部分

```toml
[status]
disabled = false
symbol = " "
style = "bold red"

[cmd_duration]
min_time = 2_000
format = "[$duration](bold yellow) "

[jobs]
symbol = "󰒋 "
style = "bold #55ffff"
```

| モジュール | 表示条件 |
|---|---|
| status | 直前のコマンドの終了コードが 0 以外 |
| cmd_duration | 実行時間が 2000ms を超過 |
| jobs | バックグラウンドジョブが存在 |

## 文字行

```toml
[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
vimcmd_symbol = "[❯](bold yellow)"
```

vi モードのコマンドラインモードでは、`vimcmd_symbol` が黄色の `❯` を表示します。

## 調整のヒント

**プロンプトが長すぎます**：使わないクラウドモジュールを無効にします。

```toml
[kubernetes]
disabled = true
```

**Git 状態の表示が遅いです**：大きなリポジトリでは `git_status` がすべての変更を調べます。無効にできます。

```toml
[git_status]
disabled = true
```

**時刻表示が不要です**：`[time] disabled = true` にします。

**配色を変更したい場合**：各 `style` には色名（`bold red`）または 16 進数（例：テーマの黄色 `bold #ffff55`）を指定できます。

## 確認

```bash
starship explain          # 逐模块解释
starship timings          # 各模块耗时
starship module directory # 单独渲染
```

## トラブルシューティング

**アイコンが四角で表示されます**：フォントが Nerd Font ではありません。

**プロンプトに Python のバージョンが表示されません**：`starship explain` で理由を確認してください。多くの場合、検出対象のファイルがありません。

**プロンプトの表示に時間がかかります**：`starship timings` で遅いモジュールを探してください。

**設定を変更しても反映されません**：編集したのが `~/dotfiles/config/starship/starship.toml`（ソースファイル）であり、`~/.config/starship.toml`（シンボリックリンク）ではないことを確認してください。

**時刻が正しく表示されません**：`time_format` はシステムのローカルタイムゾーンを使います。
