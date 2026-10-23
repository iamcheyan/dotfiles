> 摘要：gping 是带实时延迟曲线的 ping，可以同时 ping 多个目标。

# gping

## 用途

`gping` 把 ping 的延迟数据画成实时曲线，可以同时监控多个主机，直接看出抖动和丢包。它还支持把任意命令的执行时间画成曲线。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，按 OS/CPU 选择 Release 包 |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gping_arch="arm64"
  [[ "$(uname -m)" == "x86_64" ]] && gping_arch="x86_64"
  zinit ice as"command" from"gh-r" bpick"gping-macOS-${gping_arch}.tar.gz" pick"gping"
else
  local gping_arch="x86_64"
  [[ "$(uname -m)" == "aarch64" ]] && gping_arch="arm64"
  zinit ice as"command" from"gh-r" bpick"gping-Linux-musl-${gping_arch}.tar.gz" pick"gping"
fi
zinit light orf/gping
```

注意 Linux 和 macOS 的架构命名不同：Linux aarch64 对应包名 `arm64`。

## 基本用法

```bash
gping 1.1.1.1                    # ping 单个目标
gping 1.1.1.1 8.8.8.8            # 同时 ping 两个
gping github.com                 # 域名
gping --cmd 'curl -s example.com'  # 画命令执行时间
```

## 常用参数

| 参数 | 作用 |
|---|---|
| `-n` / `--watch-interval` | 采样间隔（秒），支持小数如 `0.5` |
| `-b` / `--buffer` | 曲线显示多少秒的数据，默认 30 |
| `-4` | 强制 IPv4 |
| `-6` | 强制 IPv6 |
| `-i` / `--interface` | 指定网络接口 |
| `-s` / `--simple-graphics` | 用简单字符代替 Braille 点阵 |
| `-c` / `--color` | 给每个目标指定颜色，支持 `#RRGGBB` |
| `--cmd` | 把参数当命令执行，画执行时间 |
| `--vertical-margin` | 曲线上下留白 |
| `--horizontal-margin` | 曲线左右留白 |

## 实用例子

```bash
gping -b 60 1.1.1.1              # 显示 60 秒窗口
gping -n 0.1 8.8.8.8             # 每 100ms 采样
gping -4 github.com              # 强制 IPv4
gping --cmd 'curl -s -o /dev/null https://example.com'  # 监控 HTTP 响应时间
gping -c red,blue 1.1.1.1 8.8.8.8  # 指定颜色
```

`--cmd` 模式很实用：任何命令的执行时间都能画成曲线，用来观察 DNS 解析、HTTP 响应、API 调用的稳定性。

## 云区域简写

```bash
gping aws:eu-west-1
```

支持 AWS 区域简写，自动解析成对应的 endpoint。

## 曲线读法

```text
  1.1.1.1
  ⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀
  min: 8.2ms  avg: 8.5ms  max: 9.1ms
```

- 曲线平稳 → 网络稳定。
- 曲线有规律起伏 → 可能是有其他流量周期性占用带宽。
- 突然尖峰 → 丢包重传或路由抖动。
- 曲线断档 → 完全超时。

## 与 ping 的差异

| | ping | gping |
|---|---|---|
| 输出 | 逐行文本 | 实时曲线 |
| 多目标 | 需要多个终端 | 同一图内多色 |
| 历史 | 滚动消失 | 保留 buffer 秒数 |
| 任意命令 | 不支持 | `--cmd` |

## 排错

**`gping: command not found`**：Zinit 未下载对应架构包。检查 `zinit list | grep gping`。

**曲线不显示**：终端不支持 Braille 字符。用 `-s` 切简单图形。

**权限错误**：某些系统 ping 需要 raw socket 权限。`gping` 通常用非特权模式，若报错检查系统 `ping_group_range` 设置。

**`--cmd` 模式无输出**：命令本身失败。先单独运行该命令确认。

**多目标颜色相同**：用 `-c` 显式指定，逗号分隔，顺序对应目标顺序。

<!-- lang:en -->

> Summary: gping is ping with a real-time latency graph; it can ping multiple targets at once.

# gping

## Purpose

`gping` turns ping's latency data into a real-time graph, letting you monitor multiple hosts at once and see jitter and packet loss at a glance. It can also graph the execution time of any command.

## Source and Installation

| Item | Description |
|---|---|
| Source | Zinit, choosing the Release package by OS/CPU |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gping_arch="arm64"
  [[ "$(uname -m)" == "x86_64" ]] && gping_arch="x86_64"
  zinit ice as"command" from"gh-r" bpick"gping-macOS-${gping_arch}.tar.gz" pick"gping"
else
  local gping_arch="x86_64"
  [[ "$(uname -m)" == "aarch64" ]] && gping_arch="arm64"
  zinit ice as"command" from"gh-r" bpick"gping-Linux-musl-${gping_arch}.tar.gz" pick"gping"
fi
zinit light orf/gping
```

Note that Linux and macOS name architectures differently: Linux aarch64 corresponds to the package name `arm64`.

## Basic usage

```bash
gping 1.1.1.1                    # ping 单个目标
gping 1.1.1.1 8.8.8.8            # 同时 ping 两个
gping github.com                 # 域名
gping --cmd 'curl -s example.com'  # 画命令执行时间
```

## Common options

| Option | Purpose |
|---|---|
| `-n` / `--watch-interval` | Sampling interval (seconds); decimals like `0.5` are supported |
| `-b` / `--buffer` | How many seconds of data the graph shows, default 30 |
| `-4` | Force IPv4 |
| `-6` | Force IPv6 |
| `-i` / `--interface` | Specify a network interface |
| `-s` / `--simple-graphics` | Use plain characters instead of Braille dots |
| `-c` / `--color` | Assign a color per target; `#RRGGBB` supported |
| `--cmd` | Execute the arguments as a command and graph its execution time |
| `--vertical-margin` | Vertical padding around the graph |
| `--horizontal-margin` | Horizontal padding around the graph |

## Practical examples

```bash
gping -b 60 1.1.1.1              # 显示 60 秒窗口
gping -n 0.1 8.8.8.8             # 每 100ms 采样
gping -4 github.com              # 强制 IPv4
gping --cmd 'curl -s -o /dev/null https://example.com'  # 监控 HTTP 响应时间
gping -c red,blue 1.1.1.1 8.8.8.8  # 指定颜色
```

The `--cmd` mode is very useful: the execution time of any command can be graphed, which helps you watch the stability of DNS resolution, HTTP responses, and API calls.

## Cloud region shorthand

```bash
gping aws:eu-west-1
```

AWS region shorthands are supported and resolved automatically to the corresponding endpoint.

## How to read the graph

```text
  1.1.1.1
  ⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀
  min: 8.2ms  avg: 8.5ms  max: 9.1ms
```

- A flat graph → the network is stable.
- Regular ups and downs → other traffic may be periodically consuming bandwidth.
- Sudden spikes → packet loss with retransmission, or route jitter.
- Gaps in the graph → complete timeouts.

## Differences from ping

| | ping | gping |
|---|---|---|
| Output | Line-by-line text | Real-time graph |
| Multiple targets | Needs several terminals | Multiple colors in one chart |
| History | Scrolls away | Kept for the buffer duration |
| Arbitrary commands | Not supported | `--cmd` |

## Troubleshooting

**`gping: command not found`**: Zinit has not downloaded the package for your architecture. Check `zinit list | grep gping`.

**The graph does not display**: the terminal does not support Braille characters. Switch to simple graphics with `-s`.

**Permission errors**: on some systems ping requires raw socket privileges. `gping` usually runs unprivileged; if it errors, check the system's `ping_group_range` setting.

**No output in `--cmd` mode**: the command itself is failing. Run it alone first to confirm.

**Multiple targets share the same color**: specify explicitly with `-c`, comma-separated, in the same order as the targets.

<!-- lang:ja -->

> 要約：gping はリアルタイムの遅延グラフ付き ping で、複数ターゲットを同時に ping できます。

# gping

## 用途

`gping` は ping の遅延データをリアルタイムのグラフに描画し、複数ホストを同時に監視してジッタやパケットロスを一目で把握できます。任意のコマンドの実行時間をグラフ化することもできます。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit。OS/CPU に応じて Release パッケージを選択 |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  local gping_arch="arm64"
  [[ "$(uname -m)" == "x86_64" ]] && gping_arch="x86_64"
  zinit ice as"command" from"gh-r" bpick"gping-macOS-${gping_arch}.tar.gz" pick"gping"
else
  local gping_arch="x86_64"
  [[ "$(uname -m)" == "aarch64" ]] && gping_arch="arm64"
  zinit ice as"command" from"gh-r" bpick"gping-Linux-musl-${gping_arch}.tar.gz" pick"gping"
fi
zinit light orf/gping
```

Linux と macOS ではアーキテクチャの命名が異なることに注意してください。Linux の aarch64 はパッケージ名 `arm64` に対応します。

## 基本的な使い方

```bash
gping 1.1.1.1                    # ping 单个目标
gping 1.1.1.1 8.8.8.8            # 同时 ping 两个
gping github.com                 # 域名
gping --cmd 'curl -s example.com'  # 画命令执行时间
```

## よく使うオプション

| オプション | 役割 |
|---|---|
| `-n` / `--watch-interval` | サンプリング間隔（秒）。`0.5` のような小数も可 |
| `-b` / `--buffer` | グラフに表示するデータの秒数。デフォルトは 30 |
| `-4` | IPv4 を強制 |
| `-6` | IPv6 を強制 |
| `-i` / `--interface` | ネットワークインターフェースを指定 |
| `-s` / `--simple-graphics` | Braille ドットの代わりに単純な文字を使う |
| `-c` / `--color` | ターゲットごとに色を指定。`#RRGGBB` に対応 |
| `--cmd` | 引数をコマンドとして実行し、実行時間をグラフ化 |
| `--vertical-margin` | グラフの上下の余白 |
| `--horizontal-margin` | グラフの左右の余白 |

## 実用的な例

```bash
gping -b 60 1.1.1.1              # 显示 60 秒窗口
gping -n 0.1 8.8.8.8             # 每 100ms 采样
gping -4 github.com              # 强制 IPv4
gping --cmd 'curl -s -o /dev/null https://example.com'  # 监控 HTTP 响应时间
gping -c red,blue 1.1.1.1 8.8.8.8  # 指定颜色
```

`--cmd` モードはとても便利です。任意のコマンドの実行時間をグラフ化でき、DNS 解決、HTTP 応答、API 呼び出しの安定性を観察できます。

## クラウドリージョンの略記

```bash
gping aws:eu-west-1
```

AWS リージョンの略記に対応しており、対応するエンドポイントへ自動解決します。

## グラフの読み方

```text
  1.1.1.1
  ⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀⣀
  min: 8.2ms  avg: 8.5ms  max: 9.1ms
```

- グラフが安定 → ネットワークは安定しています。
- 規則的な波 → 他のトラフィックが周期的に帯域を消費している可能性があります。
- 突然のスパイク → パケットロスの再送かルートのジッタです。
- グラフの欠落 → 完全なタイムアウトです。

## ping との違い

| | ping | gping |
|---|---|---|
| 出力 | 行単位のテキスト | リアルタイムグラフ |
| 複数ターゲット | 複数のターミナルが必要 | 同じグラフ内に多色表示 |
| 履歴 | スクロールして消える | buffer 秒数分保持 |
| 任意のコマンド | 非対応 | `--cmd` |

## トラブルシューティング

**`gping: command not found`**：Zinit が対応アーキテクチャのパッケージをダウンロードしていません。`zinit list | grep gping` を確認します。

**グラフが表示されない**：ターミナルが Braille 文字に対応していません。`-s` で単純な図形に切り替えます。

**権限エラー**：一部のシステムでは ping に raw socket 権限が必要です。`gping` は通常は非特権モードで動きますが、エラーになる場合はシステムの `ping_group_range` 設定を確認してください。

**`--cmd` モードで出力がない**：コマンド自体が失敗しています。まず単独で実行して確認します。

**複数ターゲットの色が同じ**：`-c` で明示的に指定します。カンマ区切りで、順序はターゲットの順序に対応します。
