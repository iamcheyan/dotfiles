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
