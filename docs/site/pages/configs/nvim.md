> 摘要：Neovim 作为子模块固定版本，维护者与普通用户的不同链接路径。

# Neovim 子模块

## 关系

```text
iamcheyan/dotfiles
└── config/nvim  ──gitlink──▶  iamcheyan/nvim
```

`config/nvim` 不是普通目录，而是一个 git 子模块指针，记录另一个仓库的某个提交。

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

这串哈希决定你拿到哪一版 Neovim 配置。

## 为什么要子模块

| 理由 | 说明 |
|---|---|
| 独立演进 | Neovim 配置有自己的插件、文档、站点 |
| 独立发布 | 可以单独克隆安装，不依赖 dotfiles |
| 版本固定 | dotfiles 记录一个确定的提交，不随 nvim 仓库漂移 |
| 体积 | Neovim 配置和文档量大，混在主仓库里难以维护 |

## 初始化

新克隆的仓库里 `config/nvim` 是空目录：

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

`--recursive` 是因为子模块内部可能还有子模块。

## 两种链接路径

`dotlink` 里有一段特殊逻辑：

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

| 条件 | 链接目标 |
|---|---|
| 有 `~/nvim` 且 origin 是本仓库 | `~/nvim` |
| 其它情况 | `~/dotfiles/config/nvim` |

### 维护者路径

维护者在 `~/nvim` 开发，`~/.config/nvim` 直接指向它。改代码立即生效，不用进子模块目录。

### 普通用户路径

没有 `~/nvim` 工作副本，链接子模块。`git pull` 更新 dotfiles 时，子模块跟着更新到记录的提交。

## 更新

### 普通用户

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

拿到的是 dotfiles 主仓库记录的那个 nvim 提交，不一定是最新。

### 维护者

```bash
# 1. 在 nvim 仓库开发
cd ~/nvim
git add . && git commit && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

第 2 步记录新的提交哈希，其它用户 `git pull` 后才会拿到。

### 只想更新到 nvim 最新

```bash
cd ~/dotfiles/config/nvim
git fetch && git checkout origin/main
cd ~/dotfiles
git add config/nvim
git commit -m "chore: bump nvim"
```

这会让你的 dotfiles 偏离上游记录的版本。除非你确定，否则等维护者更新。

## Neovim 本体与配置的区别

两件事容易混淆：

| | Neovim 本体 | Neovim 配置 |
|---|---|---|
| 是什么 | 编辑器二进制 | Lua 配置和插件 |
| 谁管理 | `install_nvim.sh` / `nvim-update` | 子模块 `config/nvim` |
| 更新方式 | `nvim-update` | `git submodule update` |

升级编辑器用 `nvim-update`，更新配置用子模块。两者独立。

## 子模块常见状态

```bash
git submodule status
```

| 前缀 | 含义 |
|---|---|
| 空格 | 已初始化，提交匹配 |
| `+` | 已初始化，但提交与记录不同 |
| `-` | 未初始化 |
| `U` | 有冲突 |

看到 `+` 说明子模块里的提交和 dotfiles 记录的不一致。可能是你手动 checkout 过。

## 排错

**`config/nvim` 是空目录**：没初始化子模块。

**`~/.config/nvim` 是空目录**：dotlink 链接到了未初始化的子模块。

**改了配置不生效**：改的是 `~/.config/nvim`（软链接），实际写进了源文件但可能改错了位置。确认 `readlink -f ~/.config/nvim`。

**`git status` 显示子模块有修改**：你在子模块里改了文件。要么提交到 nvim 仓库，要么放弃修改。

**`git pull` 后 Neovim 配置没变**：主仓库的指针没更新，或没跑 `git submodule update`。

**子模块冲突**：`git submodule update --init --recursive --force` 强制同步到记录的提交（会丢弃子模块内的本地修改）。

## 完整文档

Neovim 配置的内容、插件、教程、键位都在独立站点：

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com)
- [插件目录](https://nvim.iamcheyan.com/plugins.html)
- [安装说明](https://nvim.iamcheyan.com/install.html)

<!-- lang:en -->

> Summary: Neovim is pinned as a submodule, with different link paths for maintainers and regular users.

# Neovim Submodule

## Relationship

```text
iamcheyan/dotfiles
└── config/nvim  ──gitlink──▶  iamcheyan/nvim
```

`config/nvim` is not a regular directory but a git submodule pointer that records a specific commit of another repository.

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

This hash determines which version of the Neovim configuration you get.

## Why a Submodule

| Reason | Explanation |
|---|---|
| Independent evolution | The Neovim configuration has its own plugins, docs, and site |
| Independent release | It can be cloned and installed on its own, without the dotfiles |
| Pinned versions | dotfiles records a definite commit that does not drift with the nvim repository |
| Size | The Neovim configuration and docs are large and hard to maintain inside the main repository |

## Initialization

In a freshly cloned repository, `config/nvim` is an empty directory:

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

`--recursive` is needed because the submodule itself may contain submodules.

## Two Link Paths

`dotlink` has a special branch of logic:

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

| Condition | Link target |
|---|---|
| `~/nvim` exists and its origin is this repository | `~/nvim` |
| Any other case | `~/dotfiles/config/nvim` |

### Maintainer Path

Maintainers develop in `~/nvim`, and `~/.config/nvim` points directly at it. Code changes take effect immediately, with no need to go into the submodule directory.

### Regular User Path

Without a `~/nvim` working copy, the submodule is linked. When a `git pull` updates the dotfiles, the submodule follows along to the recorded commit.

## Updating

### Regular Users

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

You get the nvim commit recorded by the dotfiles main repository, which is not necessarily the latest.

### Maintainers

```bash
# 1. 在 nvim 仓库开发
cd ~/nvim
git add . && git commit && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

Step 2 records the new commit hash; only after that do other users get it with `git pull`.

### Updating to the Latest nvim Only

```bash
cd ~/dotfiles/config/nvim
git fetch && git checkout origin/main
cd ~/dotfiles
git add config/nvim
git commit -m "chore: bump nvim"
```

This makes your dotfiles diverge from the version recorded upstream. Unless you are sure, wait for the maintainer to update.

## Neovim Itself vs. the Neovim Configuration

Two things that are easy to confuse:

| | Neovim itself | Neovim configuration |
|---|---|---|
| What it is | The editor binary | Lua configuration and plugins |
| Managed by | `install_nvim.sh` / `nvim-update` | The `config/nvim` submodule |
| How to update | `nvim-update` | `git submodule update` |

Use `nvim-update` to upgrade the editor and the submodule to update the configuration. The two are independent.

## Common Submodule Statuses

```bash
git submodule status
```

| Prefix | Meaning |
|---|---|
| (space) | Initialized, commit matches |
| `+` | Initialized, but the commit differs from the recorded one |
| `-` | Not initialized |
| `U` | Has conflicts |

A `+` means the commit inside the submodule differs from what dotfiles recorded. You may have checked it out manually.

## Troubleshooting

**`config/nvim` is an empty directory**: the submodule was not initialized.

**`~/.config/nvim` is an empty directory**: dotlink linked to an uninitialized submodule.

**Configuration changes do not take effect**: you edited `~/.config/nvim` (a symlink); the write landed in the source file but possibly in the wrong place. Confirm with `readlink -f ~/.config/nvim`.

**`git status` shows the submodule as modified**: you changed files inside the submodule. Either commit them to the nvim repository or discard the changes.

**The Neovim configuration did not change after `git pull`**: the main repository's pointer was not updated, or `git submodule update` was not run.

**Submodule conflicts**: `git submodule update --init --recursive --force` syncs forcibly to the recorded commit (discarding local changes inside the submodule).

## Full Documentation

The Neovim configuration's content, plugins, tutorials, and keybindings are on a separate site:

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com)
- [Plugin directory](https://nvim.iamcheyan.com/plugins.html)
- [Installation guide](https://nvim.iamcheyan.com/install.html)

<!-- lang:ja -->

> 要約：Neovim はサブモジュールとしてバージョンを固定しており、メンテナーと一般ユーザーでリンク先が異なります。

# Neovim サブモジュール

## 関係

```text
iamcheyan/dotfiles
└── config/nvim  ──gitlink──▶  iamcheyan/nvim
```

`config/nvim` は普通のディレクトリではなく、別のリポジトリの特定のコミットを記録する git サブモジュールのポインタです。

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

このハッシュが、どのバージョンの Neovim 設定を取得するかを決めます。

## なぜサブモジュールなのか

| 理由 | 説明 |
|---|---|
| 独立した進化 | Neovim 設定には独自のプラグイン・ドキュメント・サイトがある |
| 独立したリリース | dotfiles に依存せず、単独でクローンしてインストールできる |
| バージョン固定 | dotfiles が確定したコミットを記録し、nvim リポジトリに追従して動かない |
| 容量 | Neovim の設定とドキュメントは量大く、メインリポジトリに混ぜると保守が難しい |

## 初期化

新しくクローンしたリポジトリでは `config/nvim` は空のディレクトリです：

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

`--recursive` が必要なのは、サブモジュールの内部にさらにサブモジュールがある可能性があるためです。

## 2 つのリンク経路

`dotlink` には特別な分岐があります：

```bash
if [[ "$dest" == "$HOME/.config/nvim" && -f "$HOME/nvim/init.lua" ]]; then
    local nvim_remote
    nvim_remote=$(git -C "$HOME/nvim" remote get-url origin 2>/dev/null || true)
    if [[ "$nvim_remote" =~ (^|[:/])iamcheyan/nvim(\.git)?$ ]]; then
        src="$HOME/nvim"
    fi
fi
```

| 条件 | リンク先 |
|---|---|
| `~/nvim` があり、その origin が本リポジトリ | `~/nvim` |
| その他の場合 | `~/dotfiles/config/nvim` |

### メンテナーの経路

メンテナーは `~/nvim` で開発し、`~/.config/nvim` はそれを直接指します。コードの変更は即座に反映され、サブモジュールのディレクトリに入る必要はありません。

### 一般ユーザーの経路

`~/nvim` のワーキングコピーがなければ、サブモジュールがリンクされます。`git pull` で dotfiles を更新すると、サブモジュールも記録されたコミットに合わせて更新されます。

## 更新

### 一般ユーザー

```bash
cd ~/dotfiles
git pull --ff-only
git submodule update --init --recursive
```

取得できるのは dotfiles メインリポジトリが記録している nvim のコミットで、必ずしも最新ではありません。

### メンテナー

```bash
# 1. 在 nvim 仓库开发
cd ~/nvim
git add . && git commit && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

2 番目のステップで新しいコミットハッシュを記録します。それ以降に `git pull` したユーザーが初めて取得します。

### nvim だけ最新に更新したい場合

```bash
cd ~/dotfiles/config/nvim
git fetch && git checkout origin/main
cd ~/dotfiles
git add config/nvim
git commit -m "chore: bump nvim"
```

これを行うと、あなたの dotfiles は上流が記録するバージョンから逸脱します。確信がなければ、メンテナーの更新を待ってください。

## Neovim 本体と設定の違い

混同しやすい 2 つのものです：

| | Neovim 本体 | Neovim 設定 |
|---|---|---|
| 何であるか | エディタのバイナリ | Lua 設定とプラグイン |
| 誰が管理するか | `install_nvim.sh` / `nvim-update` | サブモジュール `config/nvim` |
| 更新方法 | `nvim-update` | `git submodule update` |

エディタのアップグレードは `nvim-update`、設定の更新はサブモジュールで行います。両者は独立しています。

## サブモジュールのよくある状態

```bash
git submodule status
```

| 接頭辞 | 意味 |
|---|---|
| 空白 | 初期化済みで、コミットが一致 |
| `+` | 初期化済みだが、コミットが記録と異なる |
| `-` | 未初期化 |
| `U` | 競合あり |

`+` が付いている場合、サブモジュール内のコミットが dotfiles の記録と一致していません。手動で checkout した可能性があります。

## トラブルシューティング

**`config/nvim` が空のディレクトリ**：サブモジュールを初期化していません。

**`~/.config/nvim` が空のディレクトリ**：dotlink が未初期化のサブモジュールにリンクしています。

**設定を変えても効かない**：`~/.config/nvim`（シンボリックリンク）を編集すると、実際にはソースファイルに書き込まれますが、場所を間違えている可能性があります。`readlink -f ~/.config/nvim` で確認してください。

**`git status` でサブモジュールに変更があると表示される**：サブモジュール内でファイルを変更しています。nvim リポジトリにコミットするか、変更を破棄してください。

**`git pull` 後も Neovim 設定が変わらない**：メインリポジトリのポインタが更新されていないか、`git submodule update` を実行していません。

**サブモジュールの競合**：`git submodule update --init --recursive --force` で記録されたコミットに強制同期します（サブモジュール内のローカル変更は破棄されます）。

## 完全なドキュメント

Neovim 設定の内容・プラグイン・チュートリアル・キーバインドは独立したサイトにあります：

- [nvim.iamcheyan.com](https://nvim.iamcheyan.com)
- [プラグイン一覧](https://nvim.iamcheyan.com/plugins.html)
- [インストールガイド](https://nvim.iamcheyan.com/install.html)
