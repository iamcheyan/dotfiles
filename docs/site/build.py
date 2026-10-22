#!/usr/bin/env python3
"""Build the static public dotfiles guide into build/site.

Two-level information architecture:

  * top navigation = the six sections
  * left rail      = the individual documents of the current section

Design intent: a printed field manual, not a terminal dashboard. Warm paper,
serif prose, vermilion rules, dot-leader contents, marginal chapter numerals.
The Neovim site is deliberately the opposite: dark, monospace, green.
"""
from __future__ import annotations

import json
import re
import shutil
from html import escape
from pathlib import Path

import markdown

ROOT = Path(__file__).resolve().parents[2]
SITE_ROOT = ROOT / "docs" / "site"
SOURCE = SITE_ROOT / "pages"
OUT = ROOT / "build" / "site"

SITE = {
    "name": "Dotfiles",
    "repo": "iamcheyan/dotfiles",
    "url": "https://dotfiles.iamcheyan.com",
    "tagline": "一套公开、可独立使用的终端工作环境配置",
}

# section -> (label, one-line scope, [(doc slug, title, summary)])
SECTIONS = [
    (
        "start",
        "开始使用",
        "安装、选项与安装后核对",
        [
            ("index", "本章导读", "这套配置由什么组成，按什么顺序读。"),
            ("install", "安装流程", "克隆、子模块、init.sh、dotlink 的实际执行顺序。"),
            ("options", "init.sh 选项", "--minimal 与 --repair 各自跳过或修复什么。"),
            ("verify", "安装后核对", "逐项检查命令、链接和 Neovim 版本。"),
            ("layout", "目录结构", "仓库每个目录负责什么，哪些是生成物。"),
        ],
    ),
    (
        "shell",
        "Zsh 与终端",
        "加载顺序、交互插件、搜索函数",
        [
            ("index", "本章导读", "shell 环境的组成与阅读顺序。"),
            ("loading", "启动与加载顺序", "zshrc 到 zinit、补全、插件、fzf 的完整链路。"),
            ("history", "历史与命令行编辑", "vi-mode、Atuin、历史选项与绑定检查。"),
            ("completion", "补全系统", "compinit、zsh-completions、fzf-tab 三个阶段。"),
            ("plugins", "交互插件", "autosuggestions、autopair、you-should-use、forgit、语法高亮。"),
            ("fzf-functions", "f 与 ffd 函数", "两个文件搜索函数的行为、按键与回退逻辑。"),
            ("fnm-node", "fnm 与 Node 工具链", "惰性加载包装器与 Inshellisense 集成。"),
            ("terminal", "终端与提示符", "Starship、Ghostty、tmux 的分工。"),
            ("troubleshooting", "排错清单", "启动报错、插件缺失、预览不显示怎么查。"),
        ],
    ),
    (
        "tools",
        "工具目录",
        "每个工具一篇，用途、用法、参数、配置",
        [
            ("index", "工具总表", "全部工具与它们的来源、入口、所属章节。"),
            ("eza", "eza", "带图标与 Git 状态的 ls 替代。"),
            ("bat", "bat", "带语法高亮的 cat，同时是 fzf 预览器。"),
            ("fd", "fd", "按文件名查找，fzf 的默认枚举器。"),
            ("ripgrep", "ripgrep", "按内容搜索，遵守 ignore 规则。"),
            ("fzf", "fzf", "交互式模糊筛选，多个函数的底座。"),
            ("zoxide", "zoxide", "按访问频率跳转目录。"),
            ("atuin", "Atuin", "SQLite 历史库与增强搜索。"),
            ("direnv", "direnv", "按目录加载环境变量。"),
            ("starship", "Starship", "跨 shell 提示符。"),
            ("fnm", "fnm", "Node 版本管理器与惰性加载。"),
            ("inshellisense", "Inshellisense", "IDE 风格命令参数建议。"),
            ("forgit", "forgit", "fzf 驱动的 Git 交互命令。"),
            ("lazygit", "lazygit", "终端 Git 全功能界面。"),
            ("gitui", "gitui", "Rust 写的终端 Git 界面。"),
            ("delta", "delta", "diff 阅读器与 Git pager。"),
            ("gh", "GitHub CLI", "命令行操作仓库、PR、Actions。"),
            ("btop", "btop", "资源监视器。"),
            ("bottom", "bottom (btm)", "可配置的系统监视器。"),
            ("duf", "duf", "磁盘用量表。"),
            ("procs", "procs", "ps 的现代替代。"),
            ("gping", "gping", "带延迟曲线的 ping。"),
            ("xh", "xh", "友好的 HTTP 客户端。"),
            ("jq", "jq", "JSON 查询与改写。"),
            ("yq", "yq", "YAML/JSON 查询与改写。"),
            ("sd", "sd", "直观的文本替换。"),
            ("choose", "choose", "按列/字段抽取文本。"),
            ("glow", "glow", "终端里渲染 Markdown。"),
            ("tldr", "tldr (tealdeer)", "命令示例速查。"),
            ("broot", "broot", "树状目录浏览与 br 函数。"),
            ("ranger", "Ranger", "文件管理器与 ra 包装函数。"),
            ("vifm", "Vifm", "Vim 风格双栏文件管理器。"),
            ("yazi", "Yazi", "现代文件管理器与 flavor。"),
            ("tmux", "tmux", "终端复用、会话恢复、pane 导航。"),
            ("zellij", "zellij", "另一套终端复用器。"),
            ("fresh", "Fresh", "终端文本编辑器。"),
            ("neovim", "Neovim", "编辑器入口与独立文档站。"),
            ("httpie", "HTTPie", "http 命令与安装器。"),
            ("navi", "navi", "cheatsheet 搜索与填参。"),
            ("pet", "Pet", "命令片段库。"),
            ("pay-respects", "Pay Respects", "失败命令的修正建议。"),
        ],
    ),
    (
        "scripts",
        "自定义脚本",
        "自研工具与安装器",
        [
            ("index", "本章导读", "哪些脚本是自研的，哪些是上游安装器。"),
            ("dotlink", "dotlink", "软链接管理器：规则、备份、参数。"),
            ("init", "init.sh", "跨平台初始化：11 个步骤与失败策略。"),
            ("nvim-install", "Neovim 安装器", "install_nvim.sh 的平台与版本处理。"),
            ("nvim-update", "nvim-update", "稳定版升级、SHA-256 校验、原子切换。"),
            ("fonts", "字体安装器", "Meslo 与 Noto Serif CJK 的安装路径。"),
            ("httpie-installer", "HTTPie 安装器", "包管理器、pipx、pip 三级回退。"),
            ("zellij-installer", "Zellij 安装器", "cargo 与 binary 两种方式。"),
            ("ssh", "SSH 与 SSHFS", "vssh 与 vifm-sshfs 的参数和挂载位置。"),
            ("archives", "归档工具", "packtar 与三个解压脚本的差异。"),
            ("cleanup", "清理与系统脚本", "clear.sh 与 winetricks.sh 的影响范围。"),
            ("tmux-new", "tmux-new", "新建会话脚本的用法。"),
        ],
    ),
    (
        "configs",
        "应用配置",
        "每个配置文件的作用与键位",
        [
            ("index", "本章导读", "dotlink 实际映射了哪些配置。"),
            ("mapping", "映射清单", "源路径、目标路径与是否自动部署。"),
            ("starship", "Starship 配置", "两行提示符的模块与显示条件。"),
            ("atuin", "Atuin 配置", "关闭自动同步、数据库位置。"),
            ("tmux", "tmux 配置", "选项、键位、TPM 插件与恢复策略。"),
            ("ranger", "Ranger 配置", "预览、图标、归档插件与快捷键。"),
            ("vifm", "Vifm 配置", "键位表、剪贴板脚本与双栏布局。"),
            ("vim", "Vim 与 GVim", "共享默认值、主题与 GUI 差异。"),
            ("ghostty", "Ghostty 配置", "字体、配色、选中复制。"),
            ("misc", "nano、Herdr 与 Yazi", "其余小配置的边界。"),
            ("nvim", "Neovim 子模块", "版本固定方式与独立文档站。"),
        ],
    ),
    (
        "maintenance",
        "维护与边界",
        "更新、检查与私人覆盖",
        [
            ("index", "本章导读", "维护这套配置需要知道的事。"),
            ("boundaries", "仓库边界", "公开层、系统层、私有层各自负责什么。"),
            ("update", "更新流程", "git pull、子模块、dotlink 与 Neovim 升级。"),
            ("checks", "检查与测试", "静态检查、脚本测试、站点构建。"),
            ("local", "私人覆盖", "local/ 与 aliases 子仓库的正确用法。"),
            ("site", "本站的构建与发布", "Markdown 源、构建脚本、Actions 部署。"),
        ],
    ),
]

NAV = [(s[0], s[1], f"{i + 1:02d}") for i, s in enumerate(SECTIONS)]
BY_SLUG = {s[0]: s for s in SECTIONS}
DOC_INDEX = {
    f"{s[0]}/{d[0]}": (s[0], s[1], d[0], d[1], d[2], f"{i + 1:02d}")
    for i, s in enumerate(SECTIONS)
    for d in s[3]
}

MD = markdown.Markdown(extensions=["tables", "fenced_code", "toc", "attr_list", "sane_lists"])


def esc(s: str) -> str:
    return escape(s, quote=True)


def render_md(text: str) -> str:
    MD.reset()
    return MD.convert(text)


def top_nav(section: str, prefix: str = "../") -> str:
    return "\n".join(
        f'<a class="top-link{" current" if slug == section else ""}" href="{prefix}{slug}/index.html">'
        f"<span>{num}</span>{esc(label)}</a>"
        for slug, label, num in NAV
    )


def rail(section: str, current_doc: str) -> str:
    _slug, label, _scope, docs = BY_SLUG[section]
    items = "\n".join(
        f'<a class="rail-link{" current" if d[0] == current_doc else ""}" href="{d[0]}.html">'
        f"<span>{esc(d[1])}</span></a>"
        for d in docs
    )
    return f'''<aside class="side-rail">
      <p class="rail-title">{esc(label)}</p>
      <nav class="rail-nav">{items}</nav>
      <div class="rail-note">
        <p class="rail-note-k">来源</p>
        <p><code>iamcheyan/dotfiles</code></p>
        <p class="rail-note-k">正文依据</p>
        <p>仓库中已跟踪的脚本与配置文件</p>
      </div>
    </aside>'''


def masthead(section: str, prefix: str = "../") -> str:
    return f'''<header class="masthead">
  <div class="masthead-inner">
    <a class="wordmark" href="{prefix}index.html">
      <span class="wordmark-rule"></span>
      <span class="wordmark-text">Dotfiles</span>
      <span class="wordmark-sub">配置手册</span>
    </a>
    <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="site-nav">目录</button>
    <nav class="top-nav" id="site-nav">{top_nav(section, prefix)}</nav>
    <div class="masthead-actions">
      <a class="ghost-link" href="https://github.com/{SITE["repo"]}">GitHub</a>
      <button class="theme-toggle" type="button" aria-label="切换明暗主题"><span class="theme-glyph"></span></button>
    </div>
  </div>
</header>'''


def doc_pager(section: str, doc: str) -> str:
    docs = BY_SLUG[section][3]
    i = next(n for n, d in enumerate(docs) if d[0] == doc)
    prev_d = docs[i - 1] if i > 0 else None
    next_d = docs[i + 1] if i + 1 < len(docs) else None
    left = (
        f'<a href="{prev_d[0]}.html"><span class="pager-k">上一篇</span>'
        f'<span class="pager-t">{esc(prev_d[1])}</span></a>'
        if prev_d
        else '<span class="pager-empty"></span>'
    )
    right = (
        f'<a class="pager-next" href="{next_d[0]}.html"><span class="pager-k">下一篇</span>'
        f'<span class="pager-t">{esc(next_d[1])}</span></a>'
        if next_d
        else '<a class="pager-next" href="../index.html"><span class="pager-k">回到总目录</span>'
        '<span class="pager-t">全部章节</span></a>'
    )
    return f'<nav class="chapter-pager" aria-label="文档翻页">{left}{right}</nav>'


def page(section: str, doc: str) -> tuple[dict, str]:
    src = SOURCE / section / f"{doc}.md"
    text = src.read_text(encoding="utf-8")
    match = re.search(r"^> 摘要：(.+)$", text, re.M)
    desc = match.group(1).strip() if match else ""
    title_match = re.search(r"^# (.+)$", text, re.M)
    title = title_match.group(1).strip() if title_match else doc
    searchable = re.sub(r"\s+", " ", re.sub(r"[`#>*|]", " ", text))
    text = re.sub(r"^> 摘要：.+\n\n", "", text, count=1, flags=re.M)
    text = re.sub(r"^# .+\n+", "", text, count=1)
    num = DOC_INDEX[f"{section}/{doc}"][5]
    body = render_md(text)
    html = f'''<!doctype html>
<html lang="zh-CN" data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="{esc(desc)}">
  <meta name="theme-color" content="#f4efe4">
  <title>{esc(title)} · {esc(BY_SLUG[section][1])} · Dotfiles</title>
  <link rel="canonical" href="{SITE["url"]}/{section}/{doc}.html">
  <link rel="stylesheet" href="../assets/site.css">
  <script defer src="../assets/site.js"></script>
</head>
<body class="chapter-body">
<a class="skip" href="#content">跳到正文</a>
{masthead(section)}
<div class="page-shell">
  {rail(section, doc)}
  <main id="content" class="chapter-main">
    <nav class="breadcrumb"><a href="../index.html">总目录</a><span aria-hidden="true">/</span><a href="index.html">{esc(BY_SLUG[section][1])}</a></nav>
    <header class="chapter-head">
      <div class="chapter-num" aria-hidden="true">{num}</div>
      <div class="chapter-heading">
        <p class="chapter-kicker">{esc(BY_SLUG[section][1])} · {num} / 06</p>
        <h1>{esc(title)}</h1>
        <p class="standfirst">{esc(desc)}</p>
      </div>
    </header>
    <article class="prose">{body}</article>
    {doc_pager(section, doc)}
    <footer class="colophon">
      <p>Dotfiles 配置手册 · <code>iamcheyan/dotfiles</code></p>
      <p><a href="https://github.com/{SITE["repo"]}">查看源文件</a> · <a href="../index.html">回到总目录</a></p>
    </footer>
  </main>
</div>
</body></html>'''
    meta = {"title": title, "description": desc, "section": section, "doc": doc, "search_text": searchable}
    return meta, html


def section_index(section: str) -> tuple[dict, str]:
    slug, label, scope, docs = BY_SLUG[section]
    num = next(n for s, _l, n in NAV if s == section)
    rows = "\n".join(
        f'''<a class="toc-row" href="{d[0]}.html">
        <span class="toc-num">{i + 1:02d}</span>
        <span class="toc-title">{esc(d[1])}</span>
        <span class="toc-leader" aria-hidden="true"></span>
        <span class="toc-note">{esc(d[2])}</span>
        <span class="toc-arrow" aria-hidden="true">→</span>
      </a>'''
        for i, d in enumerate(docs)
    )
    html = f'''<!doctype html>
<html lang="zh-CN" data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="{esc(scope)}">
  <meta name="theme-color" content="#f4efe4">
  <title>{esc(label)} · Dotfiles 配置手册</title>
  <link rel="canonical" href="{SITE["url"]}/{section}/">
  <link rel="stylesheet" href="../assets/site.css">
  <script defer src="../assets/site.js"></script>
</head>
<body class="chapter-body">
<a class="skip" href="#content">跳到正文</a>
{masthead(section)}
<div class="page-shell">
  {rail(section, "index")}
  <main id="content" class="chapter-main">
    <nav class="breadcrumb"><a href="../index.html">总目录</a><span aria-hidden="true">/</span><span>{esc(label)}</span></nav>
    <header class="chapter-head">
      <div class="chapter-num" aria-hidden="true">{num}</div>
      <div class="chapter-heading">
        <p class="chapter-kicker">Field guide · {num} / 06</p>
        <h1>{esc(label)}</h1>
        <p class="standfirst">{esc(scope)}。本章共 {len(docs)} 篇文档。</p>
      </div>
    </header>
    <article class="prose"><div class="toc">{rows}</div></article>
    <footer class="colophon">
      <p>Dotfiles 配置手册 · <code>iamcheyan/dotfiles</code></p>
      <p><a href="https://github.com/{SITE["repo"]}">查看源文件</a> · <a href="../index.html">回到总目录</a></p>
    </footer>
  </main>
</div>
</body></html>'''
    return {"title": label, "description": scope, "section": section, "doc": "index", "search_text": scope}, html


def home(all_meta: list[dict]) -> str:
    sections_html = []
    for slug, label, num in NAV:
        _s, _l, scope, docs = BY_SLUG[slug]
        items = "\n".join(
            f'<a class="doc-link" href="{slug}/{d[0]}.html">'
            f'<span class="doc-num">{i + 1:02d}</span>'
            f'<span class="doc-title">{esc(d[1])}</span>'
            f'<span class="doc-note">{esc(d[2])}</span></a>'
            for i, d in enumerate(docs)
        )
        sections_html.append(
            f'''<section class="section-block">
        <header class="section-block-head">
          <span class="section-num">{num}</span>
          <div class="section-meta">
            <h2><a href="{slug}/index.html">{esc(label)}</a></h2>
            <p>{esc(scope)}</p>
          </div>
          <span class="section-count">{len(docs)} 篇</span>
        </header>
        <div class="doc-list">{items}</div>
      </section>'''
        )
    index = json.dumps(
        [
            {
                "title": m["title"],
                "description": m["description"],
                "url": f'{m["section"]}/{m["doc"]}.html',
                "text": m["search_text"][:9000],
            }
            for m in all_meta
        ],
        ensure_ascii=False,
        separators=(",", ":"),
    )
    total = sum(len(s[3]) for s in SECTIONS)
    return f'''<!doctype html>
<html lang="zh-CN" data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="{esc(SITE["tagline"])}。{total} 篇文档，逐项说明 Zsh、命令行工具、配置文件和自研脚本。">
  <meta name="theme-color" content="#f4efe4">
  <title>Dotfiles · 配置手册</title>
  <link rel="canonical" href="{SITE["url"]}/">
  <link rel="stylesheet" href="assets/site.css">
  <script defer src="assets/site.js"></script>
</head>
<body class="home-body">
<a class="skip" href="#content">跳到正文</a>
{masthead("home", "")}
<main id="content" class="home-main">

  <section class="masthead-block">
    <p class="masthead-line"><span>Public configuration</span><span>Edition 2026 · {total} documents</span></p>
    <h1>把终端配置<br><em>写成一本可以查的手册。</em></h1>
    <div class="masthead-body">
      <p class="lead">{esc(SITE["tagline"])}。六个章节、{total} 篇文档：每个工具单独一篇，正文对应仓库里真实存在的脚本与配置，不写推测的用法。</p>
      <dl class="colophon-list">
        <div><dt>平台</dt><dd>Linux · macOS · WSL</dd></div>
        <div><dt>入口</dt><dd><code>zshrc</code> + <code>dotlink</code></dd></div>
        <div><dt>编辑器</dt><dd>Neovim 0.12+</dd></div>
        <div><dt>文档</dt><dd>{total} 篇 / 6 章</dd></div>
      </dl>
    </div>
    <p class="masthead-cta"><a class="cta" href="start/index.html">从第 01 章开始</a><a class="cta-quiet" href="https://github.com/{SITE["repo"]}">直接看仓库</a></p>
  </section>

  <section class="contents" aria-labelledby="contents-title">
    <div class="contents-head">
      <h2 id="contents-title">总目录</h2>
      <label class="search"><span class="search-icon" aria-hidden="true">⌕</span><input id="site-search" type="search" placeholder="搜索 {total} 篇文档" autocomplete="off" aria-label="搜索文档"><kbd>/</kbd></label>
    </div>
    <p class="search-hint" id="search-hint">可以搜 <code>dotlink</code>、<code>fzf</code>、<code>nvim-update</code>、<code>Vifm</code>、<code>--minimal</code></p>
    <div class="search-results" id="search-results" hidden></div>
    <div class="section-grid" id="section-grid">
      {"".join(sections_html)}
    </div>
    <p class="no-results" id="no-results" hidden>没有匹配的文档。试试工具名或命令名。</p>
  </section>

  <section class="boundary-note">
    <p class="boundary-kicker">Scope</p>
    <p class="boundary-text">本站只讲可公开复用的 Zsh、CLI 与应用配置。系统包、机器专属编排和凭据属于其它仓库，不在这里索引。</p>
    <a class="boundary-link" href="maintenance/boundaries.html">仓库边界与更新方式 →</a>
  </section>

  <footer class="colophon colophon-home">
    <p>Dotfiles 配置手册 · <code>iamcheyan/dotfiles</code></p>
    <p><a href="https://github.com/{SITE["repo"]}">GitHub</a> · <a href="https://nvim.iamcheyan.com">Neovim 配置</a> · <a href="sitemap.xml">站点地图</a></p>
  </footer>
</main>
<script type="application/json" id="search-index">{index}</script>
</body></html>'''


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    assets = OUT / "assets"
    assets.mkdir(exist_ok=True)
    shutil.copy2(SITE_ROOT / "site.css", assets / "site.css")
    shutil.copy2(SITE_ROOT / "site.js", assets / "site.js")

    all_meta: list[dict] = []
    written = 0
    for slug, label, num in NAV:
        sdir = OUT / slug
        sdir.mkdir(exist_ok=True)
        for doc, _t, _s in BY_SLUG[slug][3]:
            meta, html = page(slug, doc)
            all_meta.append(meta)
            (sdir / f"{doc}.html").write_text(
                "\n".join(line.rstrip() for line in html.splitlines()) + "\n", encoding="utf-8"
            )
            written += 1

    (OUT / "index.html").write_text(
        "\n".join(line.rstrip() for line in home(all_meta).splitlines()) + "\n", encoding="utf-8"
    )
    (OUT / "CNAME").write_text("dotfiles.iamcheyan.com\n", encoding="utf-8")
    (OUT / "robots.txt").write_text(
        "User-agent: *\nAllow: /\nSitemap: https://dotfiles.iamcheyan.com/sitemap.xml\n",
        encoding="utf-8",
    )
    urls = ["", *[f'{m["section"]}/{m["doc"]}.html' for m in all_meta], *[f"{s[0]}/" for s in SECTIONS]]
    sitemap = "".join(f'<url><loc>{SITE["url"]}/{u}</loc></url>' for u in urls)
    (OUT / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + sitemap + "</urlset>\n",
        encoding="utf-8",
    )
    print(f"Built {written} documents + index into {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
