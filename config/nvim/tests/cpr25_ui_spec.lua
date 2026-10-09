local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

vim.cmd.colorscheme("blue")
local normal_bg = vim.api.nvim_get_hl(0, { name = "Normal", link = false }).bg
local noice = dofile(nvim_root .. "/lua/plugins/noice.lua")[1].opts
local command_format = noice.cmdline.format.cmdline
assert(command_format and command_format.icon == "" and command_format.conceal == false,
  "Ex command line should show Neovim's native ':' prompt without Noice's '>' icon")

dofile(nvim_root .. "/lua/config/autocmds.lua")
for _, name in ipairs({ "MsgArea", "Cmdline", "CmdLine", "CmdLinePrompt" }) do
  local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
  assert(hl.bg == normal_bg, name .. " should blend with the active Blue editor background")
end

local ui = require("config.ui_highlights")
ui.apply()
local menu_bg = vim.api.nvim_get_hl(0, { name = "BlinkCmpMenu", link = false }).bg
local kind_bg = vim.api.nvim_get_hl(0, { name = "PmenuKind", link = false }).bg
assert(kind_bg == menu_bg, "completion kind icons should not paint a contrasting background after the icon")

local blink_root = vim.fn.stdpath("data") .. "/lazy/blink.cmp"
if vim.fn.isdirectory(blink_root) == 1 then
  vim.opt.runtimepath:prepend(blink_root)
  local blink = dofile(nvim_root .. "/lua/plugins/blink.lua")[1].opts
  require("blink.cmp.config").merge_with({ appearance = blink.appearance, completion = blink.completion })
  require("blink.cmp.highlights").setup()
  local kind = vim.api.nvim_get_hl(0, { name = "BlinkCmpKindFunction", link = false })
  assert(kind.bg == menu_bg, "Blink function icon background should match the completion menu")
end

local blink = dofile(nvim_root .. "/lua/plugins/blink.lua")[1].opts
assert(blink.completion.menu.draw.gap == 1, "completion item columns should keep a single compact cell gap")
for name, icon in pairs(blink.appearance.kind_icons) do
  assert(not icon:match("%s$"), name .. " icon should not add a second trailing gap")
end

print("cpr25_ui_spec: OK")
