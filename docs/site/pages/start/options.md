> 摘要：--minimal 与 --repair 各自跳过或修复什么，以及未知参数会被如何处理。

# init.sh 选项

## 可用选项

```bash
bash init.sh              # 完整初始化
bash init.sh --minimal    # 轻量模式
bash init.sh --repair     # 额外修复 zinit 插件
```

两个选项可以同时使用：`bash init.sh --minimal --repair`。

## --minimal 跳过什么

脚本里明确跳过这些：

| 跳过项 | 原因 |
|---|---|
| 字体安装 | Meslo Nerd Font 和 Noto Serif CJK 体积大，下载慢 |
| Neovim 安装 | 已有编辑器的机器不需要再装一份 |
| translate-shell | 大型额外组件 |
| yt-dlp | 大型额外组件 |
| jq | 大型额外组件（若系统已装仍可用） |
| viu | 图片终端预览工具 |

启动时会打印一行提示，说明进入了 minimal 模式。适合：只想先拿到 shell 配置、或者在资源受限的机器上试装。

## --repair 修复什么

`--repair` 只做一件事：检查 Zinit 插件目录是否完整，不完整就重新拉取。它针对的是典型的半损坏状态：

- `~/.zinit/plugins/atuinsh---atuin` 存在但缺二进制
- `~/.zinit/plugins/Canop---broot` 下载中断
- 插件目录存在但 `zinit light` 加载时报错

它不会重装系统包，也不会覆盖你的配置文件。

## 未知参数的处理

```bash
bash init.sh --foo
```

当前实现里，参数解析用 `*) shift ;;` 兜底，未知参数被静默跳过，脚本照常按完整模式运行。这意味着**打错选项不会报错，而是执行了你没预期的完整安装**。执行前请核对拼写。

## 选项之外的可调项

`init.sh` 内部有几个环境变量可覆盖，主要用于测试和特殊环境：

| 变量 | 作用 |
|---|---|
| `NVIM_UPDATE_RELEASE_API_URL` | 替换 Neovim release API 地址 |
| `NVIM_UPDATE_INSTALL_ROOT` | 改变 Neovim 安装根目录 |
| `NVIM_UPDATE_BIN_DIR` | 改变 `nvim` 软链接所在目录 |
| `NVIM_UPDATE_TMPDIR` | 改变临时目录 |

这些变量主要由 `scripts/update_nvim.sh` 使用，测试脚本靠它们指向本地 fixture，避免真实下载。

## 什么时候不要用 init.sh

- 只想更新配置：用 `git pull` + `bash dotlink/dotlink link`。
- 只想装 Neovim：直接克隆 `iamcheyan/nvim` 跑它自己的 `init.sh`。
- 只想修复单个工具：用 `scripts/install/` 下的对应脚本。

<!-- lang:en -->

> 摘要：What --minimal skips, what --repair fixes, and how unknown arguments are handled.

# init.sh options

## Available options

```bash
bash init.sh              # full bootstrap
bash init.sh --minimal    # lightweight mode
bash init.sh --repair     # additionally repair zinit plugins
```

The two options combine: `bash init.sh --minimal --repair`.

## What --minimal skips

The script skips exactly these:

| Skipped | Why |
|---|---|
| Font install | Meslo Nerd Font and Noto Serif CJK are large, slow downloads |
| Neovim install | machines that already have an editor do not need another |
| translate-shell | large optional component |
| yt-dlp | large optional component |
| jq | large optional component (still used if the system provides it) |
| viu | in-terminal image previewer |

A line at startup announces minimal mode. Good for: grabbing just the shell config first, or trying the setup on a constrained machine.

## What --repair fixes

`--repair` does one thing: check whether Zinit plugin directories are complete and re-pull them if not. It targets the typical half-broken states:

- `~/.zinit/plugins/atuinsh---atuin` exists but the binary is missing
- `~/.zinit/plugins/Canop---broot` was interrupted mid-download
- a plugin directory exists but `zinit light` errors on load

It does not reinstall system packages or touch your config files.

## Unknown arguments

```bash
bash init.sh --foo
```

In the current implementation argument parsing falls through with `*) shift ;;`, so unknown options are silently skipped and the script runs in full mode. That means **a typo does not error out — it runs the full install you did not ask for**. Check spelling before running.

## Tunables beyond options

A few environment variables can override `init.sh` internals, mainly for testing and special environments:

| Variable | Effect |
|---|---|
| `NVIM_UPDATE_RELEASE_API_URL` | replace the Neovim release API URL |
| `NVIM_UPDATE_INSTALL_ROOT` | change the Neovim install root |
| `NVIM_UPDATE_BIN_DIR` | change where the `nvim` symlink lives |
| `NVIM_UPDATE_TMPDIR` | change the scratch directory |

These are consumed mostly by `scripts/update_nvim.sh`; test scripts point them at local fixtures to avoid real downloads.

## When not to use init.sh

- Only want updated configs: `git pull` + `bash dotlink/dotlink link`.
- Only want Neovim: clone `iamcheyan/nvim` and run its own `init.sh`.
- Only want one tool fixed: use the matching script under `scripts/install/`.

<!-- lang:ja -->

> 摘要：--minimal が省くもの、--repair が直すもの、未知の引数の扱い。

# init.sh のオプション

## 使えるオプション

```bash
bash init.sh              # 完全な初期化
bash init.sh --minimal    # 軽量モード
bash init.sh --repair     # zinit プラグインの追加修復
```

2 つのオプションは併用できます：`bash init.sh --minimal --repair`。

## --minimal が省くもの

スクリプトが明示的に省くのは次のとおりです：

| 省略対象 | 理由 |
|---|---|
| フォントインストール | Meslo Nerd Font と Noto Serif CJK は大きく、ダウンロードが遅い |
| Neovim インストール | 既にエディタがあるマシンでは不要 |
| translate-shell | 大きな追加コンポーネント |
| yt-dlp | 大きな追加コンポーネント |
| jq | 大きな追加コンポーネント（システムにあれば引き続き使用） |
| viu | ターミナル内画像プレビュー |

起動時に minimal モードに入ったことを 1 行で通知します。まずシェル設定だけ欲しい場合や、リソースが限られたマシンでの試用に向いています。

## --repair が直すもの

`--repair` がやることは 1 つ：Zinit プラグインのディレクトリが完全かを確認し、不完全なら引き直します。典型的な半壊れ状態を対象にします：

- `~/.zinit/plugins/atuinsh---atuin` はあるがバイナリが無い
- `~/.zinit/plugins/Canop---broot` のダウンロードが途中で切れた
- プラグインのディレクトリはあるが `zinit light` が読み込み時にエラーを出す

システムパッケージの再インストールも、設定ファイルの上書きも行いません。

## 未知の引数の扱い

```bash
bash init.sh --foo
```

現在の実装では引数解析が `*) shift ;;` でフォールスルーするため、未知のオプションは黙って無視され、スクリプトは完全モードで動きます。つまり**タイプミスはエラーにならず、意図しない完全インストールが走ります**。実行前に綴りを確認してください。

## オプション以外の調整項目

`init.sh` 内部はいくつかの環境変数で上書きできます。主にテストと特殊環境向けです：

| 変数 | 効果 |
|---|---|
| `NVIM_UPDATE_RELEASE_API_URL` | Neovim リリース API の URL を差し替え |
| `NVIM_UPDATE_INSTALL_ROOT` | Neovim のインストールルートを変更 |
| `NVIM_UPDATE_BIN_DIR` | `nvim` シンボリックリンクの置き場所を変更 |
| `NVIM_UPDATE_TMPDIR` | 作業用ディレクトリを変更 |

これらは主に `scripts/update_nvim.sh` が使用します。テストスクリプトはローカルの fixture を指すことで実際のダウンロードを避けています。

## init.sh を使わないほうがよいとき

- 設定の更新だけしたい：`git pull` + `bash dotlink/dotlink link`。
- Neovim だけ欲しい：`iamcheyan/nvim` を clone して自身の `init.sh` を実行。
- 特定ツールの修復だけ：`scripts/install/` の該当スクリプトを使う。
