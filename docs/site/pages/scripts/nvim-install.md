> 摘要：install_nvim.sh 检查或安装 Neovim，处理平台、架构和版本约束。

# Neovim 安装器

## 用途

`scripts/install/install_nvim.sh` 负责把 Neovim 装到用户目录，不依赖系统包管理器。`init.sh` 会调用它，也可以单独运行。

与 `nvim-update` 的分工：安装器负责「从无到有」，更新器负责「从旧到新」。

## 用法

```bash
bash scripts/install/install_nvim.sh
bash scripts/install/install_nvim.sh --version 0.12.5
bash scripts/install/install_nvim.sh --force
```

## 参数

| 参数 | 作用 |
|---|---|
| 无 | 检查已安装版本，不满足最低要求则安装最新 |
| `--version <V>` / `-v <V>` | 安装指定版本 |
| `--force` / `-f` | 强制重装，即使已满足版本要求 |

最低版本要求由脚本内的常量定义（当前 0.12）。

## 平台与架构

```bash
case "$machine" in
    x86_64|amd64) ... ;;
    aarch64|arm64) ... ;;
esac
```

| 平台 | 架构 | 下载包 |
|---|---|---|
| Linux | x86_64 | `nvim-linux-x86_64.tar.gz` |
| Linux | aarch64 | `nvim-linux-arm64.tar.gz` |
| macOS | x86_64 | `nvim-macos-x86_64.tar.gz` |
| macOS | arm64 | `nvim-macos-arm64.tar.gz` |

## 安装位置

```text
~/.local/nvim/bin/nvim          # 可执行文件
~/.local/nvim/share/nvim/       # runtime
```

注意这与 `nvim-update` 的路径不同：

| 工具 | 安装根 |
|---|---|
| `install_nvim.sh` | `~/.local/nvim` |
| `nvim-update` | `~/.local/opt/neovim/<version>` |

两者都能用，但**不要混用**——`nvim-update` 会拒绝覆盖非自己管理的软链接。

## 版本检测

```bash
installed_version=$(TERM=dumb nvim --version 2>&1 | grep -vE '^\[' | head -n 1 \
  | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | sed 's/^v//')
```

`TERM=dumb` 和 `--headless` 用来抑制终端控制序列，避免把转义码混进解析。

## 校验安装

```bash
vimruntime=$(TERM=dumb "$install_dir/bin/nvim" --clean --headless \
  +'lua print(vim.env.VIMRUNTIME)' +q 2>&1 | grep -v "^$" | grep -vE '^\[' | tail -1)
```

安装后检查 `$VIMRUNTIME` 是否指向正确目录。这能捕获「二进制存在但 runtime 缺失」的不完整安装。

## 与 init.sh 的关系

```bash
bash "$nvim_init" --skip-plugins
```

`init.sh` 调用时传 `--skip-plugins`：只装 Neovim 本体和依赖，插件留给首次启动的 lazy.nvim。

原因：插件安装需要完整运行时（Treesitter parser、编译器），在安装脚本里做容易半途失败。

## 单独使用的场景

```bash
# 只想要 Neovim，不要整套 dotfiles
git clone https://github.com/iamcheyan/nvim.git ~/nvim
bash ~/nvim/init.sh
```

Neovim 仓库有自己的 `init.sh`，本脚本是它在 dotfiles 里的副本/包装。

## 排错

**`Unsupported platform`**：架构不在支持列表。检查 `uname -m`。

**下载失败**：网络问题。脚本用 curl/wget，检查代理设置。

**安装后 `nvim` 还是旧版本**：PATH 里 `~/.local/nvim/bin` 不在前面，或系统包优先。`command -v nvim` 确认。

**`--version` 指定的版本不存在**：检查 GitHub release 页面确认 tag 名。

**和 nvim-update 冲突**：两者管理不同的安装根。选一个用，不要交替。若已混用，先删掉 `~/.local/bin/nvim` 软链接再重建。

<!-- lang:en -->
> Summary: `install_nvim.sh` checks for or installs Neovim, handling platform, architecture, and version requirements.

# Neovim Installer

## Purpose

`scripts/install/install_nvim.sh` installs Neovim in the user's directory without relying on a system package manager. `init.sh` invokes it, and it can also be run on its own.

Its role relative to `nvim-update`: the installer handles going from no installation to an installation; the updater handles moving from an old version to a new one.

## Usage

## Options

| Option | Purpose |
|---|---|
| None | Check the installed version and install the latest if it does not meet the minimum requirement |
| `--version <V>` / `-v <V>` | Install the specified version |
| `--force` / `-f` | Force reinstallation even if the version requirement is already met |

The minimum version is defined by a constant in the script (currently 0.12).

## Platform and Architecture

| Platform | Architecture | Download archive |
|---|---|---|
| Linux | x86_64 | `nvim-linux-x86_64.tar.gz` |
| Linux | aarch64 | `nvim-linux-arm64.tar.gz` |
| macOS | x86_64 | `nvim-macos-x86_64.tar.gz` |
| macOS | arm64 | `nvim-macos-arm64.tar.gz` |

## Installation Location

The executable is installed at `~/.local/nvim/bin/nvim`; runtime files are placed under `~/.local/nvim/share/nvim/`.

This differs from the paths used by `nvim-update`:

| Tool | Installation root |
|---|---|
| `install_nvim.sh` | `~/.local/nvim` |
| `nvim-update` | `~/.local/opt/neovim/<version>` |

Both work, but **do not mix them**: `nvim-update` refuses to replace symlinks it does not manage.

## Version Detection

`TERM=dumb` and `--headless` suppress terminal control sequences so escape codes are not mixed into parsed output.

## Verify the Installation

After installation, check that `$VIMRUNTIME` points to the correct directory. This catches incomplete installations where the binary exists but the runtime files are missing.

## Relationship to init.sh

When invoked by `init.sh`, `--skip-plugins` is passed: only Neovim itself and its dependencies are installed, leaving plugins for lazy.nvim to install on first launch.

Reason: plugin installation requires a fully available runtime (Treesitter parsers and a compiler); doing it in the installer can fail partway through.

## Using It on Its Own

To install Neovim without the full dotfiles setup, clone the Neovim repository and run its `init.sh`.

The Neovim repository has its own `init.sh`; this script is its copy/wrapper in dotfiles.

## Troubleshooting

**`Unsupported platform`**: The architecture is not in the supported list. Check `uname -m`.

**Download failed**: This may be a network problem. The script uses curl/wget; check proxy settings.

**`nvim` is still an old version after installation**: `~/.local/nvim/bin` may not come first in PATH, or a system package may take precedence. Check with `command -v nvim`.

**The version specified with `--version` does not exist**: Check the GitHub release page to confirm the tag name.

**Conflict with nvim-update**: The two tools manage different installation roots. Choose one and do not alternate between them. If both have already been used, remove the `~/.local/bin/nvim` symlink first, then recreate it.

<!-- lang:ja -->
> 要約：`install_nvim.sh` はプラットフォーム、アーキテクチャ、バージョン要件を確認し、Neovim をインストールします。

# Neovim インストーラー

## 用途

`scripts/install/install_nvim.sh` はシステムのパッケージマネージャーに依存せず、ユーザーのディレクトリに Neovim をインストールします。`init.sh` から呼び出せるほか、単独でも実行できます。

`nvim-update` との役割分担は、インストーラーが未導入からの導入を担当し、更新ツールが旧バージョンから新バージョンへの移行を担当することです。

## 使い方

## オプション

| オプション | 役割 |
|---|---|
| なし | インストール済みのバージョンを確認し、最低要件を満たさない場合は最新版をインストールします |
| `--version <V>` / `-v <V>` | 指定したバージョンをインストールします |
| `--force` / `-f` | バージョン要件を満たしていても強制的に再インストールします |

最低バージョンはスクリプト内の定数で定義されています（現在は 0.12 です）。

## プラットフォームとアーキテクチャ

| プラットフォーム | アーキテクチャ | ダウンロードするアーカイブ |
|---|---|---|
| Linux | x86_64 | `nvim-linux-x86_64.tar.gz` |
| Linux | aarch64 | `nvim-linux-arm64.tar.gz` |
| macOS | x86_64 | `nvim-macos-x86_64.tar.gz` |
| macOS | arm64 | `nvim-macos-arm64.tar.gz` |

## インストール先

実行ファイルは `~/.local/nvim/bin/nvim` に、runtime ファイルは `~/.local/nvim/share/nvim/` 以下に配置されます。

`nvim-update` とはパスが異なります。

| ツール | インストール先のルート |
|---|---|
| `install_nvim.sh` | `~/.local/nvim` |
| `nvim-update` | `~/.local/opt/neovim/<version>` |

どちらも使用できますが、**混在させないでください**。`nvim-update` は自分が管理していないシンボリックリンクを置き換えません。

## バージョンの検出

`TERM=dumb` と `--headless` は端末制御シーケンスを抑制し、解析結果にエスケープコードが混ざらないようにします。

## インストールの検証

インストール後、`$VIMRUNTIME` が正しいディレクトリを指していることを確認します。実行ファイルは存在しても runtime が欠けている不完全なインストールを検出できます。

## init.sh との関係

`init.sh` から呼び出す場合は `--skip-plugins` を渡します。Neovim 本体と依存関係だけをインストールし、プラグインは初回起動時に lazy.nvim がインストールします。

理由：プラグインのインストールには Treesitter parser やコンパイラーを含む実行環境が必要です。インストールスクリプト内で行うと、途中で失敗しやすくなります。

## 単独で使う場合

dotfiles 一式ではなく Neovim だけを使う場合は、Neovim リポジトリを clone して、その `init.sh` を実行してください。

Neovim リポジトリには独自の `init.sh` があり、このスクリプトは dotfiles 内にあるそのコピー／ラッパーです。

## トラブルシューティング

**`Unsupported platform`**：アーキテクチャが対応一覧にありません。`uname -m` を確認してください。

**ダウンロード失敗**：ネットワークの問題が考えられます。スクリプトは curl/wget を使うため、プロキシ設定を確認してください。

**インストール後も `nvim` が古い**：PATH で `~/.local/nvim/bin` が先頭にないか、システムパッケージが優先されている可能性があります。`command -v nvim` で確認してください。

**`--version` で指定したバージョンが存在しない**：GitHub の release ページで tag 名を確認してください。

**nvim-update との競合**：2 つのツールは別々のインストール先を管理します。どちらか一方を選び、交互に使わないでください。すでに混在している場合は、まず `~/.local/bin/nvim` のシンボリックリンクを削除してから作り直してください。
