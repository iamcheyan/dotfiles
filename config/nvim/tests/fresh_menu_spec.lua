local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.runtimepath:prepend(root)
vim.cmd("colorscheme blue")
local ui = require("config.ui_highlights")
local function hl(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end
local completion = hl("Pmenu")
local selected = hl("PmenuSel")
ui.apply()
require("config.float_style").setup()
local before = {}
for _, name in ipairs({ "Normal", "NormalFloat", "CursorLine", "Visual", "WinBar",
  "StatusLine", "SnacksPickerList", "BlinkCmpDoc" }) do before[name] = hl(name) end
for _ = 1, 3 do ui.apply() end
for name, attrs in pairs(before) do assert(vim.deep_equal(attrs, hl(name)), name .. " changed") end
for _, name in ipairs({ "Pmenu", "FreshMenu", "WhichKeyNormal", "WhichKeyDesc", "WhichKeyIconRed" }) do
  assert(hl(name).fg == hl("Normal").fg and hl(name).bg == hl("Normal").bg, name .. " should share the document blue")
end
assert(hl("PmenuBorder").fg == 0xffffff and hl("PmenuBorder").bg == hl("Normal").bg, "popup border should be white on blue")
assert(hl("FreshMenuSelected").bg == 0x0200ec and hl("FreshMenuSelected").fg == 0xffffff, "only the selected row should use the blue selection color")
assert(vim.deep_equal(hl("PmenuSel"), hl("SnacksPickerListCursorLine")))
assert(vim.deep_equal(completion, hl("BlinkCmpMenu")), "completion surface changed")
assert(vim.deep_equal(selected, hl("BlinkCmpMenuSelection")), "completion selection changed")
vim.cmd("colorscheme blue")
vim.wait(150)
assert(hl("FreshMenu").bg == hl("Normal").bg, "menu style lost after colorscheme reload")
assert(hl("FreshMenuSelected").bg == 0x0200ec, "selected row should retain its blue background after colorscheme reload")
print("fresh_menu_spec: OK")
