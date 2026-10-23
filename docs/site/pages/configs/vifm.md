> 摘要：vifmrc 的选项、完整键位表、图标规则和 vifm-copy 剪贴板脚本。

# Vifm 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/vifm/vifmrc` |
| 部署目标 | `~/.config/vifm/vifmrc` |
| 配色 | `config/vifm/colors/papercolor-dark.vifm` |
| 脚本 | `config/vifm/scripts/vifm-copy` |
| 是否自动链接 | 是（三条独立映射） |

## 选项

```vim
colorscheme papercolor-dark
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
set statusline="%t%= %A %10u:%-7g %15s %20d  "
set quickview
```

| 选项 | 作用 |
|---|---|
| `trash` | 删除移到回收站而非直接删 |
| `dotdirs=` | 控制隐藏目录显示（空值表示用默认） |
| `vicmd=nvim` | `:` 命令和编辑器用 nvim |
| `syscalls` | 允许系统调用（复制/移动用） |
| `history=200` | 命令历史条数 |
| `followlinks` | 进入软链接指向的目录 |
| `number` | 显示行号 |
| `sortnumbers` | 数字按数值排序（file2 在 file10 前） |
| `vimhelp` | 帮助用 Vim 风格导航 |
| `timefmt` | 时间显示格式 |
| `incsearch` | 搜索时实时跳转 |
| `quickview` | 右栏显示选中文件的预览（双栏布局不变） |

## 启动行为

启动时保持双栏：左栏是当前目录，右栏用 quick view 预览左栏选中的文件（文本、目录内容按 vifm 的预览规则显示）。不再有把右栏强制 `cd ~` 的自动命令，所以预览不会被打断。

启动时光标在左栏，右栏不再是固定目录，而是随左栏选择变化的预览区。需要临时单栏时按 `<Space>p`，再按一次恢复双栏。

## 状态行

```vim
set statusline="%t%= %A %10u:%-7g %15s %20d  "
```

| 占位 | 含义 |
|---|---|
| `%t` | 文件名 |
| `%=` | 左右分隔 |
| `%A` | 当前模式 |
| `%10u` | 用户 |
| `%-7g` | 组 |
| `%15s` | 大小 |
| `%20d` | 日期 |

## 图标

```vim
set classify=" :dir:"
set classify+=" :link:"
set classify+=" :exe:"
set classify+="󰈔 :reg:"
set classify+=" ::*.lua::"
set classify+=" ::*.rs::"
set classify+=" ::*.go::"
set classify+=" ::*.py::"
set classify+=" ::*.js::"
set classify+=" ::*.ts::"
set classify+=" ::*.html::"
set classify+=" ::*.css::"
set classify+=" ::.git::"
set classify+=" ::*.zip::"
set classify+=" ::*.tar::"
set classify+=" ::*.png::"
set classify+=" ::*.mp4::"
set classify+=" ::*.mp3::"
set classify+="󰈙 ::*.md::"
set classify+=" ::*.json::"
```

`classify` 的语法：`图标 :类型:` 或 `图标 ::通配符::`。

图标只是显示前缀，**不改变文件名**。复制、重命名时用真实文件名。

## 键位

### 导航

| 键 | 动作 |
|---|---|
| `j` / `k` | 上下移动 |
| `h` / `l` | 上级 / 进入 |
| `o` | 映射为 `l`（进入） |
| `O` | `:edit` |
| `<Tab>` | 下一个 tab |
| `<S-Tab>` | 上一个 tab |
| `T` | 新建 tab |
| `X` | 关闭 tab |
| `<Space>p` | 单栏/双栏切换 |
| `q` | 退出 |
| `Q` | 强制退出 |

### 文件操作

| 键 | 动作 |
|---|---|
| `a` | 新建文件（`:touch`） |
| `r` | 重命名 |
| `d` | 移到 trash |
| `D` | 直接删除 |
| `y` | 复制（`yy`） |
| `x` | 剪切（`dd`） |
| `p` / `P` | 粘贴 |
| `.` | 切换 dotfiles |
| `s` | 打开 shell |
| `f` | 搜索（`/`） |
| `F` | 按类型筛选（`=`） |
| `n` / `N` | 下一个/上一个匹配 |

### 书签

| 键 | 动作 |
|---|---|
| `m` | 添加书签 |
| `'` | 列出书签 |
| `b` | 删除书签 |
| `B` | 强制删除书签 |

### 剪贴板

| 键 | 复制内容 |
|---|---|
| `cc` | 完整路径 |
| `cf` | 文件名 |
| `cd` | 父目录 |
| `cn` | 不含扩展名的文件名 |

实现：

```vim
nnoremap cc :!vifm-copy %"c:p &<cr>
nnoremap cf :!vifm-copy %"c:t &<cr>
nnoremap cd :!vifm-copy %"c:p:h &<cr>
nnoremap cn :!vifm-copy %"c:t:r &<cr>
```

| 占位 | 含义 |
|---|---|
| `%c` | 当前文件 |
| `:p` | 完整路径 |
| `:t` | 文件名部分 |
| `:h` | 去掉最后一段（父目录） |
| `:r` | 去掉扩展名 |

## vifm-copy

```sh
#!/usr/bin/env sh
set -eu

value=${1-}

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

按环境变量 + 命令存在性双重判断：

| 后端 | 条件 |
|---|---|
| `wl-copy` | `$WAYLAND_DISPLAY` 存在且命令可用 |
| `xclip` | `$DISPLAY` 存在且命令可用 |
| `xsel` | 命令可用（无环境检查） |
| `pbcopy` | 命令可用（macOS） |
| `clip.exe` | 命令可用（WSL） |

全都不满足时**报错退出**，不会静默失败。

## 验证

```bash
vifm --version
ls -l ~/.config/vifm/
~/.config/vifm/scripts/vifm-copy "test"
```

最后一条应该把 "test" 放进剪贴板。

## 排错

**图标乱码**：字体不是 Nerd Font。

**`cc` 没反应**：`vifm-copy` 找不到剪贴板后端。`command -v wl-copy xclip xsel pbcopy clip.exe` 检查。

**配色不对**：`config/vifm/colors/papercolor-dark.vifm` 没部署。

**`v` 退出后目录没变**：Vifm 非正常退出（被 kill）。

**trash 在哪**：`~/.local/share/vifm/Trash/`。

**右栏总是跳回 home**：这是 `autocmd WinEnter` 的设计，不是 bug。
