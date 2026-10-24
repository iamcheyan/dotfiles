> 摘要：Ranger 的 rc.conf 与 rifle.conf 配置项、devicons 图标和 archives 归档插件。

# Ranger 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/ranger/` |
| 部署目标 | `~/.config/ranger/` |
| 是否自动链接 | 是（整个目录） |

目录结构：

```text
config/ranger/
├── rc.conf          # 主配置
├── rifle.conf       # 文件打开规则
├── colorschemes/
│   └── blue.py      # Neovim Blue / Nostalgia 配色
└── plugins/
    ├── ranger_devicons/   # git 子模块
    └── archives/          # git 子模块
```

## rc.conf

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"

set preview_images true
set draw_borders both
set colorscheme blue
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

### 配置项

| 行 | 作用 |
|---|---|
| `preview_images true` | 预览区显示图片（需终端支持） |
| `draw_borders both` | 三栏都画边框 |
| `colorscheme blue` | 普通文件和可执行文件使用绿色，目录和选区使用青色 |
| `default_linemode devicons` | 用 devicons 图标模式 |
| `show_hidden true` | 默认显示隐藏文件 |
| `preview_files true` | 预览区显示文件内容 |
| `map ex extract` | `ex` 触发归档插件解压 |
| `map ec compress` | `ec` 触发归档插件压缩 |

### 那个 alias

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"
```

这是一个提示性别名，输出一条示例连接串。它不执行实际连接，只是把常用地址存起来方便复制。**里面写的是示例凭据，不是真实环境**。

## rifle.conf

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

整个文件只有一条规则：所有普通文件用 `${VISUAL:-$EDITOR}` 打开。

因为 `zshrc` 把 `$VISUAL` 和 `$EDITOR` 都设成了 `nvim`，所以 Ranger 里按 Enter 打开文件时进 Neovim。

注释里提到：

```text
# rnvimr intercepts rules containing $EDITOR and opens the selected file
# through Neovim RPC. Standalone ranger still uses the configured editor.
```

如果装了 rnvimr（Neovim 的 Ranger 集成），它会拦截这条规则，用 RPC 在已有 Neovim 实例里打开。没装时就是普通调用。

## devicons 插件

给文件和目录加 Nerd Font 图标。

```text
config/ranger/plugins/ranger_devicons/
├── __init__.py
├── devicons.py
└── locales/
    ├── de.py
    ├── es.py
    ├── ja.py
    ├── zh_cn.py
    └── ...
```

启用方式：`default_linemode devicons`。

支持多语言（`zh_cn.py`、`ja.py`），会根据 `LANG` 选。

## archives 插件

提供压缩/解压命令：

| 命令 | 作用 |
|---|---|
| `:extract [dir]` | 解压到当前或指定目录 |
| `:extract_raw [flags]` | 用自定义参数解压 |
| `:extract_to_dirs [flags]` | 每个归档解压到同名子目录 |
| `:compress [flags] [file.ext]` | 压缩选中项 |

快捷映射：`ex` = extract，`ec` = compress。

支持格式取决于系统装了什么工具：

| 格式 | 依赖 |
|---|---|
| `.zip` | zip / unzip / 7z |
| `.7z` | 7z |
| `.rar` | rar / unrar / 7z |
| `.tar.gz` | tar + gzip/pigz |
| `.tar.bz2` | tar + bzip2/pbzip2 |
| `.tar.xz` | tar + xz/pixz |
| `.tar.zst` | tar + zstd |
| `.tar.lz4` | tar + lz4 |

插件会优先用并行版本（`pigz`、`pbzip2`、`pixz`）提升速度。

## 常用按键

| 键 | 作用 |
|---|---|
| `h` / `l` | 上级 / 进入 |
| `j` / `k` | 上下 |
| `Space` | 选中 |
| `v` | 反向选择 |
| `dd` | 剪切 |
| `yy` | 复制 |
| `pp` | 粘贴 |
| `dD` | 删除 |
| `cw` | 重命名 |
| `zh` | 切换隐藏 |
| `zp` | 切换预览 |
| `S` | 开 shell |
| `:` | 命令 |
| `?` | 帮助 |

## 验证

```bash
ranger --version
ls -l ~/.config/ranger/rc.conf
ls ~/.config/ranger/plugins/
```

插件目录应该是软链接或实际目录，且里面 `__init__.py` 存在。

## 排错

**图标是方框**：字体不是 Nerd Font。

**图片不预览**：终端不支持图像协议（Kitty/iTerm2/sixel）。普通终端只能显示文件名。

**`ex` / `ec` 无反应**：archives 插件没装。`git submodule update --init --recursive`。

**打开文件不用 nvim**：`$EDITOR` / `$VISUAL` 没设。检查 `echo $EDITOR`。

**插件报 Python 错误**：Ranger 用 Python 3，插件可能需要特定版本。`python3 --version` 确认。

**`alpine` 别名执行了奇怪的东西**：它只是 `echo`，输出一条示例串，不连接任何地方。

<!-- lang:en -->
> Summary: Ranger `rc.conf` and `rifle.conf` settings, devicons icons, and the archives plugin.

# Ranger Configuration

## File Locations

| Item | Path |
|---|---|
| Repository source | `config/ranger/` |
| Deployment target | `~/.config/ranger/` |
| Automatically linked | Yes (entire directory) |

Directory structure:

```text
config/ranger/
├── rc.conf          # 主配置
├── rifle.conf       # 文件打开规则
├── colorschemes/
│   └── blue.py      # Neovim Blue / Nostalgia 配色
└── plugins/
    ├── ranger_devicons/   # git 子模块
    └── archives/          # git 子模块
```

## rc.conf

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"

set preview_images true
set draw_borders both
set colorscheme blue
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

### Settings

| Line | Effect |
|---|---|
| `preview_images true` | Show images in the preview pane (requires terminal support) |
| `draw_borders both` | Draw borders around all three columns |
| `colorscheme blue` | Use green for regular and executable files, with cyan directories and selections |
| `default_linemode devicons` | Use devicons icon mode |
| `show_hidden true` | Show hidden files by default |
| `preview_files true` | Show file contents in the preview pane |
| `map ex extract` | `ex` invokes the archives plugin to extract archives |
| `map ec compress` | `ec` invokes the archives plugin to compress files |

### The alias

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"
```

This is an informational alias that prints an example connection string. It does not connect anywhere; it just keeps a frequently used address handy for copying. **The credentials shown are examples, not real credentials.**

## rifle.conf

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

The file contains a single rule: open all ordinary files with `${VISUAL:-$EDITOR}`.

Since `zshrc` sets both `$VISUAL` and `$EDITOR` to `nvim`, pressing Enter on a file in Ranger opens it in Neovim.

The comments say:

```text
# rnvimr intercepts rules containing $EDITOR and opens the selected file
# through Neovim RPC. Standalone ranger still uses the configured editor.
```

If rnvimr (the Neovim integration for Ranger) is installed, it intercepts this rule and opens the file in an existing Neovim instance over RPC. Without it, the editor is launched normally.

## devicons plugin

Adds Nerd Font icons to files and directories.

```text
config/ranger/plugins/ranger_devicons/
├── __init__.py
├── devicons.py
└── locales/
    ├── de.py
    ├── es.py
    ├── ja.py
    ├── zh_cn.py
    └── ...
```

Enable it with: `default_linemode devicons`.

It supports multiple languages (`zh_cn.py`, `ja.py`) and chooses one according to `LANG`.

## archives plugin

Provides archive extraction and compression commands:

| Command | Effect |
|---|---|
| `:extract [dir]` | Extract to the current or specified directory |
| `:extract_raw [flags]` | Extract with custom arguments |
| `:extract_to_dirs [flags]` | Extract each archive into a subdirectory with the same name |
| `:compress [flags] [file.ext]` | Compress selected items |

Key mappings: `ex` = extract, `ec` = compress.

Supported formats depend on which tools are installed on the system:

| Format | Dependency |
|---|---|
| `.zip` | zip / unzip / 7z |
| `.7z` | 7z |
| `.rar` | rar / unrar / 7z |
| `.tar.gz` | tar + gzip/pigz |
| `.tar.bz2` | tar + bzip2/pbzip2 |
| `.tar.xz` | tar + xz/pixz |
| `.tar.zst` | tar + zstd |
| `.tar.lz4` | tar + lz4 |

The plugin prefers parallel versions (`pigz`, `pbzip2`, `pixz`) to improve speed.

## Common keys

| Key | Effect |
|---|---|
| `h` / `l` | Parent directory / enter |
| `j` / `k` | Down / up |
| `Space` | Select |
| `v` | Invert selection |
| `dd` | Cut |
| `yy` | Copy |
| `pp` | Paste |
| `dD` | Delete |
| `cw` | Rename |
| `zh` | Toggle hidden files |
| `zp` | Toggle preview |
| `S` | Open a shell |
| `:` | Command |
| `?` | Help |

## Verification

```bash
ranger --version
ls -l ~/.config/ranger/rc.conf
ls ~/.config/ranger/plugins/
```

The plugin directory should be a symlink or a real directory, and it should contain `__init__.py`.

## Troubleshooting

**Icons appear as boxes**: The font is not a Nerd Font.

**Images do not preview**: The terminal does not support an image protocol (Kitty/iTerm2/sixel). Ordinary terminals can only show filenames.

**`ex` / `ec` do nothing**: The archives plugin is not installed. Run `git submodule update --init --recursive`.

**Files do not open in nvim**: `$EDITOR` / `$VISUAL` is unset. Check `echo $EDITOR`.

**The plugin reports a Python error**: Ranger uses Python 3, and the plugin may require a particular version. Check with `python3 --version`.

**The `alpine` alias does something unexpected**: It only runs `echo` and prints an example string; it does not connect anywhere.

<!-- lang:ja -->
> 要約：Ranger の `rc.conf` と `rifle.conf` の設定項目、devicons アイコン、archives プラグインについて説明します。

# Ranger の設定

## ファイルの場所

| 項目 | パス |
|---|---|
| リポジトリのソース | `config/ranger/` |
| 配置先 | `~/.config/ranger/` |
| 自動リンク | はい（ディレクトリ全体） |

ディレクトリ構成：

```text
config/ranger/
├── rc.conf          # 主配置
├── rifle.conf       # 文件打开规则
├── colorschemes/
│   └── blue.py      # Neovim Blue / Nostalgia 配色
└── plugins/
    ├── ranger_devicons/   # git 子模块
    └── archives/          # git 子模块
```

## rc.conf

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"

set preview_images true
set draw_borders both
set colorscheme blue
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

### 設定項目

| 行 | 効果 |
|---|---|
| `preview_images true` | プレビュー欄に画像を表示します（端末の対応が必要です） |
| `draw_borders both` | 3 列すべてに境界線を表示します |
| `colorscheme blue` | 通常ファイルと実行ファイルを緑、ディレクトリと選択項目をシアンで表示します |
| `default_linemode devicons` | devicons アイコンモードを使います |
| `show_hidden true` | 既定で隠しファイルを表示します |
| `preview_files true` | プレビュー欄にファイル内容を表示します |
| `map ex extract` | `ex` で archives プラグインの展開を実行します |
| `map ec compress` | `ec` で archives プラグインの圧縮を実行します |

### alias について

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"
```

これは接続例の文字列を表示する案内用 alias です。実際に接続はせず、よく使うアドレスをコピーしやすく保存します。**ここに記載した認証情報は例であり、実環境のものではありません。**

## rifle.conf

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

このファイルには、通常のファイルをすべて `${VISUAL:-$EDITOR}` で開くルールが 1 つだけあります。

`zshrc` では `$VISUAL` と `$EDITOR` の両方を `nvim` に設定しているため、Ranger で Enter キーを押すと Neovim でファイルが開きます。

コメントには次のようにあります。

```text
# rnvimr intercepts rules containing $EDITOR and opens the selected file
# through Neovim RPC. Standalone ranger still uses the configured editor.
```

rnvimr（Neovim 用 Ranger 連携機能）がインストールされている場合、このルールを横取りし、RPC 経由で既存の Neovim インスタンスにファイルを開きます。未インストールの場合は通常どおりエディターを起動します。

## devicons プラグイン

ファイルとディレクトリに Nerd Font アイコンを追加します。

```text
config/ranger/plugins/ranger_devicons/
├── __init__.py
├── devicons.py
└── locales/
    ├── de.py
    ├── es.py
    ├── ja.py
    ├── zh_cn.py
    └── ...
```

有効化するには `default_linemode devicons` を設定します。

複数の言語（`zh_cn.py`、`ja.py`）に対応しており、`LANG` に応じて選択します。

## archives プラグイン

アーカイブの展開と圧縮コマンドを提供します。

| コマンド | 効果 |
|---|---|
| `:extract [dir]` | 現在のディレクトリ、または指定したディレクトリに展開します |
| `:extract_raw [flags]` | 独自の引数で展開します |
| `:extract_to_dirs [flags]` | 各アーカイブを同名のサブディレクトリに展開します |
| `:compress [flags] [file.ext]` | 選択項目を圧縮します |

キー割り当て：`ex` = extract、`ec` = compress です。

対応形式は、システムにインストールされているツールによって異なります。

| 形式 | 依存ツール |
|---|---|
| `.zip` | zip / unzip / 7z |
| `.7z` | 7z |
| `.rar` | rar / unrar / 7z |
| `.tar.gz` | tar + gzip/pigz |
| `.tar.bz2` | tar + bzip2/pbzip2 |
| `.tar.xz` | tar + xz/pixz |
| `.tar.zst` | tar + zstd |
| `.tar.lz4` | tar + lz4 |

速度向上のため、プラグインは並列版（`pigz`、`pbzip2`、`pixz`）を優先して使います。

## よく使うキー

| キー | 効果 |
|---|---|
| `h` / `l` | 親ディレクトリへ移動 / 開く |
| `j` / `k` | 下 / 上へ移動 |
| `Space` | 選択 |
| `v` | 選択を反転 |
| `dd` | 切り取り |
| `yy` | コピー |
| `pp` | 貼り付け |
| `dD` | 削除 |
| `cw` | 名前を変更 |
| `zh` | 隠しファイルの表示を切り替えます |
| `zp` | プレビューの表示を切り替えます |
| `S` | シェルを開きます |
| `:` | コマンド |
| `?` | ヘルプ |

## 確認

```bash
ranger --version
ls -l ~/.config/ranger/rc.conf
ls ~/.config/ranger/plugins/
```

プラグインディレクトリはシンボリックリンクまたは実ディレクトリであり、その中に `__init__.py` がある必要があります。

## トラブルシューティング

**アイコンが四角で表示されます**：フォントが Nerd Font ではありません。

**画像をプレビューできません**：端末が画像プロトコル（Kitty/iTerm2/sixel）に対応していません。通常の端末ではファイル名だけが表示されます。

**`ex` / `ec` が動作しません**：archives プラグインが未インストールです。`git submodule update --init --recursive` を実行してください。

**ファイルが nvim で開きません**：`$EDITOR` / `$VISUAL` が設定されていません。`echo $EDITOR` で確認してください。

**プラグインが Python エラーを報告します**：Ranger は Python 3 を使いますが、プラグインが特定のバージョンを必要とする場合があります。`python3 --version` で確認してください。

**`alpine` alias が予期しない動作をします**：`echo` で例の文字列を表示するだけで、どこにも接続しません。
