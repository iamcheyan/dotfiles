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
| 活动标题面 | `#00aa00` | 活动标签、标题栏；文字用 `#000000` |
| 状态栏青面 | `#00aaaa` | 状态栏；文字用 `#000000` |
| 状态绿面 | `#00aa00` | 成功状态或主要确认操作；文字用 `#ffffff` |
| 明亮绿 | `#00ff00` | 已暂存、可执行文件等正向状态 |
| 警告黄 | `#ffff55` / `#ffff00` | 警告、匹配项、重点信息 |
| 错误红 | `#ff5555` | 错误、失败、冲突 |
| 错误背景 | `#aa0000` | 需要明确提示的错误区域；文字用白色 |
| 柔和绿 | `#a3be8c` | 次要、不可用或低优先级文字 |
| 结构深蓝 | `#000064` | 只用于装饰线等非文字细节，不能用作蓝底上的正文色 |

这些是颜色角色。遇到界面没有背景色支持时，优先保留终端默认背景，只应用前景色；不要为了“看起来统一”把每个程序都强制铺上背景色。需要实心画布的 TUI 才使用主背景和主文字。

## 颜色语义

- 保持成功／暂存为绿色、警告／修改为黄色、错误／删除／冲突为红色。
- 青色用于导航、目录、边界和可交互强调；黄色用于一般文字和需要注意的信息。
- 活动项要有清晰的前景／背景区别。不要把深蓝文字放在主蓝背景上；次要文字使用柔和绿，并确认仍清楚可读。
- 新的颜色组合应保持足够对比。截图里若出现难辨的文字，应先提高前景亮度，不要只靠加粗解决。
- 各应用可以调整色值映射来适配自己的能力（比如 Nano 只有 ANSI 色名、Ranger 走终端 16 色），但要保留上述角色关系。

## Ghostty ANSI 16 色映射

Ghostty 的 ANSI 色板影响 `ls`、Ranger、编辑器和其它读取终端色板的程序。色号约定如下：

| 色号 | 色值 | 色号 | 色值 |
|---:|---|---:|---|
| 0 | `#000080` | 8 | `#5f7f5f` |
| 1 | `#aa0000` | 9 | `#ff5555` |
| 2 | `#00aa00` | 10 | `#00ff00` |
| 3 | `#aaaa00` | 11 | `#ffff55` |
| 4 | `#0000aa` | 12 | `#5555ff` |
| 5 | `#aa00aa` | 13 | `#ff55ff` |
| 6 | `#00aaaa` | 14 | `#55ffff` |
| 7 | `#a3be8c` | 15 | `#ffffff` |

程序不支持 RGB 时，优先用这组 16 色映射；支持 RGB 的程序使用上方角色的精确色值。

## 现有实现

| 配置 | 配色入口 |
|---|---|
| Ghostty | `config/ghostty/config` |
| tmux | `config/tmux/tmux.conf` |
| Ranger | `config/ranger/colorschemes/blue.py` |
| Vifm | `config/vifm/colors/papercolor-dark.vifm` |
| Atuin | `config/atuin/themes/nostalgia-green.toml` |
| fzf | `plugins/fzf/fzf.zsh`；保留终端背景 |
| Starship | `config/starship/starship.toml` |
| Nano | `config/nano/nanorc` |
| eza | 继承终端 ANSI 16 色与默认高亮 |
| Herdr | `config/herdr/config.toml` |
| Vim | `config/vim/vimrc`；使用 Vim 内置 `blue` |
| Neovim | 主题由独立的 `iamcheyan/nvim` 仓库维护；以其 Blue / Nostalgia 调色板为来源 |

修改现有配置时同步更新对应配置说明；新增终端工具时先给它映射上面的颜色角色，并把新配置链接到本标准。

<!-- lang:en -->
> Summary: The shared color standard for terminal interfaces in this repository, based on the Nostalgia palette used by Neovim Blue.

# Unified Terminal Color Standard

This page is the **single source of truth** for terminal tool colors in dotfiles. When adding or changing a terminal interface, choose colors according to the roles here. Neovim Blue / Nostalgia is the standard source; Ghostty, tmux, Ranger, Vifm, Atuin, fzf, Starship, Nano, and Herdr configurations should coordinate with it.

## Core Colors

| Role | Color | Use |
|---|---|---|
| Main background | `#0000aa` | Editing areas, main TUI canvas |
| Main text | `#ffff55` | General text on blue backgrounds |
| Current line / secondary blue surface | `#000080` | Current line, inactive panes, tab backgrounds |
| Selection background | `#1e1ec8` | Search or text selections |
| Cyan accent | `#55ffff` | Line numbers, separators, navigation and borders |
| Bright cyan | `#00ffff` | Accent text such as directories and clickable items |
| Active title surface | `#00aa00` | Active tabs and title bars; use `#000000` for text |
| Status bar cyan surface | `#00aaaa` | Status bars; use `#000000` for text |
| Status green surface | `#00aa00` | Success states or primary confirmation actions; use `#ffffff` for text |
| Bright green | `#00ff00` | Positive states such as staged files and executables |
| Warning yellow | `#ffff55` / `#ffff00` | Warnings, matches, important information |
| Error red | `#ff5555` | Errors, failures, conflicts |
| Error background | `#aa0000` | Error areas needing clear emphasis; use white text |
| Muted green | `#a3be8c` | Secondary, unavailable, or low-priority text |
| Structural dark blue | `#000064` | Decorative lines and other non-text details only; never body text on a blue background |

These colors represent roles. When an interface does not support background colors, preserve the terminal's default background and apply foreground colors only. Do not force every program to paint a background for visual uniformity. Use the main background and text only for TUIs that need a solid canvas.

## Color Semantics

- Keep success/staged states green, warnings/changes yellow, and errors/deletions/conflicts red.
- Use cyan for navigation, directories, boundaries, and interactive emphasis; use yellow for general text and information that needs attention.
- Make active items clearly distinct in both foreground and background. Do not put dark blue text on the main blue background. Use muted green for secondary text and ensure it remains legible.
- New color combinations should have sufficient contrast. If text is hard to read in a screenshot, increase foreground brightness first; do not rely on bold alone.
- Applications may adjust color mappings to fit their capabilities (for example, Nano only has ANSI color names, while Ranger uses 16 terminal colors), but must preserve these role relationships.

## Ghostty ANSI 16-Color Mapping

Ghostty's ANSI palette affects `ls`, Ranger, editors, and other programs that read the terminal palette. The color indices are:

| Index | Color | Index | Color |
|---:|---|---:|---|
| 0 | `#000080` | 8 | `#5f7f5f` |
| 1 | `#aa0000` | 9 | `#ff5555` |
| 2 | `#00aa00` | 10 | `#00ff00` |
| 3 | `#aaaa00` | 11 | `#ffff55` |
| 4 | `#0000aa` | 12 | `#5555ff` |
| 5 | `#aa00aa` | 13 | `#ff55ff` |
| 6 | `#00aaaa` | 14 | `#55ffff` |
| 7 | `#a3be8c` | 15 | `#ffffff` |

For programs without RGB support, prefer this 16-color mapping. Programs with RGB support should use the exact role colors listed above.

## Existing Implementations

| Configuration | Color entry point |
|---|---|
| Ghostty | `config/ghostty/config` |
| tmux | `config/tmux/tmux.conf` |
| Ranger | `config/ranger/colorschemes/blue.py` |
| Vifm | `config/vifm/colors/papercolor-dark.vifm` |
| Atuin | `config/atuin/themes/nostalgia-green.toml` |
| fzf | `plugins/fzf/fzf.zsh`; preserve terminal background |
| Starship | `config/starship/starship.toml` |
| Nano | `config/nano/nanorc` |
| eza | Inherits terminal ANSI 16 colors and default highlights |
| Herdr | `config/herdr/config.toml` |
| Vim | `config/vim/vimrc`; uses Vim's built-in `blue` |
| Neovim | Theme maintained in the separate `iamcheyan/nvim` repository; its Blue / Nostalgia palette is the source |

When changing an existing configuration, update its documentation as well. When adding a terminal tool, first map these color roles to it, then link its configuration to this standard.

<!-- lang:ja -->
> 要約：Neovim Blue が使う Nostalgia パレットを基準とする、本リポジトリの端末インターフェース共通配色規格です。

# 端末共通配色規格

このページは dotfiles における端末ツール配色の**唯一の基準**です。端末インターフェースを追加・変更するときは、ここに示す色の役割に沿って選んでください。基準となるのは Neovim Blue / Nostalgia です。Ghostty、tmux、Ranger、Vifm、Atuin、fzf、Starship、Nano、Herdr の設定も調和させてください。

## 基本色

| 役割 | 色値 | 用途 |
|---|---|---|
| メイン背景 | `#0000aa` | 編集領域、TUI のメイン画面 |
| メイン文字 | `#ffff55` | 青い背景上の一般的な文字 |
| 現在行／サブの青い面 | `#000080` | 現在行、非アクティブな pane、タブの背景 |
| 選択背景 | `#1e1ec8` | 検索またはテキストの選択範囲 |
| シアンの強調色 | `#55ffff` | 行番号、区切り線、ナビゲーション、境界線 |
| 明るいシアン | `#00ffff` | ディレクトリやクリック可能項目などの強調文字 |
| アクティブなタイトル面 | `#00aa00` | アクティブなタブとタイトルバー。文字色は `#000000` |
| ステータスバーのシアン面 | `#00aaaa` | ステータスバー。文字色は `#000000` |
| ステータスの緑色面 | `#00aa00` | 成功状態や主要な確認操作。文字色は `#ffffff` |
| 明るい緑 | `#00ff00` | ステージ済みや実行可能ファイルなどの肯定的な状態 |
| 警告の黄色 | `#ffff55` / `#ffff00` | 警告、一致項目、重要な情報 |
| エラーの赤 | `#ff5555` | エラー、失敗、競合 |
| エラー背景 | `#aa0000` | 明確に示す必要があるエラー領域。文字色は白 |
| ミュートグリーン | `#a3be8c` | 補助的、使用不可、優先度の低い文字 |
| 構造用ダークブルー | `#000064` | 装飾線など文字以外の細部だけに使い、青い背景上の本文には使いません |

これらは色の役割を示します。背景色に対応していない画面では、端末の既定背景を維持し、前景色だけを適用してください。見た目を統一するために、すべてのプログラムへ背景色を強制しないでください。メイン背景とメイン文字を使うのは、塗りつぶし画面が必要な TUI です。

## 色の意味

- 成功／ステージ済みは緑、警告／変更は黄色、エラー／削除／競合は赤にします。
- シアンはナビゲーション、ディレクトリ、境界、操作可能項目の強調に使い、黄色は一般的な文字と注意が必要な情報に使います。
- アクティブ項目は前景と背景を明確に区別します。メインの青い背景にダークブルーの文字を置かないでください。補助的な文字にはミュートグリーンを使い、十分に読めることを確認します。
- 新しい色の組み合わせには十分なコントラストを確保してください。スクリーンショットで文字が読みにくい場合は、太字だけに頼らず、まず前景色を明るくします。
- Nano は ANSI 色名のみ、Ranger は端末の 16 色を使うなど、各アプリは機能に合わせて色値の割り当てを調整できます。ただし、色の役割の関係は保ってください。

## Ghostty ANSI 16 色の割り当て

Ghostty の ANSI パレットは `ls`、Ranger、エディターなど、端末パレットを読むプログラムに影響します。色番号は次のとおりです。

| 色番号 | 色値 | 色番号 | 色値 |
|---:|---|---:|---|
| 0 | `#000080` | 8 | `#5f7f5f` |
| 1 | `#aa0000` | 9 | `#ff5555` |
| 2 | `#00aa00` | 10 | `#00ff00` |
| 3 | `#aaaa00` | 11 | `#ffff55` |
| 4 | `#0000aa` | 12 | `#5555ff` |
| 5 | `#aa00aa` | 13 | `#ff55ff` |
| 6 | `#00aaaa` | 14 | `#55ffff` |
| 7 | `#a3be8c` | 15 | `#ffffff` |

RGB 非対応のプログラムでは、この 16 色の割り当てを優先してください。RGB 対応のプログラムでは、上記の役割に示した正確な色値を使います。

## 現在の実装

| 設定 | 配色の設定場所 |
|---|---|
| Ghostty | `config/ghostty/config` |
| tmux | `config/tmux/tmux.conf` |
| Ranger | `config/ranger/colorschemes/blue.py` |
| Vifm | `config/vifm/colors/papercolor-dark.vifm` |
| Atuin | `config/atuin/themes/nostalgia-green.toml` |
| fzf | `plugins/fzf/fzf.zsh`。端末の背景を維持します |
| Starship | `config/starship/starship.toml` |
| Nano | `config/nano/nanorc` |
| eza | 端末の ANSI 16 色とデフォルトのハイライトを継承 |
| Herdr | `config/herdr/config.toml` |
| Vim | `config/vim/vimrc`。Vim 内蔵の `blue` を使います |
| Neovim | テーマは独立した `iamcheyan/nvim` リポジトリで管理し、Blue / Nostalgia パレットを基準にします |

既存の設定を変更したら、対応する説明も更新してください。端末ツールを追加するときは、まずこの色の役割を割り当て、その設定から本規格へリンクしてください。
