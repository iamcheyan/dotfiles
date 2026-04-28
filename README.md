# 🚀 Modern dotfiles Ecosystem (macOS & Linux)

一套经过极致调校、追求**瞬时启动**与**沉浸式体验**的现代化终端配置方案。基于 Zsh、Zinit 和 Rust 工具链构建，深度适配 Apple Silicon (M1/M2/M3) 及主流 Linux 发行版。

## 🌟 核心亮点

### 1. 极致性能 (Startup Speed)
- **`zsh-evalcache`**：通过静态缓存 `atuin`、`zoxide` 和 `direnv` 的初始化脚本，将终端启动延迟降至物理极限。
- **异步加载策略**：利用 Zinit 的 `wait` 标签，非核心插件在后台静默加载，确保 Prompt（提示符）瞬间出现，拒绝卡顿。

### 2. 沉浸式输入 (Vim Mode)
- **`zsh-vi-mode`**：同步加载，确保光标状态（插入模式为细线 `|`，正常模式为方块 `█`）在启动时立即生效。
- **智能初始化**：默认进入插入模式，配合 Atuin 实现 `↑` 键智能历史搜索。

### 3. 现代化工具链 (Rust-Powered)
通过 Alias 自动无感替换传统 Unix 命令，性能更强，体验更佳：
- `ls` → **`eza`** (带图标、Git 状态显示)
- `cat` → **`bat`** (带语法高亮、行号)
- `top` → **`btop`** (全屏交互式监控)
- `find` → **`fd`** (极速搜索)
- `du` → **`dust`** (直观目录分析)
- `history` → **`atuin`** (全屏可搜索的“第二大脑”)

### 4. 自动化管理 (Maintenance)
- **`git:init`**：一键初始化 Git 仓库并生成完善的 `.gitignore` 模板（预设单字过滤、AI 辅助文件过滤等）。
- **`sbzr`**：自动优化 Rime 词库权重（长度优先）并同步最新配置。
- **`init.sh`**：15 步全自动化安装脚本，覆盖从系统工具到字体、Neovim 及 Rime 的全流程。

## 🛠 插件系统架构

| 插件名称 | 加载方式 | 功能描述 |
| :--- | :--- | :--- |
| **zinit** | 核心 | 极速插件管理器 |
| **p10k** | 同步 | 顶级视觉主题 |
| **evalcache** | 同步 | 缓存 eval 初始化，消除启动延迟 |
| **zsh-vi-mode** | 同步 | 提供稳定的 Vim 仿真与光标控制 |
| **fzf-tab** | 异步 | 用 fzf 替换传统的补全菜单 |
| **fast-syntax-highlighting** | 异步 | 智能、高性能的命令高亮 |
| **zsh-autosuggestions** | 异步 | 基于历史记录的自动建议 |
| **colored-man-pages** | 异步 | 彩色增强版帮助手册 |
| **zsh-bd** | 异步 | `bd` 命令快速回退父目录 |

## 📦 安装与同步

### 首次安装
在仓库根目录下运行：
```bash
bash init.sh
```

### 日常同步
```bash
dotsync:pull   # 拉取远程更新
os:config      # 修改别名与配置
```

## ⌨️ 常用快捷键
- **`Ctrl + R`**：唤起 Atuin 全屏历史搜索。
- **`↑`**：在输入部分编码时按上方向键，按子串过滤历史。
- **`Ctrl + T` / `Alt + C`**：利用 fzf 快速找文件或切换目录。
- **`bd [dir]`**：快速跳回指定的父目录。

---
*本配置方案严格遵循 **No-Lua** 核心原则（Rime 部分），确保极致的响应速度与多端一致性。*
