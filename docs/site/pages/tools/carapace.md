> 摘要：carapace-bin 用一个二进制为大量 CLI 命令提供统一的参数补全，并与 fzf-tab、zsh-vi-mode 共存。

# Carapace

## 它解决什么问题

很多命令的参数补全要分别安装插件，覆盖范围还不一致。carapace-bin 把几百个命令的补全集中到一个二进制里，Zsh 只需要注册一次：

```text
git checkout <Tab>
docker compose <Tab>
kubectl <Tab>
ssh <Tab>
```

它补全的是**参数和子命令**，不是文件名。文件名补全仍由 Zsh 和 fzf-tab 负责。

## 安装

本仓库通过 Zinit 从 GitHub Release 下载对应平台的 tarball：

```zsh
case "$OSTYPE" in
  darwin*)
    local carapace_asset="darwin_amd64"
    [[ "$(uname -m)" == "arm64" ]] && carapace_asset="darwin_arm64"
    ;;
  linux*)
    case "$(uname -m)" in
      aarch64|arm64) carapace_asset="linux_arm64" ;;
      i386|i686) carapace_asset="linux_386" ;;
      armv7l|armv6l|arm) carapace_asset="" ;;
      *) carapace_asset="linux_amd64" ;;
    esac
    ;;
  *) carapace_asset="" ;;
esac

if [[ -n "$carapace_asset" ]]; then
  zinit ice as"command" from"gh-r" \
    bpick"carapace-bin_*_${carapace_asset}.tar.gz" pick"carapace"
  zinit light carapace-sh/carapace-bin
fi
```

Release 里同时有 `.deb`、`.rpm`、`.apk` 和 `.tar.gz`，所以必须用 `bpick` 明确选 tarball，避免下载错资产。

安装后：

```zsh
carapace --version
```

不支持的系统或架构可以手动下载 release，或使用包管理器（Homebrew、AUR、Nix 等）。本仓库的自动安装只覆盖 Linux 的 amd64/386/arm64 和 macOS 的 amd64/arm64。

## Shell 集成

Zsh 需要加载 carapace 生成的补全函数：

```zsh
source <(carapace _carapace)
```

本仓库把它放在 `plugins/carapace/carapace.zsh`，并且在 `zshrc` 的**最后**加载：

```zsh
source "$dotfiles_root/plugins/carapace/carapace.zsh"
```

顺序很重要：`completion.zsh` 的 compinit、grok 安装器里的第二次 compinit、fzf 的补全脚本都会重新注册补全。carapace 必须在它们之后，才能覆盖原生 `_git`、`_docker` 等补全函数。

验证：

```zsh
whence -w _carapace_completer
echo ${_comps[git]}
```

应分别得到 `_carapace_completer: function` 和 `_carapace_completer`。如果 `_comps[git]` 是 `_git`，说明 carapace 被后面的 compinit 或 fzf 覆盖了。

## 基本用法

直接在命令后按 `Tab`：

```text
git <Tab>                 # 子命令、分支、文件
git checkout <Tab>        # 分支和路径
docker compose <Tab>      # 服务名和子命令
kubectl <Tab>             # 资源类型、命名空间
ssh <Tab>                 # 主机和用户
curl <Tab>                # 选项和 URL
```

补全项通常带说明文字。fzf-tab 会把列表变成可搜索的 fzf 菜单，`Tab` 继续向下选择，`Shift+Tab` 返回。

如果只需要给某一条命令注册 carapace，而不启用全部：

```zsh
source <(carapace chmod zsh)
```

查看当前支持的命令：

```zsh
carapace --list
carapace --list | grep kubectl
```

## Bridges：回退到原生补全

carapace 本身覆盖很多命令，但不可能覆盖所有命令。可以启用 bridge，让它在没有专用 completer 时调用 Zsh/Fish/Bash 的原生补全：

```zsh
export CARAPACE_BRIDGES='zsh,fish,bash'
```

本仓库**默认不开启**。原因：

- bridge 可能和 fzf-tab 的原生补全路径重复；
- 某些命令的原生补全比 carapace 更了解本地环境；
- 开启后启动和首次补全可能稍慢。

如果发现某个命令只在原生补全里可用，再设置它，或在 `local/` 里覆盖。

## 样式与配置

carapace 的补全描述颜色可以单独调整：

```zsh
carapace --style 'carapace.Value=bold,magenta'
carapace --style 'carapace.Description=dim'
carapace --style 'carapace.Value='
```

最后一条清除样式。配置和缓存在：

```text
~/.config/carapace
~/.cache/carapace
```

清理缓存：

```zsh
carapace --clear-cache
```

## 自定义 spec

carapace 支持用 YAML spec 扩展命令补全，放在：

```text
~/.config/carapace/specs/
```

常用命令：

```zsh
carapace --schema      # 输出 spec 的 JSON Schema
carapace --macro       # 查看可用宏
carapace --codegen     # 由 spec 生成代码
carapace --run         # 直接运行 spec 调试
```

**spec 会执行命令并生成补全内容**，只使用可信来源。不要把带密钥的命令写进公开 dotfiles。

## 与 fzf-tab、zsh-vi-mode 的关系

| 组件 | 分工 |
|---|---|
| compinit | 建立补全系统 |
| carapace | 为命令注册参数补全函数 |
| fzf-tab | 把补全候选显示成 fzf 菜单 |
| zsh-vi-mode | 命令行编辑键位，不接管 Tab |

carapace 不绑定键位，所以不会和 `zsh-vi-mode` 的 Insert/Normal 模式冲突。它在 fzf-tab 之后加载，fzf-tab 仍然负责最终显示。

## 更新

```zsh
zinit update carapace-sh/carapace-bin
```

不要同时使用 `carapace --selfupdate`，否则 Zinit 管理的版本和自更新版本会打架。更新后执行 `exec zsh`。

## 排错

**`carapace: command not found`**：Zinit 没下载成功。检查 `~/.zinit/plugins/carapace-sh---carapace-bin/carapace` 是否存在，以及当前架构是否在支持列表中。可执行 `zinit update carapace-sh/carapace-bin` 重试。

**所有命令都没有变化**：carapace 没有在 compinit 之后加载。检查 `echo ${_comps[git]}`；如果是 `_git`，把 `source .../carapace.zsh` 移到 zshrc 最后，或重新 `exec zsh`。

**只有某个命令没有补全**：先确认 `carapace --list | grep <command>`。没有专用 completer 时，可以设置 `CARAPACE_BRIDGES` 回退到原生补全，或只给该命令加载 `source <(carapace <command> zsh)`。

**第一次补全很慢**：carapace 会缓存补全结果到 `~/.cache/carapace`，首次调用会稍慢；可以用 `carapace --clear-cache` 清理异常缓存。

**补全颜色和主题不搭**：用 `carapace --style` 调整，或在 `local/` 中覆盖，不要修改本仓库的默认值。

<!-- lang:en -->
> Summary: carapace-bin gives many CLI commands consistent argument completion from one binary, and works with fzf-tab and zsh-vi-mode.

# Carapace

## What it solves

Argument completion for many commands usually means installing separate plugins with uneven coverage. carapace-bin centralizes hundreds of completers in one binary; Zsh registers it once:

```text
git checkout <Tab>
docker compose <Tab>
kubectl <Tab>
ssh <Tab>
```

It completes **arguments and subcommands**, not filenames—file completion still belongs to Zsh and fzf-tab.

## Install

This repo downloads the matching GitHub Release tarball through Zinit:

```zsh
case "$OSTYPE" in
  darwin*)
    local carapace_asset="darwin_amd64"
    [[ "$(uname -m)" == "arm64" ]] && carapace_asset="darwin_arm64"
    ;;
  linux*)
    case "$(uname -m)" in
      aarch64|arm64) carapace_asset="linux_arm64" ;;
      i386|i686) carapace_asset="linux_386" ;;
      armv7l|armv6l|arm) carapace_asset="" ;;
      *) carapace_asset="linux_amd64" ;;
    esac
    ;;
  *) carapace_asset="" ;;
esac

if [[ -n "$carapace_asset" ]]; then
  zinit ice as"command" from"gh-r" \
    bpick"carapace-bin_*_${carapace_asset}.tar.gz" pick"carapace"
  zinit light carapace-sh/carapace-bin
fi
```

Releases contain `.deb`, `.rpm`, `.apk`, and `.tar.gz` assets, so `bpick` selects the tarball explicitly.

```zsh
carapace --version
```

Unsupported platforms can install manually or through Homebrew/AUR/Nix. This repo covers Linux amd64/386/arm64 and macOS amd64/arm64.

## Shell integration

```zsh
source <(carapace _carapace)
```

This repo keeps it in `plugins/carapace/carapace.zsh` and loads it at the **end** of `zshrc`:

```zsh
source "$dotfiles_root/plugins/carapace/carapace.zsh"
```

Order matters: compinit in `completion.zsh`, the second compinit from the grok installer, and fzf's completion scripts all re-register completions. carapace must load after them to override native `_git`, `_docker`, etc.

Verify:

```zsh
whence -w _carapace_completer
echo ${_comps[git]}
```

Expect `_carapace_completer: function` and `_carapace_completer`. If `_comps[git]` is `_git`, a later compinit or fzf overrode carapace.

## Basic use

Press `Tab` after a command:

```text
git <Tab>                 # subcommands, branches, files
git checkout <Tab>        # branches and paths
docker compose <Tab>      # services and subcommands
kubectl <Tab>             # resource types, namespaces
ssh <Tab>                 # hosts and users
curl <Tab>                # options and URLs
```

Entries usually include descriptions. fzf-tab turns the list into a searchable fzf menu; `Tab` moves down, `Shift+Tab` moves up.

Register one command only:

```zsh
source <(carapace chmod zsh)
```

List supported commands:

```zsh
carapace --list
carapace --list | grep kubectl
```

## Bridges

carapace cannot cover every command. Bridges fall back to native Zsh/Fish/Bash completion:

```zsh
export CARAPACE_BRIDGES='zsh,fish,bash'
```

This repo leaves it off by default because:

- it can duplicate fzf-tab's native completion path;
- some native completers know more about the local environment;
- startup and first completion may be slightly slower.

Enable it in `local/` if a specific command only works through native completion.

## Styling and config

```zsh
carapace --style 'carapace.Value=bold,magenta'
carapace --style 'carapace.Description=dim'
carapace --style 'carapace.Value='
```

The last command clears the style. Config and cache live in:

```text
~/.config/carapace
~/.cache/carapace
```

Clear the cache:

```zsh
carapace --clear-cache
```

## Custom specs

YAML specs extend completion for your own commands and live in:

```text
~/.config/carapace/specs/
```

Useful commands:

```zsh
carapace --schema
carapace --macro
carapace --codegen
carapace --run
```

**Specs execute commands to produce completions**; use trusted sources only and never put secrets in public dotfiles.

## Interaction with fzf-tab and zsh-vi-mode

| Component | Role |
|---|---|
| compinit | Builds the completion system |
| carapace | Registers argument completers |
| fzf-tab | Displays candidates in an fzf menu |
| zsh-vi-mode | Command-line editing keys; does not own Tab |

carapace binds no keys, so it does not conflict with zsh-vi-mode Insert/Normal modes. Loading it after fzf-tab leaves fzf-tab in charge of display.

## Update

```zsh
zinit update carapace-sh/carapace-bin
```

Do not also use `carapace --selfupdate`; that fights Zinit's managed version. Run `exec zsh` afterwards.

## Troubleshooting

**`carapace: command not found`**: the Zinit download failed. Check `~/.zinit/plugins/carapace-sh---carapace-bin/carapace`, confirm the architecture is supported, and retry `zinit update carapace-sh/carapace-bin`.

**Nothing changed**: carapace is not loading after compinit. Check `echo ${_comps[git]}`; if it is `_git`, move the source line to the end of `zshrc` and `exec zsh`.

**One command lacks completion**: check `carapace --list | grep <command>`. If there is no completer, enable `CARAPACE_BRIDGES` or load `source <(carapace <command> zsh)` for that command.

**First completion is slow**: carapace caches results in `~/.cache/carapace`; the first run is slower. Use `carapace --clear-cache` if the cache is stale.

**Colors clash with the theme**: use `carapace --style`, or override it in `local/`; do not edit this repo's default.

<!-- lang:ja -->
> 要約：carapace-bin は 1 つのバイナリで多数の CLI に一貫した引数補完を提供し、fzf-tab と zsh-vi-mode と共存します。

# Carapace

## 解決する問題

コマンドごとに補完プラグインを入れると、対応範囲にばらつきが出ます。carapace-bin は数百のコマンドの補完を 1 つのバイナリにまとめ、Zsh 側では一度登録するだけです：

```text
git checkout <Tab>
docker compose <Tab>
kubectl <Tab>
ssh <Tab>
```

補完するのは**引数とサブコマンド**で、ファイル名ではありません。ファイル名補完は Zsh と fzf-tab が担当します。

## インストール

本リポジトリでは Zinit でプラットフォーム別の tarball を取得します：

```zsh
case "$OSTYPE" in
  darwin*)
    local carapace_asset="darwin_amd64"
    [[ "$(uname -m)" == "arm64" ]] && carapace_asset="darwin_arm64"
    ;;
  linux*)
    case "$(uname -m)" in
      aarch64|arm64) carapace_asset="linux_arm64" ;;
      i386|i686) carapace_asset="linux_386" ;;
      armv7l|armv6l|arm) carapace_asset="" ;;
      *) carapace_asset="linux_amd64" ;;
    esac
    ;;
  *) carapace_asset="" ;;
esac

if [[ -n "$carapace_asset" ]]; then
  zinit ice as"command" from"gh-r" \
    bpick"carapace-bin_*_${carapace_asset}.tar.gz" pick"carapace"
  zinit light carapace-sh/carapace-bin
fi
```

Release には `.deb`、`.rpm`、`.apk`、`.tar.gz` が混在するため、`bpick` で tarball を明示します。

```zsh
carapace --version
```

未対応環境では手動ダウンロード、Homebrew、AUR、Nix などを使います。本リポジトリは Linux amd64/386/arm64 と macOS amd64/arm64 を対象にします。

## シェル統合

```zsh
source <(carapace _carapace)
```

本リポジトリでは `plugins/carapace/carapace.zsh` に置き、`zshrc` の**最後**で読み込みます：

```zsh
source "$dotfiles_root/plugins/carapace/carapace.zsh"
```

順序が重要です。`completion.zsh` の compinit、grok インストーラの 2 回目の compinit、fzf の補完スクリプトが補完を再登録するため、carapace はその後に読み込む必要があります。

確認：

```zsh
whence -w _carapace_completer
echo ${_comps[git]}
```

`_carapace_completer: function` と `_carapace_completer` が表示されれば OK です。`_comps[git]` が `_git` なら、後続の compinit か fzf に上書きされています。

## 基本操作

コマンドの後に `Tab`：

```text
git <Tab>
git checkout <Tab>
docker compose <Tab>
kubectl <Tab>
ssh <Tab>
curl <Tab>
```

候補には説明が付くことがあります。fzf-tab が有効なら検索可能な fzf メニューになり、`Tab` で下、`Shift+Tab` で上へ移動します。

単一コマンドだけ登録：

```zsh
source <(carapace chmod zsh)
```

対応コマンド一覧：

```zsh
carapace --list
carapace --list | grep kubectl
```

## Bridges

carapace が対応していないコマンドは、ネイティブ補完へフォールバックできます：

```zsh
export CARAPACE_BRIDGES='zsh,fish,bash'
```

本リポジトリでは既定で無効です：

- fzf-tab のネイティブ補完経路と重複する可能性；
- ネイティブ補完の方がローカル環境を詳しく知っている場合がある；
- 起動や初回補完が少し遅くなる。

必要なコマンドだけ `local/` で有効にします。

## スタイルと設定

```zsh
carapace --style 'carapace.Value=bold,magenta'
carapace --style 'carapace.Description=dim'
carapace --style 'carapace.Value='
```

最後の行はスタイル解除です。設定とキャッシュ：

```text
~/.config/carapace
~/.cache/carapace
```

キャッシュ削除：

```zsh
carapace --clear-cache
```

## カスタム spec

YAML spec で独自コマンドの補完を追加できます：

```text
~/.config/carapace/specs/
```

```zsh
carapace --schema
carapace --macro
carapace --codegen
carapace --run
```

**spec は補完生成のためにコマンドを実行します**。信頼できるものだけを使い、公開 dotfiles に秘密情報を書かないでください。

## fzf-tab と zsh-vi-mode

| コンポーネント | 役割 |
|---|---|
| compinit | 補完システムの構築 |
| carapace | 引数補完関数の登録 |
| fzf-tab | 候補を fzf メニューで表示 |
| zsh-vi-mode | コマンドライン編集キー。Tab は奪わない |

carapace はキーをバインドしないため、zsh-vi-mode の Insert/Normal と衝突しません。fzf-tab の後に読み込むことで、表示は fzf-tab が担当します。

## 更新

```zsh
zinit update carapace-sh/carapace-bin
```

`carapace --selfupdate` は併用しないでください。Zinit 管理のバージョンと競合します。更新後は `exec zsh`。

## トラブルシュート

**`carapace: command not found`**：Zinit のダウンロード失敗です。`~/.zinit/plugins/carapace-sh---carapace-bin/carapace` を確認し、アーキテクチャが対応しているか確認して `zinit update carapace-sh/carapace-bin` を再実行します。

**何も変わらない**：compinit 後に carapace が読み込まれていません。`echo ${_comps[git]}` が `_git` なら、`source .../carapace.zsh` を `zshrc` の最後へ移して `exec zsh`。

**特定のコマンドだけ補完されない**：`carapace --list | grep <command>` で確認します。専用 completer がなければ `CARAPACE_BRIDGES` を有効にするか、`source <(carapace <command> zsh)` で個別に登録します。

**初回補完が遅い**：`~/.cache/carapace` にキャッシュされます。初回は遅く、異常に遅い場合は `carapace --clear-cache`。

**色がテーマに合わない**：`carapace --style` で調整するか、`local/` で上書きします。本リポジトリの既定値は変更しません。
