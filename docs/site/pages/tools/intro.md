> 摘要：全部工具的来源、入口与所属章节索引，先看这张表再跳转到具体文档。

# 工具总表

## 来源分类

| 来源 | 含义 |
|---|---|
| **Zinit** | `plugins/tools/tools.zsh` 里用 `zinit ice from"gh-r"` 从 GitHub Release 下载二进制 |
| **init.sh** | 安装脚本直接安装（系统包、npm、官方 installer） |
| **系统包** | 由发行版包管理器提供，仓库只做配置或别名 |
| **可选** | 仓库检测到才启用，缺失不影响启动 |

## 文件与搜索

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| eza | 系统包（可选） | `l`、`ll`、`la` | [eza](eza.html) |
| bat | Zinit | `bat` | [bat](bat.html) |
| fd | Zinit | `fd`、`ffd` 后端 | [fd](fd.html) |
| ripgrep | Zinit | `rg` | [ripgrep](ripgrep.html) |
| fzf | init.sh | `f`、`ffd`、`Ctrl+T` | [fzf](fzf.html) |
| zoxide | Zinit | `z`、`zi`、`za`、`zr` | [zoxide](zoxide.html) |
| glow | Zinit | `glow` | [glow](glow.html) |
| tldr | Zinit | `tldr` | [tldr](tldr.html) |
| broot | Zinit | `broot`、`br` | [broot](broot.html) |

## 文本与数据处理

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| jq | Zinit | `jq` | [jq](jq.html) |
| yq | Zinit | `yq` | [yq](yq.html) |
| sd | Zinit | `sd` | [sd](sd.html) |
| choose | Zinit | `choose` | [choose](choose.html) |

## 历史与环境

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| Atuin | 系统包 / Zinit 兜底 | `atuin`、`↑` | [Atuin](atuin.html) |
| direnv | Zinit | `direnv` | [direnv](direnv.html) |
| fnm | init.sh | `fnm`、`node`、`npm` | [fnm](fnm.html) |
| Starship | Zinit | 提示符 | [Starship](starship.html) |
| Inshellisense | init.sh（npm） | `is` | [Inshellisense](inshellisense.html) |

## Git

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| forgit | Zinit 插件 | `ga`、`gd`、`glo` 等 | [forgit](forgit.html) |
| lazygit | Zinit | `lazygit` | [lazygit](lazygit.html) |
| gitui | Zinit | `gitui` | [gitui](gitui.html) |
| delta | Zinit | `delta` | [delta](delta.html) |
| gh | Zinit | `gh` | [GitHub CLI](gh.html) |

## 系统与网络

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| btop | Zinit | `btop` | [btop](btop.html) |
| bottom | Zinit | `btm` | [bottom](bottom.html) |
| duf | Zinit | `duf` | [duf](duf.html) |
| procs | Zinit | `procs` | [procs](procs.html) |
| gping | Zinit | `gping` | [gping](gping.html) |
| xh | Zinit | `xh` | [xh](xh.html) |
| HTTPie | 安装器 | `http` | [HTTPie](httpie.html) |

## 文件管理与复用

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| Ranger | 系统包 | `ra` | [Ranger](ranger.html) |
| Vifm | 系统包 | `v` | [Vifm](vifm.html) |
| Yazi | 系统包（可选） | `yazi` | [Yazi](yazi.html) |
| tmux | 系统包 | `tmux` | [tmux](tmux.html) |
| zellij | Zinit / 安装器 | `zellij` | [zellij](zellij.html) |
| Fresh | init.sh | `fr` | [Fresh](fresh.html) |
| Neovim | 独立仓库 | `nvim` | [Neovim](neovim.html) |

## 命令片段

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| navi | Zinit | `navi` | [navi](navi.html) |
| Pet | Zinit | `pet`、`Ctrl+X Ctrl+R` | [Pet](pet.html) |
| Pay Respects | Zinit | `f`（命令失败后） | [Pay Respects](pay-respects.html) |

## 读法建议

先看表格定位工具，再进具体文档。每篇文档的结构一致：用途、来源与安装、基本用法、常用参数、本仓库的配置、排错。想快速上手只看前三节，想改配置看第五节。
