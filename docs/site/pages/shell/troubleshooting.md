> 摘要：启动报错、插件缺失、预览空白、提示符异常的分层排查方法。

# 排错清单

## 先分层，再动手

shell 问题几乎都能定位到四层之一：语法、加载顺序、依赖缺失、运行时状态。按顺序排查比反复重装有效。

## 第一层：语法

```bash
zsh -d -n ~/dotfiles/zshrc
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
bash -n ~/dotfiles/init.sh
bash -n ~/dotfiles/aliases.conf
```

`-n` 只解析不执行。任何一行报错，后面的加载都不会发生。

## 第二层：加载顺序

```bash
zsh -x -i -c 'true' 2>&1 | head -80
```

`-x` 打印每行执行内容。看最后几行就知道卡在哪个文件。

常见症状与原因：

| 症状 | 原因 |
|---|---|
| 启动很慢（>3 秒） | 某个 `zinit light` 在同步下载 |
| 提示 `compdef: command not found` | 插件在 `compinit` 前调用了 `compdef` |
| 补全候选为空 | `compinit` 没运行，或 `zcompdump` 损坏 |
| 语法高亮失效 | 高亮插件不在最后加载 |

## 第三层：依赖

```bash
command -v fd rg fzf bat eza zoxide atuin starship fnm
```

任何一个缺失，依赖它的功能就静默不生效。本仓库大量使用 `command -v` 判断，所以**不会报错，只会功能缺失**——这一点容易误判成「配置坏了」。

## 第四层：运行时状态

### Zinit 缓存损坏

```bash
zinit list              # 看是否有异常项
zinit report            # 更详细的状态
bash ~/dotfiles/init.sh --repair
```

### 补全缓存过期

```bash
rm -f ~/.zcompdump*
exec zsh
```

### 函数没定义

```bash
type f ffd ra v vssh zz
```

`type` 会明确告诉你它是函数、别名、还是找不到。

## 按症状查

### fzf 预览空白

```bash
command -v bat ls
echo $FZF_DEFAULT_OPTS
```

`bat` 缺失时预览会退化成只有目录列表。`FZF_DEFAULT_OPTS` 为空说明 `fzf.zsh` 没加载。

### 提示符没有 Python 版本

```bash
starship explain
```

它会逐模块解释显示或隐藏的原因。常见是当前目录没有 `pyproject.toml` 之类触发文件。

### 提示符显示方框

字体不是 Nerd Font。装 Meslo：

```bash
bash ~/dotfiles/scripts/install/install_font.sh --meslo
```

然后在终端设置里选择 `MesloLGS Nerd Font`。

### tmux 里颜色不对

三层都要检查：

```bash
echo $TERM                    # 应该是 tmux-256color 或 xterm-256color
tmux show -g default-terminal
tmux show -g terminal-features
```

如果 `$TERM` 是 `screen` 或 `xterm`，说明 tmux 配置没加载。

### Neovim 打开是裸界面

```bash
ls -l ~/.config/nvim
```

应该是软链接。如果是空目录，子模块没初始化：

```bash
cd ~/dotfiles && git submodule update --init --recursive
```

### `Ctrl+R` 行为和预期不符

```bash
bindkey '^R'
```

fzf、Atuin、Zsh 原生三方都可能接管。要在 `local/` 里显式覆盖：

```zsh
bindkey '^R' fzf-history-widget
```

## 最后手段

如果确认是配置本身损坏，而 `--repair` 无效：

```bash
cd ~/dotfiles
git status                    # 确认没有未提交改动
git stash                     # 或先备份
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

不要直接删 `~/.zinit` 或 `~/.config/nvim`，那会丢掉所有已下载的插件，重新下载要很久。
<!-- lang:en -->
> Summary: A layered troubleshooting method for startup errors, missing plugins, blank previews, and broken prompts.

# Troubleshooting Checklist

## Layer first, then act

Almost every shell problem can be traced to one of four layers: syntax, load order, missing dependencies, or runtime state. Working through them in order beats repeated reinstalling.

## Layer 1: syntax

```bash
zsh -d -n ~/dotfiles/zshrc
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
bash -n ~/dotfiles/init.sh
bash -n ~/dotfiles/aliases.conf
```

`-n` only parses, it doesn't execute. If any line reports an error, none of the later loading happens.

## Layer 2: load order

```bash
zsh -x -i -c 'true' 2>&1 | head -80
```

`-x` prints every executed line. The last few lines tell you which file it stalled on.

Common symptoms and causes:

| Symptom | Cause |
|---|---|
| Startup is slow (>3 seconds) | Some `zinit light` is downloading synchronously |
| Reports `compdef: command not found` | A plugin called `compdef` before `compinit` |
| Completion candidates are empty | `compinit` didn't run, or `zcompdump` is corrupted |
| Syntax highlighting stops working | The highlighting plugin isn't loaded last |

## Layer 3: dependencies

```bash
command -v fd rg fzf bat eza zoxide atuin starship fnm
```

If any one is missing, the features depending on it silently stop working. This repo checks heavily with `command -v`, so it **won't error — features just go missing** — which is easy to misread as "the config is broken".

## Layer 4: runtime state

### Corrupted Zinit cache

```bash
zinit list              # 看是否有异常项
zinit report            # 更详细的状态
bash ~/dotfiles/init.sh --repair
```

### Stale completion cache

```bash
rm -f ~/.zcompdump*
exec zsh
```

### Functions not defined

```bash
type f ffd ra v vssh zz
```

`type` tells you clearly whether it's a function, an alias, or not found.

## Search by symptom

### fzf preview is blank

```bash
command -v bat ls
echo $FZF_DEFAULT_OPTS
```

When `bat` is missing, the preview degrades to a directory listing only. An empty `FZF_DEFAULT_OPTS` means `fzf.zsh` wasn't loaded.

### Prompt doesn't show the Python version

```bash
starship explain
```

It explains, module by module, why each is shown or hidden. The usual cause is no trigger file like `pyproject.toml` in the current directory.

### Prompt shows boxes

The font isn't a Nerd Font. Install Meslo:

```bash
bash ~/dotfiles/scripts/install/install_font.sh --meslo
```

Then select `MesloLGS Nerd Font` in the terminal settings.

### Colors are wrong inside tmux

All three layers need checking:

```bash
echo $TERM                    # 应该是 tmux-256color 或 xterm-256color
tmux show -g default-terminal
tmux show -g terminal-features
```

If `$TERM` is `screen` or `xterm`, the tmux config wasn't loaded.

### Neovim opens with a bare interface

```bash
ls -l ~/.config/nvim
```

It should be a symlink. If it's an empty directory, the submodule wasn't initialized:

```bash
cd ~/dotfiles && git submodule update --init --recursive
```

### `Ctrl+R` doesn't behave as expected

```bash
bindkey '^R'
```

fzf, Atuin, and Zsh's native binding can all take over. To override explicitly, put this in `local/`:

```zsh
bindkey '^R' fzf-history-widget
```

## Last resort

If the configuration itself is confirmed broken and `--repair` doesn't help:

```bash
cd ~/dotfiles
git status                    # 确认没有未提交改动
git stash                     # 或先备份
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

Don't just delete `~/.zinit` or `~/.config/nvim` — that throws away every downloaded plugin, and re-downloading takes a long time.
<!-- lang:ja -->
> 要約：起動エラー、プラグインの欠落、プレビューの空白、プロンプトの異常に対する階層的な切り分け方法。

# トラブルシューティングチェックリスト

## まず階層分け、それから手を動かす

shell の問題はほぼすべて、構文、ロード順序、依存の欠落、実行時状態という 4 層のいずれかに位置づけられます。順番に切り分けていく方が、何度も再インストールするより効果的です。

## 第 1 層：構文

```bash
zsh -d -n ~/dotfiles/zshrc
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
bash -n ~/dotfiles/init.sh
bash -n ~/dotfiles/aliases.conf
```

`-n` は解析のみで実行しません。どれか 1 行でもエラーが出たら、後のロードは一切行われません。

## 第 2 層：ロード順序

```bash
zsh -x -i -c 'true' 2>&1 | head -80
```

`-x` は実行内容を 1 行ずつ表示します。最後の数行を見れば、どのファイルで止まったか分かります。

よくある症状と原因：

| 症状 | 原因 |
|---|---|
| 起動が遅い（3 秒超） | どれかの `zinit light` が同期ダウンロード中 |
| `compdef: command not found` と出る | プラグインが `compinit` の前に `compdef` を呼んだ |
| 補完候補が空 | `compinit` が実行されていない、または `zcompdump` が破損 |
| シンタックスハイライトが効かない | ハイライトプラグインが最後にロードされていない |

## 第 3 層：依存

```bash
command -v fd rg fzf bat eza zoxide atuin starship fnm
```

どれか 1 つでも欠けていれば、それに依存する機能は黙って無効になります。本リポジトリは `command -v` での判定を多用するため、**エラーにはならず、ただ機能が欠ける**だけです。この点を「設定が壊れた」と誤判定しやすいでしょう。

## 第 4 層：実行時状態

### Zinit キャッシュの破損

```bash
zinit list              # 看是否有异常项
zinit report            # 更详细的状态
bash ~/dotfiles/init.sh --repair
```

### 補完キャッシュの期限切れ

```bash
rm -f ~/.zcompdump*
exec zsh
```

### 関数が未定義

```bash
type f ffd ra v vssh zz
```

`type` はそれが関数か、エイリアスか、見つからないのかを明確に教えてくれます。

## 症状から調べる

### fzf のプレビューが空白

```bash
command -v bat ls
echo $FZF_DEFAULT_OPTS
```

`bat` が欠けていると、プレビューはディレクトリ一覧のみに退化します。`FZF_DEFAULT_OPTS` が空なら、`fzf.zsh` がロードされていません。

### プロンプトに Python のバージョンが出ない

```bash
starship explain
```

モジュールごとに表示・非表示の理由を説明してくれます。よくあるのは、カレントディレクトリに `pyproject.toml` などのトリガーファイルがないケースです。

### プロンプトが四角で表示される

フォントが Nerd Font ではありません。Meslo をインストールします：

```bash
bash ~/dotfiles/scripts/install/install_font.sh --meslo
```

その後、ターミナル設定で `MesloLGS Nerd Font` を選択してください。

### tmux 内で色がおかしい

3 層すべてを確認します：

```bash
echo $TERM                    # 应该是 tmux-256color 或 xterm-256color
tmux show -g default-terminal
tmux show -g terminal-features
```

`$TERM` が `screen` や `xterm` なら、tmux の設定がロードされていません。

### Neovim が素の画面で開く

```bash
ls -l ~/.config/nvim
```

シンボリックリンクであるべきです。空のディレクトリなら、サブモジュールが未初期化です：

```bash
cd ~/dotfiles && git submodule update --init --recursive
```

### `Ctrl+R` の挙動が期待と違う

```bash
bindkey '^R'
```

fzf、Atuin、Zsh 標準の 3 者がいずれも引き受け得ます。明示的に上書きしたい場合は `local/` に置きます：

```zsh
bindkey '^R' fzf-history-widget
```

## 最終手段

設定そのものの破損が確定で、`--repair` でも直らない場合：

```bash
cd ~/dotfiles
git status                    # 确认没有未提交改动
git stash                     # 或先备份
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

`~/.zinit` や `~/.config/nvim` を直接削除してはいけません。ダウンロード済みのプラグインがすべて失われ、再ダウンロードには長い時間がかかります。
