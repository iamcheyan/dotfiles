> 摘要：本仓库终端界面的统一配色规范，基准为 Neovim Blue 使用的 Nostalgia 调色板。

# 终端统一配色标准

本页是 dotfiles 中终端工具配色的**唯一基准**。新增或修改终端界面时，先按这里的颜色角色选色；Neovim Blue / Nostalgia 是标准来源，Ghostty、tmux、Ranger、Vifm、Atuin、fzf、Starship、Nano 和 Herdr 等配置都应与它保持协调。

## 核心颜色

| 角色 | 色值 | 用途 |
|---|---|---|
| 主背景 | `#0000aa` | 编辑区、TUI 主画布 |
| 主文字 | `#ffff55` | 蓝底上的一般文字 |
| 当前行／次级蓝面 | `#000080` | 当前行、非活动 pane、标签底色 |
| 选区背景 | `#1e1ec8` | 搜索或文本选区 |
| 青色强调 | `#55ffff` | 行号、分隔线、导航与边框 |
| 明亮青色 | `#00ffff` | 目录、可点击项等强调文字 |
| 活动标题面 | `#aaaaaa` | 活动标签、标题栏；文字用 `#000000` |
| 状态栏青面 | `#00aaaa` | 状态栏；文字用 `#000000` |
| 状态绿面 | `#00aa00` | 成功状态或主要确认操作；文字用 `#ffffff` |
| 明亮绿 | `#00ff00` | 已暂存、可执行文件等正向状态 |
| 警告黄 | `#ffff55` / `#ffff00` | 警告、匹配项、重点信息 |
| 错误红 | `#ff5555` | 错误、失败、冲突 |
| 错误背景 | `#aa0000` | 需要明确提示的错误区域；文字用白色 |
| 中性灰 | `#aaaaaa` | 次要文字、不可用或低优先级信息 |
| 结构深蓝 | `#000064` | 只用于装饰线等非文字细节，不能用作蓝底上的正文色 |

这些是颜色角色。遇到界面没有背景色支持时，优先保留终端默认背景，只应用前景色；不要为了“看起来统一”把每个程序都强制铺上背景色。需要实心画布的 TUI 才使用主背景和主文字。

## 颜色语义

- 保持成功／暂存为绿色、警告／修改为黄色、错误／删除／冲突为红色。
- 青色用于导航、目录、边界和可交互强调；黄色用于一般文字和需要注意的信息。
- 活动项要有清晰的前景／背景区别。不要把深蓝文字放在主蓝背景上；静音文字使用中性灰，并确认仍清楚可读。
- 新的颜色组合应保持足够对比。截图里若出现难辨的文字，应先提高前景亮度，不要只靠加粗解决。
- 各应用可以调整色值映射来适配自己的能力（比如 Nano 只有 ANSI 色名、Ranger 走终端 16 色），但要保留上述角色关系。

## Ghostty ANSI 16 色映射

Ghostty 的 ANSI 色板影响 `ls`、Ranger、编辑器和其它读取终端色板的程序。色号约定如下：

| 色号 | 色值 | 色号 | 色值 |
|---:|---|---:|---|
| 0 | `#000080` | 8 | `#555555` |
| 1 | `#aa0000` | 9 | `#ff5555` |
| 2 | `#00aa00` | 10 | `#00ff00` |
| 3 | `#aaaa00` | 11 | `#ffff55` |
| 4 | `#0000aa` | 12 | `#5555ff` |
| 5 | `#aa00aa` | 13 | `#ff55ff` |
| 6 | `#00aaaa` | 14 | `#55ffff` |
| 7 | `#aaaaaa` | 15 | `#ffffff` |

程序不支持 RGB 时，优先用这组 16 色映射；支持 RGB 的程序使用上方角色的精确色值。

## 现有实现

| 配置 | 配色入口 |
|---|---|
| Ghostty | `config/ghostty/config` |
| tmux | `config/tmux/tmux.conf` |
| Ranger | `config/ranger/colorschemes/blue.py` |
| Vifm | `config/vifm/colors/papercolor-dark.vifm` |
| Atuin | `config/atuin/themes/nostalgia-blue.toml` |
| fzf | `plugins/fzf/fzf.zsh`；保留终端背景 |
| Starship | `config/starship/starship.toml` |
| Nano | `config/nano/nanorc` |
| Herdr | `config/herdr/config.toml` |
| Vim | `config/vim/vimrc`；使用 Vim 内置 `blue` |
| Neovim | 主题由独立的 `iamcheyan/nvim` 仓库维护；以其 Blue / Nostalgia 调色板为来源 |

修改现有配置时同步更新对应配置说明；新增终端工具时先给它映射上面的颜色角色，并把新配置链接到本标准。
