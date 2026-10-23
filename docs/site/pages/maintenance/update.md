> 摘要：更新配置、子模块、Neovim 本体和插件的四条独立路径。

# 更新流程

## 四条路径

| 更新什么 | 命令 |
|---|---|
| 配置 | `git pull` + `dotlink link` |
| Neovim 配置 | `git submodule update` |
| Neovim 本体 | `nvim-update` |
| Zinit 插件和工具 | `zinit update` |

它们互相独立，不要混为一谈。

## 更新配置

```bash
cd ~/dotfiles
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

`--ff-only` 保证不产生意外的 merge commit。如果本地有提交导致无法 fast-forward，先处理本地提交。

`dotlink link` 用于同步新增/删除的映射。如果只是改了文件内容，软链接已经指向源文件，不需要重跑。

`exec zsh` 让新配置生效。

## 更新 Neovim 配置

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

这会把 `config/nvim` 拉到主仓库记录的提交。

查看当前版本：

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

前面的哈希是当前 checkout 的提交。

### 如果子模块有本地修改

```bash
cd ~/dotfiles/config/nvim
git status
```

有修改时 `git submodule update` 会拒绝或覆盖。先决定：提交到 nvim 仓库，还是丢弃。

## 更新 Neovim 本体

```bash
nvim-update
```

这是独立的脚本，把编辑器二进制升级到最新稳定版。详见 [nvim-update](../scripts/nvim-update.html)。

验证：

```bash
nvim --version | head -1
```

## 更新 Zinit 插件和工具

```zsh
zinit update
```

这更新 Zinit 管理的所有插件和从 GitHub Release 下载的二进制。

只更新一个：

```zsh
zinit update sharkdp/fd
```

## 完整更新流程

想全部更新时：

```bash
# 1. 配置
cd ~/dotfiles
git pull --ff-only

# 2. Neovim 配置
git submodule update --init --recursive

# 3. 软链接
bash dotlink/dotlink link

# 4. Neovim 本体
nvim-update

# 5. Zinit 插件
zsh -ic 'zinit update'

# 6. 重载 shell
exec zsh
```

## 回退

### 配置回退

```bash
cd ~/dotfiles
git log --oneline -5
git checkout <commit> -- <file>
```

或者整体回退：

```bash
git reset --hard <commit>
```

**注意**：`reset --hard` 会丢弃所有本地修改。

### Neovim 本体回退

```bash
ls ~/.local/opt/neovim/
ln -sf ~/.local/opt/neovim/0.11.4/bin/nvim ~/.local/bin/nvim
```

旧版本保留着，改软链接即可。

### Zinit 插件回退

```zsh
zinit delete <plugin>
zinit light <plugin>
```

或者进插件目录手动 checkout 旧提交。

## 维护者更新 Neovim 指针

```bash
# 1. 在 nvim 仓库提交
cd ~/nvim
git add . && git commit -m "..." && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

第 2 步记录新哈希，其他用户 `git pull` 后才会拿到。

## 检查更新结果

```bash
# 配置
git -C ~/dotfiles log -1 --oneline

# 子模块
git -C ~/dotfiles submodule status

# Neovim
nvim --version | head -1

# Zinit
zsh -ic 'zinit list | head -20'

# 软链接
ls -l ~/.zshrc ~/.config/nvim
```

## 排错

**`git pull` 失败「not possible to fast-forward」**：本地有提交或分叉。`git log --oneline origin/main..HEAD` 看本地多了什么。

**子模块更新后 Neovim 配置没变**：`readlink -f ~/.config/nvim` 确认链接指向哪。维护者机器可能指向 `~/nvim`。

**`nvim-update` 后插件报错**：新版本可能改 API。`nvim --version` 确认，必要时回退。

**`zinit update` 后命令消失**：某个插件的 release 资产名变了。`zinit delete` 后重新 `zinit light`。

**更新后 shell 启动变慢**：新插件在同步下载。第二次启动应该正常。

<!-- lang:en -->

> Summary: Four independent paths for updating the configuration, submodules, Neovim itself, and plugins.

# Update Process

## The Four Paths

| What to update | Command |
|---|---|
| Configuration | `git pull` + `dotlink link` |
| Neovim configuration | `git submodule update` |
| Neovim itself | `nvim-update` |
| Zinit plugins and tools | `zinit update` |

They are independent of one another; do not conflate them.

## Updating the Configuration

```bash
cd ~/dotfiles
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

`--ff-only` guarantees no unexpected merge commits. If local commits prevent a fast-forward, deal with the local commits first.

`dotlink link` syncs newly added or removed mappings. If you only changed file contents, the symlinks already point at the source files and there is no need to rerun it.

`exec zsh` makes the new configuration take effect.

## Updating the Neovim Configuration

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

This pulls `config/nvim` to the commit recorded by the main repository.

Check the current version:

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

The hash at the front is the currently checked-out commit.

### If the submodule has local modifications

```bash
cd ~/dotfiles/config/nvim
git status
```

With modifications present, `git submodule update` will refuse or overwrite. Decide first: commit to the nvim repository, or discard.

## Updating Neovim Itself

```bash
nvim-update
```

This is a standalone script that upgrades the editor binary to the latest stable release. See [nvim-update](../scripts/nvim-update.html) for details.

Verify:

```bash
nvim --version | head -1
```

## Updating Zinit Plugins and Tools

```zsh
zinit update
```

This updates all plugins managed by Zinit and the binaries downloaded from GitHub Releases.

Update just one:

```zsh
zinit update sharkdp/fd
```

## The Full Update Flow

To update everything:

```bash
# 1. 配置
cd ~/dotfiles
git pull --ff-only

# 2. Neovim 配置
git submodule update --init --recursive

# 3. 软链接
bash dotlink/dotlink link

# 4. Neovim 本体
nvim-update

# 5. Zinit 插件
zsh -ic 'zinit update'

# 6. 重载 shell
exec zsh
```

## Rolling Back

### Rolling back the configuration

```bash
cd ~/dotfiles
git log --oneline -5
git checkout <commit> -- <file>
```

Or roll back wholesale:

```bash
git reset --hard <commit>
```

**Note**: `reset --hard` discards all local modifications.

### Rolling back Neovim itself

```bash
ls ~/.local/opt/neovim/
ln -sf ~/.local/opt/neovim/0.11.4/bin/nvim ~/.local/bin/nvim
```

Old versions are kept; just change the symlink.

### Rolling back Zinit plugins

```zsh
zinit delete <plugin>
zinit light <plugin>
```

Or enter the plugin directory and manually check out an older commit.

## Maintainers Updating the Neovim Pointer

```bash
# 1. 在 nvim 仓库提交
cd ~/nvim
git add . && git commit -m "..." && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

Step 2 records the new hash; only after other users `git pull` will they receive it.

## Checking the Update Result

```bash
# 配置
git -C ~/dotfiles log -1 --oneline

# 子模块
git -C ~/dotfiles submodule status

# Neovim
nvim --version | head -1

# Zinit
zsh -ic 'zinit list | head -20'

# 软链接
ls -l ~/.zshrc ~/.config/nvim
```

## Troubleshooting

**`git pull` fails with "not possible to fast-forward"**: there are local commits or a divergence. Use `git log --oneline origin/main..HEAD` to see what local commits exist.

**The Neovim configuration did not change after the submodule update**: use `readlink -f ~/.config/nvim` to confirm where the link points. A maintainer's machine may point at `~/nvim`.

**Plugins error after `nvim-update`**: the new version may have changed APIs. Confirm with `nvim --version`, and roll back if necessary.

**Commands disappear after `zinit update`**: a plugin's release asset name changed. Do `zinit delete` and then `zinit light` again.

**The shell starts slowly after an update**: a new plugin is downloading synchronously. The second start should be normal.

<!-- lang:ja -->

> 要約：設定・サブモジュール・Neovim 本体・プラグインを更新する 4 つの独立した経路。

# 更新手順

## 4 つの経路

| 更新対象 | コマンド |
|---|---|
| 設定 | `git pull` + `dotlink link` |
| Neovim 設定 | `git submodule update` |
| Neovim 本体 | `nvim-update` |
| Zinit プラグインとツール | `zinit update` |

これらは互いに独立しているため、混同しないでください。

## 設定の更新

```bash
cd ~/dotfiles
git pull --ff-only
bash dotlink/dotlink link
exec zsh
```

`--ff-only` は予期しないマージコミットの発生を防ぎます。ローカルのコミットが原因で fast-forward できない場合は、先にローカルのコミットを処理します。

`dotlink link` は追加・削除されたマッピングを同期します。ファイルの内容だけを変更した場合は、シンボリックリンクはすでにソースファイルを指しているので、再実行は不要です。

`exec zsh` で新しい設定を有効化します。

## Neovim 設定の更新

```bash
cd ~/dotfiles
git submodule update --init --recursive
```

これにより `config/nvim` がメインリポジトリが記録しているコミットに引き上げられます。

現在のバージョンを確認：

```bash
git submodule status
# fd9ac81ffd366a7674b71cb3b97daf53b9de06b7 config/nvim (heads/main-6-gfd9ac81)
```

先頭のハッシュが現在チェックアウトされているコミットです。

### サブモジュールにローカルの変更がある場合

```bash
cd ~/dotfiles/config/nvim
git status
```

変更があると `git submodule update` は拒否するか上書きします。先に判断してください：nvim リポジトリにコミットするか、破棄するか。

## Neovim 本体の更新

```bash
nvim-update
```

エディタのバイナリを最新安定版に更新する独立したスクリプトです。詳しくは [nvim-update](../scripts/nvim-update.html) を参照してください。

検証：

```bash
nvim --version | head -1
```

## Zinit プラグインとツールの更新

```zsh
zinit update
```

Zinit が管理するすべてのプラグインと、GitHub Release からダウンロードしたバイナリを更新します。

1 つだけ更新する場合：

```zsh
zinit update sharkdp/fd
```

## 完全な更新フロー

すべて更新したい場合：

```bash
# 1. 配置
cd ~/dotfiles
git pull --ff-only

# 2. Neovim 配置
git submodule update --init --recursive

# 3. 软链接
bash dotlink/dotlink link

# 4. Neovim 本体
nvim-update

# 5. Zinit 插件
zsh -ic 'zinit update'

# 6. 重载 shell
exec zsh
```

## ロールバック

### 設定のロールバック

```bash
cd ~/dotfiles
git log --oneline -5
git checkout <commit> -- <file>
```

または全体をロールバック：

```bash
git reset --hard <commit>
```

**注意**：`reset --hard` はすべてのローカルの変更を破棄します。

### Neovim 本体のロールバック

```bash
ls ~/.local/opt/neovim/
ln -sf ~/.local/opt/neovim/0.11.4/bin/nvim ~/.local/bin/nvim
```

古いバージョンは残っているので、シンボリックリンクを張り替えるだけです。

### Zinit プラグインのロールバック

```zsh
zinit delete <plugin>
zinit light <plugin>
```

またはプラグインのディレクトリに入り、手動で古いコミットを checkout します。

## メンテナーによる Neovim ポインタの更新

```bash
# 1. 在 nvim 仓库提交
cd ~/nvim
git add . && git commit -m "..." && git push

# 2. 回 dotfiles 更新指针
cd ~/dotfiles
git add config/nvim
git commit -m "chore: update Neovim submodule"
git push
```

第 2 ステップで新しいハッシュを記録します。他のユーザーは `git pull` して初めてそれを受け取ります。

## 更新結果の確認

```bash
# 配置
git -C ~/dotfiles log -1 --oneline

# 子模块
git -C ~/dotfiles submodule status

# Neovim
nvim --version | head -1

# Zinit
zsh -ic 'zinit list | head -20'

# 软链接
ls -l ~/.zshrc ~/.config/nvim
```

## トラブルシューティング

**`git pull` が「not possible to fast-forward」で失敗する**：ローカルにコミットがあるか分岐しています。`git log --oneline origin/main..HEAD` でローカルに何があるか確認します。

**サブモジュール更新後に Neovim 設定が変わらない**：`readlink -f ~/.config/nvim` でリンクがどこを指しているか確認します。メンテナーのマシンは `~/nvim` を指している可能性があります。

**`nvim-update` 後にプラグインがエラーになる**：新しいバージョンが API を変更した可能性があります。`nvim --version` で確認し、必要ならロールバックします。

**`zinit update` 後にコマンドが消える**：プラグインの release アセット名が変わりました。`zinit delete` してから `zinit light` し直します。

**更新後に shell の起動が遅くなる**：新しいプラグインが同期的にダウンロードしています。2 回目の起動は正常なはずです。
