# LazyVim 完整使用指南

## 📦 安装 Neovim

### ⚠️ 版本要求

**LazyVim 需要 Neovim 0.9.0 或更高版本！**

如果遇到 `module 'vim.uri' not found` 错误，说明 Neovim 版本太旧，需要升级。

检查当前版本：
```bash
nvim --version
```

### 方法 1: 使用安装脚本（推荐）

```bash
install:nvim
```

或者：

```bash
bash ~/.dotfiles/scripts/install/install_nvim.sh
```

**选项：**
- `--force` 或 `-f`: 强制重新安装
- `--version VERSION` 或 `-v VERSION`: 安装指定版本

**示例：**
```bash
install:nvim                    # 安装最新版本
install:nvim --force            # 强制重新安装
install:nvim --version 0.9.5   # 安装指定版本（最低 0.9.0）
```

### 方法 2: 使用包管理器

**macOS (Homebrew):**
```bash
brew install neovim
```

**Ubuntu/Debian:**
```bash
sudo apt-get install neovim
```

**Fedora/RHEL:**
```bash
sudo dnf install neovim
```

**Arch Linux:**
```bash
sudo pacman -S neovim
```

## ✅ 安装完成

您的 Neovim 已经成功配置为 LazyVim Starter！这是正确的配置方式。

## ⚠️ 故障排除

### 错误：`module 'vim.uri' not found` 或 `module 'vim.termcap' not found`

如果遇到这些错误，可能是以下原因：

1. **Neovim 版本问题**：
   - Neovim 0.11.x 是开发版本，可能存在一些兼容性问题
   - 建议使用稳定版本 0.9.x 或 0.10.x
   ```bash
   install:nvim --version 0.10.2  # 安装稳定版本
   ```

2. **运行时文件未正确安装（Linux 特有）**：
   - 从 GitHub Releases 下载的 Neovim 需要同时安装运行时文件
   - 检查运行时文件是否存在：
   ```bash
   ls -la ~/.local/share/nvim/runtime/
   ```
   - 如果不存在，重新安装（安装脚本会自动处理）：
   ```bash
   install:nvim --force
   ```

3. **PATH 问题**：
   - 确保使用的是新安装的版本
   ```bash
   which nvim  # 应该显示 ~/.local/bin/nvim
   nvim --version  # 检查版本
   ```

4. **macOS vs Linux 差异**：
   - **macOS**: 使用 Homebrew 安装的 Neovim 会自动处理运行时文件，通常不会有此问题
   - **Linux**: 从 GitHub Releases 下载的 Neovim 需要手动安装运行时文件到 `~/.local/share/nvim/`
   - 安装脚本会自动处理这个差异，但如果您手动安装，请确保同时复制 `share/nvim/runtime/` 目录

5. **LazyVim 配置问题**：
   - 尝试更新 LazyVim 到最新版本
   - 或者清理并重新安装 LazyVim
   ```bash
   rm -rf ~/.local/share/nvim/lazy ~/.cache/nvim
   nvim  # 重新启动，会自动重新安装
   ```

## 🚀 首次启动

### 1. 启动 Neovim

```bash
nvim
```

首次启动时，LazyVim 会自动：
- 下载并安装 LazyVim 框架
- 下载并安装所有必需的插件
- 配置 LSP 和 Treesitter
- 设置所有快捷键和功能

**请耐心等待安装完成（可能需要几分钟）**

### 2. 安装 LSP 服务器

LazyVim 使用 Mason 来管理语言服务器。启动 Neovim 后：

```vim
:Mason
```

在 Mason 界面中，您可以：
- 使用 `j/k` 上下移动
- 按 `i` 安装选中的 LSP 服务器
- 按 `X` 卸载
- 按 `?` 查看帮助

**推荐安装的 LSP 服务器：**
- `lua_ls` - Lua 语言支持
- `pyright` 或 `ruff_lsp` - Python 语言支持
- `typescript-language-server` - TypeScript/JavaScript 支持
- `gopls` - Go 语言支持
- `rust_analyzer` - Rust 语言支持

## ⌨️ 核心快捷键

### Leader 键

LazyVim 的 `<leader>` 键默认是 **空格键 (Space)**

### 文件操作

| 快捷键 | 功能 |
|--------|------|
| `<leader>ff` | 查找文件（模糊搜索） |
| `<leader>fr` | 最近打开的文件 |
| `<leader>fg` | 全文搜索（live grep） |
| `<leader>fb` | 查找已打开的缓冲区 |
| `<leader>fF` | 在当前工作目录查找文件 |
| `<leader>fG` | 在当前工作目录全文搜索 |

### 缓冲区操作

| 快捷键 | 功能 |
|--------|------|
| `<leader>bd` | 关闭当前缓冲区 |
| `<leader>bD` | 强制关闭当前缓冲区 |
| `<leader>bn` | 下一个缓冲区 |
| `<leader>bp` | 上一个缓冲区 |
| `]b` | 下一个缓冲区 |
| `[b` | 上一个缓冲区 |

### 代码导航

| 快捷键 | 功能 |
|--------|------|
| `gd` | 跳转到定义 |
| `gD` | 跳转到声明 |
| `K` | 显示函数文档（hover） |
| `<leader>ca` | 代码操作（code actions） |
| `<leader>cr` | 重命名符号 |
| `<leader>cs` | 显示符号信息 |
| `<leader>cd` | 显示诊断信息 |
| `]d` | 下一个诊断 |
| `[d` | 上一个诊断 |

### 文件树

| 快捷键 | 功能 |
|--------|------|
| `<leader>e` | 打开/关闭文件树 |
| `<leader>E` | 在当前文件位置打开文件树 |

在文件树中：
- `a` - 添加文件/目录
- `r` - 重命名
- `d` - 删除
- `x` - 剪切
- `c` - 复制
- `p` - 粘贴
- `y` - 复制路径
- `Y` - 复制相对路径

### 搜索和替换

| 快捷键 | 功能 |
|--------|------|
| `<leader>ss` | 搜索当前单词 |
| `<leader>sS` | 搜索当前单词（整个项目） |
| `<leader>sr` | 替换当前单词 |
| `<leader>sR` | 替换当前单词（整个项目） |

### Git 操作

| 快捷键 | 功能 |
|--------|------|
| `<leader>gg` | 打开 LazyGit |
| `<leader>gG` | 在浮动窗口中打开 LazyGit |
| `]h` | 下一个 Git hunk |
| `[h` | 上一个 Git hunk |
| `<leader>hr` | 重置 Git hunk |
| `<leader>hR` | 重置 Git buffer |
| `<leader>hs` | 暂存 Git hunk |
| `<leader>hS` | 暂存 Git buffer |

### 窗口操作

| 快捷键 | 功能 |
|--------|------|
| `<leader>ww` | 其他窗口 |
| `<leader>wd` | 删除窗口 |
| `<leader>w-` | 水平分割 |
| `<leader>w\|` | 垂直分割 |
| `<leader>w=` | 平衡窗口大小 |

### 标签页操作

| 快捷键 | 功能 |
|--------|------|
| `<leader>tt` | 新建标签页 |
| `<leader>tn` | 下一个标签页 |
| `<leader>tp` | 上一个标签页 |
| `<leader>tm` | 移动标签页 |
| `<leader>td` | 关闭标签页 |

### 其他常用快捷键

| 快捷键 | 功能 |
|--------|------|
| `<leader>q` | 退出 |
| `<leader>Q` | 强制退出 |
| `<leader>w` | 保存文件 |
| `<leader>u` | 撤销树（可视化撤销历史） |
| `<leader>l` | LazyVim 菜单 |
| `<leader>L` | LazyVim 命令 |
| `<leader>c` | 关闭浮动窗口 |
| `<Esc>` | 退出插入模式或关闭浮动窗口 |
| `<C-c>` | 退出插入模式 |

## 🎨 主题和外观

### 切换主题

```vim
:LazyExtras
```

选择 `ui` 类别，然后选择您喜欢的主题插件。

或者直接安装主题插件，例如：

```vim
:Lazy install tokyonight.nvim
```

### 内置主题

LazyVim 默认使用 `tokyonight` 主题。您可以在 `lua/config/` 目录中自定义主题。

## 🔧 自定义配置

### 配置文件结构

```
~/.config/nvim/
├── lua/
│   ├── config/          # 您的自定义配置
│   │   ├── keymaps.lua  # 自定义快捷键
│   │   ├── options.lua  # 自定义选项
│   │   └── autocmds.lua # 自定义自动命令
│   └── plugins/         # 自定义插件
│       └── example.lua  # 插件配置示例
└── init.lua            # 入口文件
```

### 添加自定义插件

在 `lua/plugins/` 目录下创建新文件，例如 `lua/plugins/myplugin.lua`：

```lua
return {
  {
    "用户名/仓库名",
    config = function()
      -- 插件配置
    end,
  },
}
```

保存后，LazyVim 会自动加载新插件。

### 自定义快捷键

编辑 `lua/config/keymaps.lua`：

```lua
return {
  -- 示例：添加自定义快捷键
  {
    "n",
    "<leader>xx",
    function()
      print("Hello from LazyVim!")
    end,
    { desc = "Custom command" },
  },
}
```

### 自定义选项

编辑 `lua/config/options.lua`：

```lua
return {
  -- 示例：修改选项
  opt = {
    number = true,        -- 显示行号
    relativenumber = true, -- 显示相对行号
  },
}
```

## 📦 插件管理

### 打开插件管理器

```vim
:Lazy
```

在 Lazy 界面中：
- `j/k` - 上下移动
- `i` - 安装插件
- `u` - 更新插件
- `X` - 卸载插件
- `c` - 清理未使用的插件
- `s` - 同步插件
- `?` - 查看帮助

### 安装插件

1. 在 `lua/plugins/` 中添加插件配置
2. 保存文件
3. 运行 `:Lazy sync` 或等待自动同步

### 更新插件

```vim
:Lazy update
```

### 查看插件状态

```vim
:Lazy health
```

## 🛠️ 语言支持

### 启用语言支持

LazyVim 支持多种编程语言。启用方式：

```vim
:LazyExtras
```

选择 `lang` 类别，然后选择您需要的语言。

### 已支持的语言

- Python
- JavaScript/TypeScript
- Go
- Rust
- Java
- C/C++
- Lua
- 以及更多...

## 🐛 故障排除

### 插件未加载

1. 检查插件配置是否正确
2. 运行 `:Lazy` 查看插件状态
3. 运行 `:Lazy sync` 同步插件

### LSP 不工作

1. 运行 `:Mason` 确保 LSP 服务器已安装
2. 运行 `:LspInfo` 查看 LSP 状态
3. 运行 `:checkhealth` 检查健康状态

### 性能问题

1. 运行 `:Lazy profile` 查看插件加载时间
2. 禁用不需要的插件
3. 运行 `:Lazy clean` 清理未使用的插件

### 重置配置

如果需要重置到默认状态：

```bash
rm -rf ~/.local/share/nvim
rm -rf ~/.local/state/nvim
rm -rf ~/.cache/nvim
```

然后重新启动 Neovim。

## 📚 更多资源

- **官方文档**: https://lazyvim.github.io
- **GitHub Starter**: https://github.com/LazyVim/starter
- **GitHub LazyVim**: https://github.com/LazyVim/LazyVim
- **快捷键帮助**: 在 Neovim 中按 `<leader>?` 或运行 `:help lazyvim`

## 💡 提示

1. **使用 `<leader>?`** 查看所有可用快捷键
2. **使用 `:LazyExtras`** 浏览和安装额外功能
3. **使用 `:Mason`** 管理 LSP 服务器和工具
4. **使用 `:Telescope`** 快速查找任何内容
5. **使用 `<leader>l`** 打开 LazyVim 菜单

## 🎉 开始使用

现在您可以：

1. 启动 Neovim: `nvim`
2. 等待插件安装完成
3. 运行 `:Mason` 安装需要的 LSP 服务器
4. 开始编码！

享受 LazyVim 带来的强大功能！


