> 摘要：miru 是用 Go 写的终端文件查看器，Markdown 走 glamour，源码与配置文件走 chroma，按 b 在浏览器里打开带 mermaid 的 HTML 预览。

# miru

## 用途

`miru` 是一个终端文件查看器，把两种场景合并成一个命令：

- **Markdown** — TUI 里用 glamour 渲染 ANSI，按 `b` 在浏览器里打开 goldmark 生成的 HTML 页面，支持 mermaid 图表。
- **源码 / 配置文件** — TUI 里用 chroma 做语法高亮，带行号；按 `b` 在浏览器里打开深色主题的 HTML 页面。

本仓库用它作为 `bat` / `glow` 之外的第三种查看器：需要看 Markdown 里的 mermaid 图，或者需要在浏览器里看源码时用 `miru`。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `hiro4ta/miru`（Go，MIT） |
| 安装器 | `scripts/install/install_miru.sh` |
| 二进制 | 静态二进制，无 Go 工具链依赖 |
| 配置 | `~/.config/miru/config.json`（仅 theme 字段） |

```bash
# 一键安装
bash scripts/install/install_miru.sh

# 或直接用上游 bootstrap
curl -fsSL https://raw.githubusercontent.com/hir4ta/miru/main/install.sh | sh

# 或 Homebrew
brew install hir4ta/tap/miru

# 或 go install
go install github.com/hir4ta/miru/cmd/miru@latest
```

安装器会下载对应平台的 tarball，校验 SHA-256，然后调用 `miru install`（Bubble Tea 自安装 UI）把二进制装到 `~/.local/bin` 并把 PATH 写进 shell rc。

## 基本用法

```bash
miru README.md           # Markdown（glamour）
miru main.go             # 源码（chroma + 行号）
miru config.yaml         # 配置文件（chroma）
miru Dockerfile          # 按文件名识别类型（chroma）
miru --theme gruvbox README.md
miru --list-themes
miru version
```

扩展名决定走哪条路径：`.md` / `.markdown` → Markdown；其余 → Source/Config。

## 交互键位

| 键 | 作用 |
|---|---|
| `j` / `k` | 向下 / 向上滚动一行 |
| `Ctrl+d` / `Ctrl+u` | 半页滚动 |
| `g` / `G` | 顶部 / 底部 |
| `{` / `}` | 跳到上一个 / 下一个标题（仅 Markdown） |
| `b` | 在浏览器打开 |
| `s` | 设置（主题选择器） |
| `?` | 帮助 |
| `q` | 退出 |

## 浏览器预览（b）

按 `b` 启动一个 loopback HTTP 服务器（`127.0.0.1:<random>`），作用域是文件所在项目的根目录（向上找到 `.git`、`go.mod`、`package.json`、`Cargo.toml`、`pyproject.toml` 之一；找不到就用文件自身目录），在默认浏览器里打开渲染后的页面。TUI 退出时服务器自动停止。

三种渲染：

| 类型 | 渲染方式 |
|---|---|
| Markdown | goldmark + GFM，github-markdown.css，mermaid.js（CDN） |
| 源码/配置 | chroma 带行号，深色主题 |
| 图片/二进制 | 原样服务，带正确 Content-Type |

相对链接（如 `[guide](./docs/guide.md)`）会被跟踪，点击后重新渲染目标文件。

**安全注意**：Markdown 里允许 raw HTML，mermaid 用 `securityLevel: "loose"`，和 Obsidian / VS Code 预览一致。未信任的 Markdown 不要用 `b` 打开。TUI 视图本身是纯 ANSI 文本，无脚本、无远程请求。

## 主题

6 种主题：

| 主题 | 风格 |
|---|---|
| `claude`（默认） | 暖米色 + 珊瑚色 + 金色 |
| `gruvbox` | 复古暖黄/橙，深棕底 |
| `everforest` | 森林绿 + 暗土色 |
| `nord` | 北极蓝/灰，极简 |
| `dracula` | 经典紫/粉/青 |
| `tokyo-night` | 深蓝赛博朋克 |

TUI 里按 `s` 打开主题选择器，选择立即生效并写入配置文件。

优先级：

```text
--theme flag  >  $MIRU_THEME 环境变量  >  配置文件  >  claude
```

配置文件 `~/.config/miru/config.json`：

```json
{
  "theme": "gruvbox"
}
```

## 更新

```bash
miru update                 # 替换当前二进制为最新 release
miru update --help
```

更新器会下载 tarball、对照 `checksums.txt` 校验 SHA-256，再原子替换二进制。

## 卸载

```bash
rm "$(command -v miru)"
rm -rf ~/.config/miru
# bootstrap 安装器在 shell rc 里加了 "# added by miru installer" 的 PATH 行，
# 手动删掉那一块。
```

Homebrew 安装：`brew uninstall miru && brew untap hir4ta/tap`。

## 与 bat / glow 的分工

| | bat | glow | miru |
|---|---|---|---|
| Markdown | 语法高亮 | 终端渲染 | TUI glamour + 浏览器 HTML + mermaid |
| 源码 | 语法高亮 | 不支持 | chroma + 行号 + 浏览器预览 |
| 交互 | 无 | 无 | 滚动、跳转、主题切换、浏览器打开 |
| 依赖 | 无 | 无 | 无（静态二进制） |

`bat` 适合快速看文件内容，`glow` 适合终端里读 Markdown，`miru` 适合需要跳转、主题切换或浏览器预览时。

## 排错

- `miru: command not found` — Zinit / 安装器没装。`command -v miru` 确认，或直接跑 bootstrap。
- 图片 / mermaid 不显示 — 浏览器里开 DevTools 看 CSP / 网络。miru 的 CSP 是 per-render nonce，脚本只允许 nonce + strict-dynamic。
- 主题不生效 — 优先级链检查：`--theme` > `$MIRU_THEME` > 配置文件 > `claude`。
- `miru update` 失败 — 网络问题或 checksum 不匹配。`miru update --help` 查看选项。
- 配置文件路径 — `$XDG_CONFIG_HOME/miru/config.json` 或 `~/.config/miru/config.json`。

## 参考

- 上游仓库：[github.com/hir4ta/miru](https://github.com/hir4ta/miru)
- 安全模型：[SECURITY.md](https://github.com/hir4ta/miru/blob/main/SECURITY.md)
- 隐私：[PRIVACY.md](https://github.com/hir4ta/miru/blob/main/PRIVACY.md)
