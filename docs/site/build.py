#!/usr/bin/env python3
"""Build the static public dotfiles guide into build/site."""
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
    ("start", "开始使用", "01"),
    ("shell", "Zsh 与终端", "02"),
    ("tools", "工具目录", "03"),
    ("scripts", "自定义脚本", "04"),
    ("configs", "应用配置", "05"),
    ("maintenance", "维护与边界", "06"),
]
MD = markdown.Markdown(extensions=["tables", "fenced_code", "toc", "attr_list", "sane_lists"])


def esc(s: str) -> str:
    return escape(s, quote=True)


def render_md(text: str) -> str:
    MD.reset()
    return MD.convert(text)


def shell(title: str, slug: str, body: str, page_meta: dict[str, str]) -> str:
    prev_i = next(i for i, item in enumerate(NAV) if item[0] == slug)
    nav = "\n".join(
        f'<a class="nav-link{" current" if s == slug else ""}" href="{s}.html"><span>{n}</span>{esc(label)}</a>'
        for s, label, n in NAV
    )
    return f'''<!doctype html>
<html lang="zh-CN" data-theme="dark">
<head>
  <meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
  <meta name="description" content="{esc(page_meta['description'])}">
  <meta name="theme-color" content="#0b0f14">
  <title>{esc(title)} · Dotfiles</title>
  <link rel="canonical" href="{SITE['url']}/{slug}.html">
  <link rel="stylesheet" href="assets/site.css">
  <script defer src="assets/site.js"></script>
</head>
<body class="article-body">
<a class="skip" href="#content">跳到正文</a>
<header class="topbar"><div class="topbar-inner">
  <a class="brand" href="index.html"><span class="brand-mark">d/</span><span>dotfiles<span class="brand-suffix">.iamcheyan.com</span></span></a>
  <button class="menu-toggle" type="button" aria-expanded="false" aria-controls="site-nav">目录</button>
  <nav class="top-nav" id="site-nav">{nav}</nav>
  <div class="top-actions"><a class="repo-link" href="https://github.com/{SITE['repo']}">GitHub ↗</a><button class="theme-toggle" type="button" aria-label="切换主题">◐</button></div>
</div></header>
<div class="page-shell">
  <aside class="side-rail"><div class="rail-label">配置手册</div><div class="rail-nav">{nav}</div><div class="rail-note"><span class="live-dot"></span>内容对应公开仓库<br><code>iamcheyan/dotfiles</code></div></aside>
  <main id="content" class="article-main">
    <div class="crumb"><a href="index.html">总览</a><span>/</span><span>{esc(title)}</span></div>
    <header class="article-head"><div class="eyebrow">FIELD GUIDE <span>{NAV[prev_i][2]}</span></div><h1>{esc(title)}</h1><p>{esc(page_meta['description'])}</p></header>
    <article class="prose">{body}</article>
    <nav class="article-pager"><a href="index.html"><small>站点首页</small><strong>配置总览 ↗</strong></a><a href="{NAV[(prev_i + 1) % len(NAV)][0]}.html"><small>继续阅读</small><strong>{esc(NAV[(prev_i + 1) % len(NAV)][1])} →</strong></a></nav>
    <footer class="site-footer"><span>Dotfiles · 一份可独立部署的公开配置</span><a href="https://github.com/{SITE['repo']}">查看源文件 ↗</a></footer>
  </main>
</div>
</body></html>'''


def build_page(slug: str, label: str, number: str) -> tuple[dict, str]:
    source = SOURCE / f"{slug}.md"
    text = source.read_text(encoding="utf-8")
    match = re.search(r"^> 摘要：(.+)$", text, re.M)
    description = match.group(1).strip() if match else f"{label}：配置说明、使用方法和实际文件入口。"
    searchable = re.sub(r"[`#>*|]", " ", text)
    searchable = re.sub(r"\s+", " ", searchable)
    text = re.sub(r"^> 摘要：.+\n\n", "", text, count=1, flags=re.M)
    text = re.sub(r"^# .+\n+", "", text, count=1)
    html = render_md(text)
    meta = {"title": label, "description": description, "number": number, "slug": slug, "search_text": searchable}
    return meta, shell(label, slug, html, meta)


def home(cards: list[dict], search_data: list[dict]) -> str:
    rows = "\n".join(
        f'''<a class="section-row" href="{c['slug']}.html" data-search="{esc(c['title'] + ' ' + c['description'] + ' ' + c['search_text'])}">
          <span class="row-number">{c['number']}</span><span class="row-copy"><strong>{esc(c['title'])}</strong><small>{esc(c['description'])}</small></span><span class="row-count">指南 <b>→</b></span></a>'''
        for c in cards
    )
    featured = [
        ("zshrc", "shell.html", "Shell 启动主线", "从 zshrc 看加载顺序、插件阶段与按需集成。"),
        ("dotlink", "scripts.html", "自研软链工具", "了解链接映射、备份行为和 dotlink 命令。"),
        ("fzf functions", "tools.html", "交互搜索函数", "f 与 ffd 如何把文件搜索接到编辑器和文件管理器。"),
    ]
    featured_html = "\n".join(
        f'<a class="feature-row" href="{href}"><code>{esc(code)}</code><span><b>{esc(title)}</b><small>{esc(desc)}</small></span><i>↗</i></a>'
        for code, href, title, desc in featured
    )
    index = json.dumps(search_data, ensure_ascii=False, separators=(",", ":"))
    return f'''<!doctype html>
<html lang="zh-CN" data-theme="dark"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><meta name="description" content="{esc(SITE['tagline'])}。逐项介绍 Zsh、终端工具、配置文件和自定义脚本。"><meta name="theme-color" content="#0b0f14"><title>Dotfiles · iamcheyan</title><link rel="canonical" href="{SITE['url']}/"><link rel="stylesheet" href="assets/site.css"><script defer src="assets/site.js"></script></head>
<body class="home-body"><a class="skip" href="#content">跳到正文</a>
<header class="topbar"><div class="topbar-inner"><a class="brand" href="index.html"><span class="brand-mark">d/</span><span>dotfiles<span class="brand-suffix">.iamcheyan.com</span></span></a><button class="menu-toggle" type="button" aria-expanded="false" aria-controls="site-nav">目录</button><nav class="top-nav" id="site-nav">{''.join(f'<a class="nav-link" href="{s}.html"><span>{n}</span>{esc(label)}</a>' for s,label,n in NAV)}</nav><div class="top-actions"><a class="repo-link" href="https://github.com/{SITE['repo']}">GitHub ↗</a><button class="theme-toggle" type="button" aria-label="切换主题">◐</button></div></div></header>
<main id="content" class="home-wrap">
<section class="hero"><div class="hero-copy"><div class="eyebrow"><span class="live-dot"></span> PUBLIC CONFIGURATION / 2026</div><h1>终端是工作台。<br><em>配置应该说得清楚。</em></h1><p>{esc(SITE['tagline'])}。从 Zsh 启动过程到每个自定义脚本，都能在这里找到对应说明和源文件。</p><div class="hero-actions"><a class="primary-action" href="start.html">从安装开始 <span>→</span></a><a class="text-action" href="https://github.com/{SITE['repo']}">浏览代码 ↗</a></div></div>
<div class="hero-terminal"><div class="terminal-top"><span></span><span></span><span></span><small>~/dotfiles · zsh</small></div><pre><b>~</b> <i>❯</i> bash dotlink/dotlink list
<span class="term-dim">配置入口</span>   <strong>zshrc</strong>
<span class="term-dim">软链管理</span>   <strong>dotlink/dotlinkrc</strong>
<span class="term-dim">交互搜索</span>   <strong>f · ffd</strong>
<span class="term-dim">编辑器</span>     <strong>Neovim 0.12+</strong>

<span class="term-green">源文件见 iamcheyan/dotfiles</span></pre><div class="terminal-foot"><span>PLATFORM</span><b>Linux · macOS · WSL</b><span>EDITOR</span><b>Neovim</b></div></div>
<div class="hero-index"><span>配置地图</span><b>01—06</b><small>Zsh → 工具 → 脚本 → 应用</small></div></section>
<section class="overview"><div class="section-heading"><div><div class="eyebrow">INDEX / 01—06</div><h2>沿着配置入口读</h2></div><label class="search"><span>⌕</span><input id="site-search" type="search" placeholder="搜索工具、命令或脚本" autocomplete="off"><kbd>/</kbd></label></div><div class="search-hint" id="search-hint">试试：dotlink、fzf、nvim-update、Vifm</div><div class="section-list" id="section-list">{rows}</div><div class="no-results" id="no-results" hidden>没有匹配内容。试试脚本名、命令名或应用名。</div></section>
<section class="deep-dive"><div class="deep-heading"><div class="eyebrow">MAINTAINER NOTES</div><h2>从三个入口看实现</h2><p>每篇说明都指向实际维护的文件；Neovim 使用独立仓库，本手册会链接到它的完整站点。</p></div><div class="feature-list">{featured_html}</div></section>
<section class="boundary"><div><div class="eyebrow">PUBLIC / PRIVATE</div><h2>公开配置有明确边界</h2></div><p>这里介绍可公开复用的 Zsh、CLI 和应用配置。机器专属编排与凭据由私有配置管理，不会被站点索引。</p><a href="maintenance.html">查看仓库边界与更新方法 ↗</a></section>
<footer class="site-footer"><span>iamcheyan / dotfiles</span><a href="https://github.com/{SITE['repo']}">GitHub ↗</a><span>Built from tracked Markdown</span></footer>
</main><script type="application/json" id="search-index">{index}</script></body></html>'''


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    assets = OUT / "assets"
    assets.mkdir(exist_ok=True)
    shutil.copy2(SITE_ROOT / "site.css", assets / "site.css")
    shutil.copy2(SITE_ROOT / "site.js", assets / "site.js")
    cards: list[dict] = []
    pages: dict[str, str] = {}
    for slug, label, number in NAV:
        meta, html = build_page(slug, label, number)
        cards.append(meta)
        pages[f"{slug}.html"] = html
    search_data = []
    for c in cards:
        md = (SOURCE / f"{c['slug']}.md").read_text(encoding="utf-8")
        search_data.append({"title": c["title"], "description": c["description"], "url": c["slug"] + ".html", "text": re.sub(r"[#*`>|]", " ", md)[:8000]})
    pages["index.html"] = home(cards, search_data)
    for name, content in pages.items():
        (OUT / name).write_text("\n".join(line.rstrip() for line in content.splitlines()) + "\n", encoding="utf-8")
    (OUT / "CNAME").write_text("dotfiles.iamcheyan.com\n", encoding="utf-8")
    (OUT / "robots.txt").write_text("User-agent: *\nAllow: /\nSitemap: https://dotfiles.iamcheyan.com/sitemap.xml\n", encoding="utf-8")
    sitemap = [f'<url><loc>{SITE["url"]}/{name}</loc></url>' for name in ["", *pages.keys()]]
    (OUT / "sitemap.xml").write_text('<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + "".join(sitemap) + "</urlset>\n", encoding="utf-8")
    print(f"Built {len(pages)} pages into {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
