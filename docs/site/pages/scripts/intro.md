> 摘要：哪些脚本是本仓库自研的，哪些是上游工具的安装器，各自的边界在哪。

# 本章导读

## 两类脚本

`scripts/` 和 `tools/` 下的内容分两类：

**自研**——本仓库为解决具体问题写的：

| 脚本 | 作用 |
|---|---|
| `dotlink/dotlink` | 软链接管理器 |
| `init.sh` | 跨平台初始化 |
| `scripts/update_nvim.sh` | Neovim 稳定版升级 |
| `plugins/fzf/fzf.zsh` 里的 `f` / `ffd` | 文件搜索函数 |
| `plugins/sshfs/vssh.sh` | SSH 主机选择与连接 |
| `plugins/sshfs/vifm-sshfs.sh` | SSHFS 挂载 + Vifm |
| `tools/packtar.sh` | 按 gitignore 打包 |
| `tools/unzip_here.sh` 等 | 批量解压 |
| `scripts/setup/setup_fnm.sh` | fnm 惰性加载 |
| `scripts/tmux-new` | tmux 会话恢复 |
| `scripts/tmux-clipboard-copy` | 跨平台剪贴板复制（WSL/Wayland/X11/macOS） |

**上游安装器**——包装第三方工具的安装流程：

| 脚本 | 安装什么 |
|---|---|
| `scripts/install/install_font.sh` | Meslo + Noto Serif CJK |
| `scripts/install/install_nvim.sh` | Neovim 本体 |
| `scripts/install/install_httpie.sh` | HTTPie |
| `scripts/install/install_zellij.sh` | Zellij |

## 阅读顺序

1. [dotlink](dotlink.html) — 所有配置部署的基础，先理解它。
2. [init.sh](init.html) — 完整安装流程。
3. [Neovim 安装器](nvim-install.html) 与 [nvim-update](nvim-update.html) — 编辑器相关。
4. 其余安装器按需查阅。
5. [SSH 与 SSHFS](ssh.html)、[归档工具](archives.html) 是日常高频脚本。
6. [清理与系统脚本](cleanup.html) 涉及破坏性操作，读清楚再用。

## 共同设计原则

所有脚本遵循几条规则：

| 原则 | 体现 |
|---|---|
| 探测后执行 | `command -v` 判断依赖，缺失时给提示而非崩溃 |
| 跨平台 | 区分 Linux/macOS/WSL，架构分 x86_64/aarch64 |
| 可回退 | 安装失败时保留旧版本，不破坏现有环境 |
| 不静默覆盖 | 覆盖前备份或提示 |
| 校验下载 | Neovim 更新校验 SHA-256 |

例外也有：`init.sh` 的未知参数会被静默跳过，`tools/clear.sh` 直接执行清理不做确认。这两处在各自文档里明确标注。

## 修改脚本前

```bash
bash -n <script>        # 语法检查
shellcheck <script>     # 静态分析（如果装了）
```

涉及 `sudo`、`rm -rf`、`kill` 的脚本，先在容器或临时目录测试。
