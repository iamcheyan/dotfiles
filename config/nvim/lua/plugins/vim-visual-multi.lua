local last_linewise_mode = nil

vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    last_linewise_mode = nil
  end,
})

local function insert_ctrl_n()
  local vm = vim.g.Vm
  local vm_active = type(vm) == "table" and (tonumber(vm.buffer) or 0) > 0
  local extending = vm_active and tonumber(vm.extend_mode) == 1

  if not vm_active then
    last_linewise_mode = nil
  end

  local cur_col = vim.fn.col(".")
  local end_col = vim.fn.col("$")
  local at_line_end = (cur_col >= end_col) or (cur_col == end_col - 1 and cur_col > 1)
  local at_line_start = (cur_col <= 1)

  local is_eol_mode = (not extending) and ((not vm_active and at_line_end) or (vm_active and last_linewise_mode == "eol"))
  local is_bol_mode = (not extending) and ((not vm_active and at_line_start) or (vm_active and last_linewise_mode == "bol"))

  if is_eol_mode then
    last_linewise_mode = "eol"
    local total_lines = vim.fn.line("$")

    if not vm_active then
      local cur_line = vim.fn.line(".")
      if cur_line >= total_lines then
        return
      end
      vim.cmd("stopinsert")
      vim.cmd("normal! $")
      vim.fn["vm#commands#add_cursor_at_pos"](0)
      vim.cmd("normal! j$")
      vim.fn["vm#commands#add_cursor_at_pos"](0)
      vim.cmd("call b:VM_Selection.Insert.key('A')")
    else
      if vim.b.VM_Selection and vim.b.VM_Selection.Insert then
        vim.cmd("call b:VM_Selection.Insert.stop()")
      end
      vim.cmd("stopinsert")
      local max_line = 0
      if vim.b.VM_Selection and vim.b.VM_Selection.Regions then
        for _, r in ipairs(vim.b.VM_Selection.Regions) do
          if r.l > max_line then
            max_line = r.l
          end
        end
      else
        max_line = vim.fn.line(".")
      end
      local next_line = max_line + 1
      if next_line <= total_lines then
        vim.api.nvim_win_set_cursor(0, { next_line, 0 })
        vim.cmd("normal! $")
        vim.fn["vm#commands#add_cursor_at_pos"](0)
      end
      vim.cmd("call b:VM_Selection.Insert.key('A')")
    end
    return
  end

  if is_bol_mode then
    last_linewise_mode = "bol"
    local total_lines = vim.fn.line("$")

    if not vm_active then
      local cur_line = vim.fn.line(".")
      if cur_line >= total_lines then
        return
      end
      vim.cmd("stopinsert")
      vim.cmd("normal! 0")
      vim.fn["vm#commands#add_cursor_at_pos"](0)
      vim.cmd("normal! j0")
      vim.fn["vm#commands#add_cursor_at_pos"](0)
      vim.cmd("call b:VM_Selection.Insert.key('i')")
    else
      if vim.b.VM_Selection and vim.b.VM_Selection.Insert then
        vim.cmd("call b:VM_Selection.Insert.stop()")
      end
      vim.cmd("stopinsert")
      local max_line = 0
      if vim.b.VM_Selection and vim.b.VM_Selection.Regions then
        for _, r in ipairs(vim.b.VM_Selection.Regions) do
          if r.l > max_line then
            max_line = r.l
          end
        end
      else
        max_line = vim.fn.line(".")
      end
      local next_line = max_line + 1
      if next_line <= total_lines then
        vim.api.nvim_win_set_cursor(0, { next_line, 0 })
        vim.cmd("normal! 0")
        vim.fn["vm#commands#add_cursor_at_pos"](0)
      end
      vim.cmd("call b:VM_Selection.Insert.key('i')")
    end
    return
  end

  last_linewise_mode = nil
  local action = extending and "VM-Select-Cursor-Down" or "VM-Add-Cursor-Down"
  local keys = vim.api.nvim_replace_termcodes("<C-o><Plug>(" .. action .. ")", true, true, true)
  vim.api.nvim_feedkeys(keys, "n", true)
end

return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    keys = {
      { "<C-n>", "<Plug>(VM-Find-Under)", mode = { "n", "v" }, desc = "VM: Find Under" },
      { "<C-n>", insert_ctrl_n, mode = "i", desc = "VM: Add or extend cursor down" },
      { "<C-j>", "<Plug>(VM-Add-Cursor-Down)", mode = "n", desc = "VM: Add Cursor Down" },
      { "<C-k>", "<Plug>(VM-Add-Cursor-Up)", mode = "n", desc = "VM: Add Cursor Up" },
    },
  },
}
