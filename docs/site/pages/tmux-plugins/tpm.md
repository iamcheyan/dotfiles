> 摘要：TPM 是 tmux 的插件管理器，负责克隆、加载和更新 tmux.conf 里声明的插件。

# TPM

## 用途

tmux 没有内置插件系统。TPM（Tmux Plugin Manager）提供了：

- 读取 `tmux.conf` 里的 `@plugin` 声明
- 克隆对应仓库到插件目录
- 启动时 source 每个插件的 `.tmux` 文件
- 提供安装 / 更新 / 清理的快捷键

## 声明方式

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'

run '~/.config/tmux/plugins/tpm/tpm'
```

最后一行的 `run` 是**必需的**，且必须在所有 `@plugin` 之后。它启动 TPM 本体。

也可以写完整 URL 或本地路径：

```tmux
set -g @plugin 'https://github.com/user/plugin'
set -g @plugin '~/my/local/plugin'
```

## 安装位置

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

本仓库改成 `~/.config/tmux/plugins/`，默认是 `~/.tmux/plugins/`。

`run-shell` 而不是直接 `set-environment`，是为了让 shell 先展开 `$HOME`。tmux 自己解析变量在不同版本下行为不一致。

## 快捷键

| 键 | 作用 |
|---|---|
| `Prefix + I` | 安装新声明的插件，并更新已装的 |
| `Prefix + U` | 更新所有插件 |
| `Prefix + Alt+u` | 删除未在配置里声明的插件 |

`I` 是大写 i（install），`U` 是大写 u（update）。

状态栏会显示进度。完成后提示：

```text
TMUX environment reloaded.
Done, press ENTER to continue.
```

## 手动安装

不想用快捷键，或在没有交互的场景：

```bash
# 克隆 TPM 本体
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# 启动 tmux 后执行安装脚本
~/.config/tmux/plugins/tpm/bin/install_plugins

# 更新
~/.config/tmux/plugins/tpm/bin/update_plugins all

# 清理
~/.config/tmux/plugins/tpm/bin/clean_plugins
```

## 目录结构

```text
~/.config/tmux/plugins/
├── tpm/
├── tmux-sensible/
├── tmux-persist/
├── tmux-continuum/
├── tmux-yank/
├── vim-tmux-navigator/
└── tmux-fzf/
```

每个插件目录里有一个或多个 `*.tmux` 文件，TPM 在启动时 source 它们。

## 配置重载

改了 `tmux.conf` 后：

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

如果新增了 `@plugin`，还需要 `Prefix + I` 才会下载。

## 与 tmux 版本的关系

TPM 需要 tmux 1.9 以上。本仓库的 tmux 配置用了 `terminal-features` 等较新选项，建议 tmux 3.2+。

```bash
tmux -V
```

## 排错

**`Prefix + I` 没反应**：TPM 没加载。检查 `tmux.conf` 末尾的 `run` 行是否指向正确路径。

**插件下载失败**：网络问题。手动 `git clone` 到插件目录，再 `Prefix + I`。

**插件装了但不生效**：TPM 只 source 插件目录里的 `*.tmux` 文件。检查该文件是否存在。

**路径不对**：

```bash
# 在 tmux 里执行
tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH
```

**权限问题**：插件目录不可写。检查 `~/.config/tmux/` 的权限。

**插件之间冲突**：见各插件文档的排错部分。常见是键位重叠，比如 vim-tmux-navigator 和某个 pane 切换插件都绑 `Ctrl+h`。

<!-- lang:en -->

> Summary: TPM is tmux's plugin manager; it clones, loads, and updates the plugins declared in tmux.conf.

# TPM

## Purpose

tmux has no built-in plugin system. TPM (Tmux Plugin Manager) provides:

- Reading the `@plugin` declarations in `tmux.conf`
- Cloning the corresponding repositories into the plugin directory
- Sourcing each plugin's `.tmux` file at startup
- Keybindings for install / update / clean-up

## How plugins are declared

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'

run '~/.config/tmux/plugins/tpm/tpm'
```

The `run` on the last line is **required** and must come after all `@plugin` declarations. It starts TPM itself.

You can also write a full URL or a local path:

```tmux
set -g @plugin 'https://github.com/user/plugin'
set -g @plugin '~/my/local/plugin'
```

## Install location

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

This repository changes it to `~/.config/tmux/plugins/`; the default is `~/.tmux/plugins/`.

`run-shell` is used instead of a direct `set-environment` so that the shell expands `$HOME` first. tmux's own variable parsing behaves inconsistently across versions.

## Keybindings

| Key | Effect |
|---|---|
| `Prefix + I` | Install newly declared plugins and update installed ones |
| `Prefix + U` | Update all plugins |
| `Prefix + Alt+u` | Remove plugins not declared in the config |

`I` is a capital i (install), `U` is a capital u (update).

The status bar shows progress. When finished it prints:

```text
TMUX environment reloaded.
Done, press ENTER to continue.
```

## Manual installation

If you don't want to use the keybindings, or in non-interactive scenarios:

```bash
# 克隆 TPM 本体
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# 启动 tmux 后执行安装脚本
~/.config/tmux/plugins/tpm/bin/install_plugins

# 更新
~/.config/tmux/plugins/tpm/bin/update_plugins all

# 清理
~/.config/tmux/plugins/tpm/bin/clean_plugins
```

## Directory layout

```text
~/.config/tmux/plugins/
├── tpm/
├── tmux-sensible/
├── tmux-persist/
├── tmux-continuum/
├── tmux-yank/
├── vim-tmux-navigator/
└── tmux-fzf/
```

Each plugin directory contains one or more `*.tmux` files, which TPM sources at startup.

## Reloading the config

After changing `tmux.conf`:

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

If you added a new `@plugin`, you also need `Prefix + I` for it to be downloaded.

## Relationship with tmux versions

TPM requires tmux 1.9 or later. This repository's tmux config uses newer options like `terminal-features`, so tmux 3.2+ is recommended.

```bash
tmux -V
```

## Troubleshooting

**`Prefix + I` does nothing**: TPM is not loaded. Check that the `run` line at the end of `tmux.conf` points to the correct path.

**Plugin download fails**: a network problem. Manually `git clone` into the plugin directory, then press `Prefix + I`.

**Plugin is installed but has no effect**: TPM only sources the `*.tmux` files in the plugin directory. Check that the file exists.

**Wrong path**:

```bash
# 在 tmux 里执行
tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH
```

**Permission problems**: the plugin directory is not writable. Check the permissions of `~/.config/tmux/`.

**Conflicts between plugins**: see each plugin's docs under troubleshooting. The common case is overlapping keys, e.g. vim-tmux-navigator and some pane-switching plugin both binding `Ctrl+h`.

<!-- lang:ja -->

> 要約：TPM は tmux のプラグインマネージャで、tmux.conf に宣言されたプラグインのクローン・読み込み・更新を担います。

# TPM

## 用途

tmux にはプラグインシステムが組み込まれていません。TPM（Tmux Plugin Manager）は次を提供します：

- `tmux.conf` 内の `@plugin` 宣言を読み取る
- 対応するリポジトリをプラグインディレクトリにクローンする
- 起動時に各プラグインの `.tmux` ファイルを source する
- インストール / 更新 / クリーンアップのキーバインドを提供する

## 宣言の方法

```tmux
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'hyoretsu/tmux-persist'
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @plugin 'tmux-plugins/tmux-yank'
set -g @plugin 'christoomey/vim-tmux-navigator'
set -g @plugin 'sainnhe/tmux-fzf'

run '~/.config/tmux/plugins/tpm/tpm'
```

最終行の `run` は**必須**で、すべての `@plugin` の後に置く必要があります。ここで TPM 本体が起動します。

完全な URL やローカルパスを書くこともできます：

```tmux
set -g @plugin 'https://github.com/user/plugin'
set -g @plugin '~/my/local/plugin'
```

## インストール先

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

本リポジトリでは `~/.config/tmux/plugins/` に変更しています。デフォルトは `~/.tmux/plugins/` です。

`set-environment` を直接書かず `run-shell` を使うのは、シェルに先に `$HOME` を展開させるためです。tmux 自身の変数解析はバージョンによって挙動が一致しません。

## キーバインド

| キー | 役割 |
|---|---|
| `Prefix + I` | 新しく宣言されたプラグインをインストールし、既存のものを更新 |
| `Prefix + U` | すべてのプラグインを更新 |
| `Prefix + Alt+u` | 設定に宣言されていないプラグインを削除 |

`I` は大文字の i（install）、`U` は大文字の u（update）です。

ステータスバーに進行状況が表示されます。完了すると次のように出ます：

```text
TMUX environment reloaded.
Done, press ENTER to continue.
```

## 手動インストール

キーバインドを使いたくない場合や、対話できない場面では：

```bash
# 克隆 TPM 本体
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# 启动 tmux 后执行安装脚本
~/.config/tmux/plugins/tpm/bin/install_plugins

# 更新
~/.config/tmux/plugins/tpm/bin/update_plugins all

# 清理
~/.config/tmux/plugins/tpm/bin/clean_plugins
```

## ディレクトリ構成

```text
~/.config/tmux/plugins/
├── tpm/
├── tmux-sensible/
├── tmux-persist/
├── tmux-continuum/
├── tmux-yank/
├── vim-tmux-navigator/
└── tmux-fzf/
```

各プラグインディレクトリには 1 つ以上の `*.tmux` ファイルがあり、TPM が起動時に source します。

## 設定の再読み込み

`tmux.conf` を変更したあとは：

```bash
tmux source-file ~/.config/tmux/tmux.conf
```

`@plugin` を新しく追加した場合は、`Prefix + I` を実行しないとダウンロードされません。

## tmux バージョンとの関係

TPM には tmux 1.9 以上が必要です。本リポジトリの tmux 設定は `terminal-features` など比較的新しいオプションを使っているため、tmux 3.2 以上を推奨します。

```bash
tmux -V
```

## トラブルシュート

**`Prefix + I` が反応しない**：TPM が読み込まれていません。`tmux.conf` 末尾の `run` 行が正しいパスを指しているか確認します。

**プラグインのダウンロードに失敗する**：ネットワークの問題です。プラグインディレクトリに手動で `git clone` し、その後 `Prefix + I` を実行します。

**プラグインは入ったが効かない**：TPM が source するのはプラグインディレクトリ内の `*.tmux` ファイルだけです。そのファイルが存在するか確認します。

**パスがおかしい**：

```bash
# 在 tmux 里执行
tmux show-environment -g TMUX_PLUGIN_MANAGER_PATH
```

**権限の問題**：プラグインディレクトリに書き込めません。`~/.config/tmux/` の権限を確認します。

**プラグイン同士の競合**：各プラグイン文書のトラブルシュートを参照してください。よくあるのはキーの重複、たとえば vim-tmux-navigator と別の pane 切り替えプラグインが両方とも `Ctrl+h` にバインドしているケースです。
