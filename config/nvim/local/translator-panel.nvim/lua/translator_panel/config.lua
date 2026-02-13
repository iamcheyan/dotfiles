local M = {}

M.defaults = {
  toggle_key = "tj",
  copy_key = "ty",
  copy_source_key = "tY",
  source_lang = "zh",
  target_lang = "ja",
  trans_command = "trans",
  show_romaji = true,
  debounce_ms = 400,
  window = {
    width = 80,
    height = 14,
  },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  M.options = vim.tbl_deep_extend("force", vim.deepcopy(M.defaults), opts or {})
end

return M
