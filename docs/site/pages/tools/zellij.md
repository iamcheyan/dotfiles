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
