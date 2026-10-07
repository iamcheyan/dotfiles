-- One document surface for dialogs, terminal floats, and plugin popups.
local M = {}
function M.apply()
  local normal = vim.api.nvim_get_hl(0, { name = 'Normal', link = false })
  vim.api.nvim_set_hl(0, 'UnifiedFloat', { fg = normal.fg, bg = normal.bg })
  vim.api.nvim_set_hl(0, 'UnifiedFloatBorder', { fg = '#ffffff', bg = normal.bg })
  vim.api.nvim_set_hl(0, 'UnifiedFloatBackdrop', { bg = '#000000', blend = 80 })
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
    -- Snacks supplies its own backdrop. Small completion/tooltip windows stay
    -- attached to the editor without dimming it on every keystroke.
    if not ft:match('^snacks') and not ft:match('^blink') and not ft:match('^cmp')
      and (config.width or 0) >= 24 and (config.height or 0) >= 3 then
      local shade_buf = vim.api.nvim_create_buf(false, true)
      vim.bo[shade_buf].bufhidden = 'wipe'
      local shade = open(shade_buf, false, { relative = 'editor', row = 0, col = 0,
        width = vim.o.columns, height = math.max(1, vim.o.lines - vim.o.cmdheight - 1),
        focusable = false, style = 'minimal', border = 'none',
        zindex = math.max(1, (config.zindex or 50) - 1), })
      vim.wo[shade].winblend = 80
      vim.wo[shade].winhighlight = 'Normal:UnifiedFloatBackdrop,NormalNC:UnifiedFloatBackdrop'
      vim.api.nvim_create_autocmd('WinClosed', { pattern = tostring(win), once = true,
        callback = function()
          if vim.api.nvim_win_is_valid(shade) then vim.api.nvim_win_close(shade, true) end
        end })
    end
    return win
  end
  local group = vim.api.nvim_create_augroup('UnifiedFloatStyle', { clear = true })
  vim.api.nvim_create_autocmd('ColorScheme', { group = group, callback = function() vim.schedule(M.apply) end })
  M.apply()
end
return M
