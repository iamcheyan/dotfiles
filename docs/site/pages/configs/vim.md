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
