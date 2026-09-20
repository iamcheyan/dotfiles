-- Personal keymaps. Loaded after keymaps-lazyvim.lua so these mappings win
-- when they intentionally reuse the same lhs.

-- Terminal keybindings
vim.keymap.set("n", "<leader>tr", function()
  vim.cmd("vsplit | terminal")
end, { desc = "Terminal Right" })

vim.keymap.set("n", "<leader>tb", function()
  vim.cmd("split | terminal")
end, { desc = "Terminal Bottom" })

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
      "~/dotfiles",
      "~/.config/nvim",
      -- vim.env.SBZR_CHROME_RIME_YAML, -- 甚至可以精确到具体文件
    },
  })
end, { desc = "打开常用收藏" })

vim.keymap.set("n", "<leader>fo", function()
  vim.lsp.buf.format({ async = true })
end, { desc = "format this file" })

vim.keymap.set("n", "<leader>fu", function()
  local file = vim.fn.expand("%:p")
  if file ~= "" then
    vim.fn.system({ "dos2unix", file })
    vim.notify("dos2unix: " .. vim.fn.fnamemodify(file, ":t"))
  end
end, { desc = "dos2unix current file" })

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

-- 添加到 <leader><tab> 菜单中
-- <leader><tab><tab> - 列出所有 Tab Pages 并选择切换（类似 buffer 切换）
vim.keymap.set("n", "<leader><tab><tab>", function()
  local tabs = vim.api.nvim_list_tabpages()
  local current_tab = vim.api.nvim_get_current_tabpage()
  local items = {}

  for i, tab in ipairs(tabs) do
    local windows = vim.api.nvim_tabpage_list_wins(tab)
    local buf_names = {}
    for _, win in ipairs(windows) do
      local buf = vim.api.nvim_win_get_buf(win)
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then
        table.insert(buf_names, vim.fn.fnamemodify(name, ":t"))
      end
    end
    local label = #buf_names > 0 and table.concat(buf_names, ", ") or "[empty]"
    local marker = tab == current_tab and "● " or "  "
    table.insert(items, string.format("%s%d: %s", marker, i, label))
  end

  vim.ui.select(items, {
    prompt = "Select Tab Page:",
  }, function(_, idx)
    if idx then
      vim.cmd("tabnext " .. idx)
    end
  end)
end, { desc = "List and switch Tab Pages" })

-- <leader><tab><tab> 用于 tab 列表；新建 Tab 改用 n
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnew<cr>", { desc = "New Tab" })

-- 鼠标选中文本自动复制到系统剪贴板 (Copy on select)
vim.keymap.set({ "x", "s" }, "<LeftRelease>", '"+ygv', { desc = "Auto-copy selection to clipboard", silent = true })

-- =======================================================================
-- 现代编辑器操作流 (AI 协作 / 网页交互友好，兼顾 Vim 模态特性)
-- =======================================================================

-- 1. Ctrl + A: 全选整个文件 (Normal / Visual / Insert 模式均生效)
vim.keymap.set({ "n", "x" }, "<C-a>", "ggVG", { desc = "Select all lines" })
vim.keymap.set("i", "<C-a>", "<Esc>ggVG", { desc = "Select all lines" })
-- 若偶尔需要给光标处数字加 1，保留备用快捷键
vim.keymap.set("n", "<leader>a", "<C-a>", { desc = "Increment number" })

-- 2. Ctrl + C: 仅在可视模式下生效，复制选区到系统剪贴板 (普通模式保留原生中断/取消)
vim.keymap.set("x", "<C-c>", '"+y', { desc = "Copy selection to system clipboard" })

-- 3. 覆盖粘贴绝不冲掉剪贴板 (从 AI 复制之后，在 Vim 选中文本直接粘贴覆盖，剪贴板内容不变)
vim.keymap.set("x", "p", 'P', { desc = "Paste over selection without clobbering clipboard" })
vim.keymap.set("x", "<C-v>", 'P', { desc = "Paste over selection from clipboard" })

-- 4. 插入模式下 Ctrl + V: 从系统剪贴板原样粘贴 (保留缩进格式，避免自动缩进导致阶梯错位)
vim.keymap.set("i", "<C-v>", "<C-r><C-o>+", { desc = "Paste from system clipboard verbatim" })
