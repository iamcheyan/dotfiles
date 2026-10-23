> 摘要：fnm 管理 Node 版本，本仓库用惰性加载包装器避免每次启动 shell 都付出初始化成本。

# fnm

## 用途

`fnm`（Fast Node Manager）是 Node 版本管理器，用 Rust 写成。它安装多个 Node 版本，按目录或全局切换。

本仓库对它的改造在 `scripts/setup/setup_fnm.sh`：把 `node`、`npm`、`npx`、`corepack` 包成惰性函数，第一次真正调用时才初始化。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | init.sh 的 `install_fnm` 步骤 |
| 默认目录 | `~/.fnm` |
| 包装器 | `scripts/setup/setup_fnm.sh` |

安装方式由 init.sh 决定：Linux/macOS 用官方安装脚本，NixOS 提示由系统配置管理。

## 为什么惰性加载

标准做法：

```zsh
eval "$(fnm env --use-on-cd)"
```

每次启动 shell 都执行一次子进程，约 20–50ms。本仓库把它推迟到第一次用 Node 时：

```zsh
node() { __fnm_lazy_dispatch node "$@"; }
npm()  { __fnm_lazy_dispatch npm "$@"; }
```

代价是第一次 `node` 调用稍慢，收益是每个新 shell 都省一次初始化。

## 包装器的工作流程

```text
调用 node
  └── __fnm_lazy_dispatch node
        ├── 找 fnm 二进制（__fnm_bin）
        │     ├── 找到 → __fnm_lazy_load
        │     │     ├── eval "$(fnm env --shell zsh --use-on-cd)"
        │     │     ├── fnm use default
        │     │     └── 没有 default 时选本地最新版本
        │     └── 找不到 → 删掉包装函数，调用系统 node
        └── unfunction node npm npx corepack; hash -r
        └── command node "$@"
```

`unfunction` + `hash -r` 是关键：执行一次后就把包装器拆掉，后续调用直接走真实二进制，不再有函数调用开销。

## 基本用法

```bash
fnm list                       # 已安装版本
fnm list-remote --lts          # 可安装的 LTS 列表
fnm install --lts              # 装最新 LTS
fnm install 20.11.0            # 装指定版本
fnm use 20                     # 当前 shell 切到 20.x
fnm default 20                 # 设为全局默认
fnm current                    # 当前版本
fnm uninstall 18               # 卸载
fnm env                        # 打印环境变量设置
```

## --use-on-cd

包装器里用了 `fnm env --shell zsh --use-on-cd`，它注册了 `chpwd` hook：进入含 `.nvmrc` 或 `.node-version` 的目录时自动切换版本。

```bash
cd ~/projects/legacy-app    # .nvmrc 写着 16
node --version              # v16.x.x
cd ~/projects/new-app       # .nvmrc 写着 20
node --version              # v20.x.x
```

## 版本文件优先级

| 文件 | 说明 |
|---|---|
| `.node-version` | fnm 原生格式 |
| `.nvmrc` | 兼容 nvm |

内容可以是 `20`、`20.11`、`20.11.0`、`lts/*`、`latest`。

## 与 direnv 的关系

两者都能在 `cd` 时改变环境：

| | fnm | direnv |
|---|---|---|
| 触发 | `.nvmrc` / `.node-version` | `.envrc`（需 allow） |
| 范围 | 只改 Node | 任意变量 |
| 安全 | 无需授权 | 需显式 allow |

同时使用时，direnv 可以调用 `use node` 让 fnm 接管版本切换，避免两套 hook 争抢。

## 环境变量

| 变量 | 作用 |
|---|---|
| `FNM_DIR` | fnm 安装目录，默认 `~/.fnm` |
| `__FNM_LAZY_LOADED` | 内部标志，标记是否已初始化 |

## 排错

**`node: command not found`**：fnm 没装，且系统也没 Node。跑 `bash init.sh` 或手动装 fnm。

**`Error: fnm not found. Run init.sh`**：包装器找不到 fnm 二进制。`ls ~/.fnm ~/.fnm/bin` 检查目录。

**版本切换不生效**：`.nvmrc` 内容不被识别。用 `fnm use` 手动测试，确认版本已安装。

**`npm install -g` 装的命令找不到**：npm 全局 bin 目录没进 PATH。`npm prefix -g` 看路径，确认它在 PATH 里。

**每次 cd 都卡顿**：`--use-on-cd` 在有大 `.nvmrc` 树的目录里会频繁切换。可以关掉它，改为手动 `fnm use`。

**NixOS 上包装器报错**：系统用声明式配置提供 Node，没有 fnm。包装器的 fallback 会删掉函数并调用系统 `node`，应该能正常工作；若报错，检查 `__fnm_bin` 的探测路径。

<!-- lang:en -->

> Summary: fnm manages Node versions; this repo wraps it with lazy-load wrappers to avoid paying the initialization cost on every shell startup.

# fnm

## Purpose

`fnm` (Fast Node Manager) is a Node version manager written in Rust. It installs multiple Node versions and switches between them per directory or globally.

This repo's customization lives in `scripts/setup/setup_fnm.sh`: it wraps `node`, `npm`, `npx`, and `corepack` into lazy functions that only initialize on the first real call.

## Source and Installation

| Item | Description |
|---|---|
| Source | The `install_fnm` step of init.sh |
| Default directory | `~/.fnm` |
| Wrapper | `scripts/setup/setup_fnm.sh` |

The installation method is decided by init.sh: Linux/macOS use the official install script; on NixOS you are told it is managed by the system configuration.

## Why lazy loading

The standard approach:

```zsh
eval "$(fnm env --use-on-cd)"
```

...spawns a subprocess on every shell startup, about 20–50ms. This repo defers it until the first time Node is used:

```zsh
node() { __fnm_lazy_dispatch node "$@"; }
npm()  { __fnm_lazy_dispatch npm "$@"; }
```

The cost is a slightly slower first `node` call; the benefit is saving one initialization per new shell.

## How the wrapper works

```text
调用 node
  └── __fnm_lazy_dispatch node
        ├── 找 fnm 二进制（__fnm_bin）
        │     ├── 找到 → __fnm_lazy_load
        │     │     ├── eval "$(fnm env --shell zsh --use-on-cd)"
        │     │     ├── fnm use default
        │     │     └── 没有 default 时选本地最新版本
        │     └── 找不到 → 删掉包装函数，调用系统 node
        └── unfunction node npm npx corepack; hash -r
        └── command node "$@"
```

`unfunction` + `hash -r` is the key: after running once, the wrapper removes itself so later calls go straight to the real binary with no function-call overhead.

## Basic usage

```bash
fnm list                       # 已安装版本
fnm list-remote --lts          # 可安装的 LTS 列表
fnm install --lts              # 装最新 LTS
fnm install 20.11.0            # 装指定版本
fnm use 20                     # 当前 shell 切到 20.x
fnm default 20                 # 设为全局默认
fnm current                    # 当前版本
fnm uninstall 18               # 卸载
fnm env                        # 打印环境变量设置
```

## --use-on-cd

The wrapper uses `fnm env --shell zsh --use-on-cd`, which registers a `chpwd` hook: when you enter a directory containing `.nvmrc` or `.node-version`, the version switches automatically.

```bash
cd ~/projects/legacy-app    # .nvmrc 写着 16
node --version              # v16.x.x
cd ~/projects/new-app       # .nvmrc 写着 20
node --version              # v20.x.x
```

## Version file priority

| File | Description |
|---|---|
| `.node-version` | fnm native format |
| `.nvmrc` | nvm compatible |

The content can be `20`, `20.11`, `20.11.0`, `lts/*`, or `latest`.

## Relationship with direnv

Both can change the environment on `cd`:

| | fnm | direnv |
|---|---|---|
| Trigger | `.nvmrc` / `.node-version` | `.envrc` (requires allow) |
| Scope | Node only | Any variable |
| Safety | No authorization needed | Explicit allow required |

When used together, direnv can call `use node` to let fnm take over version switching, avoiding the two hooks fighting each other.

## Environment variables

| Variable | Purpose |
|---|---|
| `FNM_DIR` | fnm installation directory, default `~/.fnm` |
| `__FNM_LAZY_LOADED` | Internal flag marking whether initialization has happened |

## Troubleshooting

**`node: command not found`**: fnm is not installed and the system has no Node either. Run `bash init.sh` or install fnm manually.

**`Error: fnm not found. Run init.sh`**: the wrapper cannot find the fnm binary. Use `ls ~/.fnm ~/.fnm/bin` to check the directory.

**Version switching has no effect**: the `.nvmrc` content is not recognized. Test manually with `fnm use` and confirm the version is installed.

**Commands installed with `npm install -g` are not found**: npm's global bin directory is not in PATH. Check the path with `npm prefix -g` and confirm it is in PATH.

**Lag on every cd**: `--use-on-cd` switches frequently in directories with large `.nvmrc` trees. You can disable it and switch manually with `fnm use` instead.

**Wrapper errors on NixOS**: the system provides Node via declarative configuration, without fnm. The wrapper's fallback removes the functions and calls the system `node`, which should work fine; if it errors, check the probe paths in `__fnm_bin`.

<!-- lang:ja -->

> 要約：fnm は Node のバージョン管理ツールで、本リポジトリは遅延ロードラッパーを使ってシェル起動ごとの初期化コストを回避しています。

# fnm

## 用途

`fnm`（Fast Node Manager）は Rust 製の Node バージョンマネージャーです。複数の Node バージョンをインストールし、ディレクトリ単位またはグローバルに切り替えられます。

本リポジトリでのカスタマイズは `scripts/setup/setup_fnm.sh` にあります。`node`、`npm`、`npx`、`corepack` を遅延関数にラップし、初めて実際に呼ばれたときに初期化します。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | init.sh の `install_fnm` ステップ |
| デフォルトディレクトリ | `~/.fnm` |
| ラッパー | `scripts/setup/setup_fnm.sh` |

インストール方法は init.sh が決定します。Linux/macOS は公式インストールスクリプトを使い、NixOS ではシステム設定で管理する旨が表示されます。

## なぜ遅延ロードなのか

標準的な方法：

```zsh
eval "$(fnm env --use-on-cd)"
```

シェルを起動するたびにサブプロセスが一度実行され、約 20〜50ms かかります。本リポジトリではこれを Node を初めて使うときまで遅延させます：

```zsh
node() { __fnm_lazy_dispatch node "$@"; }
npm()  { __fnm_lazy_dispatch npm "$@"; }
```

最初の `node` 呼び出しが少し遅くなる代わりに、新しいシェルごとに初期化を一回省けます。

## ラッパーの動作フロー

```text
调用 node
  └── __fnm_lazy_dispatch node
        ├── 找 fnm 二进制（__fnm_bin）
        │     ├── 找到 → __fnm_lazy_load
        │     │     ├── eval "$(fnm env --shell zsh --use-on-cd)"
        │     │     ├── fnm use default
        │     │     └── 没有 default 时选本地最新版本
        │     └── 找不到 → 删掉包装函数，调用系统 node
        └── unfunction node npm npx corepack; hash -r
        └── command node "$@"
```

`unfunction` と `hash -r` が鍵です。一度実行されるとラッパーは自身を削除するため、以降の呼び出しは関数呼び出しのオーバーヘッドなしに実バイナリへ直接渡ります。

## 基本的な使い方

```bash
fnm list                       # 已安装版本
fnm list-remote --lts          # 可安装的 LTS 列表
fnm install --lts              # 装最新 LTS
fnm install 20.11.0            # 装指定版本
fnm use 20                     # 当前 shell 切到 20.x
fnm default 20                 # 设为全局默认
fnm current                    # 当前版本
fnm uninstall 18               # 卸载
fnm env                        # 打印环境变量设置
```

## --use-on-cd

ラッパーは `fnm env --shell zsh --use-on-cd` を使っており、`chpwd` フックを登録します。`.nvmrc` や `.node-version` を含むディレクトリに入ると、自動的にバージョンを切り替えます。

```bash
cd ~/projects/legacy-app    # .nvmrc 写着 16
node --version              # v16.x.x
cd ~/projects/new-app       # .nvmrc 写着 20
node --version              # v20.x.x
```

## バージョンファイルの優先順位

| ファイル | 説明 |
|---|---|
| `.node-version` | fnm のネイティブ形式 |
| `.nvmrc` | nvm 互換 |

内容は `20`、`20.11`、`20.11.0`、`lts/*`、`latest` などです。

## direnv との関係

どちらも `cd` 時に環境を変更できます：

| | fnm | direnv |
|---|---|---|
| トリガー | `.nvmrc` / `.node-version` | `.envrc`（allow が必要） |
| 範囲 | Node のみ | 任意の変数 |
| 安全性 | 認可不要 | 明示的な allow が必要 |

併用する場合は、direnv から `use node` を呼んで fnm にバージョン切り替えを任せると、二つのフックが競合しません。

## 環境変数

| 変数 | 役割 |
|---|---|
| `FNM_DIR` | fnm のインストールディレクトリ。デフォルトは `~/.fnm` |
| `__FNM_LAZY_LOADED` | 内部フラグ。初期化済みかどうかを示します |

## トラブルシューティング

**`node: command not found`**：fnm がインストールされておらず、システムにも Node がありません。`bash init.sh` を実行するか、手動で fnm をインストールしてください。

**`Error: fnm not found. Run init.sh`**：ラッパーが fnm バイナリを見つけられていません。`ls ~/.fnm ~/.fnm/bin` でディレクトリを確認してください。

**バージョン切り替えが効かない**：`.nvmrc` の内容が認識されていません。`fnm use` で手動テストし、バージョンがインストール済みか確認してください。

**`npm install -g` で入れたコマンドが見つからない**：npm のグローバル bin ディレクトリが PATH に入っていません。`npm prefix -g` でパスを確認し、PATH に含まれているか確かめてください。

**cd のたびにもたつく**：`--use-on-cd` が大きな `.nvmrc` ツリーのあるディレクトリで頻繁に切り替えています。無効化して手動の `fnm use` に切り替えられます。

**NixOS でラッパーがエラーになる**：システムは宣言的設定で Node を提供しており、fnm はありません。ラッパーのフォールバックは関数を削除してシステムの `node` を呼ぶため、通常は動作します。エラーになる場合は `__fnm_bin` の検出パスを確認してください。
