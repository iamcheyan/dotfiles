> 摘要：Ranger 的 rc.conf 与 rifle.conf 配置项、devicons 图标和 archives 归档插件。

# Ranger 配置

## 文件位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/ranger/` |
| 部署目标 | `~/.config/ranger/` |
| 是否自动链接 | 是（整个目录） |

目录结构：

```text
config/ranger/
├── rc.conf          # 主配置
├── rifle.conf       # 文件打开规则
└── plugins/
    ├── ranger_devicons/   # git 子模块
    └── archives/          # git 子模块
```

## rc.conf

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"

set preview_images true
set draw_borders both
default_linemode devicons
set show_hidden true
set preview_files true

map ex extract
map ec compress
```

### 配置项

| 行 | 作用 |
|---|---|
| `preview_images true` | 预览区显示图片（需终端支持） |
| `draw_borders both` | 三栏都画边框 |
| `default_linemode devicons` | 用 devicons 图标模式 |
| `show_hidden true` | 默认显示隐藏文件 |
| `preview_files true` | 预览区显示文件内容 |
| `map ex extract` | `ex` 触发归档插件解压 |
| `map ec compress` | `ec` 触发归档插件压缩 |

### 那个 alias

```text
alias alpine echo "sftp://student@localhost:2222 (密码: student)"
```

这是一个提示性别名，输出一条示例连接串。它不执行实际连接，只是把常用地址存起来方便复制。**里面写的是示例凭据，不是真实环境**。

## rifle.conf

```text
file, label editor = ${VISUAL:-$EDITOR} -- "$@"
```

整个文件只有一条规则：所有普通文件用 `${VISUAL:-$EDITOR}` 打开。

因为 `zshrc` 把 `$VISUAL` 和 `$EDITOR` 都设成了 `nvim`，所以 Ranger 里按 Enter 打开文件时进 Neovim。

注释里提到：

```text
# rnvimr intercepts rules containing $EDITOR and opens the selected file
# through Neovim RPC. Standalone ranger still uses the configured editor.
```

如果装了 rnvimr（Neovim 的 Ranger 集成），它会拦截这条规则，用 RPC 在已有 Neovim 实例里打开。没装时就是普通调用。

## devicons 插件

给文件和目录加 Nerd Font 图标。

```text
config/ranger/plugins/ranger_devicons/
├── __init__.py
├── devicons.py
└── locales/
    ├── de.py
    ├── es.py
    ├── ja.py
    ├── zh_cn.py
    └── ...
```

启用方式：`default_linemode devicons`。

支持多语言（`zh_cn.py`、`ja.py`），会根据 `LANG` 选。

## archives 插件

提供压缩/解压命令：

| 命令 | 作用 |
|---|---|
| `:extract [dir]` | 解压到当前或指定目录 |
| `:extract_raw [flags]` | 用自定义参数解压 |
| `:extract_to_dirs [flags]` | 每个归档解压到同名子目录 |
| `:compress [flags] [file.ext]` | 压缩选中项 |

快捷映射：`ex` = extract，`ec` = compress。

支持格式取决于系统装了什么工具：

| 格式 | 依赖 |
|---|---|
| `.zip` | zip / unzip / 7z |
| `.7z` | 7z |
| `.rar` | rar / unrar / 7z |
| `.tar.gz` | tar + gzip/pigz |
| `.tar.bz2` | tar + bzip2/pbzip2 |
| `.tar.xz` | tar + xz/pixz |
| `.tar.zst` | tar + zstd |
| `.tar.lz4` | tar + lz4 |

插件会优先用并行版本（`pigz`、`pbzip2`、`pixz`）提升速度。

## 常用按键

| 键 | 作用 |
|---|---|
| `h` / `l` | 上级 / 进入 |
| `j` / `k` | 上下 |
| `Space` | 选中 |
| `v` | 反向选择 |
| `dd` | 剪切 |
| `yy` | 复制 |
| `pp` | 粘贴 |
| `dD` | 删除 |
| `cw` | 重命名 |
| `zh` | 切换隐藏 |
| `zp` | 切换预览 |
| `S` | 开 shell |
| `:` | 命令 |
| `?` | 帮助 |

## 验证

```bash
ranger --version
ls -l ~/.config/ranger/rc.conf
ls ~/.config/ranger/plugins/
```

插件目录应该是软链接或实际目录，且里面 `__init__.py` 存在。

## 排错

**图标是方框**：字体不是 Nerd Font。

**图片不预览**：终端不支持图像协议（Kitty/iTerm2/sixel）。普通终端只能显示文件名。

**`ex` / `ec` 无反应**：archives 插件没装。`git submodule update --init --recursive`。

**打开文件不用 nvim**：`$EDITOR` / `$VISUAL` 没设。检查 `echo $EDITOR`。

**插件报 Python 错误**：Ranger 用 Python 3，插件可能需要特定版本。`python3 --version` 确认。

**`alpine` 别名执行了奇怪的东西**：它只是 `echo`，输出一条示例串，不连接任何地方。
