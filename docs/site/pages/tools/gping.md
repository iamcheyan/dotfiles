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
