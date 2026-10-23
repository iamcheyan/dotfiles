> 摘要：zellij 是另一套终端复用器，用 KDL 配置、有内置插件和更友好的默认键位。

# zellij

## 用途

Zellij 是 tmux 的现代替代：Rust 实现、默认键位更直观（屏幕底部实时显示可用快捷键）、内置插件系统（WASM）、布局用 KDL 声明。

本仓库同时提供 zellij 和 tmux，可以按项目选择。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit 提供命令；`scripts/install/install_zellij.sh` 可单独安装 |
| 配置 | 本仓库**没有**提供 zellij 配置文件 |

```zsh
zi_cmd zellij-org/zellij zellij
```

独立安装器：

```bash
bash scripts/install/install_zellij.sh
bash scripts/install/install_zellij.sh --method binary
bash scripts/install/install_zellij.sh --method cargo --force
```

## 基本用法

```bash
zellij                    # 新建会话
zellij -s work            # 命名会话
zellij ls                 # 列出会话
zellij attach work        # 连接
zellij kill-session work
zellij kill-all-sessions
```

## 参数

| 参数 | 作用 |
|---|---|
| `-s` / `--session` | 会话名 |
| `-l` / `--layout` | 使用布局文件或内置布局名 |
| `--layout-string` | 直接传 KDL 布局字符串 |
| `-c` / `--config` | 指定配置文件 |
| `--config-dir` | 指定配置目录 |
| `--data-dir` | 插件目录 |
| `--max-panes` | pane 数量上限 |
| `-d` / `--debug` | 调试输出 |

环境变量 `ZELLIJ_CONFIG_FILE`、`ZELLIJ_CONFIG_DIR` 可替代参数。

## 默认键位

Zellij 的核心设计是**不用记 prefix**：底部一直显示当前可用的快捷键。

| 键 | 作用 |
|---|---|
| `Ctrl+p` | pane 模式 |
| `Ctrl+t` | tab 模式 |
| `Ctrl+n` | resize 模式 |
| `Ctrl+s` | 搜索 |
| `Ctrl+o` | session 模式 |
| `Ctrl+h` | 移动模式 |
| `Ctrl+g` | 锁定模式 |
| `Esc` | 退出当前模式 |

进入某个模式后，底部栏会变成该模式的按键提示。这比 tmux 的「prefix + 键」更容易上手。

## 布局

KDL 格式：

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }
    pane split_direction="vertical" {
        pane
        pane
    }
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

保存为 `~/.config/zellij/layouts/dev.kdl`，然后：

```bash
zellij --layout dev
```

## 内置插件

| 插件 | 作用 |
|---|---|
| `tab-bar` | 顶部标签栏 |
| `status-bar` | 底部状态栏与快捷键提示 |
| `strider` | 文件浏览器 |
| `compact-bar` | 紧凑状态栏 |

插件是 WASM，加载在 pane 里。

## 与 tmux 的对比

| | tmux | zellij |
|---|---|---|
| 语言 | C | Rust |
| 配置格式 | tmux.conf | KDL |
| 快捷键 | prefix + 键 | 模式化，底部提示 |
| 插件 | 外部脚本 | 内置 WASM |
| 生态成熟度 | 高 | 中 |
| 会话恢复 | tmux-persist | 内置 session 管理 |
| 多人协作 | 支持 | 支持 |

tmux 更成熟、生态更大；zellij 上手更快、界面更现代。

## 为什么本仓库两者都留

- tmux 是长期稳定的选择，几乎所有服务器都有。
- zellij 适合本地开发，交互更舒服。
- 两者命令名不同，可以共存。

## 排错

**`zellij: command not found`**：Zinit 未下载，或安装器失败。检查 `zinit list | grep zellij`。

**会话无法恢复**：zellij 的 session 存在 `~/.cache/zellij/`，缓存被清理后无法恢复。

**按键冲突**：某些终端会把 `Ctrl+p` 等键吃掉。检查终端自身的键位设置。

**布局不生效**：KDL 语法错误时会回退默认布局。`zellij --layout <file>` 会报错提示。

**cargo 安装很慢**：编译 Rust 项目耗时长。用 `--method binary` 下载预编译版本。

**和 tmux 嵌套**：在 tmux 里跑 zellij 会出现双层状态栏和按键冲突，通常不推荐。需要时用 `Ctrl+B` 后按 `:` 发送按键给内层。

<!-- lang:en -->
> Summary: zellij is another terminal multiplexer, with KDL configuration, built-in plugins, and friendlier default key bindings.

# zellij

## Purpose

Zellij is a modern alternative to tmux: it is implemented in Rust, has more intuitive default keys (available shortcuts are shown live at the bottom of the screen), includes a plugin system (WASM), and uses KDL to declare layouts.

This repository provides both zellij and tmux, so you can choose per project.

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit provides the command; `scripts/install/install_zellij.sh` can install it separately |
| Configuration | This repository does **not** provide a zellij configuration file |

Standalone installer:

## Basic usage

## Options

| Option | Effect |
|---|---|
| `-s` / `--session` | Session name |
| `-l` / `--layout` | Use a layout file or built-in layout name |
| `--layout-string` | Pass a KDL layout string directly |
| `-c` / `--config` | Specify a configuration file |
| `--config-dir` | Specify a configuration directory |
| `--data-dir` | Plugin directory |
| `--max-panes` | Maximum number of panes |
| `-d` / `--debug` | Debug output |

The `ZELLIJ_CONFIG_FILE` and `ZELLIJ_CONFIG_DIR` environment variables can be used instead of options.

## Default key bindings

Zellij's core idea is **no prefix to remember**: currently available shortcuts are always shown at the bottom.

| Key | Effect |
|---|---|
| `Ctrl+p` | Pane mode |
| `Ctrl+t` | Tab mode |
| `Ctrl+n` | Resize mode |
| `Ctrl+s` | Search |
| `Ctrl+o` | Session mode |
| `Ctrl+h` | Move mode |
| `Ctrl+g` | Lock mode |
| `Esc` | Exit the current mode |

After entering a mode, the bottom bar changes to show its key hints. This is easier to learn than tmux's “prefix + key” approach.

## Layouts

KDL format:

Save this as `~/.config/zellij/layouts/dev.kdl`, then run:

## Built-in plugins

| Plugin | Effect |
|---|---|
| `tab-bar` | Top tab bar |
| `status-bar` | Bottom status bar and shortcut hints |
| `strider` | File browser |
| `compact-bar` | Compact status bar |

Plugins are WASM and load inside a pane.

## Comparison with tmux

| | tmux | zellij |
|---|---|---|
| Language | C | Rust |
| Configuration format | tmux.conf | KDL |
| Shortcuts | prefix + key | Modes, with hints at the bottom |
| Plugins | External scripts | Built-in WASM |
| Ecosystem maturity | High | Medium |
| Session restoration | tmux-persist | Built-in session management |
| Collaboration | Supported | Supported |

 tmux is more mature and has a larger ecosystem; zellij is quicker to learn and has a more modern interface.

## Why this repository keeps both

- tmux is a stable long-term choice and is available on nearly every server.
- zellij is suitable for local development and has a more comfortable interaction model.
- Their command names differ, so they can coexist.

## Troubleshooting

**`zellij: command not found`**: Zinit has not downloaded it, or the installer failed. Check with `zinit list | grep zellij`.

**Cannot restore a session**: zellij sessions are stored in `~/.cache/zellij/`; they cannot be restored after the cache is cleaned.

**Key conflicts**: Some terminals intercept keys such as `Ctrl+p`. Check the terminal's own key bindings.

**Layout does not take effect**: A KDL syntax error causes a fallback to the default layout. `zellij --layout <file>` reports an error.

**Cargo installation is slow**: Compiling a Rust project takes time. Use `--method binary` to download a prebuilt version.

**Nesting inside tmux**: Running zellij inside tmux creates two status bars and key conflicts, so it is generally not recommended. If needed, press `Ctrl+B` and then `:` to send keys to the inner session.

```zsh
zi_cmd zellij-org/zellij zellij
```

```bash
bash scripts/install/install_zellij.sh
bash scripts/install/install_zellij.sh --method binary
bash scripts/install/install_zellij.sh --method cargo --force
```

```bash
zellij                    # 新建会话
zellij -s work            # 命名会话
zellij ls                 # 列出会话
zellij attach work        # 连接
zellij kill-session work
zellij kill-all-sessions
```

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }
    pane split_direction="vertical" {
        pane
        pane
    }
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

```bash
zellij --layout dev
```

<!-- lang:ja -->
> 要約：zellij は別のターミナルマルチプレクサです。KDL 設定、組み込みプラグイン、分かりやすい既定キーを備えています。

# zellij

## 用途

Zellij は tmux の現代的な代替です。Rust で実装され、既定のキーがより直感的で（使えるショートカットが画面下部に常時表示されます）、プラグインシステム（WASM）を内蔵し、KDL でレイアウトを宣言します。

このリポジトリでは zellij と tmux の両方を提供しており、プロジェクトごとに選べます。

## 入手元とインストール

| 項目 | 説明 |
|---|---|
| 入手元 | Zinit がコマンドを提供します。`scripts/install/install_zellij.sh` で個別にインストールできます |
| 設定 | このリポジトリには zellij の設定ファイルは**ありません** |

個別インストーラー：

## 基本的な使い方

## オプション

| オプション | 効果 |
|---|---|
| `-s` / `--session` | セッション名 |
| `-l` / `--layout` | レイアウトファイルまたは組み込みレイアウト名を使います |
| `--layout-string` | KDL レイアウト文字列を直接渡します |
| `-c` / `--config` | 設定ファイルを指定します |
| `--config-dir` | 設定ディレクトリを指定します |
| `--data-dir` | プラグインディレクトリです |
| `--max-panes` | pane 数の上限です |
| `-d` / `--debug` | デバッグ出力を有効にします |

環境変数 `ZELLIJ_CONFIG_FILE`、`ZELLIJ_CONFIG_DIR` でオプションを代用できます。

## 既定のキー割り当て

Zellij の基本設計は**prefix を覚えなくてよいこと**です。現在使えるショートカットが常に画面下部に表示されます。

| キー | 効果 |
|---|---|
| `Ctrl+p` | pane モード |
| `Ctrl+t` | tab モード |
| `Ctrl+n` | サイズ変更モード |
| `Ctrl+s` | 検索 |
| `Ctrl+o` | session モード |
| `Ctrl+h` | 移動モード |
| `Ctrl+g` | ロックモード |
| `Esc` | 現在のモードを終了します |

モードに入ると、下部バーがそのモードのキー案内に変わります。tmux の「prefix + キー」方式より覚えやすいです。

## レイアウト

KDL 形式です。

`~/.config/zellij/layouts/dev.kdl` として保存し、次のように実行します。

## 組み込みプラグイン

| プラグイン | 効果 |
|---|---|
| `tab-bar` | 上部の tab バー |
| `status-bar` | 下部のステータスバーとショートカット案内 |
| `strider` | ファイルブラウザー |
| `compact-bar` | コンパクトなステータスバー |

プラグインは WASM で、pane 内に読み込まれます。

## tmux との比較

| | tmux | zellij |
|---|---|---|
| 言語 | C | Rust |
| 設定形式 | tmux.conf | KDL |
| ショートカット | prefix + キー | モード式で、画面下部に案内を表示します |
| プラグイン | 外部スクリプト | 組み込み WASM |
| エコシステムの成熟度 | 高い | 中程度 |
| セッション復元 | tmux-persist | 組み込みの session 管理 |
| 複数人での利用 | 対応しています | 対応しています |

tmux はより成熟し、エコシステムも大きいです。zellij は習得が速く、画面がより現代的です。

## このリポジトリで両方を使える理由

- tmux は長期利用に適した安定した選択肢で、ほぼすべてのサーバーにあります。
- zellij はローカル開発に向き、操作が快適です。
- コマンド名が異なるため、共存できます。

## トラブルシューティング

**`zellij: command not found`**：Zinit がまだダウンロードしていないか、インストーラーが失敗しました。`zinit list | grep zellij` で確認します。

**セッションを復元できません**：zellij のセッションは `~/.cache/zellij/` にあります。キャッシュを削除すると復元できません。

**キーが競合します**：端末によっては `Ctrl+p` などのキーを横取りします。端末側のキー設定を確認します。

**レイアウトが反映されません**：KDL の構文エラーがあると既定レイアウトに戻ります。`zellij --layout <file>` でエラーを確認します。

**Cargo でのインストールが遅いです**：Rust プロジェクトのコンパイルには時間がかかります。`--method binary` でビルド済みの版をダウンロードします。

**tmux の中で起動する場合**：tmux 内で zellij を実行するとステータスバーが二重になり、キーも競合するため、通常はおすすめしません。必要な場合は `Ctrl+B` の後に `:` を押して、内側のセッションへキーを送ります。

```zsh
zi_cmd zellij-org/zellij zellij
```

```bash
bash scripts/install/install_zellij.sh
bash scripts/install/install_zellij.sh --method binary
bash scripts/install/install_zellij.sh --method cargo --force
```

```bash
zellij                    # 新建会话
zellij -s work            # 命名会话
zellij ls                 # 列出会话
zellij attach work        # 连接
zellij kill-session work
zellij kill-all-sessions
```

```kdl
layout {
    pane size=1 borderless=true {
        plugin location="zellij:tab-bar"
    }
    pane split_direction="vertical" {
        pane
        pane
    }
    pane size=2 borderless=true {
        plugin location="zellij:status-bar"
    }
}
```

```bash
zellij --layout dev
```
