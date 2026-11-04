> 摘要：tmux.conf 的选项分组、键位、TPM 插件和会话恢复策略。

# tmux 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/tmux/tmux.conf` |
| 部署目标 | `~/.config/tmux/tmux.conf` |
| 是否自动链接 | 是 |

## 终端能力

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
set -g status-style "bg=#00aaaa,fg=#000000"
```

| 行 | 作用 |
|---|---|
| `default-terminal` | 声明 tmux 使用 256 色 terminfo |
| `terminal-features` | 告诉应用支持 RGB |
| `terminal-overrides` | 覆盖终端能力检测 |
| `status-style` | 状态栏青底黑字，与 Neovim Blue 的状态区一致 |

三行真彩色配置缺一不可。只有 `default-terminal` 时，Neovim 的 `termguicolors` 可能不生效。

## 鼠标与键位

```tmux
set -g mouse on
setw -g mode-keys vi
```

`mouse on` 让鼠标可以选 pane、拖边框、滚动。`mode-keys vi` 让 copy mode 用 `hjkl`。

## 编号

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

从 1 开始编号，关闭窗口后不留空号。

`base-index` 只影响新窗口。会话恢复后可能仍是 0，所以有这段：

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

重载配置时统一重编号。

## 历史与焦点

```tmux
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| 选项 | 作用 |
|---|---|
| `history-limit 200000` | 回滚缓冲 20 万行 |
| `focus-events on` | 让 Neovim 感知焦点变化（autoread、自动保存） |
| `allow-passthrough on` | 允许 Kitty 图形协议和 OSC 52 穿过 tmux |

## 环境变量传递

```tmux
set -ga update-environment "SSH_CLIENT SSH_CONNECTION SSH_TTY"
```

新 pane 会继承这些变量，用于判断是否在 SSH 会话中。

## 窗口

```tmux
bind c new-window -c "#{pane_current_path}"
set -g automatic-rename-format '#{b:pane_current_path}'
```

`bind c` 让新窗口继承当前 pane 的目录，而不是从 home 开始。`automatic-rename-format` 用目录名做窗口名。

## 边框

```tmux
set -g pane-border-style fg=#000080
set -g pane-active-border-style fg=#55ffff
```

非活动边框用深蓝，活动边框用青色，和 Neovim Blue 的分隔线一致。

## 关闭 extended-keys

```tmux
set -g extended-keys off
```

**原因**：Kitty 的 CSI-u 协议会把 `Ctrl+J` 编码成 `ESC [ 106 ; 5 u`。远端 shell 或粘贴工具不认识时，序列会作为可见文本泄漏到命令行。

关掉后普通 Ctrl 和方向键仍用兼容编码。

## pane 调整

```tmux
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

`-r` 表示可重复：按住不放会连续调整，每次 5 格。

## 结束会话与快捷操作

```tmux
set -g detach-on-destroy off
set -g word-separators " ()[]{}<>\"'"

bind e run-shell 'tmp=$(mktemp "${TMPDIR:-/tmp}/tmux-scrollback.XXXXXX.log") || exit 1; tmux capture-pane -p -J -S - -E - -t "#{pane_id}" | awk "{ lines[NR] = \$0; if (\$0 != \"\") last = NR } END { for (i = 1; i <= last; i++) print lines[i] }" > "$tmp"; tmux new-window -c "#{pane_current_path}" -n "scrollback" "nvim +\"normal! G\" -c \"nnoremap <buffer> <silent> q :q!<CR>\" \"$tmp\"; rm -f \"$tmp\""'
bind B switch-client -l
bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "lazygit"
bind M-t display-popup -E -w 85% -h 85% -d "#{pane_current_path}" "$SHELL"
bind C-y setw synchronize-panes \; display-message "synchronize-panes: #{?pane_synchronized,ON,OFF}"
bind -T copy-mode-vi [ send-keys -X previous-prompt
bind -T copy-mode-vi ] send-keys -X next-prompt
bind X confirm-before -p "Destroy session #S and its saved state? (y/n)" "run-shell '\"$HOME/dotfiles/scripts/tmux-destroy-session\" \"#{session_name}\"'"
```

| 选项 / 快捷键 | 作用 |
|---|---|
| `detach-on-destroy off` | 关闭当前 session 最后一个窗口时不退回外层终端，而是自动切到其余活跃 session |
| `word-separators` | 去掉 `/`、`.`、`:`、`-`、`_`、`@`，使鼠标双击能一次性选中完整的文件路径或 URL |
| `Prefix + e` | 抓取当前分屏全部历史滚屏（自动拼接折行）并在 Neovim 中打开，定位到末尾，按 `q` 一键关闭 |
| `Prefix + B` | 在最近使用的两个 session 之间来回秒切（与 `Prefix + b` 切最近 window 对称） |
| `Prefix + g` | 在当前分屏目录弹出 90% 大小的居中浮动 `lazygit` |
| `Prefix + Alt+t` | 在当前分屏目录弹出 85% 大小的居中临时浮动 Shell |
| `Prefix + Ctrl+y` | 切换当前窗口所有分屏同步输入（`synchronize-panes`），并在状态栏提示开关状态 |
| `copy-mode-vi` 下 `[` / `]` | 在上一条 / 下一条 Shell 提示符之间快速跳转 |
| `Prefix + X` | 确认后彻底销毁当前 session 并清理其 `tmux-persist` 保存快照 |
| 普通右键 / `Alt + 右键` | 弹出完全一致的完整分屏菜单；当分屏内程序接管了鼠标（如 `nvim`、`pi`）时，普通右键交给程序，`Alt + 右键` 强制弹出同一份 tmux 菜单 |

## TPM 插件

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @plugin 'laktak/extrakto'
set -g @plugin 'rickstaa/tmux-notify'

run '~/.config/tmux/plugins/tpm/tpm'
```

| 插件 | 快捷键 | 作用 |
|---|---|---|
| tpm | `Prefix + I` / `U` | 插件管理器 |
| tmux-sensible | — | 公认合理的默认值 |
| tmux-persist | `Prefix + Ctrl+s` / `Ctrl+r` | 保存/恢复会话 |
| tmux-continuum | 自动 | 自动保存与恢复 |
| tmux-yank | `y` | 复制到系统剪贴板 |
| vim-tmux-navigator | `Ctrl+h/j/k/l` | 跨 Neovim/tmux 切换焦点 |
| tmux-fzf | `Prefix + F` | fzf 选择 session/window/pane |
| tmux-thumbs | `Prefix + T` | 屏幕路径/Hash/URL 双字母标签无鼠标复制 |
| extrakto | `Prefix + Tab` | fzf 模糊提取当前屏幕上的词条、路径或整行 |
| tmux-notify | `Prefix + N` / `Alt+N` | 后台分屏长耗时命令完成提醒（保留 `Prefix + m` 标记分屏） |

首次安装：`Prefix + I`。更新：`Prefix + U`。

## 会话恢复

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

保存时记录 vim/nvim 的运行状态，恢复时尝试还原编辑现场。

恢复后重新编号：

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

## 私有覆盖

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

两个接入点：

| 文件 | 时机 |
|---|---|
| `private.conf` | 在插件声明之前，可覆盖前面的选项 |
| `private-after.conf` | 在所有配置之后，可覆盖包括插件设置 |

文件不存在时静默跳过。

## 常用命令

```bash
tmux source-file ~/.config/tmux/tmux.conf    # 重载
tmux list-keys                                # 所有绑定
tmux list-keys | grep -w X                    # 查某个键
tmux show -g                                  # 所有全局选项
tmux show -g default-terminal                 # 查单个
```

## 排错

**颜色不对**：三层检查 `echo $TERM`、`tmux show -g default-terminal`、`tmux show -g terminal-features`。

**插件没装**：`Prefix + I`。检查 `~/.config/tmux/plugins/`。

**`Ctrl+h/j/k/l` 不切 pane**：vim-tmux-navigator 需要 Neovim 侧配合。Neovim 配置已含。

**窗口编号从 0 开始**：后置钩子没执行。手动 `tmux move-window -r`。

**`Prefix + X` 无反应**：可能被插件覆盖。`tmux list-keys | grep -w X` 查看。

**中文宽度错乱**：`tmux-256color` 的 terminfo 不完整。`infocmp tmux-256color` 检查。

**粘贴内容错乱**：`extended-keys off` 已处理大部分情况。仍有问题时检查终端的 bracketed paste 设置。

<!-- lang:en -->
> Summary: The option groups, key bindings, TPM plugins, and session restoration strategy in `tmux.conf`.

# tmux Configuration

## File Locations

| Item | Path |
|---|---|
| Repository source | `config/tmux/tmux.conf` |
| Deployment target | `~/.config/tmux/tmux.conf` |
| Automatically linked | Yes |

## Terminal Capabilities

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
set -g status-style "bg=#00aaaa,fg=#000000"
```

| Line | Effect |
|---|---|
| `default-terminal` | Declares that tmux uses 256-color terminfo |
| `terminal-features` | Tells applications that RGB is supported |
| `terminal-overrides` | Overrides terminal capability detection |
| `status-style` | Cyan background with black text, matching the Neovim Blue status area |

All three true-color settings are required. With only `default-terminal`, Neovim's `termguicolors` may not work.

## Mouse and Keys

```tmux
set -g mouse on
setw -g mode-keys vi
```

`mouse on` lets you select panes, drag borders, and scroll. `mode-keys vi` makes copy mode use `hjkl`.

## Numbering

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

Numbering starts at 1, and closing a window does not leave a gap.

`base-index` only affects new windows. After restoring a session, numbering may still start at 0, so this block is included:

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

Reloading the configuration renumbers all windows.

## History and Focus

```tmux
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| Option | Effect |
|---|---|
| `history-limit 200000` | Scrollback buffer of 200,000 lines |
| `focus-events on` | Lets Neovim detect focus changes (autoread, autosave) |
| `allow-passthrough on` | Lets the Kitty graphics protocol and OSC 52 pass through tmux |

## Passing Environment Variables

```tmux
set -ga update-environment "SSH_CLIENT SSH_CONNECTION SSH_TTY"
```

New panes inherit these variables, which are used to determine whether the session is over SSH.

## Windows

```tmux
bind c new-window -c "#{pane_current_path}"
set -g automatic-rename-format '#{b:pane_current_path}'
```

`bind c` makes a new window inherit the current pane's directory instead of starting in home. `automatic-rename-format` uses the directory name as the window name.

## Borders

```tmux
set -g pane-border-style fg=#000080
set -g pane-active-border-style fg=#55ffff
```

Inactive borders are dark blue and the active border is cyan, matching the Neovim Blue separators.

## Disable extended-keys

```tmux
set -g extended-keys off
```

**Reason**: Kitty's CSI-u protocol encodes `Ctrl+J` as `ESC [ 106 ; 5 u`. If a remote shell or paste tool does not recognize it, the sequence can leak into the command line as visible text.

When disabled, ordinary Ctrl and arrow keys still use compatible encodings.

## Resizing Panes

```tmux
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

`-r` means repeatable: holding the key continuously resizes by 5 cells at a time.

## Ending a Session and Quick Actions

```tmux
set -g detach-on-destroy off
set -g word-separators " ()[]{}<>\"'"

bind e run-shell 'tmp=$(mktemp "${TMPDIR:-/tmp}/tmux-scrollback.XXXXXX.log") || exit 1; tmux capture-pane -p -J -S - -E - -t "#{pane_id}" | awk "{ lines[NR] = \$0; if (\$0 != \"\") last = NR } END { for (i = 1; i <= last; i++) print lines[i] }" > "$tmp"; tmux new-window -c "#{pane_current_path}" -n "scrollback" "nvim +\"normal! G\" -c \"nnoremap <buffer> <silent> q :q!<CR>\" \"$tmp\"; rm -f \"$tmp\""'
bind B switch-client -l
bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "lazygit"
bind M-t display-popup -E -w 85% -h 85% -d "#{pane_current_path}" "$SHELL"
bind C-y setw synchronize-panes \; display-message "synchronize-panes: #{?pane_synchronized,ON,OFF}"
bind -T copy-mode-vi [ send-keys -X previous-prompt
bind -T copy-mode-vi ] send-keys -X next-prompt
bind X confirm-before -p "Destroy session #S and its saved state? (y/n)" "run-shell '\"$HOME/dotfiles/scripts/tmux-destroy-session\" \"#{session_name}\"'"
```

| Option / Key | Effect |
|---|---|
| `detach-on-destroy off` | Switch to another active session instead of detaching when closing the last window |
| `word-separators` | Omits `/`, `.`, `:`, `-`, `_`, `@` so double-clicking selects full file paths and URLs |
| `Prefix + e` | Capture full pane scrollback (joining wrapped lines) and open in Neovim at the bottom (`q` to close) |
| `Prefix + B` | Toggle between the two most recently used sessions |
| `Prefix + g` | Open a centered 90% floating `lazygit` popup in the current pane directory |
| `Prefix + Alt+t` | Open a centered 85% floating shell popup in the current pane directory |
| `Prefix + Ctrl+y` | Toggle `synchronize-panes` across all panes in the current window |
| `[` / `]` in `copy-mode-vi` | Jump to previous / next shell prompt |
| `Prefix + X` | Destroy the current session and purge its `tmux-persist` snapshots after confirmation |
| Right-click / `Alt + Right-click` | Expose the exact same full pane menu; when an app captures the mouse (`nvim`, `pi`), normal right-click goes to the app while `Alt + Right-click` opens the tmux menu |

## TPM Plugins

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @plugin 'laktak/extrakto'
set -g @plugin 'rickstaa/tmux-notify'

run '~/.config/tmux/plugins/tpm/tpm'
```

| Plugin | Key | Effect |
|---|---|---|
| tpm | `Prefix + I` / `U` | Plugin manager |
| tmux-sensible | — | Widely accepted sensible defaults |
| tmux-persist | `Prefix + Ctrl+s` / `Ctrl+r` | Save/restore sessions |
| tmux-continuum | Auto | Automatic saving and restoring |
| tmux-yank | `y` | Copy to the system clipboard |
| vim-tmux-navigator | `Ctrl+h/j/k/l` | Navigate between Neovim and tmux |
| tmux-fzf | `Prefix + F` | Select sessions/windows/panes with fzf |
| tmux-thumbs | `Prefix + T` | Two-letter hint labels for mouseless copying |
| extrakto | `Prefix + Tab` | Fuzzy-extract words, paths, or lines with fzf |
| tmux-notify | `Prefix + N` / `Alt+N` | Alert when background pane commands finish |

First install: `Prefix + I`. Update: `Prefix + U`.

## Session Restoration

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

When saving, the running state of vim/nvim is recorded; restoration then attempts to restore the editing context.

Renumber after restoration:

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

## Private Overrides

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

Two integration points:

| File | When |
|---|---|
| `private.conf` | Before plugin declarations; can override earlier options |
| `private-after.conf` | After all configuration; can override even plugin settings |

Both are silently skipped when the file does not exist.

## Common Commands

```bash
tmux source-file ~/.config/tmux/tmux.conf    # 重载
tmux list-keys                                # 所有绑定
tmux list-keys | grep -w X                    # 查某个键
tmux show -g                                  # 所有全局选项
tmux show -g default-terminal                 # 查单个
```

## Troubleshooting

**Colors are wrong**: Check the three layers with `echo $TERM`, `tmux show -g default-terminal`, and `tmux show -g terminal-features`.

**Plugins are not installed**: Press `Prefix + I`. Check `~/.config/tmux/plugins/`.

**`Ctrl+h/j/k/l` does not switch panes**: vim-tmux-navigator needs cooperation from the Neovim side. The Neovim configuration already includes it.

**Window numbering starts at 0**: The post-restore hook did not run. Run `tmux move-window -r` manually.

**`Prefix + X` does nothing**: A plugin may have overridden it. Check with `tmux list-keys | grep -w X`.

**CJK character widths are wrong**: The `tmux-256color` terminfo may be incomplete. Check with `infocmp tmux-256color`.

**Pasted text is corrupted**: `extended-keys off` handles most cases. If the problem persists, check the terminal's bracketed paste setting.

<!-- lang:ja -->
> 要約：`tmux.conf` の設定グループ、キー割り当て、TPM プラグイン、セッション復元方針について説明します。

# tmux の設定

## ファイルの場所

| 項目 | パス |
|---|---|
| リポジトリのソース | `config/tmux/tmux.conf` |
| 配置先 | `~/.config/tmux/tmux.conf` |
| 自動リンク | はい |

## 端末機能

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",*:RGB"
set -as terminal-overrides ",*:Tc"
set -g status-style "bg=#00aaaa,fg=#000000"
```

| 行 | 効果 |
|---|---|
| `default-terminal` | tmux が 256 色の terminfo を使うことを宣言します |
| `terminal-features` | RGB に対応していることをアプリケーションに伝えます |
| `terminal-overrides` | 端末機能の検出結果を上書きします |
| `status-style` | シアン背景に黒文字を使い、Neovim Blue のステータス領域に合わせます |

真のカラー設定 3 行はすべて必要です。`default-terminal` だけでは、Neovim の `termguicolors` が動作しない場合があります。

## マウスとキー

```tmux
set -g mouse on
setw -g mode-keys vi
```

`mouse on` にすると pane の選択、境界線のドラッグ、スクロールができます。`mode-keys vi` にすると copy mode で `hjkl` を使います。

## 番号付け

```tmux
set -g base-index 1
setw -g pane-base-index 1
set -g renumber-windows on
```

番号は 1 から始まり、ウィンドウを閉じても番号に空きが残りません。

`base-index` が適用されるのは新しいウィンドウだけです。セッション復元後も 0 のままの場合があるため、次の設定を入れています。

```tmux
run-shell 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

設定を再読み込みすると、ウィンドウ番号をまとめて振り直します。

## 履歴とフォーカス

```tmux
set -g history-limit 200000
set -g focus-events on
set -g allow-passthrough on
```

| オプション | 効果 |
|---|---|
| `history-limit 200000` | 20 万行のスクロールバックバッファーを設定します |
| `focus-events on` | Neovim がフォーカス変更を検知できるようにします（autoread、autosave） |
| `allow-passthrough on` | Kitty の画像プロトコルと OSC 52 を tmux 経由で通します |

## 環境変数の引き継ぎ

```tmux
set -ga update-environment "SSH_CLIENT SSH_CONNECTION SSH_TTY"
```

新しい pane はこれらの変数を引き継ぎ、SSH セッションかどうかの判定に使います。

## ウィンドウ

```tmux
bind c new-window -c "#{pane_current_path}"
set -g automatic-rename-format '#{b:pane_current_path}'
```

`bind c` を使うと、新しいウィンドウは home ではなく現在の pane のディレクトリから始まります。`automatic-rename-format` はディレクトリ名をウィンドウ名に使います。

## 境界線

```tmux
set -g pane-border-style fg=#000080
set -g pane-active-border-style fg=#55ffff
```

非アクティブな境界線はダークブルー、アクティブな境界線はシアンです。Neovim Blue の区切り線と揃えています。

## extended-keys を無効化

```tmux
set -g extended-keys off
```

**理由**：Kitty の CSI-u プロトコルでは `Ctrl+J` が `ESC [ 106 ; 5 u` としてエンコードされます。リモートシェルや貼り付けツールが認識しない場合、このシーケンスが可視テキストとしてコマンドラインに漏れることがあります。

無効にしても、通常の Ctrl キーと矢印キーは互換性のあるエンコードを使います。

## pane のサイズ変更

```tmux
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5
```

`-r` は繰り返し可能という意味です。キーを押し続けると、5 セルずつ連続して調整します。

## セッション終了とショートカット操作

```tmux
set -g detach-on-destroy off
set -g word-separators " ()[]{}<>\"'"

bind e run-shell 'tmp=$(mktemp "${TMPDIR:-/tmp}/tmux-scrollback.XXXXXX.log") || exit 1; tmux capture-pane -p -J -S - -E - -t "#{pane_id}" | awk "{ lines[NR] = \$0; if (\$0 != \"\") last = NR } END { for (i = 1; i <= last; i++) print lines[i] }" > "$tmp"; tmux new-window -c "#{pane_current_path}" -n "scrollback" "nvim +\"normal! G\" -c \"nnoremap <buffer> <silent> q :q!<CR>\" \"$tmp\"; rm -f \"$tmp\""'
bind B switch-client -l
bind g display-popup -E -w 90% -h 90% -d "#{pane_current_path}" "lazygit"
bind M-t display-popup -E -w 85% -h 85% -d "#{pane_current_path}" "$SHELL"
bind C-y setw synchronize-panes \; display-message "synchronize-panes: #{?pane_synchronized,ON,OFF}"
bind -T copy-mode-vi [ send-keys -X previous-prompt
bind -T copy-mode-vi ] send-keys -X next-prompt
bind X confirm-before -p "Destroy session #S and its saved state? (y/n)" "run-shell '\"$HOME/dotfiles/scripts/tmux-destroy-session\" \"#{session_name}\"'"
```

| オプション / キー | 効果 |
|---|---|
| `detach-on-destroy off` | 最後のウィンドウを閉じたとき tmux を終了せず、他のアクティブな session に切り替えます |
| `word-separators` | `/`、`.`、`:`、`-`、`_`、`@` を除外し、ダブルクリックでパスや URL 全体を選択できるようにします |
| `Prefix + e` | 現在の pane の全スクロールバックを Neovim で開き、末尾へ移動します（`q` で終了） |
| `Prefix + B` | 直前に使っていた session と交互に切り替えます |
| `Prefix + g` | 現在のディレクトリで `lazygit` のフローティングポップアップを開きます |
| `Prefix + Alt+t` | 現在のディレクトリで一時シェルのフローティングポップアップを開きます |
| `Prefix + Ctrl+y` | 現在のウィンドウの全 pane への同時入力（`synchronize-panes`）を切り替えます |
| `copy-mode-vi` の `[` / `]` | 前後のシェルプロンプトへジャンプします |
| `Prefix + X` | 確認後、現在の session と `tmux-persist` の保存スナップショットを完全に削除します |
| 右クリック / `Alt + 右クリック` | 同一のフルメニューを表示します（アプリがマウスを使用中は `Alt + 右クリック` で強制表示） |

## TPM プラグイン

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'

set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'
set -g @plugin 'fcsonline/tmux-thumbs'
set -g @plugin 'laktak/extrakto'
set -g @plugin 'rickstaa/tmux-notify'

run '~/.config/tmux/plugins/tpm/tpm'
```

| プラグイン | キー | 効果 |
|---|---|---|
| tpm | `Prefix + I` / `U` | プラグイン管理ツール |
| tmux-sensible | — | 広く妥当とされる既定値 |
| tmux-persist | `Prefix + Ctrl+s` / `Ctrl+r` | セッションの保存／復元 |
| tmux-continuum | 自動 | 自動保存と復元 |
| tmux-yank | `y` | システムクリップボードへコピー |
| vim-tmux-navigator | `Ctrl+h/j/k/l` | Neovim と tmux の間を移動します |
| tmux-fzf | `Prefix + F` | fzf で session/window/pane を選択します |
| tmux-thumbs | `Prefix + T` | 2 文字ヒントラベルでパスやハッシュをコピーします |
| extrakto | `Prefix + Tab` | fzf で画面内の単語・パス・URL を抽出します |
| tmux-notify | `Prefix + N` / `Alt+N` | バックグラウンド pane のコマンド完了を通知します |

初回インストール：`Prefix + I`。更新：`Prefix + U`。

## セッションの復元

```tmux
set -g @persist-strategy-vim 'session'
set -g @persist-strategy-nvim 'session'
```

保存時に vim/nvim の実行状態を記録し、復元時に編集状態を戻そうとします。

復元後に番号を振り直します。

```tmux
set -g @persist-hook-post-restore-all 'tmux list-sessions 2>/dev/null | cut -d: -f1 | while read -r s; do tmux move-window -r -t "$s:" 2>/dev/null || true; done'
```

## プライベート上書き設定

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

接続箇所は 2 つあります。

| ファイル | 読み込み時点 |
|---|---|
| `private.conf` | プラグイン宣言より前。先行する設定を上書きできます |
| `private-after.conf` | すべての設定の後。プラグイン設定も含めて上書きできます |

ファイルがない場合は何も表示せずに読み込みを省略します。

## よく使うコマンド

```bash
tmux source-file ~/.config/tmux/tmux.conf    # 重载
tmux list-keys                                # 所有绑定
tmux list-keys | grep -w X                    # 查某个键
tmux show -g                                  # 所有全局选项
tmux show -g default-terminal                 # 查单个
```

## トラブルシューティング

**色が正しくありません**：`echo $TERM`、`tmux show -g default-terminal`、`tmux show -g terminal-features` で 3 層を確認します。

**プラグインがインストールされていません**：`Prefix + I` を押します。`~/.config/tmux/plugins/` を確認してください。

**`Ctrl+h/j/k/l` で pane を切り替えられません**：vim-tmux-navigator は Neovim 側の連携も必要です。Neovim の設定には含まれています。

**ウィンドウ番号が 0 から始まります**：復元後の hook が実行されていません。`tmux move-window -r` を手動で実行してください。

**`Prefix + X` が動作しません**：プラグインに上書きされた可能性があります。`tmux list-keys | grep -w X` で確認してください。

**中国語文字の幅が崩れます**：`tmux-256color` の terminfo が不完全な可能性があります。`infocmp tmux-256color` で確認してください。

**貼り付けた内容が崩れます**：`extended-keys off` で大部分の問題に対処しています。解決しない場合は、端末の bracketed paste 設定を確認してください。
