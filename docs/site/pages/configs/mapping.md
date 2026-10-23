> 摘要：dotlinkrc 里每条映射的源、目标、作用，以及哪些配置不在此列。

# 映射清单

## 自动部署的配置

`dotlink/dotlinkrc` 的 `[link]` 段：

| 源 | 目标 | 作用 |
|---|---|---|
| `zshrc` | `~/.zshrc` | Zsh 主入口 |
| `config/starship/starship.toml` | `~/.config/starship.toml` | 提示符主题 |
| `config/nano/nanorc` | `~/.nanorc` | Nano 设置 |
| `config/atuin` | `~/.config/atuin` | Atuin 配置目录 |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr 配置 |
| `config/ranger` | `~/.config/ranger` | Ranger 配置目录 |
| `config/gvim/gvimrc` | `~/.gvimrc` | GVim 外观 |
| `config/vim/vimrc` | `~/.vimrc` | Vim 通用配置 |
| `config/nvim` | `~/.config/nvim` | Neovim（子模块） |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | tmux 主配置 |
| `config/vifm/vifmrc` | `~/.config/vifm/vifmrc` | Vifm 主配置 |
| `config/vifm/colors` | `~/.config/vifm/colors` | Vifm 配色 |
| `config/vifm/scripts` | `~/.config/vifm/scripts` | Vifm 脚本 |
| `scripts/sync-webapps.py` | `~/.local/bin/sync-webapps` | Web App 同步脚本 |

## 未列入映射的配置

| 文件 | 说明 |
|---|---|
| `config/ghostty/config` | Ghostty 终端配置，需手动链接 |
| `config/vim/tests/` | 测试文件，不需要部署 |

要手动链接 Ghostty：

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## 映射写法

```ini
$HOME/dotfiles/zshrc:$HOME/.zshrc	# zsh 配置文件
```

三部分：

1. `$HOME/dotfiles/...` — 源，展开 `$HOME`
2. `:` — 分隔符
3. `$HOME/.zshrc` — 目标
4. `#` 之后 — 注释

目录映射和文件映射写法相同，`dotlink` 会判断源是文件还是目录。

## 通配符映射

```ini
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

对源目录下每个匹配项，在目标目录建立同名链接。当前 `dotlinkrc` 里 Vifm 的三条规则是显式写出的，没有用通配符；通配符能力在 `process_wildcard_pattern` 里实现，供将来扩展。

## Neovim 的特殊分支

```ini
$HOME/dotfiles/config/nvim:$HOME/.config/nvim	# Neovim 配置文件
```

实际链接目标可能不是 `config/nvim`：`dotlink` 检测到 `~/nvim` 且它的 origin 是本仓库时，改链接 `~/nvim`。

## 验证映射

```bash
bash ~/dotfiles/dotlink/dotlink list
```

它会展开所有规则并打印，不修改文件。用这个确认「到底会链接什么」。

## 添加新映射

```ini
[link]
...
$HOME/dotfiles/config/newtool:$HOME/.config/newtool   # 新工具配置
```

然后：

```bash
bash ~/dotfiles/dotlink/dotlink list    # 先看
bash ~/dotfiles/dotlink/dotlink link    # 再执行
```

## 排错

**某个配置没生效**：先 `ls -l` 目标路径，确认是不是软链接。不是就说明没在映射里。

**`~/.config/ghostty/config` 不存在**：Ghostty 不在映射里，需手动链接。

**链接指向错误**：`readlink -f ~/.config/nvim` 查看实际目标。

**`config/vifm/*` 规则没生效**：确认源目录存在。源不存在时 dotlink 静默跳过。

<!-- lang:en -->

> Summary: The source, target, and purpose of each mapping in dotlinkrc, plus which configurations are not on the list.

# Mapping List

## Auto-Deployed Configurations

The `[link]` section of `dotlink/dotlinkrc`:

| Source | Target | Purpose |
|---|---|---|
| `zshrc` | `~/.zshrc` | Zsh main entry |
| `config/starship/starship.toml` | `~/.config/starship.toml` | Prompt theme |
| `config/nano/nanorc` | `~/.nanorc` | Nano settings |
| `config/atuin` | `~/.config/atuin` | Atuin configuration directory |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr configuration |
| `config/ranger` | `~/.config/ranger` | Ranger configuration directory |
| `config/gvim/gvimrc` | `~/.gvimrc` | GVim appearance |
| `config/vim/vimrc` | `~/.vimrc` | Common Vim configuration |
| `config/nvim` | `~/.config/nvim` | Neovim (submodule) |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | tmux main configuration |
| `config/vifm/vifmrc` | `~/.config/vifm/vifmrc` | Vifm main configuration |
| `config/vifm/colors` | `~/.config/vifm/colors` | Vifm colors |
| `config/vifm/scripts` | `~/.config/vifm/scripts` | Vifm scripts |
| `scripts/sync-webapps.py` | `~/.local/bin/sync-webapps` | Web App sync script |

## Configurations Not in the Mapping

| File | Notes |
|---|---|
| `config/ghostty/config` | Ghostty terminal configuration, must be linked manually |
| `config/vim/tests/` | Test files, no need to deploy |

To link Ghostty manually:

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## Mapping Syntax

```ini
$HOME/dotfiles/zshrc:$HOME/.zshrc	# zsh 配置文件
```

Three parts:

1. `$HOME/dotfiles/...` — the source, with `$HOME` expanded
2. `:` — the separator
3. `$HOME/.zshrc` — the target
4. Anything after `#` — a comment

Directory mappings are written the same way as file mappings; `dotlink` decides whether the source is a file or a directory.

## Wildcard Mappings

```ini
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

For each match under the source directory, a link with the same name is created in the target directory. The three Vifm rules currently in `dotlinkrc` are written out explicitly, without wildcards; the wildcard capability is implemented in `process_wildcard_pattern` for future extension.

## The Special Neovim Branch

```ini
$HOME/dotfiles/config/nvim:$HOME/.config/nvim	# Neovim 配置文件
```

The actual link target may not be `config/nvim`: when `dotlink` detects `~/nvim` whose origin is this repository, it links `~/nvim` instead.

## Verifying Mappings

```bash
bash ~/dotfiles/dotlink/dotlink list
```

It expands and prints all rules without modifying any files. Use it to confirm "exactly what will be linked".

## Adding a New Mapping

```ini
[link]
...
$HOME/dotfiles/config/newtool:$HOME/.config/newtool   # 新工具配置
```

Then:

```bash
bash ~/dotfiles/dotlink/dotlink list    # 先看
bash ~/dotfiles/dotlink/dotlink link    # 再执行
```

## Troubleshooting

**A configuration is not taking effect**: first `ls -l` the target path and check whether it is a symlink. If not, it is not in the mapping.

**`~/.config/ghostty/config` does not exist**: Ghostty is not in the mapping; link it manually.

**A link points to the wrong place**: inspect the actual target with `readlink -f ~/.config/nvim`.

**The `config/vifm/*` rule did nothing**: confirm the source directory exists. dotlink silently skips missing sources.

<!-- lang:ja -->

> 要約：dotlinkrc の各マッピングのソース・ターゲット・役割、およびリストに含まれていない設定について。

# マッピング一覧

## 自動デプロイされる設定

`dotlink/dotlinkrc` の `[link]` セクション：

| ソース | ターゲット | 役割 |
|---|---|---|
| `zshrc` | `~/.zshrc` | Zsh のメインエントリ |
| `config/starship/starship.toml` | `~/.config/starship.toml` | プロンプトテーマ |
| `config/nano/nanorc` | `~/.nanorc` | Nano の設定 |
| `config/atuin` | `~/.config/atuin` | Atuin の設定ディレクトリ |
| `config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr の設定 |
| `config/ranger` | `~/.config/ranger` | Ranger の設定ディレクトリ |
| `config/gvim/gvimrc` | `~/.gvimrc` | GVim の外観 |
| `config/vim/vimrc` | `~/.vimrc` | Vim の共通設定 |
| `config/nvim` | `~/.config/nvim` | Neovim（サブモジュール） |
| `config/tmux/tmux.conf` | `~/.config/tmux/tmux.conf` | tmux のメイン設定 |
| `config/vifm/vifmrc` | `~/.config/vifm/vifmrc` | Vifm のメイン設定 |
| `config/vifm/colors` | `~/.config/vifm/colors` | Vifm の配色 |
| `config/vifm/scripts` | `~/.config/vifm/scripts` | Vifm のスクリプト |
| `scripts/sync-webapps.py` | `~/.local/bin/sync-webapps` | Web App 同期スクリプト |

## マッピングに含まれていない設定

| ファイル | 説明 |
|---|---|
| `config/ghostty/config` | Ghostty の端末設定。手動でリンクが必要 |
| `config/vim/tests/` | テストファイル。デプロイ不要 |

Ghostty を手動でリンクするには：

```bash
mkdir -p ~/.config/ghostty
ln -sf ~/dotfiles/config/ghostty/config ~/.config/ghostty/config
```

## マッピングの書式

```ini
$HOME/dotfiles/zshrc:$HOME/.zshrc	# zsh 配置文件
```

3 つの部分からなります：

1. `$HOME/dotfiles/...` — ソース。`$HOME` は展開されます
2. `:` — 区切り文字
3. `$HOME/.zshrc` — ターゲット
4. `#` 以降 — コメント

ディレクトリのマッピングもファイルと同じ書き方で、ソースがファイルかディレクトリかは `dotlink` が判定します。

## ワイルドカードマッピング

```ini
$HOME/dotfiles/config/vifm/*:$HOME/.config/vifm/*
```

ソースディレクトリ内の各マッチに対して、ターゲットディレクトリに同じ名前のリンクを作成します。現在 `dotlinkrc` にある Vifm の 3 つのルールはワイルドカードを使わず明示的に書かれています。ワイルドカード機能は `process_wildcard_pattern` に実装されており、将来の拡張用です。

## Neovim の特別な分岐

```ini
$HOME/dotfiles/config/nvim:$HOME/.config/nvim	# Neovim 配置文件
```

実際のリンク先は `config/nvim` ではない場合があります。`dotlink` は `~/nvim` が存在し、その origin が本リポジトリであることを検出すると、`~/nvim` をリンクします。

## マッピングの検証

```bash
bash ~/dotfiles/dotlink/dotlink list
```

ファイルを変更せずに、すべてのルールを展開して表示します。「実際に何がリンクされるのか」の確認に使えます。

## 新しいマッピングの追加

```ini
[link]
...
$HOME/dotfiles/config/newtool:$HOME/.config/newtool   # 新工具配置
```

次に：

```bash
bash ~/dotfiles/dotlink/dotlink list    # 先看
bash ~/dotfiles/dotlink/dotlink link    # 再执行
```

## トラブルシューティング

**ある設定が効かない**：まずターゲットのパスを `ls -l` で確認し、シンボリックリンクかどうかを見ます。違えばマッピングに含まれていません。

**`~/.config/ghostty/config` が存在しない**：Ghostty はマッピングに含まれていないため、手動でリンクします。

**リンク先がおかしい**：`readlink -f ~/.config/nvim` で実際のターゲットを確認します。

**`config/vifm/*` のルールが効かない**：ソースディレクトリが存在するか確認します。ソースが存在しない場合、dotlink は黙ってスキップします。
