> 摘要：Vim 通用配置与 GVim 专属外观，以及它们如何镜像 Neovim 的常用键位。

# Vim 与 GVim

## 两个文件

| 文件 | 目标 | 作用 |
|---|---|---|
| `config/vim/vimrc` | `~/.vimrc` | Vim 通用配置 |
| `config/gvim/gvimrc` | `~/.gvimrc` | 仅 GVim 的 GUI 外观 |

`gvimrc` 在 `vimrc` 之后加载，只处理 GUI 特有项。

## vimrc 结构

### 基础

```vim
set nocompatible
let mapleader = " "
let maplocalleader = "\\"

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin1
set background=dark
if exists("+termguicolors")
  set termguicolors
endif
syntax on
filetype plugin indent on
colorscheme blue
```

| 设置 | 作用 |
|---|---|
| `fileencodings` | 依次尝试的编码，含日文 ISO-2022-JP、CP932、EUC-JP |
| `termguicolors` | 真彩色（Vim 8+） |
| `colorscheme blue` | 内置蓝色主题，不依赖外部配色 |

`fileencodings` 里有日文编码，说明这个配置考虑过处理日文文件。

### 编辑

```vim
set tabstop=4
set softtabstop=0
set shiftwidth=4
set noexpandtab
set autoindent
set smartindent
set shiftround
set backspace=indent,eol,start
set completeopt=menu,menuone,noselect
```

用真实的 Tab 字符（`noexpandtab`），宽度 4。这与 Neovim 配置可能不同——Vim 配置是独立的一套。

### 显示

```vim
set number
set relativenumber
set cursorline
set cursorcolumn
set nowrap
set mouse=a
set scrolloff=4
set sidescrolloff=8
set splitbelow
set splitright
set hidden
set confirm
set autowrite
```

| 设置 | 作用 |
|---|---|
| `relativenumber` | 相对行号，配合 `5j` 这类跳转 |
| `cursorcolumn` | 高亮当前列 |
| `hidden` | 切换 buffer 时不要求保存 |
| `autowrite` | `:next`、`:make` 前自动保存 |
| `splitbelow` / `splitright` | 新窗口在下方/右方 |

### 搜索

```vim
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmode
set showcmd
set ruler
set wildmenu
set wildmode=longest:full,full
set updatetime=200
set timeoutlen=300
set history=1000
if exists("+inccommand")
  set inccommand=nosplit
endif
```

`smartcase`：全小写搜索忽略大小写，含大写则区分。`inccommand=nosplit` 让 `:s` 的预览在命令行内联显示。

### 剪贴板与 grep

```vim
if has("clipboard") && has("unnamedplus")
  set clipboard=unnamedplus
endif
if executable("rg")
  let &grepprg = "rg --vimgrep"
  set grepformat=%f:%l:%c:%m
endif
set path+=**
```

`path+=**` 让 `:find` 递归搜索子目录。`grepprg` 用 rg，结果带列号。

## vimrc 键位

leader 是空格，与 Neovim 一致。

| 键 | 动作 |
|---|---|
| `<C-s>` | 保存（普通/插入/可视模式） |
| `<leader>e` | `:Explore` |
| `<leader>ff` | `:find` |
| `<leader>fg` | `:grep` |
| `<leader>fb` | `:buffers` |
| `<leader>bd` | `:bdelete` |
| `<leader>qq` | `:qa` |
| `<leader>fn` | `:enew` |
| `<leader>h` | 清除搜索高亮 |
| `<S-h>` / `<S-l>` | 上一个/下一个 buffer |
| `<C-h/j/k/l>` | 窗口间移动 |
| `<leader>-` | 水平分屏 |
| `<leader>v` | 垂直分屏 |
| `<leader>ww` | 切换窗口 |

这些与 Neovim 配置的常用键位保持一致，降低切换成本。

## gvimrc

```vim
if has("gui_running")
  set guioptions-=T
  set guioptions-=L
  set guioptions-=r
  set guioptions-=b

  if exists("+guifont")
    set guifont=MesloLGS\ Nerd\ Font\ Mono\ 12
  endif
endif
```

| 设置 | 移除 |
|---|---|
| `guioptions-=T` | 工具栏 |
| `guioptions-=L` | 左侧滚动条 |
| `guioptions-=r` | 右侧滚动条 |
| `guioptions-=b` | 底部滚动条 |

字体是 Meslo Nerd Font 12pt，与终端一致。

整个文件包在 `if has("gui_running")` 里，所以在终端 Vim 里这些设置不生效。

## 与 Neovim 的关系

| | Vim | Neovim |
|---|---|---|
| 配置语言 | VimL | Lua |
| 插件 | 无（只用内置） | lazy.nvim 管理 |
| 主题 | 内置 blue | 外部配色 |
| LSP | 无 | 完整支持 |
| 用途 | 最小可用回退 | 主力编辑器 |

Vim 配置的定位是**最小可用**：没有插件依赖，任何有 Vim 的机器都能用。Neovim 配置才是完整方案。

`vi` 函数优先选 nvim，没有才退回 vim：

```zsh
vi() {
    if command -v nvim &> /dev/null; then
        nvim "$@"
    elif command -v vim &> /dev/null; then
        vim "$@"
    else
        command vi "$@"
    fi
}
```

## 测试

```bash
vim -u config/vim/vimrc -c 'source config/vim/tests/vim_config_spec.vim'
```

`config/vim/tests/vim_config_spec.vim` 是一个 Vim 脚本测试文件。

## 排错

**Vim 打开是默认外观**：`~/.vimrc` 没链接。`ls -l ~/.vimrc`。

**GVim 有工具栏**：`~/.gvimrc` 没链接，或 `gui_running` 判断失败。

**中文乱码**：`fileencodings` 顺序或系统 locale 问题。

**`<C-s>` 无反应**：终端把 Ctrl+S 当流控。`stty -ixon` 或改用 `<leader>w`。

**`:grep` 不用 rg**：`command -v rg` 无输出，或 `grepprg` 被覆盖。

**颜色只有 8 色**：终端不支持真彩色，`termguicolors` 无效。

<!-- lang:en -->
> Summary: General Vim settings, GVim-specific appearance, and how their common key bindings mirror Neovim.

# Vim and GVim

## Two Files

| File | Target | Purpose |
|---|---|---|
| `config/vim/vimrc` | `~/.vimrc` | General Vim configuration |
| `config/gvim/gvimrc` | `~/.gvimrc` | GUI appearance for GVim only |

`gvimrc` loads after `vimrc` and handles GUI-specific settings only.

## vimrc Structure

### Basics

```vim
set nocompatible
let mapleader = " "
let maplocalleader = "\\"

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin1
set background=dark
if exists("+termguicolors")
  set termguicolors
endif
syntax on
filetype plugin indent on
colorscheme blue
```

| Setting | Effect |
|---|---|
| `fileencodings` | Encodings tried in order, including Japanese ISO-2022-JP, CP932, and EUC-JP |
| `termguicolors` | True color (Vim 8+) |
| `colorscheme blue` | Built-in blue theme; no external colorscheme required |

The Japanese encodings in `fileencodings` reflect that this configuration accounts for handling Japanese files.

### Editing

```vim
set tabstop=4
set softtabstop=0
set shiftwidth=4
set noexpandtab
set autoindent
set smartindent
set shiftround
set backspace=indent,eol,start
set completeopt=menu,menuone,noselect
```

Uses real Tab characters (`noexpandtab`) with a width of 4. This may differ from the Neovim configuration; the Vim configuration is independent.

### Display

```vim
set number
set relativenumber
set cursorline
set cursorcolumn
set nowrap
set mouse=a
set scrolloff=4
set sidescrolloff=8
set splitbelow
set splitright
set hidden
set confirm
set autowrite
```

| Setting | Effect |
|---|---|
| `relativenumber` | Relative line numbers, useful for jumps such as `5j` |
| `cursorcolumn` | Highlight the current column |
| `hidden` | Do not require saving when switching buffers |
| `autowrite` | Save automatically before `:next` and `:make` |
| `splitbelow` / `splitright` | Open new windows below / to the right |

### Search

```vim
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmode
set showcmd
set ruler
set wildmenu
set wildmode=longest:full,full
set updatetime=200
set timeoutlen=300
set history=1000
if exists("+inccommand")
  set inccommand=nosplit
endif
```

`smartcase`: searches written entirely in lowercase ignore case; searches containing uppercase letters are case-sensitive. `inccommand=nosplit` shows the `:s` preview inline in the command line.

### Clipboard and grep

```vim
if has("clipboard") && has("unnamedplus")
  set clipboard=unnamedplus
endif
if executable("rg")
  let &grepprg = "rg --vimgrep"
  set grepformat=%f:%l:%c:%m
endif
set path+=**
```

`path+=**` makes `:find` search subdirectories recursively. `grepprg` uses rg, and results include column numbers.

## vimrc Key Bindings

The leader is Space, matching Neovim.

| Key | Action |
|---|---|
| `<C-s>` | Save (normal/insert/visual modes) |
| `<leader>e` | `:Explore` |
| `<leader>ff` | `:find` |
| `<leader>fg` | `:grep` |
| `<leader>fb` | `:buffers` |
| `<leader>bd` | `:bdelete` |
| `<leader>qq` | `:qa` |
| `<leader>fn` | `:enew` |
| `<leader>h` | Clear search highlighting |
| `<S-h>` / `<S-l>` | Previous / next buffer |
| `<C-h/j/k/l>` | Move between windows |
| `<leader>-` | Horizontal split |
| `<leader>v` | Vertical split |
| `<leader>ww` | Switch windows |

These common bindings match the Neovim configuration and reduce the cost of switching between editors.

## gvimrc

```vim
if has("gui_running")
  set guioptions-=T
  set guioptions-=L
  set guioptions-=r
  set guioptions-=b

  if exists("+guifont")
    set guifont=MesloLGS\ Nerd\ Font\ Mono\ 12
  endif
endif
```

| Setting | Removes |
|---|---|
| `guioptions-=T` | Toolbar |
| `guioptions-=L` | Left scrollbar |
| `guioptions-=r` | Right scrollbar |
| `guioptions-=b` | Bottom scrollbar |

The font is Meslo Nerd Font 12pt, matching the terminal.

The entire file is inside `if has("gui_running")`, so these settings have no effect in terminal Vim.

## Relationship to Neovim

| | Vim | Neovim |
|---|---|---|
| Configuration language | VimL | Lua |
| Plugins | None (built-ins only) | Managed by lazy.nvim |
| Theme | Built-in blue | External colorscheme |
| LSP | None | Full support |
| Use | Minimal fallback | Primary editor |

The Vim configuration is intended as a **minimal usable setup**: it has no plugin dependencies and works on any machine with Vim. The Neovim configuration is the complete solution.

The `vi` function prefers nvim and falls back to vim if it is unavailable:

```zsh
vi() {
    if command -v nvim &> /dev/null; then
        nvim "$@"
    elif command -v vim &> /dev/null; then
        vim "$@"
    else
        command vi "$@"
    fi
}
```

## Test

```bash
vim -u config/vim/vimrc -c 'source config/vim/tests/vim_config_spec.vim'
```

`config/vim/tests/vim_config_spec.vim` is a Vim script test file.

## Troubleshooting

**Vim opens with its default appearance**: `~/.vimrc` is not linked. Check with `ls -l ~/.vimrc`.

**GVim has a toolbar**: `~/.gvimrc` is not linked, or the `gui_running` check failed.

**Chinese text is garbled**: The `fileencodings` order or system locale may be the problem.

**`<C-s>` does nothing**: The terminal may treat Ctrl+S as flow control. Run `stty -ixon` or use `<leader>w` instead.

**`:grep` does not use rg**: `command -v rg` returns nothing, or `grepprg` was overridden.

**Only 8 colors are available**: The terminal does not support true color, so `termguicolors` has no effect.

<!-- lang:ja -->
> 要約：Vim の共通設定、GVim 専用の外観、Neovim と共通のキー割り当てについて説明します。

# Vim と GVim

## 2 つのファイル

| ファイル | 配置先 | 用途 |
|---|---|---|
| `config/vim/vimrc` | `~/.vimrc` | Vim の共通設定 |
| `config/gvim/gvimrc` | `~/.gvimrc` | GVim 専用の GUI 外観 |

`gvimrc` は `vimrc` の後に読み込まれ、GUI 専用の設定だけを扱います。

## vimrc の構成

### 基本

```vim
set nocompatible
let mapleader = " "
let maplocalleader = "\\"

set encoding=utf-8
set fileencodings=ucs-bom,utf-8,iso-2022-jp,cp932,euc-jp,default,latin1
set background=dark
if exists("+termguicolors")
  set termguicolors
endif
syntax on
filetype plugin indent on
colorscheme blue
```

| 設定 | 効果 |
|---|---|
| `fileencodings` | 試行するエンコーディング。日本語の ISO-2022-JP、CP932、EUC-JP を含みます |
| `termguicolors` | True color（Vim 8+）を有効にします |
| `colorscheme blue` | 外部配色に依存せず、内蔵の blue テーマを使います |

`fileencodings` に日本語のエンコーディングが含まれており、日本語ファイルの扱いも考慮した設定です。

### 編集

```vim
set tabstop=4
set softtabstop=0
set shiftwidth=4
set noexpandtab
set autoindent
set smartindent
set shiftround
set backspace=indent,eol,start
set completeopt=menu,menuone,noselect
```

実際の Tab 文字（`noexpandtab`）を使い、幅は 4 にします。Neovim の設定とは異なる場合があります。Vim の設定は独立しています。

### 表示

```vim
set number
set relativenumber
set cursorline
set cursorcolumn
set nowrap
set mouse=a
set scrolloff=4
set sidescrolloff=8
set splitbelow
set splitright
set hidden
set confirm
set autowrite
```

| 設定 | 効果 |
|---|---|
| `relativenumber` | 相対行番号を表示し、`5j` のような移動に役立ちます |
| `cursorcolumn` | 現在の列を強調表示します |
| `hidden` | buffer 切り替え時に保存を必須にしません |
| `autowrite` | `:next` や `:make` の前に自動保存します |
| `splitbelow` / `splitright` | 新しいウィンドウを下／右に開きます |

### 検索

```vim
set ignorecase
set smartcase
set incsearch
set hlsearch
set showmode
set showcmd
set ruler
set wildmenu
set wildmode=longest:full,full
set updatetime=200
set timeoutlen=300
set history=1000
if exists("+inccommand")
  set inccommand=nosplit
endif
```

`smartcase` は、すべて小文字の検索では大文字と小文字を区別せず、大文字を含む検索では区別します。`inccommand=nosplit` にすると、`:s` のプレビューをコマンドライン内に表示します。

### クリップボードと grep

```vim
if has("clipboard") && has("unnamedplus")
  set clipboard=unnamedplus
endif
if executable("rg")
  let &grepprg = "rg --vimgrep"
  set grepformat=%f:%l:%c:%m
endif
set path+=**
```

`path+=**` によって `:find` がサブディレクトリを再帰検索します。`grepprg` は rg を使い、結果に列番号を含めます。

## vimrc のキー割り当て

leader は Neovim と同じ Space です。

| キー | 動作 |
|---|---|
| `<C-s>` | 保存（通常／挿入／ビジュアルモード） |
| `<leader>e` | `:Explore` |
| `<leader>ff` | `:find` |
| `<leader>fg` | `:grep` |
| `<leader>fb` | `:buffers` |
| `<leader>bd` | `:bdelete` |
| `<leader>qq` | `:qa` |
| `<leader>fn` | `:enew` |
| `<leader>h` | 検索ハイライトを消去します |
| `<S-h>` / `<S-l>` | 前／次の buffer |
| `<C-h/j/k/l>` | ウィンドウ間を移動します |
| `<leader>-` | 水平分割 |
| `<leader>v` | 垂直分割 |
| `<leader>ww` | ウィンドウを切り替えます |

よく使うキーを Neovim の設定と揃え、エディターを切り替える負担を減らしています。

## gvimrc

```vim
if has("gui_running")
  set guioptions-=T
  set guioptions-=L
  set guioptions-=r
  set guioptions-=b

  if exists("+guifont")
    set guifont=MesloLGS\ Nerd\ Font\ Mono\ 12
  endif
endif
```

| 設定 | 非表示にするもの |
|---|---|
| `guioptions-=T` | ツールバー |
| `guioptions-=L` | 左のスクロールバー |
| `guioptions-=r` | 右のスクロールバー |
| `guioptions-=b` | 下のスクロールバー |

フォントは端末と同じ Meslo Nerd Font 12pt です。

ファイル全体を `if has("gui_running")` で囲んでいるため、端末版 Vim ではこれらの設定は反映されません。

## Neovim との関係

| | Vim | Neovim |
|---|---|---|
| 設定言語 | VimL | Lua |
| プラグイン | なし（内蔵機能のみ） | lazy.nvim で管理 |
| テーマ | 内蔵 blue | 外部配色 |
| LSP | なし | 完全対応 |
| 用途 | 最小限の代替環境 | メインのエディター |

Vim の設定は**最低限使える環境**を目的としています。プラグインに依存せず、Vim があるマシンなら使えます。完全な環境は Neovim の設定です。

`vi` 関数は nvim を優先し、使えない場合は vim に切り替えます。

```zsh
vi() {
    if command -v nvim &> /dev/null; then
        nvim "$@"
    elif command -v vim &> /dev/null; then
        vim "$@"
    else
        command vi "$@"
    fi
}
```

## テスト

```bash
vim -u config/vim/vimrc -c 'source config/vim/tests/vim_config_spec.vim'
```

`config/vim/tests/vim_config_spec.vim` は Vim スクリプトのテストファイルです。

## トラブルシューティング

**Vim が既定の外観で起動します**：`~/.vimrc` がリンクされていません。`ls -l ~/.vimrc` で確認してください。

**GVim にツールバーがあります**：`~/.gvimrc` がリンクされていないか、`gui_running` の判定に失敗しています。

**中国語が文字化けします**：`fileencodings` の順序、またはシステムの locale に問題がある可能性があります。

**`<C-s>` が動作しません**：端末が Ctrl+S をフロー制御として扱っている可能性があります。`stty -ixon` を実行するか、`<leader>w` を使ってください。

**`:grep` が rg を使いません**：`command -v rg` の出力がないか、`grepprg` が上書きされています。

**色が 8 色しかありません**：端末が True color に対応していないため、`termguicolors` は効果がありません。
