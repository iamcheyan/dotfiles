> 摘要：tmux 是终端复用器，本仓库的配置管真彩色、会话恢复、pane 导航和插件。

# tmux

## 用途

tmux 在终端里创建持久会话：断开 SSH 后进程继续运行，重连后恢复；把终端分成多个 pane 和 window；多人共享同一会话。

本仓库的配置重点在：真彩色、鼠标、vi copy mode、会话恢复、pane 导航。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器 |
| 配置 | `config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf` |
| 插件管理 | TPM（tmux plugin manager） |

```bash
# Debian / Ubuntu
sudo apt install tmux
# Arch
pacman -S tmux
# macOS
brew install tmux
```

## 基本用法

```bash
tmux                    # 新建会话
tmux new -s work        # 命名会话
tmux ls                 # 列出会话
tmux attach -t work     # 连接
tmux kill-session -t work
```

在 tmux 里，所有快捷键都要先按 **prefix**（默认 `Ctrl+B`）。

## 本仓库的配置要点

### 真彩色

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
```

三行缺一不可：声明 terminfo、告诉应用支持 RGB、覆盖终端能力检测。否则 Neovim 的配色会退化成 256 色近似。

### 鼠标

```tmux
set -g mouse on
```

可以点选 pane、拖动边框调整大小、滚轮滚动。

### vi copy mode

```tmux
setw -g mode-keys vi
```

进入 copy mode 后用 `hjkl` 移动、`v` 选择、`y` 复制。

### 编号从 1 开始

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

`base-index` 只影响新窗口。会话恢复后可能仍停在 0，所以配置里有个 `run-shell` 重新编号：

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

### 历史与焦点

```tmux
set -g history-limit 200000
set -g focus-events on
```

`focus-events on` 让 Neovim 知道窗口是否聚焦，用于自动保存、autoread 等特性。

### 新窗口继承路径

```tmux
bind c new-window -c "#{pane_current_path}"
```

默认新窗口从 home 开始，改成继承当前 pane 的目录。

### 关闭 extended-keys

```tmux
set -g extended-keys off
```

原因：Kitty 的 CSI-u 协议会把 `Ctrl+J` 编码成 `ESC [ 106 ; 5 u`，远端不认识时会在命令行显示成乱码。关掉后按键仍用兼容编码。

## 本仓库的键位

| 键 | 作用 |
|---|---|
| `Prefix + c` | 新窗口（继承当前路径） |
| `Prefix + H` | pane 向左扩 5 格 |
| `Prefix + J` | pane 向下扩 5 格 |
| `Prefix + K` | pane 向上扩 5 格 |
| `Prefix + L` | pane 向右扩 5 格 |
| `Prefix + X` | 确认后结束 session |
| `Prefix + x` | 结束当前 pane |

`H/J/K/L` 用 `-r` 声明可重复，按住连续调整。

## TPM 插件

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
| tpm | 插件管理器 |
| tmux-sensible | 公认合理的默认值 |
| tmux-persist | 保存/恢复会话 |
| tmux-continuum | 自动保存、自动恢复 |
| tmux-yank | 复制到系统剪贴板 |
| vim-tmux-navigator | `Ctrl+h/j/k/l` 跨 Neovim/tmux 切换 |
| tmux-fzf | fzf 选择 session/window/pane |

**安装插件**：`Prefix + I`。**更新**：`Prefix + U`。

插件路径：

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

## 会话恢复

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

保存时把 vim/nvim 的运行状态也记录。恢复后有一个钩子重新编号窗口：

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

## 私有覆盖

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

文件不存在时静默跳过。公开配置不含私有内容，但允许本机追加。

## 常用命令

```bash
tmux source-file ~/.config/tmux/tmux.conf   # 重载配置
tmux list-sessions                          # 列出会话
tmux list-windows -a                        # 所有窗口
tmux show -g default-terminal               # 查选项
tmux capture-pane -p > scrollback.txt       # 导出当前 pane 内容
```

## 排错

**颜色不对**：三层检查——`echo $TERM`、`tmux show -g default-terminal`、`tmux show -g terminal-features`。

**插件没装**：`Prefix + I` 安装。检查 `~/.config/tmux/plugins/` 是否有目录。

**`Ctrl+h/j/k/l` 在 Neovim 里不切换 pane**：vim-tmux-navigator 需要 Neovim 侧也有对应插件。Neovim 配置里已包含。

**会话恢复后窗口编号从 0 开始**：后置钩子没执行。检查 `@persist-hook-post-restore-all` 是否被正确设置。

**`Prefix + X` 无反应**：可能和某个插件冲突。`tmux list-keys | grep -w X` 查看实际绑定。

**中文显示宽度错乱**：`tmux-256color` 需要正确编译的 terminfo。检查 `infocmp tmux-256color` 是否可用。

<!-- lang:en -->
> Summary: tmux is a terminal multiplexer; this repository's configuration handles true color, session restoration, pane navigation, and plugins.

# tmux

## Purpose

tmux creates persistent sessions in a terminal: processes keep running after an SSH disconnect and resume when you reconnect; terminals can be split into panes and windows; and multiple people can share a session.

This repository focuses on true color, mouse support, vi copy mode, session restoration, and pane navigation.

## Source and installation

| Item | Description |
|---|---|
| Source | System package manager |
| Configuration | `config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf` |
| Plugin manager | TPM (tmux plugin manager) |

## Basic usage

```bash
tmux                    # 新建会话
tmux new -s work        # 命名会话
tmux ls                 # 列出会话
tmux attach -t work     # 连接
tmux kill-session -t work
```

In tmux, press **prefix** (default `Ctrl+B`) before every shortcut.

## Configuration highlights in this repository

### True color

The three lines are all required: declare terminfo, tell applications RGB is supported, and override terminal capability detection. Without them, Neovim colors fall back to an approximate 256-color palette.

### Mouse

Click to select panes, drag borders to resize them, and scroll with the wheel.

### vi copy mode

In copy mode, use `hjkl` to move, `v` to select, and `y` to copy.

### Start numbering at 1

`base-index` affects only new windows. After session restoration, numbering may still start at 0, so the configuration runs a `run-shell` command to renumber them:

### History and focus

`focus-events on` lets Neovim know whether a window has focus, for features such as automatic saving and autoread.

### New windows inherit the current path

By default, new windows start in home. This changes them to inherit the current pane's directory.

### Disable extended-keys

Reason: Kitty's CSI-u protocol encodes `Ctrl+J` as `ESC [ 106 ; 5 u`. If the remote side does not recognize it, garbled text appears on the command line. When disabled, keys still use compatible encodings.

## Key bindings in this repository

| Key | Effect |
|---|---|
| `Prefix + c` | New window (inherits current path) |
| `Prefix + H` | Expand pane left by 5 cells |
| `Prefix + J` | Expand pane down by 5 cells |
| `Prefix + K` | Expand pane up by 5 cells |
| `Prefix + L` | Expand pane right by 5 cells |
| `Prefix + X` | End session after confirmation |
| `Prefix + x` | End current pane |

`H/J/K/L` are declared repeatable with `-r`, so you can hold them to resize continuously.

## TPM plugins

| Plugin | Effect |
|---|---|
| tpm | Plugin manager |
| tmux-sensible | Widely accepted sensible defaults |
| tmux-persist | Save/restore sessions |
| tmux-continuum | Automatic save and restore |
| tmux-yank | Copy to the system clipboard |
| vim-tmux-navigator | Switch between Neovim/tmux with `Ctrl+h/j/k/l` |
| tmux-fzf | Use fzf to select a session/window/pane |

**Install plugins**: `Prefix + I`. **Update**: `Prefix + U`.

## Session restoration

The saved state of vim/nvim is also recorded. A hook renumbers windows after restoration.

## Private overrides

The file is silently skipped if it does not exist. The public configuration contains no private content, but allows local additions.

## Common commands

## Troubleshooting

**Colors look wrong**: Check three layers—`echo $TERM`, `tmux show -g default-terminal`, and `tmux show -g terminal-features`.

**Plugins are missing**: Install with `Prefix + I`. Check for directories in `~/.config/tmux/plugins/`.

**`Ctrl+h/j/k/l` does not switch panes in Neovim**: vim-tmux-navigator also needs the corresponding Neovim plugin. It is included in the Neovim configuration.

**Window numbering starts at 0 after restoration**: The post-restore hook did not run. Check whether `@persist-hook-post-restore-all` was set correctly.

**`Prefix + X` does nothing**: A plugin may conflict. Check the actual binding with `tmux list-keys | grep -w X`.

**Chinese text has incorrect display width**: `tmux-256color` requires correctly compiled terminfo. Check whether `infocmp tmux-256color` works.

```bash
# Debian / Ubuntu
sudo apt install tmux
# Arch
pacman -S tmux
# macOS
brew install tmux
```

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
```

```tmux
set -g mouse on
```

```tmux
setw -g mode-keys vi
```

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

```tmux
set -g history-limit 200000
set -g focus-events on
```

```tmux
bind c new-window -c "#{pane_current_path}"
```

```tmux
set -g extended-keys off
```

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
```

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

```bash
tmux source-file ~/.config/tmux/tmux.conf   # 重载配置
tmux list-sessions                          # 列出会话
tmux list-windows -a                        # 所有窗口
tmux show -g default-terminal               # 查选项
tmux capture-pane -p > scrollback.txt       # 导出当前 pane 内容
```

<!-- lang:ja -->
> 要約：tmux はターミナルマルチプレクサです。このリポジトリの設定では True Color、セッション復元、pane 移動、プラグインを扱います。

# tmux

## 用途

tmux はターミナル内に永続セッションを作成します。SSH が切断されてもプロセスは動作し続け、再接続後に復元できます。ターミナルを複数の pane や window に分割でき、複数人で同じセッションを共有することもできます。

このリポジトリでは True Color、マウス、vi copy mode、セッション復元、pane 移動を中心に設定しています。

## 入手元とインストール

| 項目 | 説明 |
|---|---|
| 入手元 | システムのパッケージマネージャー |
| 設定 | `config/tmux/tmux.conf` → `~/.config/tmux/tmux.conf` |
| プラグイン管理 | TPM（tmux plugin manager） |

## 基本的な使い方

```bash
tmux                    # 新建会话
tmux new -s work        # 命名会话
tmux ls                 # 列出会话
tmux attach -t work     # 连接
tmux kill-session -t work
```

tmux では、すべてのショートカットキーの前に **prefix**（既定は `Ctrl+B`）を押します。

## このリポジトリの設定の要点

### True Color

3行すべてが必要です。terminfo を宣言し、アプリケーションに RGB 対応を伝え、端末機能の検出を上書きします。設定しないと Neovim の色は 256 色相当へ劣化します。

### マウス

pane のクリック選択、境界のドラッグによるサイズ変更、ホイールでのスクロールができます。

### vi copy mode

copy mode では `hjkl` で移動し、`v` で選択し、`y` でコピーします。

### 番号を1から開始

`base-index` が適用されるのは新しい window だけです。セッション復元後は番号が0のままの場合があるため、設定では `run-shell` で再採番します。

### 履歴とフォーカス

`focus-events on` により、Neovim が window のフォーカス状態を把握できます。自動保存や autoread などの機能に使われます。

### 新しい window に現在のパスを引き継ぐ

既定では新しい window は home から始まります。この設定では現在の pane のディレクトリを引き継ぎます。

### extended-keys を無効にする

理由：Kitty の CSI-u プロトコルは `Ctrl+J` を `ESC [ 106 ; 5 u` としてエンコードします。リモート側が認識しない場合、コマンドラインに文字化けが表示されます。無効にすると、キーは互換性のある形式で送られます。

## このリポジトリのキー割り当て

| キー | 効果 |
|---|---|
| `Prefix + c` | 新しい window（現在のパスを継承） |
| `Prefix + H` | pane を左へ5セル広げます |
| `Prefix + J` | pane を下へ5セル広げます |
| `Prefix + K` | pane を上へ5セル広げます |
| `Prefix + L` | pane を右へ5セル広げます |
| `Prefix + X` | 確認後に session を終了します |
| `Prefix + x` | 現在の pane を終了します |

`H/J/K/L` は `-r` で連続入力可能にしているため、押し続けてサイズを調整できます。

## TPM プラグイン

| プラグイン | 効果 |
|---|---|
| tpm | プラグインマネージャー |
| tmux-sensible | 広く妥当とされる既定値 |
| tmux-persist | セッションの保存／復元 |
| tmux-continuum | 自動保存と自動復元 |
| tmux-yank | システムのクリップボードへコピー |
| vim-tmux-navigator | `Ctrl+h/j/k/l` で Neovim/tmux 間を移動 |
| tmux-fzf | fzf で session/window/pane を選択 |

**プラグインのインストール**：`Prefix + I`。**更新**：`Prefix + U`。

## セッション復元

保存時に vim/nvim の実行状態も記録します。復元後に window の番号を振り直すフックがあります。

## プライベート上書き

ファイルがない場合は何も表示せずスキップします。公開設定にプライベート情報は含めず、ローカルでの追加を許可します。

## よく使うコマンド

## トラブルシューティング

**色が正しくありません**：3段階で確認します—`echo $TERM`、`tmux show -g default-terminal`、`tmux show -g terminal-features`。

**プラグインがありません**：`Prefix + I` でインストールします。`~/.config/tmux/plugins/` にディレクトリがあるか確認します。

**Neovim 内で `Ctrl+h/j/k/l` による pane 移動ができません**：vim-tmux-navigator には Neovim 側の対応プラグインも必要です。Neovim 設定には含まれています。

**復元後に window 番号が0から始まります**：復元後フックが実行されていません。`@persist-hook-post-restore-all` が正しく設定されているか確認します。

**`Prefix + X` が反応しません**：プラグインと競合している可能性があります。`tmux list-keys | grep -w X` で実際の割り当てを確認します。

**中国語の表示幅が乱れます**：`tmux-256color` には正しくコンパイルされた terminfo が必要です。`infocmp tmux-256color` が使えるか確認します。

```bash
# Debian / Ubuntu
sudo apt install tmux
# Arch
pacman -S tmux
# macOS
brew install tmux
```

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
```

```tmux
set -g mouse on
```

```tmux
setw -g mode-keys vi
```

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

```tmux
set -g history-limit 200000
set -g focus-events on
```

```tmux
bind c new-window -c "#{pane_current_path}"
```

```tmux
set -g extended-keys off
```

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
```

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions ... tmux move-window -r ...'
```

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

```bash
tmux source-file ~/.config/tmux/tmux.conf   # 重载配置
tmux list-sessions                          # 列出会话
tmux list-windows -a                        # 所有窗口
tmux show -g default-terminal               # 查选项
tmux capture-pane -p > scrollback.txt       # 导出当前 pane 内容
```
