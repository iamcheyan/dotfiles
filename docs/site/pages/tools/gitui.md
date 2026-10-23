> 摘要：gitui 是 Rust 写的终端 Git 界面，启动快、内存占用低。

# gitui

## 用途

gitui 和 lazygit 定位相同：终端里的 Git 全功能界面。区别在实现——gitui 用 Rust，启动更快；lazygit 用 Go，功能迭代更激进。

本仓库同时提供两者，按偏好选。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，按 OS/CPU 选择 Release 包 |
| 加载位置 | `plugins/tools/tools.zsh` |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gitui_asset="gitui-mac.tar.gz"
  [[ "$(uname -m)" == "x86_64" ]] && gitui_asset="gitui-mac-x86.tar.gz"
  zinit ice as"command" from"gh-r" bpick"$gitui_asset" pick"gitui"
else
  local gitui_arch="x86_64"
  case "$(uname -m)" in
    aarch64|arm64) gitui_arch="aarch64" ;;
    armv7l) gitui_arch="armv7" ;;
    armv6l|arm) gitui_arch="arm" ;;
  esac
  zinit ice as"command" from"gh-r" bpick"gitui-linux-${gitui_arch}.tar.gz" pick"gitui"
fi
zinit light gitui-org/gitui
```

`bpick` 按架构挑压缩包，`pick` 指定解压后的可执行文件名。

## 启动

```bash
gitui                       # 当前目录
gitui -d ~/project          # 指定 git 目录
gitui -w ~/project          # 指定工作目录
gitui -f src/main.rs        # 打开时选中某文件
```

## 参数

| 参数 | 作用 |
|---|---|
| `-d` / `--directory` | Git 目录（等同 `GIT_DIR`） |
| `-w` / `--workdir` | 工作区（等同 `GIT_WORK_TREE`） |
| `-f` / `--file` | 打开时选中指定文件 |
| `-t` / `--theme` | 主题文件名，默认 `theme.ron` |
| `-k` / `--key-bindings` | 自定义键位文件 |
| `-s` / `--key-symbols` | 自定义符号文件 |
| `-l` / `--logging` | 启用日志 |
| `--logfile` | 指定日志路径 |
| `--watcher` | 用文件系统监听而非轮询 |
| `--bugreport` | 生成问题报告 |

## 面板与按键

| 键 | 作用 |
|---|---|
| `Tab` | 切换面板 |
| `↑` / `↓` / `j` / `k` | 移动 |
| `Enter` | 打开/进入 |
| `Space` | 暂存 |
| `c` | 提交 |
| `p` | push |
| `f` | fetch |
| `b` | 分支面板 |
| `?` | 帮助 |
| `q` | 退出 |

## --watcher

```bash
gitui --watcher
```

默认用轮询检测文件变化，每次间隔固定时间。`--watcher` 改用 `notify` 库监听 inotify 事件，变化响应更快、CPU 占用更低。

代价：某些文件系统（网络挂载、某些容器）不支持 inotify，会失效。上游文档建议在这些环境里不要开。

## 自定义主题与键位

```bash
gitui -t my-theme.ron -k my-keys.ron
```

`.ron` 是 Rust 的对象表示格式。默认主题文件在配置目录，可以用 `gitui --bugreport` 查看实际加载路径。

## 与 lazygit 的对比

| | gitui | lazygit |
|---|---|---|
| 语言 | Rust | Go |
| 启动速度 | 更快 | 快 |
| 内存 | 更低 | 稍高 |
| 功能覆盖 | 核心操作 | 更全（rebase 交互、submodule 等） |
| 配置格式 | RON | YAML |
| 社区 | 较小 | 活跃 |

日常 add/commit/push 两者都够。需要复杂 rebase 时 lazygit 更顺手。

## 排错

**`gitui: command not found`**：Zinit 未下载对应架构的包。`zinit list | grep gitui` 确认。

**启动报「not a git repository」**：当前目录不在仓库内。用 `-d` 指定。

**中文乱码**：终端字体缺 CJK 字形。

**`--watcher` 无效果**：文件系统不支持 inotify。去掉该参数。

**主题不生效**：`-t` 指定的是配置目录下的文件名，不是任意路径。先 `gitui --bugreport` 看配置目录在哪。

<!-- lang:en -->

> Summary: gitui is a terminal Git UI written in Rust, with fast startup and low memory usage.

# gitui

## Purpose

gitui has the same goal as lazygit: a full-featured Git interface in the terminal. The difference is the implementation — gitui is written in Rust and starts faster; lazygit is written in Go and iterates on features more aggressively.

This repo provides both; pick by preference.

## Source and Installation

| Item | Description |
|---|---|
| Source | Zinit, choosing the Release package by OS/CPU |
| Load point | `plugins/tools/tools.zsh` |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gitui_asset="gitui-mac.tar.gz"
  [[ "$(uname -m)" == "x86_64" ]] && gitui_asset="gitui-mac-x86.tar.gz"
  zinit ice as"command" from"gh-r" bpick"$gitui_asset" pick"gitui"
else
  local gitui_arch="x86_64"
  case "$(uname -m)" in
    aarch64|arm64) gitui_arch="aarch64" ;;
    armv7l) gitui_arch="armv7" ;;
    armv6l|arm) gitui_arch="arm" ;;
  esac
  zinit ice as"command" from"gh-r" bpick"gitui-linux-${gitui_arch}.tar.gz" pick"gitui"
fi
zinit light gitui-org/gitui
```

`bpick` picks the archive by architecture, and `pick` names the executable after extraction.

## Launching

```bash
gitui                       # 当前目录
gitui -d ~/project          # 指定 git 目录
gitui -w ~/project          # 指定工作目录
gitui -f src/main.rs        # 打开时选中某文件
```

## Options

| Option | Purpose |
|---|---|
| `-d` / `--directory` | Git directory (same as `GIT_DIR`) |
| `-w` / `--workdir` | Working tree (same as `GIT_WORK_TREE`) |
| `-f` / `--file` | Select the given file on launch |
| `-t` / `--theme` | Theme file name, default `theme.ron` |
| `-k` / `--key-bindings` | Custom keybindings file |
| `-s` / `--key-symbols` | Custom symbols file |
| `-l` / `--logging` | Enable logging |
| `--logfile` | Log path |
| `--watcher` | Use filesystem watching instead of polling |
| `--bugreport` | Generate a bug report |

## Panels and keys

| Key | Action |
|---|---|
| `Tab` | Switch panels |
| `↑` / `↓` / `j` / `k` | Move |
| `Enter` | Open/enter |
| `Space` | Stage |
| `c` | Commit |
| `p` | push |
| `f` | fetch |
| `b` | Branch panel |
| `?` | Help |
| `q` | Quit |

## --watcher

```bash
gitui --watcher
```

By default changes are detected by polling at a fixed interval. `--watcher` switches to the `notify` library listening for inotify events, which responds to changes faster and uses less CPU.

The cost: some filesystems (network mounts, some containers) do not support inotify and it will not work. The upstream docs recommend not enabling it in those environments.

## Custom themes and keybindings

```bash
gitui -t my-theme.ron -k my-keys.ron
```

`.ron` is Rust's Object Notation format. The default theme files live in the config directory; use `gitui --bugreport` to see the actual loaded paths.

## Comparison with lazygit

| | gitui | lazygit |
|---|---|---|
| Language | Rust | Go |
| Startup speed | Faster | Fast |
| Memory | Lower | Slightly higher |
| Feature coverage | Core operations | Broader (interactive rebase, submodule, etc.) |
| Config format | RON | YAML |
| Community | Smaller | Active |

For daily add/commit/push, both are sufficient. For complex rebases, lazygit is more convenient.

## Troubleshooting

**`gitui: command not found`**: Zinit has not downloaded the package for your architecture. Confirm with `zinit list | grep gitui`.

**Starts with "not a git repository"**: the current directory is not inside a repository. Use `-d` to specify one.

**Garbled Chinese**: the terminal font lacks CJK glyphs.

**`--watcher` has no effect**: the filesystem does not support inotify. Remove the flag.

**Theme not applied**: `-t` takes a file name inside the config directory, not an arbitrary path. Run `gitui --bugreport` first to find the config directory.

<!-- lang:ja -->

> 要約：gitui は Rust 製のターミナル Git UI で、起動が速くメモリ使用量も少ないのが特徴です。

# gitui

## 用途

gitui は lazygit と立ち位置が同じで、ターミナル上のフル機能 Git インターフェースです。違いは実装にあります。gitui は Rust 製で起動が速く、lazygit は Go 製で機能の進化がより積極的です。

本リポジトリでは両方を提供しており、好みで選びます。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit。OS/CPU に応じて Release パッケージを選択 |
| ロード位置 | `plugins/tools/tools.zsh` |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gitui_asset="gitui-mac.tar.gz"
  [[ "$(uname -m)" == "x86_64" ]] && gitui_asset="gitui-mac-x86.tar.gz"
  zinit ice as"command" from"gh-r" bpick"$gitui_asset" pick"gitui"
else
  local gitui_arch="x86_64"
  case "$(uname -m)" in
    aarch64|arm64) gitui_arch="aarch64" ;;
    armv7l) gitui_arch="armv7" ;;
    armv6l|arm) gitui_arch="arm" ;;
  esac
  zinit ice as"command" from"gh-r" bpick"gitui-linux-${gitui_arch}.tar.gz" pick"gitui"
fi
zinit light gitui-org/gitui
```

`bpick` がアーキテクチャごとにアーカイブを選び、`pick` が展開後の実行ファイル名を指定します。

## 起動

```bash
gitui                       # 当前目录
gitui -d ~/project          # 指定 git 目录
gitui -w ~/project          # 指定工作目录
gitui -f src/main.rs        # 打开时选中某文件
```

## オプション

| オプション | 役割 |
|---|---|
| `-d` / `--directory` | Git ディレクトリ（`GIT_DIR` と同等） |
| `-w` / `--workdir` | ワークツリー（`GIT_WORK_TREE` と同等） |
| `-f` / `--file` | 起動時に指定ファイルを選択 |
| `-t` / `--theme` | テーマファイル名。デフォルトは `theme.ron` |
| `-k` / `--key-bindings` | カスタムキーバインドファイル |
| `-s` / `--key-symbols` | カスタムシンボルファイル |
| `-l` / `--logging` | ログを有効化 |
| `--logfile` | ログのパスを指定 |
| `--watcher` | ポーリングの代わりにファイルシステム監視を使う |
| `--bugreport` | バグレポートを生成 |

## パネルとキー

| キー | 動作 |
|---|---|
| `Tab` | パネル切り替え |
| `↑` / `↓` / `j` / `k` | 移動 |
| `Enter` | 開く/入る |
| `Space` | ステージング |
| `c` | コミット |
| `p` | push |
| `f` | fetch |
| `b` | ブランチパネル |
| `?` | ヘルプ |
| `q` | 終了 |

## --watcher

```bash
gitui --watcher
```

デフォルトでは固定間隔のポーリングでファイル変化を検出します。`--watcher` は `notify` ライブラリで inotify イベントを監視する方式に変わり、変化への反応が速く CPU 使用量も抑えられます。

代償：一部のファイルシステム（ネットワークマウント、一部のコンテナ）は inotify に対応しておらず、機能しません。そうした環境では有効にしないよう上流ドキュメントも推奨しています。

## テーマとキーバインドのカスタマイズ

```bash
gitui -t my-theme.ron -k my-keys.ron
```

`.ron` は Rust の Object Notation 形式です。デフォルトのテーマファイルは設定ディレクトリにあり、`gitui --bugreport` で実際に読み込まれるパスを確認できます。

## lazygit との比較

| | gitui | lazygit |
|---|---|---|
| 言語 | Rust | Go |
| 起動速度 | より速い | 速い |
| メモリ | より少ない | やや多い |
| 機能網羅 | 基本操作 | より広い（対話的 rebase、submodule など） |
| 設定形式 | RON | YAML |
| コミュニティ | 小さめ | 活発 |

日々の add/commit/push ならどちらでも十分です。複雑な rebase が必要なときは lazygit の方が扱いやすいです。

## トラブルシューティング

**`gitui: command not found`**：Zinit が対応アーキテクチャのパッケージをダウンロードしていません。`zinit list | grep gitui` で確認します。

**「not a git repository」で起動失敗**：現在のディレクトリがリポジトリ内にありません。`-d` で指定します。

**中国語の文字化け**：ターミナルフォントに CJK グリフがありません。

**`--watcher` が効かない**：ファイルシステムが inotify に対応していません。このオプションを外します。

**テーマが効かない**：`-t` に指定するのは設定ディレクトリ内のファイル名であり、任意のパスではありません。まず `gitui --bugreport` で設定ディレクトリの場所を確認します。
