# Yazi 插件配置

## 简介

本目录包含 Yazi 文件管理器的相关配置和工具脚本。

## 文件说明

### `update_flavors.sh` - 主题更新脚本

从 [yazi-rs/flavors](https://github.com/yazi-rs/flavors) 仓库克隆/更新所有主题到 `~/.dotfiles/config/yazi/flavors` 目录。

**功能：**
- 自动从 GitHub 克隆 flavors 仓库
- 检测并更新已存在的主题
- 安装新的主题
- 显示详细的更新统计信息

**使用方法：**

```bash
# 直接运行脚本
~/.dotfiles/plugins/yazi/update_flavors.sh

# 或者添加别名后使用
alias yazi:update-flavors='~/.dotfiles/plugins/yazi/update_flavors.sh'
yazi:update-flavors
```

**工作原理：**

1. 克隆 yazi-rs/flavors 仓库到临时目录（使用 `--depth 1` 仅克隆最新版本）
2. 查找所有 `.yazi` 格式的主题目录
3. 将每个主题目录复制到 `~/.dotfiles/config/yazi/flavors/`
4. 安装额外的主题仓库（如 kanagawa、flexoki-dark、synthwave84 等）
5. 如果主题已存在，先删除再复制（更新）
6. 自动清理临时文件
7. 显示更新统计信息

**额外主题支持：**

脚本支持从独立的 GitHub 仓库安装主题。当前已配置的额外主题：

- `kanagawa.yazi` - [dangooddd/kanagawa.yazi](https://github.com/dangooddd/kanagawa.yazi)
- `flexoki-dark.yazi` - [gosxrgxx/flexoki-dark.yazi](https://github.com/gosxrgxx/flexoki-dark.yazi)
- `synthwave84.yazi` - [Miuzarte/synthwave84.yazi](https://github.com/Miuzarte/synthwave84.yazi)

要添加更多额外主题，编辑脚本中的 `EXTRA_FLAVORS` 数组：

```bash
EXTRA_FLAVORS=(
    "https://github.com/user/repo.git|target-name.yazi"
)
```

格式：`仓库URL|目标目录名`

**输出示例：**

```
ℹ 正在从 GitHub 克隆/更新 flavors 仓库...
✓ 仓库克隆成功
ℹ 正在查找所有 flavor 主题...
ℹ 更新主题: catppuccin-mocha.yazi
✓   catppuccin-mocha.yazi
ℹ 安装新主题: tokyo-night.yazi
✓   tokyo-night.yazi

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Yazi Flavors 更新完成
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

✓ 总计: 20 个主题
✓ 新增: 5 个主题
✓ 更新: 15 个主题

ℹ 主题已安装到: /home/tetsuya/.dotfiles/config/yazi/flavors
ℹ 使用 'y' 命令启动 yazi 查看效果
```

## 可用主题

从 yazi-rs/flavors 仓库可以获取以下主题：

- **Catppuccin 系列**
  - `catppuccin-mocha.yazi` - Catppuccin Mocha（深色）
  - `catppuccin-latte.yazi` - Catppuccin Latte（浅色）
  - `catppuccin-macchiato.yazi` - Catppuccin Macchiato
  - `catppuccin-frappe.yazi` - Catppuccin Frappe

- **其他主题（来自 yazi-rs/flavors）**
  - `dracula.yazi` - Dracula
  - `tokyo-night.yazi` - Tokyo Night
  - `gruvbox-dark.yazi` - Gruvbox Dark
  - `flexoki-light.yazi` - Flexoki Light
  - `rose-pine.yazi` - Rose Pine
  - 更多主题请查看 [yazi-rs/flavors](https://github.com/yazi-rs/flavors) 仓库

- **额外主题（独立仓库）**
  - `kanagawa.yazi` - Kanagawa（来自 [dangooddd/kanagawa.yazi](https://github.com/dangooddd/kanagawa.yazi)）
  - `flexoki-dark.yazi` - Flexoki Dark（来自 [gosxrgxx/flexoki-dark.yazi](https://github.com/gosxrgxx/flexoki-dark.yazi)）
  - `synthwave84.yazi` - SynthWave '84（来自 [Miuzarte/synthwave84.yazi](https://github.com/Miuzarte/synthwave84.yazi)）

## 配置主题

### 方法 1: 使用 theme.toml

编辑 `~/.dotfiles/config/yazi/theme.toml`：

```toml
[flavor]
dark = "catppuccin-mocha"
light = "catppuccin-latte"
```

### 方法 2: 使用 yazi 包管理器（可选）

```bash
# 查看已安装的包
ya pkg list

# 安装主题（从 GitHub 仓库）
ya pkg add yazi-rs/flavors:catppuccin-mocha

# 注意：如果使用本地 flavors 目录（推荐），直接修改 theme.toml 即可
```

## 注意事项

1. **主题兼容性**: 请确保主题与您的 Yazi 版本兼容。查看 [yazi-rs/flavors](https://github.com/yazi-rs/flavors) 仓库了解兼容性信息。

2. **本地主题优先**: 如果 `~/.config/yazi/flavors/` 目录下有本地主题文件，Yazi 会自动识别并使用。

3. **更新频率**: 建议定期运行 `update_flavors.sh` 脚本以获取最新的主题更新。

4. **Git 依赖**: 脚本需要 `git` 命令，请确保已安装。

## 相关链接

- **Yazi 官方文档**: https://yazi-rs.github.io/
- **Flavors 仓库**: https://github.com/yazi-rs/flavors
- **Flavors 文档**: https://yazi-rs.github.io/docs/flavors/overview

---

**最后更新**: 2025-01-XX

