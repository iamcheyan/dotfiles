#!/usr/bin/env python3
"""Build the static public dotfiles guide into build/site.

Design intent: this is a printed field manual, not a terminal dashboard. Warm
paper, serif text, vermilion rules, dot-leader contents and marginal chapter
numbers. The Neovim site is deliberately the opposite: dark, monospace, green.
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
NAV = [
    ("start", "开始使用", "01", "安装与检查"),
    ("shell", "Zsh 与终端", "02", "加载顺序、交互插件"),
    ("tools", "工具目录", "03", "命令、补全、文件管理器"),
    ("scripts", "自定义脚本", "04", "dotlink、安装器、fzf 函数"),
    ("configs", "应用配置", "05", "Starship、tmux、Vifm、Ranger"),
    ("maintenance", "维护与边界", "06", "更新、检查、私人覆盖"),
]
MD = markdown.Markdown(extensions=["tables", "fenced_code", "toc", "attr_list", "sane_lists"])


def esc(s: str) -> str:
    return escape(s, quote=True)


def render_md(text: str) -> str:
    MD.reset()
    return MD.convert(text)


def nav_links(current: str, extra: str = "") -> str:
    rows = []
    for slug, label, num, _note in NAV:
        cls = "chapter-link current" if slug == current else "chapter-link"
        rows.append(
            f'<a class="{cls}" href="{slug}.html"><span class="chapter-link-num">{num}</span>'
            f'<span class="chapter-link-label">{esc(label)}</span></a>'
        )
    return "\n".join(rows)


def masthead(current: str) -> str:
    top = "\n".join(
        f'<a class="top-link{" current" if slug == current else ""}" href="{slug}.html">'
        f'<span>{num}</span>{esc(label)}</a>'
        for slug, label, num, _note in NAV
    )
    return f'''<header class="masthead">
  <div class="masthead-inner">
    <a class="wordmark" href="index.html">
      <span class="wordmark-rule"></span>
      <span class="wordmark-text">Dotfiles</span>
      <span class="wordmark-sub">配置手册</span>
    </a>
    <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="site-nav">目录</button>
    <nav class="top-nav" id="site-nav">{top}</nav>
    <div class="masthead-actions">
      <a class="ghost-link" href="https://github.com/{SITE['repo']}">GitHub</a>
      <button class="theme-toggle" type="button" aria-label="切换明暗主题"><span class="theme-glyph"></span></button>
    </div>
  </div>
</header>'''


def shell(title: str, slug: str, body: str, page_meta: dict[str, str]) -> str:
    index = next(i for i, item in enumerate(NAV) if item[0] == slug)
    num = NAV[index][2]
    prev_slug, prev_label = NAV[index - 1][0], NAV[index - 1][1]
    next_slug, next_label = NAV[(index + 1) % len(NAV)][0], NAV[(index + 1) % len(NAV)][1]
    return f'''<!doctype html>
<html lang="zh-CN" data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="{esc(page_meta['description'])}">
  <meta name="theme-color" content="#f4efe4">
  <title>{esc(title)} · Dotfiles 配置手册</title>
  <link rel="canonical" href="{SITE['url']}/{slug}.html">
  <link rel="stylesheet" href="assets/site.css">
  <script defer src="assets/site.js"></script>
</head>
<body class="chapter-body">
<a class="skip" href="#content">跳到正文</a>
{masthead(slug)}
<div class="page-shell">
  <aside class="side-rail">
    <p class="rail-title">目录 · Contents</p>
    <nav class="rail-nav">{nav_links(slug)}</nav>
    <div class="rail-note">
      <p class="rail-note-k">来源</p>
      <p><code>iamcheyan/dotfiles</code></p>
      <p class="rail-note-k">正文依据</p>
      <p>仓库中已跟踪的脚本与配置文件</p>
    </div>
  </aside>
  <main id="content" class="chapter-main">
    <nav class="breadcrumb"><a href="index.html">总目录</a><span aria-hidden="true">/</span><span>第 {num} 章</span></nav>
    <header class="chapter-head">
      <div class="chapter-num" aria-hidden="true">{num}</div>
      <div class="chapter-heading">
        <p class="chapter-kicker">Field guide · {num} / 06</p>
        <h1>{esc(title)}</h1>
        <p class="standfirst">{esc(page_meta['description'])}</p>
      </div>
    </header>
    <article class="prose">{body}</article>
    <nav class="chapter-pager" aria-label="章节翻页">
      <a href="{prev_slug}.html"><span class="pager-k">上一章 · {NAV[index - 1][2]}</span><span class="pager-t">{esc(prev_label)}</span></a>
      <a class="pager-next" href="{next_slug}.html"><span class="pager-k">下一章 · {NAV[(index + 1) % len(NAV)][2]}</span><span class="pager-t">{esc(next_label)}</span></a>
    </nav>
    <footer class="colophon">
      <p>Dotfiles 配置手册 · 对应公开仓库 <code>iamcheyan/dotfiles</code></p>
      <p><a href="https://github.com/{SITE['repo']}">查看源文件</a> · <a href="index.html">回到总目录</a></p>
    </footer>
  </main>
</div>
</body></html>'''


def build_page(slug: str, label: str, number: str) -> tuple[dict, str]:
    text = (SOURCE / f"{slug}.md").read_text(encoding="utf-8")
    match = re.search(r"^> 摘要：(.+)$", text, re.M)
    description = match.group(1).strip() if match else f"{label}：配置说明与文件入口。"
    searchable = re.sub(r"\s+", " ", re.sub(r"[`#>*|]", " ", text))
    text = re.sub(r"^> 摘要：.+\n\n", "", text, count=1, flags=re.M)
    text = re.sub(r"^# .+\n+", "", text, count=1)
    meta = {
        "title": label,
        "description": description,
        "number": number,
        "slug": slug,
        "search_text": searchable,
    }
    return meta, shell(label, slug, render_md(text), meta)


def home(cards: list[dict], search_data: list[dict]) -> str:
    toc = "\n".join(
        f'''<a class="toc-row" href="{c['slug']}.html" data-search="{esc(c['title'] + ' ' + c['description'] + ' ' + c['search_text'])}">
        <span class="toc-num">{c['number']}</span>
        <span class="toc-title">{esc(c['title'])}</span>
        <span class="toc-leader" aria-hidden="true"></span>
        <span class="toc-note">{esc(c['description'].split('，')[0])}</span>
        <span class="toc-arrow" aria-hidden="true">→</span>
      </a>'''
        for c in cards
    )
    paths = [
        ("01", "先读启动链", "从 <code>zshrc</code> 看 Zinit、补全、fzf 函数的加载次序。", "shell.html"),
        ("02", "再查命令", "工具来源、日常用法和文件管理器键位。", "tools.html"),
        ("03", "最后改配置", "dotlink 映射、备份行为与维护检查。", "scripts.html"),
    ]
    paths_html = "\n".join(
        f'''<li class="path-item"><span class="path-num">{num}</span>
        <div><p class="path-title">{title}</p><p class="path-desc">{desc}</p>
        <a class="path-link" href="{href}">阅读本章 →</a></div></li>'''
        for num, title, desc, href in paths
    )
    index = json.dumps(search_data, ensure_ascii=False, separators=(",", ":"))
    return f'''<!doctype html>
<html lang="zh-CN" data-theme="light">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="{esc(SITE['tagline'])}。逐章说明 Zsh、命令行工具、配置文件和自研脚本。">
  <meta name="theme-color" content="#f4efe4">
  <title>Dotfiles · 配置手册</title>
  <link rel="canonical" href="{SITE['url']}/">
  <link rel="stylesheet" href="assets/site.css">
  <script defer src="assets/site.js"></script>
</head>
<body class="home-body">
<a class="skip" href="#content">跳到正文</a>
{masthead("home")}
<main id="content" class="home-main">

  <section class="masthead-block">
    <p class="masthead-line"><span>Public configuration</span><span>Edition 2026</span></p>
    <h1>把终端配置<br><em>写成一本可以查的手册。</em></h1>
    <div class="masthead-body">
      <p class="lead">{esc(SITE['tagline'])}。从 shell 启动顺序到每一个自定义脚本，正文对应仓库里真实存在的文件，不写推测的用法。</p>
      <dl class="colophon-list">
        <div><dt>平台</dt><dd>Linux · macOS · WSL</dd></div>
        <div><dt>入口</dt><dd><code>zshrc</code> + <code>dotlink</code></dd></div>
        <div><dt>编辑器</dt><dd>Neovim 0.12+</dd></div>
        <div><dt>版本</dt><dd>main 分支</dd></div>
      </dl>
    </div>
    <p class="masthead-cta"><a class="cta" href="start.html">从第 01 章开始</a><a class="cta-quiet" href="https://github.com/{SITE['repo']}">直接看仓库</a></p>
  </section>

  <section class="contents" aria-labelledby="contents-title">
    <div class="contents-head">
      <h2 id="contents-title">目录</h2>
      <label class="search"><span class="search-icon" aria-hidden="true">⌕</span><input id="site-search" type="search" placeholder="搜索工具、脚本或命令" autocomplete="off" aria-label="搜索章节"><kbd>/</kbd></label>
    </div>
    <p class="search-hint" id="search-hint">可以搜 <code>dotlink</code>、<code>fzf</code>、<code>nvim-update</code>、<code>Vifm</code></p>
    <div class="toc" id="section-list">{toc}</div>
    <p class="no-results" id="no-results" hidden>没有匹配的章节。试试脚本名或命令名。</p>
  </section>

  <section class="reading-paths" aria-labelledby="paths-title">
    <div class="paths-head">
      <h2 id="paths-title">阅读路径</h2>
      <p>不必按顺序读完。三条线分别对应「看懂加载」「查命令」「改配置」。</p>
    </div>
    <ol class="path-list">{paths_html}</ol>
  </section>

  <section class="boundary-note">
    <p class="boundary-kicker">Scope</p>
    <p class="boundary-text">本站只讲可公开复用的 Zsh、CLI 与应用配置。系统包、机器专属编排和凭据属于其它仓库，不在这里索引。</p>
    <a class="boundary-link" href="maintenance.html">仓库边界与更新方式 →</a>
  </section>

  <footer class="colophon colophon-home">
    <p>Dotfiles 配置手册 · <code>iamcheyan/dotfiles</code></p>
    <p><a href="https://github.com/{SITE['repo']}">GitHub</a> · <a href="https://nvim.iamcheyan.com">Neovim 配置</a> · <a href="sitemap.xml">站点地图</a></p>
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

    cards: list[dict] = []
    pages: dict[str, str] = {}
    for slug, label, number, _note in NAV:
        meta, html = build_page(slug, label, number)
        cards.append(meta)
        pages[f"{slug}.html"] = html

    search_data = [
        {
            "title": c["title"],
            "description": c["description"],
            "url": c["slug"] + ".html",
            "text": c["search_text"][:8000],
        }
        for c in cards
    ]
    pages["index.html"] = home(cards, search_data)

    for name, content in pages.items():
        (OUT / name).write_text(
            "\n".join(line.rstrip() for line in content.splitlines()) + "\n",
            encoding="utf-8",
        )
    (OUT / "CNAME").write_text("dotfiles.iamcheyan.com\n", encoding="utf-8")
    (OUT / "robots.txt").write_text(
        "User-agent: *\nAllow: /\nSitemap: https://dotfiles.iamcheyan.com/sitemap.xml\n",
        encoding="utf-8",
    )
    sitemap = [f'<url><loc>{SITE["url"]}/{name}</loc></url>' for name in ["", *pages.keys()]]
    (OUT / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'
        + "".join(sitemap)
        + "</urlset>\n",
        encoding="utf-8",
    )
    print(f"Built {len(pages)} pages into {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
