# Starship 提示符配置

## 简介

此文件负责配置 Starship，这是一个极速、极具定制性且适用于任何 Shell 的现代化提示符。

**官方网站**: https://starship.rs

## 文件位置

- **配置文件**: `~/dotfiles/plugins/prompt/prompt.zsh`
- **Starship 配置**: `~/.config/starship.toml` (Starship 的默认配置路径)
- **加载位置**: 在 `~/.zshrc` 中加载，并用 `zinit` 下载二进制文件：
  ```zsh
  source ~/dotfiles/plugins/prompt/prompt.zsh
  ```

## 功能与安装方式

在 `prompt.zsh` 中，我们根据当前的操作系统类型和架构，自适应地下载对应平台的 Starship 编译二进制包，并通过 `zinit` 加载和注入环境变量：

```zsh
zinit ice as"command" from"gh-r" bpick"${_starship_bpick}" pick"starship" sbin"starship"
zinit light starship/starship
```

### 初始化 Starship

当 starship 可执行文件在 PATH 中可用时，在 Zsh 中进行初始化：

```zsh
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
```

## 自定义与配置

您可以通过编辑 `~/.config/starship.toml` 文件来更改提示符的外观和显示段（例如目录、Git 状态、Node.js/Python 版本、执行时长等）：

```bash
nvim ~/.config/starship.toml
```

### 常用命令

- **查看当前配置状态**:
  ```bash
  starship explain
  ```
- **查看版本**:
  ```bash
  starship --version
  ```

## 故障排除

1. **终端显示乱码字符**:
   Starship 默认需要使用带图标的 [Nerd Fonts](https://www.nerdfonts.com/)，如果字符显示异常，请确保您的终端字体设置为了 `JetBrainsMono Nerd Font` 或其他支持 Nerd Fonts 的字体。
2. **命令找不到**:
   请检查 Zinit 安装目录下的 Starship 是否下载完整，可运行 `zinit status starship/starship` 进行排查。

## 相关文件

- **Zsh 提示符引导逻辑**: `~/dotfiles/plugins/prompt/prompt.zsh`
- **Zinit 核心逻辑**: `~/dotfiles/plugins/zinit/zinit.zsh`
