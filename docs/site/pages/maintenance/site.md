> 摘要：本站的源文件结构、构建脚本、发布流程与域名配置。

# 本站的构建与发布

## 源码结构

```text
docs/site/
├── build.py           # 生成器
├── site.css           # 样式（单一文件）
├── site.js            # 交互（搜索、主题、菜单）
└── pages/
    ├── start/         # 01 章，5 篇
    ├── shell/         # 02 章，9 篇
    ├── tools/         # 03 章，41 篇
    ├── scripts/       # 04 章，12 篇
    ├── configs/       # 05 章，12 篇
    └── maintenance/   # 06 章，6 篇
```

每章一个目录，目录里每个 `.md` 对应一篇文档。章节的文档清单写在 `build.py` 的 `SECTIONS` 里。

## 文档格式

每篇 Markdown 以两行开头：

```markdown
> 摘要：一句话说明这篇讲什么。

# 文档标题

正文...
```

| 部分 | 用途 |
|---|---|
| `> 摘要：` | 提取成 `<meta description>` 和页面副标题 |
| `# 标题` | 提取成 `<h1>`，正文里会被移除 |
| 其余 | 转成 HTML 正文 |

## 构建

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

输出：

```text
Built 74 documents + index into build/site
```

生成物：

```text
build/site/
├── index.html           # 总目录
├── assets/site.css
├── assets/site.js
├── start/*.html
├── shell/*.html
├── tools/*.html
├── scripts/*.html
├── configs/*.html
├── maintenance/*.html
├── CNAME
├── robots.txt
└── sitemap.xml
```

`build/` 在 `.gitignore` 里，不提交。

## 生成器做什么

`build.py` 的核心逻辑：

1. 遍历 `SECTIONS` 里的每个章节和文档
2. 读 Markdown，提取摘要和标题
3. 用 `markdown` 库转 HTML
4. 套上统一的页面外壳（导航、侧栏、翻页）
5. 生成总目录页
6. 生成 sitemap 和 robots.txt

### 页面外壳

每篇文档的页面结构：

```html
<header class="masthead">      顶部导航（6 个章节）
<div class="page-shell">
  <aside class="side-rail">    左侧侧栏（当前章节的文档列表）
  <main>
    <nav class="breadcrumb">   面包屑
    <header class="chapter-head">  章号 + 标题 + 摘要
    <article class="prose">    正文
    <nav class="chapter-pager">    上一篇/下一篇
    <footer class="colophon">  页脚
```

**左侧侧栏只显示当前章节的文档**，这是两层信息架构的关键。

### 路径处理

章节页在子目录里，所以资源路径用 `../`：

```python
'<link rel="stylesheet" href="../assets/site.css">'
```

文档之间的链接是同目录相对路径：

```python
f'<a href="{doc}.html">'
```

跨章节链接要写 `../other/index.html`。

## 样式设计

`site.css` 的设计意图写在文件开头：

```css
/* dotfiles.iamcheyan.com — 配置手册 / printed field manual

   Deliberately not the Neovim site. That one is a dark terminal surface with
   monospace and a green accent. This one is warm paper, serif prose, vermilion
   rules, dot-leader contents and marginal chapter numerals. */
```

| 特征 | 实现 |
|---|---|
| 暖纸底 | `--paper: #f4efe4` |
| 衬线正文 | `Noto Serif SC` |
| 朱红强调 | `--vermilion: #a8321a` |
| 点线目录 | `.toc-leader` 的 `border-bottom: 1px dotted` |
| 页边章号 | `.chapter-num` 大号衬线数字 |
| 小节编号 | `.prose h2::before` 的 `counter(section)` |

深色主题是 token 替换，不重写选择器：

```css
:root[data-theme="dark"] {
  --paper: #17130f;
  --ink: #f0e7d8;
  ...
}
```

## 交互

`site.js` 三件事：

| 功能 | 实现 |
|---|---|
| 主题切换 | `localStorage` 存 `dotfiles-theme` |
| 移动端菜单 | 切换 `.top-nav.open` |
| 首页搜索 | 读 `data-search` 属性过滤 |

搜索索引内联在首页 HTML 里：

```python
index = json.dumps([...], ensure_ascii=False)
```

```html
<script type="application/json" id="search-index">{index}</script>
```

## 发布

`.github/workflows/deploy-site.yml`：

```yaml
on:
  push:
    branches: [main]
    paths:
      - "docs/site/**"
      - ".github/workflows/deploy-site.yml"
```

只在站点文件变更时触发，改 shell 配置不会触发部署。

流程：

1. checkout
2. 装 Python 3.12 和 `Markdown==3.7`
3. `python3 docs/site/build.py`
4. `actions/configure-pages`
5. `actions/upload-pages-artifact`
6. `actions/deploy-pages`

## 域名

| 项目 | 值 |
|---|---|
| 域名 | `dotfiles.iamcheyan.com` |
| DNS | Cloudflare CNAME → `iamcheyan.github.io`，代理开启 |
| Pages | `build_type=workflow`，`cname` 已设置 |
| HTTPS | 由 Cloudflare 的 `iamcheyan.com` 证书提供 |

GitHub Pages 自己的证书状态是 `null`，`https_enforced` 无法开启。这是已知限制。

## 新增一篇文档

1. 在对应章节目录建 `.md` 文件
2. 在 `build.py` 的 `SECTIONS` 里加一行：

```python
("newdoc", "新文档标题", "一句话摘要。"),
```

3. 重新构建验证

## 新增一个章节

1. 建目录 `docs/site/pages/newsection/`
2. 在 `SECTIONS` 里加一个元组：

```python
(
    "newsection",
    "新章节",
    "章节范围说明",
    [
        ("index", "本章导读", "摘要。"),
        ...
    ],
),
```

3. 顶部导航会自动包含它

## 排错

**`FileNotFoundError`**：`SECTIONS` 里声明的文档没有对应 `.md` 文件。

**链接 404**：跨章节链接路径写错，少了 `../`。

**样式没更新**：浏览器缓存。`build/site/assets/site.css` 是复制过去的，确认构建跑过。

**搜索不到新文档**：`data-search` 属性由 `build.py` 生成，重新构建才有。

**部署没触发**：改动不在 `docs/site/**` 路径下。

**线上还是旧内容**：Cloudflare 缓存。等几分钟或清缓存。

<!-- lang:en -->

> Summary: The source file layout of this site, the build script, the publishing process, and the domain configuration.

# Building and Publishing This Site

## Source Structure

```text
docs/site/
├── build.py           # 生成器
├── site.css           # 样式（单一文件）
├── site.js            # 交互（搜索、主题、菜单）
└── pages/
    ├── start/         # 01 章，5 篇
    ├── shell/         # 02 章，9 篇
    ├── tools/         # 03 章，41 篇
    ├── scripts/       # 04 章，12 篇
    ├── configs/       # 05 章，12 篇
    └── maintenance/   # 06 章，6 篇
```

One directory per chapter; every `.md` in a directory corresponds to one document. The document list of a chapter is written in `SECTIONS` in `build.py`.

## Document Format

Every Markdown document starts with two lines:

```markdown
> 摘要：一句话说明这篇讲什么。

# 文档标题

正文...
```

| Part | Purpose |
|---|---|
| `> 摘要：` | Extracted into `<meta description>` and the page subtitle |
| `# 标题` | Extracted into `<h1>`, removed from the body |
| Everything else | Converted into the HTML body |

## Build

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

Output:

```text
Built 74 documents + index into build/site
```

Generated artifacts:

```text
build/site/
├── index.html           # 总目录
├── assets/site.css
├── assets/site.js
├── start/*.html
├── shell/*.html
├── tools/*.html
├── scripts/*.html
├── configs/*.html
├── maintenance/*.html
├── CNAME
├── robots.txt
└── sitemap.xml
```

`build/` is in `.gitignore` and is not committed.

## What the Generator Does

The core logic of `build.py`:

1. Iterate over every chapter and document in `SECTIONS`
2. Read the Markdown, extract the summary and title
3. Convert HTML with the `markdown` library
4. Wrap everything in the unified page shell (navigation, sidebar, pager)
5. Generate the master index page
6. Generate the sitemap and robots.txt

### The page shell

The page structure of every document:

```html
<header class="masthead">      顶部导航（6 个章节）
<div class="page-shell">
  <aside class="side-rail">    左侧侧栏（当前章节的文档列表）
  <main>
    <nav class="breadcrumb">   面包屑
    <header class="chapter-head">  章号 + 标题 + 摘要
    <article class="prose">    正文
    <nav class="chapter-pager">    上一篇/下一篇
    <footer class="colophon">  页脚
```

**The left sidebar shows only the documents of the current chapter**; this is the key to the two-level information architecture.

### Path handling

Chapter pages live in subdirectories, so asset paths use `../`:

```python
'<link rel="stylesheet" href="../assets/site.css">'
```

Links between documents are same-directory relative paths:

```python
f'<a href="{doc}.html">'
```

Cross-chapter links must be written as `../other/index.html`.

## Visual Design

The design intent of `site.css` is written at the top of the file:

```css
/* dotfiles.iamcheyan.com — 配置手册 / printed field manual

   Deliberately not the Neovim site. That one is a dark terminal surface with
   monospace and a green accent. This one is warm paper, serif prose, vermilion
   rules, dot-leader contents and marginal chapter numerals. */
```

| Trait | Implementation |
|---|---|
| Warm paper background | `--paper: #f4efe4` |
| Serif body text | `Noto Serif SC` |
| Vermilion accent | `--vermilion: #a8321a` |
| Dot-leader contents | `border-bottom: 1px dotted` on `.toc-leader` |
| Chapter numerals in the margin | Large serif digits in `.chapter-num` |
| Section numbering | `counter(section)` in `.prose h2::before` |

The dark theme is a token swap, not a selector rewrite:

```css
:root[data-theme="dark"] {
  --paper: #17130f;
  --ink: #f0e7d8;
  ...
}
```

## Interactivity

`site.js` does three things:

| Feature | Implementation |
|---|---|
| Theme switching | `localStorage` stores `dotfiles-theme` |
| Mobile menu | Toggles `.top-nav.open` |
| Home page search | Reads the `data-search` attribute to filter |

The search index is inlined into the home page HTML:

```python
index = json.dumps([...], ensure_ascii=False)
```

```html
<script type="application/json" id="search-index">{index}</script>
```

## Publishing

`.github/workflows/deploy-site.yml`:

```yaml
on:
  push:
    branches: [main]
    paths:
      - "docs/site/**"
      - ".github/workflows/deploy-site.yml"
```

It triggers only when site files change; changing shell configuration does not trigger a deployment.

The pipeline:

1. checkout
2. Install Python 3.12 and `Markdown==3.7`
3. `python3 docs/site/build.py`
4. `actions/configure-pages`
5. `actions/upload-pages-artifact`
6. `actions/deploy-pages`

## Domain

| Item | Value |
|---|---|
| Domain | `dotfiles.iamcheyan.com` |
| DNS | Cloudflare CNAME → `iamcheyan.github.io`, proxy enabled |
| Pages | `build_type=workflow`, `cname` is set |
| HTTPS | Provided by the `iamcheyan.com` certificate from Cloudflare |

GitHub Pages' own certificate status is `null`, and `https_enforced` cannot be enabled. This is a known limitation.

## Adding a Document

1. Create the `.md` file in the corresponding chapter directory
2. Add a line to `SECTIONS` in `build.py`:

```python
("newdoc", "新文档标题", "一句话摘要。"),
```

3. Rebuild to verify

## Adding a Chapter

1. Create the directory `docs/site/pages/newsection/`
2. Add a tuple to `SECTIONS`:

```python
(
    "newsection",
    "新章节",
    "章节范围说明",
    [
        ("index", "本章导读", "摘要。"),
        ...
    ],
),
```

3. The top navigation will include it automatically

## Troubleshooting

**`FileNotFoundError`**: a document declared in `SECTIONS` has no corresponding `.md` file.

**A link 404s**: the cross-chapter link path is wrong and missing `../`.

**Styles are not updated**: browser cache. `build/site/assets/site.css` is copied over; confirm the build has run.

**New documents are not searchable**: the `data-search` attribute is generated by `build.py`; it only exists after a rebuild.

**The deployment did not trigger**: the change is not under the `docs/site/**` path.

**The live site still shows old content**: Cloudflare cache. Wait a few minutes or purge the cache.

<!-- lang:ja -->

> 要約：本サイトのソースファイル構成、ビルドスクリプト、公開フロー、ドメイン設定。

# 本サイトのビルドと公開

## ソース構成

```text
docs/site/
├── build.py           # 生成器
├── site.css           # 样式（单一文件）
├── site.js            # 交互（搜索、主题、菜单）
└── pages/
    ├── start/         # 01 章，5 篇
    ├── shell/         # 02 章，9 篇
    ├── tools/         # 03 章，41 篇
    ├── scripts/       # 04 章，12 篇
    ├── configs/       # 05 章，12 篇
    └── maintenance/   # 06 章，6 篇
```

章ごとに 1 つのディレクトリがあり、ディレクトリ内の各 `.md` が 1 つのドキュメントに対応します。章のドキュメント一覧は `build.py` の `SECTIONS` に書かれています。

## ドキュメントの形式

各 Markdown は次の 2 行で始まります：

```markdown
> 摘要：一句话说明这篇讲什么。

# 文档标题

正文...
```

| 部分 | 用途 |
|---|---|
| `> 摘要：` | `<meta description>` とページのサブタイトルに抽出される |
| `# 标题` | `<h1>` に抽出され、本文からは取り除かれる |
| その他 | HTML 本文に変換される |

## ビルド

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

出力：

```text
Built 74 documents + index into build/site
```

生成物：

```text
build/site/
├── index.html           # 总目录
├── assets/site.css
├── assets/site.js
├── start/*.html
├── shell/*.html
├── tools/*.html
├── scripts/*.html
├── configs/*.html
├── maintenance/*.html
├── CNAME
├── robots.txt
└── sitemap.xml
```

`build/` は `.gitignore` に入っており、コミットされません。

## 生成器が行うこと

`build.py` の核心的なロジック：

1. `SECTIONS` 内の各章と各ドキュメントを走査する
2. Markdown を読み、要約とタイトルを抽出する
3. `markdown` ライブラリで HTML に変換する
4. 統一されたページシェル（ナビ、サイドバー、ページ送り）で包む
5. 総目次ページを生成する
6. サイトマップと robots.txt を生成する

### ページシェル

各ドキュメントのページ構造：

```html
<header class="masthead">      顶部导航（6 个章节）
<div class="page-shell">
  <aside class="side-rail">    左侧侧栏（当前章节的文档列表）
  <main>
    <nav class="breadcrumb">   面包屑
    <header class="chapter-head">  章号 + 标题 + 摘要
    <article class="prose">    正文
    <nav class="chapter-pager">    上一篇/下一篇
    <footer class="colophon">  页脚
```

**左側のサイドバーには現在の章のドキュメントだけを表示します**。これが 2 層の情報アーキテクチャの鍵です。

### パス処理

章のページはサブディレクトリにあるため、アセットのパスは `../` を使います：

```python
'<link rel="stylesheet" href="../assets/site.css">'
```

ドキュメント間のリンクは同一ディレクトリの相対パスです：

```python
f'<a href="{doc}.html">'
```

章をまたぐリンクは `../other/index.html` のように書く必要があります。

## デザイン

`site.css` のデザインの意図はファイルの冒頭に書かれています：

```css
/* dotfiles.iamcheyan.com — 配置手册 / printed field manual

   Deliberately not the Neovim site. That one is a dark terminal surface with
   monospace and a green accent. This one is warm paper, serif prose, vermilion
   rules, dot-leader contents and marginal chapter numerals. */
```

| 特徴 | 実装 |
|---|---|
| 暖かい紙の背景 | `--paper: #f4efe4` |
| セリフ体の本文 | `Noto Serif SC` |
| 朱色のアクセント | `--vermilion: #a8321a` |
| 点線リーダーの目次 | `.toc-leader` の `border-bottom: 1px dotted` |
| 余白の章番号 | `.chapter-num` の大きなセリフ体の数字 |
| 小節の番号付け | `.prose h2::before` の `counter(section)` |

ダークテーマはセレクタの書き直しではなく、トークンの置き換えで実現しています：

```css
:root[data-theme="dark"] {
  --paper: #17130f;
  --ink: #f0e7d8;
  ...
}
```

## インタラクション

`site.js` の 3 つの役割：

| 機能 | 実装 |
|---|---|
| テーマ切り替え | `localStorage` に `dotfiles-theme` を保存 |
| モバイルメニュー | `.top-nav.open` をトグル |
| トップページの検索 | `data-search` 属性を読んでフィルタリング |

検索インデックスはトップページの HTML にインライン化されます：

```python
index = json.dumps([...], ensure_ascii=False)
```

```html
<script type="application/json" id="search-index">{index}</script>
```

## 公開

`.github/workflows/deploy-site.yml`：

```yaml
on:
  push:
    branches: [main]
    paths:
      - "docs/site/**"
      - ".github/workflows/deploy-site.yml"
```

サイトのファイルが変わったときだけ発火し、shell 設定の変更ではデプロイされません。

フロー：

1. checkout
2. Python 3.12 と `Markdown==3.7` をインストール
3. `python3 docs/site/build.py`
4. `actions/configure-pages`
5. `actions/upload-pages-artifact`
6. `actions/deploy-pages`

## ドメイン

| 項目 | 値 |
|---|---|
| ドメイン | `dotfiles.iamcheyan.com` |
| DNS | Cloudflare CNAME → `iamcheyan.github.io`、プロキシ有効 |
| Pages | `build_type=workflow`、`cname` 済み |
| HTTPS | Cloudflare の `iamcheyan.com` 証明書で提供 |

GitHub Pages 自体の証明書ステータスは `null` で、`https_enforced` を有効にできません。これは既知の制限です。

## ドキュメントを 1 つ追加する

1. 該当する章のディレクトリに `.md` ファイルを作成する
2. `build.py` の `SECTIONS` に 1 行追加する：

```python
("newdoc", "新文档标题", "一句话摘要。"),
```

3. 再ビルドして検証する

## 章を 1 つ追加する

1. `docs/site/pages/newsection/` ディレクトリを作成する
2. `SECTIONS` にタプルを追加する：

```python
(
    "newsection",
    "新章节",
    "章节范围说明",
    [
        ("index", "本章导读", "摘要。"),
        ...
    ],
),
```

3. トップのナビゲーションに自動的に含まれます

## トラブルシューティング

**`FileNotFoundError`**：`SECTIONS` で宣言されたドキュメントに対応する `.md` ファイルがない。

**リンクが 404 になる**：章をまたぐリンクのパスが間違っていて、`../` が抜けている。

**スタイルが更新されない**：ブラウザキャッシュです。`build/site/assets/site.css` はコピーされたものなので、ビルドが実行されたか確認する。

**新しいドキュメントが検索に出ない**：`data-search` 属性は `build.py` が生成するので、再ビルドして初めて現れます。

**デプロイが発火しない**：変更が `docs/site/**` のパス下にない。

**公開サイトがまだ古い内容**：Cloudflare のキャッシュです。数分待つか、キャッシュを消してください。
