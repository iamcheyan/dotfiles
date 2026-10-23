> 摘要：tmux 的 7 个插件各自负责什么，怎么安装，读哪一篇。

# 本章导读

## 插件全景

`config/tmux/tmux.conf` 声明 7 项：1 个管理器 + 6 个功能插件。

| 插件 | 一句话 | 文档 |
|---|---|---|
| TPM | 插件管理器本体 | [TPM](tpm.html) |
| tmux-sensible | 补上公认合理的默认值 | [sensible](sensible.html) |
| tmux-persist | 手动保存 / 恢复会话 | [persist](persist.html) |
| tmux-continuum | 自动保存、自动恢复 | [continuum](continuum.html) |
| tmux-yank | 复制到系统剪贴板 | [yank](yank.html) |
| vim-tmux-navigator | `Ctrl+h/j/k/l` 跨 Neovim 与 pane | [vim-navigator](vim-navigator.html) |
| tmux-fzf | fzf 查找 session / window / pane | [tmux-fzf](tmux-fzf.html) |

## 安装路径

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

插件装在 `~/.config/tmux/plugins/`，不在默认的 `~/.tmux/plugins/`。用 `run-shell` 是为了让 shell 先展开 `$HOME`，避免 tmux 解析环境变量的差异。

## 首次安装

```bash
# 1. 确保 tmux 已启动
tmux

# 2. Prefix + I
```

`Prefix` 默认是 `Ctrl+B`。`Prefix + I`（大写 i）让 TPM 克隆所有 `@plugin` 声明的仓库。

状态栏会显示安装进度，完成后提示 `TMUX environment reloaded`。

## 本仓库的相关配置

| 配置项 | 值 | 作用 |
|---|---|---|
| `@persist-strategy-vim` | `session` | 保存时记录 vim 状态 |
| `@persist-strategy-nvim` | `session` | 保存时记录 nvim 状态 |
| `@persist-hook-post-restore-all` | 重编号命令 | 恢复后统一窗口编号 |

没有为 yank、fzf、continuum 设置额外选项，都用上游默认值。

## 更新与清理

| 键 | 作用 |
|---|---|
| `Prefix + I` | 安装 / 更新 |
| `Prefix + U` | 更新（部分版本） |
| `Prefix + Alt+u` | 卸载未在配置里声明的插件 |

具体见 [TPM](tpm.html)。

## 两个私有接入点

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

| 文件 | 时机 |
|---|---|
| `private.conf` | 插件声明之前，可覆盖前面的选项 |
| `private-after.conf` | 全部配置之后，可覆盖插件设置 |

文件不存在时静默跳过。这是公开配置不含私有内容、但允许本机追加的机制。

## 排错起点

插件没生效时按顺序查：

```bash
ls ~/.config/tmux/plugins/          # 目录有没有
tmux show -g @plugin                # 声明有没有
echo $TMUX_PLUGIN_MANAGER_PATH      # 路径对不对（在 tmux 里执行）
```

<!-- lang:en -->

> Summary: what each of tmux's 7 plugins is responsible for, how to install them, and which page to read.

# Chapter Guide

## Plugin overview

`config/tmux/tmux.conf` declares 7 entries: 1 manager + 6 feature plugins.

| Plugin | In one line | Docs |
|---|---|---|
| TPM | The plugin manager itself | [TPM](tpm.html) |
| tmux-sensible | Adds widely accepted sensible defaults | [sensible](sensible.html) |
| tmux-persist | Manually save / restore sessions | [persist](persist.html) |
| tmux-continuum | Auto-save, auto-restore | [continuum](continuum.html) |
| tmux-yank | Copy to the system clipboard | [yank](yank.html) |
| vim-tmux-navigator | `Ctrl+h/j/k/l` across Neovim and panes | [vim-navigator](vim-navigator.html) |
| tmux-fzf | fzf for finding session / window / pane | [tmux-fzf](tmux-fzf.html) |

## Installation path

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

Plugins are installed in `~/.config/tmux/plugins/`, not the default `~/.tmux/plugins/`. Using `run-shell` lets the shell expand `$HOME` first, avoiding differences in how tmux parses environment variables.

## First-time installation

```bash
# 1. 确保 tmux 已启动
tmux

# 2. Prefix + I
```

`Prefix` defaults to `Ctrl+B`. `Prefix + I` (capital i) makes TPM clone all repositories declared with `@plugin`.

The status bar shows the installation progress, and when finished it prints `TMUX environment reloaded`.

## Related configuration in this repository

| Option | Value | Effect |
|---|---|---|
| `@persist-strategy-vim` | `session` | Records vim state on save |
| `@persist-strategy-nvim` | `session` | Records nvim state on save |
| `@persist-hook-post-restore-all` | Renumber command | Unifies window numbers after restore |

No extra options are set for yank, fzf, or continuum; all use upstream defaults.

## Updating and cleaning

| Key | Effect |
|---|---|
| `Prefix + I` | Install / update |
| `Prefix + U` | Update (some versions) |
| `Prefix + Alt+u` | Uninstall plugins not declared in the config |

See [TPM](tpm.html) for details.

## Two private hooks

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

| File | Timing |
|---|---|
| `private.conf` | Before the plugin declarations; can override earlier options |
| `private-after.conf` | After the entire config; can override plugin settings |

Missing files are silently skipped. This is the mechanism that keeps the public config free of private content while allowing local additions.

## Where to start troubleshooting

When a plugin doesn't take effect, check in order:

```bash
ls ~/.config/tmux/plugins/          # 目录有没有
tmux show -g @plugin                # 声明有没有
echo $TMUX_PLUGIN_MANAGER_PATH      # 路径对不对（在 tmux 里执行）
```

<!-- lang:ja -->

> 要約：tmux の 7 つのプラグインがそれぞれ何を担い、どうインストールし、どのページを読むべきかの説明です。

# 本章のガイド

## プラグイン一覧

`config/tmux/tmux.conf` には 7 項目を宣言しています：マネージャ 1 つ + 機能プラグイン 6 つ。

| プラグイン | 一言でいうと | ドキュメント |
|---|---|---|
| TPM | プラグインマネージャ本体 | [TPM](tpm.html) |
| tmux-sensible | 広く合意された妥当なデフォルト値を補う | [sensible](sensible.html) |
| tmux-persist | セッションの手動保存 / 復元 | [persist](persist.html) |
| tmux-continuum | 自動保存・自動復元 | [continuum](continuum.html) |
| tmux-yank | システムクリップボードへのコピー | [yank](yank.html) |
| vim-tmux-navigator | `Ctrl+h/j/k/l` を Neovim と pane の間で共有 | [vim-navigator](vim-navigator.html) |
| tmux-fzf | fzf で session / window / pane を探す | [tmux-fzf](tmux-fzf.html) |

## インストール先

```tmux
run-shell 'tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.config/tmux/plugins/"'
```

プラグインは `~/.config/tmux/plugins/` にインストールされ、デフォルトの `~/.tmux/plugins/` ではありません。`run-shell` を使うのは、シェルに先に `$HOME` を展開させ、tmux が環境変数を解釈する差異を避けるためです。

## 初回インストール

```bash
# 1. 确保 tmux 已启动
tmux

# 2. Prefix + I
```

`Prefix` のデフォルトは `Ctrl+B` です。`Prefix + I`（大文字の i）で TPM が `@plugin` で宣言されたすべてのリポジトリをクローンします。

ステータスバーにインストールの進行状況が表示され、完了すると `TMUX environment reloaded` と出ます。

## 本リポジトリの関連設定

| 設定項目 | 値 | 役割 |
|---|---|---|
| `@persist-strategy-vim` | `session` | 保存時に vim の状態を記録 |
| `@persist-strategy-nvim` | `session` | 保存時に nvim の状態を記録 |
| `@persist-hook-post-restore-all` | リナンバリングコマンド | 復元後にウィンドウ番号を統一 |

yank・fzf・continuum には追加のオプションを設定しておらず、すべて上流のデフォルト値を使います。

## 更新とクリーンアップ

| キー | 役割 |
|---|---|
| `Prefix + I` | インストール / 更新 |
| `Prefix + U` | 更新（一部のバージョン） |
| `Prefix + Alt+u` | 設定に宣言されていないプラグインを削除 |

詳しくは [TPM](tpm.html) を参照してください。

## 2 つのプライベート投入点

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}

if-shell '[ -f "$HOME/.config/tmux/private-after.conf" ]' \
  'source-file "$HOME/.config/tmux/private-after.conf"'
```

| ファイル | タイミング |
|---|---|
| `private.conf` | プラグイン宣言の前。前のオプションを上書きできる |
| `private-after.conf` | すべての設定の後。プラグインの設定を上書きできる |

ファイルが存在しない場合は黙ってスキップします。公開設定にプライベートな内容を含めず、かつローカルでの追記を許すための仕組みです。

## トラブルシュートの入り口

プラグインが効かないときは、この順で確認します：

```bash
ls ~/.config/tmux/plugins/          # 目录有没有
tmux show -g @plugin                # 声明有没有
echo $TMUX_PLUGIN_MANAGER_PATH      # 路径对不对（在 tmux 里执行）
```
