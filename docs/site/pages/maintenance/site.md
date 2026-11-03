> 摘要：本站的源文件结构、CDS 页面外壳、构建脚本、发布流程与域名配置。

# 本站的构建与发布

## 源码结构

```text
docs/site/
├── build.py        # 生成器：页面、导航、搜索索引、站点地图
├── styles.css      # CDS 外壳与文档版式（单文件，构建时内联）
└── pages/
    ├── start/         # 01 章
    ├── shell/         # 02 章
    ├── commands/      # Linux 命令手册
    ├── tools/         # 工具目录
    ├── scripts/       # 自定义脚本
    ├── zsh-plugins/   # Zsh 插件
    ├── tmux-plugins/  # tmux 插件
    ├── configs/       # 应用配置
    └── maintenance/   # 维护与边界
```

每章一个目录，目录里每个 `.md` 对应一篇文档。章节顺序与文档清单写在 `build.py`
的 `SECTIONS` 里；站点共 130 篇文档、139 个生成页面。

## 页面外壳

页面使用 Cheyan Design System（CDS）：

```text
顶部工具行：项目链接 · 语言切换 · 主题开关
品牌行：    dotfiles.iamcheyan.com · 安装 / 工具 / GitHub / 目录
文档主体：  左侧章节与当前章文档导航 + 右侧正文
页脚：      项目说明与作者署名
```

桌面端保持文档站原有的“左侧导航 + 右侧阅读栏”结构；正文最大宽度为 44rem。
1024px 以下正文优先显示，侧栏通过“目录”按钮展开。颜色、字体、间距、边框、
主题切换和按钮样式沿用 CDS 令牌；浅色与深色主题只替换 token，不复制版式。

`styles.css` 内联进每个页面，因此站点没有额外的 CSS/JS 静态资源依赖。
`APP_JS` 定义在 `build.py` 中，负责语言、主题、目录抽屉和搜索索引交互。

## 文档格式

每篇 Markdown 可以包含中文、英文、日文三个块：

```markdown
> 摘要：一句话说明这篇讲什么。

# 文档标题

正文……

<!-- lang:en -->

> Summary: one-line summary.

# Document title

Body…

<!-- lang:ja -->

> 要約：一行の要約。

# 文書タイトル

本文…
```

| 部分 | 用途 |
|---|---|
| `> 摘要：` / `> Summary:` / `> 要約：` | 提取为 description 与页面导语 |
| `# 标题` | 提取为页面 `<h1>`，正文中移除 |
| `<!-- lang:xx -->` | 分隔三语块；没有标记时按中文单语处理 |
| 其余 Markdown | 转成正文；表格、代码块、标题锚点由 Markdown 扩展处理 |

缺少某语言的正文时，构建会回退到中文，语言切换不会出现空白页。

## 构建

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

输出：

```text
build/site/
├── index.html
├── changes.html
├── start/*.html
├── shell/*.html
├── commands/*.html
├── tools/*.html
├── scripts/*.html
├── zsh-plugins/*.html
├── tmux-plugins/*.html
├── configs/*.html
├── maintenance/*.html
├── CNAME
├── robots.txt
└── sitemap.xml
```

`build/` 被 `.gitignore` 忽略，不提交生成物。

## 搜索

搜索索引由 `search_index()` 从 `SECTIONS`、`LANG_TITLES` 和三语标题生成，
内联为 JSON。浏览器端按当前语言过滤，标题命中优先于描述与正文；`/` 聚焦搜索框，
方向键选择结果，Enter 打开，Escape 关闭。

## 发布

`.github/workflows/deploy-site.yml` 在 `docs/site/**` 或工作流自身变更时触发：

1. checkout 仓库
2. 安装 Python 3.12 与 `Markdown==3.7`
3. 运行 `python3 docs/site/build.py`
4. 上传 `build/site` 为 Pages artifact
5. 部署到 GitHub Pages

## 域名

| 项目 | 值 |
|---|---|
| 域名 | `dotfiles.iamcheyan.com` |
| DNS | Cloudflare CNAME → `iamcheyan.github.io` |
| Pages | workflow 构建，`CNAME` 由生成器写入 |
| HTTPS | 由 Cloudflare 的 `iamcheyan.com` 证书提供 |

## 新增文档或章节

新增文档：在章节目录添加 `.md`，并在 `build.py` 的对应 `SECTIONS` 清单中加入
`(slug, 标题, 摘要)`，然后重新构建。

新增章节：创建 `docs/site/pages/<slug>/`，在 `SECTIONS` 中增加章节元组；顶部
导航、侧栏、首页目录、搜索和 sitemap 会自动包含它。

## 排错

**`FileNotFoundError`**：`SECTIONS` 中声明的文档缺少对应 Markdown 文件。

**链接 404**：跨章节链接需要 `../<slug>/<doc>.html`。

**样式没更新**：样式在构建时内联；确认重新运行了 `build.py`，必要时强制刷新缓存。

**搜索不到新文档**：搜索索引在构建时生成，新增 Markdown 后必须重新构建。

**移动端看不到侧栏**：1024px 以下侧栏默认收起，点击顶栏“目录”按钮展开。

<!-- lang:en -->

> Summary: The site's source layout, CDS shell, build script, publishing workflow and domain configuration.

# Building and Publishing This Site

## Source layout

```text
docs/site/
├── build.py        # generator: pages, navigation, search index, sitemap
├── styles.css      # CDS shell and documentation layout (inlined at build time)
└── pages/
    ├── start/         # chapter 01
    ├── shell/         # chapter 02
    ├── commands/      # Linux command reference
    ├── tools/         # tool catalogue
    ├── scripts/       # custom scripts
    ├── zsh-plugins/   # Zsh plugins
    ├── tmux-plugins/  # tmux plugins
    ├── configs/       # application configuration
    └── maintenance/   # maintenance and boundaries
```

One directory per chapter; each `.md` becomes a document. Section order and document
lists live in `SECTIONS` in `build.py`. The site currently builds 130 documents into
139 pages.

## Page shell

The site uses the Cheyan Design System (CDS):

```text
Utility row: project links · language switch · theme switch
Brand row:   dotfiles.iamcheyan.com · Install / Tools / GitHub / Menu
Body:        chapter/document rail + reading column
Footer:      project note and attribution
```

Desktop keeps the original documentation architecture: a left rail and a reading
column capped at 44rem. Below 1024px the content comes first and the rail opens from
the header's Menu button. Colour, typography, spacing, borders, theme and buttons use
CDS tokens. The dark theme swaps tokens rather than duplicating the layout.

`styles.css` is inlined into every page, so the site has no separate CSS/JS asset
dependency. `APP_JS` in `build.py` owns language, theme, the navigation drawer and
search.

## Document format

Each Markdown file may contain Chinese, English and Japanese blocks:

```markdown
> 摘要：one-line summary.

# Document title

Body…

<!-- lang:en -->

> Summary: one-line summary.

# Document title

Body…

<!-- lang:ja -->

> 要約：一行の要約。

# 文書タイトル

本文…
```

| Part | Purpose |
|---|---|
| `> 摘要：` / `> Summary:` / `> 要約：` | extracted into the description and page lead |
| `# Heading` | extracted into the page `<h1>` and removed from the body |
| `<!-- lang:xx -->` | separates language blocks; files without markers are Chinese-only |
| Other Markdown | rendered as body content with tables, fenced code and heading anchors |

Missing translations fall back to Chinese content, so switching language never blanks
a page.

## Build

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

Output:

```text
build/site/
├── index.html
├── changes.html
├── start/*.html
├── shell/*.html
├── commands/*.html
├── tools/*.html
├── scripts/*.html
├── zsh-plugins/*.html
├── tmux-plugins/*.html
├── configs/*.html
├── maintenance/*.html
├── CNAME
├── robots.txt
└── sitemap.xml
```

`build/` is ignored by Git and is not committed.

## Search

`search_index()` builds a JSON index from `SECTIONS`, `LANG_TITLES` and the
per-language titles. The browser filters it by active language; title matches rank
above descriptions and body text. Press `/` to focus search, use the arrow keys to
select a result, Enter to open it and Escape to close.

## Publishing

`.github/workflows/deploy-site.yml` runs when `docs/site/**` or the workflow changes:

1. checkout the repository
2. install Python 3.12 and `Markdown==3.7`
3. run `python3 docs/site/build.py`
4. upload `build/site` as the Pages artifact
5. deploy to GitHub Pages

## Domain

| Item | Value |
|---|---|
| Domain | `dotfiles.iamcheyan.com` |
| DNS | Cloudflare CNAME → `iamcheyan.github.io` |
| Pages | workflow build; the generator writes `CNAME` |
| HTTPS | provided by the Cloudflare `iamcheyan.com` certificate |

## Adding documents or chapters

For a document, add a `.md` under the chapter directory, add `(slug, title, summary)`
to that chapter's list in `SECTIONS`, and rebuild.

For a chapter, create `docs/site/pages/<slug>/` and add a section tuple to `SECTIONS`.
The top navigation, rail, home index, search index and sitemap include it automatically.

## Troubleshooting

**`FileNotFoundError`**: a document declared in `SECTIONS` has no Markdown file.

**404 link**: cross-chapter links must use `../<slug>/<doc>.html`.

**Styles did not update**: styles are inlined at build time; rebuild with `build.py`
and force-refresh the browser if necessary.

**A new document is not searchable**: the index is generated at build time; rebuild
after adding Markdown.

**The rail is missing on mobile**: it is collapsed below 1024px; open it with the
header's Menu button.

<!-- lang:ja -->

> 要約：本站のソース構成、CDS シェル、ビルドスクリプト、公開手順、ドメイン設定。

# 本站のビルドと公開

## ソース構成

```text
docs/site/
├── build.py        # 生成器：ページ、ナビ、検索索引、サイトマップ
├── styles.css      # CDS シェルと文書レイアウト（ビルド時にインライン化）
└── pages/
    ├── start/         # 第 01 章
    ├── shell/         # 第 02 章
    ├── commands/      # Linux コマンド
    ├── tools/         # ツール一覧
    ├── scripts/       # 自作スクリプト
    ├── zsh-plugins/   # Zsh プラグイン
    ├── tmux-plugins/  # tmux プラグイン
    ├── configs/       # アプリ設定
    └── maintenance/   # メンテナンスと境界
```

章ごとにディレクトリがあり、各 `.md` が 1 ページになります。章の順序と文書一覧は
`build.py` の `SECTIONS` にあります。現在 130 文書、139 ページを生成します。

## ページシェル

Cheyan Design System（CDS）を使用します：

```text
ユーティリティ行：プロジェクトリンク・言語切替・テーマ切替
ブランド行：      dotfiles.iamcheyan.com · 導入 / ツール / GitHub / 目次
本文：            章と文書のナビ + 本文カラム
フッター：        プロジェクト説明と作者表示
```

デスクトップでは従来の「左ナビ + 右本文」を維持し、本文は最大 44rem です。
1024px 以下では本文を先に表示し、左ナビはヘッダーの「目次」ボタンで開きます。
色、書体、余白、罫線、テーマ、ボタンは CDS トークンを使用し、ダークテーマは
レイアウトを複製せずトークンだけを切り替えます。

`styles.css` は各ページにインライン化されるため、別の CSS/JS 資産に依存しません。
`build.py` の `APP_JS` が言語、テーマ、ナビゲーション、検索を担当します。

## 文書形式

各 Markdown は中国語・英語・日本語のブロックを含められます：

```markdown
> 摘要：一行の要約。

# 文書タイトル

本文…

<!-- lang:ja -->

> 要約：一行の要約。

# 文書タイトル

本文…
```

| 部分 | 用途 |
|---|---|
| `> 摘要：` / `> Summary:` / `> 要約：` | description とページ導入文に使用 |
| `# 見出し` | ページの `<h1>` として抽出し、本文から除く |
| `<!-- lang:xx -->` | 言語ブロックの区切り。マーカーがなければ中国語のみ |
| その他の Markdown | 表、コードブロック、見出しアンカー付きで本文に変換 |

訳文がない場合は中国語本文にフォールバックするため、言語切替で空ページになりません。

## ビルド

```bash
cd ~/dotfiles
python3 docs/site/build.py
```

出力：

```text
build/site/
├── index.html
├── changes.html
├── start/*.html
├── shell/*.html
├── commands/*.html
├── tools/*.html
├── scripts/*.html
├── zsh-plugins/*.html
├── tmux-plugins/*.html
├── configs/*.html
├── maintenance/*.html
├── CNAME
├── robots.txt
└── sitemap.xml
```

`build/` は Git の管理外です。

## 検索

`search_index()` が `SECTIONS`、`LANG_TITLES`、各言語のタイトルから JSON 索引を
生成します。ブラウザ側で現在の言語に絞り、タイトル一致を説明文・本文より優先します。
`/` で検索欄に移動し、矢印キーで選択、Enter で開き、Escape で閉じます。

## 公開

`.github/workflows/deploy-site.yml` は `docs/site/**` またはワークフロー変更時に
実行されます：

1. リポジトリを checkout
2. Python 3.12 と `Markdown==3.7` をインストール
3. `python3 docs/site/build.py` を実行
4. `build/site` を Pages artifact としてアップロード
5. GitHub Pages にデプロイ

## ドメイン

| 項目 | 値 |
|---|---|
| ドメイン | `dotfiles.iamcheyan.com` |
| DNS | Cloudflare CNAME → `iamcheyan.github.io` |
| Pages | workflow ビルド。`CNAME` は生成器が書き込み |
| HTTPS | Cloudflare の `iamcheyan.com` 証明書 |

## 文書・章の追加

文書は章ディレクトリに `.md` を追加し、`SECTIONS` の該当章に
`(slug, タイトル, 概要)` を追加して再ビルドします。

章は `docs/site/pages/<slug>/` を作成し、`SECTIONS` に章タプルを追加します。
トップナビ、サイドレール、ホーム目次、検索索引、サイトマップに自動で反映されます。

## トラブルシューティング

**`FileNotFoundError`**：`SECTIONS` に宣言した文書の Markdown がありません。

**リンク 404**：章をまたぐリンクは `../<slug>/<doc>.html` にします。

**スタイルが更新されない**：スタイルはビルド時にインライン化されます。`build.py`
を再実行し、必要ならブラウザキャッシュを更新してください。

**新しい文書が検索に出ない**：索引はビルド時に生成されます。Markdown 追加後に
再ビルドしてください。

**モバイルでサイドレールが見えない**：1024px 以下では折りたたまれます。ヘッダーの
「目次」ボタンで開きます。
