# Neovim Plugins

此列表按当前 `lua/plugins/*.lua` 配置整理。更新时间: 2026-07-14。

## Core

| Plugin | Purpose |
| --- | --- |
| `lazy.nvim` | Plugin manager and bootstrap runtime. |
| `snacks.nvim` | Picker, dashboard, terminal, buffer delete, git helpers, toggles, notifications. |
| `which-key.nvim` | Keymap discovery UI. |

## UI

| Plugin | Purpose |
| --- | --- |
| `heirline.nvim` | Custom winbar/status UI. |
| `bufferline.nvim` | Buffer line. |
| `nvim-web-devicons` | File icons. |
| `dashboard` via `snacks.nvim` | Startup dashboard. |

## LSP And Completion

| Plugin | Purpose |
| --- | --- |
| `nvim-lspconfig` | Server definitions used by native `vim.lsp.config()`. |
| `mason.nvim` | Installs LSP servers and CLI tools. |
| `mason-lspconfig.nvim` | Bridges Mason package names to LSP config names. |
| `blink.cmp` | Completion engine. |
| `fidget.nvim` | LSP progress notifications. |

## Treesitter And Editing

| Plugin | Purpose |
| --- | --- |
| `nvim-treesitter` | Parser installation and queries; features are enabled by local FileType autocmds. |
| `nvim-treesitter-textobjects` | Function/class/parameter movement. |
| `mini.ai` | Text objects. |
| `mini.pairs` | Pair insertion. |
| `indent-blankline.nvim` | Indent guides. |

## Navigation And Search

| Plugin | Purpose |
| --- | --- |
| `telescope.nvim` | Telescope commands and yank history picker integration. |
| `telescope-fzf-native.nvim` | Native fzf sorter for Telescope. |
| `plenary.nvim` | Telescope dependency. |
| `flash.nvim` | Fast jump/search motions. |
| `nvim-hlslens` | Search result lens/highlight integration. |
| `neo-tree.nvim` | Tree file explorer. |
| `oil.nvim` | Directory-as-buffer file editing. |
| `grug-far.nvim` | Project and file search/replace. |
| `aerial.nvim` | Symbol outline. |

## Git

| Plugin | Purpose |
| --- | --- |
| `gitsigns.nvim` | Git signs, hunk actions, blame, and diff helpers. |
| `diffview.nvim` | Git diff and file history views. |

## Sessions And Tools

| Plugin | Purpose |
| --- | --- |
| `auto-session` | Session save and restore. |
| `yanky.nvim` | Yank history and enhanced paste. |
| `sqlite.lua` | Persistent yank history storage. |
| `ccc.nvim` | Color picker. |
| `vim-visual-multi` | Multiple cursors. |
| `nui.nvim` | UI component dependency. |
| `VimQuest.nvim` | Local learning/game plugin loaded from this config. |

## Local Policy

- No `LazyVim/LazyVim` import is used.
- LazyVim-style keymaps that are still wanted live in `lua/config/keymaps-lazyvim.lua`.
- Personal keymaps live in `lua/config/keymaps.lua` and load last.
