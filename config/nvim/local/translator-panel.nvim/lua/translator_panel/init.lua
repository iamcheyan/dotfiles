local config = require("translator_panel.config")
local panel = require("translator_panel.panel")

local M = {}

function M.setup(opts)
  config.setup(opts)

  vim.keymap.set("n", config.options.toggle_key, function()
    panel.toggle()
  end, { desc = "Toggle translator panel" })

  vim.api.nvim_create_user_command("TranslatorPanelSetLang", function(opts)
    if #opts.fargs < 2 then
      vim.notify("Usage: TranslatorPanelSetLang {source} {target}", vim.log.levels.ERROR)
      return
    end
    config.options.source_lang = opts.fargs[1]
    config.options.target_lang = opts.fargs[2]
    panel.refresh()
  end, { nargs = "+", desc = "Set translator panel source/target language" })

  vim.api.nvim_create_user_command("TranslatorPanelSetSource", function(opts)
    if #opts.fargs < 1 then
      vim.notify("Usage: TranslatorPanelSetSource {source}", vim.log.levels.ERROR)
      return
    end
    config.options.source_lang = opts.fargs[1]
    panel.refresh()
  end, { nargs = "+", desc = "Set translator panel source language" })

  vim.api.nvim_create_user_command("TranslatorPanelSetTarget", function(opts)
    if #opts.fargs < 1 then
      vim.notify("Usage: TranslatorPanelSetTarget {target}", vim.log.levels.ERROR)
      return
    end
    config.options.target_lang = opts.fargs[1]
    panel.refresh()
  end, { nargs = "+", desc = "Set translator panel target language" })
end

return M
