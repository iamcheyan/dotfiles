> 摘要：nano、Herdr、Yazi 三个较小配置的边界与部署方式。

# nano、Herdr 与 Yazi

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

## Yazi

### 位置

| 项目 | 路径 |
|---|---|
| 仓库内容 | `config/yazi/flavors/kanagawa.yazi/` |
| 部署目标 | 无（未列入 dotlink） |
| 是否自动链接 | **否** |

### 内容

只有一个 flavor：

```text
kanagawa.yazi/
├── flavor.toml
├── tmtheme.xml
├── LICENSE
├── LICENSE-tmtheme
└── preview.png
```

它是 Kanagawa 配色的 Yazi 主题，本身是一个嵌套的 git 仓库。

### 为什么只有 flavor

Yazi 主配置（`yazi.toml`、`keymap.toml`、`theme.toml`）通常包含个人路径、常用目录、私有预览命令。这些属于私有配置边界。

Flavor 是纯样式文件，可以安全分享。

### 手动使用

```bash
mkdir -p ~/.config/yazi/flavors
ln -s ~/dotfiles/config/yazi/flavors/kanagawa.yazi ~/.config/yazi/flavors/kanagawa.yazi
```

然后在 `~/.config/yazi/theme.toml`：

```toml
[flavor]
dark = "kanagawa"
light = "kanagawa"
```

### 排错

**flavor 不生效**：确认软链接和 `theme.toml` 的引用名。

**Yazi 没装**：本仓库不安装它。`cargo install --locked yazi-fm yazi-cli` 或包管理器。

**嵌套 git 仓库警告**：`config/yazi/flavors/kanagawa.yazi/` 有自己的 `.git`，Git 会提示。它作为 vendored 内容存在，不参与本仓库的提交。

## 三个配置的共同点

| 配置 | 部署 | 完整度 |
|---|---|---|
| nano | 自动 | 完整 |
| Herdr | 自动 | 部分（无凭据） |
| Yazi | 手动 | 只有 flavor |

这体现了公开仓库的分层原则：能完整公开的自动部署，涉及个人的只放可分享部分，需要判断的手动处理。
