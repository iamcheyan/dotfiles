> 摘要：改完配置后应该跑哪些静态检查、脚本测试和站点构建。

# 检查与测试

## 静态检查

### shell 语法

```bash
zsh -d -n ~/dotfiles/zshrc
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
zsh -d -n ~/dotfiles/plugins/fzf/fzf.zsh
bash -n ~/dotfiles/init.sh
bash -n ~/dotfiles/aliases.conf
```

`-n` 只解析不执行。`-d` 禁用全局 rc，避免加载你的实际配置。

### 空白字符

```bash
cd ~/dotfiles && git diff --check
```

检查行尾空白、冲突标记。提交前必跑。

### 脚本静态分析

```bash
shellcheck ~/dotfiles/init.sh
shellcheck ~/dotfiles/tools/*.sh
```

shellcheck 会指出未引用变量、错误的比较运算符、易错的重定向等。不是所有警告都要修，但 SC2086（未引用变量）几乎总是真问题。

## 运行时检查

### Zsh 配置加载

```bash
TERM=xterm-256color zsh -lic 'source ~/dotfiles/zshrc >/dev/null 2>&1; true'
echo $?
```

在登录 shell 里 source 完整配置，退出码应为 0。

### 追踪加载过程

```bash
zsh -x -i -c 'true' 2>&1 | head -80
```

看最后几行就知道卡在哪。

### 函数是否定义

```bash
zsh -ic 'type f ffd ra v vssh zz'
```

## 脚本测试

### Neovim 更新器

```bash
bash ~/dotfiles/scripts/tests/nvim_update_test.sh
```

这个测试用本地 fixture 模拟 GitHub API：

```bash
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$digest" \
  '{tag_name: $tag, assets: [{name: $name, browser_download_url: $url, digest: $digest}]}'
```

它验证：

| 场景 | 期望 |
|---|---|
| 正常升级 | 装到新版本目录，软链接更新 |
| SHA-256 不匹配 | 拒绝安装，退出非零 |
| `--help` | 输出用法 |
| 别名传参 | `nvim-update --help` 正确透传 |

**不下载真实文件**，所以可以在离线环境跑。

### Vim 配置测试

```bash
vim -u ~/dotfiles/config/vim/vimrc -c 'source ~/dotfiles/config/vim/tests/vim_config_spec.vim'
```

## 站点构建

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

输出：

```text
Built 74 documents + index into build/site
```

检查：

```bash
# 页面数
find build/site -name '*.html' | wc -l

# 内部链接
python3 - <<'PY'
from pathlib import Path
from html.parser import HTMLParser
root = Path('build/site')
class A(HTMLParser):
    def __init__(self):
        super().__init__(); self.links = []
    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag == 'a' and 'href' in d: self.links.append(d['href'])
bad = []
for page in root.rglob('*.html'):
    a = A(); a.feed(page.read_text())
    for href in a.links:
        if href.startswith(('http:', 'https:', '#', 'mailto:')): continue
        target = (page.parent / href.split('#')[0]).resolve()
        if not target.exists(): bad.append((page, href))
print('broken:', len(bad))
PY
```

## 提交前清单

```bash
cd ~/dotfiles
git status                      # 确认改了哪些
git diff                        # 逐行检查
git diff --check                # 空白字符
zsh -d -n zshrc                 # 如果改了 shell
bash -n init.sh                 # 如果改了 init
python3 docs/site/build.py      # 如果改了站点
```

## 隐私检查

提交前确认没有敏感内容：

```bash
git diff --cached | grep -iE 'token|secret|password|api[_-]?key|BEGIN.*PRIVATE'
```

有匹配就停下来看是不是误提交。

## 排错

**`zsh -n` 报语法错但实际能跑**：可能用了 `-n` 不支持的语法（比如某些 heredoc）。改用 `zsh -x -c 'source file'` 实测。

**shellcheck 报大量警告**：先只看 `error` 级别：

```bash
shellcheck -S error init.sh
```

**测试脚本失败**：读脚本里的 assert 消息，通常直接说明了期望值。

**站点构建报 `FileNotFoundError`**：某篇文档缺失。检查 `SECTIONS` 里声明的 slug 是否都有对应 `.md`。

**链接检查报 broken**：文档里写了相对路径但目标不存在。注意章节页用 `../` 前缀。

<!-- lang:en -->

> Summary: Which static checks, script tests, and site builds to run after changing configuration.

# Checks and Tests

## Static Checks

### Shell syntax

```bash
zsh -d -n ~/dotfiles/zshrc
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
zsh -d -n ~/dotfiles/plugins/fzf/fzf.zsh
bash -n ~/dotfiles/init.sh
bash -n ~/dotfiles/aliases.conf
```

`-n` only parses without executing. `-d` disables global rc files so your actual configuration is not loaded.

### Whitespace

```bash
cd ~/dotfiles && git diff --check
```

Checks trailing whitespace and conflict markers. Must be run before every commit.

### Static script analysis

```bash
shellcheck ~/dotfiles/init.sh
shellcheck ~/dotfiles/tools/*.sh
```

shellcheck points out unquoted variables, wrong comparison operators, error-prone redirections, and more. Not every warning needs fixing, but SC2086 (unquoted variable) is almost always a real problem.

## Runtime Checks

### Loading the Zsh configuration

```bash
TERM=xterm-256color zsh -lic 'source ~/dotfiles/zshrc >/dev/null 2>&1; true'
echo $?
```

Sources the full configuration in a login shell; the exit code should be 0.

### Tracing the load process

```bash
zsh -x -i -c 'true' 2>&1 | head -80
```

The last few lines tell you where it got stuck.

### Whether functions are defined

```bash
zsh -ic 'type f ffd ra v vssh zz'
```

## Script Tests

### The Neovim updater

```bash
bash ~/dotfiles/scripts/tests/nvim_update_test.sh
```

This test uses a local fixture to simulate the GitHub API:

```bash
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$digest" \
  '{tag_name: $tag, assets: [{name: $name, browser_download_url: $url, digest: $digest}]}'
```

It verifies:

| Scenario | Expectation |
|---|---|
| Normal upgrade | Installs into the new version directory and updates the symlink |
| SHA-256 mismatch | Refuses to install and exits non-zero |
| `--help` | Prints usage |
| Aliases passing arguments | `nvim-update --help` passes through correctly |

It **does not download real files**, so it can run in an offline environment.

### The Vim configuration test

```bash
vim -u ~/dotfiles/config/vim/vimrc -c 'source ~/dotfiles/config/vim/tests/vim_config_spec.vim'
```

## Site Build

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

Output:

```text
Built 74 documents + index into build/site
```

Checks:

```bash
# 页面数
find build/site -name '*.html' | wc -l

# 内部链接
python3 - <<'PY'
from pathlib import Path
from html.parser import HTMLParser
root = Path('build/site')
class A(HTMLParser):
    def __init__(self):
        super().__init__(); self.links = []
    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag == 'a' and 'href' in d: self.links.append(d['href'])
bad = []
for page in root.rglob('*.html'):
    a = A(); a.feed(page.read_text())
    for href in a.links:
        if href.startswith(('http:', 'https:', '#', 'mailto:')): continue
        target = (page.parent / href.split('#')[0]).resolve()
        if not target.exists(): bad.append((page, href))
print('broken:', len(bad))
PY
```

## Pre-Commit Checklist

```bash
cd ~/dotfiles
git status                      # 确认改了哪些
git diff                        # 逐行检查
git diff --check                # 空白字符
zsh -d -n zshrc                 # 如果改了 shell
bash -n init.sh                 # 如果改了 init
python3 docs/site/build.py      # 如果改了站点
```

## Privacy Check

Before committing, confirm there is no sensitive content:

```bash
git diff --cached | grep -iE 'token|secret|password|api[_-]?key|BEGIN.*PRIVATE'
```

If there are matches, stop and check whether it is an accidental commit.

## Troubleshooting

**`zsh -n` reports a syntax error but the file actually runs**: you may be using syntax that `-n` does not support (such as certain heredocs). Test it for real with `zsh -x -c 'source file'`.

**shellcheck reports many warnings**: look at the `error` level first:

```bash
shellcheck -S error init.sh
```

**A test script fails**: read the assert messages in the script; they usually state the expected value directly.

**The site build reports `FileNotFoundError`**: a document is missing. Check that every slug declared in `SECTIONS` has a corresponding `.md` file.

**The link check reports broken**: a relative path is written in a document but the target does not exist. Note that chapter pages use the `../` prefix.

<!-- lang:ja -->

> 要約：設定を変更した後に実行すべき静的チェック、スクリプトテスト、サイトビルド。

# チェックとテスト

## 静的チェック

### Shell の構文

```bash
zsh -d -n ~/dotfiles/zshrc
zsh -d -n ~/dotfiles/plugins/zsh-plugins.zsh
zsh -d -n ~/dotfiles/plugins/fzf/fzf.zsh
bash -n ~/dotfiles/init.sh
bash -n ~/dotfiles/aliases.conf
```

`-n` は実行せずに構文解析だけを行います。`-d` はグローバルな rc を無効化し、実際の設定を読み込まないようにします。

### 空白文字

```bash
cd ~/dotfiles && git diff --check
```

行末の空白やコンフリクトマーカーをチェックします。コミット前に必ず実行します。

### スクリプトの静的解析

```bash
shellcheck ~/dotfiles/init.sh
shellcheck ~/dotfiles/tools/*.sh
```

shellcheck は、引用されていない変数、誤った比較演算子、落とし穴になりがちなリダイレクトなどを指摘します。すべての警告を修正する必要はありませんが、SC2086（引用されていない変数）はほぼ常に実際の問題です。

## 実行時チェック

### Zsh 設定の読み込み

```bash
TERM=xterm-256color zsh -lic 'source ~/dotfiles/zshrc >/dev/null 2>&1; true'
echo $?
```

ログインシェルで完全な設定を source し、終了コードが 0 であることを確認します。

### 読み込み過程のトレース

```bash
zsh -x -i -c 'true' 2>&1 | head -80
```

最後の数行を見れば、どこで止まっているかが分かります。

### 関数が定義されているか

```bash
zsh -ic 'type f ffd ra v vssh zz'
```

## スクリプトテスト

### Neovim アップデーター

```bash
bash ~/dotfiles/scripts/tests/nvim_update_test.sh
```

このテストはローカルの fixture で GitHub API を模擬します：

```bash
jq -n --arg tag 'v0.12.5' --arg name 'nvim-linux-x86_64.tar.gz' \
  --arg url "$asset_url" --arg digest "sha256:$digest" \
  '{tag_name: $tag, assets: [{name: $name, browser_download_url: $url, digest: $digest}]}'
```

検証する内容：

| シナリオ | 期待結果 |
|---|---|
| 通常のアップグレード | 新バージョンのディレクトリにインストールされ、シンボリックリンクが更新される |
| SHA-256 不一致 | インストールを拒否し、非ゼロで終了する |
| `--help` | 使い方を出力する |
| エイリアス経由の引数 | `nvim-update --help` が正しく透過される |

**実ファイルをダウンロードしない**ので、オフライン環境でも実行できます。

### Vim 設定のテスト

```bash
vim -u ~/dotfiles/config/vim/vimrc -c 'source ~/dotfiles/config/vim/tests/vim_config_spec.vim'
```

## サイトビルド

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

出力：

```text
Built 74 documents + index into build/site
```

チェック：

```bash
# 页面数
find build/site -name '*.html' | wc -l

# 内部链接
python3 - <<'PY'
from pathlib import Path
from html.parser import HTMLParser
root = Path('build/site')
class A(HTMLParser):
    def __init__(self):
        super().__init__(); self.links = []
    def handle_starttag(self, tag, attrs):
        d = dict(attrs)
        if tag == 'a' and 'href' in d: self.links.append(d['href'])
bad = []
for page in root.rglob('*.html'):
    a = A(); a.feed(page.read_text())
    for href in a.links:
        if href.startswith(('http:', 'https:', '#', 'mailto:')): continue
        target = (page.parent / href.split('#')[0]).resolve()
        if not target.exists(): bad.append((page, href))
print('broken:', len(bad))
PY
```

## コミット前チェックリスト

```bash
cd ~/dotfiles
git status                      # 确认改了哪些
git diff                        # 逐行检查
git diff --check                # 空白字符
zsh -d -n zshrc                 # 如果改了 shell
bash -n init.sh                 # 如果改了 init
python3 docs/site/build.py      # 如果改了站点
```

## プライバシーチェック

コミット前に機密内容が含まれていないか確認します：

```bash
git diff --cached | grep -iE 'token|secret|password|api[_-]?key|BEGIN.*PRIVATE'
```

マッチした場合は立ち止まって、誤コミットではないか確認してください。

## トラブルシューティング

**`zsh -n` が構文エラーを報告するが実際には動く**：`-n` が対応していない構文（一部の heredoc など）を使っている可能性があります。`zsh -x -c 'source file'` で実際に試してください。

**shellcheck が大量の警告を出す**：まず `error` レベルだけを見ます：

```bash
shellcheck -S error init.sh
```

**テストスクリプトが失敗する**：スクリプト内の assert メッセージを読みます。通常は期待値が直接書かれています。

**サイトビルドが `FileNotFoundError` を報告する**：ドキュメントが欠けています。`SECTIONS` で宣言された slug に対応する `.md` がすべて存在するか確認してください。

**リンクチェックが broken を報告する**：ドキュメントに相対パスが書かれているのに対象が存在しません。章のページは `../` 接頭辞を使う点に注意してください。
