> 摘要：lf 是受 Ranger 启发的终端文件管理器；本仓库为它配置实心 Nerd Font 图标、彩色预览、fzf/ripgrep 搜索和目录跳转。

# lf

## 用途

`lf` 是受 Ranger 启发的终端文件管理器。此配置保留熟悉的 `h/j/k/l` 导航、面板边框、隐藏文件、预览和图标。`lfm` 包装函数会在正常退出后将 shell 切换到 lf 最后访问的目录。

## 安装与部署

`init.sh` 在 Debian/Ubuntu、Fedora/RHEL、Arch、Void 和 macOS 的包清单中安装 lf。NixOS 的系统包由系统配置管理。dotlink 部署配置目录：

```text
config/lf/ -> ~/.config/lf/
```

```bash
bash ~/dotfiles/dotlink/dotlink list
bash ~/dotfiles/dotlink/dotlink link
```

独立安装可使用发行版包，或遵循 [lf 官方发布说明](https://github.com/gokcehan/lf)。

## 配置

`config/lf/lfrc` 保留 Ranger 风格导航、边框、隐藏文件和预览。右侧信息栏显示权限、大小、修改时间和 inode 状态变更时间；按 `i` 查看详细文件信息。`ff` 用 fzf 搜索当前目录树，`fr` 用 ripgrep 搜索文件内容，`z` 从 zoxide 历史中交互跳转，`tw` 在当前目录打开 tmux 新窗口。`st` 按修改时间排序，`sn` 恢复自然文件名顺序。

`config/lf/preview` 用 bat 为文本预览上色、列出归档内容，并在支持时用 Kitty 图形协议、chafa 或 viu 显示图片。其他终端需要 chafa 或 viu 才能显示图片；缺少 bat 时文本预览回退到 sed。

`config/lf/icons` 参照 Ranger devicons，为目录和常见文件类型映射实心 Nerd Font 图标。需要 Nerd Font 或兼容字体。

## 常用按键

| 键 | 作用 |
|---|---|
| `h` / `l` | 上级目录 / 进入目录或打开文件 |
| `j` / `k` | 上下移动 |
| `Space` | 选择当前项并移动到下一项 |
| `v` | 反转选择 |
| `dd` / `yy` / `pp` | 剪切 / 复制 / 粘贴 |
| `dD` | 删除（lf 会确认） |
| `cw` | 重命名 |
| `zh` / `zp` | 切换隐藏文件 / 预览 |
| `/`、`n`、`N` | 搜索、下一个、上一个匹配 |
| `ff` / `fr` / `z` | 文件搜索 / 内容搜索 / zoxide 跳转 |
| `tw` | 在当前目录打开 tmux 新窗口 |
| `st` / `sn` | 按修改时间 / 自然文件名排序 |
| `i` | 查看文件详细信息 |
| `S` | 在当前目录打开 shell |
| `ex` / `ec` | 解压 / 压缩 |
| `q` | 退出 |

未特别映射的按键沿用 lf 默认行为。完整列表见 `lf -doc` 或 lf 内的 `<f-1>`。

## 使用 lfm

```zsh
lfm             # 从当前目录启动
lfm ~/Downloads # 从指定目录启动
```

正常退出 lf 后，当前 shell 会切换到最后访问的目录。直接运行 `lf` 不会改变父 shell 的工作目录。

## 归档依赖

归档操作调用 `tar`、`unzip`、`zip`、`unrar`、`7z`。`.tar.zst` 需要支持 `--zstd` 的 tar 和 zstd。

## 验证与排错

```bash
lf -version
readlink -f ~/.config/lf
lf -doc | head -30
```

- **配置没有生效**：确认 `readlink -f ~/.config/lf` 指向 dotfiles 的 `config/lf`，再运行 `bash ~/dotfiles/dotlink/dotlink link`。
- **图标显示为问号或方框**：在终端选择 Nerd Font，并使用 UTF-8 locale。
- **图片预览不可用**：Kitty 图形协议只适用于 Kitty 或兼容终端；其他终端安装 chafa 或 viu。
- **`ff`、`fr` 或 `z` 无法启动**：分别确认 fzf、ripgrep、zoxide 已安装。
- **退出后 shell 目录没有变化**：使用 `lfm` 启动并正常退出。

上游资料：[lf 官方文档](https://github.com/gokcehan/lf/blob/master/doc.md)、[Ranger devicons](https://github.com/alexanderjeurissen/ranger_devicons)。

<!-- lang:en -->
> Summary: `lf` is a terminal file manager inspired by Ranger, with solid Nerd Font icons, colored previews, fzf/ripgrep search, and directory jumps.

# lf

## Purpose

`lf` is a terminal file manager inspired by Ranger. This setup keeps familiar `h/j/k/l` navigation, pane borders, hidden files, previews, and icons. The `lfm` wrapper changes the shell to the last directory visited after a normal exit.

## Installation and deployment

`init.sh` installs lf through system packages on Debian/Ubuntu, Fedora/RHEL, Arch, Void, and macOS. NixOS packages are managed by the system configuration. Dotlink deploys the configuration directory:

```text
config/lf/ -> ~/.config/lf/
```

```bash
bash ~/dotfiles/dotlink/dotlink list
bash ~/dotfiles/dotlink/dotlink link
```

For standalone installation, use a distribution package or follow the [official lf release instructions](https://github.com/gokcehan/lf).

## Configuration

`config/lf/lfrc` preserves Ranger-style navigation, borders, hidden files, and previews. Its info column shows permissions, size, modification time, and inode change time. Press `i` for a detailed file view. `ff` searches the current tree with fzf, `fr` searches content with ripgrep, `z` picks a directory from zoxide history, and `tw` opens a tmux window in the current directory. Use `st` for modification-time sorting and `sn` for natural filename order.

`config/lf/preview` colorizes text with bat, lists archive contents, and displays images through Kitty graphics, chafa, or viu when available. Chafa or viu is needed for image previews outside Kitty; text falls back to sed without bat.

`config/lf/icons` follows Ranger devicons with solid Nerd Font glyphs for folders and common file types. Use Nerd Font or a compatible font.

## Common keys

| Key | Action |
|---|---|
| `h` / `l` | Parent directory / enter directory or open file |
| `j` / `k` | Move down / up |
| `Space` | Select current item and move down |
| `v` | Invert selection |
| `dd` / `yy` / `pp` | Cut / copy / paste |
| `dD` | Delete (lf asks for confirmation) |
| `cw` | Rename |
| `zh` / `zp` | Toggle hidden files / preview |
| `/`, `n`, `N` | Search, next match, previous match |
| `ff` / `fr` / `z` | Find files / search contents / jump to a zoxide directory |
| `tw` | Open a tmux window in the current directory |
| `st` / `sn` | Sort by modification time / natural filename order |
| `i` | Show detailed file information |
| `S` | Open a shell in the current directory |
| `ex` / `ec` | Extract / compress |
| `q` | Quit |

Unmapped keys keep lf's defaults. See `lf -doc` or press `<f-1>` inside lf for the full reference.

## Use lfm

```zsh
lfm             # start in the current directory
lfm ~/Downloads # start in a chosen directory
```

After lf exits normally, the shell changes to the last visited directory. Running `lf` directly cannot change its parent shell's working directory.

## Archive dependencies

Archive commands call `tar`, `unzip`, `zip`, `unrar`, and `7z`. `.tar.zst` requires tar with `--zstd` support and zstd.

## Verification and troubleshooting

```bash
lf -version
readlink -f ~/.config/lf
lf -doc | head -30
```

- **Configuration did not take effect:** check that `readlink -f ~/.config/lf` points to dotfiles `config/lf`, then run `bash ~/dotfiles/dotlink/dotlink link`.
- **Icons show as boxes:** select a Nerd Font in the terminal and use a UTF-8 locale.
- **Image previews are unavailable:** Kitty graphics work in Kitty or compatible terminals; install chafa or viu for other terminals.
- **`ff`, `fr`, or `z` does not start:** check that fzf, ripgrep, or zoxide is installed.
- **The shell directory does not change after exit:** start lf through `lfm` and exit normally.

Upstream references: [lf documentation](https://github.com/gokcehan/lf/blob/master/doc.md), [Ranger devicons](https://github.com/alexanderjeurissen/ranger_devicons).

<!-- lang:ja -->
> 要約：lf は Ranger に着想を得たターミナルファイルマネージャーです。実体のある Nerd Font アイコン、色付きプレビュー、fzf/ripgrep 検索、ディレクトリ移動を設定します。

# lf

## 用途

`lf` は Ranger に着想を得たターミナルファイルマネージャーです。`h/j/k/l` の移動、枠線、隠しファイル、プレビュー、アイコンを設定しています。`lfm` 関数で正常終了すると、シェルは最後に移動したディレクトリへ移ります。

## インストールと配置

`init.sh` は Debian/Ubuntu、Fedora/RHEL、Arch、Void、macOS でシステムパッケージから lf をインストールします。NixOS のパッケージはシステム設定で管理します。dotlink が設定を配置します。

```text
config/lf/ -> ~/.config/lf/
```

```bash
bash ~/dotfiles/dotlink/dotlink list
bash ~/dotfiles/dotlink/dotlink link
```

単独でインストールする場合はディストリビューションのパッケージ、または[lf 公式リリース手順](https://github.com/gokcehan/lf)を利用してください。

## 設定

`config/lf/lfrc` は Ranger 風の移動、枠線、隠しファイル、プレビューを保ちます。情報欄には権限、サイズ、更新日時、inode の状態変更時刻を表示します。`i` で詳細を確認できます。`ff` は fzf で現在のツリーを検索し、`fr` は ripgrep でファイル内容を検索します。`z` は zoxide 履歴から移動先を選び、`tw` は現在のディレクトリで tmux の新しいウィンドウを開きます。`st` は更新日時順、`sn` は自然なファイル名順です。

`config/lf/preview` は bat でテキストを色付けし、アーカイブの内容を一覧表示します。対応環境では Kitty グラフィックス、chafa、viu で画像を表示します。Kitty 以外では画像表示に chafa または viu が必要です。bat がない場合、テキストは sed で表示します。

`config/lf/icons` は Ranger devicons を参考に、ディレクトリと一般的なファイルへ Nerd Font の実体アイコンを割り当てます。Nerd Font または互換フォントが必要です。

## 主なキー

| キー | 操作 |
|---|---|
| `h` / `l` | 親ディレクトリ / ディレクトリに入る・ファイルを開く |
| `j` / `k` | 下 / 上へ移動 |
| `Space` | 項目を選択して次へ移動 |
| `v` | 選択を反転 |
| `dd` / `yy` / `pp` | 切り取り / コピー / 貼り付け |
| `dD` | 削除（lf が確認を表示） |
| `cw` | 名前変更 |
| `zh` / `zp` | 隠しファイル / プレビューを切り替え |
| `/`、`n`、`N` | 検索、次の一致、前の一致 |
| `ff` / `fr` / `z` | ファイル検索 / 内容検索 / zoxide ジャンプ |
| `tw` | 現在のディレクトリで tmux 新規ウィンドウを開く |
| `st` / `sn` | 更新日時順 / 自然なファイル名順 |
| `i` | ファイル詳細を表示 |
| `S` | 現在のディレクトリでシェルを開く |
| `ex` / `ec` | 展開 / 圧縮 |
| `q` | 終了 |

未設定のキーは lf のデフォルト動作を使います。全一覧は `lf -doc` または lf 内の `<f-1>` を参照してください。

## lfm の使用

```zsh
lfm             # 現在のディレクトリから起動
lfm ~/Downloads # 指定ディレクトリから起動
```

lf を正常終了すると、シェルは最後に移動したディレクトリへ移ります。`lf` を直接起動した場合、親シェルの作業ディレクトリは変わりません。

## アーカイブ依存

アーカイブ操作には `tar`、`unzip`、`zip`、`unrar`、`7z` を使います。`.tar.zst` には `--zstd` 対応 tar と zstd が必要です。

## 確認とトラブルシューティング

```bash
lf -version
readlink -f ~/.config/lf
lf -doc | head -30
```

- **設定が反映されない：** `readlink -f ~/.config/lf` が dotfiles の `config/lf` を指すか確認し、`bash ~/dotfiles/dotlink/dotlink link` を実行します。
- **アイコンが四角形になる：** 端末で Nerd Font を選び、UTF-8 locale を使います。
- **画像プレビューが使えない：** Kitty では Kitty グラフィックスを使います。他の端末では chafa または viu を導入します。
- **`ff`、`fr`、`z` が使えない：** fzf、ripgrep、zoxide の導入を確認します。
- **終了後にディレクトリが変わらない：** `lfm` から起動して正常終了してください。

上流資料：[lf 公式ドキュメント](https://github.com/gokcehan/lf/blob/master/doc.md)、[Ranger devicons](https://github.com/alexanderjeurissen/ranger_devicons)。
