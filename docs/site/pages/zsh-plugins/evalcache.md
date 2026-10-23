> 摘要：evalcache 缓存 shell hook 的初始化输出，避免每次启动都执行子进程。

# evalcache

## 用途

很多工具通过 `eval "$(tool init zsh)"` 接入 shell。每次启动 shell 都要执行一次子进程，生成一段固定不变的 shell 代码。

`mroth/evalcache` 提供 `_evalcache` 函数：第一次执行并缓存输出，之后直接 source 缓存文件。

## 加载方式

```zsh
zsh_plugins_load_main() {
  zinit light mroth/evalcache
  ...
}
```

它加载得很早（在 vi-mode 之前），因为后面的 `zshrc` 要用它。

## 本仓库的用法

`zshrc` 里两处：

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi

if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'
  alias za='z -a'
  alias zr='z -r'
fi
```

`_evalcache atuin init zsh` 等价于：

```zsh
eval "$(atuin init zsh)"
```

但只在缓存不存在或工具更新时真正执行。

## 缓存机制

```text
~/.cache/zsh/evalcache/
├── atuin-init-zsh
└── zoxide-init-zsh
```

缓存的键由「命令 + 参数」生成。文件里存的是该命令的输出。

失效条件：

| 情况 | 行为 |
|---|---|
| 缓存不存在 | 执行命令并写入缓存 |
| 工具版本变化 | evalcache 会比较二进制修改时间，过期则重算 |
| 手动删除缓存 | 下次启动重新生成 |

## 为什么值得

| | 不用 evalcache | 用 evalcache |
|---|---|---|
| 每次启动 | 执行 `atuin init zsh`（约 30–80ms） | 读一个文件（约 1ms） |
| 启动 10 次 | 累计 300–800ms | 累计 10ms |
| 磁盘占用 | 0 | 几十 KB |

对经常开新终端或新 tmux pane 的人来说，差别明显。

## 手动控制

```bash
# 看缓存内容
ls ~/.cache/zsh/evalcache/
cat ~/.cache/zsh/evalcache/zoxide-init-zsh | head

# 强制重建
rm -rf ~/.cache/zsh/evalcache
exec zsh
```

升级 atuin 或 zoxide 后如果行为异常，先清这个目录。

## 什么时候不该用

| 情况 | 原因 |
|---|---|
| 输出含动态路径 | 缓存后路径不会更新 |
| 输出依赖当前目录 | 缓存是全局的，会出错 |
| 工具每次输出都不同 | 缓存失去意义 |

`evalcache` 适合「输出只随版本变化」的工具，不适合「输出随环境变化」的工具。

## 与其它加速手段的区别

| 手段 | 优化什么 |
|---|---|
| evalcache | 缓存 `eval "$(...)"` 的输出 |
| fnm 惰性加载 | 推迟到第一次用 Node 时初始化 |
| Zinit 缓存 | 插件本体不重新下载 |
| `zinit ice lucid` | 延迟插件的键位绑定 |

它们解决不同环节，可以叠加。

## 排错

**`_evalcache: command not found`**：evalcache 没加载。检查 `zsh_plugins_load_main` 里那行，以及它是否在 `zshrc` 调用 `zsh_plugins_load_main` 之前定义。

**改了 atuin 配置但没生效**：缓存还是旧的。`rm -rf ~/.cache/zsh/evalcache`。

**缓存目录不存在**：第一次运行时自动创建。如果创建失败，检查 `$XDG_CACHE_HOME` 的权限。

**启动仍然慢**：用 `zsh -x -i -c true 2>&1 | tail -30` 看时间花在哪，可能不是这两个 hook。

<!-- lang:en -->

> Summary: evalcache caches the initialization output of shell hooks so that child processes are not executed on every startup.

# evalcache

## Purpose

Many tools hook into the shell via `eval "$(tool init zsh)"`. Every shell startup runs a child process once to generate a piece of shell code that never changes.

`mroth/evalcache` provides the `_evalcache` function: the first run executes and caches the output; afterwards the cached file is simply sourced.

## Loading

```zsh
zsh_plugins_load_main() {
  zinit light mroth/evalcache
  ...
}
```

It loads very early (before vi-mode), because the later `zshrc` needs it.

## How this repo uses it

Two places in `zshrc`:

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi

if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'
  alias za='z -a'
  alias zr='z -r'
fi
```

`_evalcache atuin init zsh` is equivalent to:

```zsh
eval "$(atuin init zsh)"
```

except it only actually executes when the cache does not exist or the tool has been updated.

## Cache mechanism

```text
~/.cache/zsh/evalcache/
├── atuin-init-zsh
└── zoxide-init-zsh
```

The cache key is generated from "command + arguments". The file stores that command's output.

Invalidation conditions:

| Situation | Behavior |
|---|---|
| Cache missing | Executes the command and writes the cache |
| Tool version changed | evalcache compares the binary's modification time and recomputes if stale |
| Cache deleted manually | Regenerated on next startup |

## Why it is worth it

| | Without evalcache | With evalcache |
|---|---|---|
| Every startup | Runs `atuin init zsh` (about 30–80ms) | Reads one file (about 1ms) |
| 10 startups | 300–800ms total | 10ms total |
| Disk usage | 0 | A few dozen KB |

For people who open new terminals or tmux panes often, the difference is obvious.

## Manual control

```bash
# 看缓存内容
ls ~/.cache/zsh/evalcache/
cat ~/.cache/zsh/evalcache/zoxide-init-zsh | head

# 强制重建
rm -rf ~/.cache/zsh/evalcache
exec zsh
```

If atuin or zoxide behaves oddly after an upgrade, clear this directory first.

## When not to use it

| Situation | Reason |
|---|---|
| Output contains dynamic paths | Cached paths will not update |
| Output depends on the current directory | The cache is global, so it will be wrong |
| Tool output differs every time | The cache loses its point |

`evalcache` suits tools whose "output only changes with version", not tools whose "output changes with the environment".

## Difference from other speedup techniques

| Technique | What it optimizes |
|---|---|
| evalcache | Caches the output of `eval "$(...)"` |
| fnm lazy loading | Defers initialization until Node is first used |
| Zinit cache | Plugin bodies are not re-downloaded |
| `zinit ice lucid` | Delays a plugin's keybindings |

They solve different stages and can be combined.

## Troubleshooting

**`_evalcache: command not found`**: evalcache is not loaded. Check the line in `zsh_plugins_load_main`, and whether it is defined before `zshrc` calls `zsh_plugins_load_main`.

**Changed the atuin config but it did not take effect**: the cache is still old. Run `rm -rf ~/.cache/zsh/evalcache`.

**The cache directory does not exist**: it is created automatically on first run. If creation fails, check the permissions of `$XDG_CACHE_HOME`.

**Startup is still slow**: use `zsh -x -i -c true 2>&1 | tail -30` to see where the time goes; it may not be these two hooks.

<!-- lang:ja -->

> 要約：evalcache はシェルフックの初期化出力をキャッシュし、起動のたびに子プロセスを実行するのを避けます。

# evalcache

## 用途

多くのツールは `eval "$(tool init zsh)"` でシェルに組み込まれます。シェルを起動するたびに子プロセスを1回実行し、内容の変わらないシェルコードを生成させられます。

`mroth/evalcache` は `_evalcache` 関数を提供します：初回は実行して出力をキャッシュし、以降はキャッシュファイルを直接 source します。

## 読み込み方法

```zsh
zsh_plugins_load_main() {
  zinit light mroth/evalcache
  ...
}
```

ごく早い段階（vi-mode より前）で読み込まれます。後の `zshrc` がこれを使うためです。

## 本リポジトリでの使い方

`zshrc` 内の2箇所：

```zsh
if command -v atuin > /dev/null; then
  _evalcache atuin init zsh
fi

if command -v zoxide > /dev/null; then
  _evalcache zoxide init zsh
  alias zi='z -i'
  alias za='z -a'
  alias zr='z -r'
fi
```

`_evalcache atuin init zsh` は次と等価です：

```zsh
eval "$(atuin init zsh)"
```

ただし、キャッシュが存在しないかツールが更新されたときにだけ実際に実行されます。

## キャッシュの仕組み

```text
~/.cache/zsh/evalcache/
├── atuin-init-zsh
└── zoxide-init-zsh
```

キャッシュのキーは「コマンド＋引数」から生成されます。ファイルにはそのコマンドの出力が保存されます。

無効化の条件：

| 状況 | 動作 |
|---|---|
| キャッシュが存在しない | コマンドを実行してキャッシュに書き込む |
| ツールのバージョンが変わった | evalcache はバイナリの更新時刻を比較し、古ければ再計算する |
| キャッシュを手動で削除 | 次回起動時に再生成される |

## 価値がある理由

| | evalcache なし | evalcache あり |
|---|---|---|
| 毎回の起動 | `atuin init zsh` を実行（約 30–80ms） | ファイルを1つ読む（約 1ms） |
| 起動10回 | 累計 300–800ms | 累計 10ms |
| ディスク使用量 | 0 | 数十 KB |

新しいターミナルや tmux pane を頻繁に開く人には、差は歴然です。

## 手動での管理

```bash
# 看缓存内容
ls ~/.cache/zsh/evalcache/
cat ~/.cache/zsh/evalcache/zoxide-init-zsh | head

# 强制重建
rm -rf ~/.cache/zsh/evalcache
exec zsh
```

atuin や zoxide をアップグレードした後に動作がおかしい場合は、まずこのディレクトリを削除します。

## 使うべきでないとき

| 状況 | 理由 |
|---|---|
| 出力に動的なパスが含まれる | キャッシュ後はパスが更新されない |
| 出力がカレントディレクトリに依存する | キャッシュはグローバルなため誤動作する |
| 出力が毎回異なるツール | キャッシュの意味がなくなる |

`evalcache` は「出力がバージョンによってのみ変わる」ツールに向いており、「出力が環境によって変わる」ツールには向きません。

## 他の高速化手段との違い

| 手段 | 最適化の対象 |
|---|---|
| evalcache | `eval "$(...)"` の出力をキャッシュ |
| fnm の遅延読み込み | 初めて Node を使う時まで初期化を先送り |
| Zinit キャッシュ | プラグイン本体を再ダウンロードしない |
| `zinit ice lucid` | プラグインのキーバインドを遅延 |

それぞれ異なる段階を解決するため、併用できます。

## トラブルシューティング

**`_evalcache: command not found`**：evalcache が読み込まれていません。`zsh_plugins_load_main` 内のその行と、`zshrc` が `zsh_plugins_load_main` を呼ぶより前に定義されているかを確認します。

**atuin の設定を変えたのに反映されない**：キャッシュが古いままです。`rm -rf ~/.cache/zsh/evalcache` を実行します。

**キャッシュディレクトリが存在しない**：初回実行時に自動作成されます。作成に失敗する場合は `$XDG_CACHE_HOME` の権限を確認します。

**起動がまだ遅い**：`zsh -x -i -c true 2>&1 | tail -30` で時間がどこに使われているか確認します。この2つの hook ではない可能性もあります。
