> 摘要：mise 是现代的多语言与运行时版本管理器（asdf / nvm / pyenv 的 Rust 替代品），本仓库用 _evalcache 缓存其激活输出。

# mise

## 用途

`mise`（前身 rtx）是用 Rust 编写的现代化开发工具与运行时版本管理器：
- **多语言统一管理**：统一管理 Node.js、Python、Go、Rust、Java、Ruby 等多种语言和 CLI 工具版本，替代散落的 nvm、pyenv、rbenv、gvm。
- **按目录自动切换**：进入项目目录时，自动识别 `.mise.toml`、`.tool-versions`、`.node-version` 等配置文件并切换对应版本。
- **环境与任务运行**：支持定义项目专用的环境变量与自动化任务（类似 make / npm scripts）。

本仓库在 `init.sh` 中集成了它的安装，并在 `zshrc` 中通过 `_evalcache` 实现了快速激活。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 官方独立安装脚本或系统包管理器 |
| 安装方式 | `init.sh` 中自动执行 `curl -fsSL https://mise.run \| sh` |
| 安装路径 | `~/.local/bin/mise` |
| 缺失影响 | 仅跳过 `mise activate zsh`，不影响其它 Shell 插件 |

手工安装方式：

```bash
# 官方独立安装器（Linux / macOS）
curl https://mise.run | sh

# macOS Homebrew
brew install mise

# Arch Linux
sudo pacman -S mise
```

## 初始化与缓存

在 `zshrc` 中：

```zsh
if command -v mise > /dev/null; then
  _evalcache mise activate zsh
fi
```

`mise activate zsh` 会输出 shell hook 代码（监控目录变化并自动切换 PATH）。`_evalcache` 会将该输出缓存到 `~/.zsh-evalcache/` 下，只有当 `mise` 二进制文件更新时才会重新执行，确保每次打开新终端几乎零耗时。

## 常用命令

| 命令 | 说明 |
|---|---|
| `mise use <tool>@<version>` | 在当前目录使用指定版本（写入 `.mise.toml`） |
| `mise use -g <tool>@<version>` | 全局默认使用指定版本 |
| `mise ls` | 列出已安装的全部工具与当前激活版本 |
| `mise ls-remote <tool>` | 查看远程可安装的版本列表 |
| `mise install` | 根据当前目录的配置文件安装所有缺失的工具版本 |
| `mise uninstall <tool>@<version>` | 卸载特定版本 |
| `mise doctor` | 检查环境配置与 PATH 是否正确生效 |
| `mise run <task>` | 运行 `.mise.toml` 中配置的任务 |

## 实战例子

```bash
# 全局安装并使用 Node.js LTS 与 Python 3.12
mise use -g node@lts
mise use -g python@3.12

# 某个项目需要特定版本的 Go 和 Node
cd ~/projects/my-app
mise use go@1.22
mise use node@18

# 查看当前目录下生效的版本
mise ls
```

## 与 fnm 的关系

本仓库同时保留了 `fnm`：
- **`fnm`**：专注于 Node.js 的轻量、超快切换，配合 `setup_fnm.sh` 实现了按需惰性加载。
- **`mise`**：全功能的多语言环境编排工具，适合管理除 Node 之外的 Python、Go、Rust 工具链或复合项目。
两者在 PATH 管理上互不冲突，用户可按喜好和项目特征搭配使用。

<!-- lang:en -->
> Summary: mise is a modern polyglot dev tool and runtime manager (a fast Rust replacement for asdf / nvm / pyenv); this repo caches its activation via _evalcache.

# mise

## Purpose

`mise` (formerly rtx) is a modern developer tool and runtime version manager written in Rust:
- **Unified toolchains**: Manages versions for Node.js, Python, Go, Rust, Java, Ruby, and standalone CLI tools under a single interface, replacing fragmented nvm, pyenv, rbenv, and gvm tools.
- **Automatic directory-based switching**: Automatically detects `.mise.toml`, `.tool-versions`, `.node-version`, and switches active runtimes when entering project directories.
- **Environment & task execution**: Supports project-specific environment variables and task automation (similar to make / npm scripts).

This repository integrates `mise` in `init.sh` and activates it efficiently in `zshrc` using `_evalcache`.

## Source and Installation

| Item | Details |
|---|---|
| Source | Official standalone installer or system package manager |
| Installed by | `init.sh` runs `curl -fsSL https://mise.run \| sh` |
| Binary path | `~/.local/bin/mise` |
| Missing impact | Skips `mise activate zsh`; other shell features remain intact |

Manual installation:

```bash
# Official installer (Linux / macOS)
curl https://mise.run | sh

# macOS Homebrew
brew install mise

# Arch Linux
sudo pacman -S mise
```

## Initialization and Caching

In `zshrc`:

```zsh
if command -v mise > /dev/null; then
  _evalcache mise activate zsh
fi
```

`mise activate zsh` produces shell hooks to monitor directory changes and adjust `$PATH`. `_evalcache` caches this script in `~/.zsh-evalcache/`, re-evaluating it only when the `mise` binary itself is modified. This guarantees near-instant shell startup times.

## Common Commands

| Command | Description |
|---|---|
| `mise use <tool>@<version>` | Pin a tool version for the current directory (writes to `.mise.toml`) |
| `mise use -g <tool>@<version>` | Pin a tool version globally |
| `mise ls` | List installed tools and active versions |
| `mise ls-remote <tool>` | List available versions from upstream |
| `mise install` | Install all missing tools declared in the current project configuration |
| `mise uninstall <tool>@<version>` | Remove a specific tool version |
| `mise doctor` | Diagnose environment issues and PATH resolution |
| `mise run <task>` | Execute a task defined in `.mise.toml` |

## Practical Examples

```bash
# Set global default versions for Node.js LTS and Python 3.12
mise use -g node@lts
mise use -g python@3.12

# Pin specific Go and Node versions inside a project
cd ~/projects/my-app
mise use go@1.22
mise use node@18

# Inspect currently active versions
mise ls
```

## Relationship with fnm

This repository also maintains `fnm`:
- **`fnm`**: Focused exclusively on Node.js with ultra-fast lazy loading via `setup_fnm.sh`.
- **`mise`**: A full-featured polyglot manager suitable for Python, Go, Rust, and multi-language repositories.
Both coexist harmoniously on `$PATH`.

<!-- lang:ja -->
> 要約：mise は現代的な多言語・ランタイムバージョンマネージャ（asdf / nvm / pyenv の高速な Rust 代替）で、本リポジトリでは _evalcache によりアクティベーション出力をキャッシュします。

# mise

## 用途

`mise`（旧称 rtx）は Rust 製の現代的な開発ツールおよびランタイムバージョン管理ツールです：
- **複数言語の統合管理**：Node.js、Python、Go、Rust、Java、Ruby や各種 CLI ツールのバージョンを一元管理し、乱立する nvm、pyenv、rbenv、gvm を置き換えます。
- **ディレクトリ連動の自動切替**：プロジェクトディレクトリに移動した際、`.mise.toml`、`.tool-versions`、`.node-version` などを検知して自動で対応バージョンへ切り替えます。
- **環境変数とタスクランナー**：プロジェクト固有の環境変数や自動化タスク（make / npm scripts に類似）の定義をサポートします。

本リポジトリでは `init.sh` での自動インストールに対応し、`zshrc` 内で `_evalcache` を使って高速に初期化します。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | 公式スタンドアロンインストーラまたはシステムパッケージマネージャ |
| インストール方法 | `init.sh` 内で `curl -fsSL https://mise.run \| sh` を実行 |
| 配置先 | `~/.local/bin/mise` |
| 未インストール時 | `mise activate zsh` をスキップするのみで他機能には影響なし |

手動インストール：

```bash
# 公式インストーラ（Linux / macOS）
curl https://mise.run | sh

# macOS Homebrew
brew install mise

# Arch Linux
sudo pacman -S mise
```

## 初期化とキャッシュ

`zshrc` 内の記述：

```zsh
if command -v mise > /dev/null; then
  _evalcache mise activate zsh
fi
```

`mise activate zsh` はディレクトリ移動を検知して `$PATH` を切り替える shell hook コードを出力します。`_evalcache` はこの内容を `~/.zsh-evalcache/` にキャッシュし、`mise` バイナリが更新された場合のみ再実行するため、シェル起動時のオーバーヘッドをほぼゼロに抑えます。

## よく使うコマンド

| コマンド | 説明 |
|---|---|
| `mise use <tool>@<version>` | カレントディレクトリで使用するバージョンを指定（`.mise.toml` に保存） |
| `mise use -g <tool>@<version>` | グローバル既定のバージョンを指定 |
| `mise ls` | インストール済みツールと現在アクティブなバージョンを一覧表示 |
| `mise ls-remote <tool>` | リモートで提供されている利用可能なバージョン一覧を表示 |
| `mise install` | カレント設定で未インストールの全ツールを一括導入 |
| `mise uninstall <tool>@<version>` | 特定のバージョンをアンインストール |
| `mise doctor` | 設定状況や PATH が正しく解決されているか診断 |
| `mise run <task>` | `.mise.toml` で定義されたタスクを実行 |

## 実用例

```bash
# グローバル既定として Node.js LTS と Python 3.12 を設定
mise use -g node@lts
mise use -g python@3.12

# プロジェクト専用の Go と Node を指定
cd ~/projects/my-app
mise use go@1.22
mise use node@18

# 現在有効なバージョンを確認
mise ls
```

## fnm との関係

本リポジトリでは引き続き `fnm` も保持しています：
- **`fnm`**：Node.js に特化した超高速な切替器で、`setup_fnm.sh` によるオンデマンド遅延ロードと連携します。
- **`mise`**：Python、Go、Rust など多言語の複合スタックに適した汎用マネージャです。
両者は `$PATH` 上で競合することなく併用可能です。
