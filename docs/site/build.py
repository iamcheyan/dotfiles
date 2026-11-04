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
            ("long-command-editing", "长命令编辑", "Ctrl+X Ctrl+E 打开 Neovim，Ctrl+O 插入换行。"),
            ("completion", "补全系统", "compinit、zsh-completions、fzf-tab 三个阶段。"),
            ("plugins", "交互插件", "autosuggestions、autopair、forgit、语法高亮。"),
            ("fzf-functions", "f 与 ffd 函数", "两个文件搜索函数的行为、按键与回退逻辑。"),
            ("fnm-node", "fnm 与 Node 工具链", "惰性加载包装器与 npm 全局命令。"),
            ("terminal", "终端与提示符", "Starship、Ghostty、tmux 的分工。"),
            ("troubleshooting", "排错清单", "启动报错、插件缺失、预览不显示怎么查。"),
        ],
    ),
    (
        "commands",
        "Linux 命令手册",
        "常用命令的用法，以及它们在这台 Debian 13 工作机上的实际差异",
        [
            ("intro", "本章导读", "这份手册覆盖什么，命令在本机环境下的三个问题。"),
            ("files", "文件与目录", "ls/eza、cd/zoxide、cp、mv、rm、ln 与权限速查。"),
            ("text", "文本处理", "cat/bat、grep/ripgrep、sed/sd、awk、sort/uniq、jq。"),
            ("search", "查找", "find/fd、locate、which/type 与 fzf 交互式筛选。"),
            ("process", "进程与作业", "ps/procs、btop、kill 信号、后台任务与内存视角。"),
            ("permissions", "权限与提权", "chmod 两种记法、chown、umask、sudo 与 polkit 审查。"),
            ("disk", "磁盘与挂载", "df/duf、ncdu、lsblk、NAS 挂载与 SMART 健康。"),
            ("network", "网络与传输", "ip、ss、curl、ssh、scp/rsync 与 Tailscale。"),
            ("system", "系统信息与日志", "hostnamectl、free、dmesg、journalctl 与服务排查。"),
            ("packages", "软件包管理", "apt、pacman、nixos-rebuild、cargo/npm/pipx 与 Docker。"),
            ("archives", "压缩与归档", "tar/zstd、zip、7z 与解压陌生包的安全习惯。"),
            ("our-environment", "本机环境实战", "内存纪律、Zsh 差异、tmux OSC 52、gh 环境变量、无头桌面。"),
            ("cheatsheet", "速查表", "高频组合、管道模式、危险命令清单与打印卡片。"),
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
            ("carapace", "Carapace", "多命令参数补全、原生补全 bridges 与 spec。"),
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
            ("lf", "lf", "Ranger-style bindings, Nerd Font icons, pane borders, and archive commands."),
            ("vifm", "Vifm", "Vim 风格双栏文件管理器。"),
            ("tmux", "tmux", "终端复用、会话恢复、pane 导航。"),
            ("zellij", "zellij", "另一套终端复用器。"),
            ("fresh", "Fresh", "终端文本编辑器。"),
            ("neovim", "Neovim", "编辑器入口与独立文档站。"),
            ("httpie", "HTTPie", "http 命令与安装器。"),
            ("navi", "navi", "cheatsheet 搜索与填参。"),
            ("pet", "Pet", "命令片段库。"),
            ("miru", "miru", "终端文件查看器：Markdown 走 glamour，源码与配置走 chroma，按 b 在浏览器预览。"),
            ("pay-respects", "pay-respects", "按 F 为错误命令提供修正建议。"),
            ("delta", "delta", "git diff 的语法高亮分页器，diffnav 的渲染引擎。"),
            ("diffnav", "diffnav", "基于 delta 的 git diff 分页器，带 GitHub 风格文件树与 watch 模式。"),
            ("hunk", "hunk", "面向代码评审的终端 diff 查看器：多文件侧栏、agent 行内批注、GitHub PR 直连。"),
            ("visidata", "VisiData", "终端电子表格：浏览、排序、筛选、统计 CSV/TSV/JSON 等表格数据。"),
            ("tabiew", "tabiew", "CSV/TSV/parquet 的 TUI 查看器，支持 SQL 查询。"),
            ("qsv", "qsv", "极速 CSV 数据整理工具箱：70+ 子命令，统计、验证、转换、join。"),
            ("toolong", "toolong", "查看、tail、合并和搜索日志文件与 JSONL，自动识别时间戳。"),
            ("harlequin", "harlequin", "终端 SQL IDE：多连接、结果分栏、100+ 键位，附带 hsql agent 客户端。"),
            ("lazysql", "LazySQL", "Vim 键位终端数据库管理器：多连接、表浏览、SQL 编辑器。"),
            ("sqlmux", "sqlmux", "tmux 式窗格与 Vim 风格 SQL 编辑器的终端数据库客户端。"),
            ("rainfrog", "Rainfrog", "轻量终端数据库客户端：查询编辑、历史、收藏与表格浏览。"),
            ("dekit", "dekit", "进程管理器：用一个配置文件在开发与生产环境编排任务、依赖与重启。"),
            ("topgrade", "topgrade", "一条命令升级所有东西：apt、npm、pipx、cargo、rustup 等。"),
            ("mise", "mise", "多语言开发工具与运行时版本管理器。"),
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
            ("intro", "本章导读", "9 个插件的职责、加载阶段与顺序约束。"),
            ("zinit", "Zinit", "插件管理器本体：ice、light、snippet、update。"),
            ("zsh-completions", "zsh-completions", "额外命令补全定义，compinit 前加载。"),
            ("fzf-tab", "fzf-tab", "用 fzf 替代补全菜单，含预览与分组切换。"),
            ("evalcache", "evalcache", "缓存 shell hook 输出，加快启动。"),
            ("vi-mode", "zsh-vi-mode", "命令行 Vim 编辑模式与按键表。"),
            ("zsh-abbr", "zsh-abbr", "自动展开缩写、作用域、历史与 vi-mode 键位。"),
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
        "TPM 与九个插件的用途、配置项与用法",
        [
            ("intro", "本章导读", "10 个插件各自的职责与安装方式。"),
            ("tpm", "TPM", "插件管理器本体：安装、更新、清理。"),
            ("sensible", "tmux-sensible", "一组公认合理的默认值。"),
            ("persist", "tmux-persist", "手动保存与恢复会话。"),
            ("continuum", "tmux-continuum", "自动保存、自动恢复、状态栏提示。"),
            ("yank", "tmux-yank", "复制到系统剪贴板，含 OSC 52。"),
            ("vim-navigator", "vim-tmux-navigator", "Ctrl+h/j/k/l 跨 Neovim 与 pane 切换。"),
            ("tmux-fzf", "tmux-fzf", "用 fzf 查找 session、window、pane。"),
            ("tmux-thumbs", "tmux-thumbs", "屏幕文本与路径的双字母快速标签复制。"),
            ("extrakto", "extrakto", "用 fzf 模糊提取当前屏幕上的单词、路径或 URL。"),
            ("tmux-notify", "tmux-notify", "后台分屏长耗时命令完成提醒。"),
        ],
    ),
    (
        "configs",
        "应用配置",
        "每个配置文件的作用与键位",
        [
            ("intro", "本章导读", "dotlink 实际映射了哪些配置。"),
            ("theme-standard", "终端统一配色标准", "Neovim Blue / Nostalgia 的颜色角色与应用规则。"),
            ("mapping", "映射清单", "源路径、目标路径与是否自动部署。"),
            ("starship", "Starship 配置", "两行提示符的模块与显示条件。"),
            ("atuin", "Atuin 配置", "关闭自动同步、数据库位置。"),
            ("tmux", "tmux 配置", "选项、键位、TPM 插件与恢复策略。"),
            ("ranger", "Ranger 配置", "预览、图标、归档插件与快捷键。"),
            ("lf", "lf 設定", "Ranger風キーバインド、アイコン、枠線、ディレクトリ移動。"),
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


def render_md_langs(blocks: dict[str, str], langs_on_page: list[str]) -> str:
    """Render each language block and wrap it in a language span."""
    out = []
    for lang in LANGS:
        if lang not in blocks or lang not in langs_on_page:
            continue
        out.append(f'<div class="lb" data-lang="{lang}">{render_md(blocks[lang])}</div>')
    return "".join(out)


def doc_lang_meta(src: Path) -> tuple[dict[str, str], list[str]]:
    """Per-language (title, description) for one markdown source.

    Files without markers collapse to a single zh block, so old pages need
    no changes.
    """
    blocks = split_langs(src.read_text(encoding="utf-8"))
    meta: dict[str, tuple[str, str]] = {}
    summary_re = re.compile(r"^> (?:摘要|Summary|要約)：?(.+)$", re.M)
    for lang, text in blocks.items():
        m_desc = summary_re.search(text)
        m_title = re.search(r"^# (.+)$", text, re.M)
        desc = m_desc.group(1).strip().lstrip(":： ").strip() if m_desc else ""
        title = m_title.group(1).strip() if m_title else src.stem
        meta[lang] = (title, desc)
    return blocks, meta


# ---------------------------------------------------------------------------
# Layout - modelled on dotfiles.github.io: a fixed 270px header column on the
# left (site title, tagline, stacked navigation) and a 500px content column on
# the right. Lato, black on white, blue links, light grey code blocks.
# ---------------------------------------------------------------------------

TAGLINE = "Your unofficial guide to this dotfiles setup."

LANGS = ["zh", "en", "ja"]
LANG_MARK = re.compile(r"^<!--\s*lang:(zh|en|ja)\s*-->\s*$", re.M)

# UI chrome strings per language. Doc titles come from the per-language H1.
UI = {
    "zh": {"search": "搜索 {} 篇文档", "toggle": "切换语言"},
    "en": {"search": "Search {} documents", "toggle": "Switch language"},
    "ja": {"search": "{} 件のドキュメントを検索", "toggle": "言語を切り替える"},
}

# section slug -> label/scope per language, for nav and index pages
SECTIONS_I18N = {
    "start": {
        "zh": ("开始使用", "安装、选项与安装后核对"),
        "en": ("Getting started", "Install, options and post-install checks"),
        "ja": ("はじめに", "インストール・オプション・導入確認"),
    },
    "shell": {
        "zh": ("Zsh 与终端", "加载顺序、交互插件、搜索函数"),
        "en": ("Zsh & terminal", "Load order, interactive plugins, search functions"),
        "ja": ("Zsh とターミナル", "読み込み順・対話プラグイン・検索関数"),
    },
    "commands": {
        "zh": ("Linux 命令手册", "本仓库日常用到的命令速查"),
        "en": ("Linux commands", "Everyday command reference in this repo"),
        "ja": ("Linux コマンド", "このリポジトリで常用するコマンド集"),
    },
    "tools": {
        "zh": ("工具目录", "每个工具一页：做什么、怎么调、哪些选项要紧"),
        "en": ("Tools", "One page per tool: what it does, how to call it, which flags matter"),
        "ja": ("ツール", "ツールごとに 1 ページ：役割・呼び出し方・重要なフラグ"),
    },
    "scripts": {
        "zh": ("自定义脚本", "scripts/ 下每个脚本的行为与用法"),
        "en": ("Custom scripts", "Behaviour and usage of each script under scripts/"),
        "ja": ("自作スクリプト", "scripts/ 配下の各スクリプトの動作と使い方"),
    },
    "zsh-plugins": {
        "zh": ("Zsh 插件", "Zinit 管理的 Zsh 插件"),
        "en": ("Zsh plugins", "Zinit-managed Zsh plugins"),
        "ja": ("Zsh プラグイン", "Zinit で管理する Zsh プラグイン"),
    },
    "tmux-plugins": {
        "zh": ("tmux 插件", "TPM 管理的 tmux 插件"),
        "en": ("tmux plugins", "TPM-managed tmux plugins"),
        "ja": ("tmux プラグイン", "TPM で管理する tmux プラグイン"),
    },
    "configs": {
        "zh": ("应用配置", "各应用的配置文件与关键选项"),
        "en": ("App configs", "Config files and the options that matter"),
        "ja": ("アプリ設定", "各アプリの設定ファイルと重要なオプション"),
    },
    "maintenance": {
        "zh": ("维护与边界", "更新、备份、检查与边界"),
        "en": ("Maintenance", "Updates, backups, checks and boundaries"),
        "ja": ("メンテナンス", "更新・バックアップ・確認と境界"),
    },
}

# (section, doc) -> {lang: (title, description)}, filled while building pages
LANG_TITLES: dict[tuple[str, str], dict[str, tuple[str, str]]] = {}


def split_langs(text: str) -> dict[str, str]:
    """Split one markdown file into per-language blocks.

    A file without <!-- lang:xx --> markers is a single zh document, so the
    110 existing pages keep working unchanged while translations are added
    one block at a time.
    """
    if not LANG_MARK.search(text):
        return {"zh": text}
    out: dict[str, list[str]] = {}
    cur = "zh"  # content before the first marker is the zh block
    out.setdefault(cur, [])
    in_fence = False
    for line in text.splitlines(keepends=True):
        stripped = line.strip()
        if stripped.startswith("```") or stripped.startswith("~~~"):
            in_fence = not in_fence
        m = LANG_MARK.match(line.strip("\n")) if not in_fence else None
        if m:
            cur = m.group(1)
            out.setdefault(cur, [])
            continue
        out[cur].append(line)
    return {lang: "".join(lines).strip("\n") + "\n" for lang, lines in out.items()}


def lang_span(value_by_lang: dict[str, str], langs_on_page: list[str]) -> str:
    """One string, one span per available language, hidden by CSS elsewhere."""
    spans = []
    for lang in LANGS:
        if lang in value_by_lang and lang in langs_on_page:
            spans.append(f'<span class="lb" data-lang="{lang}">{esc(value_by_lang[lang])}</span>')
    return "".join(spans)


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
    if (!btn) return;
    btn.setAttribute('aria-pressed', dark ? 'true' : 'false');
    btn.setAttribute('aria-label', dark ? '切换到浅色主题' : '切换到深色主题');
    btn.title = dark ? '切换到浅色主题' : '切换到深色主题';
    var mark = btn.querySelector('.theme-mark');
    if (mark) mark.textContent = dark ? '☀️' : '🌙';
  }

  /* ---- language -------------------------------------------------------- */
  var LANG_KEY = 'dotfiles-lang';
  var LANGS = ['zh', 'en', 'ja'];
  var LANG_LABEL = { zh: '中', en: 'EN', ja: '日' };
  var LANG_NAME = { zh: '中文', en: 'English', ja: '日本語' };

  function applyLang(lang) {
    if (LANGS.indexOf(lang) < 0) lang = 'zh';
    root.setAttribute('data-lang', lang);
    var btn = document.getElementById('lang-toggle');
    if (btn) {
      btn.textContent = LANG_LABEL[lang];
      btn.setAttribute('aria-label', '切换语言，当前 ' + LANG_NAME[lang]);
      btn.title = '切换语言，当前 ' + LANG_NAME[lang];
    }
    var q = document.getElementById('q');
    if (q) q.placeholder = q.getAttribute('data-' + lang) || q.placeholder;
    try { localStorage.setItem(LANG_KEY, lang); } catch (e) {}
  }

  function detectLang() {
    try {
      var saved = localStorage.getItem(LANG_KEY);
      if (saved) return saved;
    } catch (e) {}
    var nav = (navigator.language || navigator.browserLang || 'zh').toLowerCase();
    if (nav.indexOf('zh') === 0) return 'zh';
    if (nav.indexOf('ja') === 0) return 'ja';
    return 'en';
  }

  applyLang(detectLang());

  document.addEventListener('click', function (event) {
    var langBtn = event.target.closest('#lang-toggle');
    if (langBtn) {
      var cur = root.getAttribute('data-lang');
      applyLang(LANGS[(LANGS.indexOf(cur) + 1) % LANGS.length]);
      return;
    }

    var theme = event.target.closest('#theme-toggle');
    if (theme) {
      var next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
      root.setAttribute('data-theme', next);
      try { localStorage.setItem(THEME_KEY, next); } catch (e) {}
      applyThemeLabel();
      return;
    }

    var navToggle = event.target.closest('#nav-toggle');
    if (navToggle) {
      var open = document.body.classList.toggle('nav-open');
      navToggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      return;
    }
  });

  document.addEventListener('keydown', function (event) {
    if (event.key !== 'Escape') return;
    var navToggle = document.getElementById('nav-toggle');
    if (document.body.classList.contains('nav-open')) {
      document.body.classList.remove('nav-open');
      if (navToggle) {
        navToggle.setAttribute('aria-expanded', 'false');
        navToggle.focus();
      }
    }
  });

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

    var lang = root.getAttribute('data-lang') || 'zh';
    var pool = index.filter(function (e) { return e.l === lang; });
    if (!pool.length) pool = index.filter(function (e) { return e.l === 'zh'; });

    var hits = [];
    for (var i = 0; i < pool.length; i++) {
      var s = score(pool[i], query);
      if (s >= 0) hits.push({ entry: pool[i], score: s });
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
            for lang in LANGS:
                t, d = title, summary
                meta = LANG_TITLES.get((slug, doc), {}).get(lang)
                if meta:
                    t, d = meta
                rows.append(
                    {
                        "l": lang,
                        "t": t,
                        "d": d,
                        "s": SECTIONS_I18N.get(slug, {}).get(lang, (label, ""))[0],
                        "u": f"{prefix}{slug}/{doc}.html",
                    }
                )
    return json.dumps(rows, ensure_ascii=False, separators=(",", ":"))


def inline_assets() -> tuple[str, str]:
    return (SITE_ROOT / "styles.css").read_text(encoding="utf-8"), APP_JS


def head_block(title: str, description: str, prefix: str) -> str:
    css, _ = inline_assets()
    return f'''<!DOCTYPE html>
<html lang="zh-CN" data-theme="light" data-lang="zh">
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
        i18n = SECTIONS_I18N.get(slug, {})
        labels = {lang: i18n.get(lang, (label, ""))[0] for lang in LANGS}
        parts.append(
            f'<a class="nav-section{" active" if active else ""}" href="{prefix}{slug}/index.html">'
            f'<span class="nav-num">{num}</span>{lang_span(labels, LANGS)}</a>'
        )
        if active:
            links = "\n".join(
                f'<a class="nav-doc{" active" if d[0] == doc else ""}" href="{prefix}{slug}/{d[0]}.html">'
                f'{lang_span({l: LANG_TITLES.get((slug, d[0]), {}).get(l, (d[1], ""))[0] for l in LANGS}, LANGS)}</a>'
                for d in BY_SLUG[slug][3]
            )
            parts.append(f'<div class="nav-docs">{links}</div>')
    return "\n".join(parts)


def header(section: str, doc: str, prefix: str) -> str:
    nav_items = {
        "start": {"zh": "安装", "en": "Install", "ja": "導入"},
        "tools": {"zh": "工具", "en": "Tools", "ja": "ツール"},
    }
    return f'''<header class="site-header">
  <div class="topbar">
    <nav class="topbar-links" aria-label="Project links">
      <a href="https://iamcheyan.com/">Iam cheyan .com</a>
      <a href="https://github.com/{SITE["repo"]}">GitHub</a>
      <a href="https://nvim.iamcheyan.com">Neovim</a>
      <a href="{prefix}changes.html">{lang_span({"zh": "最近改动", "en": "Recent changes", "ja": "最近の変更"}, LANGS)}</a>
    </nav>
    <div class="header-tools">
      <button id="lang-toggle" type="button" class="lang-toggle" aria-label="切换语言" title="切换语言">中</button>
      <button id="theme-toggle" type="button" class="theme-toggle" aria-label="切换到深色主题" title="切换到深色主题" aria-pressed="false">
        <span class="theme-mark" aria-hidden="true">🌙</span>
      </button>
    </div>
  </div>
  <div class="brandbar">
    <a class="brand" href="{prefix}index.html">dotfiles<span class="brand-dot">.</span><span class="brand-sub">iamcheyan.com</span></a>
    <nav class="site-nav" aria-label="Primary navigation">
      <a href="{prefix}start/index.html">{lang_span(nav_items["start"], LANGS)}</a>
      <a href="{prefix}tools/index.html">{lang_span(nav_items["tools"], LANGS)}</a>
      <a href="https://github.com/{SITE["repo"]}">GitHub</a>
      <button class="nav-toggle" id="nav-toggle" type="button" aria-controls="site-navigation" aria-expanded="false">{lang_span({"zh": "目录", "en": "Menu", "ja": "目次"}, LANGS)}</button>
    </nav>
  </div>
</header>'''


def sidebar(section: str, doc: str, prefix: str) -> str:
    count = sum(len(s[3]) for s in SECTIONS)
    return f'''<aside class="site-sidebar" id="site-navigation">
  <div class="search-box">
    <label class="search-label" for="q">搜索文档</label>
    <input id="q" type="search" data-zh="搜索 {count} 篇文档" data-en="Search {count} documents" data-ja="{count} 件のドキュメントを検索" placeholder="搜索 {count} 篇文档" autocomplete="off" spellcheck="false" aria-label="搜索文档">
    <div class="results" id="results" hidden></div>
  </div>
  <nav class="side-nav" aria-label="Documentation">
    {side_nav(section, doc, prefix)}
  </nav>
  <p class="side-meta"><a href="https://github.com/{SITE["repo"]}">GitHub repository</a><br>
  <a href="https://nvim.iamcheyan.com">Neovim configuration</a><br>
  <a href="{prefix}changes.html">{lang_span({"zh": "最近改动", "en": "Recent changes", "ja": "最近の変更"}, LANGS)}</a></p>
</aside>'''


def footer(prefix: str) -> str:
    return f'''<footer class="site-footer">
  <div class="footer-inner">
    <span>{lang_span({"zh": "公开 dotfiles 与终端环境文档", "en": "Public dotfiles and terminal environment guide", "ja": "公開 dotfiles とターミナル環境のドキュメント"}, LANGS)}</span>
    <span>© {SITE["repo"].split("/")[0]} · <a href="https://iamcheyan.com/">A project by Cheyan</a></span>
  </div>
</footer>'''


def _doc_titles(section: str, doc: str) -> dict[str, str]:
    i = next(n for n, d in enumerate(BY_SLUG[section][3]) if d[0] == doc)
    zh_title = BY_SLUG[section][3][i][1]
    return {l: LANG_TITLES.get((section, doc), {}).get(l, (zh_title, ""))[0] for l in LANGS}


def pager(section: str, doc: str, prefix: str) -> str:
    docs = BY_SLUG[section][3]
    i = next(n for n, d in enumerate(docs) if d[0] == doc)
    prev_d = docs[i - 1] if i > 0 else None
    next_d = docs[i + 1] if i + 1 < len(docs) else None
    left = (
        f'<a href="{prefix}{section}/{prev_d[0]}.html">&larr; {lang_span(_doc_titles(section, prev_d[0]), LANGS)}</a>'
        if prev_d else ""
    )
    if next_d:
        right = f'<a href="{prefix}{section}/{next_d[0]}.html">{lang_span(_doc_titles(section, next_d[0]), LANGS)} &rarr;</a>'
    else:
        idx = {l: SECTIONS_I18N.get(section, {}).get(l, (BY_SLUG[section][1], ""))[0] for l in LANGS}
        right = f'<a href="{prefix}{section}/index.html">{lang_span(idx, LANGS)} &rarr;</a>'
    return f'<p class="pager">{left}<span class="pager-sep"> · </span>{right}</p>'


def tail_block(prefix: str) -> str:
    return f'''<script id="search-index" type="application/json">{search_index(prefix)}</script>
<script>
{APP_JS}
</script>
</body>
</html>'''


def page(section: str, doc: str) -> tuple[dict, str]:
    src = SOURCE / section / f"{doc}.md"
    blocks, lang_meta = doc_lang_meta(src)
    # A language missing on this page falls back to zh content, so switching
    # languages never blanks the page; translations then land block by block.
    if "zh" in blocks:
        for lang in LANGS:
            if lang not in blocks:
                blocks[lang] = blocks["zh"]
                lang_meta[lang] = lang_meta["zh"]
    LANG_TITLES[(section, doc)] = lang_meta
    langs_on_page = [l for l in LANGS if l in blocks]
    title = lang_meta.get("zh", (doc, ""))[0]
    desc = lang_meta.get("zh", ("", ""))[1]
    # strip summary line (摘要/Summary/要約) and H1 from each block
    summary_re = re.compile(r"^> (摘要|Summary|要約)：?.+\n\n", re.M)
    for lang in blocks:
        t = summary_re.sub("", blocks[lang], count=1)
        t = re.sub(r"^# .+\n+", "", t, count=1)
        blocks[lang] = t
    body = render_md_langs(blocks, langs_on_page)
    title_spans = lang_span({l: lang_meta[l][0] for l in langs_on_page}, langs_on_page)
    lead_spans = lang_span({l: lang_meta[l][1] for l in langs_on_page}, langs_on_page)
    section_num = next(num for slug, _label, num in NAV if slug == section)
    html = f'''{head_block(title, desc, "../")}
<body>
<a class="skip-link" href="#main">{lang_span({"zh": "跳到正文", "en": "Skip to content", "ja": "本文へ"}, LANGS)}</a>
<div class="site-shell">
{header(section, doc, "../")}
<div class="site-layout">
{sidebar(section, doc, "../")}
<main class="site-content" id="main">
  <header class="page-head">
    <p class="eyebrow">CHAPTER {section_num} / {esc(section.upper())}</p>
    <h1 class="page-title" id="{esc(doc)}">{title_spans}</h1>
    <p class="page-lead">{lead_spans}</p>
  </header>
  <div class="article-body">
{body}
  </div>
  {pager(section, doc, "../")}
</main>
</div>
{footer("../")}
</div>
{tail_block("../")}'''
    meta = {"title": title, "description": desc, "section": section, "doc": doc}
    return meta, html


def section_index(section: str) -> tuple[dict, str]:
    slug, label, scope, docs = BY_SLUG[section]
    i18n = SECTIONS_I18N.get(slug, {})
    label_of = {l: i18n.get(l, (label, ""))[0] for l in LANGS}
    scope_of = {l: i18n.get(l, (scope, ""))[1] for l in LANGS}
    section_num = next(num for s, _label, num in NAV if s == slug)
    items = []
    for i, d in enumerate(docs, start=1):
        meta = LANG_TITLES.get((slug, d[0]), {})
        title_spans = lang_span({l: meta.get(l, (d[1], d[2]))[0] for l in LANGS}, LANGS)
        desc_spans = lang_span({l: meta.get(l, (d[1], d[2]))[1] for l in LANGS}, LANGS)
        items.append(
            f'<li><a class="doc-link" href="{d[0]}.html">'
            f'<span class="doc-num">{i:02d}</span>'
            f'<span class="doc-copy"><span class="doc-title">{title_spans}</span>'
            f'<span class="doc-desc">{desc_spans}</span></span>'
            f'<span class="doc-arrow" aria-hidden="true">&rarr;</span></a></li>'
        )
    title_spans = lang_span(label_of, LANGS)
    scope_spans = lang_span(scope_of, LANGS)
    html = f'''{head_block(label, scope, "../")}
<body>
<a class="skip-link" href="#main">{lang_span({"zh": "跳到正文", "en": "Skip to content", "ja": "本文へ"}, LANGS)}</a>
<div class="site-shell">
{header(section, "index", "../")}
<div class="site-layout">
{sidebar(section, "index", "../")}
<main class="site-content" id="main">
  <header class="page-head">
    <p class="eyebrow">SECTION {section_num} / {esc(slug.upper())}</p>
    <h1 class="page-title" id="{esc(slug)}">{title_spans}</h1>
    <p class="page-lead">{scope_spans}</p>
  </header>
  <ul class="section-index">
{chr(10).join(items)}
  </ul>
</main>
</div>
{footer("../")}
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

    count = len(rows) if rows else 0
    html = f'''{head_block("Recent changes", "最近提交记录，来自本仓库的 git 历史。", "")}
<body>
<a class="skip-link" href="#main">{lang_span({"zh": "跳到正文", "en": "Skip to content", "ja": "本文へ"}, LANGS)}</a>
<div class="site-shell">
{header("changes", "", "")}
<div class="site-layout">
{sidebar("changes", "", "")}
<main class="site-content" id="main">
  <header class="page-head">
    <p class="eyebrow">HISTORY / GIT LOG</p>
    <h1 class="page-title" id="changes">{lang_span({"zh": "最近改动", "en": "Recent changes", "ja": "最近の変更"}, LANGS)}</h1>
    <p class="page-lead lb" data-lang="zh">最近 {count} 次提交，直接读取本仓库的 git 历史。每次推送站点文件时，这个列表会随构建一起更新。</p>
    <p class="page-lead lb" data-lang="en">The latest {count} commits, read straight from this repository's git history. The list updates on every push that touches the site.</p>
    <p class="page-lead lb" data-lang="ja">直近 {count} 件のコミット。リポジトリの git 履歴から直接読み込み、サイトファイルを含むプッシュのたびに更新されます。</p>
  </header>
  {listing}
  <p><a class="button" href="index.html">{lang_span({"zh": "返回目录", "en": "Back to the index", "ja": "目次へ戻る"}, LANGS)} &rarr;</a></p>
</main>
</div>
{footer("")}
</div>
{tail_block("")}'''
    return html


def home() -> str:
    sections_html = []
    for slug, label, num in NAV:
        _s, _l, scope, docs = BY_SLUG[slug]
        i18n = SECTIONS_I18N.get(slug, {})
        label_of = {l: i18n.get(l, (label, ""))[0] for l in LANGS}
        scope_of = {l: i18n.get(l, (scope, ""))[1] for l in LANGS}
        items = []
        for di, d in enumerate(docs, start=1):
            meta = LANG_TITLES.get((slug, d[0]), {})
            title_spans = lang_span({l: meta.get(l, (d[1], d[2]))[0] for l in LANGS}, LANGS)
            desc_spans = lang_span({l: meta.get(l, (d[1], d[2]))[1] for l in LANGS}, LANGS)
            items.append(
                f'<li><a class="doc-link" href="{slug}/{d[0]}.html">'
                f'<span class="doc-num">{di:02d}</span>'
                f'<span class="doc-copy"><span class="doc-title">{title_spans}</span>'
                f'<span class="doc-desc">{desc_spans}</span></span></a></li>'
            )
        label_spans = lang_span(label_of, LANGS)
        scope_spans = lang_span(scope_of, LANGS)
        english_label = esc(i18n.get("en", (label, ""))[0]).upper()
        sections_html.append(
            f'''<section class="chapter-index" id="{slug}">
  <h2 class="section-heading"><a class="section-title" href="{slug}/index.html">{label_spans}</a><span class="section-label">{num} / {english_label}</span></h2>
  <p class="chapter-scope">{scope_spans}</p>
  <ul class="doc-list">
{chr(10).join(items)}
  </ul>
</section>'''
        )
    total = sum(len(s[3]) for s in SECTIONS)
    lead_zh = f'{esc(SITE["tagline"])}。{total} 篇文档，分 {len(SECTIONS)} 章。每个工具一页：做什么、怎么调、哪些选项要紧、本仓库实际配置了什么。'
    lead_en = f'{esc(SITE["tagline"])}. {total} documents in {len(SECTIONS)} sections. Each tool has its own page: what it does, how to invoke it, which flags matter, and what this repository actually configures.'
    lead_ja = f'{esc(SITE["tagline"])}。{total} 件のドキュメントを {len(SECTIONS)} 章に分けています。ツールごとに 1 ページ：役割・呼び出し方・重要なフラグ・このリポジトリでの実際の設定。'
    html = f'''{head_block("dotfiles.iamcheyan.com", SITE["tagline"], "")}
<body>
<a class="skip-link" href="#main">{lang_span({"zh": "跳到正文", "en": "Skip to content", "ja": "本文へ"}, LANGS)}</a>
<div class="site-shell">
{header("home", "", "")}
<div class="site-layout">
{sidebar("home", "", "")}
<main class="site-content" id="main">
  <section class="home-intro">
    <p class="eyebrow">PUBLIC DOTFILES / FIELD MANUAL</p>
    <h1 class="page-title" id="dotfiles">dotfiles<span class="brand-dot">.</span>iamcheyan.com</h1>
    <p class="page-lead lb" data-lang="zh">{lead_zh}</p>
    <p class="page-lead lb" data-lang="en">{lead_en}</p>
    <p class="page-lead lb" data-lang="ja">{lead_ja}</p>
    <div class="home-actions">
      <a class="button button-primary" href="start/index.html">{lang_span({"zh": "从安装开始", "en": "Start with installation", "ja": "導入から始める"}, LANGS)}</a>
      <a class="button" href="changes.html">{lang_span({"zh": "最近改动", "en": "Recent changes", "ja": "最近の変更"}, LANGS)}</a>
    </div>
  </section>
{chr(10).join(sections_html)}
</main>
</div>
{footer("")}
</div>
{tail_block("")}'''
    return html


def prescan_titles() -> None:
    """Fill LANG_TITLES for every (section, doc) before anything renders."""
    for slug, _label, _scope, docs in SECTIONS:
        for doc, _t, _s in docs:
            src = SOURCE / slug / f"{doc}.md"
            if not src.exists():
                continue
            _blocks, lang_meta = doc_lang_meta(src)
            existing = LANG_TITLES.get((slug, doc), {})
            existing.update(lang_meta)
            LANG_TITLES[(slug, doc)] = existing


def main() -> None:
    OUT.mkdir(parents=True, exist_ok=True)
    prescan_titles()
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
