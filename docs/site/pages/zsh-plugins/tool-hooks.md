> 摘要：navi、Pet 两个可选 CLI 工具的 shell 集成，工具缺失时静默跳过。

# 可选工具集成

## 定位

这两个不是 Zinit 插件，而是**外部 CLI 工具**。它们各自提供一段 shell 集成代码，由 `plugins/zsh-plugins.zsh` 里的 `zsh_plugins_load_shell_tools` 统一接入。

```zsh
zsh_plugins_load_shell_tools() {
  if command -v navi >/dev/null 2>&1; then
    eval "$(navi widget zsh)"
  fi

  if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
  fi
}
```

两个 `command -v` 判断是核心：工具没装就什么也不做，shell 照常启动。

## 调用时机

`zshrc` 里：

```zsh
# Load optional tool widgets after fzf, while preserving Atuin's history bindings.
zsh_plugins_load_shell_tools
```

位置在 fzf 函数加载之后、Atuin 绑定之后。原因：

| 依赖 | 说明 |
|---|---|
| fzf | navi 和 Pet 的选择界面使用 fzf |
| Atuin | 不能覆盖 `↑` 的历史绑定 |

## navi

### 集成做了什么

```zsh
eval "$(navi widget zsh)"
```

注册一个 `zle` widget，把 navi 的 cheatsheet 选择器接到命令行。选中条目后，命令写回缓冲区，不直接执行。

### 用法

| 键 | 行为 |
|---|---|
| `Ctrl+G` | 打开 navi 选择器（默认绑定） |

选中后可以继续编辑再回车。

### 依赖

| 依赖 | 用途 |
|---|---|
| `navi` | 本体 |
| `fzf` | 选择界面 |
| cheatsheet 仓库 | 内容来源 |

首次使用需要导入 cheatsheet：

```bash
navi repo add denisidoro/cheats
```

### 没装时

跳过，`Ctrl+G` 保持终端默认行为（通常是无操作）。

## Pet

### 集成做了什么

pet-select widget 将 Pet 搜索结果写回命令行，允许先检查和编辑再执行。
## 两者对比

| | navi | Pet |
|---|---|---|
| 触发 | `Ctrl+G` | `Ctrl+X Ctrl+R` |
| 数据 | cheatsheet 仓库 | 本地片段库 |
| 输出 | 写回命令行 | 写回命令行 |
| 依赖 | fzf | Pet 自身 |

## 加一个新工具的集成

在 `zsh_plugins_load_shell_tools` 里追加：

```zsh
if command -v mytool >/dev/null 2>&1; then
  eval "$(mytool init zsh)"
fi
```

三条原则：

1. 必须有 `command -v` 判断
2. 初始化输出用 `eval`（或按工具文档的方式 source）
3. 不要覆盖已有的 `Ctrl+R`、`↑` 等高频绑定

## 排错

**`Ctrl+G` 没反应**：navi 没装，或 widget 没注册。`zle -l | grep navi` 检查。

**`Ctrl+X Ctrl+R` 没反应**：pet 没装，或 `pet-select` 没注册。`type pet-select` 检查。

**集成报错但工具在**：工具的 `init` 子命令输出格式变了。手动执行看输出：

```bash
navi widget zsh | head
```

**`Ctrl+R` 被覆盖**：某个工具在 Atuin 之后绑定了它。检查 `zshrc` 里 `zsh_plugins_load_shell_tools` 的位置。

<!-- lang:en -->

> Summary: Shell integration for the two optional CLI tools navi and Pet; silently skipped when the tools are missing.

# Optional Tool Integration

## Positioning

These two are not Zinit plugins but **external CLI tools**. Each provides a piece of shell integration code, wired in uniformly by `zsh_plugins_load_shell_tools` in `plugins/zsh-plugins.zsh`.

```zsh
zsh_plugins_load_shell_tools() {
  if command -v navi >/dev/null 2>&1; then
    eval "$(navi widget zsh)"
  fi

  if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
  fi
}
```

The two `command -v` checks are the core: if a tool is not installed, nothing happens and the shell starts as usual.

## When It Runs

In `zshrc`:

```zsh
# Load optional tool widgets after fzf, while preserving Atuin's history bindings.
zsh_plugins_load_shell_tools
```

It sits after the fzf function loading and after the Atuin bindings. The reasons:

| Dependency | Explanation |
|---|---|
| fzf | navi and Pet use fzf for their selection UI |
| Atuin | Must not override the `↑` history binding |

## navi

### What the Integration Does

```zsh
eval "$(navi widget zsh)"
```

Registers a `zle` widget that hooks navi's cheatsheet selector into the command line. After selecting an entry, the command is written back to the buffer without being executed directly.

### Usage

| Key | Behavior |
|---|---|
| `Ctrl+G` | Opens the navi selector (default binding) |

After selecting, you can keep editing before pressing Enter.

### Dependencies

| Dependency | Purpose |
|---|---|
| `navi` | The tool itself |
| `fzf` | Selection UI |
| cheatsheet repository | Source of the content |

First-time use requires importing a cheatsheet:

```bash
navi repo add denisidoro/cheats
```

### When Not Installed

It is skipped and `Ctrl+G` keeps the terminal's default behavior (usually a no-op).

## Pet

### What the Integration Does

The pet-select widget writes Pet's search results back to the command line, letting you inspect and them before executing.
## Comparing the Two

| | navi | Pet |
|---|---|---|
| Trigger | `Ctrl+G` | `Ctrl+X Ctrl+R` |
| Data | Cheatsheet repository | Local snippet library |
| Output | Written back to the command line | Written back to the command line |
| Dependency | fzf | Pet itself |

## Adding a New Tool Integration

Append to `zsh_plugins_load_shell_tools`:

```zsh
if command -v mytool >/dev/null 2>&1; then
  eval "$(mytool init zsh)"
fi
```

Three principles:

1. There must be a `command -v` check
2. Evaluate the initialization output with `eval` (or source it the way the tool's docs prescribe)
3. Do not overwrite existing high-frequency bindings like `Ctrl+R` or `↑`

## Troubleshooting

**`Ctrl+G` does nothing**: navi is not installed, or the widget was not registered. Check with `zle -l | grep navi`.

**`Ctrl+X Ctrl+R` does nothing**: pet is not installed, or `pet-select` was not registered. Check with `type pet-select`.

**The integration errors but the tool exists**: the tool's `init` subcommand changed its output format. Run it manually to inspect the output:

```bash
navi widget zsh | head
```

**`Ctrl+R` got overwritten**: some tool bound it after Atuin. Check the position of `zsh_plugins_load_shell_tools` in `zshrc`.

<!-- lang:ja -->

> 要約：navi・Pet という二つのオプション CLI ツールのシェル統合。ツールがなければ黙ってスキップします。

# オプションツール統合

## 位置づけ

この二つは Zinit プラグインではなく**外部 CLI ツール**です。それぞれがシェル統合コードを提供しており、`plugins/zsh-plugins.zsh` の `zsh_plugins_load_shell_tools` が一括して接続します。

```zsh
zsh_plugins_load_shell_tools() {
  if command -v navi >/dev/null 2>&1; then
    eval "$(navi widget zsh)"
  fi

  if command -v pet >/dev/null 2>&1; then
    function pet-select() {
      BUFFER="$(pet search --query "$LBUFFER")"
      CURSOR=$#BUFFER
      zle redisplay
    }
    zle -N pet-select
    bindkey '^X^R' pet-select
  fi
}
```

二つの `command -v` 判定が核心です。ツールが入っていなければ何もせず、シェルは通常どおり起動します。

## 呼び出しのタイミング

`zshrc` 内：

```zsh
# Load optional tool widgets after fzf, while preserving Atuin's history bindings.
zsh_plugins_load_shell_tools
```

fzf 関数の読み込みの後、Atuin のバインドの後に置かれています。理由は次のとおりです：

| 依存 | 説明 |
|---|---|
| fzf | navi と Pet の選択 UI は fzf を使う |
| Atuin | `↑` の履歴バインドを上書きしてはならない |

## navi

### 統合がやっていること

```zsh
eval "$(navi widget zsh)"
```

`zle` widget を登録し、navi のチートシートセレクターをコマンドラインに接続します。項目を選ぶとコマンドがバッファに書き戻され、直接実行はされません。

### 使い方

| キー | 動作 |
|---|---|
| `Ctrl+G` | navi セレクターを開く（既定のバインド） |

選んだあと、さらに編集してから Enter を押せます。

### 依存

| 依存 | 用途 |
|---|---|
| `navi` | 本体 |
| `fzf` | 選択 UI |
| チートシートリポジトリ | 内容の供給源 |

初回利用時はチートシートのインポートが必要です：

```bash
navi repo add denisidoro/cheats
```

### 入っていない場合

スキップされ、`Ctrl+G` はターミナルの既定の挙動のままです（通常は何もしない）。

## Pet

### 統合がやっていること

pet-select widget は Pet の検索結果をコマンドラインに書き戻し、実行前に確認・編集できるようにします。
## 両者の比較

| | navi | Pet |
|---|---|---|
| 起動キー | `Ctrl+G` | `Ctrl+X Ctrl+R` |
| データ | チートシートリポジトリ | ローカルのスニペット庫 |
| 出力 | コマンドラインへ書き戻し | コマンドラインへ書き戻し |
| 依存 | fzf | Pet 自身 |

## 新しいツールの統合を追加する

`zsh_plugins_load_shell_tools` に追記します：

```zsh
if command -v mytool >/dev/null 2>&1; then
  eval "$(mytool init zsh)"
fi
```

三つの原則：

1. 必ず `command -v` 判定を入れる
2. 初期化出力は `eval` で評価する（またはツールのドキュメントに従って source する）
3. 既存の `Ctrl+R`・`↑` など使用頻度の高いバインドを上書きしない

## トラブルシューティング

**`Ctrl+G` が反応しない**：navi が入っていないか、widget が登録されていません。`zle -l | grep navi` で確認します。

**`Ctrl+X Ctrl+R` が反応しない**：pet が入っていないか、`pet-select` が登録されていません。`type pet-select` で確認します。

**ツールはあるのに統合がエラーになる**：ツールの `init` サブコマンドの出力形式が変わっています。手動で実行して出力を確認します：

```bash
navi widget zsh | head
```

**`Ctrl+R` が上書きされた**：どれかのツールが Atuin の後にバインドしています。`zshrc` 内の `zsh_plugins_load_shell_tools` の位置を確認します。
