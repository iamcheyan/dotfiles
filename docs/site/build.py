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
import subprocess
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
            ("intro", "本章导读", "这套配置由什么组成，按什么顺序读。"),
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
            ("intro", "本章导读", "shell 环境的组成与阅读顺序。"),
            ("loading", "启动与加载顺序", "zshrc 到 zinit、补全、插件、fzf 的完整链路。"),
            ("history", "历史与命令行编辑", "vi-mode、Atuin、历史选项与绑定检查。"),
            ("completion", "补全系统", "compinit、zsh-completions、fzf-tab 三个阶段。"),
            ("plugins", "交互插件", "autosuggestions、autopair、forgit、语法高亮。"),
            ("fzf-functions", "f 与 ffd 函数", "两个文件搜索函数的行为、按键与回退逻辑。"),
            ("fnm-node", "fnm 与 Node 工具链", "惰性加载包装器与 npm 全局命令。"),
            ("terminal", "终端与提示符", "Starship、Ghostty、tmux 的分工。"),
            ("troubleshooting", "排错清单", "启动报错、插件缺失、预览不显示怎么查。"),
        ],
    ),
    (
        "tools",
        "工具目录",
        "已接入工具的用途、用法、参数与配置",
        [
            ("intro", "工具总表", "已接入工具的来源、入口与章节。"),
            ("eza", "eza", "带图标与 Git 状态的 ls 替代。"),
            ("fd", "fd", "按文件名查找，fzf 的默认枚举器。"),
            ("ripgrep", "ripgrep", "按内容搜索，遵守 ignore 规则。"),
            ("fzf", "fzf", "交互式模糊筛选，多个函数的底座。"),
            ("zoxide", "zoxide", "按访问频率跳转目录。"),
            ("atuin", "Atuin", "SQLite 历史库与增强搜索。"),
            ("direnv", "direnv", "按目录加载环境变量。"),
            ("starship", "Starship", "跨 shell 提示符。"),
            ("fnm", "fnm", "Node 版本管理器与惰性加载。"),
            ("forgit", "forgit", "fzf 驱动的 Git 交互命令。"),
            ("lazygit", "lazygit", "终端 Git 全功能界面。"),
            ("gitui", "gitui", "Rust 写的终端 Git 界面。"),
            ("gh", "GitHub CLI", "命令行操作仓库、PR、Actions。"),
            ("btop", "btop", "资源监视器。"),
            ("bottom", "bottom (btm)", "可配置的系统监视器。"),
            ("duf", "duf", "磁盘用量表。"),
            ("procs", "procs", "ps 的现代替代。"),
            ("gping", "gping", "带延迟曲线的 ping。"),
            ("jq", "jq", "JSON 查询与改写。"),
            ("sd", "sd", "直观的文本替换。"),
            ("glow", "glow", "终端里渲染 Markdown。"),
            ("broot", "broot", "树状目录浏览与 br 函数。"),
            ("ranger", "Ranger", "文件管理器与 ra 包装函数。"),
            ("vifm", "Vifm", "Vim 风格双栏文件管理器。"),
            ("tmux", "tmux", "终端复用、会话恢复、pane 导航。"),
            ("zellij", "zellij", "另一套终端复用器。"),
            ("fresh", "Fresh", "终端文本编辑器。"),
            ("neovim", "Neovim", "编辑器入口与独立文档站。"),
            ("httpie", "HTTPie", "http 命令与安装器。"),
            ("navi", "navi", "cheatsheet 搜索与填参。"),
            ("pet", "Pet", "命令片段库。"),
        ],
    ),
    (
        "scripts",
        "自定义脚本",
        "自研工具与安装器",
        [
            ("intro", "本章导读", "哪些脚本是自研的，哪些是上游安装器。"),
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
        "zsh-plugins",
        "Zsh 插件",
        "每个插件的加载方式、配置与用法",
        [
            ("intro", "本章导读", "11 个插件各自的职责与加载阶段。"),
            ("zinit", "Zinit", "插件管理器本体：ice、light、snippet、update。"),
            ("zsh-completions", "zsh-completions", "额外命令补全定义，compinit 前加载。"),
            ("fzf-tab", "fzf-tab", "用 fzf 替代补全菜单，含预览与分组切换。"),
            ("evalcache", "evalcache", "缓存 shell hook 输出，加快启动。"),
            ("vi-mode", "zsh-vi-mode", "命令行 Vim 编辑模式与按键表。"),
            ("autosuggestions", "zsh-autosuggestions", "历史与补全的异步建议。"),
            ("autopair", "zsh-autopair", "自动配对括号与引号。"),
            ("forgit", "forgit", "fzf 驱动的 Git 交互命令。"),
            ("syntax-highlighting", "zsh-syntax-highlighting", "实时命令语法高亮，必须最后加载。"),
            ("fzf-snippets", "fzf 补全与键绑定", "通过 Zinit snippet 加载的两个上游脚本。"),
            ("tool-hooks", "可选工具集成", "navi 与 Pet 的 hook 接入。"),
        ],
    ),
    (
        "tmux-plugins",
        "tmux 插件",
        "TPM 与六个插件的用途、配置项与用法",
        [
            ("intro", "本章导读", "7 个插件各自的职责与安装方式。"),
            ("tpm", "TPM", "插件管理器本体：安装、更新、清理。"),
            ("sensible", "tmux-sensible", "一组公认合理的默认值。"),
            ("persist", "tmux-persist", "手动保存与恢复会话。"),
            ("continuum", "tmux-continuum", "自动保存、自动恢复、状态栏提示。"),
            ("yank", "tmux-yank", "复制到系统剪贴板，含 OSC 52。"),
            ("vim-navigator", "vim-tmux-navigator", "Ctrl+h/j/k/l 跨 Neovim 与 pane 切换。"),
            ("tmux-fzf", "tmux-fzf", "用 fzf 查找 session、window、pane。"),
        ],
    ),
    (
        "configs",
        "应用配置",
        "每个配置文件的作用与键位",
        [
            ("intro", "本章导读", "dotlink 实际映射了哪些配置。"),
            ("mapping", "映射清单", "源路径、目标路径与是否自动部署。"),
            ("starship", "Starship 配置", "两行提示符的模块与显示条件。"),
            ("atuin", "Atuin 配置", "关闭自动同步、数据库位置。"),
            ("tmux", "tmux 配置", "选项、键位、TPM 插件与恢复策略。"),
            ("ranger", "Ranger 配置", "预览、图标、归档插件与快捷键。"),
            ("vifm", "Vifm 配置", "键位表、剪贴板脚本与双栏布局。"),
            ("vim", "Vim 与 GVim", "共享默认值、主题与 GUI 差异。"),
            ("ghostty", "Ghostty 配置", "字体、配色、选中复制。"),
            ("misc", "nano 与 Herdr", "其余小配置的边界。"),
            ("nvim", "Neovim 子模块", "版本固定方式与独立文档站。"),
        ],
    ),
    (
        "maintenance",
        "维护与边界",
        "更新、检查与私人覆盖",
        [
            ("intro", "本章导读", "维护这套配置需要知道的事。"),
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

APP_JS = r"""
(function () {
  var root = document.documentElement;

  /* ---- theme ---------------------------------------------------------- */
  var THEME_KEY = 'dotfiles-theme';
  try {
    var saved = localStorage.getItem(THEME_KEY);
    if (saved === 'dark' || saved === 'light') root.setAttribute('data-theme', saved);
  } catch (e) {}

  function applyThemeLabel() {
    var dark = root.getAttribute('data-theme') === 'dark';
    var btn = document.getElementById('theme-toggle');
    if (btn) btn.textContent = dark ? 'Light' : 'Dark';
  }

  document.addEventListener('click', function (event) {
    var theme = event.target.closest('#theme-toggle');
    if (theme) {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem(THEME_KEY, next); } catch (e) {}
      applyThemeLabel();
      return;
    }

    var side = event.target.closest('#sidebar-toggle');
    if (side) {
      var hidden = document.body.classList.toggle('no-sidebar');
      try { localStorage.setItem('dotfiles-sidebar', hidden ? 'off' : 'on'); } catch (e) {}
      return;
    }

    var restore = event.target.closest('#sidebar-restore');
    if (restore) {
      document.body.classList.remove('no-sidebar');
      try { localStorage.setItem('dotfiles-sidebar', 'on'); } catch (e) {}
      return;
    }
  });

  try {
    if (localStorage.getItem('dotfiles-sidebar') === 'off') {
      document.body.classList.add('no-sidebar');
    }
  } catch (e) {}

  applyThemeLabel();

  /* ---- search --------------------------------------------------------- */
  var input = document.getElementById('q');
  var box = document.getElementById('results');
  var index = [];
  var payload = document.getElementById('search-index');
  if (payload) {
    try { index = JSON.parse(payload.textContent); } catch (e) { index = []; }
  }

  if (!input || !box) return;

  var selected = -1;
  var items = [];

  function esc(text) {
    return String(text).replace(/[&<>"]/g, function (ch) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch];
    });
  }

  function mark(text, query) {
    if (!query) return esc(text);
    var at = text.toLowerCase().indexOf(query);
    if (at < 0) return esc(text);
    return esc(text.slice(0, at)) + '<mark>' + esc(text.slice(at, at + query.length)) +
      '</mark>' + esc(text.slice(at + query.length));
  }

  function score(entry, query) {
    var title = entry.t.toLowerCase();
    var desc = (entry.d || '').toLowerCase();
    var body = (entry.x || '').toLowerCase();
    var at = title.indexOf(query);
    if (at === 0) return 1000;
    if (at > 0) return 800 - at;
    if (desc.indexOf(query) >= 0) return 500;
    if (body.indexOf(query) >= 0) return 200;
    return -1;
  }

  function close() {
    box.hidden = true;
    box.innerHTML = '';
    selected = -1;
    items = [];
  }

  function highlight(next) {
    if (!items.length) return;
    if (selected >= 0 && items[selected]) items[selected].classList.remove('sel');
    selected = (next + items.length) % items.length;
    items[selected].classList.add('sel');
    items[selected].scrollIntoView({ block: 'nearest' });
  }

  function render() {
    var query = input.value.trim().toLowerCase();
    if (!query) { close(); return; }

    var hits = [];
    for (var i = 0; i < index.length; i++) {
      var s = score(index[i], query);
      if (s >= 0) hits.push({ entry: index[i], score: s });
    }
    hits.sort(function (a, b) { return b.score - a.score; });
    hits = hits.slice(0, 24);

    if (!hits.length) {
      box.innerHTML = '<div class="r-empty">No document matches &ldquo;' + esc(input.value.trim()) + '&rdquo;.</div>';
      box.hidden = false;
      items = [];
      selected = -1;
      return;
    }

    var html = '';
    for (var j = 0; j < hits.length; j++) {
      var e = hits[j].entry;
      html += '<a href="' + e.u + '">' +
        '<span class="r-section">' + esc(e.s) + '</span>' +
        '<span class="r-title">' + mark(e.t, query) + '</span>' +
        '<span class="r-desc">' + mark(e.d || '', query) + '</span>' +
        '</a>';
    }
    box.innerHTML = html;
    box.hidden = false;
    items = Array.prototype.slice.call(box.querySelectorAll('a'));
    selected = -1;
    highlight(0);
  }

  input.addEventListener('input', render);
  input.addEventListener('focus', function () { if (input.value.trim()) render(); });

  input.addEventListener('keydown', function (event) {
    if (event.key === 'ArrowDown') { event.preventDefault(); highlight(selected + 1); }
    else if (event.key === 'ArrowUp') { event.preventDefault(); highlight(selected - 1); }
    else if (event.key === 'Enter') {
      if (selected >= 0 && items[selected]) { event.preventDefault(); window.location.href = items[selected].getAttribute('href'); }
    } else if (event.key === 'Escape') { input.value = ''; close(); input.blur(); }
  });

  document.addEventListener('keydown', function (event) {
    var typing = ['INPUT', 'TEXTAREA', 'SELECT'].indexOf(document.activeElement.tagName) >= 0;
    if (event.key === '/' && !typing) { event.preventDefault(); input.focus(); input.select(); }
  });

  document.addEventListener('click', function (event) {
    if (!event.target.closest('.search-box')) close();
  });
})();
"""


def read_git_log(limit: int = 14) -> list[dict]:
    """Recent commits touching the site or the configuration it documents."""
    try:
        out = subprocess.run(
            ["git", "-C", str(ROOT), "log", f"-{limit}", "--date=short",
             "--pretty=format:%h%x1f%ad%x1f%s"],
            capture_output=True, text=True, timeout=20, check=True,
        ).stdout
    except Exception:
        return []
    rows = []
    for line in out.splitlines():
        parts = line.split("\x1f")
        if len(parts) == 3:
            rows.append({"hash": parts[0], "date": parts[1], "subject": parts[2]})
    return rows


def search_index(prefix: str) -> str:
    rows = []
    for section in SECTIONS:
        slug, label, _scope, docs = section
        for doc, title, summary in docs:
            rows.append(
                {
                    "t": title,
                    "d": summary,
                    "s": label,
                    "u": f"{prefix}{slug}/{doc}.html",
                }
            )
    return json.dumps(rows, ensure_ascii=False, separators=(",", ":"))


def inline_assets() -> tuple[str, str]:
    return (SITE_ROOT / "styles.css").read_text(encoding="utf-8"), APP_JS


def head_block(title: str, description: str, prefix: str) -> str:
    css, _ = inline_assets()
    return f'''<!DOCTYPE html>
<html lang="zh-CN" data-theme="light">
<head>
<meta charset="utf-8">
<meta content="width=device-width, initial-scale=1, user-scalable=yes" name="viewport">
<title>{esc(title)} - dotfiles.iamcheyan.com</title>
<meta name="description" content="{esc(description)}">
<meta name="color-scheme" content="light dark">
<style>
{css}
</style>
</head>'''


def side_nav(section: str, doc: str, prefix: str) -> str:
    parts = []
    for slug, label, num in NAV:
        active = slug == section
        parts.append(
            f'<a class="nav-section{" active" if active else ""}" href="{prefix}{slug}/index.html">'
            f'<span class="nav-num">{num}</span>{esc(label)}</a>'
        )
        if active:
            links = "\n".join(
                f'<a class="nav-doc{" active" if d[0] == doc else ""}" href="{prefix}{slug}/{d[0]}.html">{esc(d[1])}</a>'
                for d in BY_SLUG[slug][3]
            )
            parts.append(f'<div class="nav-docs">{links}</div>')
    return "\n".join(parts)


def header(section: str, doc: str, prefix: str) -> str:
    return f'''<header>
  <p class="site-title"><a href="{prefix}index.html">dotfiles</a></p>
  <p class="site-tagline"><em>{TAGLINE}</em></p>

  <div class="toolbar">
    <div class="search-box">
      <input id="q" type="search" placeholder="Search {sum(len(s[3]) for s in SECTIONS)} documents" autocomplete="off" spellcheck="false" aria-label="Search documents">
      <div class="results" id="results" hidden></div>
    </div>
    <div class="toggles">
      <button id="theme-toggle" type="button" aria-label="Toggle colour theme">Dark</button>
      <button id="sidebar-toggle" type="button">Hide sidebar</button>
    </div>
  </div>

  <nav>
    {side_nav(section, doc, prefix)}
  </nav>
  <p class="site-meta"><a href="https://github.com/{SITE["repo"]}">GitHub repository</a><br>
  <a href="https://nvim.iamcheyan.com">Neovim configuration</a><br>
  <a href="{prefix}changes.html">Recent changes</a></p>
</header>'''


def pager(section: str, doc: str, prefix: str) -> str:
    docs = BY_SLUG[section][3]
    i = next(n for n, d in enumerate(docs) if d[0] == doc)
    prev_d = docs[i - 1] if i > 0 else None
    next_d = docs[i + 1] if i + 1 < len(docs) else None
    left = f'<a href="{prefix}{section}/{prev_d[0]}.html">&larr; {esc(prev_d[1])}</a>' if prev_d else ""
    right = (
        f'<a href="{prefix}{section}/{next_d[0]}.html">{esc(next_d[1])} &rarr;</a>'
        if next_d
        else f'<a href="{prefix}{section}/index.html">{esc(BY_SLUG[section][1])} index &rarr;</a>'
    )
    return f'<p class="pager">{left}<span class="pager-sep"> · </span>{right}</p>'


def tail_block(prefix: str) -> str:
    return f'''<button class="restore" id="sidebar-restore" type="button">Show sidebar</button>
<script id="search-index" type="application/json">{search_index(prefix)}</script>
<script>
{APP_JS}
</script>
</body>
</html>'''


def page(section: str, doc: str) -> tuple[dict, str]:
    src = SOURCE / section / f"{doc}.md"
    text = src.read_text(encoding="utf-8")
    match = re.search(r"^> 摘要：(.+)$", text, re.M)
    desc = match.group(1).strip() if match else ""
    title_match = re.search(r"^# (.+)$", text, re.M)
    title = title_match.group(1).strip() if title_match else doc
    text = re.sub(r"^> 摘要：.+\n\n", "", text, count=1, flags=re.M)
    text = re.sub(r"^# .+\n+", "", text, count=1)
    body = render_md(text)
    html = f'''{head_block(title, desc, "../")}
<body>
<div class="wrapper">
{header(section, doc, "../")}
<section>
<h1 id="{esc(doc)}">{esc(title)}</h1>
{body}
{pager(section, doc, "../")}
</section>
</div>
{tail_block("../")}'''
    meta = {"title": title, "description": desc, "section": section, "doc": doc}
    return meta, html


def section_index(section: str) -> tuple[dict, str]:
    slug, label, scope, docs = BY_SLUG[section]
    items = "\n".join(f'<li><a href="{d[0]}.html">{esc(d[1])}</a> — {esc(d[2])}</li>' for d in docs)
    html = f'''{head_block(label, scope, "../")}
<body>
<div class="wrapper">
{header(section, "index", "../")}
<section>
<h1 id="{esc(slug)}">{esc(label)}</h1>
<p>{esc(scope)} — {len(docs)} documents.</p>
<ul>
{items}
</ul>
</section>
</div>
{tail_block("../")}'''
    return {"title": label, "description": scope, "section": section, "doc": "index"}, html


def changes_page() -> str:
    rows = read_git_log()
    if rows:
        items = "\n".join(
            f'<li><span class="c-hash">{esc(r["hash"])}</span>'
            f'<span class="c-date">{esc(r["date"])}</span>'
            f'<span class="c-subject">{esc(r["subject"])}</span></li>'
            for r in rows
        )
        listing = f'<ul class="changes">\n{items}\n</ul>'
    else:
        listing = '<ul class="changes"><li class="c-empty">Git history is unavailable in this build.</li></ul>'

    html = f'''{head_block("Recent changes", "最近提交记录，来自本仓库的 git 历史。", "")}
<body>
<div class="wrapper">
{header("changes", "", "")}
<section>
<h1 id="changes">Recent changes</h1>
<p>最近 {len(rows) if rows else 0} 次提交，直接读取本仓库的 git 历史。每次推送站点文件时，这个列表会随构建一起更新。</p>
{listing}
<p><a href="index.html">Back to the index &rarr;</a></p>
</section>
</div>
{tail_block("")}'''
    return html


def home() -> str:
    sections_html = []
    for slug, label, num in NAV:
        _s, _l, scope, docs = BY_SLUG[slug]
        items = "\n".join(f'<li><a href="{slug}/{d[0]}.html">{esc(d[1])}</a> — {esc(d[2])}</li>' for d in docs)
        sections_html.append(
            f'''<h2><a href="{slug}/index.html">{esc(label)}</a></h2>
<p>{esc(scope)} — {len(docs)} documents.</p>
<ul>
{items}
</ul>'''
        )
    total = sum(len(s[3]) for s in SECTIONS)
    html = f'''{head_block("dotfiles.iamcheyan.com", SITE["tagline"], "")}
<body>
<div class="wrapper">
{header("home", "", "")}
<section>
<h1 id="dotfiles">dotfiles.iamcheyan.com</h1>
<p>{esc(SITE["tagline"])}。{total} documents in {len(SECTIONS)} sections. Each tool has its own
page: what it does, how to invoke it, which flags matter, and what this
repository actually configures.</p>
<p><a href="start/index.html">Start with installation &rarr;</a> &nbsp;
<a href="changes.html">Recent changes &rarr;</a></p>
{"".join(sections_html)}
</section>
</div>
{tail_block("")}'''
    return html


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    written = 0
    for slug, label, num in NAV:
        sdir = OUT / slug
        sdir.mkdir(exist_ok=True)
        _meta, idx = section_index(slug)
        (sdir / "index.html").write_text(
            "\n".join(line.rstrip() for line in idx.splitlines()) + "\n", encoding="utf-8"
        )
        written += 1
        for doc, _t, _s in BY_SLUG[slug][3]:
            _meta, html = page(slug, doc)
            (sdir / f"{doc}.html").write_text(
                "\n".join(line.rstrip() for line in html.splitlines()) + "\n", encoding="utf-8"
            )
            written += 1

    (OUT / "index.html").write_text(
        "\n".join(line.rstrip() for line in home().splitlines()) + "\n", encoding="utf-8"
    )
    (OUT / "changes.html").write_text(
        "\n".join(line.rstrip() for line in changes_page().splitlines()) + "\n", encoding="utf-8"
    )
    (OUT / "CNAME").write_text("dotfiles.iamcheyan.com\n", encoding="utf-8")
    (OUT / "robots.txt").write_text(
        "User-agent: *\nAllow: /\nSitemap: https://dotfiles.iamcheyan.com/sitemap.xml\n",
        encoding="utf-8",
    )
    urls = ["", "changes.html", *[f"{s[0]}/" for s in SECTIONS]]
    urls += [f"{s[0]}/{d[0]}.html" for s in SECTIONS for d in s[3]]
    sitemap = "".join(f'<url><loc>{SITE["url"]}/{u}</loc></url>' for u in urls)
    (OUT / "sitemap.xml").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">' + sitemap + "</urlset>\n",
        encoding="utf-8",
    )
    print(f"Built {written} pages + index + changes into {OUT.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
