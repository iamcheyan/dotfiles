> 摘要：init.sh 的 11 个步骤、失败策略、平台分支，以及为什么顺序是现在这样。

# init.sh

## 用途

`init.sh` 是新机器的一键初始化：检查/安装依赖、配置 shell、部署配置。它把十几件分散的事串成一条流程。

## 用法

```bash
bash init.sh                # 完整
bash init.sh --minimal      # 跳过字体、Neovim、大型额外组件
bash init.sh --repair       # 修复 zinit 插件和已知的 Atuin migration 错误
```

## 失败策略

```bash
run_step() {
    local step_name="$1"; shift
    if ! "$@"; then
        print_warning "$step_name failed, skipping..."
    fi
}
```

每个步骤包在 `run_step` 里：失败打印 warning，继续下一步。**不会整体中断**。

这意味着脚本跑完 ≠ 全部成功。必须自己核对（见 [安装后核对](../start/verify.html)）。

## 11 个步骤

### Step 1：定位仓库

```bash
detect_dotfiles_dir
```

找到脚本所在仓库的根目录。失败则整体退出。

### Step 2：zsh

```bash
install_zsh
```

按发行版选择安装命令：apt、dnf、pacman、zypper 等。已安装则跳过。安装后询问是否设为默认 shell。

### Step 3：基础工具

```bash
install_essentials
```

git、curl、build-essential、unzip、tar 等。这是后续所有步骤的前提。

### Step 3.5：子模块

```bash
init_git_submodules
```

`git submodule update --init --recursive`。不做这步，`config/nvim` 会是空目录。

### Step 4：zinit

```bash
install_zinit
```

克隆 `zdharma-continuum/zinit` 到 `~/.zinit/bin`。

### Step 4.5：修复（可选）

```bash
if [[ "$REPAIR" == "true" ]]; then
    repair_zinit_plugins
fi
```

每次运行都会更新 Atuin：dpkg 安装先从配置的 apt 源升级；若版本仍低于 18.13.6，则用官方安装器安装到 `$HOME/.atuin/bin`。已有用户目录安装会运行 `atuin update`，新 shell 会优先使用该版本。其他安装方式尝试 `atuin update`。`--repair` 还会检查已知易损插件目录（atuin、broot），并检测 Atuin migration `20260224000100` 错误。若发现该错误，会把默认 `history.db` 移到带时间戳的备份文件，让 Atuin 下次启动时重建。自定义 `db_path` 不会自动移动。此操作只是恢复 shell 的应急措施；根治方式是升级到 Atuin 18.13.6 或更新版本，并让所有 shell 使用同一版本。

### Step 5：fnm

```bash
install_fnm
```

安装 Node 版本管理器。NixOS 上跳过，提示由系统配置管理。

### Step 6：Fresh

```bash
install_fresh
```

按平台选择安装方式：Linux/WSL 用官方 installer，macOS 用 Homebrew，Windows 用 winget。NixOS 跳过。

### Step 7：fzf

```bash
install_fzf
```

检查系统 fzf 版本，过旧时从 GitHub 安装新版。

### Step 8：dotlink

```bash
run_dotlink
```

调用 `dotlink` 建立所有软链接。**这一步之后配置就生效了**，即使后面失败。

### Step 8.5：Ranger 插件

```bash
install_ranger_devicons
install_ranger_archives
```

克隆两个 ranger 插件。它们也是 git 子模块，这里做兜底检查。

### Step 9：`.zshrc` 链接

创建 `~/.zshrc` → `~/dotfiles/zshrc` 的链接。

## 之后的额外步骤

脚本继续处理：

| 组件 | 说明 |
|---|---|
| 字体 | Meslo Nerd Font + Noto Serif CJK（`--minimal` 跳过） |
| Neovim | 调用子模块的 `init.sh --skip-plugins`（`--minimal` 跳过） |
| Docker | 仅 Linux |
| Zellij | 检查/安装 |
| gh-dash | gh 扩展 |
| Herdr | 本地 AI 助手 |
| mise | 多语言开发环境与运行时版本管理（curl -fsSL https://mise.run \| sh） |

## 平台分支

```bash
case "$OS" in
    debian|ubuntu) ... ;;
    fedora) ... ;;
    arch) ... ;;
    void) ... ;;
    darwin) ... ;;
    nixos) ... ;;
esac
```

NixOS 的分支特殊：**不安装任何系统包**，只做用户目录配置，然后提示用户去 `nixos-config` 声明依赖。

## 覆盖提示

```bash
echo "This script will:"
echo "  1. Create symlinks for config files (replacing existing files)"
echo "  2. Create a ~/.zshrc symlink (replacing the existing file)"
echo -e "${RED}Warning: existing config files will be overwritten.${NC}"
for i in {3..1}; do
    echo -ne "$i... \r"
    sleep 1
done
```

明确告知会覆盖，倒数 3 秒。没有交互确认，倒数结束就继续。

## 为什么不幂等

脚本设计成可以重复运行，但**重复运行仍会重新走所有步骤**。已安装的会跳过，但不会跳过检查本身。

想只更新配置：

```bash
git pull --ff-only
bash dotlink/dotlink link
```

不需要重跑 `init.sh`。

## 排错

**某步失败但脚本继续了**：这是设计行为。看 warning 信息，手动补该步骤。

**字体没装**：`--minimal` 跳过了。单独运行 `bash scripts/install/install_font.sh`。

**Neovim 版本旧**：可能 Step 9 之后 Neovim 步骤失败。单独跑 `bash config/nvim/init.sh`。

**`~/.zshrc` 还是旧文件**：Step 9 失败。手动 `bash dotlink/dotlink link`。

**NixOS 上装不了 Docker**：预期行为，脚本明确跳过。

<!-- lang:en -->

> Summary: init.sh's 11 steps, its failure strategy, its platform branches, and why the steps are ordered the way they are.

# init.sh

## Purpose

`init.sh` is the one-shot bootstrap for a new machine: it checks/installs dependencies, configures the shell, and deploys the configuration. It strings a dozen scattered tasks into one flow.

## Usage

```bash
bash init.sh                # 完整
bash init.sh --minimal      # 跳过字体、Neovim、大型额外组件
bash init.sh --repair       # Repair zinit plugins and the known Atuin migration error
```

## Failure Strategy

```bash
run_step() {
    local step_name="$1"; shift
    if ! "$@"; then
        print_warning "$step_name failed, skipping..."
    fi
}
```

Every step is wrapped in `run_step`: on failure it prints a warning and moves on to the next step. **It never aborts the whole run.**

This means "the script finished" ≠ "everything succeeded". You must verify things yourself (see [Post-install Verification](../start/verify.html)).

## The 11 Steps

### Step 1: Locate the Repository

```bash
detect_dotfiles_dir
```

Finds the root of the repository the script lives in. On failure, the whole script exits.

### Step 2: zsh

```bash
install_zsh
```

Picks the install command per distribution: apt, dnf, pacman, zypper, etc. Skipped if already installed. After installing, it asks whether to set zsh as the default shell.

### Step 3: Essential Tools

```bash
install_essentials
```

git, curl, build-essential, unzip, tar, etc. These are the prerequisite for every later step.

### Step 3.5: Submodules

```bash
init_git_submodules
```

`git submodule update --init --recursive`. Without this, `config/nvim` is an empty directory.

### Step 4: zinit

```bash
install_zinit
```

Clones `zdharma-continuum/zinit` into `~/.zinit/bin`.

### Step 4.5: Repair (optional)

```bash
if [[ "$REPAIR" == "true" ]]; then
    repair_zinit_plugins
fi
```

Every run updates Atuin: dpkg installations are upgraded from configured apt repositories first; if the resulting version is older than 18.13.6, the official installer places a current build in `$HOME/.atuin/bin`. Existing user installs run `atuin update`, and new shells prefer that copy. Other installation methods attempt `atuin update`. With `--repair`, it also checks known-fragile plugins (atuin, broot) and detects the Atuin migration `20260224000100` error. If found, it moves the default `history.db` to a timestamped backup so Atuin can recreate it on next use. A custom `db_path` is left untouched. This is an emergency recovery; the durable fix is to upgrade to Atuin 18.13.6 or newer and use the same version in every shell.

### Step 5: fnm

```bash
install_fnm
```

Installs the Node version manager. Skipped on NixOS, where the system config manages it.

### Step 6: Fresh

```bash
install_fresh
```

Chooses the install method per platform: the official installer on Linux/WSL, Homebrew on macOS, winget on Windows. Skipped on NixOS.

### Step 7: fzf

```bash
install_fzf
```

Checks the system fzf version and installs a newer one from GitHub if it's too old.

### Step 8: dotlink

```bash
run_dotlink
```

Calls `dotlink` to create all symlinks. **After this step the configuration is live**, even if later steps fail.

### Step 8.5: Ranger Plugins

```bash
install_ranger_devicons
install_ranger_archives
```

Clones the two ranger plugins. They are also git submodules; this is a fallback check.

### Step 9: The `.zshrc` Link

Creates the `~/.zshrc` → `~/dotfiles/zshrc` link.

## Extra Steps Afterwards

The script then handles:

| Component | Description |
|---|---|
| Fonts | Meslo Nerd Font + Noto Serif CJK (skipped with `--minimal`) |
| Neovim | Calls the submodule's `init.sh --skip-plugins` (skipped with `--minimal`) |
| Docker | Linux only |
| Zellij | Check/install |
| gh-dash | gh extension |
| Herdr | Local AI assistant |
| mise | Polyglot runtime version manager (curl -fsSL https://mise.run \| sh) |

## Platform Branches

```bash
case "$OS" in
    debian|ubuntu) ... ;;
    fedora) ... ;;
    arch) ... ;;
    void) ... ;;
    darwin) ... ;;
    nixos) ... ;;
esac
```

The NixOS branch is special: **it installs no system packages at all**, only sets up the user directories, then prompts the user to declare dependencies in `nixos-config`.

## Overwrite Warning

```bash
echo "This script will:"
echo "  1. Create symlinks for config files (replacing existing files)"
echo "  2. Create a ~/.zshrc symlink (replacing the existing file)"
echo -e "${RED}Warning: existing config files will be overwritten.${NC}"
for i in {3..1}; do
    echo -ne "$i... \r"
    sleep 1
done
```

It clearly states that files will be overwritten and counts down 3 seconds. There is no interactive confirmation; when the countdown ends it just continues.

## Why It's Not Idempotent

The script is designed to be re-runnable, but **re-running still walks through every step**. Installed items are skipped, but the checks themselves are not skipped.

To update only the configuration:

```bash
git pull --ff-only
bash dotlink/dotlink link
```

There's no need to re-run `init.sh`.

## Troubleshooting

**A step failed but the script continued**: that's by design. Read the warning messages and redo that step manually.

**Fonts weren't installed**: `--minimal` skipped them. Run `bash scripts/install/install_font.sh` on its own.

**Neovim version is old**: the Neovim step after Step 9 may have failed. Run `bash config/nvim/init.sh` on its own.

**`~/.zshrc` is still the old file**: Step 9 failed. Manually run `bash dotlink/dotlink link`.

**Docker can't be installed on NixOS**: expected behavior; the script skips it deliberately.

<!-- lang:ja -->

> 要約：init.sh の 11 ステップ、失敗時の方針、プラットフォームごとの分岐、そして順序が今こうなっている理由。

# init.sh

## 役割

`init.sh` は新しいマシンをワンショットで初期化します：依存の確認・インストール、シェルの設定、設定ファイルの配置。散らばった十数個の作業を 1 本の流れにつなげたものです。

## 使い方

```bash
bash init.sh                # 完整
bash init.sh --minimal      # 跳过字体、Neovim、大型额外组件
bash init.sh --repair       # zinit プラグインと既知の Atuin migration エラーを修復
```

## 失敗時の方針

```bash
run_step() {
    local step_name="$1"; shift
    if ! "$@"; then
        print_warning "$step_name failed, skipping..."
    fi
}
```

各ステップは `run_step` で包まれています：失敗したら warning を出して次のステップへ進みます。**全体を中断することはありません。**

つまり、スクリプトが最後まで走った ≠ 全部成功です。自分で確認する必要があります（[インストール後の確認](../start/verify.html) を参照）。

## 11 のステップ

### Step 1：リポジトリの場所特定

```bash
detect_dotfiles_dir
```

スクリプトが属するリポジトリのルートを見つけます。失敗した場合は全体が終了します。

### Step 2：zsh

```bash
install_zsh
```

ディストリビューションに応じてインストールコマンドを選びます：apt、dnf、pacman、zypper など。インストール済みならスキップ。インストール後、デフォルトシェルにするか尋ねます。

### Step 3：基本ツール

```bash
install_essentials
```

git、curl、build-essential、unzip、tar など。以降のすべてのステップの前提です。

### Step 3.5：サブモジュール

```bash
init_git_submodules
```

`git submodule update --init --recursive`。これをしないと `config/nvim` は空のディレクトリのままです。

### Step 4：zinit

```bash
install_zinit
```

`zdharma-continuum/zinit` を `~/.zinit/bin` にクローンします。

### Step 4.5：修復（任意）

```bash
if [[ "$REPAIR" == "true" ]]; then
    repair_zinit_plugins
fi
```

毎回 `atuin update` による Atuin の更新を試みます。システムのパッケージマネージャーでインストールされ、自動更新できない場合は、そのパッケージマネージャーで更新するよう表示します。`--repair` では既知の壊れやすいプラグイン（atuin、broot）を確認し、Atuin migration `20260224000100` エラーも検出します。エラーがあれば、既定の `history.db` を日時付きバックアップ名に移動し、次回 Atuin 起動時に再作成できるようにします。カスタム `db_path` は自動で移動しません。これは緊急復旧であり、根本修正には Atuin 18.13.6 以降へ更新し、全 shell で同じバージョンを使ってください。

### Step 5：fnm

```bash
install_fnm
```

Node のバージョンマネージャーをインストールします。NixOS ではスキップし、システム設定で管理するよう促します。

### Step 6：Fresh

```bash
install_fresh
```

プラットフォームに応じてインストール方法を選びます：Linux/WSL は公式 installer、macOS は Homebrew、Windows は winget。NixOS ではスキップ。

### Step 7：fzf

```bash
install_fzf
```

システムの fzf のバージョンを確認し、古すぎる場合は GitHub から新版を入れます。

### Step 8：dotlink

```bash
run_dotlink
```

`dotlink` を呼んですべてのシンボリックリンクを作ります。**このステップの後には設定が有効になっています。**その後で失敗してもです。

### Step 8.5：Ranger プラグイン

```bash
install_ranger_devicons
install_ranger_archives
```

ranger の 2 つのプラグインをクローンします。どちらも git サブモジュールなので、ここでは念押しのチェックになります。

### Step 9：`.zshrc` のリンク

`~/.zshrc` → `~/dotfiles/zshrc` のリンクを作ります。

## その後の追加ステップ

スクリプトはさらに次を処理します：

| コンポーネント | 説明 |
|---|---|
| フォント | Meslo Nerd Font + Noto Serif CJK（`--minimal` でスキップ） |
| Neovim | サブモジュールの `init.sh --skip-plugins` を呼び出し（`--minimal` でスキップ） |
| Docker | Linux のみ |
| Zellij | 確認・インストール |
| gh-dash | gh 拡張 |
| Herdr | ローカル AI アシスタント |
| mise | 多言語・ランタイムバージョン管理（curl -fsSL https://mise.run \| sh） |

## プラットフォームの分岐

```bash
case "$OS" in
    debian|ubuntu) ... ;;
    fedora) ... ;;
    arch) ... ;;
    void) ... ;;
    darwin) ... ;;
    nixos) ... ;;
esac
```

NixOS の分岐は特殊です：**システムパッケージは一切インストールせず**、ユーザーディレクトリの設定だけを行い、依存は `nixos-config` で宣言するよう促します。

## 上書きの警告

```bash
echo "This script will:"
echo "  1. Create symlinks for config files (replacing existing files)"
echo "  2. Create a ~/.zshrc symlink (replacing the existing file)"
echo -e "${RED}Warning: existing config files will be overwritten.${NC}"
for i in {3..1}; do
    echo -ne "$i... \r"
    sleep 1
done
```

上書きすることを明示し、3 秒カウントダウンします。対話的な確認はなく、カウントダウンが終わればそのまま進みます。

## なべき等でないのか

スクリプトは繰り返し実行できるように設計されていますが、**再実行でも全ステップを通しで走ります**。インストール済みのものはスキップされますが、確認そのものは省略されません。

設定だけを更新したいとき：

```bash
git pull --ff-only
bash dotlink/dotlink link
```

`init.sh` を再実行する必要はありません。

## トラブルシューティング

**あるステップが失敗したのにスクリプトが続いた**：設計どおりの動作です。warning の文面を読み、そのステップを手動でやり直します。

**フォントが入っていない**：`--minimal` でスキップされました。`bash scripts/install/install_font.sh` を単独で実行します。

**Neovim のバージョンが古い**：Step 9 の後の Neovim ステップが失敗した可能性があります。`bash config/nvim/init.sh` を単独で実行します。

**`~/.zshrc` がまだ古いファイルのまま**：Step 9 が失敗しています。手動で `bash dotlink/dotlink link` を実行します。

**NixOS で Docker を入れられない**：想定内の動作です。スクリプトは明示的にスキップします。
