# translator-panel.nvim

A lightweight floating translation panel for Neovim that uses
[Translate Shell](https://github.com/soimort/translate-shell).

## Features

- Toggleable floating panel with live translation.
- Supports translation phonetics (romaji) via Translate Shell.
- Quick copy for translation and source text.
- Switch source/target languages at runtime.

## Requirements

- Neovim 0.8+
- `trans` (Translate Shell) available in `$PATH`

## Installation

Use your preferred plugin manager, for example with lazy.nvim:

```lua
{
  "translator-panel.nvim",
  opts = {},
}
```

## Setup

```lua
require("translator_panel").setup({
  toggle_key = "tj",
  copy_key = "ty",
  copy_source_key = "tY",
  source_lang = "zh",
  target_lang = "ja",
  show_romaji = true,
  trans_command = "trans",
  debounce_ms = 400,
  window = {
    width = 80,
    height = 14,
  },
})
```

## Usage

- `tj`: Toggle the panel.
- `ty`: Copy the translation result.
- `tY`: Copy the source text from the input area.

## Commands

- `:TranslatorPanelSetLang {source} {target}`
- `:TranslatorPanelSetSource {source}`
- `:TranslatorPanelSetTarget {target}`

Examples:

```vim
:TranslatorPanelSetLang zh ja
:TranslatorPanelSetSource auto
:TranslatorPanelSetTarget en
```

## Notes

- Default language pair is Chinese to Japanese (`zh:ja`).
- If you do not want romaji, set `show_romaji = false`.
