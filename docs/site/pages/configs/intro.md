> 摘要：dotlink 实际部署了哪些配置，哪些在仓库里但不会自动链接。

# 本章导读

> **主题规范：** 本仓库终端配色统一遵循 [Neovim Blue / Nostalgia 标准](theme-standard.html)。新增或修改工具主题时，按该页的颜色角色和对比要求执行。

## 两类配置

| 类别 | 是否自动部署 |
|---|---|
| 列入 `dotlink/dotlinkrc` 的 | 是，`dotlink link` 时建立软链接 |
| 在 `config/` 但未列入的 | 否，需要手动链接 |

这个区别很重要：看到 `config/ghostty/config` 存在，不代表安装后 Ghostty 就用上了它。

## 阅读顺序

1. [映射清单](mapping.html) — 先看哪些配置真的会生效。
2. 然后按需跳转：Starship、tmux、Ranger、Vifm、Vim、Ghostty。
3. [Neovim 子模块](nvim.html) — 编辑器部分指向独立站点。

## 配置文件的共同特点

本仓库的配置遵循几条规则：

| 规则 | 体现 |
|---|---|
| 不写死个人路径 | 用 `$HOME`、相对路径、运行时推导 |
| 可选依赖先探测 | `command -v` 判断，缺失时降级 |
| 私有内容外部引入 | tmux 的 `private.conf`、`local/` 目录 |
| 单一职责 | 一个文件管一个程序 |

## 修改配置的流程

```bash
# 1. 改源文件，不要改软链接目标
$EDITOR ~/dotfiles/config/tmux/tmux.conf

# 2. 验证
bash -n ~/dotfiles/zshrc          # 如果是 shell
tmux source-file ~/.config/tmux/tmux.conf   # 如果是 tmux

# 3. 提交
cd ~/dotfiles && git diff && git commit
```

改完通常不需要重跑 `dotlink`，因为软链接指向的就是源文件。只有新增/删除映射时才需要。

<!-- lang:en -->

> Summary: Which configurations dotlink actually deploys, and which ones sit in the repository without being auto-linked.

# About This Chapter

> **Theme convention:** All terminal color schemes in this repository follow the [Neovim Blue / Nostalgia standard](theme-standard.html). When adding or modifying a tool's theme, follow the color roles and contrast requirements on that page.

## Two Kinds of Configuration

| Category | Auto-deployed |
|---|---|
| Listed in `dotlink/dotlinkrc` | Yes, symlinked by `dotlink link` |
| In `config/` but not listed | No, must be linked manually |

This distinction matters: the existence of `config/ghostty/config` does not mean Ghostty will use it after installation.

## Reading Order

1. [Mapping list](mapping.html) — first check which configurations actually take effect.
2. Then jump to what you need: Starship, tmux, Ranger, Vifm, Vim, Ghostty.
3. [Neovim submodule](nvim.html) — the editor section points to a separate site.

## Common Traits of the Configuration Files

The configurations in this repository follow a few rules:

| Rule | How it shows up |
|---|---|
| No hard-coded personal paths | Uses `$HOME`, relative paths, runtime detection |
| Optional dependencies are probed first | `command -v` checks with graceful degradation when missing |
| Private content is externalized | tmux's `private.conf`, the `local/` directory |
| Single responsibility | One file governs one program |

## How to Modify a Configuration

```bash
# 1. 改源文件，不要改软链接目标
$EDITOR ~/dotfiles/config/tmux/tmux.conf

# 2. 验证
bash -n ~/dotfiles/zshrc          # 如果是 shell
tmux source-file ~/.config/tmux/tmux.conf   # 如果是 tmux

# 3. 提交
cd ~/dotfiles && git diff && git commit
```

After editing you usually do not need to re-run `dotlink`, because the symlinks point directly at the source files. You only need it when adding or removing mappings.

<!-- lang:ja -->

> 要約：dotlink が実際にデプロイする設定と、リポジトリにはあるが自動リンクされない設定の違いについて。

# この章の読み方

> **テーマ規約：** 本リポジトリの端末配色はすべて [Neovim Blue / Nostalgia 標準](theme-standard.html) に統一されています。ツールのテーマを追加・変更する際は、そのページの色の役割とコントラストの要件に従ってください。

## 2 種類の設定

| 区分 | 自動デプロイ |
|---|---|
| `dotlink/dotlinkrc` に記載されているもの | はい。`dotlink link` でシンボリックリンクを作成 |
| `config/` にあるが未記載のもの | いいえ。手動でリンクが必要 |

この違いは重要です。`config/ghostty/config` が存在していても、インストール後に Ghostty がそれを使うとは限りません。

## 読む順番

1. [マッピング一覧](mapping.html) — まずどの設定が実際に効くのかを確認します。
2. 次に必要に応じて参照します：Starship、tmux、Ranger、Vifm、Vim、Ghostty。
3. [Neovim サブモジュール](nvim.html) — エディタ部分は独立したサイトを指します。

## 設定ファイルに共通する特徴

本リポジトリの設定はいくつかのルールに従っています：

| ルール | 現れ方 |
|---|---|
| 個人パスをハードコードしない | `$HOME`・相対パス・実行時の推論を使う |
| 任意の依存は先に検出する | `command -v` で判定し、無ければ縮退動作 |
| プライベートな内容は外部に置く | tmux の `private.conf`、`local/` ディレクトリ |
| 単一責任 | 1 ファイルが 1 プログラムを担当 |

## 設定を変更する流れ

```bash
# 1. 改源文件，不要改软链接目标
$EDITOR ~/dotfiles/config/tmux/tmux.conf

# 2. 验证
bash -n ~/dotfiles/zshrc          # 如果是 shell
tmux source-file ~/.config/tmux/tmux.conf   # 如果是 tmux

# 3. 提交
cd ~/dotfiles && git diff && git commit
```

編集後、通常は `dotlink` の再実行は不要です。シンボリックリンクはソースファイルを直接指しているためです。必要になるのはマッピングの追加・削除時だけです。
