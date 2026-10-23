> 摘要：Vifm 是 Vim 风格的双栏文件管理器，本仓库配了完整键位和剪贴板脚本。

# Vifm

## 用途

Vifm 用 Vim 的键位习惯管理文件：`hjkl` 移动、`dd` 删除、`yy` 复制、`p` 粘贴。本仓库默认双栏：左栏浏览，右栏是 quick view 预览，按 `<Space>p` 可切到单栏。

相比 Ranger，Vifm 更贴近 Vim 用户的手感，配置文件也是 Vim 语法。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器（`init.sh` 的必备工具清单已包含 vifm） |
| 配置 | `config/vifm/` → `~/.config/vifm/` |
| 包装函数 | `v`（定义在 `zshrc`） |

```bash
# 已运行过 init.sh 的机器无需手动安装；单独安装：
# Debian / Ubuntu
sudo apt install vifm
# Arch
sudo pacman -S vifm
# macOS
brew install vifm
```

## v 包装函数

```zsh
v() {
  local tmp="$(mktemp -t vifm-cwd.XXXXXX)"
  vifm --choose-dir="$tmp" "$@"
  if [ -f "$tmp" ]; then
    cd "$(cat "$tmp")"
    rm -f "$tmp"
  fi
}
```

与 `ra` 同理：Vifm 退出时把最后目录写进临时文件，`v` 读出来并 `cd`。

```bash
v                  # 从当前目录
v ~/dotfiles       # 从指定目录
```

## 本仓库的配置

`config/vifm/vifmrc` 的关键设置：

```vim
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
colorscheme papercolor-dark
```

| 设置 | 作用 |
|---|---|
| `trash` | 删除移到回收站而非直接删 |
| `dotdirs=` | 控制隐藏目录的显示方式 |
| `vicmd=nvim` | `:` 命令和编辑器用 nvim |
| `history=200` | 命令历史 200 条 |
| `followlinks` | 进入软链接指向的目录 |
| `number` | 显示行号 |
| `sortnumbers` | 数字按数值排序 |
| `incsearch` | 搜索时实时跳转 |
| `colorscheme papercolor-dark` | 配色 |

右栏目录预览使用简洁清单：

装有 `eza` 时每项带 Nerd Font 图标、目录排在前面，并使用主题的青色目录／绿色可执行文件颜色；没有时回退到带 `/` 目录标记的 `ls`。文件预览仍由 Vifm 原有规则处理。

## 本仓库的键位

### 导航

| 键 | 作用 |
|---|---|
| `j` / `k` | 上下移动 |
| `h` / `l` | 上级 / 进入（`o` 也映射为 `l`） |
| `gg` / `G` | 首行 / 末行 |
| `<Tab>` / `<S-Tab>` | 下一个 / 上一个 tab |
| `T` / `X` | 新建 tab / 关闭 tab |
| `<Space>p` | 单栏/双栏切换 |
| `q` / `Q` | 退出 / 强制退出 |

### 文件操作

| 键 | 作用 |
|---|---|
| `a` | 新建文件 |
| `r` | 重命名 |
| `d` | 移到 trash |
| `D` | 直接删除 |
| `y` | 复制（yy） |
| `x` | 剪切（dd） |
| `p` / `P` | 粘贴 |
| `.` | 切换 dotfiles 显示 |
| `s` | 打开 shell |
| `f` / `F` | 搜索 / 按类型筛选 |

### 书签

| 键 | 作用 |
|---|---|
| `m` | 添加书签 |
| `'` | 列出书签 |
| `b` / `B` | 删除书签 |

### 剪贴板

| 键 | 复制内容 |
|---|---|
| `cc` | 完整路径 |
| `cf` | 文件名 |
| `cd` | 父目录路径 |
| `cn` | 不含扩展名的文件名 |

这四条调用 `vifm-copy`：

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

`%c` 是 Vifm 的当前文件占位符，`:p` 完整路径、`:t` 文件名、`:h` 去尾、`:r` 去扩展名。

## vifm-copy 脚本

`config/vifm/scripts/vifm-copy` 按顺序探测剪贴板后端：

```sh
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

| 后端 | 环境 |
|---|---|
| `wl-copy` | Wayland |
| `xclip` | X11 |
| `xsel` | X11 备选 |
| `pbcopy` | macOS |
| `clip.exe` | WSL |

找不到后端时返回错误，不会假装成功。

## 图标

配置里用 `set classify` 给不同文件类型加图标：

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+=" ::*.lua::"
```

图标只是显示前缀，不改变文件名。

## 与 Ranger 的分工

| | Ranger | Vifm |
|---|---|---|
| 键位 | 自己的体系 | Vim 风格 |
| 配置格式 | Python | Vim 语法 |
| 预览 | 图像支持更好 | 文本为主 |
| 插件生态 | 丰富 | 较少 |

Vim 用户通常更习惯 Vifm。

## 排错

**`v: command not found`**：`zshrc` 里的函数没加载，或 vifm 没装。

**图标乱码**：字体不是 Nerd Font。

**`cc` 等剪贴板键没反应**：`vifm-copy` 找不到后端。检查 `command -v wl-copy xclip xsel`。

**`v` 退出后目录没变**：Vifm 非正常退出。

**trash 目录在哪**：`~/.local/share/vifm/Trash/`。想清空直接删。

**颜色不对**：`colorscheme papercolor-dark` 依赖 `config/vifm/colors/papercolor-dark.vifm` 已部署。

<!-- lang:en -->
> Summary: Vifm is a Vim-style two-pane file manager; this repository includes complete key bindings and a clipboard script.

# Vifm

## Purpose

Vifm manages files using Vim-style keys: move with `hjkl`, delete with `dd`, copy with `yy`, and paste with `p`. This repository defaults to two panes: browse in the left pane and preview with quick view in the right pane. Press `<Space>p` to switch to a single pane.

Compared with Ranger, Vifm feels more familiar to Vim users, and its configuration file also uses Vim syntax.

## Source and installation

| Item | Description |
|---|---|
| Source | System package manager (vifm is included in the required tools list in `init.sh`) |
| Configuration | `config/vifm/` → `~/.config/vifm/` |
| Wrapper function | `v` (defined in `zshrc`) |

## v wrapper function

Like `ra`, when Vifm exits it writes the last directory to a temporary file, which `v` reads and uses with `cd`.

## Configuration in this repository

The key settings in `config/vifm/vifmrc` are:

| Setting | Effect |
|---|---|
| `trash` | Move deleted items to trash instead of deleting them immediately |
| `dotdirs=` | Control how hidden directories are displayed |
| `vicmd=nvim` | Use nvim for the `:` command and as the editor |
| `history=200` | Keep 200 commands in history |
| `followlinks` | Enter directories pointed to by symlinks |
| `number` | Show line numbers |
| `sortnumbers` | Sort numbers by numeric value |
| `incsearch` | Jump as you search |
| `colorscheme papercolor-dark` | Color scheme |

The right pane uses a concise list for directory previews:

When `eza` is installed, each item has a Nerd Font icon, directories appear first, and the theme's cyan directory and green executable colors are used. Otherwise, it falls back to `ls` with `/` directory markers. File previews continue to use Vifm's existing rules.

## Key bindings in this repository

### Navigation

| Key | Effect |
|---|---|
| `j` / `k` | Move up/down |
| `h` / `l` | Go to parent / enter ( `o` is also mapped to `l`) |
| `gg` / `G` | First / last line |
| `<Tab>` / `<S-Tab>` | Next / previous tab |
| `T` / `X` | Create / close tab |
| `<Space>p` | Toggle single/two panes |
| `q` / `Q` | Quit / force quit |

### File operations

| Key | Effect |
|---|---|
| `a` | Create a file |
| `r` | Rename |
| `d` | Move to trash |
| `D` | Delete directly |
| `y` | Copy (`yy`) |
| `x` | Cut (`dd`) |
| `p` / `P` | Paste |
| `.` | Toggle dotfiles display |
| `s` | Open a shell |
| `f` / `F` | Search / filter by type |

### Bookmarks

| Key | Effect |
|---|---|
| `m` | Add a bookmark |
| `'` | List bookmarks |
| `b` / `B` | Delete a bookmark |

### Clipboard

| Key | Copies |
|---|---|
| `cc` | Full path |
| `cf` | Filename |
| `cd` | Parent directory path |
| `cn` | Filename without extension |

These four mappings call `vifm-copy`:

`%c` is Vifm's current file placeholder; `:p` means full path, `:t` filename, `:h` head, and `:r` root (without extension).

## vifm-copy script

`config/vifm/scripts/vifm-copy` checks clipboard backends in order:

| Backend | Environment |
|---|---|
| `wl-copy` | Wayland |
| `xclip` | X11 |
| `xsel` | X11 fallback |
| `pbcopy` | macOS |
| `clip.exe` | WSL |

If no backend is found, it returns an error instead of pretending the copy succeeded.

## Icons

The configuration uses `set classify` to add icons to different file types:

Icons are only display prefixes; they do not change filenames.

## How Ranger and Vifm differ

| | Ranger | Vifm |
|---|---|---|
| Key bindings | Its own system | Vim-style |
| Configuration format | Python | Vim syntax |
| Preview | Better image support | Mainly text |
| Plugin ecosystem | Extensive | Smaller |

Vim users usually find Vifm more familiar.

## Troubleshooting

**`v: command not found`**: The function in `zshrc` has not loaded, or vifm is not installed.

**Icons are garbled**: The font is not a Nerd Font.

**Clipboard keys such as `cc` do nothing**: `vifm-copy` cannot find a backend. Check with `command -v wl-copy xclip xsel`.

**The directory does not change after `v` exits**: Vifm did not exit normally.

**Where is the trash directory?**: `~/.local/share/vifm/Trash/`. Delete its contents directly to empty it.

**Colors look wrong**: `colorscheme papercolor-dark` depends on `config/vifm/colors/papercolor-dark.vifm` being deployed.

```bash
# 已运行过 init.sh 的机器无需手动安装；单独安装：
# Debian / Ubuntu
sudo apt install vifm
# Arch
sudo pacman -S vifm
# macOS
brew install vifm
```

```zsh
v() {
  local tmp="$(mktemp -t vifm-cwd.XXXXXX)"
  vifm --choose-dir="$tmp" "$@"
  if [ -f "$tmp" ]; then
    cd "$(cat "$tmp")"
    rm -f "$tmp"
  fi
}
```

```bash
v                  # 从当前目录
v ~/dotfiles       # 从指定目录
```

```vim
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
colorscheme papercolor-dark
```

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

```sh
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

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+=" ::*.lua::"
```

<!-- lang:ja -->
> 要約：Vifm は Vim 風の2ペインファイルマネージャーです。このリポジトリには一通りのキー割り当てとクリップボードスクリプトがあります。

# Vifm

## 用途

Vifm は Vim のキー操作でファイルを管理します。`hjkl` で移動し、`dd` で削除し、`yy` でコピーし、`p` で貼り付けます。このリポジトリでは既定で2ペインにし、左側で一覧を見て右側で quick view プレビューを表示します。`<Space>p` で1ペインに切り替えます。

Ranger と比べると、Vifm は Vim ユーザーになじみやすく、設定ファイルも Vim 構文です。

## 入手元とインストール

| 項目 | 説明 |
|---|---|
| 入手元 | システムのパッケージマネージャー（`init.sh` の必須ツール一覧に vifm が含まれます） |
| 設定 | `config/vifm/` → `~/.config/vifm/` |
| ラッパー関数 | `v`（`zshrc` で定義） |

## v ラッパー関数

`ra` と同じく、Vifm の終了時に最後のディレクトリを一時ファイルへ書き込みます。`v` が読み取り、その場所へ `cd` します。

## このリポジトリの設定

`config/vifm/vifmrc` の主な設定は次のとおりです。

| 設定 | 効果 |
|---|---|
| `trash` | 削除した項目をすぐ消さず、ゴミ箱へ移動します |
| `dotdirs=` | 隠しディレクトリの表示方法を制御します |
| `vicmd=nvim` | `:` コマンドとエディターに nvim を使います |
| `history=200` | コマンド履歴を200件保持します |
| `followlinks` | シンボリックリンク先のディレクトリへ移動します |
| `number` | 行番号を表示します |
| `sortnumbers` | 数値を数値として並べ替えます |
| `incsearch` | 検索中に該当箇所へ移動します |
| `colorscheme papercolor-dark` | カラースキームです |

右ペインのディレクトリプレビューには簡潔な一覧を使います。

`eza` があれば各項目に Nerd Font アイコンを付け、ディレクトリを先に並べ、テーマのシアンのディレクトリ色と緑の実行可能ファイル色を使います。ない場合は、ディレクトリを `/` で示す `ls` に切り替えます。ファイルプレビューは Vifm 本来のルールで処理します。

## このリポジトリのキー割り当て

### 移動

| キー | 効果 |
|---|---|
| `j` / `k` | 上／下へ移動します |
| `h` / `l` | 親へ移動／開きます（`o` も `l` に割り当てています） |
| `gg` / `G` | 先頭行／最終行へ移動します |
| `<Tab>` / `<S-Tab>` | 次／前の tab へ移動します |
| `T` / `X` | tab を作成／閉じます |
| `<Space>p` | 1ペイン／2ペインを切り替えます |
| `q` / `Q` | 終了／強制終了します |

### ファイル操作

| キー | 効果 |
|---|---|
| `a` | ファイルを作成します |
| `r` | 名前を変更します |
| `d` | ゴミ箱へ移動します |
| `D` | 直接削除します |
| `y` | コピーします（yy） |
| `x` | 切り取ります（dd） |
| `p` / `P` | 貼り付けます |
| `.` | dotfiles の表示を切り替えます |
| `s` | shell を開きます |
| `f` / `F` | 検索／種類で絞り込みます |

### ブックマーク

| キー | 効果 |
|---|---|
| `m` | ブックマークを追加します |
| `'` | ブックマーク一覧を表示します |
| `b` / `B` | ブックマークを削除します |

### クリップボード

| キー | コピーする内容 |
|---|---|
| `cc` | 完全なパス |
| `cf` | ファイル名 |
| `cd` | 親ディレクトリのパス |
| `cn` | 拡張子を除いたファイル名 |

この4つの割り当ては `vifm-copy` を呼び出します。

`%c` は Vifm の現在のファイルを表すプレースホルダーです。`:p` は完全なパス、`:t` はファイル名、`:h` は末尾を除いた親部分、`:r` は拡張子を除いた名前を表します。

## vifm-copy スクリプト

`config/vifm/scripts/vifm-copy` はクリップボードのバックエンドを順に確認します。

| バックエンド | 環境 |
|---|---|
| `wl-copy` | Wayland |
| `xclip` | X11 |
| `xsel` | X11 の代替手段 |
| `pbcopy` | macOS |
| `clip.exe` | WSL |

バックエンドが見つからない場合はエラーを返し、成功したようには見せません。

## アイコン

設定では `set classify` を使ってファイル種別ごとにアイコンを付けます。

アイコンは表示上の接頭辞にすぎず、ファイル名は変わりません。

## Ranger との使い分け

| | Ranger | Vifm |
|---|---|---|
| キー割り当て | 独自の体系 | Vim 風 |
| 設定形式 | Python | Vim 構文 |
| プレビュー | 画像対応が優れています | 主にテキストです |
| プラグイン環境 | 豊富です | 少なめです |

Vim ユーザーは通常 Vifm のほうになじみやすいです。

## トラブルシューティング

**`v: command not found`**：`zshrc` の関数が読み込まれていないか、vifm がインストールされていません。

**アイコンが文字化けします**：フォントが Nerd Font ではありません。

**`cc` などのクリップボードキーが動きません**：`vifm-copy` がバックエンドを見つけられません。`command -v wl-copy xclip xsel` で確認します。

**`v` の終了後にディレクトリが変わりません**：Vifm が正常に終了しませんでした。

**ゴミ箱の場所**：`~/.local/share/vifm/Trash/` です。空にするには中身を直接削除します。

**色が正しくありません**：`colorscheme papercolor-dark` を使うには `config/vifm/colors/papercolor-dark.vifm` が配置されている必要があります。

```bash
# 已运行过 init.sh 的机器无需手动安装；单独安装：
# Debian / Ubuntu
sudo apt install vifm
# Arch
sudo pacman -S vifm
# macOS
brew install vifm
```

```zsh
v() {
  local tmp="$(mktemp -t vifm-cwd.XXXXXX)"
  vifm --choose-dir="$tmp" "$@"
  if [ -f "$tmp" ]; then
    cd "$(cat "$tmp")"
    rm -f "$tmp"
  fi
}
```

```bash
v                  # 从当前目录
v ~/dotfiles       # 从指定目录
```

```vim
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
colorscheme papercolor-dark
```

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

```sh
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

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+=" ::*.lua::"
```
