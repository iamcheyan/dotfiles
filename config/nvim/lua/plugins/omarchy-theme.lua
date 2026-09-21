-- Omarchy owns the generated theme file.  It is only valid in the Hyprland
-- session; labwc and other compositors must keep the public palette.
local desktop = table.concat({ vim.env.XDG_CURRENT_DESKTOP or "", vim.env.XDG_SESSION_DESKTOP or "" }, ":")
if not desktop:lower():match("hyprland") then
  return {}
end

local theme_file = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

if vim.fn.filereadable(theme_file) == 1 then
  local ok, specs = pcall(dofile, theme_file)
  if ok and type(specs) == "table" then
    return specs
  end
end

return {}
