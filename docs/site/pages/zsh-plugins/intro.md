> 摘要：Zsh 插件的加载阶段、顺序约束和逐项说明入口。

# 本章导读

## 插件全景

`plugins/zsh-plugins.zsh` 加载 9 个 Zsh 插件仓库；CLI 二进制在 `plugins/tools/tools.zsh` 中单独管理，不计入插件数。插件按 Zsh 初始化约束分阶段加载。

| 阶段 | 插件 | 为什么在这个位置 |
|---|---|---|
| compinit 前 | zsh-completions | 补全定义必须先进入 `$fpath` |
| compinit 后 | fzf-tab | 需要 `compinit` 建立的补全系统 |
| main 阶段 | evalcache | 缓存后续 hook 的输出 |
| main 阶段 | zsh-vi-mode | 必须在 autosuggestions 之前，避免键位冲突 |
| main 阶段 | zsh-abbr | 提供命令行缩写；键位在 `zvm_after_init` 里统一绑定 |
| main 阶段 | zsh-autosuggestions | 依赖 vi-mode 的键位已就位 |
| main 阶段 | zsh-autopair | 无顺序依赖 |
| main 阶段 | forgit | 依赖 fzf |
| main 阶段 | zsh-syntax-highlighting | **必须最后**，否则 hook 被覆盖 |
| 任意 | Zinit 本体 | 一切的前提 |
| 任意 | fzf 补全/键绑定 snippet | 上游脚本，非插件 |
| 运行时 | navi / Pet hook | 工具装了才接入 |

## 为什么顺序不能乱

三个硬约束：

1. **compinit 之前必须有 zsh-completions**。`compinit` 扫描 `$fpath` 生成补全缓存，之后再加载的补全定义不会自动生效。
2. **fzf-tab 必须在 compinit 之后**。它替换的是补全菜单的显示层，没有补全系统就没有可替换的东西。
3. **syntax-highlighting 必须最后**。它通过 `zle` 的 `line-pre-redraw` hook 上色，任何在它之后设置 hook 的插件都会打断着色。

违反任一条，症状都很隐蔽：不报错，只是功能静默失效。

## 阅读顺序

| 想了解 | 读哪篇 |
|---|---|
| 插件怎么装、怎么更新 | [Zinit](zinit.html) |
| Tab 补全不好用 | [zsh-completions](zsh-completions.html)、[fzf-tab](fzf-tab.html) |
| 启动太慢 | [evalcache](evalcache.html) |
| 命令行 Vim 键位 | [zsh-vi-mode](vi-mode.html) |
| 命令行缩写 | [zsh-abbr](zsh-abbr.html) |
| 建议文字颜色/行为 | [zsh-autosuggestions](autosuggestions.html) |
| 括号自动补全 | [zsh-autopair](autopair.html) |
| Git 交互命令 | [forgit](forgit.html) |
| 语法高亮失效 | [zsh-syntax-highlighting](syntax-highlighting.html) |
| `Ctrl+T` / `Ctrl+R` | [fzf 补全与键绑定](fzf-snippets.html) |
| `f`、`Ctrl+X Ctrl+R` 从哪来 | [可选工具集成](tool-hooks.html) |

## 加一个插件的流程

```bash
$EDITOR ~/dotfiles/plugins/zsh-plugins.zsh
```

1. 判断它属于哪个阶段，放进对应的 `zsh_plugins_load_*` 函数。
2. `zinit light owner/repo`，需要参数时先 `zinit ice`。
3. 把该插件的环境变量、`zstyle`、hook 紧挨着写在下面，不要分散到别的文件。
4. 检查：

```bash
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ~/dotfiles/zshrc >/dev/null 2>&1; true'
```

## 一条设计原则

所有可选集成都是「先探测、再加载」：

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

工具没装时什么也不做，shell 照常启动。这条规则让整个配置在没有 Zinit 缓存、没有额外工具的新机器上也能启动。

<!-- lang:en -->

> Summary: Zsh plugin load stages, ordering constraints, and links to each plugin guide.

## Chapter Guide

## Plugin Overview

`plugins/zsh-plugins.zsh` loads 9 Zsh plugin repositories; CLI binaries are managed separately in `plugins/tools/tools.zsh` and are not included in that count. Plugins load in stages to respect Zsh initialization constraints.

| Stage | Plugin | Why it is at this position |
|---|---|---|
| Before compinit | zsh-completions | Completion definitions must enter `$fpath` first |
| After compinit | fzf-tab | Requires the completion system built by `compinit` |
| main stage | evalcache | Caches the output of later hooks |
| main stage | zsh-vi-mode | Must come before autosuggestions to avoid keybinding conflicts |
| main stage | zsh-abbr | Provides command-line abbreviations; keybindings are centralized in `zvm_after_init` |
| main stage | zsh-autosuggestions | Depends on vi-mode's keybindings being in place |
| main stage | zsh-autopair | No ordering dependency |
| main stage | forgit | Depends on fzf |
| main stage | zsh-syntax-highlighting | **Must be last**, otherwise hooks get overwritten |
| Any | Zinit itself | The prerequisite for everything |
| Any | fzf completion/keybinding snippet | Upstream script, not a plugin |
| Runtime | navi / Pet hook | Wired in only when the tool is installed |

## Why the Order Cannot Change

Three hard constraints:

1. **zsh-completions must come before compinit**. `compinit` scans `$fpath` to build the completion cache; completion definitions loaded afterwards do not take effect automatically.
2. **fzf-tab must come after compinit**. It replaces the display layer of the completion menu; without the completion system there is nothing to replace.
3. **syntax-highlighting must be last**. It colors the line via the `zle` `line-pre-redraw` hook; any plugin that sets a hook after it will interrupt the coloring.

If any of these is violated, the symptoms are subtle: no error is raised, features just silently stop working.

## Reading Order

| If you want to know | Read |
|---|---|
| How plugins are installed and updated | [Zinit](zinit.html) |
| Tab completion not working well | [zsh-completions](zsh-completions.html), [fzf-tab](fzf-tab.html) |
| Startup is too slow | [evalcache](evalcache.html) |
| Vim keybindings on the command line | [zsh-vi-mode](vi-mode.html) |
| Command-line abbreviations | [zsh-abbr](zsh-abbr.html) |
| Suggestion text color/behavior | [zsh-autosuggestions](autosuggestions.html) |
| Automatic bracket closing | [zsh-autopair](autopair.html) |
| Interactive Git commands | [forgit](forgit.html) |
| Syntax highlighting broken | [zsh-syntax-highlighting](syntax-highlighting.html) |
| `Ctrl+T` / `Ctrl+R` | [fzf completion and keybindings](fzf-snippets.html) |
| Where `f`, `Ctrl+X Ctrl+R` come from | [Optional tool integration](tool-hooks.html) |

## How to Add a Plugin

```bash
$EDITOR ~/dotfiles/plugins/zsh-plugins.zsh
```

1. Determine which stage it belongs to and put it into the corresponding `zsh_plugins_load_*` function.
2. Run `zinit light owner/repo`; use `zinit ice` first if parameters are needed.
3. Write the plugin's environment variables, `zstyle`, and hooks right below it; do not scatter them into other files.
4. Check:

```bash
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ~/dotfiles/zshrc >/dev/null 2>&1; true'
```

## One Design Principle

All optional integrations follow "probe first, then load":

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

When a tool is not installed, nothing happens and the shell starts as usual. This rule lets the whole configuration start even on a new machine without the Zinit cache or extra tools.

<!-- lang:ja -->

> 要約：Zsh プラグインの読み込み段階、順序の制約、各ガイドへのリンク。

## 本章のガイド

## プラグイン全体像

`plugins/zsh-plugins.zsh` は 9 個の Zsh プラグインリポジトリを読み込みます。CLI バイナリは `plugins/tools/tools.zsh` で別に管理し、この数には含めません。プラグインは Zsh の初期化順序に合わせて段階的に読み込みます。

| 段階 | プラグイン | この位置にある理由 |
|---|---|---|
| compinit の前 | zsh-completions | 補完定義は先に `$fpath` に入る必要がある |
| compinit の後 | fzf-tab | `compinit` が構築した補完システムが必要 |
| main 段階 | evalcache | 後続の hook の出力をキャッシュ |
| main 段階 | zsh-vi-mode | キーバインドの衝突を避けるため autosuggestions より前であること |
| main 段階 | zsh-abbr | コマンドライン略語を提供し、キー設定は `zvm_after_init` に集約 |
| main 段階 | zsh-autosuggestions | vi-mode のキーバインドが整っていることに依存 |
| main 段階 | zsh-autopair | 順序の依存なし |
| main 段階 | forgit | fzf に依存 |
| main 段階 | zsh-syntax-highlighting | **必ず最後**。そうでないと hook が上書きされる |
| 任意 | Zinit 本体 | すべての前提 |
| 任意 | fzf 補完/キーバインド snippet | 上流スクリプトでありプラグインではない |
| 実行時 | navi / Pet hook | ツールが入っていれば接続 |

## なぜ順序を変えてはいけないのか

三つのハードな制約があります：

1. **compinit の前に zsh-completions が必要**。`compinit` は `$fpath` を走査して補完キャッシュを生成します。その後に読み込まれた補完定義は自動的には有効になりません。
2. **fzf-tab は compinit の後でなければならない**。置き換えるのは補完メニューの表示層であり、補完システムがなければ置き換える対象が存在しません。
3. **syntax-highlighting は最後でなければならない**。`zle` の `line-pre-redraw` hook を通じて着色しており、それより後に hook を設定するプラグインは着色を壊します。

いずれかに違反しても症状はわかりにくいです。エラーが出るのではなく、機能が黙って無効になるだけです。

## 読む順序

| 知りたいこと | 読むページ |
|---|---|
| プラグインの導入・更新方法 | [Zinit](zinit.html) |
| Tab 補全が使いにくい | [zsh-completions](zsh-completions.html)、[fzf-tab](fzf-tab.html) |
| 起動が遅い | [evalcache](evalcache.html) |
| コマンドラインの Vim キーバインド | [zsh-vi-mode](vi-mode.html) |
| コマンドライン略語 | [zsh-abbr](zsh-abbr.html) |
| 補完候補の文字色/挙動 | [zsh-autosuggestions](autosuggestions.html) |
| 括弧の自動補完 | [zsh-autopair](autopair.html) |
| Git の対話コマンド | [forgit](forgit.html) |
| シンタックスハイライトが効かない | [zsh-syntax-highlighting](syntax-highlighting.html) |
| `Ctrl+T` / `Ctrl+R` | [fzf 補完とキーバインド](fzf-snippets.html) |
| `f`、`Ctrl+X Ctrl+R` の由来 | [オプションツール統合](tool-hooks.html) |

## プラグイン追加の手順

```bash
$EDITOR ~/dotfiles/plugins/zsh-plugins.zsh
```

1. どの段階に属するかを判断し、対応する `zsh_plugins_load_*` 関数に入れます。
2. `zinit light owner/repo` を実行します。パラメータが必要なら先に `zinit ice` を書きます。
3. そのプラグインの環境変数・`zstyle`・hook は直下にまとめて書き、別のファイルに分散させません。
4. チェックします：

```bash
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
TERM=xterm-256color zsh -lic 'source ~/dotfiles/zshrc >/dev/null 2>&1; true'
```

## 一つの設計原則

オプションの統合はすべて「先に検出してから読み込む」方式です：

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

ツールが入っていなければ何もせず、シェルは通常どおり起動します。このルールのおかげで、Zinit のキャッシュも追加ツールもない新しいマシンでも設定全体を起動できます。
