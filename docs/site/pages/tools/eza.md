> 摘要：eza 是 ls 的现代替代，本仓库用它实现 l、ll、la 三个列表别名。

# eza

## 用途

`eza` 是 `ls` 的替代品：彩色输出、文件类型图标、Git 状态列、树状视图、更合理的默认排序。本仓库不安装它（由系统包管理器提供），但检测到之后会定义三个别名。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器，仓库不安装 |
| 检测 | `aliases.conf` 里用 `command -v eza` 判断 |
| 缺失影响 | `l`/`ll`/`la` 三个别名不定义，其它功能不受影响 |

```bash
# Debian / Ubuntu
sudo apt install eza
# Arch
sudo pacman -S eza
# macOS
brew install eza
```

Debian 12 的软件源里没有 eza，需要添加第三方源或用 cargo 安装。装不上就继续用系统 `ls`，本仓库不会因此报错。

## 本仓库定义的别名

```zsh
if command -v eza >/dev/null 2>&1; then
    alias l="eza --icons --group-directories-first --sort=modified --reverse"
    alias ll="eza -lh --icons --group-directories-first --git --sort=modified --reverse"
    alias la="eza -a --icons --group-directories-first --sort=modified --reverse"
fi
```

| 别名 | 展开 |
|---|---|
| `l` | 图标 + 目录优先 + 按修改时间倒序 |
| `ll` | 同上 + 长格式（权限、大小）+ Git 状态 |
| `la` | 同上 + 包含隐藏文件 |

三个都用了 `--sort=modified --reverse`，即**最近修改的排在最上面**。这和 `ls` 默认按名字排序不同，是为了让刚编辑过的文件浮到顶部。

`--group-directories-first` 让目录始终在文件之前，即使文件更新。

## 常用参数

| 参数 | 作用 |
|---|---|
| `-l` | 长格式 |
| `-h` | 人类可读的大小（1K、2M） |
| `-a` | 包含隐藏文件 |
| `-T` / `--tree` | 树状视图 |
| `--level=N` | 树状视图的深度 |
| `--git` | 显示 Git 状态列 |
| `--icons` | 显示文件类型图标 |
| `--group-directories-first` | 目录排在最前 |
| `-s modified` | 按修改时间排序 |
| `-r` | 反转排序 |
| `--time-style=long-iso` | 时间格式 |
| `-1` | 每行一个文件（fzf-tab 预览用这个） |

## 实用例子

```bash
eza -lh --git                      # 长格式 + Git 状态
eza -T --level=2                   # 两层树状
eza -la --time-style=long-iso      # 带完整时间戳
eza --sort=size -l                 # 按大小排序
eza -1 --color=always              # 单列，供 fzf 预览
```

`-1 --color=always` 是 fzf-tab 的 `cd` 预览命令，`--color=always` 不能省，否则管道输出没有颜色。

## 与本仓库其它部分的联动

- `plugins/zsh-plugins.zsh` 里 fzf-tab 的 `cd` 和 `z` 补全预览用 `eza -1 --color=always`，没有 eza 时回退到 `ls -1`。
- fzf-tab 的 `zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}` 依赖 `LS_COLORS`，与 eza 无关，两者可以共存。

## 排错

**`l` 命令不存在**：`command -v eza` 无输出，说明没装。装好后 `exec zsh`。

**图标显示成方框**：终端字体不是 Nerd Font。装 Meslo 后重新选字体。

**`--git` 列不显示**：不在 Git 仓库内，或者 eza 版本太旧不支持该参数。

**排序和预期不符**：`--sort=modified --reverse` 是最近的在前。想要最旧的在前，去掉 `--reverse`。
