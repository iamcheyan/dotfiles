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
