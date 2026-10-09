-- Run with the real config: nvim --headless -c 'Lazy load heirline.nvim' -c 'luafile config/nvim/tests/git_branch_padding_spec.lua' -c 'qa!'
assert(package.loaded.heirline, "heirline must be loaded from the real config")
local buf = vim.api.nvim_get_current_buf()
vim.b[buf].gitsigns_status_dict = { head = "main", added = 0, changed = 0, removed = 0 }
vim.cmd("redrawstatus")

local rendered = vim.api.nvim_eval_statusline(vim.o.statusline, { winid = 0, highlights = false }).str
local icon = ""
local icon_start = rendered:find(icon, 1, true)
assert(icon_start, "Git branch indicator must render")
local leading = rendered:sub(1, icon_start - 1)
assert(leading == " ", "Git indicator should keep only the global left margin; rendered prefix=" .. string.format("%q", leading))
local branch_start = icon_start + #icon
assert(rendered:sub(branch_start, branch_start) == " ", "Git icon and branch name should keep their readable separator")
assert(rendered:sub(branch_start + 1, branch_start + 4) == "main", "Git branch label should remain visible")
print("git_branch_padding_spec: OK")
