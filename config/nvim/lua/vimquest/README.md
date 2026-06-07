# VimQuest.nvim

A Neovim plugin that turns your codebase into an English vocabulary quiz. VimQuest copies code files from your project, injects word puzzles as comments, and lets you practice vocabulary without leaving your editor.

## How It Works

1. VimQuest scans your project and randomly selects code files
2. Copies them to a temporary session directory
3. Injects vocabulary tasks as code comments (fill-in-the-blank, synonym replacement, etc.)
4. You edit the answer lines directly in the code, then check your results
5. After the round, you can start a new round or restore your original project

## Task Types

| Type | Description |
|------|-------------|
| **Fill** | Complete a sentence with the missing English word (given Chinese meaning) |
| **Replace** | Replace a synonym back to the core word |
| **Delete** | Remove the redundant word from a sentence |
| **Meaning** | Type the English word from its Chinese definition |
| **Japanese Meaning** | Type the English word from its Japanese definition |
| **Example Translation** | Guess the word from a Japanese example sentence |

## Installation

### lazy.nvim

```lua
{
  dir = vim.fn.stdpath("config"),
  name = "VimQuest.nvim",
  lazy = false,
  config = function()
    require("vimquest").setup()
  end,
}
```

## Usage

### Commands

| Command | Description |
|---------|-------------|
| `:VimQuestStart` | Start a new quiz round |
| `:VimQuestStop` | Stop and restore the original project |
| `:VimQuestNext` | Jump to the next task |
| `:VimQuestCheck` | Check all answers and show results |
| `:VimQuestHint` | Show hint for the task at cursor |
| `:VimQuestStats` | Show current round statistics |

### Keymaps (default)

| Key | Action |
|-----|--------|
| `<leader>qs` | Start |
| `<leader>qx` | Stop |
| `<leader>qn` | Next task |
| `<leader>qc` | Check answers |
| `<leader>qh` | Show hint |
| `<leader>qt` | Show stats |
| `K` | Show hint (when in active session) or LSP hover |

## Configuration

```lua
require("vimquest").setup({
  task_count = 10,          -- number of tasks per round
  copy_file_count = 10,     -- number of files to copy
  wordlist = "lua/vimquest/data/ogden-850-words.json",
  exclude_dirs = {          -- directories to skip
    [".git"] = true,
    ["node_modules"] = true,
  },
  code_extensions = {       -- file extensions to include
    lua = true, js = true, ts = true, py = true,
    -- ... see defaults for full list
  },
})
```

## Word List

The default word list is based on Ogden's Basic English (850 words), with Chinese and Japanese translations, example sentences, synonyms, and core meanings.

## Requirements

- Neovim >= 0.8
