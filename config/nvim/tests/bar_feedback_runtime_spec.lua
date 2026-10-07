-- Run from repository root: nvim --headless -u NONE -l config/nvim/tests/bar_feedback_runtime_spec.lua
vim.opt.rtp:prepend(vim.fn.getcwd() .. '/config/nvim')
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/heirline.nvim')
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/bufferline.nvim')
vim.opt.rtp:prepend(vim.fn.stdpath('data') .. '/lazy/nvim-web-devicons')
package.path = vim.fn.getcwd() .. '/config/nvim/lua/?.lua;' .. package.path
require('config.ui_highlights').apply()
local spec = dofile('config/nvim/lua/plugins/heirline.lua')[1]
local h = require('heirline')
h.setup(spec.opts())
h.eval_statusline()
assert(_G.heirline_encoding_menu)
_G.heirline_encoding_menu(0, 1, 'r', '')
local function find(c, name)
  if c.on_click and c.on_click.name == name then return c end
  for _, child in ipairs(c) do local result = find(child,name); if result then return result end end
end
local c = find(h.statusline,'heirline_encoding_menu')
assert(c._pressed, 'actual callback must set pressed')
assert(c.hl(c).bg, 'press must paint background')
assert(c.provider():match('^ UTF%-8 $'), 'encoding must have one cell padding')
h.eval_statusline()
vim.wait(300)
assert(not c._pressed, 'pulse must clear')
local b = dofile('config/nvim/lua/plugins/bufferline.lua')[1]
b.config(nil,b.opts())
vim.cmd('file feedback.lua')
local line = _G.nvim_bufferline()
require('config.bar_feedback').press('___bufferline_private.handle_click',vim.api.nvim_get_current_buf())
local pressed = _G.nvim_bufferline()
assert(pressed:find('BarPressed'), 'tab must visibly change')
assert(line ~= pressed)
local feedback=require('config.bar_feedback')
local breadcrumb='%1@v:lua.contextline_click@ %#WinBar# test %* %X'
assert(feedback.paint(breadcrumb,'contextline_click:1','WinBar'):find('BarPressedWinBar'))
-- Popup positioning must see the original marker at the padded chip edge.
local aligned = feedback.paint('prefix %2@v:lua.contextline_click@%#ContextlineActiveMenu# symbol %X',
  'contextline_click:2', 'WinBar')
local evaluated = vim.api.nvim_eval_statusline(aligned, { use_winbar = true, highlights = true })
local anchor
for _, item in ipairs(evaluated.highlights) do
  for _, group in ipairs(item.groups or { item.group }) do
    if group == 'ContextlineActiveMenu' then anchor = anchor or item.start end
  end
end
assert(anchor == #'prefix ', 'menu anchor must include the left padding')
print('bar click runtime: OK')
vim.cmd('qa!')
