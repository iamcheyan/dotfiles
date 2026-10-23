> 摘要：Zinit 是本仓库的 Zsh 插件管理器，负责下载、缓存、加载插件和 CLI 二进制。

# Zinit

## 用途

Zinit 管理三类东西：

| 类型 | 例子 | 加载方式 |
|---|---|---|
| Zsh 插件 | fzf-tab、zsh-autosuggestions | `zinit light` |
| 远程脚本 | fzf 的 key-bindings | `zinit snippet` |
| CLI 二进制 | fd、bat、jq | `zinit ice from"gh-r"` + `zinit light` |

它把这些东西缓存到 `~/.zinit/`，之后启动时直接 source，不再联网。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 仓库 | `zdharma-continuum/zinit` |
| 安装位置 | `~/.zinit/bin` |
| 自动安装 | `plugins/zinit/zinit.zsh` 检测不到时自动 clone |

```zsh
if [[ ! -f ~/.zinit/bin/zinit.zsh ]]; then
  mkdir -p ~/.zinit
  git clone https://github.com/zdharma-continuum/zinit.git ~/.zinit/bin
fi

source ~/.zinit/bin/zinit.zsh
```

这段在 `zshrc` 里最先执行，因为后面所有插件都依赖它。

## 核心概念

### ice

`zinit ice` 设置「下一个 `zinit light` 的加载参数」。它只影响紧随其后的一条命令。

```zsh
zinit ice lucid
zinit light jeffreytse/zsh-vi-mode
```

`lucid` 表示延迟生效，避免插件在加载瞬间改键位。

### light

```zsh
zinit light owner/repo
```

克隆（首次）并 source 插件。这是最常用的形式。

### snippet

```zsh
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

下载单个文件并 source，不需要整个仓库。适合上游提供的独立脚本。

## 本仓库用到的 ice 参数

| 参数 | 作用 | 用在哪 |
|---|---|---|
| `lucid` | 延迟生效，不立即改键位 | zsh-vi-mode |
| `blockf` | 阻止插件把自己的目录加进 `fpath` | zsh-completions |
| `as"completion"` | 声明这是补全脚本 | fzf snippet |
| `as"command"` | 声明这是可执行文件 | 所有 CLI 工具 |
| `from"gh-r"` | 从 GitHub Release 下载 | 所有 CLI 工具 |
| `pick"name"` | 指定解压后取哪个文件 | fd、bat、jq 等 |
| `sbin"name"` | 把二进制放进 Zinit 的 bin 目录 | direnv、fd |
| `mv"src -> dst"` | 解压后重命名/移动 | fd、ripgrep、tealdeer |
| `bpick"pattern"` | 按模式选择 Release 资产 | starship、gping、gitui |

## 本仓库的封装

`plugins/tools/tools.zsh` 顶部定义了一个辅助函数：

```zsh
zi_cmd() {
  zinit ice as"command" from"gh-r" pick"$2"
  zinit light "$1"
}
```

把「下载 GitHub Release 二进制并指定可执行名」压缩成一行：

```zsh
zi_cmd sharkdp/bat bat
```

等价于：

```zsh
zinit ice as"command" from"gh-r" pick"bat"
zinit light sharkdp/bat
```

需要特殊处理（子目录、重命名、多架构）的工具就不用这个封装，直接写完整的 `zinit ice`。

## 常用命令

```zsh
zinit list                  # 已安装的插件和工具
zinit report                # 更详细的状态
zinit update                # 更新全部
zinit update sharkdp/fd     # 更新单个
zinit delete <plugin>       # 删除
zinit self-update           # 更新 Zinit 本体
zinit times                 # 各插件加载耗时
```

`zinit times` 是排查启动慢的入口——它按耗时排序显示每个插件。

## 目录结构

```text
~/.zinit/
├── bin/                    # Zinit 本体
├── plugins/                # 插件与工具
│   ├── zsh-users---zsh-autosuggestions/
│   ├── sharkdp---bat/
│   └── ...
└── snippets/               # snippet 下载的文件
```

目录名把 `owner/repo` 的斜杠换成三个连字符。

## 加载顺序的实际控制

Zinit 本身不保证顺序，顺序由 `zshrc` 里 source 的顺序决定：

```zsh
source plugins/zinit/zinit.zsh
source plugins/zsh-plugins.zsh      # 只定义函数，不加载
source plugins/tools/tools.zsh      # 加载 CLI 工具
zsh_plugins_load_pre_compinit       # zsh-completions
source plugins/completion/completion.zsh
zsh_plugins_load_post_compinit      # fzf-tab
source scripts/setup/setup_fnm.sh
zsh_plugins_load_main               # 其余插件，语法高亮最后
```

`zsh-plugins.zsh` 在第二个位置被 source，但它只定义三个函数，真正加载发生在后面调用函数时。这个设计让「文件位置」和「加载时机」解耦。

## 排错

**`zinit: command not found`**：`~/.zinit/bin/zinit.zsh` 不存在。重新跑 `bash init.sh` 或手动 clone。

**插件没下载**：首次启动需要网络。`zinit list` 看有没有该条目；没有就重启 Zsh 触发。

**更新后命令消失**：上游改了 Release 资产名。`zinit delete <plugin>` 后重新 `zinit light`。

**启动很慢**：`zinit times` 找耗时项。常见是某个插件在同步 clone。

**`--repair` 什么时候用**：插件目录存在但内容不完整（比如 atuin、broot 下载中断）。`bash init.sh --repair` 会重新拉取。
