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
