> 摘要：install_font.sh 安装 Meslo Nerd Font 与 Noto Serif CJK，供终端图标和中文显示使用。

# 字体安装器

## 用途

装两种字体：

| 字体 | 用途 |
|---|---|
| Meslo Nerd Font | 终端和编辑器的图标（Powerline、Devicons、Material） |
| Noto Serif CJK | 中日韩文字的字形 |

缺 Meslo 时图标显示成方框；缺 Noto 时中文可能显示成豆腐块。

## 用法

```bash
bash scripts/install/install_font.sh
bash scripts/install/install_font.sh --meslo
bash scripts/install/install_font.sh --noto
bash scripts/install/install_font.sh --all
bash scripts/install/install_font.sh --all --force
```

**注意**：这个脚本没有 `install:font` 别名。仓库的 `scripts/install/README.md` 里写着有，但当前 `aliases.conf` 没有定义，直接运行脚本。

## 参数

| 参数 | 短参数 | 作用 |
|---|---|---|
| `--meslo` | `-m` | 只装 Meslo |
| `--noto` | `-n` | 只装 Noto Serif |
| `--all` | `-a` | 两个都装 |
| `--force` | `-f` | 强制重装 |
| 无 | | 默认装 Meslo |

不指定字体类型时默认只装 Meslo（向后兼容）。

## Meslo 的下载与安装

```bash
MESLO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.tar.xz"
MESLO_TAR="$HOME/.cache/fonts/Meslo.tar.xz"
```

| 步骤 | 说明 |
|---|---|
| 缓存 | 下载到 `~/.cache/fonts/Meslo.tar.xz`，已存在则跳过 |
| 解压 Linux | `~/.fonts/`，然后 `fc-cache -fv` |
| 解压 macOS | `~/Library/Fonts/`，系统自动加载 |

版本固定为 v3.4.0，升级需要改脚本里的 URL。

## Noto Serif CJK 的安装

不是单个文件，而是从四个 zip 下载：

```bash
download_links=(
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/07_NotoSerifCJKjp.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/12_NotoSerifJP.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/09_NotoSerifCJKsc.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/14_NotoSerifSC.zip"
)
```

| 文件 | 内容 |
|---|---|
| `NotoSerifCJKjp` | 日文优先的 CJK 全字集 |
| `NotoSerifJP` | 日文字集 |
| `NotoSerifCJKsc` | 简体中文优先的 CJK 全字集 |
| `NotoSerifSC` | 简体中文字集 |

装四份是因为 CJK 字形的地区差异：同一个汉字在日文和简体中文里字形不同（比如「直」「骨」）。装了对应地区的字集，排版才正确。

脚本还会尝试 `git clone https://github.com/iamcheyan/fonts.git`，失败时只走下载路径。

## 已安装检测

```bash
check_meslo_installed() {
    ...
}
```

已装且未加 `--force` 时跳过，打印「✓ Meslo font is installed; skipping installation」。

## 验证

```bash
# Linux
fc-list | grep -i meslo
fc-list | grep -i "noto serif cjk"

# macOS
ls ~/Library/Fonts | grep -i meslo
```

在终端设置里选择 `MesloLGS Nerd Font` 或 `MesloLGS NF`。

## 图标测试

装完后测试图标是否正常：

```bash
echo "   󰈙 󰊢 󰉋 󰡨 󰅩"
```

如果显示成方框，说明字体没生效或终端没选中正确字体。

## 为什么需要 Nerd Font

本仓库多处使用 Nerd Font 私有区字符：

| 位置 | 字符 |
|---|---|
| Starship 提示符 | `❯`、``、`` |
| Vifm 文件图标 | ``、``、`` |
| Neovim 状态栏 | ``、`` |
| fzf 提示 | 无（纯文本） |

这些字符在 Unicode 私有使用区（PUA），普通字体没有对应字形。

## 排错

**图标显示成方框**：终端字体没选对。不是「装了就行」，要在终端配置里显式选择。

**中文显示成豆腐块**：Noto Serif CJK 没装，或终端的 fallback 字体链没包含它。

**`fc-cache` 找不到**：Linux 上需要 `fontconfig` 包。`sudo apt install fontconfig`。

**下载很慢**：Meslo 约 20MB，Noto 四个包合计约 100MB。`--meslo` 只装前者。

**`--force` 后还是旧字体**：字体缓存没刷新。`fc-cache -fv` 手动执行。

**macOS 上字体不显示**：`~/Library/Fonts` 权限问题，或需要重启应用（不是重启系统）。

**脚本报 `install:font: command not found`**：别名不存在，用完整路径 `bash scripts/install/install_font.sh`。

<!-- lang:en -->

> Summary: install_font.sh installs Meslo Nerd Font and Noto Serif CJK, for terminal icons and CJK display.

# Font Installer

## Purpose

Installs two fonts:

| Font | Use |
|---|---|
| Meslo Nerd Font | Icons in terminals and editors (Powerline, Devicons, Material) |
| Noto Serif CJK | Glyphs for Chinese, Japanese and Korean text |

Without Meslo, icons render as boxes; without Noto, Chinese may render as tofu.

## Usage

```bash
bash scripts/install/install_font.sh
bash scripts/install/install_font.sh --meslo
bash scripts/install/install_font.sh --noto
bash scripts/install/install_font.sh --all
bash scripts/install/install_font.sh --all --force
```

**Note**: there is no `install:font` alias for this script. The repository's `scripts/install/README.md` says there is, but the current `aliases.conf` doesn't define it — run the script directly.

## Arguments

| Argument | Short | Effect |
|---|---|---|
| `--meslo` | `-m` | Install Meslo only |
| `--noto` | `-n` | Install Noto Serif only |
| `--all` | `-a` | Install both |
| `--force` | `-f` | Force reinstall |
| none | | Meslo by default |

Without a font type specified, only Meslo is installed (for backward compatibility).

## Meslo Download and Install

```bash
MESLO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.tar.xz"
MESLO_TAR="$HOME/.cache/fonts/Meslo.tar.xz"
```

| Step | Description |
|---|---|
| Cache | Downloads to `~/.cache/fonts/Meslo.tar.xz`; skipped if already present |
| Extract on Linux | `~/.fonts/`, then `fc-cache -fv` |
| Extract on macOS | `~/Library/Fonts/`, loaded automatically by the system |

The version is pinned to v3.4.0; upgrading requires changing the URL in the script.

## Installing Noto Serif CJK

Not a single file but four zip downloads:

```bash
download_links=(
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/07_NotoSerifCJKjp.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/12_NotoSerifJP.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/09_NotoSerifCJKsc.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/14_NotoSerifSC.zip"
)
```

| File | Contents |
|---|---|
| `NotoSerifCJKjp` | CJK full set, Japanese-priority glyphs |
| `NotoSerifJP` | Japanese glyph set |
| `NotoSerifCJKsc` | CJK full set, Simplified Chinese-priority glyphs |
| `NotoSerifSC` | Simplified Chinese glyph set |

All four are installed because of regional differences in CJK glyphs: the same character can look different in Japanese and Simplified Chinese (e.g. 直 and 骨). Only with the matching regional glyph set installed does the typesetting come out right.

The script also tries `git clone https://github.com/iamcheyan/fonts.git`; on failure it falls back to the download path only.

## Installed Detection

```bash
check_meslo_installed() {
    ...
}
```

If already installed and `--force` wasn't given, it skips and prints "✓ Meslo font is installed; skipping installation".

## Verify

```bash
# Linux
fc-list | grep -i meslo
fc-list | grep -i "noto serif cjk"

# macOS
ls ~/Library/Fonts | grep -i meslo
```

Select `MesloLGS Nerd Font` or `MesloLGS NF` in your terminal settings.

## Icon Test

After installing, test that icons render:

```bash
echo "   󰈙 󰊢 󰉋 󰡨 󰅩"
```

If they show as boxes, the font isn't in effect or the terminal hasn't selected the right font.

## Why a Nerd Font Is Needed

This repository uses Nerd Font private-use-area characters in several places:

| Where | Characters |
|---|---|
| Starship prompt | `❯`、``、`` |
| Vifm file icons | ``、``、`` |
| Neovim statusline | ``、`` |
| fzf prompt | none (plain text) |

These characters live in the Unicode Private Use Area (PUA), which ordinary fonts have no glyphs for.

## Troubleshooting

**Icons render as boxes**: the terminal font isn't set correctly. Installing isn't enough — you must explicitly select the font in the terminal's configuration.

**Chinese renders as tofu**: Noto Serif CJK isn't installed, or the terminal's fallback font chain doesn't include it.

**`fc-cache` not found**: the `fontconfig` package is needed on Linux. `sudo apt install fontconfig`.

**Downloads are slow**: Meslo is about 20 MB, and the four Noto packages together about 100 MB. `--meslo` installs only the former.

**Old font still shows after `--force`**: the font cache wasn't refreshed. Run `fc-cache -fv` manually.

**Font doesn't show on macOS**: a permissions problem with `~/Library/Fonts`, or the app needs a restart (not the system).

**Script reports `install:font: command not found`**: the alias doesn't exist; use the full path `bash scripts/install/install_font.sh`.

<!-- lang:ja -->

> 要約：install_font.sh は Meslo Nerd Font と Noto Serif CJK をインストールし、ターミナルのアイコン表示と CJK 文字の表示に使います。

# フォントインストーラー

## 役割

2 種類のフォントをインストールします：

| フォント | 用途 |
|---|---|
| Meslo Nerd Font | ターミナルやエディタのアイコン（Powerline、Devicons、Material） |
| Noto Serif CJK | 中日韓文字のグリフ |

Meslo が欠けるとアイコンが四角に表示され、Noto が欠けると中国語が豆腐になることがあります。

## 使い方

```bash
bash scripts/install/install_font.sh
bash scripts/install/install_font.sh --meslo
bash scripts/install/install_font.sh --noto
bash scripts/install/install_font.sh --all
bash scripts/install/install_font.sh --all --force
```

**注意**：このスクリプトには `install:font` エイリアスがありません。リポジトリの `scripts/install/README.md` には存在すると書いてありますが、現在の `aliases.conf` では定義されていないので、スクリプトを直接実行してください。

## 引数

| 引数 | 短い形 | 働き |
|---|---|---|
| `--meslo` | `-m` | Meslo だけインストール |
| `--noto` | `-n` | Noto Serif だけインストール |
| `--all` | `-a` | 両方インストール |
| `--force` | `-f` | 強制再インストール |
| なし | | デフォルトで Meslo |

フォントの種類を指定しないときは Meslo だけ入ります（後方互換）。

## Meslo のダウンロードとインストール

```bash
MESLO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.tar.xz"
MESLO_TAR="$HOME/.cache/fonts/Meslo.tar.xz"
```

| 手順 | 説明 |
|---|---|
| キャッシュ | `~/.cache/fonts/Meslo.tar.xz` にダウンロード。既にあればスキップ |
| Linux で展開 | `~/.fonts/`、その後 `fc-cache -fv` |
| macOS で展開 | `~/Library/Fonts/`、システムが自動で読み込む |

バージョンは v3.4.0 に固定されています。上げるにはスクリプト内の URL を書き換える必要があります。

## Noto Serif CJK のインストール

1 つのファイルではなく、4 つの zip をダウンロードします：

```bash
download_links=(
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/07_NotoSerifCJKjp.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/12_NotoSerifJP.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/09_NotoSerifCJKsc.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/14_NotoSerifSC.zip"
)
```

| ファイル | 中身 |
|---|---|
| `NotoSerifCJKjp` | 日本語優先の CJK 全字セット |
| `NotoSerifJP` | 日本語の字セット |
| `NotoSerifCJKsc` | 簡体字中国語優先の CJK 全字セット |
| `NotoSerifSC` | 簡体字中国語の字セット |

4 つとも入れるのは、CJK の字形には地域差があるからです。同じ漢字でも日本語と簡体字中国語では形が違います（「直」「骨」など）。対応する地域の字セットが入ってはじめて、組版が正しくなります。

スクリプトは `git clone https://github.com/iamcheyan/fonts.git` も試みます。失敗したときはダウンロード経路だけにフォールバックします。

## インストール済みの判定

```bash
check_meslo_installed() {
    ...
}
```

インストール済みで `--force` がなければスキップし、「✓ Meslo font is installed; skipping installation」と表示します。

## 確認

```bash
# Linux
fc-list | grep -i meslo
fc-list | grep -i "noto serif cjk"

# macOS
ls ~/Library/Fonts | grep -i meslo
```

ターミナルの設定で `MesloLGS Nerd Font` か `MesloLGS NF` を選んでください。

## アイコンのテスト

インストール後にアイコンが正しく出るか確認します：

```bash
echo "   󰈙 󰊢 󰉋 󰡨 󰅩"
```

四角に表示されるなら、フォントが効いていないか、ターミナルで正しいフォントが選ばれていません。

## なぜ Nerd Font が必要か

このリポジトリでは複数の場所で Nerd Font の私的領域の文字を使っています：

| 場所 | 文字 |
|---|---|
| Starship プロンプト | `❯`、``、`` |
| Vifm のファイルアイコン | ``、``、`` |
| Neovim のステータスライン | ``、`` |
| fzf のプロンプト | なし（プレーンテキスト） |

これらの文字は Unicode の私用面（PUA）にあり、普通のフォントには対応するグリフがありません。

## トラブルシューティング

**アイコンが四角に表示される**：ターミナルのフォント設定が合っていません。「入れたから OK」ではなく、ターミナルの設定で明示的に選ぶ必要があります。

**中国語が豆腐になる**：Noto Serif CJK が入っていないか、ターミナルのフォールバック字体チェーンに含まれていません。

**`fc-cache` が見つからない**：Linux では `fontconfig` パッケージが必要です。`sudo apt install fontconfig`。

**ダウンロードが遅い**：Meslo は約 20MB、Noto の 4 パッケージは合計約 100MB です。`--meslo` なら前者だけ入れます。

**`--force` を使っても古いフォントのまま**：フォントキャッシュが更新されていません。`fc-cache -fv` を手動で実行します。

**macOS でフォントが出ない**：`~/Library/Fonts` の権限の問題か、アプリの再起動が必要です（システム再起動ではなく）。

**スクリプトが `install:font: command not found` を出す**：エイリアスは存在しません。フルパスの `bash scripts/install/install_font.sh` を使ってください。
