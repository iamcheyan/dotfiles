-- One document surface for dialogs, terminal floats, and plugin popups.
local M = {}
function M.apply()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  vim.api.nvim_set_hl(0, 'UnifiedFloat', { fg = normal.fg, bg = normal.bg })
  vim.api.nvim_set_hl(0, 'UnifiedFloatBorder', { fg = '#ffffff', bg = normal.bg })
  for _, name in ipairs({ 'NormalFloat', 'SnacksNormal', 'SnacksNormalNC', 'SnacksTerminal', 'SnacksLazygit' }) do
    vim.api.nvim_set_hl(0, name, { link = 'UnifiedFloat' })
  end
  vim.api.nvim_set_hl(0, 'FloatBorder', { link = 'UnifiedFloatBorder' })
  vim.api.nvim_set_hl(0, 'FreshMenu', { link = 'UnifiedFloat' })
  vim.api.nvim_set_hl(0, 'FreshMenuBorder', { link = 'UnifiedFloatBorder' })
  vim.api.nvim_set_hl(0, 'FreshMenuSelected', { link = 'SnacksPickerListCursorLine' })
end
function M.setup()
  if M.installed then return end
  M.installed = true
  local open = vim.api.nvim_open_win
  vim.api.nvim_open_win = function(buf, enter, config)
    local float = config.relative and config.relative ~= '' and not config.external
    local ft = vim.bo[buf].filetype
    local backdrop = float and config.focusable == false and config.border == 'none'
    if float and not backdrop and not ft:match('^snacks_picker') then
      config = vim.tbl_extend('force', {}, config, { border = 'single' })
    end
    local win = open(buf, enter, config)
    if not float or backdrop then return win end
    local mappings = {}
    for mapping in vim.wo[win].winhighlight:gmatch('[^,]+') do
      local from = mapping:match('^([^:]+):')
      if from ~= 'Normal' and from ~= 'NormalNC' and from ~= 'NormalFloat' and from ~= 'FloatBorder' then
        mappings[#mappings + 1] = mapping
      end
    end
    vim.list_extend(mappings, { 'Normal:UnifiedFloat', 'NormalNC:UnifiedFloat',
      'NormalFloat:UnifiedFloat', 'FloatBorder:UnifiedFloatBorder' })
    vim.wo[win].winhighlight = table.concat(mappings, ',')
    return win
  end
  local group = vim.api.nvim_create_augroup('UnifiedFloatStyle', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = function() vim.schedule(M.apply) end })
  M.apply()
end
return M
