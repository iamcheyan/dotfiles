> 摘要：nano 与 Herdr 两个较小配置的边界与部署方式。

# nano 与 Herdr

三个配置文件体量小，或只部分部署，放在一起说明。

## nano

### 位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/nano/nanorc` |
| 部署目标 | `~/.nanorc` |
| 是否自动链接 | 是 |

### 用途

Nano 的语法高亮和默认选项。适合在没有 Vim 的环境里应急编辑。

### 注意

`~/.nanorc` 会被 Nano 读取，如果文件里有语法错误，Nano 会报错但通常仍能启动。

本仓库的 `nanorc` 内容较短，主要是语法高亮包含和少量默认项。

Nano 标题栏用蓝底黄字，状态栏用青色，选区和行号沿用 Neovim Blue 的蓝／青色强调。

### 验证

```bash
nano --version
nano /tmp/test.txt
```

### 排错

**Nano 启动报语法错误**：`nanorc` 里有不兼容当前 Nano 版本的指令。注释掉对应行。

**没有语法高亮**：`include` 路径不对，或 Nano 编译时没启用语法支持。

## Herdr

### 位置

| 项目 | 路径 |
|---|---|
| 仓库源文件 | `config/herdr/config.toml` |
| 部署目标 | `~/.config/herdr/config.toml` |
| 是否自动链接 | 是 |

### 用途

Herdr 是一个本地 AI 编程助手，`init.sh` 会通过官方脚本安装：

```bash
curl -fsSL https://herdr.dev/install.sh | sh
```

配置是 TOML 格式，本仓库提供一个基础主题配置。

Herdr 面板背景、青色强调色和绿色提示色与 Neovim Blue / Nostalgia 配色一致。

### 边界

Herdr 的 API key、provider 配置属于私有内容，**不在这里**。公开配置只包含界面和通用选项。

### 验证

```bash
herdr --version
ls -l ~/.config/herdr/config.toml
```

### 排错

**配置不生效**：确认 Herdr 读的是这个路径。

**认证失败**：key 不在公开配置里，需要自己在私有配置或环境变量里提供。
