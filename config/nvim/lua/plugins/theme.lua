-- Compatibility entry point for systems where the Omarchy-generated theme
-- symlink is unavailable. The actual fallback-aware implementation lives in
-- plugins/omarchy-theme.lua.
return require("plugins.omarchy-theme")
