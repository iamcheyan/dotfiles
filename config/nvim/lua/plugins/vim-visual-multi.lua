local function insert_ctrl_n()
  local vm = vim.g.Vm
  local vm_active = type(vm) == "table" and (tonumber(vm.buffer) or 0) > 0
  local extending = vm_active and tonumber(vm.extend_mode) == 1
  local at_line_end = vim.fn.col(".") == vim.fn.col("$")
  local action = extending and "VM-Select-Cursor-Down" or "VM-Add-Cursor-Down"
  local keys = "<C-o><Plug>(" .. action .. ")"

  if at_line_end and not extending then
    keys = keys .. "<Plug>(VM-I-End)"
  end

  return keys
end

return {
  {
    "mg979/vim-visual-multi",
    branch = "master",
    keys = {
      { "<C-n>", "<Plug>(VM-Find-Under)", mode = { "n", "v" }, desc = "VM: Find Under" },
      { "<C-n>", insert_ctrl_n, mode = "i", expr = true, desc = "VM: Add or extend cursor down" },
      { "<C-j>", "<Plug>(VM-Add-Cursor-Down)", mode = "n", desc = "VM: Add Cursor Down" },
      { "<C-k>", "<Plug>(VM-Add-Cursor-Up)", mode = "n", desc = "VM: Add Cursor Up" },
    },
  },
}
