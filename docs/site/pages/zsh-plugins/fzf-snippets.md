> 摘要：通过 Zinit snippet 加载 fzf 官方的补全脚本与键绑定脚本，提供 Ctrl+T、Alt+C、Ctrl+R。

# fzf 补全与键绑定

## 用途

fzf 二进制本身只是一个筛选器，它不注册任何 shell 快捷键。`Ctrl+T`、`Alt+C`、`Ctrl+R` 来自两个官方脚本：

| 脚本 | 提供 |
|---|---|
| `completion.zsh` | `fzf` 命令本身的补全 |
| `key-bindings.zsh` | `Ctrl+T`、`Alt+C`、`Ctrl+R` |

## 加载方式

```zsh
# fzf（使用系统安装的 fzf，这里只加载补全和键绑定）
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh

zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`as"completion"` 告诉 Zinit：这是补全脚本，加载时不要当普通插件处理。

注意 fzf 二进制的安装被注释掉了：

```zsh
# zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
# zinit light junegunn/fzf
```

本仓库用系统包或 `init.sh` 安装的 fzf，Zinit 只负责加载这两个脚本。

## 三个快捷键

### Ctrl+T

把选中的文件路径插入当前命令行。

```text
$ vim <Ctrl+T>
→ 弹出 fzf 文件列表
→ 选中 file.txt
$ vim file.txt
```

支持多选，多个路径以空格分隔插入。

### Alt+C

选择目录并 `cd` 过去。

```text
$ <Alt+C>
→ 弹出目录选择器
→ 选中 ~/projects/foo
$ pwd
/home/user/projects/foo
```

只列目录，不列文件。

### Ctrl+R

搜索命令历史，选中后插入命令行。

```text
$ <Ctrl+R>
→ 弹出历史搜索
→ 输入 git
→ 选中 git status
$ git status
```

**注意**：本仓库的 `Ctrl+R` 可能被 Atuin 接管。用 `bindkey '^R'` 确认当前绑定。

## 兜底加载

`plugins/fzf/fzf.zsh` 里还有一层：

```zsh
if [[ -e /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
elif [[ -e /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -e /usr/share/fzf/shell/completion.zsh ]]; then
    source /usr/share/fzf/shell/completion.zsh
elif [[ -e /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi
```

系统包安装的 fzf 通常自带这些脚本。两层都加载不会冲突——后加载的覆盖同名 widget。

## 与 FZF_DEFAULT_OPTS 的关系

三个快捷键都会读 `FZF_DEFAULT_OPTS`：

```zsh
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

所以按 `Ctrl+T` 时也有右侧预览。

`FZF_CTRL_T_COMMAND` 控制 `Ctrl+T` 的候选来源：

```zsh
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
```

## 与 `f` / `ffd` 的区别

| | 快捷键 | `f` / `ffd` |
|---|---|---|
| 触发 | `Ctrl+T` 等 | 手动输入命令 |
| 行为 | 插入路径到命令行 | 直接打开文件/目录 |
| 定义位置 | 上游脚本 | `plugins/fzf/fzf.zsh` |
| 可定制性 | 低 | 高 |

快捷键适合「我已经在写命令，需要补一个路径」；`f` 适合「我要去某个文件」。

## 排错

**`Ctrl+T` 没反应**：key-bindings 没加载。检查 `zinit list` 里有没有 snippet 条目。

**`Ctrl+T` 插入路径但预览空白**：`bat` 不可用，或 `FZF_DEFAULT_OPTS` 里的预览命令失败。

**`Alt+C` 后目录没变**：某些终端把 `Alt+C` 解释成别的键。可以改用 `Alt+C` 的替代绑定：

```zsh
bindkey '^[c' fzf-cd-widget
```

**`Ctrl+R` 行为不是 fzf**：被 Atuin 接管了。`bindkey '^R'` 查看。

**snippet 下载失败**：Zinit 需要网络。首次启动时检查连接，或手动 `zinit update`。

**重复定义 widget 警告**：两个来源都加载了。通常无害，后加载的覆盖前面的。

<!-- lang:en -->

> Summary: Loads fzf's official completion and key-binding scripts via a Zinit snippet, providing Ctrl+T, Alt+C, and Ctrl+R.

# fzf completion and key bindings

## Purpose

The fzf binary itself is only a filter; it registers no shell shortcuts. `Ctrl+T`, `Alt+C`, and `Ctrl+R` come from two official scripts:

| Script | Provides |
|---|---|
| `completion.zsh` | Completion for the `fzf` command itself |
| `key-bindings.zsh` | `Ctrl+T`, `Alt+C`, `Ctrl+R` |

## Loading

```zsh
# fzf（使用系统安装的 fzf，这里只加载补全和键绑定）
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh

zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`as"completion"` tells Zinit: this is a completion script, do not treat it as a regular plugin when loading.

Note that installing the fzf binary is commented out:

```zsh
# zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
# zinit light junegunn/fzf
```

This repo uses the fzf installed by the system package or `init.sh`; Zinit is only responsible for loading these two scripts.

## The three shortcuts

### Ctrl+T

Inserts the selected file path into the current command line.

```text
$ vim <Ctrl+T>
→ 弹出 fzf 文件列表
→ 选中 file.txt
$ vim file.txt
```

Multi-select is supported; multiple paths are inserted separated by spaces.

### Alt+C

Selects a directory and `cd`s into it.

```text
$ <Alt+C>
→ 弹出目录选择器
→ 选中 ~/projects/foo
$ pwd
/home/user/projects/foo
```

Only directories are listed, not files.

### Ctrl+R

Searches the command history and inserts the selected command into the command line.

```text
$ <Ctrl+R>
→ 弹出历史搜索
→ 输入 git
→ 选中 git status
$ git status
```

**Note**: in this repo `Ctrl+R` may be taken over by Atuin. Use `bindkey '^R'` to check the current binding.

## Fallback loading

`plugins/fzf/fzf.zsh` has one more layer:

```zsh
if [[ -e /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
elif [[ -e /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -e /usr/share/fzf/shell/completion.zsh ]]; then
    source /usr/share/fzf/shell/completion.zsh
elif [[ -e /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi
```

fzf installed by the system package usually ships with these scripts. Loading both layers does not conflict — widgets loaded later override identically named ones.

## Relationship with FZF_DEFAULT_OPTS

All three shortcuts read `FZF_DEFAULT_OPTS`:

```zsh
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

So pressing `Ctrl+T` also shows the right-side preview.

`FZF_CTRL_T_COMMAND` controls the candidates for `Ctrl+T`:

```zsh
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
```

## Difference from `f` / `ffd`

| | Shortcuts | `f` / `ffd` |
|---|---|---|
| Trigger | `Ctrl+T` etc. | Manually typing a command |
| Behavior | Inserts a path into the command line | Directly opens a file/directory |
| Defined in | Upstream scripts | `plugins/fzf/fzf.zsh` |
| Customizability | Low | High |

Shortcuts suit "I am already writing a command and need to fill in a path"; `f` suits "I want to go to a file".

## Troubleshooting

**`Ctrl+T` does nothing**: key-bindings are not loaded. Check whether there are snippet entries in `zinit list`.

**`Ctrl+T` inserts the path but the preview is blank**: `bat` is unavailable, or the preview command in `FZF_DEFAULT_OPTS` failed.

**Directory unchanged after `Alt+C`**: some terminals interpret `Alt+C` as a different key. You can add an alternative binding for `Alt+C`:

```zsh
bindkey '^[c' fzf-cd-widget
```

**`Ctrl+R` does not behave like fzf**: it was taken over by Atuin. Check with `bindkey '^R'`.

**Snippet download failed**: Zinit needs network. Check the connection on first startup, or run `zinit update` manually.

**Duplicate widget definition warnings**: both sources were loaded. Usually harmless; the later one overrides the earlier.

<!-- lang:ja -->

> 要約：Zinit snippet で fzf 公式の補完スクリプトとキーバインドスクリプトを読み込み、Ctrl+T・Alt+C・Ctrl+R を提供します。

# fzf 補完とキーバインド

## 用途

fzf バイナリ自体はフィルタにすぎず、シェルのショートカットキーは何も登録しません。`Ctrl+T`、`Alt+C`、`Ctrl+R` は2つの公式スクリプトから来ています：

| スクリプト | 提供するもの |
|---|---|
| `completion.zsh` | `fzf` コマンド自体の補完 |
| `key-bindings.zsh` | `Ctrl+T`、`Alt+C`、`Ctrl+R` |

## 読み込み方法

```zsh
# fzf（使用系统安装的 fzf，这里只加载补全和键绑定）
zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/completion.zsh

zinit ice as"completion"
zinit snippet https://github.com/junegunn/fzf/raw/master/shell/key-bindings.zsh
```

`as"completion"` は Zinit に「これは補完スクリプトであり、読み込み時に通常のプラグインとして扱わない」ことを伝えます。

fzf バイナリのインストールはコメントアウトされている点にも注意してください：

```zsh
# zinit ice from"gh-r" as"command" bpick"*linux_arm64.tar.gz"
# zinit light junegunn/fzf
```

本リポジトリではシステムパッケージか `init.sh` でインストールされた fzf を使い、Zinit はこの2つのスクリプトの読み込みだけを担います。

## 3つのショートカットキー

### Ctrl+T

選択したファイルパスを現在のコマンドラインに挿入します。

```text
$ vim <Ctrl+T>
→ 弹出 fzf 文件列表
→ 选中 file.txt
$ vim file.txt
```

複数選択に対応しており、複数のパスは空白区切りで挿入されます。

### Alt+C

ディレクトリを選んでそこへ `cd` します。

```text
$ <Alt+C>
→ 弹出目录选择器
→ 选中 ~/projects/foo
$ pwd
/home/user/projects/foo
```

ファイルではなくディレクトリのみ表示されます。

### Ctrl+R

コマンド履歴を検索し、選んだコマンドをコマンドラインに挿入します。

```text
$ <Ctrl+R>
→ 弹出历史搜索
→ 输入 git
→ 选中 git status
$ git status
```

**注意**：本リポジトリの `Ctrl+R` は Atuin に奪われている可能性があります。`bindkey '^R'` で現在のバインドを確認してください。

## フォールバック読み込み

`plugins/fzf/fzf.zsh` にはさらに1層あります：

```zsh
if [[ -e /usr/share/fzf/shell/key-bindings.zsh ]]; then
    source /usr/share/fzf/shell/key-bindings.zsh
elif [[ -e /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
fi

if [[ -e /usr/share/fzf/shell/completion.zsh ]]; then
    source /usr/share/fzf/shell/completion.zsh
elif [[ -e /usr/share/fzf/completion.zsh ]]; then
    source /usr/share/fzf/completion.zsh
fi
```

システムパッケージで入った fzf は通常これらのスクリプトを同梱しています。両層を読み込んでも衝突しません——後から読み込まれた方が同名のウィジェットを上書きします。

## FZF_DEFAULT_OPTS との関係

3つのショートカットはいずれも `FZF_DEFAULT_OPTS` を読みます：

```zsh
export FZF_DEFAULT_OPTS="--height 90% --layout=reverse --border --wrap \
  --preview '([[ -d {} ]] && ls -F --color=always {}) || ([[ -f {} ]] && bat --style=numbers --color=always --line-range :300 {})' \
  --preview-window=right:40%"
```

そのため `Ctrl+T` を押したときも右側にプレビューが出ます。

`FZF_CTRL_T_COMMAND` は `Ctrl+T` の候補ソースを制御します：

```zsh
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
```

## `f` / `ffd` との違い

| | ショートカットキー | `f` / `ffd` |
|---|---|---|
| 発動 | `Ctrl+T` など | 手動でコマンドを入力 |
| 動作 | パスをコマンドラインに挿入 | ファイル/ディレクトリを直接開く |
| 定義場所 | 上流スクリプト | `plugins/fzf/fzf.zsh` |
| カスタマイズ性 | 低い | 高い |

ショートカットは「もうコマンドを書いていて、パスを1つ補いたい」場合に向き、`f` は「あるファイルへ行きたい」場合に向いています。

## トラブルシューティング

**`Ctrl+T` が反応しない**：key-bindings が読み込まれていません。`zinit list` に snippet の項目があるか確認します。

**`Ctrl+T` はパスを挿入するがプレビューが空白**：`bat` が使えないか、`FZF_DEFAULT_OPTS` 内のプレビューコマンドが失敗しています。

**`Alt+C` の後もディレクトリが変わらない**：一部の端末は `Alt+C` を別のキーとして解釈します。`Alt+C` の代替バインドを追加できます：

```zsh
bindkey '^[c' fzf-cd-widget
```

**`Ctrl+R` の挙動が fzf ではない**：Atuin に奪われています。`bindkey '^R'` で確認します。

**snippet のダウンロードに失敗**：Zinit にはネットワークが必要です。初回起動時に接続を確認するか、手動で `zinit update` を実行します。

**ウィジェットの重複定義の警告**：両方のソースが読み込まれています。通常は無害で、後から読み込まれた方が上書きします。
