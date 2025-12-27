# Scripts 目录说明

## 目录结构

```
scripts/
├── utils/     # 通用工具脚本
├── dev/       # 开发相关脚本
├── install/  # 安装脚本
└── system/    # 系统管理脚本
```

### `scripts/utils/` - 通用工具脚本
**特点：**
- ✅ 单功能、轻量级（通常 < 100 行）
- ✅ 通用性强，不依赖特定环境
- ✅ 可独立使用，无复杂依赖
- ✅ 跨平台兼容性好

**当前脚本：**
- `extract.sh` - 通用解压（支持多种格式）
- `url_encode.sh` - URL 编码
- `url_decode.sh` - URL 解码
- `random_string.sh` - 随机字符串生成

### `scripts/dev/` - 开发相关脚本
**特点：**
- 开发工作流相关
- Git 操作、项目管理等

**当前脚本：**
- `git_clean.sh` - Git 清理未跟踪文件
- `push_dotfiles.sh` - Dotfiles 推送工具（自动包含 IP、设备名、时间戳）

### `scripts/install/` - 安装脚本
**特点：**
- 用于安装和配置各种工具和软件
- 从 GitHub Releases 或其他源下载并安装

**当前脚本：**
- `install_font.sh` - 安装字体（Meslo、Noto Serif）
- `install_nvim.sh` - 安装 Neovim（从 GitHub Releases）
- `install_rime.sh` - 安装 Rime 输入法配置（从 GitHub 克隆）

### `scripts/system/` - 系统管理脚本
**特点：**
- 系统配置、维护相关
- 备份、磁盘管理、端口检查等

**当前脚本：**
- `backup_config.sh` - 备份配置文件（带时间戳）
- `disk_usage.sh` - 磁盘使用情况查看
- `find_large_files.sh` - 查找大文件
- `port_check.sh` - 端口占用检查

---

## 与 `tools/` 目录的区别

### `tools/` - 专业工具和工作流脚本
**特点：**
- ⚙️ 复杂工具（通常 > 100 行）
- ⚙️ 特定用途（WSL、Rime、VirtualBox、Wine）
- ⚙️ 工作流自动化
- ⚙️ 可能有交互式菜单
- ⚙️ 环境特定（如 WSL、特定系统配置）

**示例：**
- `easygit.sh` - Git 仓库管理工具（有菜单）
- `VirtualBox.sh` - VirtualBox 虚拟机管理
- `sbzr.sh` - Rime 输入法配置
- `repo_size.sh` - 仓库大小分析（复杂逻辑）
- `open_windows_folder.sh` - WSL 特定功能

---

## 区分原则

| 维度 | `scripts/utils/` | `tools/` |
|------|-----------------|----------|
| **复杂度** | 简单（< 100 行） | 复杂（> 100 行） |
| **用途** | 通用工具 | 专业工具/工作流 |
| **依赖** | 最小依赖 | 可能有特定环境依赖 |
| **交互** | 命令行参数 | 可能有交互式菜单 |
| **平台** | 跨平台 | 可能平台特定 |
| **维护** | 低维护成本 | 可能需要持续维护 |

---

## 迁移建议

如果发现重叠，建议：
1. **保留更通用的版本** → `scripts/utils/`
2. **保留特定用途的版本** → `tools/`
3. **合并功能** → 如果功能可以合并，保留更完善的版本

### 示例对比

| 工具 | 位置 | 特点 |
|------|------|------|
| `extract.sh` | `scripts/utils/` | 单文件解压，支持多种格式 |
| `unzip_here.sh` | `tools/` | 批量递归解压所有 .zip |
| `git_clean.sh` | `scripts/dev/` | 简单 Git 清理 |
| `easygit.sh` | `tools/` | 完整 Git 工作流管理 |

两者可以共存，因为用途不同。

