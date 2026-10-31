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
| fd | Zinit | `fd`、`ffd` 后端 | [fd](fd.html) |
| ripgrep | Zinit | `rg` | [ripgrep](ripgrep.html) |
| fzf | init.sh | `f`、`ffd`、`Ctrl+T` | [fzf](fzf.html) |
| zoxide | Zinit | `z`、`zi`、`za`、`zr` | [zoxide](zoxide.html) |
| glow | Zinit | `glow` | [glow](glow.html) |
| broot | Zinit | `broot`、`br` | [broot](broot.html) |

## 文本与数据处理

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| jq | Zinit | `jq` | [jq](jq.html) |
| sd | Zinit | `sd` | [sd](sd.html) |

## 历史与环境

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| Atuin | 系统包 / Zinit 兜底 | `atuin`、`↑` | [Atuin](atuin.html) |
| direnv | Zinit | `direnv` | [direnv](direnv.html) |
| fnm | init.sh | `fnm`、`node`、`npm` | [fnm](fnm.html) |
| Starship | Zinit | 提示符 | [Starship](starship.html) |

## Git

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| forgit | Zinit 插件 | `ga`、`gd`、`glo` 等 | [forgit](forgit.html) |
| lazygit | Zinit | `lazygit` | [lazygit](lazygit.html) |
| gitui | Zinit | `gitui` | [gitui](gitui.html) |
| gh | Zinit | `gh` | [GitHub CLI](gh.html) |
| gh-dash | init.sh (gh extension) | `gh dash` | [GitHub CLI](gh.html) |

## 系统与网络

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| btop | Zinit | `btop` | [btop](btop.html) |
| bottom | Zinit | `btm` | [bottom](bottom.html) |
| duf | Zinit | `duf` | [duf](duf.html) |
| procs | Zinit | `procs` | [procs](procs.html) |
| gping | system package (optional) | `gping` | [gping](gping.html) |
| HTTPie | 安装器 | `http` | [HTTPie](httpie.html) |

## 文件管理与复用

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| Ranger | 系统包 | `ra` | [Ranger](ranger.html) |
| Vifm | 系统包 | `v` | [Vifm](vifm.html) |
| tmux | 系统包 | `tmux` | [tmux](tmux.html) |
| zellij | Zinit / 安装器 | `zellij` | [zellij](zellij.html) |
| Fresh | init.sh | `fr` | [Fresh](fresh.html) |
| Neovim | 独立仓库 | `nvim` | [Neovim](neovim.html) |

## 数据与日志

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| VisiData | pipx | `vd file.csv` | [VisiData](visidata.html) |
| tabiew | 上游 install.sh | `tw file.csv` | [tabiew](tabiew.html) |
| qsv | 上游 Release | `qsv stats data.csv` | [qsv](qsv.html) |
| toolong | pipx | `tl app.log` | [toolong](toolong.html) |
| dekit | 上游 install.sh | `dekit up` | [dekit](dekit.html) |
| topgrade | 上游 Release | `topgrade` | [topgrade](topgrade.html) |
| mise | 上游 install.sh | `mise use` | [mise](mise.html) |

## 数据库

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| Harlequin | pipx | `harlequin` | [Harlequin](harlequin.html) |
| LazySQL | init.sh（官方 release） | `lazysql` | [LazySQL](lazysql.html) |
| sqlmux | init.sh（校验 SHA-256 的官方 release） | `sqlmux` | [sqlmux](sqlmux.html) |
| Rainfrog | init.sh（系统包 / 官方 release） | `rainfrog` | [Rainfrog](rainfrog.html) |

## Diff 与评审

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| delta | 上游 Release | `delta`（diffnav 依赖） | [delta](delta.html) |
| diffnav | 上游 Release | `git diff \| diffnav` | [diffnav](diffnav.html) |
| hunk | 上游 Release | `hunk diff` | [hunk](hunk.html) |

## 命令片段

| 工具 | 来源 | 入口 | 文档 |
|---|---|---|---|
| navi | Zinit | `navi` | [navi](navi.html) |
| Pet | Zinit | `pet`、`Ctrl+X Ctrl+R` | [Pet](pet.html) |
| pay-respects | init.sh | `F` | [pay-respects](pay-respects.html) |

## 读法建议

先看表格定位工具，再进具体文档。每篇文档的结构一致：用途、来源与安装、基本用法、常用参数、本仓库的配置、排错。想快速上手只看前三节，想改配置看第五节。

<!-- lang:en -->

> Summary: Where every tool comes from, how it is invoked, and which page documents it. Read this table first, then jump to the specific doc.

# Tool index

## By source

| Source | Meaning |
|---|---|
| **Zinit** | binary downloaded from a GitHub Release via `zinit ice from"gh-r"` in `plugins/tools/tools.zsh` |
| **init.sh** | installed directly by the bootstrap script (system packages, npm, official installers) |
| **System package** | provided by the distro package manager; the repo only adds config or aliases |
| **Optional** | enabled only when detected; absence does not break startup |

## Files & search

| Tool | Source | Entry | Doc |
|---|---|---|---|
| eza | system package (optional) | `l`, `ll`, `la` | [eza](eza.html) |
| fd | Zinit | `fd`, `ffd` backend | [fd](fd.html) |
| ripgrep | Zinit | `rg` | [ripgrep](ripgrep.html) |
| fzf | init.sh | `f`, `ffd`, `Ctrl+T` | [fzf](fzf.html) |
| zoxide | Zinit | `z`, `zi`, `za`, `zr` | [zoxide](zoxide.html) |
| glow | Zinit | `glow` | [glow](glow.html) |
| broot | Zinit | `broot`, `br` | [broot](broot.html) |

## Text & data

| Tool | Source | Entry | Doc |
|---|---|---|---|
| jq | Zinit | `jq` | [jq](jq.html) |
| sd | Zinit | `sd` | [sd](sd.html) |

## History & environment

| Tool | Source | Entry | Doc |
|---|---|---|---|
| Atuin | system package / Zinit fallback | `atuin`, `↑` | [Atuin](atuin.html) |
| direnv | Zinit | `direnv` | [direnv](direnv.html) |
| fnm | init.sh | `fnm`, `node`, `npm` | [fnm](fnm.html) |
| Starship | Zinit | prompt | [Starship](starship.html) |

## Git

| Tool | Source | Entry | Doc |
|---|---|---|---|
| forgit | Zinit plugin | `ga`, `gd`, `glo`, … | [forgit](forgit.html) |
| lazygit | Zinit | `lazygit` | [lazygit](lazygit.html) |
| gitui | Zinit | `gitui` | [gitui](gitui.html) |
| gh | Zinit | `gh` | [GitHub CLI](gh.html) |
| gh-dash | init.sh (gh extension) | `gh dash` | [GitHub CLI](gh.html) |

## System & network

| Tool | Source | Entry | Doc |
|---|---|---|---|
| btop | Zinit | `btop` | [btop](btop.html) |
| bottom | Zinit | `btm` | [bottom](bottom.html) |
| duf | Zinit | `duf` | [duf](duf.html) |
| procs | Zinit | `procs` | [procs](procs.html) |
| gping | system package (optional) | `gping` | [gping](gping.html) |
| HTTPie | installer | `http` | [HTTPie](httpie.html) |

## File management & reuse

| Tool | Source | Entry | Doc |
|---|---|---|---|
| Ranger | system package | `ra` | [Ranger](ranger.html) |
| Vifm | system package | `v` | [Vifm](vifm.html) |
| tmux | system package | `tmux` | [tmux](tmux.html) |
| zellij | Zinit / installer | `zellij` | [zellij](zellij.html) |
| Fresh | init.sh | `fr` | [Fresh](fresh.html) |
| Neovim | separate repository | `nvim` | [Neovim](neovim.html) |

## Data & logs

| Tool | Source | Entry | Doc |
|---|---|---|---|
| VisiData | pipx | `vd file.csv` | [VisiData](visidata.html) |
| tabiew | upstream install.sh | `tw file.csv` | [tabiew](tabiew.html) |
| qsv | upstream Release | `qsv stats data.csv` | [qsv](qsv.html) |
| toolong | pipx | `tl app.log` | [toolong](toolong.html) |
| dekit | upstream install.sh | `dekit up` | [dekit](dekit.html) |
| topgrade | upstream Release | `topgrade` | [topgrade](topgrade.html) |
| mise | upstream install.sh | `mise use` | [mise](mise.html) |

## Databases

| Tool | Source | Entry | Doc |
|---|---|---|---|
| Harlequin | pipx | `harlequin` | [Harlequin](harlequin.html) |
| LazySQL | init.sh (official release) | `lazysql` | [LazySQL](lazysql.html) |
| sqlmux | init.sh (SHA-256-verified official release) | `sqlmux` | [sqlmux](sqlmux.html) |
| Rainfrog | init.sh (system package / official release) | `rainfrog` | [Rainfrog](rainfrog.html) |

## Diff & review

| Tool | Source | Entry | Doc |
|---|---|---|---|
| delta | upstream Release | `delta` (diffnav dependency) | [delta](delta.html) |
| diffnav | upstream Release | `git diff \| diffnav` | [diffnav](diffnav.html) |
| hunk | upstream Release | `hunk diff` | [hunk](hunk.html) |

## Snippets

| Tool | Source | Entry | Doc |
|---|---|---|---|
| navi | Zinit | `navi` | [navi](navi.html) |
| Pet | Zinit | `pet`, `Ctrl+X Ctrl+R` | [Pet](pet.html) |
| pay-respects | init.sh | `F` | [pay-respects](pay-respects.html) |

## How to read this

Find the tool in a table, then open its page. Every page follows the same structure: purpose, source and install, basic usage, common flags, this repo's config, troubleshooting. For a quick start read only the first three sections; to change configuration, see the fifth.

<!-- lang:ja -->

> 要約：全ツールの出所・入り口・担当ページの一覧。まずこの表を見てから各ドキュメントへ移動します。

# ツール総表

## 出所分類

| 出所 | 意味 |
|---|---|
| **Zinit** | `plugins/tools/tools.zsh` 内で `zinit ice from"gh-r"` により GitHub Release からバイナリを取得 |
| **init.sh** | 初期化スクリプトが直接インストール（システムパッケージ・npm・公式インストーラ） |
| **システムパッケージ** | ディストロのパッケージマネージャが提供。リポジトリは設定やエイリアスのみ |
| **任意** | 検出できた場合のみ有効。無くても起動に影響しない |

## ファイルと検索

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| eza | システムパッケージ（任意） | `l`、`ll`、`la` | [eza](eza.html) |
| fd | Zinit | `fd`、`ffd` バックエンド | [fd](fd.html) |
| ripgrep | Zinit | `rg` | [ripgrep](ripgrep.html) |
| fzf | init.sh | `f`、`ffd`、`Ctrl+T` | [fzf](fzf.html) |
| zoxide | Zinit | `z`、`zi`、`za`、`zr` | [zoxide](zoxide.html) |
| glow | Zinit | `glow` | [glow](glow.html) |
| broot | Zinit | `broot`、`br` | [broot](broot.html) |

## テキストとデータ

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| jq | Zinit | `jq` | [jq](jq.html) |
| sd | Zinit | `sd` | [sd](sd.html) |

## 履歴と環境

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| Atuin | システムパッケージ / Zinit フォールバック | `atuin`、`↑` | [Atuin](atuin.html) |
| direnv | Zinit | `direnv` | [direnv](direnv.html) |
| fnm | init.sh | `fnm`、`node`、`npm` | [fnm](fnm.html) |
| Starship | Zinit | プロンプト | [Starship](starship.html) |

## Git

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| forgit | Zinit プラグイン | `ga`、`gd`、`glo` など | [forgit](forgit.html) |
| lazygit | Zinit | `lazygit` | [lazygit](lazygit.html) |
| gitui | Zinit | `gitui` | [gitui](gitui.html) |
| gh | Zinit | `gh` | [GitHub CLI](gh.html) |
| gh-dash | init.sh (gh extension) | `gh dash` | [GitHub CLI](gh.html) |

## システムとネットワーク

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| btop | Zinit | `btop` | [btop](btop.html) |
| bottom | Zinit | `btm` | [bottom](bottom.html) |
| duf | Zinit | `duf` | [duf](duf.html) |
| procs | Zinit | `procs` | [procs](procs.html) |
| gping | システムパッケージ（任意） | `gping` | [gping](gping.html) |
| HTTPie | インストーラ | `http` | [HTTPie](httpie.html) |

## ファイル管理と再利用

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| Ranger | システムパッケージ | `ra` | [Ranger](ranger.html) |
| Vifm | システムパッケージ | `v` | [Vifm](vifm.html) |
| tmux | システムパッケージ | `tmux` | [tmux](tmux.html) |
| zellij | Zinit / インストーラ | `zellij` | [zellij](zellij.html) |
| Fresh | init.sh | `fr` | [Fresh](fresh.html) |
| Neovim | 独立リポジトリ | `nvim` | [Neovim](neovim.html) |

## データとログ

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| VisiData | pipx | `vd file.csv` | [VisiData](visidata.html) |
| tabiew | 上流 install.sh | `tw file.csv` | [tabiew](tabiew.html) |
| qsv | 上流 Release | `qsv stats data.csv` | [qsv](qsv.html) |
| toolong | pipx | `tl app.log` | [toolong](toolong.html) |
| dekit | 上流 install.sh | `dekit up` | [dekit](dekit.html) |
| topgrade | 上流 Release | `topgrade` | [topgrade](topgrade.html) |
| mise | 上流 install.sh | `mise use` | [mise](mise.html) |

## データベース

| ツール | 入手元 | コマンド | ドキュメント |
|---|---|---|---|
| Harlequin | pipx | `harlequin` | [Harlequin](harlequin.html) |
| LazySQL | init.sh（公式 release） | `lazysql` | [LazySQL](lazysql.html) |
| sqlmux | init.sh（SHA-256 検証済み公式 release） | `sqlmux` | [sqlmux](sqlmux.html) |
| Rainfrog | init.sh（システムパッケージ / 公式 release） | `rainfrog` | [Rainfrog](rainfrog.html) |

## Diff とレビュー

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| delta | 上流 Release | `delta`（diffnav の依存） | [delta](delta.html) |
| diffnav | 上流 Release | `git diff \| diffnav` | [diffnav](diffnav.html) |
| hunk | 上流 Release | `hunk diff` | [hunk](hunk.html) |

## コマンドスニペット

| ツール | 出所 | 入口 | ドキュメント |
|---|---|---|---|
| navi | Zinit | `navi` | [navi](navi.html) |
| Pet | Zinit | `pet`、`Ctrl+X Ctrl+R` | [Pet](pet.html) |
| pay-respects | init.sh | `F` | [pay-respects](pay-respects.html) |

## 読み方

まず表でツールを探し、個別のページへ進みます。各ページの構成は共通です：役割、出所とインストール、基本的な使い方、主要なフラグ、このリポジトリでの設定、トラブルシュート。手早く始めるには最初の 3 節だけ、設定を変えるなら 5 節目を見てください。
