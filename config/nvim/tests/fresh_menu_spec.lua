local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":h:h")
vim.opt.runtimepath:prepend(root)
vim.cmd("colorscheme blue")
local ui = require("config.ui_highlights")
local function hl(name) return vim.api.nvim_get_hl(0, { name = name, link = false }) end
local completion = hl("Pmenu")
local selected = hl("PmenuSel")
ui.apply()
local before = {}
for _, name in ipairs({ "Normal", "NormalFloat", "CursorLine", "Visual", "WinBar",
  "StatusLine", "SnacksPickerList", "BlinkCmpDoc" }) do before[name] = hl(name) end
for _ = 1, 3 do ui.apply_menu_highlights(); ui.apply_completion_highlights(); ui.apply_picker_highlights() end
for name, attrs in pairs(before) do assert(vim.deep_equal(attrs, hl(name)), name .. " changed") end
for _, name in ipairs({ "Pmenu", "FreshMenu", "WhichKeyNormal", "WhichKeyDesc", "WhichKeyIconRed" }) do
  assert(hl(name).fg == 0 and hl(name).bg == 0xaaaaaa, name .. " should use grey and black")
end
assert(hl("PmenuSel").fg == 0xffffff and hl("PmenuSel").bg == 0x00aa00)
assert(vim.deep_equal(completion, hl("BlinkCmpMenu")), "completion surface changed")
assert(vim.deep_equal(selected, hl("BlinkCmpMenuSelection")), "completion selection changed")
vim.cmd("colorscheme blue")
vim.wait(150)
assert(hl("FreshMenu").bg == 0xaaaaaa, "menu style lost after colorscheme reload")
print("fresh_menu_spec: OK")
