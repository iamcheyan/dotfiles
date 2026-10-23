> 摘要：clear.sh 是 WSL 清理脚本，会执行破坏性操作；winetricks.sh 负责在特殊发行版上转发调用。

# 清理与系统脚本

## tools/clear.sh

### 用途

WSL 全系统清理：Cargo 缓存、Rust 旧工具链、pip 缓存、apt 缓存、journal 日志、Snap 缓存、`/tmp`，最后列出大文件和目录用量。

### 会做什么

```bash
# 1. Cargo 缓存
cargo cache -a

# 2. Rust 旧工具链
rustup cleanup -y

# 3. pip 缓存
rm -rf ~/.cache/pip

# 4. apt 缓存与无用包
sudo apt clean
sudo apt autoremove -y

# 5. journal 日志（保留 3 天）
sudo journalctl --vacuum-time=3d

# 6. Snap 缓存
sudo du -hx /var/lib/snapd/snaps

# 7. /tmp
sudo rm -rf /tmp/*

# 8. 列出 >500MB 文件
sudo find / -xdev -type f -size +500M

# 9. 列出顶层目录用量
sudo du -hx --max-depth=1 /
```

### 风险

| 操作 | 风险 |
|---|---|
| `rm -rf /tmp/*` | 删除所有临时文件，运行中的程序可能出错 |
| `apt autoremove -y` | 删除「不再需要」的包，可能误删 |
| `rustup cleanup -y` | 删除旧工具链，无法回退 |
| `journalctl --vacuum-time=3d` | 删除 3 天前的日志，事后无法追查 |

**脚本不做任何确认**，直接执行。运行前读一遍，确认当前环境。

### 使用建议

```bash
# 先看会做什么
less ~/dotfiles/tools/clear.sh

# 在容器或测试机上先跑
# 生产环境慎用，尤其 rm -rf /tmp/*
```

### 适用场景

它是为 WSL 设计的：WSL 的虚拟磁盘会随使用膨胀，需要定期清理。在普通 Linux 服务器上，`/tmp` 可能有正在运行的服务文件，不要盲目执行。

## tools/winetricks.sh

### 用途

智能运行 winetricks：

- Silverblue/Kinoite（不可变系统）通过 Toolbox 容器转发
- 其它系统检查并安装 winetricks，然后执行传入命令

### 用法

```bash
bash tools/winetricks.sh corefonts
bash tools/winetricks.sh --help
```

### 逻辑

```bash
main() {
    if is_silverblue_kinoite; then
        toolbox run --container wine winetricks "$@"
        exit 0
    fi

    if ! command -v winetricks &> /dev/null; then
        install_winetricks
    fi

    if [ $# -eq 0 ]; then
        echo "Provide the winetricks command to run as an argument"
        exit 1
    fi

    winetricks "$@"
}
```

### 发行版检测

```bash
is_silverblue_kinoite() {
    grep -q "silverblue\|kinoite" /etc/os-release
}
```

Fedora 的不可变变体不能直接装包，所以通过 Toolbox 容器运行。

### 安装分支

| 系统 | 命令 |
|---|---|
| apt | `sudo apt install -y winetricks` |
| dnf | `sudo dnf install -y winetricks` |
| pacman | `sudo pacman -S --noconfirm winetricks` |
| 其它 | 报错，要求手动安装 |

### 注意

`install_winetricks` 会执行 `sudo apt update` 等操作，属于系统级变更。在没有 WINE 需求的机器上不要运行。

## 这两个脚本的定位

它们不在 `init.sh` 的默认流程里，是**按需手动运行**的工具脚本。设计上假设使用者知道自己在做什么。

与其它脚本的对比：

| 脚本 | 是否自动运行 | 是否破坏性 |
|---|---|---|
| `install_font.sh` | 是（init.sh） | 否 |
| `install_nvim.sh` | 是（init.sh） | 否 |
| `clear.sh` | 否 | 是 |
| `winetricks.sh` | 否 | 可能（装包） |

## 排错

**clear.sh 删掉了正在用的文件**：`/tmp` 被清空导致程序出错。重启相关服务。

**`cargo cache` 不存在**：没装 `cargo-cache`。脚本用 `command -v cargo` 判断，但 `cargo cache` 是子命令，需要单独安装 `cargo-cache`。

**`rustup cleanup` 失败**：脚本用 `|| echo` 兜底，不中断。

**winetricks 在 Silverblue 上找不到容器**：需要先创建名为 `wine` 的 Toolbox 容器。

**`Provide the winetricks command`**：没传参数。至少要给一个子命令，比如 `corefonts`。

<!-- lang:en -->

> Summary: clear.sh is a WSL cleanup script that performs destructive operations; winetricks.sh forwards calls on special distributions.

# Cleanup and System Scripts

## tools/clear.sh

### Purpose

Full-system WSL cleanup: Cargo cache, old Rust toolchains, pip cache, apt cache, journal logs, Snap cache, `/tmp`, and finally a listing of large files and top-level directory usage.

### What It Does

```bash
# 1. Cargo 缓存
cargo cache -a

# 2. Rust 旧工具链
rustup cleanup -y

# 3. pip 缓存
rm -rf ~/.cache/pip

# 4. apt 缓存与无用包
sudo apt clean
sudo apt autoremove -y

# 5. journal 日志（保留 3 天）
sudo journalctl --vacuum-time=3d

# 6. Snap 缓存
sudo du -hx /var/lib/snapd/snaps

# 7. /tmp
sudo rm -rf /tmp/*

# 8. 列出 >500MB 文件
sudo find / -xdev -type f -size +500M

# 9. 列出顶层目录用量
sudo du -hx --max-depth=1 /
```

### Risks

| Operation | Risk |
|---|---|
| `rm -rf /tmp/*` | Deletes all temp files; running programs may break |
| `apt autoremove -y` | Deletes "no longer needed" packages; may remove something you wanted |
| `rustup cleanup -y` | Deletes old toolchains; cannot be undone |
| `journalctl --vacuum-time=3d` | Deletes logs older than 3 days; cannot be traced afterwards |

**The script asks for no confirmation** and runs straight through. Read it once before running and confirm it fits your environment.

### Usage Advice

```bash
# 先看会做什么
less ~/dotfiles/tools/clear.sh

# 在容器或测试机上先跑
# 生产环境慎用，尤其 rm -rf /tmp/*
```

### When to Use It

It was designed for WSL: WSL's virtual disk grows with use and needs periodic cleanup. On an ordinary Linux server, `/tmp` may hold files belonging to running services, so don't run it blindly there.

## tools/winetricks.sh

### Purpose

Runs winetricks intelligently:

- On Silverblue/Kinoite (immutable systems) it forwards through a Toolbox container
- On other systems it checks for and installs winetricks, then runs the given command

### Usage

```bash
bash tools/winetricks.sh corefonts
bash tools/winetricks.sh --help
```

### Logic

```bash
main() {
    if is_silverblue_kinoite; then
        toolbox run --container wine winetricks "$@"
        exit 0
    fi

    if ! command -v winetricks &> /dev/null; then
        install_winetricks
    fi

    if [ $# -eq 0 ]; then
        echo "Provide the winetricks command to run as an argument"
        exit 1
    fi

    winetricks "$@"
}
```

### Distribution Detection

```bash
is_silverblue_kinoite() {
    grep -q "silverblue\|kinoite" /etc/os-release
}
```

Fedora's immutable variants can't install packages directly, so it runs through a Toolbox container instead.

### Install Branches

| System | Command |
|---|---|
| apt | `sudo apt install -y winetricks` |
| dnf | `sudo dnf install -y winetricks` |
| pacman | `sudo pacman -S --noconfirm winetricks` |
| Others | Error out; manual install required |

### Caution

`install_winetricks` runs `sudo apt update` and similar operations — that's a system-level change. Don't run it on machines that have no WINE needs.

## Where These Two Scripts Fit

They are not part of `init.sh`'s default flow; they are utility scripts meant to be **run manually when needed**. The design assumes the user knows what they're doing.

Comparison with other scripts:

| Script | Runs automatically | Destructive |
|---|---|---|
| `install_font.sh` | Yes (init.sh) | No |
| `install_nvim.sh` | Yes (init.sh) | No |
| `clear.sh` | No | Yes |
| `winetricks.sh` | No | Possibly (package installs) |

## Troubleshooting

**clear.sh deleted files that were in use**: `/tmp` was emptied and a program broke. Restart the affected services.

**`cargo cache` doesn't exist**: `cargo-cache` isn't installed. The script checks with `command -v cargo`, but `cargo cache` is a subcommand and `cargo-cache` must be installed separately.

**`rustup cleanup` fails**: the script falls back with `|| echo` and keeps going.

**winetricks can't find the container on Silverblue**: you need to create a Toolbox container named `wine` first.

**`Provide the winetricks command`**: no argument was passed. At least one subcommand is required, e.g. `corefonts`.

<!-- lang:ja -->

> 要約：clear.sh は破壊的な操作を行う WSL クリーンアップスクリプト、winetricks.sh は特殊なディストリで呼び出しを中継します。

# クリーンアップとシステムスクリプト

## tools/clear.sh

### 役割

WSL のシステム全体クリーンアップ：Cargo キャッシュ、Rust の古いツールチェーン、pip キャッシュ、apt キャッシュ、journal ログ、Snap キャッシュ、`/tmp` を片付け、最後に大きなファイルとトップレベルディレクトリの使用量を一覧表示します。

### 行うこと

```bash
# 1. Cargo 缓存
cargo cache -a

# 2. Rust 旧工具链
rustup cleanup -y

# 3. pip 缓存
rm -rf ~/.cache/pip

# 4. apt 缓存与无用包
sudo apt clean
sudo apt autoremove -y

# 5. journal 日志（保留 3 天）
sudo journalctl --vacuum-time=3d

# 6. Snap 缓存
sudo du -hx /var/lib/snapd/snaps

# 7. /tmp
sudo rm -rf /tmp/*

# 8. 列出 >500MB 文件
sudo find / -xdev -type f -size +500M

# 9. 列出顶层目录用量
sudo du -hx --max-depth=1 /
```

### リスク

| 操作 | リスク |
|---|---|
| `rm -rf /tmp/*` | 一時ファイルをすべて削除。実行中のプログラムが壊れることがある |
| `apt autoremove -y` | 「不要になった」パッケージを削除。必要なものを誤って消す可能性がある |
| `rustup cleanup -y` | 古いツールチェーンを削除。元に戻せない |
| `journalctl --vacuum-time=3d` | 3 日前より古いログを削除。後から追跡できなくなる |

**スクリプトは何も確認せず**、そのまま実行します。実行前に一度読み、今の環境に合うか確かめてください。

### 使い方のアドバイス

```bash
# 先看会做什么
less ~/dotfiles/tools/clear.sh

# 在容器或测试机上先跑
# 生产环境慎用，尤其 rm -rf /tmp/*
```

### 向いている場面

WSL 向けに設計されています：WSL の仮想ディスクは使うほど膨らむので、定期的な掃除が必要です。普通の Linux サーバーでは `/tmp` に動作中のサービスのファイルがあることがあるので、安易に実行しないでください。

## tools/winetricks.sh

### 役割

winetricks を賢く実行します：

- Silverblue/Kinoite（イミュータブルなシステム）では Toolbox コンテナ経由で中継
- その他のシステムでは winetricks を確認・インストールしてから、渡されたコマンドを実行

### 使い方

```bash
bash tools/winetricks.sh corefonts
bash tools/winetricks.sh --help
```

### ロジック

```bash
main() {
    if is_silverblue_kinoite; then
        toolbox run --container wine winetricks "$@"
        exit 0
    fi

    if ! command -v winetricks &> /dev/null; then
        install_winetricks
    fi

    if [ $# -eq 0 ]; then
        echo "Provide the winetricks command to run as an argument"
        exit 1
    fi

    winetricks "$@"
}
```

### ディストリの検出

```bash
is_silverblue_kinoite() {
    grep -q "silverblue\|kinoite" /etc/os-release
}
```

Fedora のイミュータブルな派生ではパッケージを直接インストールできないため、Toolbox コンテナ経由で実行します。

### インストール分岐

| システム | コマンド |
|---|---|
| apt | `sudo apt install -y winetricks` |
| dnf | `sudo dnf install -y winetricks` |
| pacman | `sudo pacman -S --noconfirm winetricks` |
| その他 | エラーにして手動インストールを求める |

### 注意

`install_winetricks` は `sudo apt update` などを実行するので、システムレベルの変更にあたります。WINE が必要ないマシンでは実行しないでください。

## この 2 つのスクリプトの位置づけ

`init.sh` のデフォルトの流れには含まれず、**必要に応じて手動で実行する**ユーティリティスクリプトです。設計上、使う人は自分が何をしているか分かっている前提です。

他のスクリプトとの比較：

| スクリプト | 自動実行されるか | 破壊的か |
|---|---|---|
| `install_font.sh` | はい（init.sh） | いいえ |
| `install_nvim.sh` | はい（init.sh） | いいえ |
| `clear.sh` | いいえ | はい |
| `winetricks.sh` | いいえ | 場合による（パッケージ導入） |

## トラブルシューティング

**clear.sh が使用中のファイルを消した**：`/tmp` が空になったせいでプログラムが壊れた状態です。関係するサービスを再起動します。

**`cargo cache` が存在しない**：`cargo-cache` が未インストールです。スクリプトは `command -v cargo` で判定しますが、`cargo cache` はサブコマンドなので `cargo-cache` を別途インストールする必要があります。

**`rustup cleanup` が失敗する**：スクリプトは `|| echo` でフォールバックするので中断しません。

**winetricks が Silverblue でコンテナを見つけられない**：先に `wine` という名前の Toolbox コンテナを作っておく必要があります。

**`Provide the winetricks command`**：引数が渡されていません。`corefonts` のようなサブコマンドを最低 1 つ渡してください。
