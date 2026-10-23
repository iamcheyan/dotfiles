> 摘要：Ranger 是终端文件管理器，本仓库用 ra 包装函数让退出后自动切换目录。

# Ranger

## 用途

Ranger 用三栏布局浏览文件系统：左栏父目录、中栏当前目录、右栏预览。它支持图像/文本预览、批量选择、书签、标签页。本仓库装了 devicons 和 archives 两个插件。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器 |
| 配置 | `config/ranger/` → `~/.config/ranger/` |
| 插件 | `ranger_devicons`、`archives`（都是 git 子模块） |

```bash
# Debian / Ubuntu
sudo apt install ranger
# Arch
sudo pacman -S ranger
# macOS
brew install ranger
```

init.sh 会检查并克隆两个插件：

```bash
git clone --depth 1 https://github.com/alexanderjeurissen/ranger_devicons.git "$plugin_dir"
git clone --depth 1 https://github.com/maximtrp/ranger-archives.git "$plugin_dir"
```

## ra 包装函数

`aliases.conf` 里定义：

```zsh
function ra {
  local tmpfile
  tmpfile="$(mktemp)"
  ranger --choosedir="$tmpfile" "${@:-$PWD}"
  if [ -f "$tmpfile" ]; then
    local newdir
    newdir="$(cat "$tmpfile")"
    [ -d "$newdir" ] && cd "$newdir"
    rm -f "$tmpfile"
  fi
}
```

流程：

1. 创建临时文件
2. `ranger --choosedir=<tmp>` 启动，Ranger 退出时把最后所在目录写进该文件
3. 读出来，`cd` 过去
4. 删除临时文件

所以 `ra` 退出后你的 shell 就在 Ranger 最后停留的目录，这是它相对直接 `ranger` 的核心价值。

## 基本用法

```bash
ra                  # 从当前目录
ra ~/dotfiles       # 从指定目录
ra file.txt         # 打开并选中文件
```

## 本仓库的 Ranger 配置

`config/ranger/rc.conf`：

```text
set preview_images true
set draw_borders both
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

| 配置 | 作用 |
|---|---|
| `preview_images` | 预览区显示图片（需要终端支持） |
| `draw_borders both` | 三栏都画边框 |
| `default_linemode devicons` | 用 devicons 显示文件图标 |
| `show_hidden` | 默认显示隐藏文件 |
| `preview_files` | 预览区显示文件内容 |
| `map ex extract` | `ex` 触发解压 |
| `map ec compress` | `ec` 触发压缩 |

## 常用按键

| 键 | 作用 |
|---|---|
| `h` / `l` | 上级目录 / 进入 |
| `j` / `k` | 上下移动 |
| `Space` | 选中/取消选中 |
| `v` | 反向选择 |
| `dd` | 剪切 |
| `yy` | 复制 |
| `pp` | 粘贴 |
| `dD` | 删除 |
| `cw` | 重命名 |
| `zh` | 切换隐藏文件 |
| `zp` | 切换预览 |
| `S` | 打开 shell |
| `q` | 退出 |
| `?` | 帮助 |
| `:` | 输入命令 |

## 书签

| 键 | 作用 |
|---|---|
| `m` + 字母 | 添加书签 |
| `'` + 字母 | 跳转书签 |
| `` ` `` + 字母 | 跳转到书签并进入 |
| `um` | 删除书签 |

书签保存在 `~/.config/ranger/bookmarks`。

## 归档插件

| 命令 | 作用 |
|---|---|
| `:extract` | 解压选中归档到当前目录 |
| `:extract_to_dirs` | 每个归档解压到同名子目录 |
| `:compress` | 压缩选中项 |
| `ex` | `:extract` 的快捷映射 |
| `ec` | `:compress` 的快捷映射 |

支持格式取决于系统里装了哪些压缩工具：tar、zip、7z、rar、zstd、lz4 等。

## rifle 配置

`config/ranger/rifle.conf` 决定用什么程序打开文件：

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

`$VISUAL` 或 `$EDITOR` 由 `zshrc` 设为 nvim。所以按 Enter 打开文件时进 Neovim。

## 图像预览依赖

`preview_images` 需要终端支持图像协议：

- Kitty（kitty graphics protocol）
- iTerm2（inline images）
- 某些终端支持 sixel

Ghostty 和普通终端通常不支持，此时预览区显示文件名而非图片。

## 排错

**`ra: command not found`**：`aliases.conf` 没加载，或 ranger 没装。

**图标乱码**：字体不是 Nerd Font。

**图片不预览**：终端不支持图像协议，正常现象。

**插件不生效**：子模块没初始化。`cd ~/dotfiles && git submodule update --init --recursive`。

**`ra` 退出后目录没变**：Ranger 里没有正常退出（比如被 kill）。`--choosedir` 只在正常退出时写文件。

**删除操作很慢**：大文件删除会阻塞界面。Ranger 有 `set confirm_on_delete` 选项可调整。

<!-- lang:en -->

> Summary: Ranger is a terminal file manager; in this repository the ra wrapper function switches your shell's directory to wherever you left Ranger on exit.

# Ranger

## Purpose

Ranger browses the filesystem with a three-column layout: parent directory on the left, current directory in the middle, preview on the right. It supports image/text previews, bulk selection, bookmarks and tabs. This repository installs two plugins: devicons and archives.

## Source and install

| Item | Notes |
|---|---|
| Source | system package manager |
| Config | `config/ranger/` → `~/.config/ranger/` |
| Plugins | `ranger_devicons`, `archives` (both git submodules) |

```bash
# Debian / Ubuntu
sudo apt install ranger
# Arch
sudo pacman -S ranger
# macOS
brew install ranger
```

init.sh checks for and clones the two plugins:

```bash
git clone --depth 1 https://github.com/alexanderjeurissen/ranger_devicons.git "$plugin_dir"
git clone --depth 1 https://github.com/maximtrp/ranger-archives.git "$plugin_dir"
```

## The ra wrapper function

Defined in `aliases.conf`:

```zsh
function ra {
  local tmpfile
  tmpfile="$(mktemp)"
  ranger --choosedir="$tmpfile" "${@:-$PWD}"
  if [ -f "$tmpfile" ]; then
    local newdir
    newdir="$(cat "$tmpfile")"
    [ -d "$newdir" ] && cd "$newdir"
    rm -f "$tmpfile"
  fi
}
```

The flow:

1. create a temp file
2. start `ranger --choosedir=<tmp>`; on exit Ranger writes the last directory it was in into that file
3. read it back and `cd` there
4. delete the temp file

So after `ra` exits, your shell is in the directory where Ranger last stood — this is its core value over running `ranger` directly.

## Basic usage

```bash
ra                  # 从当前目录
ra ~/dotfiles       # 从指定目录
ra file.txt         # 打开并选中文件
```

## Ranger config in this repository

`config/ranger/rc.conf`:

```text
set preview_images true
set draw_borders both
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

| Setting | Effect |
|---|---|
| `preview_images` | show images in the preview pane (terminal support required) |
| `draw_borders both` | draw borders on all three columns |
| `default_linemode devicons` | show file icons with devicons |
| `show_hidden` | show hidden files by default |
| `preview_files` | show file contents in the preview pane |
| `map ex extract` | `ex` triggers extraction |
| `map ec compress` | `ec` triggers compression |

## Key bindings

| Key | Effect |
|---|---|
| `h` / `l` | parent directory / enter |
| `j` / `k` | move up and down |
| `Space` | select/deselect |
| `v` | invert selection |
| `dd` | cut |
| `yy` | copy |
| `pp` | paste |
| `dD` | delete |
| `cw` | rename |
| `zh` | toggle hidden files |
| `zp` | toggle preview |
| `S` | open a shell |
| `q` | quit |
| `?` | help |
| `:` | enter a command |

## Bookmarks

| Key | Effect |
|---|---|
| `m` + letter | add a bookmark |
| `'` + letter | jump to a bookmark |
| `` ` `` + letter | jump to a bookmark and enter it |
| `um` | delete a bookmark |

Bookmarks are stored in `~/.config/ranger/bookmarks`.

## Archives plugin

| Command | Effect |
|---|---|
| `:extract` | extract the selected archive into the current directory |
| `:extract_to_dirs` | extract each archive into a same-named subdirectory |
| `:compress` | compress the selected items |
| `ex` | shortcut mapping for `:extract` |
| `ec` | shortcut mapping for `:compress` |

Supported formats depend on which compression tools are installed on the system: tar, zip, 7z, rar, zstd, lz4 and so on.

## rifle configuration

`config/ranger/rifle.conf` decides which program opens a file:

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

`$VISUAL` or `$EDITOR` is set to nvim by `zshrc`, so pressing Enter on a file opens Neovim.

## Image preview dependencies

`preview_images` requires a terminal with an image protocol:

- Kitty (kitty graphics protocol)
- iTerm2 (inline images)
- some terminals support sixel

Ghostty and ordinary terminals usually don't, in which case the preview pane shows the file name instead of an image.

## Troubleshooting

**`ra: command not found`** — `aliases.conf` wasn't loaded, or ranger isn't installed.

**Garbled icons** — the font is not a Nerd Font.

**No image preview** — the terminal doesn't support an image protocol; this is expected.

**Plugins not working** — the submodules aren't initialized. Run `cd ~/dotfiles && git submodule update --init --recursive`.

**Directory doesn't change after `ra` exits** — Ranger wasn't exited normally (for example it was killed). `--choosedir` only writes the file on a normal exit.

**Deletes are slow** — deleting large files blocks the UI. Ranger has a `set confirm_on_delete` option you can adjust.

<!-- lang:ja -->

> 要約：Ranger はターミナルのファイルマネージャで、本リポジトリでは ra ラッパー関数により、終了後にそのディレクトリへ自動的に移動できます。

# Ranger

## 用途

Ranger は 3 カラムのレイアウトでファイルシステムを操作します。左が親ディレクトリ、中央が現在のディレクトリ、右がプレビューです。画像/テキストのプレビュー、一括選択、ブックマーク、タブに対応しています。本リポジトリでは devicons と archives の 2 つのプラグインを入れています。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | システムのパッケージマネージャ |
| 設定 | `config/ranger/` → `~/.config/ranger/` |
| プラグイン | `ranger_devicons`、`archives`（どちらも git サブモジュール） |

```bash
# Debian / Ubuntu
sudo apt install ranger
# Arch
sudo pacman -S ranger
# macOS
brew install ranger
```

init.sh は 2 つのプラグインを確認してクローンします：

```bash
git clone --depth 1 https://github.com/alexanderjeurissen/ranger_devicons.git "$plugin_dir"
git clone --depth 1 https://github.com/maximtrp/ranger-archives.git "$plugin_dir"
```

## ra ラッパー関数

`aliases.conf` に定義があります：

```zsh
function ra {
  local tmpfile
  tmpfile="$(mktemp)"
  ranger --choosedir="$tmpfile" "${@:-$PWD}"
  if [ -f "$tmpfile" ]; then
    local newdir
    newdir="$(cat "$tmpfile")"
    [ -d "$newdir" ] && cd "$newdir"
    rm -f "$tmpfile"
  fi
}
```

流れはこうです：

1. 一時ファイルを作る
2. `ranger --choosedir=<tmp>` で起動する。Ranger は終了時に最後にいたディレクトリをこのファイルに書き込む
3. 読み出して `cd` する
4. 一時ファイルを削除する

つまり `ra` から抜けると、シェルは Ranger が最後にいたディレクトリにいます。これが素の `ranger` に対する最大の価値です。

## 基本的な使い方

```bash
ra                  # 从当前目录
ra ~/dotfiles       # 从指定目录
ra file.txt         # 打开并选中文件
```

## 本リポジトリの Ranger 設定

`config/ranger/rc.conf`：

```text
set preview_images true
set draw_borders both
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

| 設定 | 効果 |
|---|---|
| `preview_images` | プレビュー枠に画像を表示（ターミナルの対応が必要） |
| `draw_borders both` | 3 カラムすべてに枠線を描く |
| `default_linemode devicons` | devicons でファイルアイコンを表示 |
| `show_hidden` | デフォルトで隠しファイルを表示 |
| `preview_files` | プレビュー枠にファイル内容を表示 |
| `map ex extract` | `ex` で解凍を実行 |
| `map ec compress` | `ec` で圧縮を実行 |

## よく使うキー

| キー | 効果 |
|---|---|
| `h` / `l` | 上の階層へ / 中へ入る |
| `j` / `k` | 上下移動 |
| `Space` | 選択/選択解除 |
| `v` | 選択を反転 |
| `dd` | 切り取り |
| `yy` | コピー |
| `pp` | 貼り付け |
| `dD` | 削除 |
| `cw` | リネーム |
| `zh` | 隠しファイルの表示切替 |
| `zp` | プレビューの切替 |
| `S` | シェルを開く |
| `q` | 終了 |
| `?` | ヘルプ |
| `:` | コマンド入力 |

## ブックマーク

| キー | 効果 |
|---|---|
| `m` + 英字 | ブックマークを追加 |
| `'` + 英字 | ブックマークへ移動 |
| `` ` `` + 英字 | ブックマークへ移動して中へ入る |
| `um` | ブックマークを削除 |

ブックマークは `~/.config/ranger/bookmarks` に保存されます。

## アーカイブプラグイン

| コマンド | 効果 |
|---|---|
| `:extract` | 選択したアーカイブを現在のディレクトリに解凍 |
| `:extract_to_dirs` | アーカイブごとに同名のサブディレクトリへ解凍 |
| `:compress` | 選択項目を圧縮 |
| `ex` | `:extract` のショートカットマップ |
| `ec` | `:compress` のショートカットマップ |

対応形式はシステムに入っている圧縮ツール次第です。tar、zip、7z、rar、zstd、lz4 など。

## rifle の設定

`config/ranger/rifle.conf` が、どのプログラムでファイルを開くかを決めます：

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

`$VISUAL` か `$EDITOR` は `zshrc` が nvim に設定しているので、Enter でファイルを開くと Neovim に入ります。

## 画像プレビューの依存

`preview_images` には画像プロトコルに対応したターミナルが必要です：

- Kitty（kitty graphics protocol）
- iTerm2（inline images）
- sixel に対応した一部のターミナル

Ghostty や一般的なターミナルは通常非対応で、その場合プレビュー枠には画像の代わりにファイル名が表示されます。

## トラブルシュート

**`ra: command not found`**：`aliases.conf` が読み込まれていないか、ranger が未インストールです。

**アイコンが文字化けする**：フォントが Nerd Font ではありません。

**画像がプレビューされない**：ターミナルが画像プロトコルに非対応で、正常な挙動です。

**プラグインが効かない**：サブモジュールが未初期化です。`cd ~/dotfiles && git submodule update --init --recursive` を実行します。

**`ra` 終了後にディレクトリが変わらない**：Ranger を正常に終了していません（kill された場合など）。`--choosedir` は正常終了時だけファイルを書き込みます。

**削除が遅い**：大きなファイルの削除は UI をブロックします。Ranger には `set confirm_on_delete` の調整可能なオプションがあります。
