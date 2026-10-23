> 摘要：install_zellij.sh 支持 cargo 源码编译和下载预编译二进制两种安装方式。

# Zellij 安装器

## 用途

`scripts/install/install_zellij.sh` 安装 Zellij。它支持两种方式：Cargo 源码编译，或下载 Linux 预编译二进制。

## 用法

```bash
bash scripts/install/install_zellij.sh
bash scripts/install/install_zellij.sh --method binary
bash scripts/install/install_zellij.sh --method cargo
bash scripts/install/install_zellij.sh --method cargo --force
```

## 参数

| 参数 | 作用 |
|---|---|
| `--method auto` | 默认。有 Cargo 就编译，否则下二进制 |
| `--method cargo` | 强制源码编译 |
| `--method binary` | 强制下载预编译 |
| `--force` | 已安装时也重装 |

## auto 的判断逻辑

```bash
if [ "$INSTALL_METHOD" = "auto" ]; then
    if command_exists cargo; then
        install_with_cargo
    else
        install_with_binary
    fi
fi
```

有 Rust 工具链就编译，否则用二进制。编译耗时几分钟，但能得到针对本机优化的版本。

## cargo 方式

```bash
install_with_cargo() {
    if ! command_exists cargo; then
        print_error "cargo not found; install Rust first"
        return 1
    fi
    ...
    cargo install zellij
}
```

失败处理：

```bash
if [ $? -eq 0 ]; then
    print_success "zellij installed successfully!"
else
    if [ "$was_installed" = "true" ]; then
        print_warning "Reinstallation failed, but the previous version is still available"
        ...
        return 0  # 旧版本还在，视为成功
    else
        print_error "cargo installation failed"
        return 1
    fi
fi
```

**重装失败但旧版本可用时返回 0**，不破坏现有环境。这是脚本里值得注意的设计。

## binary 方式

```bash
ARCH=$(detect_arch)
VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest \
  | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' || echo "v0.40.0")

DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/${VERSION}/zellij-${ARCH}-unknown-linux-musl.tar.gz"
BIN_DIR="$HOME/.local/bin"
```

| 架构 | 下载包 |
|---|---|
| x86_64 | `zellij-x86_64-unknown-linux-musl.tar.gz` |
| aarch64 | `zellij-aarch64-unknown-linux-musl.tar.gz` |

musl 版本静态链接，不依赖系统 glibc。

安装到 `~/.local/bin/zellij`，如果该目录不在 PATH 会给出提示。

## 已安装检测

```bash
if check_installed && [ "$FORCE" != "true" ]; then
    read -p "zellij is installed; reinstall it? (y/N): " -n 1 -r
    ...
fi
```

已安装时**交互式询问**是否重装，默认 N。这一点和 `install_httpie.sh` 不同（后者直接跳过）。

## 与 Zinit 的关系

`plugins/tools/tools.zsh` 里也有：

```zsh
zi_cmd zellij-org/zellij zellij
```

两条路径都能得到 `zellij` 命令：

| 来源 | 位置 |
|---|---|
| Zinit | `~/.zinit/plugins/zellij-org---zellij/zellij` |
| 本安装器 | `~/.local/bin/zellij` |

PATH 顺序决定用哪个。通常 Zinit 目录在前。

## 验证

```bash
zellij --version
command -v zellij
```

## 排错

**`cargo not found`**：没装 Rust。用 `--method binary` 或先装 Rust。

**编译时 SIGKILL**：内存不足。脚本提示：

```text
If compilation fails (for example, SIGKILL), you may be out of memory
```

改用 `--method binary`。

**下载失败**：网络问题，或 GitHub API 限流。脚本用 `curl -s`，失败时回退到硬编码的 `v0.40.0`。

**装完 `zellij` 命令找不到**：`~/.local/bin` 不在 PATH。脚本会打印提示。

**版本和 Zinit 的不一致**：`command -v zellij` 确认实际用的是哪个。

**在非 Linux 上运行**：binary 分支只支持 Linux。macOS 用 `--method cargo` 或 Homebrew。

<!-- lang:en -->
> Summary: `install_zellij.sh` supports two installation methods: compiling from source with Cargo or downloading a prebuilt binary.

# Zellij Installer

## Purpose

`scripts/install/install_zellij.sh` installs Zellij. It supports Cargo source compilation and downloading a prebuilt Linux binary.

## Usage

## Options

| Option | Purpose |
|---|---|
| `--method auto` | Default. Compile if Cargo is available; otherwise download a binary |
| `--method cargo` | Force source compilation |
| `--method binary` | Force downloading a prebuilt binary |
| `--force` | Reinstall even if already installed |

## How auto Chooses

If the Rust toolchain is available, it compiles; otherwise it uses a binary. Compilation takes a few minutes but can produce a build optimized for the machine.

## cargo Method

If reinstallation fails but the previous version is still available, the script **returns 0** and preserves the existing environment. This behavior is worth noting.

## binary Method

| Architecture | Download archive |
|---|---|
| x86_64 | `zellij-x86_64-unknown-linux-musl.tar.gz` |
| aarch64 | `zellij-aarch64-unknown-linux-musl.tar.gz` |

The musl build is statically linked and does not depend on the system glibc.

It installs to `~/.local/bin/zellij` and prints a notice if that directory is not in PATH.

## Check Whether It Is Installed

When Zellij is already installed, the script **asks interactively** whether to reinstall; the default is N. This differs from `install_httpie.sh`, which skips installation directly.

## Relationship to Zinit

`plugins/tools/tools.zsh` also provides:

Both paths provide the `zellij` command:

| Source | Location |
|---|---|
| Zinit | `~/.zinit/plugins/zellij-org---zellij/zellij` |
| This installer | `~/.local/bin/zellij` |

PATH order determines which one is used. Usually the Zinit directory comes first.

## Verify

## Troubleshooting

**`cargo not found`**: Rust is not installed. Use `--method binary` or install Rust first.

**SIGKILL during compilation**: There may not be enough memory. The script displays a notice; use `--method binary` instead.

**Download failed**: This may be a network issue or GitHub API rate limiting. The script uses `curl -s`; on failure it falls back to the hardcoded `v0.40.0`.

**The `zellij` command is not found after installation**: `~/.local/bin` is not in PATH. The script prints a notice.

**Version differs from Zinit**: Use `command -v zellij` to check which installation is active.

**Running outside Linux**: The binary branch supports Linux only. On macOS, use `--method cargo` or Homebrew.

<!-- lang:ja -->
> 要約：`install_zellij.sh` は Cargo によるソースビルドと、ビルド済みバイナリのダウンロードという 2 つの方法に対応します。

# Zellij インストーラー

## 用途

`scripts/install/install_zellij.sh` は Zellij をインストールします。Cargo でのソースビルドと、Linux 用ビルド済みバイナリのダウンロードに対応しています。

## 使い方

## オプション

| オプション | 役割 |
|---|---|
| `--method auto` | デフォルトです。Cargo があればビルドし、なければバイナリをダウンロードします |
| `--method cargo` | ソースからのビルドを強制します |
| `--method binary` | ビルド済みバイナリのダウンロードを強制します |
| `--force` | インストール済みでも再インストールします |

## auto の判定

Rust ツールチェーンがあればビルドし、なければバイナリを使います。ビルドには数分かかりますが、マシンに合わせて最適化されたバージョンを作成できます。

## cargo 方式

再インストールに失敗しても旧バージョンが利用可能な場合、スクリプトは **終了コード 0 を返し**、既存環境を保持します。注目すべき動作です。

## binary 方式

| アーキテクチャ | ダウンロードするアーカイブ |
|---|---|
| x86_64 | `zellij-x86_64-unknown-linux-musl.tar.gz` |
| aarch64 | `zellij-aarch64-unknown-linux-musl.tar.gz` |

musl 版は静的リンクされており、システムの glibc に依存しません。

`~/.local/bin/zellij` にインストールし、このディレクトリが PATH にない場合は案内を表示します。

## インストール済みかどうかの確認

すでにインストールされている場合、再インストールするかを**対話形式で確認**します。デフォルトは N です。インストールをそのままスキップする `install_httpie.sh` とは異なります。

## Zinit との関係

`plugins/tools/tools.zsh` にも設定があります。

どちらの経路でも `zellij` コマンドを利用できます。

| 提供元 | 場所 |
|---|---|
| Zinit | `~/.zinit/plugins/zellij-org---zellij/zellij` |
| このインストーラー | `~/.local/bin/zellij` |

どちらを使うかは PATH の順序で決まります。通常は Zinit のディレクトリが先です。

## 検証

## トラブルシューティング

**`cargo not found`**：Rust がインストールされていません。`--method binary` を使うか、先に Rust をインストールしてください。

**ビルド中に SIGKILL が発生する**：メモリ不足の可能性があります。スクリプトの案内に従い、`--method binary` を使ってください。

**ダウンロード失敗**：ネットワークの問題、または GitHub API のレート制限が考えられます。スクリプトは `curl -s` を使い、失敗すると固定値 `v0.40.0` にフォールバックします。

**インストール後に `zellij` コマンドが見つからない**：`~/.local/bin` が PATH にありません。スクリプトが案内を表示します。

**Zinit とバージョンが異なる**：`command -v zellij` で実際に使われているインストール先を確認してください。

**Linux 以外で実行する**：binary 分岐は Linux のみ対応です。macOS では `--method cargo` または Homebrew を使ってください。
