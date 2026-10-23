> 摘要：nvim-update 把 Neovim 升级到最新稳定版，校验 SHA-256，原子切换软链接，保留旧版本可回退。

# nvim-update

## 用途

`nvim-update` 把用户级 Neovim 升级到 GitHub 最新稳定 release。它不碰系统包，不破坏现有版本，失败时能回退。

## 用法

```bash
nvim-update
nvim-update --help
```

`nvim-update` 是 `aliases.conf` 里定义的别名：

```zsh
alias nvim-update='bash "$HOME/dotfiles/scripts/update_nvim.sh"'
```

也可以直接运行脚本：

```bash
bash ~/dotfiles/scripts/update_nvim.sh
```

## 安装布局

```text
~/.local/opt/neovim/
├── 0.11.4/
│   ├── bin/nvim
│   └── share/nvim/runtime/
└── 0.12.5/
    ├── bin/nvim
    └── share/nvim/runtime/

~/.local/bin/nvim -> ~/.local/opt/neovim/0.12.5/bin/nvim
```

**旧版本保留**，所以回退只需要改软链接：

```bash
ln -sf ~/.local/opt/neovim/0.11.4/bin/nvim ~/.local/bin/nvim
```

## 完整流程

### 1. 前置检查

```bash
need curl
need jq
need tar
```

NixOS 直接拒绝：

```bash
if [[ "${ID:-}" == "nixos" ]]; then
  fail "NixOS detected; update Neovim through your NixOS package configuration instead."
fi
```

理由：绕过声明式包管理会导致系统和用户安装冲突。

### 2. 平台判定

```bash
case "$system:$machine" in
  Linux:x86_64|Linux:amd64) asset_name="nvim-linux-x86_64.tar.gz" ;;
  Linux:aarch64|Linux:arm64) asset_name="nvim-linux-arm64.tar.gz" ;;
  Darwin:x86_64) asset_name="nvim-macos-x86_64.tar.gz" ;;
  Darwin:arm64|Darwin:aarch64) asset_name="nvim-macos-arm64.tar.gz" ;;
  *) fail "Unsupported platform: $system/$machine" ;;
esac
```

### 3. 软链接安全检查

```bash
if [[ -e "$link" && ! -L "$link" ]]; then
  fail "Refusing to replace non-symlink file at $link."
fi
if [[ -L "$link" ]]; then
  existing_target="$(readlink "$link")"
  case "$existing_target" in
    "$INSTALL_ROOT"/*) ;;
    *) fail "Refusing to replace unrelated symlink at $link -> $existing_target" ;;
  esac
fi
```

只接管「指向自己安装根」的软链接。如果 `~/.local/bin/nvim` 指向系统包或别的地方，拒绝执行，让你手动处理。

### 4. 拉取 release 元数据

```bash
curl --fail --silent --show-error --location --retry 3 --output "$release_json" "$API_URL"

tag="$(jq -er '.tag_name | strings | select(test("^v[0-9]+\\.[0-9]+\\.[0-9]+$"))' "$release_json")"
```

`jq -e` 保证解析失败时退出码非零，`select(test(...))` 保证 tag 是稳定的语义化版本（排除 `nightly`、`prerelease`）。

### 5. 提取下载地址与摘要

```bash
asset_url="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .browser_download_url | strings | select(length > 0)' \
  "$release_json")"

expected_digest="$(jq -er --arg name "$asset_name" \
  '.assets[] | select(.name == $name) | .digest | strings
   | select(test("^sha256:[0-9a-fA-F]{64}$")) | sub("^sha256:"; "")' \
  "$release_json")"
```

**两处都是 `-e`**：字段缺失或格式不对时脚本立即失败，不会拿着空值继续。

### 6. 下载并校验

```bash
curl --fail --silent --show-error --location --retry 3 --output "$archive" "$asset_url"
actual_digest="$(sha256_file "$archive")"
if [[ "$actual_digest" != "$expected_digest" ]]; then
  fail "SHA-256 mismatch for $asset_name; refusing to install."
fi
```

摘要不匹配就中止，不安装。这是防篡改/防下载损坏的关键一步。

### 7. 解压到版本目录

```bash
version_dir="$INSTALL_ROOT/$version"
if [[ -L "$version_dir" ]]; then
  fail "Refusing to trust a symlink as the version directory"
fi

if [[ -d "$version_dir" ]]; then
  candidate="$version_dir/bin/nvim"
  [[ -x "$candidate" && -d "$version_dir/share/nvim/runtime" ]] \
    || fail "Existing version directory is incomplete"
else
  staging_dir="$(mktemp -d "$INSTALL_ROOT/.staging-$version.XXXXXX")"
  tar -xzf "$archive" -C "$staging_dir" --strip-components=1
  candidate="$staging_dir/bin/nvim"
  [[ -x "$candidate" && -d "$staging_dir/share/nvim/runtime" ]] \
    || fail "The release archive is missing Neovim's binary or runtime files."
  mv "$staging_dir" "$version_dir"
  staging_dir=""
  candidate="$version_dir/bin/nvim"
fi
```

三个保护：

1. 版本目录不能是软链接（防指向攻击）
2. 已存在的版本目录必须完整（有 bin 和 runtime）
3. 先解压到 staging，验证通过后才 `mv` 到最终位置

### 8. 验证二进制

```bash
version_line="$("$candidate" --version 2>&1)" || fail "The downloaded Neovim binary could not run."
case "$version_line" in
  *"NVIM v$version"*) ;;
  *) fail "Downloaded binary version did not match release tag $tag." ;;
esac
```

实际运行二进制并比对版本号。防止「下载的是对的包但里面是错的」。

### 9. 原子切换软链接

```bash
temp_link="$BIN_DIR/.nvim-update.$$.tmp"
ln -s "$candidate" "$temp_link"
mv -f "$temp_link" "$link"
```

先建临时链接，再 `mv -f` 覆盖。`mv` 在同一文件系统内是原子的，避免出现「链接短暂不存在」的窗口。

### 10. 最终验证

```bash
installed_line="$("$link" --version 2>&1)" || fail "Installed Neovim did not launch from $link."
case "$installed_line" in
  *"NVIM v$version"*) ;;
  *) fail "Installed command did not resolve to the expected Neovim $tag." ;;
esac
```

通过 `~/.local/bin/nvim` 再跑一次，确认路径解析正确。

## 环境变量

测试和特殊部署时可以覆盖：

| 变量 | 默认 |
|---|---|
| `NVIM_UPDATE_RELEASE_API_URL` | `https://api.github.com/repos/neovim/neovim/releases/latest` |
| `NVIM_UPDATE_INSTALL_ROOT` | `$HOME/.local/opt/neovim` |
| `NVIM_UPDATE_BIN_DIR` | `$HOME/.local/bin` |
| `NVIM_UPDATE_TMPDIR` | `${TMPDIR:-/tmp}` |

## 测试

```bash
bash scripts/tests/nvim_update_test.sh
```

测试用本地 fixture 模拟 GitHub API，不下载真实文件。它验证：

- 正常升级流程
- SHA-256 不匹配时拒绝安装
- `--help` 输出
- 别名正确传递参数

## 回退

```bash
ls ~/.local/opt/neovim/
ln -sf ~/.local/opt/neovim/0.11.4/bin/nvim ~/.local/bin/nvim
nvim --version
```

## 排错

**`Refusing to replace non-symlink file`**：`~/.local/bin/nvim` 是普通文件。先移走它。

**`Refusing to replace unrelated symlink`**：链接指向别处（比如 `/usr/bin/nvim`）。删除后重试。

**`SHA-256 mismatch`**：下载损坏或代理篡改。重试；持续失败检查网络中间设备。

**`does not provide a valid SHA-256 digest`**：GitHub API 返回的 release 缺 digest 字段。极旧或极新的 release 可能没有，等上游修复或手动安装。

**`NixOS detected`**：预期行为。用系统配置升级。

**升级后插件报错**：新版本 Neovim 可能改变 API。检查 `:checkhealth`，必要时回退。

<!-- lang:en -->
> Summary: `nvim-update` upgrades Neovim to the latest stable version, verifies SHA-256, switches the symlink atomically, and keeps old versions for rollback.

# nvim-update

## Purpose

`nvim-update` upgrades the user-level Neovim installation to the latest stable GitHub release. It does not touch system packages or damage the existing version, and it can roll back after a failure.

## Usage

`nvim-update` is an alias defined in `aliases.conf`. You can also run the script directly.

## Installation Layout

Old versions are retained, so rollback only requires changing the symlink.

## Complete Process

### 1. Prerequisite Checks

NixOS is rejected directly because bypassing declarative package management can create conflicts between system and user installations.

### 2. Platform Detection

### 3. Symlink Safety Check

Only symlinks pointing into the tool's own installation root are adopted. If `~/.local/bin/nvim` points to a system package or another location, execution is refused so you can handle it manually.

### 4. Fetch Release Metadata

`jq -e` makes parsing failures return a nonzero status; `select(test(...))` ensures the tag is a stable semantic version, excluding `nightly` and prereleases.

### 5. Extract the Download URL and Digest

**Both commands use `-e`**: if a field is missing or malformed, the script fails immediately instead of continuing with an empty value.

### 6. Download and Verify

A digest mismatch aborts installation. This is the key protection against tampering or a corrupted download.

### 7. Extract to the Version Directory

Three safeguards apply:

1. The version directory cannot be a symlink (prevents redirection attacks).
2. An existing version directory must be complete (it must contain `bin` and runtime files).
3. The archive is extracted to a staging directory and moved to its final location only after validation.

### 8. Verify the Binary

The binary is run and its version is compared with the release tag. This catches a package that has the right download but the wrong contents.

### 9. Switch the Symlink Atomically

A temporary link is created first, then `mv -f` replaces the target. On the same filesystem, `mv` is atomic, avoiding a window where the link is missing.

### 10. Final Verification

Run it once more through `~/.local/bin/nvim` to confirm path resolution.

## Environment Variables

These can be overridden for tests and special deployments:

| Variable | Default |
|---|---|
| `NVIM_UPDATE_RELEASE_API_URL` | `https://api.github.com/repos/neovim/neovim/releases/latest` |
| `NVIM_UPDATE_INSTALL_ROOT` | `$HOME/.local/opt/neovim` |
| `NVIM_UPDATE_BIN_DIR` | `$HOME/.local/bin` |
| `NVIM_UPDATE_TMPDIR` | `${TMPDIR:-/tmp}` |

## Tests

The test uses a local fixture to simulate the GitHub API and does not download real files. It verifies:

- The normal upgrade process
- Refusal to install when SHA-256 does not match
- `--help` output
- Correct argument forwarding by the alias

## Rollback

## Troubleshooting

**`Refusing to replace non-symlink file`**: `~/.local/bin/nvim` is a regular file. Move it out of the way first.

**`Refusing to replace unrelated symlink`**: The link points elsewhere (for example, `/usr/bin/nvim`). Remove it and retry.

**`SHA-256 mismatch`**: The download may be corrupted or altered by a proxy. Retry; if it continues, check network intermediaries.

**`does not provide a valid SHA-256 digest`**: The GitHub API release has no digest field. Very old or very new releases may lack it; wait for an upstream fix or install manually.

**`NixOS detected`**: This is expected. Upgrade through the system configuration.

**Plugins fail after upgrading**: A new Neovim version may change APIs. Check `:checkhealth` and roll back if needed.

<!-- lang:ja -->
> 要約：`nvim-update` は Neovim を最新の安定版に更新し、SHA-256 を検証してシンボリックリンクをアトミックに切り替え、旧バージョンをロールバック用に保持します。

# nvim-update

## 用途

`nvim-update` はユーザー用 Neovim を GitHub の最新安定版に更新します。システムパッケージには触れず、既存バージョンを壊さないようにし、失敗時にはロールバックできます。

## 使い方

`nvim-update` は `aliases.conf` で定義されたエイリアスです。スクリプトを直接実行することもできます。

## インストール構成

旧バージョンを保持するため、シンボリックリンクを変更するだけでロールバックできます。

## 処理の全体像

### 1. 事前確認

NixOS では実行を拒否します。宣言的なパッケージ管理を迂回すると、システム用とユーザー用のインストールが競合する可能性があるためです。

### 2. プラットフォームの判定

### 3. シンボリックリンクの安全確認

ツール自身のインストール先を指すシンボリックリンクだけを引き継ぎます。`~/.local/bin/nvim` がシステムパッケージなど別の場所を指している場合は、手動で対処できるよう実行を拒否します。

### 4. release メタデータの取得

`jq -e` により解析に失敗すると終了コードが 0 以外になります。`select(test(...))` により `nightly` や prerelease を除外し、安定版のセマンティックバージョン tag だけを受け入れます。

### 5. ダウンロード URL と digest の抽出

**どちらのコマンドにも `-e` を指定しています**。フィールドがない場合や形式が不正な場合、空の値で続行せず直ちに失敗します。

### 6. ダウンロードと検証

digest が一致しなければインストールを中止します。改ざんやダウンロード破損を防ぐ重要な手順です。

### 7. バージョンディレクトリへの展開

次の 3 点で保護します。

1. バージョンディレクトリをシンボリックリンクにできません（別の場所へ誘導する攻撃を防ぎます）。
2. 既存のバージョンディレクトリには `bin` と runtime ファイルが必要です。
3. staging ディレクトリに展開し、検証後に最終位置へ移動します。

### 8. バイナリの検証

バイナリを実行し、バージョンを release tag と照合します。正しいアーカイブ名でも内容が異なる場合に検出できます。

### 9. シンボリックリンクのアトミックな切り替え

最初に一時リンクを作り、その後 `mv -f` で置き換えます。同じファイルシステム内の `mv` はアトミックなので、リンクが一時的に消える状態を避けられます。

### 10. 最終確認

最後に `~/.local/bin/nvim` 経由でもう一度実行し、パス解決を確認します。

## 環境変数

テストや特殊な配置では、次の値を上書きできます。

| 変数 | デフォルト |
|---|---|
| `NVIM_UPDATE_RELEASE_API_URL` | `https://api.github.com/repos/neovim/neovim/releases/latest` |
| `NVIM_UPDATE_INSTALL_ROOT` | `$HOME/.local/opt/neovim` |
| `NVIM_UPDATE_BIN_DIR` | `$HOME/.local/bin` |
| `NVIM_UPDATE_TMPDIR` | `${TMPDIR:-/tmp}` |

## テスト

ローカル fixture で GitHub API を模擬するため、実際のファイルはダウンロードしません。次を検証します。

- 通常のアップグレード処理
- SHA-256 が一致しない場合のインストール拒否
- `--help` の出力
- エイリアスによる引数の正しい引き渡し

## ロールバック

## トラブルシューティング

**`Refusing to replace non-symlink file`**：`~/.local/bin/nvim` が通常ファイルです。まず別の場所へ移動してください。

**`Refusing to replace unrelated symlink`**：リンクが別の場所（例：`/usr/bin/nvim`）を指しています。削除してから再試行してください。

**`SHA-256 mismatch`**：ダウンロードの破損、またはプロキシによる変更が考えられます。再試行し、続く場合はネットワーク経路を確認してください。

**`does not provide a valid SHA-256 digest`**：GitHub API の release に digest フィールドがありません。非常に古い release や新しい release では未提供の場合があります。上流の修正を待つか、手動でインストールしてください。

**`NixOS detected`**：想定された動作です。システム設定からアップグレードしてください。

**更新後にプラグインがエラーになる**：新しい Neovim で API が変わった可能性があります。`:checkhealth` を確認し、必要ならロールバックしてください。
