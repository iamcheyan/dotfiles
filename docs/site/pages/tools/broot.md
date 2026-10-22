> 摘要：broot 用树状视图浏览目录，配合 br 函数可以在退出时切换目录。

# broot

## 用途

`broot` 显示目录树，让你在树里移动、预览、搜索、执行操作。它不是全屏文件管理器，而是「先看结构，再决定去哪」。

本仓库在 `zshrc` 里生成 `br` shell 函数：

```zsh
if command -v broot >/dev/null 2>&1; then
    eval "$(broot --print-shell-function zsh)"
fi
```

`br` 比直接 `broot` 多一个能力：退出时把当前目录传给 shell。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，按 OS/架构选择 Release 包 |
| 可执行名 | `broot` |
| shell 函数 | `br`，启动时由 broot 自己生成 |

```zsh
if [[ "$OSTYPE" == "darwin"* ]]; then
  zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/aarch64-apple-darwin/broot -> broot" pick"broot"
else
  case "$(uname -m)" in
    aarch64|arm64)
      zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/aarch64-unknown-linux-gnu/broot -> broot" pick"broot" ;;
    armv7l|armv7)
      zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/armv7-unknown-linux-gnueabihf/broot -> broot" pick"broot" ;;
    *)
      zinit ice as"command" from"gh-r" bpick"broot_*.zip" mv"broot_*/x86_64-unknown-linux-gnu-glibc2.28/broot -> broot" pick"broot" ;;
  esac
fi
zinit light Canop/broot
```

broot 的 release 是 zip，内部按架构分了多层目录，`mv` 规则把二进制抽出来。

## 首次使用

```bash
broot
```

首次启动会引导你安装 shell 函数（`br`）。本仓库已经在 `zshrc` 里自动生成，所以通常不需要手动装。

## 基本用法

```bash
br                  # 从当前目录打开树
br ~/dotfiles       # 从指定目录
br -s               # 显示文件大小
br -p               # 显示权限
br --sizes --dates  # 多列信息
broot               # 不带 shell 函数，退出后不切目录
```

## 树里的操作

| 键 | 作用 |
|---|---|
| `↑` / `↓` 或 `j` / `k` | 移动 |
| `→` / `←` | 展开/折叠 |
| `Enter` | 打开文件（用 `$EDITOR`）或进入目录 |
| `:` | 输入命令 |
| `/` | 搜索文件名 |
| `Ctrl+F` | 搜索内容 |
| `Esc` | 返回/退出 |
| `?` | 帮助 |
| `q` | 退出 |

### 常用命令（按 `:` 后输入）

| 命令 | 作用 |
|---|---|
| `:cd` | 切换 shell 目录到当前位置（配合 `br`） |
| `:e` | 用编辑器打开 |
| `:rm` | 删除 |
| `:mv` | 移动/重命名 |
| `:cp` | 复制 |
| `:mkdir` | 新建目录 |
| `:focus` | 只显示匹配项 |
| `:toggle_hidden` | 显示隐藏文件 |

## 模糊搜索

broot 支持模糊模式：直接输入字符即可过滤。

```text
输入 "dfg" → 匹配 dotfiles/git 这类路径
```

按 `Esc` 退出模糊模式回到树视图。

## 配置文件

```bash
broot --conf ~/.config/broot/conf.hjson
```

默认位置：`~/.config/broot/conf.hjson`。首次启动会生成一个带注释的默认配置。

常用自定义：

```hjson
{
    default_flags: "-s -p"
    verbs: [
        {
            invocation: "edit"
            shortcut: "e"
            execution: "$EDITOR {file}"
        }
    ]
}
```

本仓库不提供该配置，用上游默认值。

## 与 ranger / vifm 的分工

| | broot | ranger | vifm |
|---|---|---|---|
| 形态 | 树状浏览 | 双栏（三栏） | 双栏 |
| 强项 | 看结构、模糊搜索 | 预览、批量操作 | Vim 键位 |
| 退出切目录 | `br` + `:cd` | `ra` 自动 | `v` 自动 |
| 资源占用 | 低 | 中 | 低 |

想快速看清目录结构用 broot，要做批量文件操作用 ranger，要 Vim 键位用 vifm。

## 排错

**`br: command not found`**：`zshrc` 里那段 `eval "$(broot --print-shell-function zsh)"` 没执行。确认 `command -v broot` 有输出。

**`br` 退出后没切目录**：忘了在 broot 里执行 `:cd`。`br` 只在你显式 `:cd` 时才切换。

**树加载慢**：大目录默认全展开。用 `-d` 限制深度，或在配置里设 `max_depth`。

**图标乱码**：字体不是 Nerd Font。

**权限错误**：broot 默认不显示无权限目录的内容。用 `sudo broot` 或配置里放宽。
