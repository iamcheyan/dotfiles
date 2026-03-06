-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Terminal keybindings
vim.keymap.set("n", "<leader>tr", function()
  vim.cmd("vsplit | terminal")
end, { desc = "Terminal Right" })

vim.keymap.set("n", "<leader>tb", function()
  vim.cmd("split | terminal")
end, { desc = "Terminal Bottom" })

-- Muren (Multiple Replacements) keybindings
-- vim.keymap.set("n", "<leader>rr", "<cmd>MurenToggle<cr>", { desc = "Muren: Toggle UI" })
-- vim.keymap.set("n", "<leader>rR", "<cmd>MurenUnique<cr>", { desc = "Muren: Open with unique matches" })

vim.keymap.set("n", "<leader>cf", function()
  vim.fn.setreg("+", vim.fn.expand("%"))
end, { desc = "Copy file (relative path)" })

vim.keymap.set("n", "<leader>cF", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end, { desc = "Copy file (absolute path)" })

vim.keymap.set("n", "<leader>cd", function()
  vim.fn.setreg("+", vim.fn.expand("%:p:h"))
end, { desc = "Copy directory" })

vim.keymap.set("n", "<leader>fC", function()
  require("telescope.builtin").find_files({
    prompt_title = "常用配置文件",
    search_dirs = {
      "~/.dotfiles",
      "~/.config/nvim",
      "${WIN_HOME}/.vscode/extension/sbzr.chrome.extension/chrome-extension/sbzr.yaml", -- 甚至可以精确到具体文件
    },
  })
end, { desc = "打开常用收藏" })

-- grug-far:
-- <leader>sr => project search/replace
-- <leader>sR => current file search/replace
-- visual mode uses selected text as Search
vim.keymap.set("n", "<leader>sr", function()
  require("grug-far").open()
end, { desc = "Search/Replace (project)" })

vim.keymap.set("x", "<leader>sr", function()
  require("grug-far").with_visual_selection()
end, { desc = "Search/Replace selection (project)" })

vim.keymap.set("n", "<leader>sR", function()
  require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search/Replace (current file)" })

vim.keymap.set("x", "<leader>sR", function()
  require("grug-far").with_visual_selection({ prefills = { paths = vim.fn.expand("%") } })
end, { desc = "Search/Replace selection (current file)" })

-- lua/config/keymaps.lua
vim.keymap.set("n", "<leader>d", '"_d', { desc = "Delete to blackhole" })
vim.keymap.set("v", "<leader>d", '"_d', { desc = "Visual delete to blackhole" })

-- Click a diagnostics sign line to open its message float.
vim.keymap.set("n", "<LeftMouse>", function()
  local m = vim.fn.getmousepos()
  if m.winid and m.winid ~= 0 then
    vim.api.nvim_set_current_win(m.winid)
  end
  if m.line and m.line > 0 then
    vim.api.nvim_win_set_cursor(0, { m.line, math.max((m.column or 1) - 1, 0) })
    local diags = vim.diagnostic.get(0, { lnum = m.line - 1 })
    if #diags > 0 then
      vim.diagnostic.open_float(nil, {
        focus = false,
        scope = "line",
        border = "rounded",
        source = "if_many",
      })
    end
  end
end, { desc = "Mouse click line; show diagnostics float when present" })
