# Tools 工具文档

专业工具和工作流脚本目录，包含复杂、特定用途的工具。

## 目录说明

这些工具通常是复杂脚本（通常 > 100 行），具有以下特点：
- 复杂工具，包含多个功能
- 特定用途（WSL、Rime、VirtualBox、Wine 等）
- 工作流自动化
- 可能有交互式菜单
- 环境特定（如 WSL、特定系统配置）

---

## 工具列表

### 1. `easygit.sh` - Git 仓库管理工具

**功能**：提供完整的 Git 仓库管理功能，包括初始化、推送、拉取、强制操作等。

**主要功能**：
- 初始化新仓库并推送到 GitHub（可选择公开/私有）
- 设置/更新远程仓库地址
- 普通推送和拉取
- 强制推送和拉取（覆盖远程/本地）
- 显示仓库信息

**用法**：
```bash
easygit init                    # 初始化并推送新仓库
easygit set-remote <URL>        # 设置远程仓库
easygit push                    # 普通推送
easygit pull                    # 普通拉取
easygit force-push              # 强制推送覆盖远程
easygit force-pull              # 强制拉取覆盖本地
easygit info                    # 显示仓库信息
easygit help                    # 显示帮助
```

**别名**：`easygit`, `git:init`

**依赖**：
- Git
- GitHub CLI (`gh`)（用于创建仓库，可选）

**特点**：
- 交互式菜单
- 自动检测 GitHub CLI 可用性
- 支持公开/私有仓库选择
- 彩色输出

---

### 2. `repo_size.sh` - 仓库大小分析工具

**功能**：显示 Git 仓库的真实大小，排除 `.gitignore` 和 `.git` 等文件。

**主要功能**：
- 读取 `.gitignore` 文件并排除匹配的文件
- 排除 `.git` 目录和其他 Git 相关文件
- 可选：排除子 Git 仓库
- 计算并显示目录的真实大小
- 彩色输出，显示详细统计信息

**用法**：
```bash
repo:size                           # 分析当前目录
repo:size /path/to/dir              # 分析指定目录
repo:size --exclude-subrepos        # 排除子仓库
repo:size -e                        # 排除子仓库（简写）
```

**别名**：`repo:size`

**依赖**：
- Git
- `du` 命令

**特点**：
- 智能排除 `.gitignore` 规则
- 支持子仓库排除
- 详细的统计信息输出
- 彩色格式化输出

---

### 3. `packtar.sh` - 目录打包工具

**功能**：将当前目录打包为 `tar.gz` 文件，并放置到父目录。

**主要功能**：
- 打包当前目录为 `tar.gz`
- 支持 `.tar-exclude` 文件排除特定文件/目录
- 输出到父目录
- 显示打包进度

**用法**：
```bash
packtar myarchive                  # 打包为 myarchive.tar.gz
packtar backup-$(date +%Y%m%d)    # 使用日期命名
```

**别名**：`packtar`, `sh:packtar`

**依赖**：
- `tar` 命令

**特点**：
- 自动排除 `.tar-exclude` 文件中列出的内容
- 输出到父目录，避免包含自身
- 支持自定义文件名

**`.tar-exclude` 文件示例**：
```
node_modules/
.git/
*.log
.DS_Store
```

---

### 4. `unzip_here.sh` - 批量解压工具

**功能**：递归查找当前目录下的所有 `.zip` 文件并自动解压。

**主要功能**：
- 递归查找所有 `.zip` 文件
- 自动解压到文件所在目录
- 不覆盖已存在的文件（`-n` 选项）
- 显示解压进度

**用法**：
```bash
unzip:here                         # 解压当前目录下所有 .zip
sh:unzip                           # 同上
```

**别名**：`unzip:here`, `sh:unzip`, `sh:unzip_here`

**依赖**：
- `unzip` 命令
- `find` 命令

**特点**：
- 批量处理，无需手动指定文件
- 递归查找子目录
- 安全解压（不覆盖已存在文件）

**与 `extract.sh` 的区别**：
- `extract.sh`：单文件解压，支持多种格式
- `unzip_here.sh`：批量递归解压所有 `.zip` 文件

---

### 5. `jp_convert.sh` - 日语转换工具

**功能**：将日语文本转换为平假名、片假名、罗马字。

**主要功能**：
- 日语 → 平假名（ひらがな）
- 日语 → 片假名（カタカナ）
- 日语 → 罗马字（ローマ字）
- 支持参数输入、管道输入、交互式输入

**用法**：
```bash
# 参数输入
jp "日本語のテキスト"

# 管道输入
echo "日本語のテキスト" | jp

# 交互式输入
jp
```

**别名**：`jp`, `sh:jp_convert`

**依赖**：
- Python 3
- `pykakasi` 库（`pip install pykakasi`）

**示例**：
```bash
$ jp "日本語"
平假名: にほんご
片假名: ニホンゴ
罗马字: nihongo
```

---

### 6. `sbzr.sh` - Rime 输入法配置工具

**功能**：初始化/同步 Rime 输入法配置并更新日语词库。

**主要功能**：
- 检查 Rime 配置目录是否为空
- 如果为空，从 GitHub 拉取配置
- 更新日语词库（jaroomaji）
- 显示配置状态

**用法**：
```bash
sbzr                              # 初始化/同步 Rime 配置
```

**别名**：`sbzr`

**依赖**：
- Git
- Rime 输入法

**配置目录**：`~/.dotfiles/config/rime`

**Git 仓库**：`https://github.com/iamcheyan/rime.git`

**特点**：
- 自动检测配置目录状态
- 自动拉取最新配置
- 自动更新日语词库
- 彩色输出

---

### 7. `VirtualBox.sh` - VirtualBox 虚拟机管理工具

**功能**：管理 VirtualBox 虚拟机的启动、导出、保存等操作。

**主要功能**：
- 启动 Windows 11 虚拟机（headless 模式）
- 导出所有虚拟机
- 保存所有运行中虚拟机的状态
- 关闭 VirtualBox 管理器

**用法**：
```bash
vbox start                        # 启动 Windows 11 虚拟机
vbox export                       # 导出所有虚拟机
vbox save                         # 保存所有运行中虚拟机的状态
vbox close                        # 关闭 VirtualBox 管理器
vbox help                         # 显示帮助
```

**别名**：`vbox`

**依赖**：
- VirtualBox
- `VBoxManage` 命令
- `sudo` 权限（用于以特定用户运行）

**特点**：
- 针对特定虚拟机（Windows 11）优化
- 自动处理内存不足错误
- 支持 headless 模式启动

---

### 8. `remove_zone_identifier.sh` - Zone.Identifier 清理工具

**功能**：查找并删除 Windows 下载文件中的 `Zone.Identifier` 文件。

**主要功能**：
- 递归查找 `Zone.Identifier` 文件（包括 `:Zone.Identifier` 和 `zone.identifier`）
- 交互式确认删除
- 显示找到的文件列表
- 安全删除（需要确认）

**用法**：
```bash
zone:remove                       # 删除当前目录下的 Zone.Identifier 文件
sh:remove_zone_identifier          # 同上
```

**别名**：`zone:remove`, `sh:remove_zone_identifier`

**依赖**：
- `find` 命令

**特点**：
- 安全删除（需要用户确认）
- 支持多种 Zone.Identifier 文件命名格式
- 递归查找子目录

**适用场景**：
- 从 Windows 下载到 Linux 的文件
- WSL 环境中的文件清理

---

### 9. `open_windows_folder.sh` - WSL Windows 文件夹打开工具

**功能**：在 WSL 环境中使用 Windows 的 `explorer.exe` 打开文件夹。

**主要功能**：
- 将 WSL 路径转换为 Windows 路径
- 使用 Windows Explorer 打开文件夹
- 支持当前目录和指定路径

**用法**：
```bash
win:open                          # 打开当前目录
win:open /path/to/folder          # 打开指定目录
sh:open_windows_folder             # 同上
```

**别名**：`win:open`, `sh:open_windows_folder`

**依赖**：
- WSL 环境
- `wslpath` 命令
- Windows `explorer.exe`

**特点**：
- 自动路径转换
- 支持相对路径和绝对路径
- WSL 专用工具

---

### 10. `run_wine.sh` - Wine 运行工具

**功能**：智能检测并运行 Wine，支持 Flatpak 和系统安装版本。

**主要功能**：
- 自动检测 Wine 安装方式（Flatpak 或系统安装）
- 自动安装 Wine（如未安装）
- 支持 Silverblue/Kinoite 系统
- 运行 Windows 程序

**用法**：
```bash
wine program.exe                   # 运行 Windows 程序
wine /path/to/program.exe          # 运行指定路径的程序
```

**别名**：`wine`

**依赖**：
- Wine（Flatpak 或系统安装）
- `flatpak`（如使用 Flatpak 版本）

**特点**：
- 自动检测和安装
- 支持多种 Wine 安装方式
- 针对 Silverblue/Kinoite 优化

---

### 11. `winetricks.sh` - Winetricks 工具

**功能**：智能运行 Winetricks，支持 Flatpak 和系统安装版本。

**主要功能**：
- 自动检测 Winetricks 安装方式
- 自动安装 Winetricks（如未安装）
- 支持 Silverblue/Kinoite 系统（使用 toolbox）
- 运行 Winetricks 命令

**用法**：
```bash
winetricks <command>              # 运行 winetricks 命令
winetricks corefonts              # 安装核心字体
winetricks vcrun2019             # 安装 Visual C++ 2019
```

**别名**：`winetricks`

**依赖**：
- Winetricks（Flatpak 或系统安装）
- `flatpak` 或 `toolbox`（根据系统）

**特点**：
- 自动检测和安装
- 支持多种安装方式
- 针对 Silverblue/Kinoite 优化（使用 toolbox 容器）

---

## 工具分类

### Git 相关
- `easygit.sh` - Git 仓库管理
- `repo_size.sh` - 仓库大小分析

### 文件操作
- `packtar.sh` - 目录打包
- `unzip_here.sh` - 批量解压

### 系统工具
- `VirtualBox.sh` - 虚拟机管理
- `remove_zone_identifier.sh` - 文件清理
- `open_windows_folder.sh` - WSL 工具

### 开发工具
- `jp_convert.sh` - 日语转换
- `sbzr.sh` - 输入法配置

### Windows 兼容
- `run_wine.sh` - Wine 运行
- `winetricks.sh` - Winetricks 工具

---

## 使用建议

### 何时使用这些工具

- **easygit.sh**：需要完整的 Git 工作流管理时
- **repo_size.sh**：需要分析仓库真实大小时
- **packtar.sh**：需要打包目录时
- **unzip_here.sh**：需要批量解压多个 zip 文件时
- **jp_convert.sh**：需要日语文本转换时
- **sbzr.sh**：需要管理 Rime 输入法配置时
- **VirtualBox.sh**：需要管理虚拟机时
- **remove_zone_identifier.sh**：需要清理 Windows 下载标记时
- **open_windows_folder.sh**：在 WSL 中需要打开 Windows 文件夹时
- **run_wine.sh** / **winetricks.sh**：需要运行 Windows 程序时

### 与其他工具的区别

这些工具与 `scripts/utils/` 目录中的工具区别在于：

| 特性 | `tools/` | `scripts/utils/` |
|------|----------|-----------------|
| 复杂度 | 复杂（> 100 行） | 简单（< 100 行） |
| 功能 | 多功能/工作流 | 单功能 |
| 依赖 | 可能有特定环境依赖 | 最小依赖 |
| 平台 | 可能平台特定 | 跨平台 |
| 交互 | 可能有交互式菜单 | 命令行参数 |

---

## 添加新工具

添加新工具到 `tools/` 时，请遵循以下原则：

1. **复杂功能**：工具应包含多个功能或复杂逻辑
2. **特定用途**：针对特定环境或工作流
3. **文档化**：在脚本头部添加清晰的注释和使用说明
4. **别名**：在 `aliases.conf` 中添加对应的别名
5. **错误处理**：包含完善的错误处理和用户提示

---

## 相关文档

- [主 README](../README.md) - 整体目录结构说明
- [Scripts Utils README](../scripts/utils/README.md) - 通用工具文档
- [Scripts README](../scripts/README.md) - Scripts 目录详细说明

