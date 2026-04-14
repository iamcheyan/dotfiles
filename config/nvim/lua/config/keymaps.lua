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
      -- vim.env.SBZR_CHROME_RIME_YAML, -- 甚至可以精确到具体文件
    },
  })
end, { desc = "打开常用收藏" })

vim.keymap.set("n", "<leader>fo", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "format this file" })

vim.keymap.set("n", "<leader>aa", "ggVG", { desc = "CLRT A" })
vim.keymap.set("n", "<leader>ac", function()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "" })
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end, { desc = "清空文档(不进寄存器)" })

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
vim.keymap.set("x", "<leader>ad", '"_d', { desc = "删除选中(不进寄存器)" })

vim.keymap.set("n", "<2-LeftMouse>", function()
  local m = vim.fn.getmousepos()
  if m.winid and m.winid ~= 0 then
    vim.api.nvim_set_current_win(m.winid)
  end
  if not (m.line and m.line > 0) then
    return
  end

  local col = math.max((m.column or 1) - 1, 0)
  vim.api.nvim_win_set_cursor(0, { m.line, col })

  local line = vim.api.nvim_get_current_line()
  local cursor_col = vim.api.nvim_win_get_cursor(0)[2] + 1
  local color_found = false

  for s in line:gmatch("()#%x%x%x%x%x%x") do
    local e = s + 6
    if cursor_col >= s and cursor_col <= e then
      color_found = true
      break
    end
  end

  if not color_found then
    for s in line:gmatch("()#%x%x%x") do
      local e = s + 3
      if cursor_col >= s and cursor_col <= e then
        color_found = true
        break
      end
    end
  end

  if color_found then
    vim.cmd("CccPick")
  end
end, { desc = "双击颜色弹出 ccc 取色器" })

-- Click a diagnostics sign line to open its message float.
vim.keymap.set("n", "<LeftMouse>", function()
  local m = vim.fn.getmousepos()
  -- Keep default single-click behavior for tabline/statusline, etc.
  if not (m.winid and m.winid ~= 0 and m.line and m.line > 0) then
    vim.api.nvim_feedkeys(vim.keycode("<LeftMouse>"), "n", false)
    return
  end

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
