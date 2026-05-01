# OmnySSH 使用文档

## 简介

OmnySSH 是一个 TUI SSH 仪表盘和服务器管理工具，可以从单个终端窗口管理所有服务器。

## 安装

二进制文件已安装在 `~/.local/bin/omny`

首次运行前需要配置配置文件链接:

```bash
ln -sf ~/dotfiles/omnyssh/config.toml ~/.config/omnyssh/config.toml
ln -sf ~/dotfiles/omnyssh/hosts.toml ~/.config/omnyssh/hosts.toml
ln -sf ~/dotfiles/omnyssh/snippets.toml ~/.config/omnyssh/snippets.toml
```

或直接运行 `~/dotfiles/scripts/install/install_omnyssh.sh`

## 使用

### 启动

```bash
omny
# 或指定主题
omny --theme dracula
omny --theme nord
omny --theme gruvbox
```

### 快捷键

| 按键 | 功能 |
|------|------|
| `1` | 仪表盘（实时监控） |
| `2` | 文件管理器（SFTP） |
| `3` | 代码片段（保存的命令） |
| `4` | 终端（多会话） |
| `/` | 模糊搜索 |
| `a` | 添加服务器 |
| `Enter` | 连接选中的服务器 |
| `q` | 退出 |

## 配置文件

配置文件位于 `~/.config/omnyssh/`:

- `config.toml` - 应用设置、主题、快捷键
- `hosts.toml` - 服务器列表
- `snippets.toml` - 保存的命令

### hosts.toml 示例

```toml
[[hosts]]
name = "my-server"
hostname = "server.example.internal"
user = "deploy"
port = 22
identity_file = "~/.ssh/id_ed25519"
tags = ["production", "web"]
notes = "Web 服务器"
```

### snippets.toml 示例

```toml
[[snippets]]
name = "Docker 重启"
command = "cd /opt/app && docker compose down && docker compose up -d"
scope = "global"
tags = ["docker"]
```

## 主题

可选主题: `default`, `dracula`, `nord`, `gruvbox`

可通过 `config.toml` 或 `--theme` 参数设置。
