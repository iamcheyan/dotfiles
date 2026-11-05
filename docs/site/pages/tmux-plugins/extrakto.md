> 摘要：extrakto 用 fzf 模糊搜索当前分屏中的单词、路径、URL 或整行内容，支持一键插入命令行或复制。

# extrakto

## 用途

当终端上方刚刚输出了一个很长的分支名、容器 ID、文件路径或报错信息，而你马上要在下一条命令里用到它时，`extrakto` 允许直接按下 `Prefix + Tab` 弹出 `fzf`，模糊搜索当前分屏里的所有文本片段，回车即可插入到当前命令行。

## 本仓库配置

```tmux
set -g @plugin 'laktak/extrakto'
set -g @extrakto_clip_tool "$HOME/dotfiles/scripts/tmux-copy"
set -g @extrakto_clip_tool_run "fg"
```

| 选项 | 值 | 说明 |
|---|---|---|
| 默认触发键 | `Prefix + Tab` | 打开 extrakto 的 fzf 提取面板 |
| `@extrakto_clip_tool` | `$HOME/dotfiles/scripts/tmux-copy` | 复用本仓库统一的剪贴板脚本（同时支持本地剪贴板与 SSH OSC 52） |
| `@extrakto_clip_tool_run` | `fg` | 在前台执行剪贴板脚本，确保 OSC 52 序列能发送到当前客户端终端 |

## 界面按键

打开 `Prefix + Tab` 后：

| 键 | 作用 |
|---|---|
| 直接输入字符 | 模糊过滤当前屏幕上的候选词 |
| `Tab` | 将选中内容**直接插入**到当前 pane 的命令行 |
| `Enter` | 将选中内容**复制**到系统剪贴板 |
| `Ctrl+f` | 切换提取模式：`word`（单词/令牌）→ `path`（路径）→ `url`（链接）→ `line`（整行） |
| `Ctrl+g` | 切换抓取范围（当前屏幕 / 全部历史滚屏 / 所有 pane） |
| `Esc` | 退出 |

<!-- lang:en -->

> Summary: extrakto uses fzf to fuzzy-search words, paths, URLs, or lines from the current pane and insert or copy them.

# extrakto

## Purpose

When a command outputs a long branch name, container ID, file path, or URL that you immediately need in your next command, `extrakto` lets you press `Prefix + Tab` to fuzzy-search tokens from the pane in `fzf` and insert or copy the match.

## Configuration in this repository

```tmux
set -g @plugin 'laktak/extrakto'
set -g @extrakto_clip_tool "$HOME/dotfiles/scripts/tmux-copy"
set -g @extrakto_clip_tool_run "fg"
```

| Option | Value | Description |
|---|---|---|
| Trigger key | `Prefix + Tab` | Opens the extrakto fzf popup |
| `@extrakto_clip_tool` | `$HOME/dotfiles/scripts/tmux-copy` | Routes copying through the repository's unified local + OSC 52 clipboard helper |
| `@extrakto_clip_tool_run` | `fg` | Runs the clipboard helper in the foreground so OSC 52 reaches the active client |

## Keys inside extrakto

| Key | Effect |
|---|---|
| Typing | Fuzzy-filter candidates from the pane |
| `Tab` | **Insert** the selected text into the current pane's command line |
| `Enter` | **Copy** the selected text to the clipboard |
| `Ctrl+f` | Cycle filter mode (`word` → `path` → `url` → `line`) |
| `Ctrl+g` | Cycle grab area (recent / full history / all panes) |
| `Esc` | Cancel |

<!-- lang:ja -->

> 要約：extrakto は現在の pane 内の単語・パス・URL・行を fzf でファジー検索し、コマンドラインへの挿入やコピーを行います。

# extrakto

## 用途

直前の出力に含まれる長いブランチ名、コンテナ ID、ファイルパス、URL などを次のコマンドですぐ使いたいとき、`Prefix + Tab` で `fzf` を開き、画面内のテキストを絞り込んでそのまま挿入・コピーできます。

## 本リポジトリの設定

```tmux
set -g @plugin 'laktak/extrakto'
set -g @extrakto_clip_tool "$HOME/dotfiles/scripts/tmux-copy"
set -g @extrakto_clip_tool_run "fg"
```

## 操作キー

| キー | 役割 |
|---|---|
| 文字入力 | 候補のファジー絞り込み |
| `Tab` | 選択した文字列を現在の pane に**挿入** |
| `Enter` | 選択した文字列をクリップボードに**コピー** |
| `Ctrl+f` | 抽出モードの切り替え（`word` → `path` → `url` → `line`） |
| `Ctrl+g` | 取得範囲の切り替え |
| `Esc` | 終了 |
