> 摘要：install_font.sh 安装 Meslo Nerd Font 与 Noto Serif CJK，供终端图标和中文显示使用。

# 字体安装器

## 用途

装两种字体：

| 字体 | 用途 |
|---|---|
| Meslo Nerd Font | 终端和编辑器的图标（Powerline、Devicons、Material） |
| Noto Serif CJK | 中日韩文字的字形 |

缺 Meslo 时图标显示成方框；缺 Noto 时中文可能显示成豆腐块。

## 用法

```bash
bash scripts/install/install_font.sh
bash scripts/install/install_font.sh --meslo
bash scripts/install/install_font.sh --noto
bash scripts/install/install_font.sh --all
bash scripts/install/install_font.sh --all --force
```

**注意**：这个脚本没有 `install:font` 别名。仓库的 `scripts/install/README.md` 里写着有，但当前 `aliases.conf` 没有定义，直接运行脚本。

## 参数

| 参数 | 短参数 | 作用 |
|---|---|---|
| `--meslo` | `-m` | 只装 Meslo |
| `--noto` | `-n` | 只装 Noto Serif |
| `--all` | `-a` | 两个都装 |
| `--force` | `-f` | 强制重装 |
| 无 | | 默认装 Meslo |

不指定字体类型时默认只装 Meslo（向后兼容）。

## Meslo 的下载与安装

```bash
MESLO_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/Meslo.tar.xz"
MESLO_TAR="$HOME/.cache/fonts/Meslo.tar.xz"
```

| 步骤 | 说明 |
|---|---|
| 缓存 | 下载到 `~/.cache/fonts/Meslo.tar.xz`，已存在则跳过 |
| 解压 Linux | `~/.fonts/`，然后 `fc-cache -fv` |
| 解压 macOS | `~/Library/Fonts/`，系统自动加载 |

版本固定为 v3.4.0，升级需要改脚本里的 URL。

## Noto Serif CJK 的安装

不是单个文件，而是从四个 zip 下载：

```bash
download_links=(
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/07_NotoSerifCJKjp.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/12_NotoSerifJP.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/09_NotoSerifCJKsc.zip"
  "https://github.com/notofonts/noto-cjk/releases/download/Serif2.003/14_NotoSerifSC.zip"
)
```

| 文件 | 内容 |
|---|---|
| `NotoSerifCJKjp` | 日文优先的 CJK 全字集 |
| `NotoSerifJP` | 日文字集 |
| `NotoSerifCJKsc` | 简体中文优先的 CJK 全字集 |
| `NotoSerifSC` | 简体中文字集 |

装四份是因为 CJK 字形的地区差异：同一个汉字在日文和简体中文里字形不同（比如「直」「骨」）。装了对应地区的字集，排版才正确。

脚本还会尝试 `git clone https://github.com/iamcheyan/fonts.git`，失败时只走下载路径。

## 已安装检测

```bash
check_meslo_installed() {
    ...
}
```

已装且未加 `--force` 时跳过，打印「✓ Meslo font is installed; skipping installation」。

## 验证

```bash
# Linux
fc-list | grep -i meslo
fc-list | grep -i "noto serif cjk"

# macOS
ls ~/Library/Fonts | grep -i meslo
```

在终端设置里选择 `MesloLGS Nerd Font` 或 `MesloLGS NF`。

## 图标测试

装完后测试图标是否正常：

```bash
echo "   󰈙 󰊢 󰉋 󰡨 󰅩"
```

如果显示成方框，说明字体没生效或终端没选中正确字体。

## 为什么需要 Nerd Font

本仓库多处使用 Nerd Font 私有区字符：

| 位置 | 字符 |
|---|---|
| Starship 提示符 | `❯`、``、`` |
| Vifm 文件图标 | ``、``、`` |
| Neovim 状态栏 | ``、`` |
| fzf 提示 | 无（纯文本） |

这些字符在 Unicode 私有使用区（PUA），普通字体没有对应字形。

## 排错

**图标显示成方框**：终端字体没选对。不是「装了就行」，要在终端配置里显式选择。

**中文显示成豆腐块**：Noto Serif CJK 没装，或终端的 fallback 字体链没包含它。

**`fc-cache` 找不到**：Linux 上需要 `fontconfig` 包。`sudo apt install fontconfig`。

**下载很慢**：Meslo 约 20MB，Noto 四个包合计约 100MB。`--meslo` 只装前者。

**`--force` 后还是旧字体**：字体缓存没刷新。`fc-cache -fv` 手动执行。

**macOS 上字体不显示**：`~/Library/Fonts` 权限问题，或需要重启应用（不是重启系统）。

**脚本报 `install:font: command not found`**：别名不存在，用完整路径 `bash scripts/install/install_font.sh`。
