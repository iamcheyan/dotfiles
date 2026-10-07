-- AutoSession recovery for deleted records/files and explicit-file launches.
-- Run: nvim --headless -u NONE -l config/nvim/tests/auto_session_recovery_spec.lua
local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

local spec = dofile(nvim_root .. "/lua/plugins/auto-session.lua")[1]
local opts = spec.opts
assert(opts.args_allow_files_auto_save == true, "launching with explicit files should still update the session")
assert(type(opts.auto_create) == "function", "creating a missing session record should ask the user")
assert(type(opts.pre_restore_cmds) == "table" and type(opts.pre_restore_cmds[1]) == "function", "restore should check deleted files before sourcing")
assert(type(opts.restore_error_handler) == "function", "missing-path restore errors need a recovery handler")

local root = vim.fn.tempname()
local session_root = root .. "/sessions"
local missing_dir = root .. "/deleted-project"
vim.fn.mkdir(session_root, "p")
vim.fn.writefile({ "session marker" }, session_root .. "/workspace.vim")
local original_auto = package.loaded["auto-session"]
local original_lib = package.loaded["auto-session.lib"]
local original_confirm = vim.fn.confirm
local original_uis = vim.api.nvim_list_uis
local choice, prompts = 1, 0
vim.fn.confirm = function()
  prompts = prompts + 1
  return choice
end
vim.api.nvim_list_uis = function() return { { chan = 1 } } end
local session_api = {
  get_root_dir = function() return session_root .. "/" end,
  session_exists_for_cwd = function() return false end,
  default_restore_error_handler = function() return false end,
}
local session_lib = {
  escape_session_name = function(name) return name end,
  legacy_escape_session_name = function(name) return name end,
  create_session_summary = function()
    return { cwd = missing_dir, current_buffer = "deleted.cbl", buffers = { { path = "deleted.cbl" } } }
  end,
  resolve_filename_path = function(path, cwd) return cwd .. "/" .. path end,
}
package.loaded["auto-session"] = session_api
package.loaded["auto-session.lib"] = session_lib

choice = 2
assert(opts.pre_restore_cmds[1]("workspace") == false, "Skip should skip a stale session")
assert(vim.fn.isdirectory(missing_dir) == 0, "Skip must not recreate deleted paths")
choice = 1
assert(opts.pre_restore_cmds[1]("workspace") == true, "Create should allow restoring after repairing paths")
assert(vim.fn.isdirectory(missing_dir) == 1, "Create should recreate the missing project directory")
assert(vim.fn.filereadable(missing_dir .. "/deleted.cbl") == 1, "Create should recreate the missing session file")

choice = 1
assert(opts.auto_create() == true, "Create should enable saving a missing session record")
choice = 2
assert(opts.auto_create() == false, "Skip should prevent silent creation of a session record")
local prompts_before_existing = prompts
session_api.session_exists_for_cwd = function() return true end
assert(opts.auto_create() == true and prompts == prompts_before_existing, "an existing session should update without a create prompt")

choice = 1
assert(opts.restore_error_handler("E344: Can't find directory") == true, "Continue should retain autosave after a missing-path restore error")
choice = 2
assert(opts.restore_error_handler("ENOENT: no such file or directory") == false, "Skip should disable saving after aborting recovery")

package.loaded["auto-session"] = original_auto
package.loaded["auto-session.lib"] = original_lib
vim.fn.confirm = original_confirm
vim.api.nvim_list_uis = original_uis
vim.fn.delete(root, "rf")
print("auto_session_recovery_spec: OK")
