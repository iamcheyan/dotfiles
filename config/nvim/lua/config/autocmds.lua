-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Keep LazyVim default startup behavior:
-- restore session when available; otherwise show dashboard.

local function set_cmdline_highlights()
  local bg = "#2a2a2a"
  local fg = "#d6d6d6"

  vim.api.nvim_set_hl(0, "MsgArea", { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, "Cmdline", { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, "CmdLine", { bg = bg, fg = fg })
  vim.api.nvim_set_hl(0, "CmdLinePrompt", { bg = bg, fg = "#f0f0f0", bold = true })
  vim.api.nvim_set_hl(0, "WinSeparator", { fg = bg, bg = "NONE" })
  vim.api.nvim_set_hl(0, "VertSplit", { fg = bg, bg = "NONE" })
end

vim.api.nvim_create_autocmd("ColorScheme", {
  callback = set_cmdline_highlights,
})

set_cmdline_highlights()
