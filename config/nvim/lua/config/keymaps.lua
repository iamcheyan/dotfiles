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
vim.keymap.set("n", "<leader>rr", "<cmd>MurenToggle<cr>", { desc = "Muren: Toggle UI" })
vim.keymap.set("n", "<leader>rR", "<cmd>MurenUnique<cr>", { desc = "Muren: Open with unique matches" })
