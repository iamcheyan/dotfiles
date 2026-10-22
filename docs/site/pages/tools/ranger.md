> 摘要：Ranger 是终端文件管理器，本仓库用 ra 包装函数让退出后自动切换目录。

# Ranger

## 用途

Ranger 用三栏布局浏览文件系统：左栏父目录、中栏当前目录、右栏预览。它支持图像/文本预览、批量选择、书签、标签页。本仓库装了 devicons 和 archives 两个插件。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | 系统包管理器 |
| 配置 | `config/ranger/` → `~/.config/ranger/` |
| 插件 | `ranger_devicons`、`archives`（都是 git 子模块） |

```bash
# Debian / Ubuntu
sudo apt install ranger
# Arch
sudo pacman -S ranger
# macOS
brew install ranger
```

init.sh 会检查并克隆两个插件：

```bash
git clone --depth 1 https://github.com/alexanderjeurissen/ranger_devicons.git "$plugin_dir"
git clone --depth 1 https://github.com/maximtrp/ranger-archives.git "$plugin_dir"
```

## ra 包装函数

`aliases.conf` 里定义：

```zsh
function ra {
  local tmpfile
  tmpfile="$(mktemp)"
  ranger --choosedir="$tmpfile" "${@:-$PWD}"
  if [ -f "$tmpfile" ]; then
    local newdir
    newdir="$(cat "$tmpfile")"
    [ -d "$newdir" ] && cd "$newdir"
    rm -f "$tmpfile"
  fi
}
```

流程：

1. 创建临时文件
2. `ranger --choosedir=<tmp>` 启动，Ranger 退出时把最后所在目录写进该文件
3. 读出来，`cd` 过去
4. 删除临时文件

所以 `ra` 退出后你的 shell 就在 Ranger 最后停留的目录，这是它相对直接 `ranger` 的核心价值。

## 基本用法

```bash
ra                  # 从当前目录
ra ~/dotfiles       # 从指定目录
ra file.txt         # 打开并选中文件
```

## 本仓库的 Ranger 配置

`config/ranger/rc.conf`：

```text
set preview_images true
set draw_borders both
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

| 配置 | 作用 |
|---|---|
| `preview_images` | 预览区显示图片（需要终端支持） |
| `draw_borders both` | 三栏都画边框 |
| `default_linemode devicons` | 用 devicons 显示文件图标 |
| `show_hidden` | 默认显示隐藏文件 |
| `preview_files` | 预览区显示文件内容 |
| `map ex extract` | `ex` 触发解压 |
| `map ec compress` | `ec` 触发压缩 |

## 常用按键

| 键 | 作用 |
|---|---|
| `h` / `l` | 上级目录 / 进入 |
| `j` / `k` | 上下移动 |
| `Space` | 选中/取消选中 |
| `v` | 反向选择 |
| `dd` | 剪切 |
| `yy` | 复制 |
| `pp` | 粘贴 |
| `dD` | 删除 |
| `cw` | 重命名 |
| `zh` | 切换隐藏文件 |
| `zp` | 切换预览 |
| `S` | 打开 shell |
| `q` | 退出 |
| `?` | 帮助 |
| `:` | 输入命令 |

## 书签

| 键 | 作用 |
|---|---|
| `m` + 字母 | 添加书签 |
| `'` + 字母 | 跳转书签 |
| `` ` `` + 字母 | 跳转到书签并进入 |
| `um` | 删除书签 |

书签保存在 `~/.config/ranger/bookmarks`。

## 归档插件

| 命令 | 作用 |
|---|---|
| `:extract` | 解压选中归档到当前目录 |
| `:extract_to_dirs` | 每个归档解压到同名子目录 |
| `:compress` | 压缩选中项 |
| `ex` | `:extract` 的快捷映射 |
| `ec` | `:compress` 的快捷映射 |

支持格式取决于系统里装了哪些压缩工具：tar、zip、7z、rar、zstd、lz4 等。

## rifle 配置

`config/ranger/rifle.conf` 决定用什么程序打开文件：

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

`$VISUAL` 或 `$EDITOR` 由 `zshrc` 设为 nvim。所以按 Enter 打开文件时进 Neovim。

## 图像预览依赖

`preview_images` 需要终端支持图像协议：

- Kitty（kitty graphics protocol）
- iTerm2（inline images）
- 某些终端支持 sixel

Ghostty 和普通终端通常不支持，此时预览区显示文件名而非图片。

## 排错

**`ra: command not found`**：`aliases.conf` 没加载，或 ranger 没装。

**图标乱码**：字体不是 Nerd Font。

**图片不预览**：终端不支持图像协议，正常现象。

**插件不生效**：子模块没初始化。`cd ~/dotfiles && git submodule update --init --recursive`。

**`ra` 退出后目录没变**：Ranger 里没有正常退出（比如被 kill）。`--choosedir` 只在正常退出时写文件。

**删除操作很慢**：大文件删除会阻塞界面。Ranger 有 `set confirm_on_delete` 选项可调整。
