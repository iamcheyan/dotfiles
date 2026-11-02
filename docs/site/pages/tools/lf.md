> 摘要：lf 是受 Ranger 启发的终端文件管理器；本仓库为它配置边框、Nerd Font 图标、预览、常用 Ranger 键位与目录切换包装函数。

# lf

## 用途

`lf` 是受 Ranger 启发的终端文件管理器。配置保留 `h/j/k/l` 导航习惯，并启用面板边框、隐藏文件、预览和 Nerd Font 图标。`lfm` 包装函数会像 `ra` 一样，在正常退出后把当前 shell 切换到 lf 最后所在的目录。

## 安装与部署

`init.sh` 在 Debian/Ubuntu、Fedora/RHEL、Arch、Void 和 macOS 的包清单中安装 lf。NixOS 的系统包由 `nixos-config` 管理。配置目录通过 dotlink 部署：

```text
config/lf/ -> ~/.config/lf/
```

```bash
bash ~/dotfiles/dotlink/dotlink list
bash ~/dotfiles/dotlink/dotlink link
```

独立安装可使用发行版包，或遵循 [lf 官方发布说明](https://github.com/gokcehan/lf)。

## 配置

`config/lf/lfrc` 启用面板边框与圆角外框、Nerd Font 图标、文件预览、隐藏文件、大小写不敏感搜索，以及 Ranger 风格的移动、选择、剪切、复制、粘贴、删除、重命名、搜索和 shell 操作。`ex` 解压、`ec` 压缩。

`config/lf/icons` 基于 lf 官方图标示例，映射常见文件类型和扩展名。图标需要 Nerd Font 或兼容字体；若看到问号或方框，检查终端字体及 UTF-8 locale。

## 常用按键

| 键 | 作用 |
|---|---|
| `h` / `l` | 上级目录 / 进入目录或打开文件 |
| `j` / `k` | 上下移动 |
| `Space` | 选择当前项并移动到下一项 |
| `v` | 反转选择 |
| `dd` | 剪切当前项或选中项 |
| `yy` | 复制当前项或选中项 |
| `pp` | 粘贴 |
| `dD` | 删除（lf 会确认） |
| `cw` | 重命名 |
| `zh` / `zp` | 切换隐藏文件 / 预览 |
| `/`、`n`、`N` | 搜索、下一个、上一个匹配 |
| `S` | 在当前目录打开 shell |
| `ex` / `ec` | 解压 / 压缩 |
| `q` | 退出 |

未特别映射的按键沿用 lf 默认行为。完整列表见 `lf -doc` 或 lf 内的 `<f-1>`。

## 使用 lfm

```zsh
lfm             # 从当前目录启动
lfm ~/Downloads # 从指定目录启动
```

正常退出 lf 后，当前 shell 会切换到最后访问的目录。直接运行 `lf` 也可以，但不会改变父 shell 的工作目录。

## 归档依赖

归档操作调用系统程序：`tar`、`unzip`、`zip`、`unrar`、`7z`。`.tar.zst` 需要支持 `--zstd` 的 tar 和 zstd。缺少对应后端时，lf 会显示命令错误。

## 验证与排错

```bash
lf -version
readlink -f ~/.config/lf
lf -doc | head -30
```

- **配置没有生效**：确认 `readlink -f ~/.config/lf` 指向 dotfiles 的 `config/lf`，再运行 `bash ~/dotfiles/dotlink/dotlink link`。
- **图标显示为问号或方框**：在终端选择 Nerd Font，并使用 UTF-8 locale。
- **预览或归档命令失败**：检查所需系统工具是否安装。
- **退出后 shell 目录没有变化**：用 `lfm` 启动并正常退出；直接运行 `lf` 无法修改父 shell。

上游资料：[lf 官方文档](https://github.com/gokcehan/lf/blob/master/doc.md)、[官方图标示例](https://github.com/gokcehan/lf/blob/master/etc/icons.example)。

<!-- lang:en -->
> Summary: `lf` is a terminal file manager inspired by Ranger. This repository configures borders, Nerd Font icons, previews, familiar bindings, and a wrapper that changes directory on exit.

# lf

## Purpose

`lf` is a terminal file manager inspired by Ranger. The configuration keeps `h/j/k/l` navigation and enables pane borders, hidden files, previews, and Nerd Font icons. Like `ra`, the `lfm` wrapper changes the shell to the last directory visited after a normal exit.

## Installation and deployment

`init.sh` installs lf through system packages on Debian/Ubuntu, Fedora/RHEL, Arch, Void, and macOS. NixOS system packages are managed through `nixos-config`. Dotlink deploys the configuration directory:

```text
config/lf/ -> ~/.config/lf/
```

```bash
bash ~/dotfiles/dotlink/dotlink list
bash ~/dotfiles/dotlink/dotlink link
```

For standalone installation, use a distribution package or follow the [official lf release instructions](https://github.com/gokcehan/lf).

## Configuration

`config/lf/lfrc` enables pane borders with rounded outer corners, Nerd Font icons, file previews, hidden files, case-insensitive search, and Ranger-style movement, selection, cut/copy/paste, delete, rename, search, and shell bindings. `ex` extracts archives; `ec` creates them.

`config/lf/icons` is based on the official lf icon example and maps common file types and extensions. Icons require a Nerd Font or compatible terminal font. If glyphs appear as question marks or boxes, check the terminal font and UTF-8 locale.

## Common keys

| Key | Action |
|---|---|
| `h` / `l` | Parent directory / enter directory or open file |
| `j` / `k` | Move down / up |
| `Space` | Select current item and move down |
| `v` | Invert selection |
| `dd` | Cut current or selected items |
| `yy` | Copy current or selected items |
| `pp` | Paste |
| `dD` | Delete (lf asks for confirmation) |
| `cw` | Rename |
| `zh` / `zp` | Toggle hidden files / preview |
| `/`, `n`, `N` | Search, next match, previous match |
| `S` | Open a shell in the current directory |
| `ex` / `ec` | Extract / compress |
| `q` | Quit |

Unmapped keys keep lf's defaults. See `lf -doc` or press `<f-1>` inside lf for the full reference.

## Use lfm

```zsh
lfm             # start in the current directory
lfm ~/Downloads # start in a chosen directory
```

After lf exits normally, the shell changes to the last visited directory. Running `lf` directly works too, but cannot change its parent shell's working directory.

## Archive dependencies

Archive operations call system tools: `tar`, `unzip`, `zip`, `unrar`, and `7z`. `.tar.zst` requires tar with `--zstd` support and zstd. lf reports a command error when a required backend is missing.

## Verification and troubleshooting

```bash
lf -version
readlink -f ~/.config/lf
lf -doc | head -30
```

- **Configuration did not take effect:** check whether `readlink -f ~/.config/lf` points to dotfiles `config/lf`, then run `bash ~/dotfiles/dotlink/dotlink link`.
- **Icons show as question marks or boxes:** select a Nerd Font in the terminal and use a UTF-8 locale.
- **Preview or archive command fails:** check that the required system utility is installed.
- **The shell directory does not change after exit:** start lf through `lfm` and exit normally. Running `lf` directly cannot modify the parent shell.

Upstream references: [lf documentation](https://github.com/gokcehan/lf/blob/master/doc.md), [official icon example](https://github.com/gokcehan/lf/blob/master/etc/icons.example).

<!-- lang:ja -->
> 要約：lf は Ranger に着想を得たターミナルファイルマネージャーです。このリポジトリでは枠線、Nerd Font アイコン、プレビュー、Ranger 風のキー操作、終了後にディレクトリを移動する関数を設定しています。

# lf

## 用途

`lf` は Ranger に着想を得たターミナルファイルマネージャーです。`h/j/k/l` の移動を保ち、枠線、隠しファイル、プレビュー、Nerd Font アイコンを有効にしています。`lfm` 関数は `ra` と同じように動作し、正常終了後に lf で最後に開いていたディレクトリへシェルを移動します。

## インストールと配置

`init.sh` は Debian/Ubuntu、Fedora/RHEL、Arch、Void、macOS でシステムパッケージから lf をインストールします。NixOS では `nixos-config` でシステムパッケージを管理します。dotlink が設定ディレクトリを配置します。

```text
config/lf/ -> ~/.config/lf/
```

```bash
bash ~/dotfiles/dotlink/dotlink list
bash ~/dotfiles/dotlink/dotlink link
```

単独でインストールする場合はディストリビューションのパッケージ、または [lf 公式リリース手順](https://github.com/gokcehan/lf)を利用してください。

## 設定

`config/lf/lfrc` では、角丸の枠線、Nerd Font アイコン、ファイルプレビュー、隠しファイル、大文字小文字を区別しない検索、Ranger 風の移動・選択・切り取り・コピー・貼り付け・削除・名前変更・検索・シェル操作を有効にします。`ex` は展開、`ec` は圧縮です。

`config/lf/icons` は lf 公式アイコン例をもとに、一般的なファイル種別と拡張子を設定しています。表示には Nerd Font または互換フォントが必要です。文字が疑問符や四角形になる場合は、端末フォントと UTF-8 locale を確認してください。

## 主なキー

| キー | 操作 |
|---|---|
| `h` / `l` | 親ディレクトリ / ディレクトリに入る・ファイルを開く |
| `j` / `k` | 下 / 上へ移動 |
| `Space` | 項目を選択して次へ移動 |
| `v` | 選択を反転 |
| `dd` | 現在または選択項目を切り取り |
| `yy` | 現在または選択項目をコピー |
| `pp` | 貼り付け |
| `dD` | 削除（lf が確認を表示） |
| `cw` | 名前変更 |
| `zh` / `zp` | 隠しファイル / プレビューを切り替え |
| `/`、`n`、`N` | 検索、次の一致、前の一致 |
| `S` | 現在のディレクトリでシェルを開く |
| `ex` / `ec` | 展開 / 圧縮 |
| `q` | 終了 |

個別に設定していないキーは lf のデフォルト動作を使います。全キー一覧は `lf -doc` または lf 内の `<f-1>` で確認できます。

## lfm の使用

```zsh
lfm             # 現在のディレクトリから起動
lfm ~/Downloads # 指定ディレクトリから起動
```

lf を正常終了すると、シェルは最後に移動したディレクトリへ移ります。`lf` を直接起動することもできますが、親シェルの作業ディレクトリは変更できません。

## アーカイブの依存コマンド

アーカイブ操作では `tar`、`unzip`、`zip`、`unrar`、`7z` を呼び出します。`.tar.zst` には `--zstd` 対応の tar と zstd が必要です。必要なコマンドがない場合、lf はエラーを表示します。

## 確認とトラブルシューティング

```bash
lf -version
readlink -f ~/.config/lf
lf -doc | head -30
```

- **設定が反映されない：** `readlink -f ~/.config/lf` が dotfiles の `config/lf` を指すか確認し、`bash ~/dotfiles/dotlink/dotlink link` を実行します。
- **アイコンが疑問符や四角形になる：** 端末で Nerd Font を選び、UTF-8 locale を使います。
- **プレビューやアーカイブ操作が失敗する：** 必要なシステムコマンドがあるか確認します。
- **終了後にシェルのディレクトリが変わらない：** `lfm` から起動して正常終了してください。直接実行した `lf` は親シェルを変更できません。

上流資料：[lf 公式ドキュメント](https://github.com/gokcehan/lf/blob/master/doc.md)、[公式アイコン例](https://github.com/gokcehan/lf/blob/master/etc/icons.example)。
