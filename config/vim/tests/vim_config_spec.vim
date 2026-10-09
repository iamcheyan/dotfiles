" Run with: vim -Nu NONE -n -es -S config/vim/tests/vim_config_spec.vim
let s:vim_root = fnamemodify(expand("<sfile>:p"), ":h:h")
execute "source " . fnameescape(s:vim_root . "/vimrc")

call assert_equal("blue", get(g:, "colors_name", ""), "Vim and Neovim should share the Blue colorscheme")
call assert_equal("dark", &background)
call assert_equal(1, &number)
call assert_equal(1, &relativenumber)
call assert_equal(1, &cursorline)
call assert_equal(1, &cursorcolumn)
call assert_equal(0, &wrap)
call assert_equal(4, &tabstop)
call assert_equal(0, &softtabstop)
call assert_equal(4, &shiftwidth)
call assert_equal(0, &expandtab)
call assert_equal(1, &autoindent)
call assert_equal(1, &smartindent)
call assert_equal(1, &splitbelow)
call assert_equal(1, &splitright)
call assert_equal(1, &hidden)
call assert_equal(1, &ignorecase)
call assert_equal(1, &smartcase)
call assert_equal(1, &incsearch)
call assert_equal(1, &hlsearch)
call assert_equal(4, &scrolloff)
call assert_equal(8, &sidescrolloff)
call assert_equal(1, &laststatus, "Vim should keep its native statusline visibility")
call assert_true(empty(&statusline), "Vim should not add a custom themed status bar")
call assert_equal(1, &showmode)
call assert_equal(1, &showcmd)
call assert_equal(1, &ruler)
call assert_true(!empty(maparg("<C-s>", "n")), "Ctrl-S should save like Neovim")
call assert_true(!empty(maparg("<C-h>", "n")), "Ctrl-h should navigate windows like Neovim")
call assert_true(!empty(maparg("<S-h>", "n")), "Shift-h should move to the previous buffer")
call assert_true(!empty(maparg("<S-l>", "n")), "Shift-l should move to the next buffer")
call assert_true(!empty(maparg(" e", "n")), "Space-e should open Vim's built-in file explorer")
call assert_true(!empty(maparg(" ff", "n")), "Space-ff should open Vim's file finder")
call assert_true(!empty(maparg(" fg", "n")), "Space-fg should open Vim's grep prompt")
call assert_true(!empty(maparg(" qq", "n")), "Space-qq should quit all like Neovim")
if executable("rg")
  call assert_match("rg --vimgrep", &grepprg)
endif

if exists("&termguicolors")
  call assert_equal(1, &termguicolors)
endif
if has("mouse")
  call assert_equal("a", &mouse)
endif
if has("clipboard") && has("unnamedplus")
  call assert_true(stridx(&clipboard, "unnamedplus") >= 0)
endif

if !empty(v:errors)
  cquit
endif
qa!
