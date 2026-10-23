> 摘要：navi 搜索 cheatsheet 并填写参数，把命令放回命令行再执行。

# navi

## 用途

`navi` 是一个交互式 cheatsheet 浏览器：你搜索「怎么解压 tar」，它列出相关命令，选中后按提示填参数，最后把命令送到命令行。

它解决的是「记不住语法但知道要干什么」的问题。

## 来源与安装

| 项目 | 说明 |
|---|---|
| 来源 | Zinit，从 GitHub Release 下载 |
| shell 集成 | `plugins/zsh-plugins.zsh` 里的 `zsh_plugins_load_shell_tools` |
| cheatsheet 目录 | 默认 `~/.local/share/navi/cheats/` |

```zsh
zi_cmd denisidoro/navi navi
```

## shell 集成

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

有 `command -v` 判断，navi 没装时静默跳过，不影响 shell 启动。

## 基本用法

```bash
navi                    # 打开交互界面
navi --print            # 只打印命令，不执行
navi --query git        # 带初始查询
navi --tldr             # 用 tldr 页面作为数据源
navi fn widget::last_command   # 在 widget 里调用
```

## 交互界面

| 键 | 作用 |
|---|---|
| 输入 | 模糊搜索 |
| `↑` / `↓` | 移动 |
| `Enter` | 选中，进入参数填写 |
| `Ctrl+O` | 切换来源 |
| `Esc` | 退出 |

选中后会显示该条目需要的参数，逐个填写。填完后命令写入当前命令行（不是直接执行），可以先改再回车。

## cheatsheet 格式

`.cheat` 文件是纯文本：

```text
% git, branch

# 创建并切换到分支
 git switch -c <branch>

$ branch: git branch --format='%(refname:short)'
```

| 语法 | 含义 |
|---|---|
| `% 标签1, 标签2` | 分组标签 |
| `# 说明` | 注释 |
| 缩进的行 | 命令模板 |
| `<name>` | 待填参数 |
| `$ name: 命令` | 参数候选值来源 |

`$ branch: git branch ...` 会用该命令的输出作为候选，让你从现有分支里选，而不是手打。

## 仓库管理

```bash
navi repo add denisidoro/cheats     # 添加社区 cheatsheet 仓库
navi repo browse                    # 浏览可用仓库
navi repo browse --list             # 列出已添加的
```

首次使用时 navi 会提示导入 cheatsheet 仓库。

## 配置

```bash
navi info config-path     # 配置路径
```

默认在 `~/.config/navi/config.yaml`：

```yaml
cheats:
  paths:
    - ~/.local/share/navi/cheats
    - ~/dotfiles/cheats

style:
  tag:
    color: cyan
  comment:
    color: white
```

`cheats.paths` 可以指向多个目录，方便把项目自己的 cheatsheet 放进去。

## 与 tldr / --help 的分工

| | tldr | navi | --help |
|---|---|---|---|
| 内容 | 社区维护的常用示例 | 你自己的 cheatsheet | 完整参数 |
| 交互 | 只读 | 可搜索、可填参 | 只读 |
| 输出 | 显示 | 送到命令行 | 显示 |
| 适合 | 学新命令 | 记住自己的常用命令 | 查参数 |

三者的关系：tldr 学通用用法，navi 存自己的高频命令，`--help` 查细节。

## 实用场景

### 存自己的常用命令

```bash
mkdir -p ~/dotfiles/cheats
cat > ~/dotfiles/cheats/deploy.cheat <<'EOF'
% deploy, k8s

# 滚动更新 deployment
 kubectl rollout restart deployment/<name> -n <namespace>

$ name: kubectl get deploy -o name | cut -d/ -f2
$ namespace: kubectl get ns -o name | cut -d/ -f2
EOF
```

然后在 navi 里搜索 `rollout` 就能找到。

### 配合 fzf 直接用

```bash
navi --print | fzf
```

## 排错

**`navi: command not found`**：Zinit 未下载。`zinit list | grep navi` 确认。

**没有 widget**：`eval "$(navi widget zsh)"` 没执行。检查 `zsh_plugins_load_shell_tools` 是否被调用。

**cheatsheet 不显示**：确认路径在 `config.yaml` 的 `cheats.paths` 里。

**参数候选为空**：`$ name: 命令` 里的命令执行失败。先单独运行它确认。

**中文显示问题**：终端字体缺 CJK。

<!-- lang:en -->

> Summary: navi searches cheat sheets and fills in parameters, placing the command back on the command line before running it.

# navi

## Purpose

`navi` is an interactive cheat sheet browser: you search for "how to extract a tar", it lists related commands, you pick one, fill in the parameters as prompted, and finally the command is handed to the command line.

It solves the problem of "not remembering the syntax but knowing what you want to do".

## Source and install

| Item | Notes |
|---|---|
| Source | Zinit, downloaded from GitHub Release |
| Shell integration | `zsh_plugins_load_shell_tools` in `plugins/zsh-plugins.zsh` |
| Cheat sheet directory | default `~/.local/share/navi/cheats/` |

```zsh
zi_cmd denisidoro/navi navi
```

## Shell integration

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

The `command -v` check means navi is skipped silently when it isn't installed, without affecting shell startup.

## Basic usage

```bash
navi                    # 打开交互界面
navi --print            # 只打印命令，不执行
navi --query git        # 带初始查询
navi --tldr             # 用 tldr 页面作为数据源
navi fn widget::last_command   # 在 widget 里调用
```

## The interactive interface

| Key | Effect |
|---|---|
| Typing | fuzzy search |
| `↑` / `↓` | move |
| `Enter` | select and move on to parameter filling |
| `Ctrl+O` | switch source |
| `Esc` | quit |

After selecting an entry, the parameters it needs are shown one by one for you to fill in. When done, the command is written into the current command line (not executed directly), so you can edit it before pressing Enter.

## Cheat sheet format

A `.cheat` file is plain text:

```text
% git, branch

# 创建并切换到分支
 git switch -c <branch>

$ branch: git branch --format='%(refname:short)'
```

| Syntax | Meaning |
|---|---|
| `% tag1, tag2` | grouping tags |
| `# comment` | comment |
| Indented lines | command template |
| `<name>` | parameter to fill in |
| `$ name: command` | source of candidate values for a parameter |

`$ branch: git branch ...` uses that command's output as the candidates, so you pick from existing branches instead of typing one by hand.

## Managing repositories

```bash
navi repo add denisidoro/cheats     # 添加社区 cheatsheet 仓库
navi repo browse                    # 浏览可用仓库
navi repo browse --list             # 列出已添加的
```

On first use navi prompts you to import a cheat sheet repository.

## Configuration

```bash
navi info config-path     # 配置路径
```

By default at `~/.config/navi/config.yaml`:

```yaml
cheats:
  paths:
    - ~/.local/share/navi/cheats
    - ~/dotfiles/cheats

style:
  tag:
    color: cyan
  comment:
    color: white
```

`cheats.paths` can point at multiple directories, which makes it easy to add a project's own cheat sheets.

## Division of labor with tldr / --help

| | tldr | navi | --help |
|---|---|---|---|
| Content | community-maintained common examples | your own cheat sheet | full flags |
| Interaction | read-only | searchable, parameter-filling | read-only |
| Output | displayed | handed to the command line | displayed |
| Good for | learning a new command | remembering your own frequent commands | looking up flags |

How the three relate: tldr for learning general usage, navi for storing your own high-frequency commands, `--help` for details.

## Practical scenarios

### Storing your own frequent commands

```bash
mkdir -p ~/dotfiles/cheats
cat > ~/dotfiles/cheats/deploy.cheat <<'EOF'
% deploy, k8s

# 滚动更新 deployment
 kubectl rollout restart deployment/<name> -n <namespace>

$ name: kubectl get deploy -o name | cut -d/ -f2
$ namespace: kubectl get ns -o name | cut -d/ -f2
EOF
```

Then searching for `rollout` in navi finds it.

### Piping through fzf

```bash
navi --print | fzf
```

## Troubleshooting

**`navi: command not found`** — Zinit hasn't downloaded it. Confirm with `zinit list | grep navi`.

**No widget** — `eval "$(navi widget zsh)"` wasn't executed. Check that `zsh_plugins_load_shell_tools` gets called.

**Cheat sheets don't show** — confirm the path is listed under `cheats.paths` in `config.yaml`.

**Empty parameter candidates** — the command in `$ name: command` failed. Run it standalone first to confirm.

**Chinese rendering problems** — the terminal font lacks CJK glyphs.

<!-- lang:ja -->

> 要約：navi はチートシートを検索してパラメータを記入し、コマンドをコマンドラインに戻してから実行します。

# navi

## 用途

`navi` はインタラクティブなチートシートブラウザです。「tar の解凍方法」で検索すると関連するコマンドが一覧表示され、選んでプロンプトに従ってパラメータを記入すると、最後にコマンドがコマンドラインに送られます。

解決するのは「やりたいことは分かるが構文を覚えていない」という問題です。

## ソースとインストール

| 項目 | 説明 |
|---|---|
| ソース | Zinit、GitHub Release からダウンロード |
| シェル統合 | `plugins/zsh-plugins.zsh` の `zsh_plugins_load_shell_tools` |
| チートシートディレクトリ | デフォルトは `~/.local/share/navi/cheats/` |

```zsh
zi_cmd denisidoro/navi navi
```

## シェル統合

```zsh
if command -v navi >/dev/null 2>&1; then
  eval "$(navi widget zsh)"
fi
```

`command -v` の判定があるため、navi が入っていなくても黙ってスキップされ、シェルの起動に影響しません。

## 基本的な使い方

```bash
navi                    # 打开交互界面
navi --print            # 只打印命令，不执行
navi --query git        # 带初始查询
navi --tldr             # 用 tldr 页面作为数据源
navi fn widget::last_command   # 在 widget 里调用
```

## インタラクティブ画面

| キー | 効果 |
|---|---|
| 入力 | 曖昧検索 |
| `↑` / `↓` | 移動 |
| `Enter` | 選択してパラメータ記入へ進む |
| `Ctrl+O` | ソースの切り替え |
| `Esc` | 終了 |

エントリを選ぶと、それに必要なパラメータが順番に表示され、1 つずつ記入します。記入が終わるとコマンドが現在のコマンドラインに書き込まれます（直接実行はされない）ので、Enter を押す前に編集できます。

## チートシートの形式

`.cheat` ファイルはプレーンテキストです：

```text
% git, branch

# 创建并切换到分支
 git switch -c <branch>

$ branch: git branch --format='%(refname:short)'
```

| 構文 | 意味 |
|---|---|
| `% タグ1, タグ2` | グループのタグ |
| `# 説明` | コメント |
| インデントされた行 | コマンドテンプレート |
| `<name>` | 記入待ちのパラメータ |
| `$ name: コマンド` | パラメータ候補の取得元 |

`$ branch: git branch ...` はそのコマンドの出力を候補として使うので、手打ちではなく既存のブランチから選べます。

## リポジトリ管理

```bash
navi repo add denisidoro/cheats     # 添加社区 cheatsheet 仓库
navi repo browse                    # 浏览可用仓库
navi repo browse --list             # 列出已添加的
```

初回利用時、navi はチートシートリポジトリのインポートを促してきます。

## 設定

```bash
navi info config-path     # 配置路径
```

デフォルトは `~/.config/navi/config.yaml` です：

```yaml
cheats:
  paths:
    - ~/.local/share/navi/cheats
    - ~/dotfiles/cheats

style:
  tag:
    color: cyan
  comment:
    color: white
```

`cheats.paths` は複数のディレクトリを指せます。プロジェクト自身のチートシートを置くのに便利です。

## tldr / --help との使い分け

| | tldr | navi | --help |
|---|---|---|---|
| 内容 | コミュニティ管理のよくある例 | 自分のチートシート | 完全なオプション |
| インタラクション | 読み取り専用 | 検索・記入ができる | 読み取り専用 |
| 出力 | 表示 | コマンドラインへ送る | 表示 |
| 向いている場面 | 新しいコマンドを学ぶ | 自分の頻出コマンドを思い出す | オプションを調べる |

3 者の関係はこうです。tldr で一般的な使い方を学び、navi に自分の頻出コマンドを保存し、`--help` で細部を調べます。

## 実用シナリオ

### 自分の頻出コマンドを保存する

```bash
mkdir -p ~/dotfiles/cheats
cat > ~/dotfiles/cheats/deploy.cheat <<'EOF'
% deploy, k8s

# 滚动更新 deployment
 kubectl rollout restart deployment/<name> -n <namespace>

$ name: kubectl get deploy -o name | cut -d/ -f2
$ namespace: kubectl get ns -o name | cut -d/ -f2
EOF
```

あとは navi で `rollout` を検索すれば見つかります。

### fzf と組み合わせて使う

```bash
navi --print | fzf
```

## トラブルシュート

**`navi: command not found`**：Zinit が未ダウンロードです。`zinit list | grep navi` で確認します。

**ウィジェットがない**：`eval "$(navi widget zsh)"` が実行されていません。`zsh_plugins_load_shell_tools` が呼ばれているか確認します。

**チートシートが表示されない**：パスが `config.yaml` の `cheats.paths` に入っているか確認します。

**パラメータ候補が空**：`$ name: コマンド` のコマンド実行に失敗しています。まず単体で実行して確認します。

**中国語の表示問題**：ターミナルのフォントに CJK がありません。
