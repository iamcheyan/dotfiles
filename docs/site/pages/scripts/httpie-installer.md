> 摘要：HTTPie 默认使用系统包管理器或 pipx；pip 仅供显式选择的虚拟环境。

# HTTPie 安装器

`install:httpie` 调用 `scripts/install/install_httpie.sh`。已有 `http` 时跳过，`--force` 可重装。

```bash
install:httpie
install:httpie --method package
install:httpie --method pipx
install:httpie --force
```

默认 `auto` 先使用系统包管理器，再调用共享 `install_pipx_tool.sh` 安装 pipx 和 HTTPie，不回退系统 pip。`--method pip` 仅在当前 Python 的 `sys.prefix != sys.base_prefix` 时允许：

```bash
python3 -m venv .venv
source .venv/bin/activate
install:httpie --method pip
```

| 系统 | pipx 安装命令 |
|---|---|
| Arch / EndeavourOS / Manjaro | `sudo pacman -S --needed --noconfirm python-pipx` |
| Debian / Ubuntu | `sudo apt-get install -y pipx` |
| Fedora | `sudo dnf install -y pipx` |
| macOS | `brew install pipx` |

共享安装器随后执行 `pipx ensurepath` 与 `pipx install httpie`。系统包安装失败时报告错误，不尝试绕过 PEP 668。未知系统需先通过系统包管理器安装 pipx。

回归验证：`python3 scripts/tests/pipx_install_test.py`，使用隔离命令替身，不调用本机包管理器。

<!-- lang:en -->
# HTTPie installer

`install:httpie` uses the system package manager, then the shared pipx installer. Existing `http` skips installation; `--force` reinstalls it. System pip is never an automatic fallback.

The shared installer installs pipx via pacman (`python-pipx`), apt-get, dnf or Homebrew, then runs `pipx ensurepath` and `pipx install httpie`. Unsupported systems must install pipx themselves. Explicit `--method pip` requires an active Python virtual environment (`sys.prefix != sys.base_prefix`); it never passes `--user` or bypasses PEP 668.

<!-- lang:ja -->
# HTTPie インストーラー

`install:httpie` はシステムのパッケージ管理、その次に共通 pipx インストーラーを使用します。`http` があればスキップし、`--force` で再インストールします。システム pip への自動フォールバックはありません。

pipx は pacman (`python-pipx`)、apt-get、dnf、Homebrew で導入し、`pipx ensurepath` と `pipx install httpie` を実行します。明示的な `--method pip` は有効な Python 仮想環境のみで使用でき、PEP 668 を回避しません。
