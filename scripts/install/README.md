# `scripts/install/` - 安装脚本

此目录包含用于安装和配置各种工具和软件的脚本。

## 脚本列表

### 1. `install_font.sh` - 字体安装脚本

**功能：**
- 安装 Meslo 字体（Nerd Font，用于终端和编辑器）
- 安装 Noto Serif 字体（CJK 支持）

**用法：**
```bash
install:font              # 安装所有字体（Meslo + Noto）
install:font --meslo      # 只安装 Meslo
install:font --noto       # 只安装 Noto Serif
install:font --all        # 安装所有字体
install:font --force      # 强制重新安装
```

**别名：**
- `install:font` - 通过 `aliases.conf` 定义

**特点：**
- 自动检测操作系统（Linux/macOS）
- 支持交互式和非交互式模式
- 自动刷新字体缓存（Linux）
- 从 GitHub Releases 下载 Meslo 字体

---

### 2. `install_nvim.sh` - Neovim 安装脚本

**功能：**
- 从 GitHub Releases 下载并安装最新版本的 Neovim
- 支持 Linux 和 macOS
- 自动检测系统架构（x86_64、aarch64/arm64）

**用法：**
```bash
install:nvim                    # 安装最新版本
install:nvim --force            # 强制重新安装
install:nvim --version 0.9.5   # 安装指定版本
```

**别名：**
- `install:nvim` - 通过 `aliases.conf` 定义

**特点：**
- 自动检测操作系统和架构
- 自动获取最新版本号
- 安装到 `~/.local/bin/nvim`
- 支持版本检查和缓存
- 彩色输出和进度提示

**安装位置：**
- Linux/macOS: `~/.local/bin/nvim`
- 确保 `~/.local/bin` 在 PATH 中

**支持的平台：**
- Linux: x86_64, aarch64
- macOS: x86_64, arm64 (Apple Silicon)

---

### 3. `install_rime.sh` - Rime 输入法配置安装脚本

**功能：**
- 从 GitHub 克隆 Rime 输入法配置仓库
- 克隆到 `~/.dotfiles/rime`

**用法：**
```bash
install:rime           # 安装 Rime 配置
install:rime --force   # 强制重新克隆
```

**别名：**
- `install:rime` - 通过 `aliases.conf` 定义

**特点：**
- 检查目录是否已存在
- 支持 `--force` 参数强制重新克隆
- 交互式确认删除现有配置

**安装位置：**
- `~/.dotfiles/rime`

**后续步骤：**
安装后需要使用 `dotlink` 创建符号链接到：
- Linux (fcitx5): `~/.local/share/fcitx5/rime`
- Linux (ibus): `~/.config/ibus/rime`
- macOS: `~/Library/Rime`
- Windows: `%APPDATA%\Rime`

---

## 使用方式

### 通过别名（推荐）

所有安装脚本都通过 `aliases.conf` 定义了别名：

```bash
install:font    # 安装字体
install:nvim    # 安装 Neovim
install:rime    # 安装 Rime 配置
```

### 直接运行脚本

```bash
bash ~/.dotfiles/scripts/install/install_font.sh
bash ~/.dotfiles/scripts/install/install_nvim.sh
bash ~/.dotfiles/scripts/install/install_rime.sh
```

---

## 脚本特点

所有安装脚本都遵循以下设计原则：

1. **跨平台支持** - 自动检测操作系统和架构
2. **用户友好** - 彩色输出、进度提示、错误处理
3. **智能检测** - 检查已安装版本，避免重复安装
4. **交互式确认** - 关键操作前询问用户
5. **缓存支持** - 下载的文件会缓存，避免重复下载
6. **错误处理** - 完善的错误处理和提示

---

## 依赖要求

### 通用依赖
- `bash` - 所有脚本都需要
- `curl` 或 `wget` - 用于下载文件
- `git` - 用于克隆仓库（`install_rime.sh`）

### 特定依赖
- `install_font.sh`: `tar`, `unzip`, `fc-cache` (Linux)
- `install_nvim.sh`: `tar`
- `install_rime.sh`: `git`

---

## 故障排除

### 字体安装失败
- 检查网络连接
- 确保有足够的磁盘空间
- 检查 `~/.fonts` 或 `~/Library/Fonts` 目录权限

### Neovim 安装失败
- 检查网络连接
- 确保 `~/.local/bin` 目录存在且可写
- 验证系统架构是否支持

### Rime 配置克隆失败
- 检查网络连接
- 确保 Git 已安装
- 检查 `~/.dotfiles/rime` 目录权限

---

**最后更新**: 2025-01-XX

