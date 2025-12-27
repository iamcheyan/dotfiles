# superfile (spf) - 终端文件管理器使用文档

## 简介

superfile (spf) 是一个美观现代的终端文件管理器，使用 Go 语言编写。它提供了直观的界面和强大的文件管理功能。

**官方仓库**: https://github.com/yorukot/superfile  
**官方网站**: https://superfile.dev

## 安装

本插件已配置自动安装功能，首次使用时会自动下载安装。

### 手动安装

如果需要手动安装，可以使用官方安装脚本：

```bash
# macOS 和 Linux
bash -c "$(curl -sLo- https://superfile.dev/install.sh)"

# Windows (PowerShell)
powershell -ExecutionPolicy Bypass -Command "Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://superfile.dev/install.ps1'))"
```

### 安装位置

- Linux/macOS: `~/.local/bin/spf`
- 确保 `~/.local/bin` 在 PATH 中

## 基本使用

### 启动 superfile

```bash
# 从当前目录启动
spf

# 从指定目录启动
spf ~/Documents
spf /path/to/directory

# 使用别名（拼写容错）
superfile
superfiles
```

### 退出后切换目录

本插件已配置退出后自动切换目录功能：

1. 在 superfile 中浏览文件
2. 退出 superfile（按 `q` 或 `Esc`）
3. 终端会自动切换到 superfile 退出时的目录

**工作原理：**
- superfile 退出时将当前目录保存到 `lastdir` 文件
- 插件函数读取该文件并自动切换目录
- Linux: `~/.local/state/superfile/lastdir`
- macOS: `~/Library/Application Support/superfile/lastdir`

## 核心功能

### 文件操作

- **复制**: 选择文件后使用复制命令
- **移动**: 选择文件后使用移动命令
- **删除**: 选择文件后使用删除命令
- **重命名**: 选择文件后使用重命名命令
- **创建**: 创建新文件或目录

### 导航

- **上下移动**: 使用方向键或 `j`/`k`（vim 模式）
- **进入目录**: `Enter` 或 `l`
- **返回上级**: `Backspace` 或 `h`
- **跳转**: 快速跳转到指定路径

### 搜索

- **文件搜索**: 快速查找文件
- **内容搜索**: 在文件中搜索内容

## 快捷键

### 基本导航

| 快捷键 | 功能 |
|--------|------|
| `↑` / `k` | 向上移动 |
| `↓` / `j` | 向下移动 |
| `←` / `h` | 返回上级目录 |
| `→` / `l` | 进入目录 |
| `Enter` | 进入目录或打开文件 |
| `Backspace` | 返回上级目录 |
| `~` | 跳转到家目录 |
| `/` | 跳转到根目录 |

### 文件操作

| 快捷键 | 功能 |
|--------|------|
| `Space` | 选择/取消选择文件 |
| `c` | 复制文件 |
| `x` | 剪切文件 |
| `v` | 粘贴文件 |
| `d` | 删除文件 |
| `r` | 重命名文件 |
| `n` | 新建文件/目录 |
| `y` | 复制文件路径 |

### 视图和界面

| 快捷键 | 功能 |
|--------|------|
| `Tab` | 切换面板 |
| `t` | 切换文件树视图 |
| `p` | 切换预览窗口 |
| `s` | 切换排序方式 |
| `f` | 切换显示隐藏文件 |
| `?` | 显示帮助 |

### 搜索

| 快捷键 | 功能 |
|--------|------|
| `/` | 搜索文件 |
| `Ctrl+F` | 搜索文件内容 |

### 退出

| 快捷键 | 功能 |
|--------|------|
| `q` | 退出 superfile |
| `Esc` | 退出或取消操作 |

## 配置

### 配置文件位置

superfile 的配置文件位于：

- Linux: `~/.config/superfile/config.toml`
- macOS: `~/Library/Application Support/superfile/config.toml`
- Windows: `%APPDATA%\superfile\config.toml`

### 启用退出后切换目录

在配置文件中设置：

```toml
cd_on_quit = true
```

### 其他常用配置

```toml
# 自动检查更新（默认启用）
auto_check_update = true

# 显示隐藏文件
show_hidden = false

# 默认排序方式
sort_by = "name"  # name, size, modified, extension

# 预览设置
preview = true
preview_size = 5  # 预览窗口大小（行数）
```

## 高级技巧

### 1. 批量操作

1. 使用 `Space` 选择多个文件
2. 选择完成后执行操作（复制、移动、删除等）
3. 所有选中的文件会一起处理

### 2. 快速导航

- 使用 `~` 快速跳转到家目录
- 使用 `/` 快速跳转到根目录
- 使用路径输入快速跳转

### 3. 文件预览

- 启用预览窗口可以快速查看文件内容
- 支持文本文件、图片等格式
- 使用 `p` 切换预览窗口显示/隐藏

### 4. 搜索功能

- 使用 `/` 搜索文件名
- 使用 `Ctrl+F` 搜索文件内容
- 支持正则表达式搜索

### 5. 文件树视图

- 使用 `t` 切换文件树视图
- 可以快速浏览目录结构
- 方便在深层目录中导航

## 插件和主题

superfile 支持插件和主题系统，可以扩展功能和自定义外观。

### 安装插件

参考官方文档：https://github.com/yorukot/superfile/wiki/Plugins

### 安装主题

参考官方文档：https://github.com/yorukot/superfile/wiki/Themes

## Vim 模式

如果您是 vim/nvim 用户，建议使用 vim 版本的快捷键配置：

1. 查看官方 vim 快捷键配置
2. 修改配置文件使用 vim 快捷键

## 故障排除

### 问题 1: 退出后没有切换目录

**可能原因：**
- `cd_on_quit` 未启用
- `lastdir` 文件路径不正确

**解决方法：**
1. 检查配置文件中的 `cd_on_quit = true`
2. 检查 `lastdir` 文件是否存在：
   ```bash
   # Linux
   cat ~/.local/state/superfile/lastdir
   
   # macOS
   cat ~/Library/Application\ Support/superfile/lastdir
   ```

### 问题 2: 命令找不到

**解决方法：**
1. 检查 `~/.local/bin` 是否在 PATH 中
2. 运行 `source ~/.zshrc` 重新加载配置
3. 手动安装：`bash -c "$(curl -sLo- https://superfile.dev/install.sh)"`

### 问题 3: 自动安装失败

**解决方法：**
1. 检查网络连接
2. 手动下载安装脚本并运行
3. 检查 `~/.local/bin` 目录权限

## 与 yazi 的对比

| 特性 | superfile (spf) | yazi |
|------|----------------|------|
| 退出后切换目录 | ✓ 支持 | ✓ 支持 |
| 文件预览 | ✓ 支持 | ✓ 支持 |
| 插件系统 | ✓ 支持 | ✓ 支持 |
| 主题系统 | ✓ 支持 | ✓ 支持 |
| Vim 模式 | ✓ 支持 | ✓ 支持 |
| 异步操作 | ✓ 支持 | ✓ 支持 |

## 更多资源

- **官方仓库**: https://github.com/yorukot/superfile
- **官方网站**: https://superfile.dev
- **教程**: https://github.com/yorukot/superfile/wiki/Tutorial
- **快捷键文档**: https://github.com/yorukot/superfile/wiki/Hotkeys
- **配置文档**: https://github.com/yorukot/superfile/wiki/Config
- **插件文档**: https://github.com/yorukot/superfile/wiki/Plugins
- **主题文档**: https://github.com/yorukot/superfile/wiki/Themes
- **故障排除**: https://github.com/yorukot/superfile/wiki/Troubleshooting

## 使用示例

### 示例 1: 浏览并切换到目录

```bash
# 启动 superfile
spf

# 在 superfile 中：
# 1. 使用方向键导航到目标目录
# 2. 按 Enter 进入目录
# 3. 浏览文件
# 4. 按 q 退出

# 退出后，终端自动切换到 superfile 退出时的目录
```

### 示例 2: 从指定目录启动

```bash
# 从 Documents 目录启动
spf ~/Documents

# 浏览文件后退出，终端会停留在最后的目录
```

### 示例 3: 批量操作文件

```bash
spf

# 在 superfile 中：
# 1. 使用 Space 选择多个文件
# 2. 按 c 复制选中的文件
# 3. 导航到目标目录
# 4. 按 v 粘贴文件
# 5. 按 q 退出
```

## 提示

1. **首次使用**: 建议先查看帮助（按 `?`）了解所有快捷键
2. **Vim 用户**: 使用 vim 版本的快捷键配置会更熟悉
3. **性能**: superfile 使用异步操作，处理大目录时性能优秀
4. **更新**: superfile 会自动检查更新（可在配置中禁用）
5. **配置**: 根据个人习惯调整配置文件和快捷键

---

**最后更新**: 2025-01-XX

