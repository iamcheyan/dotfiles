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


# ---------------------------------------------------------------------------
# Layout — modelled on dotfiles.github.io: a fixed 270px header column on the
# left (site title, tagline, stacked navigation) and a 500px content column on
# the right. Lato, black on white, blue links, light grey code blocks.
# ---------------------------------------------------------------------------

TAGLINE = "Your unofficial guide to this dotfiles setup."


def side_nav(section: str, doc: str, prefix: str) -> str:
    """Stacked navigation: the six sections, with the active one expanded."""
    parts = []
    for slug, label, num in NAV:
        active = slug == section
        parts.append(
            f'<a class="nav-section{" active" if active else ""}" href="{prefix}{slug}/index.html">'
            f"<span class=\"nav-num\">{num}</span>{esc(label)}</a>"
        )
        if active:
            docs = BY_SLUG[slug][3]
            links = "\n".join(
                f'<a class="nav-doc{" active" if d[0] == doc else ""}" href="{prefix}{slug}/{d[0]}.html">{esc(d[1])}</a>'
                for d in docs
            )
            parts.append(f'<div class="nav-docs">{links}</div>')
    return "\n".join(parts)


def header(section: str, doc: str, prefix: str) -> str:
    return f'''<header>
  <p class="site-title"><a href="{prefix}index.html">dotfiles</a></p>
  <p class="site-tagline"><em>{TAGLINE}</em></p>
  <nav>
    {side_nav(section, doc, prefix)}
  </nav>
  <p class="site-meta"><a href="https://github.com/{SITE["repo"]}">GitHub repository</a><br>
  <a href="https://nvim.iamcheyan.com">Neovim configuration</a></p>
</header>'''


def pager(section: str, doc: str, prefix: str) -> str:
    docs = BY_SLUG[section][3]
    i = next(n for n, d in enumerate(docs) if d[0] == doc)
    prev_d = docs[i - 1] if i > 0 else None
    next_d = docs[i + 1] if i + 1 < len(docs) else None
    left = (
        f'<a href="{prefix}{section}/{prev_d[0]}.html">&larr; {esc(prev_d[1])}</a>'
        if prev_d
        else ""
    )
    right = (
        f'<a href="{prefix}{section}/{next_d[0]}.html">{esc(next_d[1])} &rarr;</a>'
        if next_d
        else f'<a href="{prefix}{section}/index.html">{esc(BY_SLUG[section][1])} index &rarr;</a>'
    )
    return f'<p class="pager">{left}<span class="pager-sep"> · </span>{right}</p>'


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
    body = render_md(text)
    html = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1, user-scalable=yes" name="viewport">
<title>{esc(title)} - dotfiles.iamcheyan.com</title>
<meta name="description" content="{esc(desc)}">
<link href="../stylesheets/styles.css" rel="stylesheet">
</head>
<body>
<div class="wrapper">
{header(section, doc, "../")}
<section>
<h1 id="{esc(doc)}">{esc(title)}</h1>
{body}
{pager(section, doc, "../")}
</section>
</div>
</body>
</html>'''
    meta = {"title": title, "description": desc, "section": section, "doc": doc, "search_text": searchable}
    return meta, html


def section_index(section: str) -> tuple[dict, str]:
    slug, label, scope, docs = BY_SLUG[section]
    items = "\n".join(
        f'<li><a href="{d[0]}.html">{esc(d[1])}</a> — {esc(d[2])}</li>'
        for d in docs
    )
    html = f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1, user-scalable=yes" name="viewport">
<title>{esc(label)} - dotfiles.iamcheyan.com</title>
<meta name="description" content="{esc(scope)}">
<link href="../stylesheets/styles.css" rel="stylesheet">
</head>
<body>
<div class="wrapper">
{header(section, "index", "../")}
<section>
<h1 id="{esc(slug)}">{esc(label)}</h1>
<p>{esc(scope)}</p>
<ul>
{items}
</ul>
</section>
</div>
</body>
</html>'''
    return {"title": label, "description": scope, "section": section, "doc": "index", "search_text": scope}, html


def home(all_meta: list[dict]) -> str:
    sections_html = []
    for slug, label, num in NAV:
        _s, _l, scope, docs = BY_SLUG[slug]
        items = "\n".join(
            f'<li><a href="{slug}/{d[0]}.html">{esc(d[1])}</a> — {esc(d[2])}</li>'
            for d in docs
        )
        sections_html.append(
            f'''<h2><a href="{slug}/index.html">{esc(label)}</a></h2>
<p>{esc(scope)} — {len(docs)} documents.</p>
<ul>
{items}
</ul>'''
        )
    total = sum(len(s[3]) for s in SECTIONS)
    return f'''<!DOCTYPE html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1, user-scalable=yes" name="viewport">
<title>dotfiles.iamcheyan.com</title>
<meta name="description" content="{esc(SITE["tagline"])}">
<link href="stylesheets/styles.css" rel="stylesheet">
</head>
<body>
<div class="wrapper">
{header("home", "", "")}
<section>
<h1 id="dotfiles">dotfiles.iamcheyan.com</h1>
<p>{esc(SITE["tagline"])}。{total} documents in six sections. Each tool has its own
page: what it does, how to invoke it, which flags matter, and what this
repository actually configures.</p>
<p><a href="start/index.html">Start with installation &rarr;</a></p>
{"".join(sections_html)}
</section>
</div>
</body>
</html>'''


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    sheets = OUT / "stylesheets"
    sheets.mkdir(exist_ok=True)
    shutil.copy2(SITE_ROOT / "styles.css", sheets / "styles.css")

    written = 0
    for slug, label, num in NAV:
        sdir = OUT / slug
        sdir.mkdir(exist_ok=True)
        for doc, _t, _s in BY_SLUG[slug][3]:
            _meta, html = page(slug, doc)
            (sdir / f"{doc}.html").write_text(
                "\n".join(line.rstrip() for line in html.splitlines()) + "\n", encoding="utf-8"
            )
            written += 1

    (OUT / "index.html").write_text(
        "\n".join(line.rstrip() for line in home([]).splitlines()) + "\n", encoding="utf-8"
    )
    (OUT / "CNAME").write_text("dotfiles.iamcheyan.com\n", encoding="utf-8")
    (OUT / "robots.txt").write_text(
        "User-agent: *\nAllow: /\nSitemap: https://dotfiles.iamcheyan.com/sitemap.xml\n",
        encoding="utf-8",
    )
    urls = ["", *[f"{s[0]}/" for s in SECTIONS]]
    urls += [f"{s[0]}/{d[0]}.html" for s in SECTIONS for d in s[3]]
    sitemap = "".join(f'<url><loc>{SITE["url"]}/{u}</loc></url>' for u in urls)
    (OUT / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + sitemap + "</urlset>\n",
        encoding="utf-8",
    )
    print(f"Built {written} documents + index into {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
