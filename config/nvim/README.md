# Neovim Configuration

This is a self-managed Neovim setup built on `lazy.nvim`. It intentionally does
not import the LazyVim distribution; LazyVim behavior that is still wanted is
ported into local files under `lua/config/` and `lua/plugins/`.

## Requirements

- Neovim 0.11 or newer
- `git`
- `rg` for grep-based pickers
- C/C++ build tools for native plugins and Treesitter parsers
- `unzip`, `curl`, and `tar` for Mason packages
- Optional: `lazygit` for `<leader>gg`

Install Neovim with the dotfiles helper:

```bash
install:nvim
```

or run the installer directly:

```bash
bash ~/dotfiles/scripts/install/install_nvim.sh
```

## Layout

- `init.lua`: entry point, only loads `config.lazy`
- `lua/config/lazy.lua`: bootstraps `lazy.nvim`, registers local pseudo-events,
  and loads keymaps/autocmds
- `lua/config/options.lua`: core editor defaults
- `lua/config/keymaps-lazyvim.lua`: locally ported LazyVim-style keymaps
- `lua/config/keymaps.lua`: personal keymaps, loaded last so personal mappings win
- `lua/plugins/*.lua`: self-contained plugin specs
- `colors/oceanblack.vim`: default colorscheme

## Core Choices

- Plugin manager: `lazy.nvim`
- Picker and UI utilities: `snacks.nvim`
- Completion: `blink.cmp`
- LSP: native `vim.lsp.config()` / `vim.lsp.enable()` plus Mason
- Treesitter: `nvim-treesitter` main branch with explicit FileType activation
- Session restore: `auto-session`
- File managers: `neo-tree.nvim` and `oil.nvim`
- Status/winbar: `heirline.nvim`

## LSP

Configured servers:

- `lua_ls`
- `basedpyright`

Mason also ensures these CLI tools:

- `stylua`
- `shfmt`

Open Mason with:

```vim
:Mason
```

## Treesitter

This config tracks the `main` branch of `nvim-treesitter`. On that branch,
highlighting, folds, and indentation are enabled explicitly from a `FileType`
autocmd instead of the old `highlight.enable` / `indent.enable` module options.

Check parser state with:

```vim
:checkhealth nvim-treesitter
```

Install or update parsers with:

```vim
:TSInstall lua python typescript
:TSUpdate
```

## Keymaps

The leader key is `<Space>`.

Important groups:

- `<leader>f`: files, buffers, grep, recent files
- `<leader>g`: git actions
- `<leader>c`: code actions and personal copy-path helpers
- `<leader>u`: UI toggles
- `<leader>w`: windows and sessions
- `<leader><tab>`: tab pages

Personal mappings in `lua/config/keymaps.lua` load after the LazyVim-compatible
port, so local mappings intentionally override compatibility mappings.

## Maintenance

After changing plugin specs:

```vim
:Lazy sync
:Lazy clean
```

After editing this chezmoi source tree, apply it:

```bash
chezmoi apply
```

Useful checks:

```bash
nvim --headless '+lua print("NVIM_START_OK")' '+qa'
nvim --headless '+checkhealth vim.lsp' '+qa'
```
