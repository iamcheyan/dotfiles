> 摘要：bottom（btm）是可配置的终端系统监视器，Rust 实现，支持 TOML 配置。

# bottom (btm)

## 用途

`bottom` 和 btop 定位相同，但设计取向不同：btop 偏图形化，bottom 偏可配置和脚本友好。它用 Rust 写成，启动快、内存占用低。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| 可执行名 | `btm` |

```zsh
zi_cmd ClementTsang/bottom btm
```

注意命令名是 `btm` 而不是 `bottom`。

## 启动

```bash
btm                  # 默认布局
btm --basic          # 简化外观，接近 htop
btm --battery        # 显示电池
btm -b               # 同上 --basic
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-b` / `--basic` | 隐藏曲线，用纯文本条形 |
| `--battery` | 显示电池电量 |
| `-t` / `--default_time_value` | 曲线默认时间窗，如 `60s` |
| `-C` / `--config_location` | 指定配置文件路径 |
| `--autohide_time` | 缩放后自动隐藏时间轴 |
| `--hide_time` | 完全隐藏时间轴 |
| `--default_widget_type` | 默认聚焦的面板类型 |
| `--default_widget_count` | 聚焦第 N 个同类型面板 |
| `--rate` | 采样间隔（毫秒） |

`--basic` 在 SSH 或低带宽环境里特别有用，因为曲线刷新会产生大量终端输出。

## 界面与按键

| 键 | 作用 |
|---|---|
| `q` / `Esc` | 退出 |
| `?` | 帮助 |
| `f` | 打开过滤 |
| `/` | 搜索进程 |
| `dd` | 结束选中进程 |
| `Tab` | 切换面板 |
| `+` / `-` | 缩放时间轴 |
| `e` | 展开/折叠 |
| `Ctrl+f` | 冻结/解冻刷新 |

## 配置

```bash
btm -C ~/.config/bottom/bottom.toml
```

不给 `-C` 时用默认位置；文件不存在会自动创建。

配置是 TOML，主要段落：

```toml
[flags]
rate = 1000
dot_marker = false
enable_gpu = false

[colors]
table_header_color = "LightCyan"

[disk_filter]
is_list_ignored = true
list = ["/dev/loop"]

[processes]
columns = ["pid", "name", "cpu", "mem"]
```

`[processes].columns` 可以自定义进程表显示哪些列，这是 bottom 相对 btop 的优势——输出更紧凑，适合小窗口。

## 与 btop 的选择

| 场景 | 推荐 |
|---|---|
| 想看得舒服、有鼠标 | btop |
| SSH / 低带宽 | `btm --basic` |
| 要自定义列 | bottom |
| 要脚本化输出 | `procs` 或 `ps` |

## 排错

**`btm: command not found`**：Zinit 未下载。注意命令名是 `btm`。

**图形乱码**：字体或 `$TERM` 问题。`--basic` 可规避。

**GPU 不显示**：需要编译时启用 GPU 特性，release 包默认可能不含。配置里 `enable_gpu = true` 也要求底层支持。

**磁盘列表太长**：用 `[disk_filter]` 排除 loop 设备和网络挂载。

**配置不生效**：确认 `-C` 指向的文件存在且是有效 TOML。TOML 语法错误时 bottom 会回退默认值，不报错。

<!-- lang:en -->
> Summary: bottom (btm) is a configurable terminal system monitor written in Rust, with TOML-based configuration.

# bottom (btm)

## Purpose

`bottom` targets the same role as btop but with a different design philosophy: btop leans graphical, bottom leans configurable and script-friendly. It is written in Rust, starts quickly, and uses little memory.

## Source and installation

| Item | Description |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Executable name | `btm` |

```zsh
zi_cmd ClementTsang/bottom btm
```

Note that the command name is `btm`, not `bottom`.

## Launching

```bash
btm                  # 默认布局
btm --basic          # 简化外观，接近 htop
btm --battery        # 显示电池
btm -b               # 同上 --basic
```

## Common options

| Option | Action |
|---|---|
| `-b` / `--basic` | Hide graphs, use plain-text bars |
| `--battery` | Show battery level |
| `-t` / `--default_time_value` | Default time window for graphs, e.g. `60s` |
| `-C` / `--config_location` | Specify a config file path |
| `--autohide_time` | Auto-hide the time axis after zooming |
| `--hide_time` | Hide the time axis entirely |
| `--default_widget_type` | Type of the panel focused by default |
| `--default_widget_count` | Focus the Nth panel of that type |
| `--rate` | Sampling interval (milliseconds) |

`--basic` is especially useful over SSH or on low-bandwidth links, because graph refreshes produce a lot of terminal output.

## Interface and keys

| Key | Action |
|---|---|
| `q` / `Esc` | Quit |
| `?` | Help |
| `f` | Open filter |
| `/` | Search processes |
| `dd` | Kill the selected process |
| `Tab` | Switch panels |
| `+` / `-` | Zoom the time axis |
| `e` | Expand/collapse |
| `Ctrl+f` | Freeze/unfreeze refreshing |

## Configuration

```bash
btm -C ~/.config/bottom/bottom.toml
```

Without `-C` the default location is used; the file is created automatically if missing.

The config is TOML with these main sections:

```toml
[flags]
rate = 1000
dot_marker = false
enable_gpu = false

[colors]
table_header_color = "LightCyan"

[disk_filter]
is_list_ignored = true
list = ["/dev/loop"]

[processes]
columns = ["pid", "name", "cpu", "mem"]
```

`[processes].columns` lets you customize which columns the process table shows — this is bottom's advantage over btop: more compact output, better for small windows.

## Choosing between bottom and btop

| Scenario | Recommendation |
|---|---|
| Comfortable visuals, mouse support | btop |
| SSH / low bandwidth | `btm --basic` |
| Custom columns | bottom |
| Scriptable output | `procs` or `ps` |

## Troubleshooting

**`btm: command not found`**: Zinit has not downloaded it. Remember the command name is `btm`.

**Garbled graphics**: a font or `$TERM` problem. `--basic` works around it.

**GPU not shown**: GPU support must be enabled at compile time and may be absent from release binaries. `enable_gpu = true` in the config also requires underlying support.

**Disk list too long**: use `[disk_filter]` to exclude loop devices and network mounts.

**Config not applied**: verify the file pointed to by `-C` exists and is valid TOML. On a TOML syntax error, bottom silently falls back to defaults without reporting an error.

<!-- lang:ja -->
> 要約：bottom（btm）は設定可能なターミナル用システムモニターで、Rust 実装、TOML 設定に対応しています。

# bottom (btm)

## 用途

`bottom` は btop と同じ立ち位置ですが、設計の方向性が異なります。btop はグラフィカル寄り、bottom は設定可能性とスクリプト容易性寄りです。Rust で書かれており、起動が速くメモリ使用量も少ないです。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |
| 実行ファイル名 | `btm` |

```zsh
zi_cmd ClementTsang/bottom btm
```

コマンド名は `bottom` ではなく `btm` であることに注意してください。

## 起動

```bash
btm                  # 默认布局
btm --basic          # 简化外观，接近 htop
btm --battery        # 显示电池
btm -b               # 同上 --basic
```

## よく使うオプション

| オプション | 動作 |
|---|---|
| `-b` / `--basic` | グラフを隠し、プレーンテキストのバーで表示 |
| `--battery` | バッテリー残量を表示 |
| `-t` / `--default_time_value` | グラフのデフォルト時間窓、例：`60s` |
| `-C` / `--config_location` | 設定ファイルのパスを指定 |
| `--autohide_time` | ズーム後に時間軸を自動的に隠す |
| `--hide_time` | 時間軸を完全に隠す |
| `--default_widget_type` | デフォルトでフォーカスするパネルの種類 |
| `--default_widget_count` | 同種パネルの N 番目にフォーカス |
| `--rate` | サンプリング間隔（ミリ秒） |

`--basic` は SSH や低帯域環境で特に有用です。グラフの再描画が大量のターミナル出力を生成するためです。

## インターフェースとキー操作

| キー | 動作 |
|---|---|
| `q` / `Esc` | 終了 |
| `?` | ヘルプ |
| `f` | フィルタを開く |
| `/` | プロセスを検索 |
| `dd` | 選択したプロセスを終了 |
| `Tab` | パネルを切り替え |
| `+` / `-` | 時間軸をズーム |
| `e` | 展開/折りたたみ |
| `Ctrl+f` | 更新の凍結/解除 |

## 設定

```bash
btm -C ~/.config/bottom/bottom.toml
```

`-C` を省略するとデフォルトの場所を使い、ファイルがなければ自動的に作成されます。

設定は TOML で、主なセクションは次のとおりです：

```toml
[flags]
rate = 1000
dot_marker = false
enable_gpu = false

[colors]
table_header_color = "LightCyan"

[disk_filter]
is_list_ignored = true
list = ["/dev/loop"]

[processes]
columns = ["pid", "name", "cpu", "mem"]
```

`[processes].columns` でプロセステーブルの表示列をカスタマイズできます。これは bottom が btop に対して持つ利点で、出力がよりコンパクトになり、小さいウィンドウに向いています。

## bottom と btop の使い分け

| シーン | おすすめ |
|---|---|
| 見やすさ・マウス操作重視 | btop |
| SSH / 低帯域 | `btm --basic` |
| 列をカスタマイズしたい | bottom |
| スクリプト向け出力 | `procs` か `ps` |

## トラブルシューティング

**`btm: command not found`**：Zinit がダウンロードしていません。コマンド名が `btm` であることに注意してください。

**グラフィックが文字化けする**：フォントか `$TERM` の問題です。`--basic` で回避できます。

**GPU が表示されない**：コンパイル時に GPU 機能を有効にする必要があり、release のバイナリには含まれていない場合があります。設定の `enable_gpu = true` も下層のサポートが前提です。

**ディスク一覧が長すぎる**：`[disk_filter]` で loop デバイスやネットワークマウントを除外してください。

**設定が反映されない**：`-C` が指すファイルが存在し、有効な TOML か確認してください。TOML の構文エラーがあると、bottom はエラーを出さずにデフォルト値へフォールバックします。
