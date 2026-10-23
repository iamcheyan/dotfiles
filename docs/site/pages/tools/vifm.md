> 摘要：Vifm 是 Vim 风格的双栏文件管理器，本仓库配了完整键位和剪贴板脚本。

# Vifm

## 用途

Vifm 用 Vim 的键位习惯管理文件：`hjkl` 移动、`dd` 删除、`yy` 复制、`p` 粘贴。本仓库默认双栏：左栏浏览，右栏是 quick view 预览，按 `<Space>p` 可切到单栏。

相比 Ranger，Vifm 更贴近 Vim 用户的手感，配置文件也是 Vim 语法。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器（`init.sh` 的必备工具清单已包含 vifm） |
| 配置 | `config/vifm/` → `~/.config/vifm/` |
| 包装函数 | `v`（定义在 `zshrc`） |

```bash
# 已运行过 init.sh 的机器无需手动安装；单独安装：
# Debian / Ubuntu
sudo apt install vifm
# Arch
sudo pacman -S vifm
# macOS
brew install vifm
```

## v 包装函数

```zsh
v() {
  local tmp="$(mktemp -t vifm-cwd.XXXXXX)"
  vifm --choose-dir="$tmp" "$@"
  if [ -f "$tmp" ]; then
    cd "$(cat "$tmp")"
    rm -f "$tmp"
  fi
}
```

与 `ra` 同理：Vifm 退出时把最后目录写进临时文件，`v` 读出来并 `cd`。

```bash
v                  # 从当前目录
v ~/dotfiles       # 从指定目录
```

## 本仓库的配置

`config/vifm/vifmrc` 的关键设置：

```vim
set trash
set dotdirs=
set vicmd=nvim
set syscalls
set history=200
set followlinks
set number
set sortnumbers
set vimhelp
set timefmt=%Y-%m-%d\ %H:%M
set incsearch
colorscheme papercolor-dark
```

| 设置 | 作用 |
|---|---|
| `trash` | 删除移到回收站而非直接删 |
| `dotdirs=` | 控制隐藏目录的显示方式 |
| `vicmd=nvim` | `:` 命令和编辑器用 nvim |
| `history=200` | 命令历史 200 条 |
| `followlinks` | 进入软链接指向的目录 |
| `number` | 显示行号 |
| `sortnumbers` | 数字按数值排序 |
| `incsearch` | 搜索时实时跳转 |
| `colorscheme papercolor-dark` | 配色 |

右栏目录预览使用简洁清单：

装有 `eza` 时每项带 Nerd Font 图标、目录排在前面，并使用主题的青色目录／绿色可执行文件颜色；没有时回退到带 `/` 目录标记的 `ls`。文件预览仍由 Vifm 原有规则处理。

## 本仓库的键位

### 导航

| 键 | 作用 |
|---|---|
| `j` / `k` | 上下移动 |
| `h` / `l` | 上级 / 进入（`o` 也映射为 `l`） |
| `gg` / `G` | 首行 / 末行 |
| `<Tab>` / `<S-Tab>` | 下一个 / 上一个 tab |
| `T` / `X` | 新建 tab / 关闭 tab |
| `<Space>p` | 单栏/双栏切换 |
| `q` / `Q` | 退出 / 强制退出 |

### 文件操作

| 键 | 作用 |
|---|---|
| `a` | 新建文件 |
| `r` | 重命名 |
| `d` | 移到 trash |
| `D` | 直接删除 |
| `y` | 复制（yy） |
| `x` | 剪切（dd） |
| `p` / `P` | 粘贴 |
| `.` | 切换 dotfiles 显示 |
| `s` | 打开 shell |
| `f` / `F` | 搜索 / 按类型筛选 |

### 书签

| 键 | 作用 |
|---|---|
| `m` | 添加书签 |
| `'` | 列出书签 |
| `b` / `B` | 删除书签 |

### 剪贴板

| 键 | 复制内容 |
|---|---|
| `cc` | 完整路径 |
| `cf` | 文件名 |
| `cd` | 父目录路径 |
| `cn` | 不含扩展名的文件名 |

这四条调用 `vifm-copy`：

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

`%c` 是 Vifm 的当前文件占位符，`:p` 完整路径、`:t` 文件名、`:h` 去尾、`:r` 去扩展名。

## vifm-copy 脚本

`config/vifm/scripts/vifm-copy` 按顺序探测剪贴板后端：

```sh
if [ -n "${WAYLAND_DISPLAY-}" ] && command -v wl-copy >/dev/null 2>&1; then
  printf '%s' "$value" | wl-copy
elif [ -n "${DISPLAY-}" ] && command -v xclip >/dev/null 2>&1; then
  printf '%s' "$value" | xclip -selection clipboard
elif command -v xsel >/dev/null 2>&1; then
  printf '%s' "$value" | xsel -ib
elif command -v pbcopy >/dev/null 2>&1; then
  printf '%s' "$value" | pbcopy
elif command -v clip.exe >/dev/null 2>&1; then
  printf '%s' "$value" | clip.exe
else
  printf 'vifm-copy: no clipboard command found\n' >&2
  exit 1
fi
```

| 后端 | 环境 |
|---|---|
| `wl-copy` | Wayland |
| `xclip` | X11 |
| `xsel` | X11 备选 |
| `pbcopy` | macOS |
| `clip.exe` | WSL |

找不到后端时返回错误，不会假装成功。

## 图标

配置里用 `set classify` 给不同文件类型加图标：

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+=" ::*.lua::"
```

图标只是显示前缀，不改变文件名。

## 与 Ranger 的分工

| | Ranger | Vifm |
|---|---|---|
| 键位 | 自己的体系 | Vim 风格 |
| 配置格式 | Python | Vim 语法 |
| 预览 | 图像支持更好 | 文本为主 |
| 插件生态 | 丰富 | 较少 |

Vim 用户通常更习惯 Vifm。

## 排错

**`v: command not found`**：`zshrc` 里的函数没加载，或 vifm 没装。

**图标乱码**：字体不是 Nerd Font。

**`cc` 等剪贴板键没反应**：`vifm-copy` 找不到后端。检查 `command -v wl-copy xclip xsel`。

**`v` 退出后目录没变**：Vifm 非正常退出。

**trash 目录在哪**：`~/.local/share/vifm/Trash/`。想清空直接删。

**颜色不对**：`colorscheme papercolor-dark` 依赖 `config/vifm/colors/papercolor-dark.vifm` 已部署。
