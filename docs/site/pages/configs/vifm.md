> 摘要：vifmrc 的选项、完整键位表、图标规则和 vifm-copy 剪贴板脚本。

# Vifm 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/vifm/vifmrc` |
| 部署目标 | `~/.config/vifm/vifmrc` |
| 安装 | `init.sh` 必备工具清单（系统包管理器） |
| 配色 | `config/vifm/colors/papercolor-dark.vifm` |
| 脚本 | `config/vifm/scripts/`（剪贴板与目录预览） |
| 是否自动链接 | 是（三条独立映射） |

当前 `papercolor-dark` 配色文件已改为与 Neovim 内置 Blue 主题使用的 Nostalgia 蓝色调一致：主面板为蓝底黄字，光标行用深蓝与青色强调，活动面板标题为绿底黑字，状态行使用青绿色。Vifm 支持真彩色终端时使用精确色值；256 色终端使用近似色。

## 选项

```vim
colorscheme papercolor-dark
set trash
set dotdirs=
set vicmd=nvim
set syscalls
set history=200
set followlinks
set number
set sortnumbers
set vimhelp
set timefmt=%Y-%m-%d\ %H:%M
set incsearch
set statusline="%t%= %A %10u:%-7g %15s %20d  "
set quickview
```

| 选项 | 作用 |
|---|---|
| `trash` | 删除移到回收站而非直接删 |
| `dotdirs=` | 控制隐藏目录显示（空值表示用默认） |
| `vicmd=nvim` | `:` 命令和编辑器用 nvim |
| `syscalls` | 允许系统调用（复制/移动用） |
| `history=200` | 命令历史条数 |
| `followlinks` | 进入软链接指向的目录 |
| `number` | 显示行号 |
| `sortnumbers` | 数字按数值排序（file2 在 file10 前） |
| `vimhelp` | 帮助用 Vim 风格导航 |
| `timefmt` | 时间显示格式 |
| `incsearch` | 搜索时实时跳转 |
| `quickview` | 右栏显示选中文件的预览（双栏布局不变） |

## 启动行为

启动时保持双栏：左栏是当前目录，右栏用 quick view 预览左栏选中的文件（文本、目录内容按 vifm 的预览规则显示）。不再有把右栏强制 `cd ~` 的自动命令，所以预览不会被打断。

启动时光标在左栏，右栏不再是固定目录，而是随左栏选择变化的预览区。需要临时单栏时按 `<Space>p`，再按一次恢复双栏。

### 目录预览

Vifm 默认把右栏目录预览画成递归树，深层目录和 `.git` 文件会让画面很密。本仓库将目录预览改为一行一个项目的简洁清单：安装了 `eza` 时显示 Nerd Font 图标、把目录排在前面，并按主题将目录标成青色、可执行项标成绿色；没有 `eza` 时用 `ls -1pA` 显示目录标记。文件预览仍使用 Vifm 原有方式。

```vim
fileviewer */ vifm-preview-dir %"c
```

预览脚本位于 `config/vifm/scripts/vifm-preview-dir`，Vifm 会把自己的 `scripts/` 目录加入命令搜索路径。

## 状态行

```vim
set statusline="%t%= %A %10u:%-7g %15s %20d  "
```

| 占位 | 含义 |
|---|---|
| `%t` | 文件名 |
| `%=` | 左右分隔 |
| `%A` | 当前模式 |
| `%10u` | 用户 |
| `%-7g` | 组 |
| `%15s` | 大小 |
| `%20d` | 日期 |

## 图标

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+="󰈔 :reg:"
set classify+=" ::*.lua::"
set classify+=" ::*.rs::"
set classify+=" ::*.go::"
set classify+=" ::*.py::"
set classify+=" ::*.js::"
set classify+=" ::*.ts::"
set classify+=" ::*.html::"
set classify+=" ::*.css::"
set classify+=" ::.git::"
set classify+=" ::*.zip::"
set classify+=" ::*.tar::"
set classify+=" ::*.png::"
set classify+=" ::*.mp4::"
set classify+=" ::*.mp3::"
set classify+="󰈙 ::*.md::"
set classify+=" ::*.json::"
```

`classify` 的语法：`图标 :类型:` 或 `图标 ::通配符::`。

图标只是显示前缀，**不改变文件名**。复制、重命名时用真实文件名。

## 键位

### 导航

| 键 | 动作 |
|---|---|
| `j` / `k` | 上下移动 |
| `h` / `l` | 上级 / 进入 |
| `o` | 映射为 `l`（进入） |
| `O` | `:edit` |
| `<Tab>` | 下一个 tab |
| `<S-Tab>` | 上一个 tab |
| `T` | 新建 tab |
| `X` | 关闭 tab |
| `<Space>p` | 单栏/双栏切换 |
| `q` | 退出 |
| `Q` | 强制退出 |

### 文件操作

| 键 | 动作 |
|---|---|
| `a` | 新建文件（`:touch`） |
| `r` | 重命名 |
| `d` | 移到 trash |
| `D` | 直接删除 |
| `y` | 复制（`yy`） |
| `x` | 剪切（`dd`） |
| `p` / `P` | 粘贴 |
| `.` | 切换 dotfiles |
| `s` | 打开 shell |
| `f` | 搜索（`/`） |
| `F` | 按类型筛选（`=`） |
| `n` / `N` | 下一个/上一个匹配 |

### 书签

| 键 | 动作 |
|---|---|
| `m` | 添加书签 |
| `'` | 列出书签 |
| `b` | 删除书签 |
| `B` | 强制删除书签 |

### 剪贴板

| 键 | 复制内容 |
|---|---|
| `cc` | 完整路径 |
| `cf` | 文件名 |
| `cd` | 父目录 |
| `cn` | 不含扩展名的文件名 |

实现：

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

| 占位 | 含义 |
|---|---|
| `%c` | 当前文件 |
| `:p` | 完整路径 |
| `:t` | 文件名部分 |
| `:h` | 去掉最后一段（父目录） |
| `:r` | 去掉扩展名 |

## vifm-copy

```sh
#!/usr/bin/env sh
set -eu

value=${1-}

if [ -n "${WAYLAND_DISPLAY-}" ] && command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$value" | wl-copy
elif [ -n "${DISPLAY-}" ] && command -v xclip >/dev/null 2>&1; then
  printf '%s' "$value" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$value" | xsel -ib
elif command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$value" | pbcopy
elif command -v clip.exe >/dev/null 2>&1; then
  printf '%s' "$value" | clip.exe
else
  printf 'vifm-copy: no clipboard command found\n' >&2
  exit 1
fi
```

按环境变量 + 命令存在性双重判断：

| 后端 | 条件 |
|---|---|
| `wl-copy` | `$WAYLAND_DISPLAY` 存在且命令可用 |
| `xclip` | `$DISPLAY` 存在且命令可用 |
| `xsel` | 命令可用（无环境检查） |
| `pbcopy` | 命令可用（macOS） |
| `clip.exe` | 命令可用（WSL） |

全都不满足时**报错退出**，不会静默失败。

## 验证

```bash
vifm --version
ls -l ~/.config/vifm/
~/.config/vifm/scripts/vifm-copy "test"
```

最后一条应该把 "test" 放进剪贴板。

## 排错

**图标乱码**：字体不是 Nerd Font。

**`cc` 没反应**：`vifm-copy` 找不到剪贴板后端。`command -v wl-copy xclip xsel pbcopy clip.exe` 检查。

**配色不对**：`config/vifm/colors/papercolor-dark.vifm` 没部署。

**`v` 退出后目录没变**：Vifm 非正常退出（被 kill）。

**trash 在哪**：`~/.local/share/vifm/Trash/`。

**右栏总是跳回 home**：这是 `autocmd WinEnter` 的设计，不是 bug。

<!-- lang:en -->
> Summary: The options and full key-binding table in `vifmrc`, icon rules, and the `vifm-copy` clipboard script.

# Vifm Configuration

## File Locations

| Item | Path |
|---|---|
| Repository source | `config/vifm/vifmrc` |
| Deployment target | `~/.config/vifm/vifmrc` |
| Installation | Required tools list in `init.sh` (system package manager) |
| Colorscheme | `config/vifm/colors/papercolor-dark.vifm` |
| Scripts | `config/vifm/scripts/` (clipboard and directory preview) |
| Automatically linked | Yes (three separate mappings) |

The current `papercolor-dark` colorscheme has been aligned with the Nostalgia blue tones used by Neovim's built-in Blue theme: the main panes use yellow text on a blue background, the cursor line is emphasized with dark blue and cyan, the active pane title uses black text on green, and the status line is cyan-green. Vifm uses exact color values in true-color terminals and approximations in 256-color terminals.

## Options

```vim
colorscheme papercolor-dark
set trash
set dotdirs=
set vicmd=nvim
set syscalls
set history=200
set followlinks
set number
set sortnumbers
set vimhelp
set timefmt=%Y-%m-%d\ %H:%M
set incsearch
set statusline="%t%= %A %10u:%-7g %15s %20d  "
set quickview
```

| Option | Effect |
|---|---|
| `trash` | Move deleted items to trash instead of deleting them directly |
| `dotdirs=` | Controls display of hidden directories (an empty value uses the default) |
| `vicmd=nvim` | Use nvim for `:` commands and as the editor |
| `syscalls` | Allow system calls (used for copying/moving) |
| `history=200` | Number of command-history entries |
| `followlinks` | Enter directories targeted by symlinks |
| `number` | Show line numbers |
| `sortnumbers` | Sort numbers numerically (`file2` before `file10`) |
| `vimhelp` | Use Vim-style navigation in help |
| `timefmt` | Time display format |
| `incsearch` | Jump as you type a search |
| `quickview` | Preview the selected file in the right pane (keeps the two-pane layout) |

## Startup Behavior

Startup keeps the two-pane layout: the left pane shows the current directory, and the right pane previews the file selected in the left pane (text and directory contents are shown according to Vifm's preview rules). There is no longer an automatic command that forces the right pane to `cd ~`, so it does not interrupt previews.

The cursor starts in the left pane. The right pane is no longer fixed to a directory; it becomes a preview area that follows the left-pane selection. Press `<Space>p` to temporarily use a single pane, then press it again to restore the two-pane view.

### Directory Preview

By default, Vifm renders directory previews in the right pane as a recursive tree, which can become cluttered with deeply nested directories and `.git` files. This repository changes directory previews to a simple one-item-per-line list: when `eza` is installed, it shows Nerd Font icons, sorts directories first, and colors directories cyan and executables green according to the theme; without `eza`, it uses `ls -1pA` to mark directories. File previews continue to use Vifm's original behavior.

```vim
fileviewer */ vifm-preview-dir %"c
```

The preview script is at `config/vifm/scripts/vifm-preview-dir`. Vifm adds its own `scripts/` directory to the command search path.

## Status Line

```vim
set statusline="%t%= %A %10u:%-7g %15s %20d  "
```

| Placeholder | Meaning |
|---|---|
| `%t` | Filename |
| `%=` | Left/right separator |
| `%A` | Current mode |
| `%10u` | User |
| `%-7g` | Group |
| `%15s` | Size |
| `%20d` | Date |

## Icons

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+="󰈔 :reg:"
set classify+=" ::*.lua::"
set classify+=" ::*.rs::"
set classify+=" ::*.go::"
set classify+=" ::*.py::"
set classify+=" ::*.js::"
set classify+=" ::*.ts::"
set classify+=" ::*.html::"
set classify+=" ::*.css::"
set classify+=" ::.git::"
set classify+=" ::*.zip::"
set classify+=" ::*.tar::"
set classify+=" ::*.png::"
set classify+=" ::*.mp4::"
set classify+=" ::*.mp3::"
set classify+="󰈙 ::*.md::"
set classify+=" ::*.json::"
```

`classify` syntax: `icon :type:` or `icon ::wildcard::`.

Icons are display prefixes only; they do **not** change filenames. Use the actual filename when copying or renaming.

## Key Bindings

### Navigation

| Key | Action |
|---|---|
| `j` / `k` | Move down / up |
| `h` / `l` | Parent directory / enter |
| `o` | Mapped to `l` (enter) |
| `O` | `:edit` |
| `<Tab>` | Next tab |
| `<S-Tab>` | Previous tab |
| `T` | Create a tab |
| `X` | Close a tab |
| `<Space>p` | Toggle single-/two-pane view |
| `q` | Quit |
| `Q` | Force quit |

### File Operations

| Key | Action |
|---|---|
| `a` | Create a file (`:touch`) |
| `r` | Rename |
| `d` | Move to trash |
| `D` | Delete directly |
| `y` | Copy (`yy`) |
| `x` | Cut (`dd`) |
| `p` / `P` | Paste |
| `.` | Toggle dotfiles |
| `s` | Open a shell |
| `f` | Search (`/`) |
| `F` | Filter by type (`=`) |
| `n` / `N` | Next / previous match |

### Bookmarks

| Key | Action |
|---|---|
| `m` | Add a bookmark |
| `'` | List bookmarks |
| `b` | Delete a bookmark |
| `B` | Force-delete a bookmark |

### Clipboard

| Key | Copies |
|---|---|
| `cc` | Full path |
| `cf` | Filename |
| `cd` | Parent directory |
| `cn` | Filename without extension |

Implementation:

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

| Placeholder | Meaning |
|---|---|
| `%c` | Current file |
| `:p` | Full path |
| `:t` | Filename component |
| `:h` | Remove the last component (parent directory) |
| `:r` | Remove the extension |

## vifm-copy

```sh
#!/usr/bin/env sh
set -eu

value=${1-}

if [ -n "${WAYLAND_DISPLAY-}" ] && command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$value" | wl-copy
elif [ -n "${DISPLAY-}" ] && command -v xclip >/dev/null 2>&1; then
  printf '%s' "$value" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$value" | xsel -ib
elif command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$value" | pbcopy
elif command -v clip.exe >/dev/null 2>&1; then
  printf '%s' "$value" | clip.exe
else
  printf 'vifm-copy: no clipboard command found\n' >&2
  exit 1
fi
```

It checks both the environment variable and the command's availability:

| Backend | Condition |
|---|---|
| `wl-copy` | `$WAYLAND_DISPLAY` is set and the command is available |
| `xclip` | `$DISPLAY` is set and the command is available |
| `xsel` | The command is available (no environment check) |
| `pbcopy` | The command is available (macOS) |
| `clip.exe` | The command is available (WSL) |

If none are available, it **reports an error and exits** instead of failing silently.

## Verification

```bash
vifm --version
ls -l ~/.config/vifm/
~/.config/vifm/scripts/vifm-copy "test"
```

The last command should copy "test" to the clipboard.

## Troubleshooting

**Icons are garbled**: The font is not a Nerd Font.

**`cc` does nothing**: `vifm-copy` cannot find a clipboard backend. Check with `command -v wl-copy xclip xsel pbcopy clip.exe`.

**Colors are wrong**: `config/vifm/colors/papercolor-dark.vifm` has not been deployed.

**The directory does not change after quitting with `v`**: Vifm did not exit normally (it was killed).

**Where is trash?**: `~/.local/share/vifm/Trash/`.

**The right pane always jumps back to home**: This is the design of `autocmd WinEnter`, not a bug.

<!-- lang:ja -->
> 要約：`vifmrc` のオプションと全キー割り当て、アイコン規則、`vifm-copy` クリップボードスクリプトについて説明します。

# Vifm の設定

## ファイルの場所

| 項目 | パス |
|---|---|
| リポジトリのソース | `config/vifm/vifmrc` |
| 配置先 | `~/.config/vifm/vifmrc` |
| インストール | `init.sh` の必須ツール一覧（システムのパッケージマネージャー） |
| 配色 | `config/vifm/colors/papercolor-dark.vifm` |
| スクリプト | `config/vifm/scripts/`（クリップボードとディレクトリプレビュー） |
| 自動リンク | はい（個別に 3 つマッピング） |

現在の `papercolor-dark` 配色は、Neovim 内蔵 Blue テーマの Nostalgia ブルー系に揃えています。メイン pane は青背景に黄色文字、カーソル行はダークブルーとシアンで強調し、アクティブ pane のタイトルは緑背景に黒文字、ステータス行はシアングリーンです。Vifm は True color 端末では正確な色値を使い、256 色端末では近似色を使います。

## オプション

```vim
colorscheme papercolor-dark
set trash
set dotdirs=
set vicmd=nvim
set syscalls
set history=200
set followlinks
set number
set sortnumbers
set vimhelp
set timefmt=%Y-%m-%d\ %H:%M
set incsearch
set statusline="%t%= %A %10u:%-7g %15s %20d  "
set quickview
```

| オプション | 効果 |
|---|---|
| `trash` | 削除した項目を直接消さず、ゴミ箱へ移動します |
| `dotdirs=` | 隠しディレクトリの表示を制御します（空値では既定値を使います） |
| `vicmd=nvim` | `:` コマンドとエディターに nvim を使います |
| `syscalls` | システムコールを許可します（コピー／移動に使います） |
| `history=200` | コマンド履歴の件数 |
| `followlinks` | シンボリックリンク先のディレクトリへ移動します |
| `number` | 行番号を表示します |
| `sortnumbers` | 数字を数値として並べます（`file2` が `file10` より前） |
| `vimhelp` | ヘルプで Vim 形式のナビゲーションを使います |
| `timefmt` | 時刻の表示形式 |
| `incsearch` | 検索中に逐次移動します |
| `quickview` | 右 pane に選択ファイルをプレビューします（2 pane レイアウトを維持） |

## 起動時の動作

起動時は 2 pane を維持します。左 pane に現在のディレクトリを表示し、右 pane では左側で選択したファイルをプレビューします（テキストやディレクトリ内容は Vifm のプレビュー規則に従います）。右 pane を強制的に `cd ~` する自動コマンドはなくなったため、プレビューが中断されません。

起動時のカーソルは左 pane にあります。右 pane は固定ディレクトリではなく、左側の選択に応じて変わるプレビュー領域です。一時的に 1 pane にするには `<Space>p` を押し、もう一度押すと 2 pane に戻ります。

### ディレクトリプレビュー

既定では Vifm は右 pane のディレクトリプレビューを再帰ツリーで描画するため、深いディレクトリや `.git` ファイルが多いと画面が混み合います。本リポジトリでは、1 項目を 1 行で表示する簡潔な一覧に変更しています。`eza` がインストールされている場合は Nerd Font アイコンを表示し、ディレクトリを先に並べ、テーマに従ってディレクトリをシアン、実行可能項目を緑で示します。`eza` がない場合は `ls -1pA` でディレクトリを示します。ファイルプレビューは Vifm 本来の方式を使います。

```vim
fileviewer */ vifm-preview-dir %"c
```

プレビュースクリプトは `config/vifm/scripts/vifm-preview-dir` にあります。Vifm は独自の `scripts/` ディレクトリをコマンド検索パスに追加します。

## ステータス行

```vim
set statusline="%t%= %A %10u:%-7g %15s %20d  "
```

| プレースホルダー | 意味 |
|---|---|
| `%t` | ファイル名 |
| `%=` | 左右の区切り |
| `%A` | 現在のモード |
| `%10u` | ユーザー |
| `%-7g` | グループ |
| `%15s` | サイズ |
| `%20d` | 日付 |

## アイコン

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+="󰈔 :reg:"
set classify+=" ::*.lua::"
set classify+=" ::*.rs::"
set classify+=" ::*.go::"
set classify+=" ::*.py::"
set classify+=" ::*.js::"
set classify+=" ::*.ts::"
set classify+=" ::*.html::"
set classify+=" ::*.css::"
set classify+=" ::.git::"
set classify+=" ::*.zip::"
set classify+=" ::*.tar::"
set classify+=" ::*.png::"
set classify+=" ::*.mp4::"
set classify+=" ::*.mp3::"
set classify+="󰈙 ::*.md::"
set classify+=" ::*.json::"
```

`classify` の構文は `アイコン :種類:` または `アイコン ::ワイルドカード::` です。

アイコンは表示用の接頭辞にすぎず、ファイル名は**変わりません**。コピーや名前変更には実際のファイル名を使います。

## キー割り当て

### ナビゲーション

| キー | 動作 |
|---|---|
| `j` / `k` | 下／上へ移動 |
| `h` / `l` | 親ディレクトリへ移動／開く |
| `o` | `l`（開く）に割り当てています |
| `O` | `:edit` |
| `<Tab>` | 次の tab |
| `<S-Tab>` | 前の tab |
| `T` | tab を作成します |
| `X` | tab を閉じます |
| `<Space>p` | 1 pane／2 pane を切り替えます |
| `q` | 終了 |
| `Q` | 強制終了 |

### ファイル操作

| キー | 動作 |
|---|---|
| `a` | ファイルを作成します（`:touch`） |
| `r` | 名前を変更します |
| `d` | ゴミ箱へ移動します |
| `D` | 直接削除します |
| `y` | コピーします（`yy`） |
| `x` | 切り取ります（`dd`） |
| `p` / `P` | 貼り付けます |
| `.` | dotfiles の表示を切り替えます |
| `s` | シェルを開きます |
| `f` | 検索します（`/`） |
| `F` | 種類で絞り込みます（`=`） |
| `n` / `N` | 次／前の一致項目へ移動します |

### ブックマーク

| キー | 動作 |
|---|---|
| `m` | ブックマークを追加します |
| `'` | ブックマーク一覧を表示します |
| `b` | ブックマークを削除します |
| `B` | ブックマークを強制削除します |

### クリップボード

| キー | コピーする内容 |
|---|---|
| `cc` | 絶対パス |
| `cf` | ファイル名 |
| `cd` | 親ディレクトリ |
| `cn` | 拡張子を除いたファイル名 |

実装：

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

| プレースホルダー | 意味 |
|---|---|
| `%c` | 現在のファイル |
| `:p` | 絶対パス |
| `:t` | ファイル名部分 |
| `:h` | 最後の要素を除去します（親ディレクトリ） |
| `:r` | 拡張子を除去します |

## vifm-copy

```sh
#!/usr/bin/env sh
set -eu

value=${1-}

if [ -n "${WAYLAND_DISPLAY-}" ] && command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$value" | wl-copy
elif [ -n "${DISPLAY-}" ] && command -v xclip >/dev/null 2>&1; then
  printf '%s' "$value" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$value" | xsel -ib
elif command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$value" | pbcopy
elif command -v clip.exe >/dev/null 2>&1; then
  printf '%s' "$value" | clip.exe
else
  printf 'vifm-copy: no clipboard command found\n' >&2
  exit 1
fi
```

バックエンドは、環境変数とコマンドの有無の両方で判定します。

| バックエンド | 条件 |
|---|---|
| `wl-copy` | `$WAYLAND_DISPLAY` が設定され、コマンドが使えます |
| `xclip` | `$DISPLAY` が設定され、コマンドが使えます |
| `xsel` | コマンドが使えます（環境変数の確認なし） |
| `pbcopy` | コマンドが使えます（macOS） |
| `clip.exe` | コマンドが使えます（WSL） |

どれも使えない場合は、黙って失敗せず**エラーを表示して終了します**。

## 確認

```bash
vifm --version
ls -l ~/.config/vifm/
~/.config/vifm/scripts/vifm-copy "test"
```

最後のコマンドで "test" がクリップボードに入ります。

## トラブルシューティング

**アイコンが文字化けします**：フォントが Nerd Font ではありません。

**`cc` が動作しません**：`vifm-copy` がクリップボードのバックエンドを見つけられません。`command -v wl-copy xclip xsel pbcopy clip.exe` で確認してください。

**配色が正しくありません**：`config/vifm/colors/papercolor-dark.vifm` が配置されていません。

**`v` で終了してもディレクトリが変わりません**：Vifm が正常終了していません（kill されています）。

**ゴミ箱の場所**：`~/.local/share/vifm/Trash/` です。

**右 pane がいつも home に戻ります**：これは `autocmd WinEnter` の設計であり、不具合ではありません。
