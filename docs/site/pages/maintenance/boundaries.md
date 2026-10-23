> 摘要：公开层、系统层、私有层各自拥有什么，以及为什么不能跨层复制配置。

# 仓库边界

## 三层分工

### 系统层

由 NixOS 配置管理（`~/nixos-config`）：

| 内容 | 例子 |
|---|---|
| 系统包 | `zsh`、`tmux`、`ripgrep` |
| 服务 | Docker、SSH |
| 硬件 | 显卡驱动、内核模块 |
| 用户组 | `docker`、`video` |
| 字体 | 系统级安装 |

### 私有层

由 Chezmoi 管理（`~/chezmoi`）：

| 内容 | 例子 |
|---|---|
| AI Agent | provider 配置、quota |
| 输入法 | Fcitx5、Karabiner |
| 终端 | Kitty、Zellij |
| Shell 私有扩展 | `~/.config/aliases.conf` |
| 凭据 | API key、token、`.env` |
| 机器专属 | 私有服务器地址、专属脚本 |

### 公开层

本仓库：

| 内容 | 例子 |
|---|---|
| Zsh 通用配置 | `zshrc`、`aliases.conf` |
| CLI 工具配置 | Starship、Atuin、Ranger、Vifm |
| 编辑器 | Vim、GVim、Neovim 子模块 |
| 脚本 | `dotlink`、`init.sh`、安装器 |
| 文档 | `docs/`、本站源文件 |

## 判断标准

一个配置该放哪层，问三个问题：

| 问题 | 是 → | 否 ↓ |
|---|---|---|
| 需要 `sudo` 或改系统？ | 系统层 | 下一问 |
| 含凭据、私有地址、个人身份？ | 私有层 | 下一问 |
| 别人克隆后能直接用？ | 公开层 | 私有层 |

## 公开仓库不接受的

| 类型 | 例子 | 原因 |
|---|---|---|
| 密码、token | API key、SSH 私钥 | 泄露即失效 |
| 私有地址 | 内网 IP、私有域名 | 暴露基础设施 |
| 个人身份 | 真实姓名、邮箱 | 隐私 |
| 机器专属 | 特定路径、专属脚本 | 对他人无用 |
| Agent 配置 | provider、quota | 含凭据 |
| 大文件 | 字体二进制、模型 | 仓库膨胀 |

`.gitignore` 里有对应规则，但**不要只依赖它**——提交前自己确认。

## 跨层协作的正确方式

### 公开层引用私有层

`zshrc` 里：

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
```

私有文件存在就加载，不存在就跳过。公开层不知道私有层的内容。

### tmux

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

同样的模式：检测文件存在再加载。

### local/ 目录

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
```

用户自己的覆盖放 `local/`，Git 忽略除 README 外的所有文件。

## 反模式

**不要**在公开配置里加机器特判：

```zsh
# 错误示范
if [[ "$(hostname)" == "my-laptop" ]]; then
  export SPECIAL_VAR=1
fi
```

正确做法是放进私有层。

**不要**把私有内容复制进公开仓库再 gitignore：

```bash
# 错误示范
cp ~/.config/private.conf ./config/   # 然后加进 .gitignore
```

文件在仓库里就可能在某个时刻被提交。直接放私有层。

**不要**在两个仓库维护同一份配置：改一处忘另一处会导致行为不一致。

## 检查是否误提交

```bash
git log --all --full-history -- '*token*' '*secret*' '*.env'
```

如果发现敏感文件曾进过历史，需要重写历史（`git filter-repo`）并轮换凭据。**仅仅删除文件不够**，历史里还能查到。

## 仓库的提交检查

`.github/workflows/enforce-commit-identity.yml` 会检查提交身份是否符合要求。

`.githooks/lib/privacy-check.sh` 是本地钩子，用于扫描敏感内容。新克隆的仓库会从 `init.templateDir` 拿到钩子。

## 排错

**某个配置在另一台机器上行为不同**：可能依赖了私有层的内容。检查该配置是否有 `if [ -f ... ]` 的降级分支。

**提交被拒**：检查 commit 作者身份是否符合 workflow 要求。

**不确定该放哪**：默认放私有层。从私有移到公开容易，反向很难（历史已公开）。

<!-- lang:en -->

> Summary: What the public layer, system layer, and private layer each own, and why configurations must not be copied across layers.

# Repository Boundaries

## Division of Labor Among the Three Layers

### System Layer

Managed by the NixOS configuration (`~/nixos-config`):

| Content | Examples |
|---|---|
| System packages | `zsh`, `tmux`, `ripgrep` |
| Services | Docker, SSH |
| Hardware | GPU drivers, kernel modules |
| User groups | `docker`, `video` |
| Fonts | System-wide installation |

### Private Layer

Managed by Chezmoi (`~/chezmoi`):

| Content | Examples |
|---|---|
| AI Agents | provider configuration, quota |
| Input methods | Fcitx5, Karabiner |
| Terminals | Kitty, Zellij |
| Private shell extensions | `~/.config/aliases.conf` |
| Credentials | API keys, tokens, `.env` |
| Machine-specific | Private server addresses, dedicated scripts |

### Public Layer

This repository:

| Content | Examples |
|---|---|
| Common Zsh configuration | `zshrc`, `aliases.conf` |
| CLI tool configuration | Starship, Atuin, Ranger, Vifm |
| Editors | Vim, GVim, Neovim submodule |
| Scripts | `dotlink`, `init.sh`, installers |
| Documentation | `docs/`, source files of this site |

## Decision Criteria

To decide which layer a configuration belongs in, ask three questions:

| Question | Yes → | No ↓ |
|---|---|---|
| Requires `sudo` or modifies the system? | System layer | Next question |
| Contains credentials, private addresses, or personal identity? | Private layer | Next question |
| Works directly after others clone it? | Public layer | Private layer |

## What the Public Repository Does Not Accept

| Type | Examples | Reason |
|---|---|---|
| Passwords, tokens | API keys, SSH private keys | Once leaked, they are compromised |
| Private addresses | Intranet IPs, private domains | Exposes infrastructure |
| Personal identity | Real names, email addresses | Privacy |
| Machine-specific | Specific paths, dedicated scripts | Useless to others |
| Agent configuration | providers, quota | Contains credentials |
| Large files | Font binaries, models | Repository bloat |

There are corresponding rules in `.gitignore`, but **do not rely on it alone** — verify it yourself before committing.

## The Right Way to Cooperate Across Layers

### The Public Layer Referencing the Private Layer

In `zshrc`:

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
```

The private file is loaded if it exists and skipped if it does not. The public layer does not know the contents of the private layer.

### tmux

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

The same pattern: check that the file exists before loading it.

### The local/ Directory

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
```

Put your own overrides in `local/`; Git ignores everything there except the README.

## Anti-Patterns

**Do not** add machine-specific conditionals to public configuration:

```zsh
# 错误示范
if [[ "$(hostname)" == "my-laptop" ]]; then
  export SPECIAL_VAR=1
fi
```

The right approach is to put it in the private layer.

**Do not** copy private content into the public repository and then gitignore it:

```bash
# 错误示范
cp ~/.config/private.conf ./config/   # 然后加进 .gitignore
```

Once a file is inside the repository it may be committed at some point. Put it directly in the private layer.

**Do not** maintain the same configuration in two repositories: changing one and forgetting the other leads to inconsistent behavior.

## Checking for Accidentally Committed Secrets

```bash
git log --all --full-history -- '*token*' '*secret*' '*.env'
```

If you find that sensitive files ever entered the history, you need to rewrite history (`git filter-repo`) and rotate credentials. **Deleting the files alone is not enough** — they can still be found in the history.

## Commit Checks in the Repository

`.github/workflows/enforce-commit-identity.yml` checks that the commit identity meets the requirements.

`.githooks/lib/privacy-check.sh` is a local hook used to scan for sensitive content. Freshly cloned repositories get the hooks from `init.templateDir`.

## Troubleshooting

**A configuration behaves differently on another machine**: it may depend on content from the private layer. Check whether the configuration has an `if [ -f ... ]` fallback branch.

**A commit is rejected**: check whether the commit author identity meets the workflow requirements.

**Unsure where something belongs**: default to the private layer. Moving from private to public is easy; the reverse is hard (the history is already public).

<!-- lang:ja -->

> 要約：公開層・システム層・プライベート層のそれぞれが何を所有するか、そして層をまたいで設定をコピーしてはいけない理由。

# リポジトリの境界

## 3 層の役割分担

### システム層

NixOS 設定（`~/nixos-config`）が管理します：

| 内容 | 例 |
|---|---|
| システムパッケージ | `zsh`、`tmux`、`ripgrep` |
| サービス | Docker、SSH |
| ハードウェア | GPU ドライバー、カーネルモジュール |
| ユーザーグループ | `docker`、`video` |
| フォント | システム全体へのインストール |

### プライベート層

Chezmoi が管理します（`~/chezmoi`）：

| 内容 | 例 |
|---|---|
| AI Agent | provider 設定、quota |
| 入力メソッド | Fcitx5、Karabiner |
| ターミナル | Kitty、Zellij |
| Shell のプライベート拡張 | `~/.config/aliases.conf` |
| 認証情報 | API キー、トークン、`.env` |
| マシン固有 | プライベートサーバーのアドレス、専用スクリプト |

### 公開層

本リポジトリ：

| 内容 | 例 |
|---|---|
| Zsh 共通設定 | `zshrc`、`aliases.conf` |
| CLI ツール設定 | Starship、Atuin、Ranger、Vifm |
| エディタ | Vim、GVim、Neovim サブモジュール |
| スクリプト | `dotlink`、`init.sh`、インストーラー |
| ドキュメント | `docs/`、本サイトのソースファイル |

## 判断基準

ある設定をどの層に置くべきか、3 つの質問で判断します：

| 質問 | はい → | いいえ ↓ |
|---|---|---|
| `sudo` が必要、またはシステムを変更するか？ | システム層 | 次の質問へ |
| 認証情報・プライベートアドレス・個人を特定できる情報を含むか？ | プライベート層 | 次の質問へ |
| 他の人がクローンしてすぐ使えるか？ | 公開層 | プライベート層 |

## 公開リポジトリが受け付けないもの

| 種類 | 例 | 理由 |
|---|---|---|
| パスワード、トークン | API キー、SSH 秘密鍵 | 漏洩した時点で失効を要する |
| プライベートアドレス | 内部 IP、プライベートドメイン | インフラが露出する |
| 個人を特定できる情報 | 本名、メールアドレス | プライバシー |
| マシン固有 | 特定のパス、専用スクリプト | 他の人には無用 |
| Agent 設定 | provider、quota | 認証情報を含む |
| 大きなファイル | フォントのバイナリ、モデル | リポジトリが肥大化する |

`.gitignore` に対応するルールがありますが、**それだけに頼らないでください** — コミット前に必ず自分で確認します。

## 層をまたぐ協力の正しいやり方

### 公開層からプライベート層を参照する

`zshrc` 内：

```zsh
[[ -f ~/.config/aliases.conf ]] && source ~/.config/aliases.conf
```

プライベートファイルが存在すれば読み込み、存在しなければスキップします。公開層はプライベート層の内容を知りません。

### tmux

```tmux
if-shell '[ -f "$HOME/.config/tmux/private.conf" ]' {
  source-file "$HOME/.config/tmux/private.conf"
}
```

同じパターンです：ファイルの存在を確認してから読み込みます。

### local/ ディレクトリ

```zsh
for dotfiles_local_file in "$dotfiles_root"/local/*(N.D.); do
    [[ "${dotfiles_local_file:t}" == "README.md" ]] && continue
    source "$dotfiles_local_file"
done
```

ユーザー自身の上書きは `local/` に置き、Git は README 以外のすべてのファイルを無視します。

## アンチパターン

公開設定にマシン固有の条件分岐を追加**しないでください**：

```zsh
# 错误示范
if [[ "$(hostname)" == "my-laptop" ]]; then
  export SPECIAL_VAR=1
fi
```

正しいやり方は、プライベート層に置くことです。

プライベートな内容を公開リポジトリにコピーしてから gitignore する**こともしないでください**：

```bash
# 错误示范
cp ~/.config/private.conf ./config/   # 然后加进 .gitignore
```

ファイルがリポジトリ内にあれば、いつかコミットされる可能性があります。直接プライベート層に置いてください。

同じ設定を 2 つのリポジトリで管理**しないでください**：片方だけ変更してもう片方を忘れると、動作が不一致になります。

## 誤コミットの確認

```bash
git log --all --full-history -- '*token*' '*secret*' '*.env'
```

機密ファイルが履歴に入ったことが判明した場合は、履歴の書き換え（`git filter-repo`）と認証情報のローテーションが必要です。**ファイルを削除するだけでは不十分**で、履歴からまだ辿れてしまいます。

## リポジトリのコミットチェック

`.github/workflows/enforce-commit-identity.yml` は、コミットの作者情報が要件を満たすかチェックします。

`.githooks/lib/privacy-check.sh` は機密内容を走査するローカルフックです。新しくクローンしたリポジトリは `init.templateDir` からフックを取得します。

## トラブルシューティング

**ある設定が別のマシンで異なる動作をする**：プライベート層の内容に依存している可能性があります。その設定に `if [ -f ... ]` のフォールバック分岐があるか確認してください。

**コミットが拒否される**：コミットの作者情報が workflow の要件を満たしているか確認してください。

**どこに置くべきか迷う**：デフォルトでプライベート層に置きます。プライベートから公開へ移すのは簡単ですが、逆は難しくなります（履歴はすでに公開されているため）。
