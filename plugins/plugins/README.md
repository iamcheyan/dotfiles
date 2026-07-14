# Zsh 功能插件配置

## 简介

此文件负责配置和管理 Zsh 的功能插件，包括自动建议、语法高亮、vim 模式、以及各种实用插件。这些插件增强了 Zsh 的功能和用户体验。当前配置**不使用任何 Oh My Zsh 片段**（不再依赖 `OMZP::*`）。

## 文件位置

- **配置文件**: `~/dotfiles/plugins/plugins/plugins.zsh`
- **加载位置**: 在 `~/.zshrc` 中，于 `completion.zsh` 之后、`fzf.zsh` 之前加载

> 另有 4 个功能插件在 `~/.zshrc` 中直接加载（见下文「在 zshrc 中直接加载的插件」）。

## 已安装的插件

### 本文件（plugins.zsh）加载的插件

#### 1. zshcp

Zsh 剪贴板管理插件，提供剪贴板历史记录与快捷键。

```zsh
zinit light 1mykull/zshcp
```

**功能**: 剪贴板历史记录、快捷键集成。

#### 2. you-should-use

当输入命令时，如果存在对应的别名，会显示提醒。

```zsh
zinit light MichaelAquilina/zsh-you-should-use
```

**功能**: 自动提醒使用已有别名，无需额外操作。

#### 3. zsh-extract

自动解压各种压缩文件（30+ 格式），无需记忆解压命令。

```zsh
zinit light le0me55i/zsh-extract
```

**功能**: 输入 `extract <file>` 或 `x <file>` 自动根据格式解压。

#### 4. fast-syntax-highlighting

语法高亮插件，实时高亮命令语法。

```zsh
zinit light zdharma-continuum/fast-syntax-highlighting
```

**功能**:
- 命令语法高亮
- 错误命令红色显示
- 有效命令绿色显示

**加载顺序**: 必须最后加载，以确保正确高亮所有命令。

### 在 zshrc 中直接加载的插件

> 这些插件在 `~/.zshrc` 中通过 `zinit light` 直接加载（位于 `plugins.zsh` 之前）：

#### 5. evalcache (`mroth/evalcache`)

缓存 init 脚本输出，减少 atuin / zoxide / direnv 这类 hook 的重复开销。

```zsh
zinit light mroth/evalcache
```

**功能**: 提供 `_evalcache` 函数，缓存 `cmd init zsh` 类脚本的输出。

#### 6. zsh-autosuggestions (`zsh-users/zsh-autosuggestions`)

自动建议插件，根据历史记录提供命令建议。

```zsh
zinit light zsh-users/zsh-autosuggestions
```

**功能**:
- 根据历史记录自动建议
- 使用 `→` 键（或 `Ctrl+→` 部分）接受建议
- 配置：`ZSH_AUTOSUGGEST_STRATEGY=(history completion)`、`ZSH_AUTOSUGGEST_USE_ASYNC=1`

**加载顺序**: 在 `zsh-vi-mode` 之后加载。

#### 7. zsh-autopair (`hlissner/zsh-autopair`)

自动补全括号、引号等配对符号。

```zsh
zinit light hlissner/zsh-autopair
```

**功能**: 输入 `(` 时自动补全 `)`，支持多种括号与引号。

#### 8. zsh-vi-mode (`jeffreytse/zsh-vi-mode`)

Vim 键绑定模式，提供 Vim 风格的命令行编辑体验。

```zsh
zinit light jeffreytse/zsh-vi-mode
```

**功能**:
- Vim 模式的命令编辑
- 可视模式选择
- 文本对象操作
- 自定义键绑定

**加载顺序**: 必须在 `zsh-autosuggestions` 之前加载，避免按键绑定冲突。

**配置**:
```zsh
export ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT  # 每次新行开始默认进入插入模式
function zvm_after_init() {
  zvm_bindkey viins '^[[A' atuin-up-search
  zvm_bindkey viins '^[OA' atuin-up-search
}
```

## 配置选项

### AUTO_CD

启用自动 cd 功能，输入目录路径时自动切换：

```zsh
setopt AUTO_CD
```

**使用**: 直接输入目录路径，无需 `cd` 命令。

## 使用说明

### 插件管理

#### 查看已安装的插件

```bash
zinit list
```

#### 更新插件

```bash
# 更新所有插件
zinit update

# 更新特定插件
zinit update jeffreytse/zsh-vi-mode
```

#### 删除插件

```bash
zinit delete jeffreytse/zsh-vi-mode
```

### 插件使用

#### zsh-vi-mode

- 按 `Esc` 进入普通模式
- 使用 `h`, `j`, `k`, `l` 移动光标
- 使用 `i` 进入插入模式
- 使用 `v` 进入可视模式

#### zsh-autosuggestions

- 输入命令时自动显示建议（灰色）
- 按 `→` 键接受完整建议
- 按 `Ctrl+→` 接受部分建议

#### zsh-extract

```bash
extract archive.tar.gz   # 自动解压
x archive.zip            # 等价别名
```

#### you-should-use

自动提醒使用别名，无需额外操作。

## 添加新插件

### 使用 Zinit 安装

```zsh
# 从 GitHub 安装
zinit light owner/repo
```

示例（添加到 `plugins.zsh`）：

```zsh
zinit light zsh-users/zsh-history-substring-search
```

> 注意：如需在 `zsh-autosuggestions` 之前加载（如影响键绑定的插件），应放到 `~/.zshrc` 中、在 `plugins.zsh` 之前直接 `zinit light`。

## 加载顺序

正确的加载顺序很重要：

1. **zsh-vi-mode** (zshrc): 必须在 autosuggestions 之前
2. **zsh-autosuggestions** (zshrc): 在 vi-mode 之后
3. **fzf-tab** (completion.zsh): 在 `compinit` 之后、`zsh-autosuggestions` 之前
4. **fast-syntax-highlighting** (plugins.zsh): 必须最后加载

## 故障排除

### 插件未加载

1. **检查插件是否安装**:
   ```bash
   zinit list | grep plugin-name
   ```

2. **重新加载配置**:
   ```bash
   source ~/.zshrc
   ```

3. **检查加载顺序**: 确保加载顺序正确

### 键绑定冲突

如果键绑定不工作：

1. **检查加载顺序**: 确保 `zsh-vi-mode` 在 `zsh-autosuggestions` 之前
2. **检查其他插件**: 可能有其他插件覆盖了键绑定

### 语法高亮不工作

1. **检查加载顺序**: 确保 `fast-syntax-highlighting` 最后加载
2. **检查插件是否加载**:
   ```bash
   zinit list | grep syntax-highlighting
   ```

## 相关文件

- **补全配置**: `~/dotfiles/plugins/completion/completion.zsh` - 补全系统配置
- **工具配置**: `~/dotfiles/plugins/tools/tools.zsh` - CLI 工具安装
- **fzf 配置**: `~/dotfiles/plugins/fzf/fzf.zsh` - fzf 详细配置

## 参考资源

- [zsh-vi-mode GitHub](https://github.com/jeffreytse/zsh-vi-mode)
- [zsh-autosuggestions GitHub](https://github.com/zsh-users/zsh-autosuggestions)
- [fast-syntax-highlighting GitHub](https://github.com/zdharma-continuum/fast-syntax-highlighting)
- [zsh-autopair GitHub](https://github.com/hlissner/zsh-autopair)
- [zshcp GitHub](https://github.com/1mykull/zshcp)
- [you-should-use GitHub](https://github.com/MichaelAquilina/zsh-you-should-use)
- [zsh-extract GitHub](https://github.com/le0me55i/zsh-extract)
- [evalcache GitHub](https://github.com/mroth/evalcache)
