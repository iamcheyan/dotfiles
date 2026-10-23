> 摘要：zsh-completions 提供额外的命令补全定义，必须在 compinit 之前加载。

# zsh-completions

## 用途

Zsh 自带一部分命令补全，但覆盖不全。`zsh-users/zsh-completions` 收集社区维护的补全定义，补充 Docker、kubectl、git 扩展、各类 CLI 的补全。

它只提供**定义文件**，不改变补全的显示方式。显示层由 fzf-tab 负责。

## 加载方式

```zsh
zsh_plugins_load_pre_compinit() {
  zinit ice blockf
  zinit light zsh-users/zsh-completions
}
```

`blockf` 是这里的关键参数。

## blockf 是什么

默认情况下，Zinit 会把插件的目录加进 `$fpath`。对于补全插件，这会带来问题：`$fpath` 里多出一个没有 `_` 前缀文件的目录，`compinit` 可能报错或产生警告。

`blockf` 阻止这个行为。插件自己的 `zsh-completions.plugin.zsh` 会用 `fpath+=` 把正确的子目录加进去，不需要 Zinit 代劳。

## 为什么必须在 compinit 之前

Zsh 的补全系统是这样工作的：

```text
compinit
  ├── 扫描 $fpath 里所有以 _ 开头的文件
  ├── 读取每个文件的 #compdef 声明
  └── 生成 ~/.zcompdump 缓存

之后加载的补全定义 → 不会自动进入缓存 → 需要 rehash 或重启
```

所以补全定义必须**先**进 `$fpath`，**再**运行 `compinit`。

本仓库的顺序：

```zsh
zsh_plugins_load_pre_compinit   # ← zsh-completions 进 fpath
source plugins/completion/completion.zsh   # ← compinit
zsh_plugins_load_post_compinit  # ← fzf-tab
```

## 能补全什么

取决于插件目录里有哪些 `_` 文件。常见的：

| 命令 | 补全内容 |
|---|---|
| `docker` | 子命令、容器名、镜像名 |
| `docker compose` | 服务名、配置项 |
| `kubectl` | 资源类型、namespace、pod 名 |
| `git` | 部分子命令的扩展参数 |
| `npm` / `yarn` | script 名、包名 |
| `systemctl` | 单元名 |
| `gh` | 子命令与参数 |

具体清单：

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | head -40
```

## 验证是否生效

```bash
# 看 fpath 里有没有补全目录
print -l $fpath | grep -i completions

# 看某个命令有没有补全函数
which _docker

# 看补全定义文件数量
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | wc -l
```

`which _docker` 有输出说明补全函数已加载。

## 与 fzf-tab 的关系

| | zsh-completions | fzf-tab |
|---|---|---|
| 提供什么 | 补全的**内容** | 补全的**界面** |
| 时机 | compinit 前 | compinit 后 |
| 没有它会怎样 | 候选里缺少子命令 | 候选以原生菜单显示 |

两者互补，缺一不可。

## 排错

**某个命令没有补全**：先确认插件里有对应文件：

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | grep -i docker
```

有文件但补全不生效，多半是 `zcompdump` 过期：

```bash
rm -f ~/.zcompdump*
exec zsh
```

**`compinit: insecure directories` 警告**：`$fpath` 里某个目录的权限不对（组或其他用户可写）。按提示 `chmod` 修正。

**补全候选为空**：`compinit` 根本没运行。检查 `plugins/completion/completion.zsh` 是否被 source。

**新装的 CLI 没有补全**：有些工具自己提供补全（比如 `gh completion -s zsh`），需要单独生成，不在这个插件里。

<!-- lang:en -->

> Summary: zsh-completions provides extra command completion definitions and must load before compinit.

# zsh-completions

## Purpose

Zsh ships with some command completions, but coverage is incomplete. `zsh-users/zsh-completions` collects community-maintained completion definitions, supplementing completions for Docker, kubectl, git extensions, and various CLIs.

It only provides **definition files**; it does not change how completions are displayed. The display layer is fzf-tab's job.

## How It Loads

```zsh
zsh_plugins_load_pre_compinit() {
  zinit ice blockf
  zinit light zsh-users/zsh-completions
}
```

`blockf` is the key parameter here.

## What blockf Is

By default, Zinit adds the plugin's directory to `$fpath`. For a completion plugin this causes a problem: `$fpath` gains a directory without `_`-prefixed files, and `compinit` may error or emit warnings.

`blockf` prevents this behavior. The plugin's own `zsh-completions.plugin.zsh` uses `fpath+=` to add the correct subdirectory, so Zinit does not need to do it.

## Why It Must Come Before compinit

Zsh's completion system works like this:

```text
compinit
  ├── 扫描 $fpath 里所有以 _ 开头的文件
  ├── 读取每个文件的 #compdef 声明
  └── 生成 ~/.zcompdump 缓存

之后加载的补全定义 → 不会自动进入缓存 → 需要 rehash 或重启
```

So completion definitions must enter `$fpath` **before** `compinit` runs.

This repository's order:

```zsh
zsh_plugins_load_pre_compinit   # ← zsh-completions 进 fpath
source plugins/completion/completion.zsh   # ← compinit
zsh_plugins_load_post_compinit  # ← fzf-tab
```

## What It Can Complete

Depends on which `_` files exist in the plugin directory. Common ones:

| Command | Completion contents |
|---|---|
| `docker` | Subcommands, container names, image names |
| `docker compose` | Service names, configuration options |
| `kubectl` | Resource types, namespaces, pod names |
| `git` | Extended arguments for some subcommands |
| `npm` / `yarn` | Script names, package names |
| `systemctl` | Unit names |
| `gh` | Subcommands and arguments |

For the concrete list:

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | head -40
```

## Verifying It Works

```bash
# 看 fpath 里有没有补全目录
print -l $fpath | grep -i completions

# 看某个命令有没有补全函数
which _docker

# 看补全定义文件数量
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | wc -l
```

If `which _docker` produces output, the completion function is loaded.

## Relationship with fzf-tab

| | zsh-completions | fzf-tab |
|---|---|---|
| What it provides | The **content** of completions | The **interface** of completions |
| Timing | Before compinit | After compinit |
| Without it | Candidates miss subcommands | Candidates display in the native menu |

The two complement each other; both are needed.

## Troubleshooting

**A command has no completion**: first confirm the plugin has the corresponding file:

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | grep -i docker
```

If the file exists but completion does not work, the `zcompdump` is most likely stale:

```bash
rm -f ~/.zcompdump*
exec zsh
```

**`compinit: insecure directories` warning**: some directory in `$fpath` has wrong permissions (group or others can write). Fix it with `chmod` as the message suggests.

**Completion candidates are empty**: `compinit` never ran. Check whether `plugins/completion/completion.zsh` is sourced.

**A newly installed CLI has no completion**: some tools provide their own completions (e.g. `gh completion -s zsh`) and must be generated separately; they are not part of this plugin.

<!-- lang:ja -->

> 要約：zsh-completions は追加のコマンド補完定義を提供し、compinit の前に読み込む必要があります。

# zsh-completions

## 用途

Zsh には一部のコマンド補完が組み込まれていますが、網羅は不十分です。`zsh-users/zsh-completions` はコミュニティが保守する補完定義を集め、Docker・kubectl・git の拡張・各種 CLI の補完を補います。

提供するのは**定義ファイル**だけです。補完の表示方法は変えません。表示層は fzf-tab の担当です。

## 読み込み方法

```zsh
zsh_plugins_load_pre_compinit() {
  zinit ice blockf
  zinit light zsh-users/zsh-completions
}
```

ここで重要なパラメータが `blockf` です。

## blockf とは

既定では Zinit はプラグインのディレクトリを `$fpath` に加えます。補完プラグインではこれが問題になります。`_` で始まるファイルがないディレクトリが `$fpath` に増え、`compinit` がエラーや警告を出すことがあります。

`blockf` はこの挙動を防ぎます。プラグイン自身の `zsh-completions.plugin.zsh` が `fpath+=` で正しいサブディレクトリを追加するので、Zinit が代行する必要はありません。

## なぜ compinit の前でなければならないのか

Zsh の補完システムは次のように動作します：

```text
compinit
  ├── 扫描 $fpath 里所有以 _ 开头的文件
  ├── 读取每个文件的 #compdef 声明
  └── 生成 ~/.zcompdump 缓存

之后加载的补全定义 → 不会自动进入缓存 → 需要 rehash 或重启
```

したがって補完定義は、`compinit` を実行する**前に** `$fpath` に入っている必要があります。

本リポジトリの順序：

```zsh
zsh_plugins_load_pre_compinit   # ← zsh-completions 进 fpath
source plugins/completion/completion.zsh   # ← compinit
zsh_plugins_load_post_compinit  # ← fzf-tab
```

## 何を補完できるか

プラグインディレクトリにどの `_` ファイルがあるか次第です。よくあるもの：

| コマンド | 補完内容 |
|---|---|
| `docker` | サブコマンド、コンテナ名、イメージ名 |
| `docker compose` | サービス名、設定項目 |
| `kubectl` | リソースタイプ、namespace、pod 名 |
| `git` | 一部のサブコマンドの拡張引数 |
| `npm` / `yarn` | script 名、パッケージ名 |
| `systemctl` | ユニット名 |
| `gh` | サブコマンドと引数 |

具体的な一覧は：

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | head -40
```

## 有効かどうかの確認

```bash
# 看 fpath 里有没有补全目录
print -l $fpath | grep -i completions

# 看某个命令有没有补全函数
which _docker

# 看补全定义文件数量
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | wc -l
```

`which _docker` に出力があれば補完関数は読み込まれています。

## fzf-tab との関係

| | zsh-completions | fzf-tab |
|---|---|---|
| 提供するもの | 補完の**内容** | 補完の**インターフェース** |
| タイミング | compinit の前 | compinit の後 |
| ない場合 | 候補にサブコマンドが欠ける | 候補がネイティブメニューで表示される |

両者は補完関係にあり、どちらか一方だけでは成り立ちません。

## トラブルシューティング

**あるコマンドの補完がない**：まずプラグインに対応ファイルがあるか確認します：

```bash
ls ~/.zinit/plugins/zsh-users---zsh-completions/src/ | grep -i docker
```

ファイルはあるのに補完が効かない場合は、たいてい `zcompdump` が古くなっています：

```bash
rm -f ~/.zcompdump*
exec zsh
```

**`compinit: insecure directories` の警告**：`$fpath` 内のどこかのディレクトリの権限が正しくありません（グループまたは他ユーザーが書き込み可能）。メッセージに従って `chmod` で修正します。

**補完候補が空**：`compinit` がそもそも実行されていません。`plugins/completion/completion.zsh` が source されているか確認します。

**新しく入れた CLI に補完がない**：自分で補完を提供するツールもあります（たとえば `gh completion -s zsh`）。それらは別途生成が必要で、このプラグインには含まれません。
