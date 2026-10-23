> 摘要：Starship 提示符的模块组成、Ghostty 终端外观，以及 tmux 的分工与键位。

# 终端与提示符

三者解决不同问题：Starship 画提示符，Ghostty 提供终端窗口，tmux 管理会话和分屏。

## Starship

### 加载方式

```zsh
zinit ice as"command" from"gh-r" bpick"${_starship_bpick}" pick"starship" sbin"starship"
zinit light starship/starship

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

`_starship_bpick` 按 OS 和架构选择 release 包：macOS 分 arm64/x86_64，Linux 分 aarch64/x86_64 且用 musl 版本（静态链接，不依赖系统 glibc）。

### 提示符结构

配置在 `config/starship/starship.toml`。主行：

```text
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character
```

右行：

```text
$status$cmd_duration$jobs
```

### 各模块的显示条件

| 模块 | 出现条件 |
|---|---|
| `hostname` | 只在 SSH 会话显示，格式 `host@ssh` |
| `directory` | 总是；截断到 3 层，进入仓库后显示仓库相对路径 |
| `git_branch` / `git_status` | 在 Git 仓库内 |
| `python` | 检测到 `requirements.txt`、`pyproject.toml`、`.venv` 等 |
| `nodejs` | 检测到 `package.json` 或 `node_modules` |
| `rust` | `Cargo.toml` |
| `golang` | `go.mod` |
| `java` | `pom.xml`、`build.gradle` 等 |
| `docker_context` | 设置了非默认 docker context |
| `kubernetes` | 有 kube context |
| `aws` | 有 AWS profile 或 region |
| `terraform` | 在 Terraform 目录 |
| `cmd_duration` | 命令耗时超过 2000ms |
| `time` | 总是，格式 `%H:%M` |

### 常用命令

```bash
starship explain        # 解释当前提示符每个模块为什么出现
starship prompt         # 打印当前提示符
starship module git_branch   # 单独渲染某模块
starship config         # 打开配置文件
starship preset nerd-font-symbols  # 换预设
```

`starship explain` 是排查「为什么提示符里没有 Python 版本」最快的方法。

### 符号与 Nerd Font

配置里大量使用 Nerd Font 图标（`❯`、``、``、`󰏗`）。终端字体必须是 Nerd Font，否则显示成方框或问号。本仓库用 Meslo Nerd Font，由 `install_font.sh` 安装。

## Ghostty

`config/ghostty/config`：

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
background = #000000
foreground = #f8f8f2
cursor-color = #50fa7b
copy-on-select = clipboard
window-padding-x = 5
window-padding-y = 5
keybind = f11=toggle_fullscreen
```

配色是 Dracula 风格的 16 色板。`copy-on-select = clipboard` 意味着选中文本立即进系统剪贴板，不需要 `Ctrl+Shift+C`。

**注意**：这个文件当前**没有**列入 `dotlink/dotlinkrc`。要让 Ghostty 用上它，需要手动建立链接：

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## tmux

### 基础选项

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -g mouse on
setw -g mode-keys vi
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| 选项 | 作用 |
|---|---|
| `default-terminal` | 声明支持 256 色 |
| `terminal-features ,*:RGB` | 让应用认为支持真彩色 |
| `mouse on` | 鼠标可选 pane、调大小、滚动 |
| `mode-keys vi` | copy mode 用 vi 键位 |
| `base-index 1` | window 从 1 开始编号 |
| `renumber-windows on` | 关闭窗口后重新编号，不留空号 |
| `history-limit 200000` | 回滚缓冲 20 万行 |
| `focus-events on` | 让 Neovim 感知焦点变化 |
| `allow-passthrough on` | 允许 Kitty 图形协议和 OSC 52 剪贴板穿过 tmux |

### 键位

| 键 | 动作 |
|---|---|
| `Prefix + c` | 新窗口，继承当前 pane 的路径 |
| `Prefix + H/J/K/L` | 向左/下/上/右调整 pane 大小，每次 5 格 |
| `Prefix + X` | 确认后结束整个 session |
| `Prefix + x` | 结束当前 pane |

`H/J/K/L` 用 `-r` 声明为可重复，按住不放会连续调整。

### TPM 插件

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
```

| 插件 | 作用 |
|---|---|
| `tpm` | 插件管理器本体 |
| `tmux-sensible` | 一组公认合理的默认值 |
| `tmux-persist` | 保存/恢复会话 |
| `tmux-continuum` | 自动保存、自动恢复 |
| `tmux-yank` | 复制到系统剪贴板 |
| `vim-tmux-navigator` | `Ctrl+h/j/k/l` 在 Neovim 和 tmux pane 间无缝切换 |
| `tmux-fzf` | 用 fzf 选择 session/window/pane |

首次安装插件：`Prefix + I`。更新：`Prefix + U`。

### 会话恢复

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

意思是保存会话时，把 vim/nvim 的运行状态也记录下来，恢复时尝试还原编辑现场。

恢复后有一个后置钩子重新编号窗口，避免恢复出 0 号窗口：

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

### 私有覆盖

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

文件不存在时静默跳过。这样公开配置不包含私有内容，但允许本机追加。

### 为什么关掉 extended-keys

```tmux
set -g extended-keys off
```

Kitty 的 CSI-u 协议会把 `Ctrl+J` 编码成 `ESC [ 106 ; 5 u`。如果远端 shell 或粘贴工具不认识这个序列，它会作为可见文本泄漏到命令行。关掉之后，普通 Ctrl 和方向键仍用兼容编码。

## 三者如何配合

```text
Ghostty（终端窗口，负责字体与颜色）
  └── tmux（会话、分屏、持久化）
        └── zsh（Starship 提示符）
              └── nvim / 其它 TUI
```

真彩色需要 Ghostty 支持、tmux 传递、应用声明三层都成立。任何一层缺失，颜色会退化成 256 色近似值。
<!-- lang:en -->
> Summary: The module composition of the Starship prompt, the Ghostty terminal appearance, and how tmux divides responsibilities plus its key bindings.

# Terminal and Prompt

The three solve different problems: Starship draws the prompt, Ghostty provides the terminal window, and tmux manages sessions and split panes.

## Starship

### How it loads

```zsh
zinit ice as"command" from"gh-r" bpick"${_starship_bpick}" pick"starship" sbin"starship"
zinit light starship/starship

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

`_starship_bpick` picks the release package by OS and architecture: macOS splits arm64/x86_64; Linux splits aarch64/x86_64 and uses the musl build (statically linked, no dependency on system glibc).

### Prompt structure

Configuration lives in `config/starship/starship.toml`. The main line:

```text
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character
```

The right line:

```text
$status$cmd_duration$jobs
```

### When each module appears

| Module | Condition |
|---|---|
| `hostname` | Only shown in SSH sessions, formatted `host@ssh` |
| `directory` | Always; truncated to 3 levels, shows repo-relative paths inside a repository |
| `git_branch` / `git_status` | Inside a Git repository |
| `python` | Detects `requirements.txt`, `pyproject.toml`, `.venv`, etc. |
| `nodejs` | Detects `package.json` or `node_modules` |
| `rust` | `Cargo.toml` |
| `golang` | `go.mod` |
| `java` | `pom.xml`, `build.gradle`, etc. |
| `docker_context` | A non-default docker context is set |
| `kubernetes` | A kube context exists |
| `aws` | An AWS profile or region exists |
| `terraform` | Inside a Terraform directory |
| `cmd_duration` | Command took longer than 2000ms |
| `time` | Always, format `%H:%M` |

### Common commands

```bash
starship explain        # 解释当前提示符每个模块为什么出现
starship prompt         # 打印当前提示符
starship module git_branch   # 单独渲染某模块
starship config         # 打开配置文件
starship preset nerd-font-symbols  # 换预设
```

`starship explain` is the fastest way to answer "why doesn't the prompt show the Python version".

### Symbols and Nerd Fonts

The configuration uses many Nerd Font glyphs (`❯`, ``, ``, `󰏗`). The terminal font must be a Nerd Font, otherwise they render as boxes or question marks. This repo uses Meslo Nerd Font, installed by `install_font.sh`.

## Ghostty

`config/ghostty/config`:

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
background = #000000
foreground = #f8f8f2
cursor-color = #50fa7b
copy-on-select = clipboard
window-padding-x = 5
window-padding-y = 5
keybind = f11=toggle_fullscreen
```

The color scheme is a Dracula-style 16-color palette. `copy-on-select = clipboard` means selected text goes straight into the system clipboard, no `Ctrl+Shift+C` needed.

**Note**: this file is currently **not** listed in `dotlink/dotlinkrc`. To make Ghostty use it, create the link manually:

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## tmux

### Basic options

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -g mouse on
setw -g mode-keys vi
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| Option | Purpose |
|---|---|
| `default-terminal` | Declares 256-color support |
| `terminal-features ,*:RGB` | Makes applications believe true color is supported |
| `mouse on` | Mouse can select panes, resize, and scroll |
| `mode-keys vi` | copy mode uses vi keys |
| `base-index 1` | Windows number from 1 |
| `renumber-windows on` | Renumber after closing a window, leaving no gaps |
| `history-limit 200000` | 200,000-line scrollback buffer |
| `focus-events on` | Lets Neovim sense focus changes |
| `allow-passthrough on` | Lets the Kitty graphics protocol and OSC 52 clipboard pass through tmux |

### Key bindings

| Key | Action |
|---|---|
| `Prefix + c` | New window, inheriting the current pane's path |
| `Prefix + H/J/K/L` | Resize pane left/down/up/right, 5 cells at a time |
| `Prefix + X` | End the whole session after confirmation |
| `Prefix + x` | End the current pane |

`H/J/K/L` are declared repeatable with `-r`; holding the key keeps adjusting.

### TPM plugins

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
```

| Plugin | Purpose |
|---|---|
| `tpm` | The plugin manager itself |
| `tmux-sensible` | A set of widely accepted sane defaults |
| `tmux-persist` | Save/restore sessions |
| `tmux-continuum` | Automatic saving and restoring |
| `tmux-yank` | Copy to the system clipboard |
| `vim-tmux-navigator` | `Ctrl+h/j/k/l` moves seamlessly between Neovim and tmux panes |
| `tmux-fzf` | Pick session/window/pane with fzf |

First-time plugin install: `Prefix + I`. Update: `Prefix + U`.

### Session restore

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

This means that when saving a session, the running state of vim/nvim is also recorded, and restoring tries to bring back the editing scene.

After restore, a post hook renumbers windows to avoid restoring a window numbered 0:

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

### Private overrides

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

If the file doesn't exist it is silently skipped. This keeps private content out of the public config while allowing per-machine additions.

### Why extended-keys is disabled

```tmux
set -g extended-keys off
```

Kitty's CSI-u protocol encodes `Ctrl+J` as `ESC [ 106 ; 5 u`. If a remote shell or paste tool doesn't recognize this sequence, it leaks into the command line as visible text. With it disabled, plain Ctrl and arrow keys still use compatible encodings.

## How the three work together

```text
Ghostty（终端窗口，负责字体与颜色）
  └── tmux（会话、分屏、持久化）
        └── zsh（Starship 提示符）
              └── nvim / 其它 TUI
```

True color requires all three layers to hold: Ghostty supports it, tmux passes it through, and the application declares it. If any layer is missing, colors degrade to a 256-color approximation.
<!-- lang:ja -->
> 要約：Starship プロンプトのモジュール構成、Ghostty ターミナルの外観、tmux の役割分担とキーバインド。

# ターミナルとプロンプト

3 者はそれぞれ別の問題を解決します。Starship はプロンプトを描き、Ghostty はターミナルウィンドウを提供し、tmux はセッションと画面分割を管理します。

## Starship

### ロード方法

```zsh
zinit ice as"command" from"gh-r" bpick"${_starship_bpick}" pick"starship" sbin"starship"
zinit light starship/starship

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

`_starship_bpick` は OS とアーキテクチャでリリースパッケージを選びます。macOS は arm64/x86_64、Linux は aarch64/x86_64 で musl 版（静的リンクでシステム glibc に依存しない）を使用します。

### プロンプトの構造

設定は `config/starship/starship.toml` にあります。メイン行：

```text
$hostname$directory$git_branch$git_status$python$nodejs$rust$golang$java$package$docker_context$kubernetes$aws$terraform$time
$character
```

右行：

```text
$status$cmd_duration$jobs
```

### 各モジュールの表示条件

| モジュール | 出現条件 |
|---|---|
| `hostname` | SSH セッションのみ。形式は `host@ssh` |
| `directory` | 常時。3 階層まで切り詰め、リポジトリ内ではリポジトリ相対パスを表示 |
| `git_branch` / `git_status` | Git リポジトリ内 |
| `python` | `requirements.txt`、`pyproject.toml`、`.venv` などを検出 |
| `nodejs` | `package.json` か `node_modules` を検出 |
| `rust` | `Cargo.toml` |
| `golang` | `go.mod` |
| `java` | `pom.xml`、`build.gradle` など |
| `docker_context` | デフォルト以外の docker context が設定されている |
| `kubernetes` | kube context がある |
| `aws` | AWS profile か region がある |
| `terraform` | Terraform ディレクトリ内 |
| `cmd_duration` | コマンドが 2000ms を超えた |
| `time` | 常時。形式は `%H:%M` |

### よく使うコマンド

```bash
starship explain        # 解释当前提示符每个模块为什么出现
starship prompt         # 打印当前提示符
starship module git_branch   # 单独渲染某模块
starship config         # 打开配置文件
starship preset nerd-font-symbols  # 换预设
```

「なぜプロンプトに Python のバージョンが出ないのか」を調べる最速の方法は `starship explain` です。

### 記号と Nerd Font

設定では Nerd Font のアイコン（`❯`、``、``、`󰏗`）を多く使います。ターミナルのフォントが Nerd Font でないと、四角や疑問符で表示されます。本リポジトリは Meslo Nerd Font を使い、`install_font.sh` がインストールします。

## Ghostty

`config/ghostty/config`：

```text
font-family = MesloLGS Nerd Font Mono
font-size = 11
background = #000000
foreground = #f8f8f2
cursor-color = #50fa7b
copy-on-select = clipboard
window-padding-x = 5
window-padding-y = 5
keybind = f11=toggle_fullscreen
```

カラースキームは Dracula 風の 16 色パレットです。`copy-on-select = clipboard` により、選択したテキストは即座にシステムクリップボードに入り、`Ctrl+Shift+C` は不要です。

**注意**：このファイルは現在 `dotlink/dotlinkrc` に**登録されていません**。Ghostty に使わせるにはリンクを手動で張る必要があります：

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## tmux

### 基本オプション

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -g mouse on
setw -g mode-keys vi
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| オプション | 役割 |
|---|---|
| `default-terminal` | 256 色対応を宣言 |
| `terminal-features ,*:RGB` | アプリにトゥルーカラー対応と思わせる |
| `mouse on` | マウスで pane の選択、リサイズ、スクロールが可能 |
| `mode-keys vi` | copy mode で vi キーを使用 |
| `base-index 1` | window の番号を 1 から開始 |
| `renumber-windows on` | window を閉じた後に番号を振り直し、欠番を残さない |
| `history-limit 200000` | スクロールバック 20 万行 |
| `focus-events on` | Neovim にフォーカス変化を伝える |
| `allow-passthrough on` | Kitty のグラフィックプロトコルと OSC 52 クリップボードが tmux を通過できるようにする |

### キーバインド

| キー | 動作 |
|---|---|
| `Prefix + c` | 新しい window。現在の pane のパスを引き継ぐ |
| `Prefix + H/J/K/L` | pane を左/下/上/右へリサイズ。毎回 5 マス |
| `Prefix + X` | 確認後にセッション全体を終了 |
| `Prefix + x` | 現在の pane を終了 |

`H/J/K/L` は `-r` で繰り返し可能として宣言されており、押し続けると連続で調整されます。

### TPM プラグイン

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
```

| プラグイン | 役割 |
|---|---|
| `tpm` | プラグインマネージャ本体 |
| `tmux-sensible` | 広く受け入れられた妥当なデフォルト値集 |
| `tmux-persist` | セッションの保存/復元 |
| `tmux-continuum` | 自動保存・自動復元 |
| `tmux-yank` | システムクリップボードへのコピー |
| `vim-tmux-navigator` | `Ctrl+h/j/k/l` で Neovim と tmux pane をシームレスに移動 |
| `tmux-fzf` | fzf で session/window/pane を選択 |

初回のプラグインインストールは `Prefix + I`。更新は `Prefix + U`。

### セッション復元

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

セッション保存時に vim/nvim の実行状態も記録し、復元時に編集現場の再現を試みるという意味です。

復元後には後処理 hook で window の番号を振り直し、0 番の window が復元されるのを防ぎます：

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

### プライベート上書き

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

ファイルがなければ黙ってスキップします。公開設定にプライベートな内容を含めずに、ローカルでの追加を許します。

### extended-keys を無効化する理由

```tmux
set -g extended-keys off
```

Kitty の CSI-u プロトコルは `Ctrl+J` を `ESC [ 106 ; 5 u` とエンコードします。リモートのシェルや貼り付けツールがこのシーケンスを認識しない場合、可視テキストとしてコマンドラインに漏れ出ます。無効化しても、通常の Ctrl と矢印キーは互換エンコーディングを使い続けます。

## 3 者の連携

```text
Ghostty（终端窗口，负责字体与颜色）
  └── tmux（会话、分屏、持久化）
        └── zsh（Starship 提示符）
              └── nvim / 其它 TUI
```

トゥルーカラーには Ghostty の対応、tmux の中継、アプリの宣言という 3 層すべてが成立する必要があります。どれか 1 層でも欠けると、色は 256 色近似に退化します。
