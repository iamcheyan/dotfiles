-- LazyVim default `<leader>` keymaps, ported to our pure lazy.nvim setup.
-- These were previously injected by LazyVim itself (lazyvim/config/keymaps.lua
-- and the various plugin specs); removing LazyVim dropped them. Wired to the
-- pickers/plugins we actually use:
--   * snacks.nvim picker  -> find / grep / buffers / recent / help / treesitter
--   * gitsigns.nvim       -> <leader>g* (see plugins/gitsigns.lua)
--   * vim builtins        -> windows / splits / UI / quit / new file / terminal
-- Your own custom keymaps live in config/keymaps.lua and are untouched.

local map = vim.keymap.set

------------------- Find / Search -------------------------------------------
map("n", "<leader><space>", function() Snacks.picker.pick("files") end, { desc = "Find Files (Root Dir)" })
map("n", "<leader>ff", function() Snacks.picker.pick("files") end, { desc = "Find Files" })
map("n", "<leader>fF", function()
  local root = vim.fs.root(0, ".git")
  Snacks.picker.pick("files", { dirs = { root or vim.uv.cwd() } })
end, { desc = "Find Files (Git Root)" })
map("n", "<leader>fb", function() Snacks.picker.pick("buffers") end, { desc = "Buffers" })
map("n", "<leader>fr", function() Snacks.picker.pick("recent") end, { desc = "Recent" })
map("n", "<leader>fR", function() Snacks.picker.resume() end, { desc = "Resume" })
map("n", "<leader>fg", function() Snacks.picker.pick("grep") end, { desc = "Grep" })
map("n", "<leader>fG", function() Snacks.picker.pick("grep") end, { desc = "Grep (Root Dir)" })
map("n", "<leader>fw", function() Snacks.picker.pick("grep", { search = vim.fn.expand("<cword>") }) end, { desc = "Grep Word (cwd)" })
map("n", "<leader>fW", function() Snacks.picker.pick("grep", { search = vim.fn.expand("<cword>") }) end, { desc = "Grep Word (Root)" })
map("n", "<leader>fc", function() Snacks.picker.pick("grep", { search = vim.fn.expand("<cword>") }) end, { desc = "Word under Cursor" })
map("n", "<leader>fh", function() Snacks.picker.pick("help") end, { desc = "Help Pages" })
map("n", "<leader>fS", function() Snacks.picker.pick("treesitter") end, { desc = "Treesitter Symbols" })
map("n", "<leader>/", function() Snacks.picker.pick("grep") end, { desc = "Grep" })
map("n", "<leader>,", function() Snacks.picker.pick("buffers") end, { desc = "Switch Buffer" })
map("n", "<leader>?", function() Snacks.picker.pick("help") end, { desc = "Help" })

------------------- Buffers ---------------------------------------------------
map("n", "<leader>bb", function() Snacks.picker.pick("buffers") end, { desc = "Switch Buffer" })
map("n", "<leader>bd", "<cmd>bdelete<cr>", { desc = "Delete Buffer" })
map("n", "<leader>bD", "<cmd>bdelete!<cr>", { desc = "Delete Buffer (Force)" })
map("n", "<leader>bo", function()
  local cur = vim.api.nvim_get_current_buf()
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= cur and vim.api.nvim_buf_is_loaded(b) and vim.bo[b].buftype == "" then
      vim.api.nvim_buf_delete(b, {})
    end
  end
end, { desc = "Close Other Buffers" })
map("n", "<leader>bl", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bh", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })
map("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next Buffer" })
map("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Prev Buffer" })

------------------- Windows / Splits ----------------------------------------
map("n", "<leader>w|", "<cmd>vsplit<cr>", { desc = "Split Right" })
map("n", "<leader>w-", "<cmd>split<cr>", { desc = "Split Below" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Delete Window" })
map("n", "<leader>w=", "<cmd>wincmd =<cr>", { desc = "Equal Width" })
map("n", "<leader>wm", "<cmd>wincmd _<cr><cmd>wincmd |<cr>", { desc = "Maximize" })
map("n", "<leader>ww", "<c-w><c-w>", { desc = "Other Window" })
map("n", "<leader>wh", "<c-w>h", { desc = "Window Left" })
map("n", "<leader>wj", "<c-w>j", { desc = "Window Down" })
map("n", "<leader>wk", "<c-w>k", { desc = "Window Up" })
map("n", "<leader>wl", "<c-w>l", { desc = "Window Right" })
map("n", "<leader>wH", "<c-w>H", { desc = "Move Window Left" })
map("n", "<leader>wJ", "<c-w>J", { desc = "Move Window Down" })
map("n", "<leader>wK", "<c-w>K", { desc = "Move Window Up" })
map("n", "<leader>wL", "<c-w>L", { desc = "Move Window Right" })
map("n", "<leader>s|", "<cmd>vsplit<cr>", { desc = "Split Right" })
map("n", "<leader>s-", "<cmd>split<cr>", { desc = "Split Below" })

------------------- UI toggles (<leader>u) -----------------------------------
map("n", "<leader>un", function() vim.opt.number = not vim.opt.number:get() end, { desc = "Line Numbers" })
map("n", "<leader>uw", function() vim.opt.wrap = not vim.opt.wrap:get() end, { desc = "Wrap" })
map("n", "<leader>us", function() vim.opt.spell = not vim.opt.spell:get() end, { desc = "Spelling" })
map("n", "<leader>uh", function() vim.opt.hlsearch = not vim.opt.hlsearch:get() end, { desc = "Search Highlight" })
map("n", "<leader>uc", function() vim.opt.conceallevel = vim.opt.conceallevel:get() == 0 and 2 or 0 end, { desc = "Conceal" })
map("n", "<leader>ul", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>uL", "<cmd>copen<cr>", { desc = "Quickfix List" })
map("n", "<leader>ud", function() vim.diagnostic.enable(not vim.diagnostic.is_enabled()) end, { desc = "Diagnostics" })
map("n", "<leader>uz", function() pcall(Snacks.zen.zoom) end, { desc = "Zen Mode" })
map("n", "<leader>uT", function() vim.opt.showtabline = vim.opt.showtabline:get() == 0 and 2 or 0 end, { desc = "Tabline" })

------------------- Quit / Files / Terminal ---------------------------------
map("n", "<leader>q", "<cmd>qa<cr>", { desc = "Quit All" })
map("n", "<leader>qq", "<cmd>qa!<cr>", { desc = "Quit All (Force)" })
map("n", "<leader>fn", function()
  vim.ui.input({ prompt = "New File: ", completion = "file" }, function(input)
    if input and #input > 0 then
      vim.cmd("edit " .. vim.fn.fnameescape(input))
    end
  end)
end, { desc = "New File" })
map("n", "<c-/>", function() pcall(Snacks.terminal.toggle) end, { desc = "Terminal (Toggle)" })
