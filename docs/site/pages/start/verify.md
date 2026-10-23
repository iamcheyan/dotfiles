> 摘要：安装完成后逐项核对命令、软链接、Neovim 版本和 shell 集成是否真的生效。

# 安装后核对

## 为什么需要这一步

`init.sh` 采用 best-effort 策略：单步失败只打印 warning 并继续。所以「脚本跑完了」不等于「环境可用」。下面的检查按依赖层级排列，从底层往上查。

## 第一层：命令是否存在

```bash
command -v zsh git curl
command -v fzf fd rg
command -v eza bat zoxide atuin
command -v nvim tmux
```

预期结果：每条都打印一个绝对路径。打印不出来说明该工具没装上，或者不在 PATH。

`eza` 和 `bat` 是可选的：`aliases.conf` 里用 `command -v eza` 做了判断，没有 eza 时 `l`/`ll`/`la` 别名根本不会定义，也不会报错。

## 第二层：软链接指向哪里

```bash
ls -l ~/.zshrc ~/.vimrc ~/.config/nvim ~/.config/starship.toml
```

每个都应该是 `->` 指向 `~/dotfiles/...` 的软链接。如果 `~/.zshrc` 还是普通文件，说明 dotlink 没跑成功，或者它被跳过了。

逐个核对全部映射：

```bash
sed -n '/^\[link\]/,$p' ~/dotfiles/dotlink/dotlinkrc
```

## 第三层：Neovim 版本

```bash
nvim --version | head -1
```

必须是 `NVIM v0.12.x` 或更高。低于 0.12 时 Treesitter 的 main 分支和部分插件会失败。

如果 `command -v nvim` 指向 `/usr/bin/nvim` 而系统版本过旧：

```bash
ls -l ~/.local/bin/nvim
```

正常情况这是指向 `~/.local/opt/neovim/<version>/bin/nvim` 的软链接。如果它指向了系统路径，用 `nvim-update` 重新建立用户级安装。

## 第四层：Zinit 是否正常

```bash
zinit list
```

应该列出已安装的插件和工具。空列表通常意味着 zinit 本体没装好，或者 `zshrc` 没被加载。

## 第五层：shell 集成

```bash
echo $SHELL
echo $FZF_DEFAULT_COMMAND
type f ffd ra v vssh
bindkey '^R'
```

- `$SHELL` 应为 zsh 的路径。
- `$FZF_DEFAULT_COMMAND` 应以 `fd` 或 `fdfind` 开头。
- `type` 应把每个函数显示为 `function`。
- `bindkey '^R'` 显示当前 Ctrl+R 绑定，用于确认是 fzf 还是 Atuin 接管。

## 第六层：实际用一次

```bash
f            # 应弹出文件选择器
z dotfiles   # 应跳转到仓库
nvim         # 应进入配置好的界面，而不是裸 Neovim
```

如果 `nvim` 打开后没有插件界面，多半是 `~/.config/nvim` 链接到了空目录（子模块没初始化）。

## 常见失败与对应原因

| 现象 | 原因 |
|---|---|
| `command not found: zsh` | 第 2 步失败，或没重新登录 |
| `~/.zshrc` 是普通文件 | dotlink 未执行或执行失败 |
| `nvim` 版本低于 0.12 | 用户级安装没建立，走了系统包 |
| `zinit list` 为空 | zinit 目录缺失或 `zshrc` 未加载 |
| `f` 未定义 | `plugins/fzf/fzf.zsh` 未加载，检查 `zshrc` |
| `~/.config/nvim` 为空 | 子模块未初始化 |

逐项修好后重新 `exec zsh`，再从第一层核对。

<!-- lang:en -->

> 摘要：After installation, verify layer by layer that commands, symlinks, the Neovim version and shell integration actually work.

# Post-install verification

## Why this matters

`init.sh` is best-effort: a failed step prints a warning and the run continues. "The script finished" therefore does not mean "the environment works". The checks below are ordered by dependency, bottom up.

## Layer 1: do the commands exist

```bash
command -v zsh git curl
command -v fzf fd rg
command -v eza bat zoxide atuin
command -v nvim tmux
```

Expected: every line prints an absolute path. A missing line means the tool is not installed or not on PATH.

`eza` and `bat` are optional: `aliases.conf` guards with `command -v eza`, so without eza the `l`/`ll`/`la` aliases are simply never defined — no errors.

## Layer 2: where the symlinks point

```bash
ls -l ~/.zshrc ~/.vimrc ~/.config/nvim ~/.config/starship.toml
```

Each should be a symlink (`->`) into `~/dotfiles/...`. A plain-file `~/.zshrc` means dotlink did not run or was skipped.

Check the whole mapping list:

```bash
sed -n '/^\[link\]/,$p' ~/dotfiles/dotlink/dotlinkrc
```

## Layer 3: the Neovim version

```bash
nvim --version | head -1
```

Must be `NVIM v0.12.x` or newer. Below 0.12, Treesitter's main branch and several plugins fail.

If `command -v nvim` resolves to `/usr/bin/nvim` and the system version is too old:

```bash
ls -l ~/.local/bin/nvim
```

Normally this is a symlink into `~/.local/opt/neovim/<version>/bin/nvim`. If it points at a system path instead, rebuild the user-level install with `nvim-update`.

## Layer 4: is Zinit alive

```bash
zinit list
```

Should list installed plugins and tools. An empty list usually means zinit itself is missing or `zshrc` never loaded.

## Layer 5: shell integration

```bash
echo $SHELL
echo $FZF_DEFAULT_COMMAND
type f ffd ra v vssh
bindkey '^R'
```

- `$SHELL` should be the zsh path.
- `$FZF_DEFAULT_COMMAND` should start with `fd` or `fdfind`.
- `type` should report each name as a `function`.
- `bindkey '^R'` shows what owns Ctrl+R now — fzf or Atuin.

## Layer 6: actually use it

```bash
f            # should open the file picker
z dotfiles   # should jump to the repository
nvim         # should open the configured UI, not bare Neovim
```

If `nvim` opens without the plugin UI, `~/.config/nvim` most likely links to an empty directory (submodule not initialized).

## Common failures and causes

| Symptom | Cause |
|---|---|
| `command not found: zsh` | step 2 failed, or you did not re-login |
| `~/.zshrc` is a plain file | dotlink not run or failed |
| `nvim` older than 0.12 | user-level install missing, system package used |
| `zinit list` empty | zinit directory missing or `zshrc` not loaded |
| `f` undefined | `plugins/fzf/fzf.zsh` not loaded; check `zshrc` |
| `~/.config/nvim` empty | submodule not initialized |

Fix item by item, `exec zsh` again, then re-verify from layer 1.

<!-- lang:ja -->

> 摘要：インストール後、コマンド・シンボリックリンク・Neovim バージョン・シェル統合が本当に動くかを段階的に確認する。

# インストール後の確認

## なぜ必要か

`init.sh` はベストエフォート方式で、失敗したステップは warning を出して続行します。つまり「スクリプトが終わった」は「環境が使える」を意味しません。以下の確認は依存の下から上へ順に並んでいます。

## 第 1 層：コマンドの存在

```bash
command -v zsh git curl
command -v fzf fd rg
command -v eza bat zoxide atuin
command -v nvim tmux
```

期待値：各行が絶対パスを 1 つ表示。表示されなければ未インストールか PATH 外です。

`eza` と `bat` は任意です。`aliases.conf` は `command -v eza` で判定しており、eza がなければ `l`/`ll`/`la` エイリアスは定義されず、エラーも出ません。

## 第 2 層：シンボリックリンクの向き

```bash
ls -l ~/.zshrc ~/.vimrc ~/.config/nvim ~/.config/starship.toml
```

すべて `->` で `~/dotfiles/...` を指すシンボリックリンクであるべきです。`~/.zshrc` が通常ファイルのままなら、dotlink が実行されていないか失敗しています。

マッピング全体を確認するには：

```bash
sed -n '/^\[link\]/,$p' ~/dotfiles/dotlink/dotlinkrc
```

## 第 3 層：Neovim のバージョン

```bash
nvim --version | head -1
```

`NVIM v0.12.x` 以上が必須です。0.12 未満では Treesitter の main ブランチと一部プラグインが失敗します。

`command -v nvim` が `/usr/bin/nvim` を指し、システム版が古い場合：

```bash
ls -l ~/.local/bin/nvim
```

本来は `~/.local/opt/neovim/<version>/bin/nvim` へのシンボリックリンクです。システムパスを指しているなら `nvim-update` でユーザー級インストールを作り直します。

## 第 4 層：Zinit の状態

```bash
zinit list
```

インストール済みのプラグインとツールが列挙されるはずです。空リストは大抵、zinit 本体が無いか `zshrc` が読み込まれていないことを意味します。

## 第 5 層：シェル統合

```bash
echo $SHELL
echo $FZF_DEFAULT_COMMAND
type f ffd ra v vssh
bindkey '^R'
```

- `$SHELL` は zsh のパスであるべき。
- `$FZF_DEFAULT_COMMAND` は `fd` か `fdfind` で始まるべき。
- `type` は各名前を `function` と報告するべき。
- `bindkey '^R'` は Ctrl+R の現在の持ち主（fzf か Atuin）を確認するためのもの。

## 第 6 層：実際に使ってみる

```bash
f            # ファイルピッカーが開くはず
z dotfiles   # リポジトリへジャンプするはず
nvim         # 裸の Neovim ではなく設定済み UI が開くはず
```

`nvim` を開いてプラグイン UI が出ないなら、`~/.config/nvim` が空ディレクトリ（サブモジュール未初期化）にリンクしている可能性が高いです。

## よくある失敗と原因

| 症状 | 原因 |
|---|---|
| `command not found: zsh` | ステップ 2 の失敗、または再ログイン未実施 |
| `~/.zshrc` が通常ファイル | dotlink 未実行または失敗 |
| `nvim` が 0.12 未満 | ユーザー級インストール未構築、システムパッケージを使用 |
| `zinit list` が空 | zinit ディレクトリ欠落または `zshrc` 未読み込み |
| `f` が未定義 | `plugins/fzf/fzf.zsh` 未読み込み。`zshrc` を確認 |
| `~/.config/nvim` が空 | サブモジュール未初期化 |

1 つずつ直し、再度 `exec zsh` してから第 1 層から確認し直します。
