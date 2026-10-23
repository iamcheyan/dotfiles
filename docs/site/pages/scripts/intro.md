> 摘要：哪些脚本是本仓库自研的，哪些是上游工具的安装器，各自的边界在哪。

# 本章导读

## 两类脚本

`scripts/` 和 `tools/` 下的内容分两类：

**自研**——本仓库为解决具体问题写的：

| 脚本 | 作用 |
|---|---|
| `dotlink/dotlink` | 软链接管理器 |
| `init.sh` | 跨平台初始化 |
| `scripts/update_nvim.sh` | Neovim 稳定版升级 |
| `plugins/fzf/fzf.zsh` 里的 `f` / `ffd` | 文件搜索函数 |
| `plugins/sshfs/vssh.sh` | SSH 主机选择与连接 |
| `plugins/sshfs/vifm-sshfs.sh` | SSHFS 挂载 + Vifm |
| `tools/packtar.sh` | 按 gitignore 打包 |
| `tools/unzip_here.sh` 等 | 批量解压 |
| `scripts/setup/setup_fnm.sh` | fnm 惰性加载 |
| `scripts/tmux-new` | tmux 会话恢复 |
| `scripts/tmux-clipboard-copy` | 跨平台本地剪贴板复制（WSL/Wayland/X11/macOS） |
| `scripts/tmux-copy` | SSH 优先 OSC 52，并回退到跨平台本地剪贴板 |

**上游安装器**——包装第三方工具的安装流程：

| 脚本 | 安装什么 |
|---|---|
| `scripts/install/install_font.sh` | Meslo + Noto Serif CJK |
| `scripts/install/install_nvim.sh` | Neovim 本体 |
| `scripts/install/install_httpie.sh` | HTTPie |
| `scripts/install/install_zellij.sh` | Zellij |

## 阅读顺序

1. [dotlink](dotlink.html) — 所有配置部署的基础，先理解它。
2. [init.sh](init.html) — 完整安装流程。
3. [Neovim 安装器](nvim-install.html) 与 [nvim-update](nvim-update.html) — 编辑器相关。
4. 其余安装器按需查阅。
5. [SSH 与 SSHFS](ssh.html)、[归档工具](archives.html) 是日常高频脚本。
6. [清理与系统脚本](cleanup.html) 涉及破坏性操作，读清楚再用。

## 共同设计原则

所有脚本遵循几条规则：

| 原则 | 体现 |
|---|---|
| 探测后执行 | `command -v` 判断依赖，缺失时给提示而非崩溃 |
| 跨平台 | 区分 Linux/macOS/WSL，架构分 x86_64/aarch64 |
| 可回退 | 安装失败时保留旧版本，不破坏现有环境 |
| 不静默覆盖 | 覆盖前备份或提示 |
| 校验下载 | Neovim 更新校验 SHA-256 |

例外也有：`init.sh` 的未知参数会被静默跳过，`tools/clear.sh` 直接执行清理不做确认。这两处在各自文档里明确标注。

## 修改脚本前

```bash
bash -n <script>        # 语法检查
shellcheck <script>     # 静态分析（如果装了）
```

涉及 `sudo`、`rm -rf`、`kill` 的脚本，先在容器或临时目录测试。

<!-- lang:en -->
> Summary: Which scripts are developed in this repository, which are installers for upstream tools, and where their respective boundaries lie.

# Chapter Overview

## Two Types of Scripts

Content under `scripts/` and `tools/` falls into two groups:

**Developed here** — written by this repository to solve specific problems:

| Script | Purpose |
|---|---|
| `dotlink/dotlink` | Symlink manager |
| `init.sh` | Cross-platform initialization |
| `scripts/update_nvim.sh` | Upgrade Neovim to the stable release |
| `f` / `ffd` in `plugins/fzf/fzf.zsh` | File search functions |
| `plugins/sshfs/vssh.sh` | Choose and connect to an SSH host |
| `plugins/sshfs/vifm-sshfs.sh` | Mount with SSHFS and use Vifm |
| `tools/packtar.sh` | Create archives according to gitignore rules |
| `tools/unzip_here.sh` and others | Batch extraction |
| `scripts/setup/setup_fnm.sh` | Lazy loading for fnm |
| `scripts/tmux-new` | tmux session recovery |
| `scripts/tmux-clipboard-copy` | Cross-platform local clipboard copying (WSL/Wayland/X11/macOS) |
| `scripts/tmux-copy` | Prefer SSH OSC 52, with cross-platform local clipboard fallback |

**Upstream installers** — wrap the installation process for third-party tools:

| Script | What it installs |
|---|---|
| `scripts/install/install_font.sh` | Meslo + Noto Serif CJK |
| `scripts/install/install_nvim.sh` | Neovim itself |
| `scripts/install/install_httpie.sh` | HTTPie |
| `scripts/install/install_zellij.sh` | Zellij |

## Reading Order

1. [dotlink](dotlink.html) — the foundation for deploying all configuration; start here.
2. [init.sh](init.html) — the complete installation process.
3. [Neovim installer](nvim-install.html) and [nvim-update](nvim-update.html) — editor-related scripts.
4. Consult the other installers as needed.
5. [SSH and SSHFS](ssh.html) and [archive tools](archives.html) are frequently used day-to-day scripts.
6. [Cleanup and system scripts](cleanup.html) involve destructive operations; read carefully before using them.

## Shared Design Principles

All scripts follow several rules:

| Principle | How it is applied |
|---|---|
| Detect before acting | Use `command -v` to check dependencies and report missing ones instead of crashing |
| Cross-platform | Distinguish Linux/macOS/WSL and x86_64/aarch64 architectures |
| Recoverable | Preserve the old version if installation fails; do not damage the existing environment |
| No silent overwrites | Back up or prompt before overwriting |
| Verify downloads | Check SHA-256 when updating Neovim |

There are exceptions: unknown arguments to `init.sh` are silently skipped, and `tools/clear.sh` performs cleanup without confirmation. These are clearly called out in their respective documentation.

## Before Changing Scripts

For scripts involving `sudo`, `rm -rf`, or `kill`, test in a container or temporary directory first.

<!-- lang:ja -->
> 要約：このリポジトリで独自に開発したスクリプトと、上流ツールのインストーラーを区別し、それぞれの範囲を説明します。

# この章の概要

## 2 種類のスクリプト

`scripts/` と `tools/` の内容は、次の 2 種類に分かれます。

**独自開発** — このリポジトリが具体的な問題を解決するために作成したものです。

| スクリプト | 役割 |
|---|---|
| `dotlink/dotlink` | シンボリックリンク管理ツール |
| `init.sh` | クロスプラットフォームの初期化 |
| `scripts/update_nvim.sh` | Neovim 安定版へのアップグレード |
| `plugins/fzf/fzf.zsh` 内の `f` / `ffd` | ファイル検索関数 |
| `plugins/sshfs/vssh.sh` | SSH ホストの選択と接続 |
| `plugins/sshfs/vifm-sshfs.sh` | SSHFS でマウントして Vifm で利用 |
| `tools/packtar.sh` | gitignore に従ったアーカイブ作成 |
| `tools/unzip_here.sh` など | 一括展開 |
| `scripts/setup/setup_fnm.sh` | fnm の遅延読み込み |
| `scripts/tmux-new` | tmux セッションの復旧 |
| `scripts/tmux-clipboard-copy` | WSL/Wayland/X11/macOS に対応したローカルクリップボードへのコピー |
| `scripts/tmux-copy` | SSH の OSC 52 を優先し、クロスプラットフォームのローカルクリップボードにフォールバック |

**上流インストーラー** — サードパーティ製ツールのインストール手順をまとめたものです。

| スクリプト | インストール対象 |
|---|---|
| `scripts/install/install_font.sh` | Meslo + Noto Serif CJK |
| `scripts/install/install_nvim.sh` | Neovim 本体 |
| `scripts/install/install_httpie.sh` | HTTPie |
| `scripts/install/install_zellij.sh` | Zellij |

## 読む順序

1. [dotlink](dotlink.html) — すべての設定を配置する基盤です。最初に読んでください。
2. [init.sh](init.html) — インストール全体の流れです。
3. [Neovim インストーラー](nvim-install.html) と [nvim-update](nvim-update.html) — エディター関連です。
4. その他のインストーラーは必要に応じて参照してください。
5. [SSH と SSHFS](ssh.html)、[アーカイブツール](archives.html) は日常的によく使うスクリプトです。
6. [クリーンアップとシステムスクリプト](cleanup.html) は破壊的な操作を含むため、使用前によく読んでください。

## 共通の設計原則

すべてのスクリプトは、次のルールに従います。

| 原則 | 実装内容 |
|---|---|
| 実行前に検出 | `command -v` で依存関係を確認し、不足時は異常終了ではなく案内を表示します |
| クロスプラットフォーム | Linux/macOS/WSL と x86_64/aarch64 の違いを考慮します |
| 復旧可能 | インストールに失敗した場合も旧バージョンを保持し、既存環境を壊しません |
| 無言で上書きしない | 上書き前にバックアップするか、確認します |
| ダウンロードを検証 | Neovim の更新時に SHA-256 を検証します |

例外もあります。`init.sh` は未知の引数を警告なしでスキップし、`tools/clear.sh` は確認せずにクリーンアップを実行します。これらは各ドキュメントで明記しています。

## スクリプトを変更する前に

`sudo`、`rm -rf`、`kill` を使うスクリプトは、まずコンテナーまたは一時ディレクトリでテストしてください。
