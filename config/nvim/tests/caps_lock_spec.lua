-- Regression test for Caps Lock detection and state tracking (WSL, Linux, macOS).
-- Run: nvim --headless -u NONE -l config/nvim/tests/caps_lock_spec.lua

local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path
vim.cmd("filetype plugin indent on")
dofile(nvim_root .. "/lua/config/options.lua")
require("config.ui_highlights").apply()

local caps = require("config.caps_lock")

-- 1. State normalization & unknown preservation
caps.reset()
assert(_G._heirline_caps_lock_on == nil, "initial state must be nil (unknown)")
assert(caps.get_state() == nil, "get_state must reflect nil initially")

for _, val in ipairs({ true, "on", "ON", "yes", "YES", "1", "true", "True" }) do
  caps.set_state(val)
  assert(_G._heirline_caps_lock_on == true, "set_state(" .. tostring(val) .. ") must set state to true")
end

for _, val in ipairs({ false, "off", "OFF", "no", "NO", "0", "false", "False" }) do
  caps.set_state(val)
  assert(_G._heirline_caps_lock_on == false, "set_state(" .. tostring(val) .. ") must set state to false")
end

for _, val in ipairs({ nil, "unknown", "invalid", "", 123 }) do
  caps.set_state(val)
  assert(_G._heirline_caps_lock_on == nil, "set_state(" .. tostring(val) .. ") must preserve nil (unknown)")
end

-- 2. Output parser for PowerShell change monitor
caps.reset()
caps.parse_powershell_output("True")
assert(_G._heirline_caps_lock_on == true, "parse_powershell_output('True') must set state to true")

caps.parse_powershell_output("False")
assert(_G._heirline_caps_lock_on == false, "parse_powershell_output('False') must set state to false")

caps.parse_powershell_output("True\r")
assert(_G._heirline_caps_lock_on == true, "parse_powershell_output('True\\r') must strip CRLF and set true")

caps.parse_powershell_output("False\r")
assert(_G._heirline_caps_lock_on == false, "parse_powershell_output('False\\r') must strip CRLF and set false")

-- Blank lines should not alter existing state
caps.parse_powershell_output("")
assert(_G._heirline_caps_lock_on == false, "empty line must not alter state")
caps.parse_powershell_output("   \r\n")
assert(_G._heirline_caps_lock_on == false, "whitespace line must not alter state")

-- 3. WSL environment detection
caps.reset()
-- Current host is Debian VM: should not detect WSL
assert(caps.is_wsl() == false, "Debian VM must not detect as WSL")

-- Test WSL detection via WSL_DISTRO_NAME
caps.reset()
vim.env.WSL_DISTRO_NAME = "Ubuntu-24.04"
assert(caps.is_wsl() == true, "WSL_DISTRO_NAME must trigger WSL detection")
vim.env.WSL_DISTRO_NAME = nil

-- Test WSL detection via WSL_INTEROP
caps.reset()
vim.env.WSL_INTEROP = "/run/WSL/1_interop"
assert(caps.is_wsl() == true, "WSL_INTEROP must trigger WSL detection")
vim.env.WSL_INTEROP = nil

-- Test WSL detection via /proc/version content
local tmp_proc = vim.fn.tempname()
local f = io.open(tmp_proc, "w")
assert(f)
f:write("Linux version 5.15.153.1-microsoft-standard-WSL2 (oe-user@oe-host) (gcc version 11.2.0) #1 SMP Wed Mar 13 06:17:39 UTC 2024\n")
f:close()

caps.reset()
caps._proc_version_path = tmp_proc
assert(caps.is_wsl() == true, "microsoft-standard-WSL2 in /proc/version must trigger WSL detection")

-- Test non-WSL /proc/version
f = io.open(tmp_proc, "w")
assert(f)
f:write("Linux debian 6.12.101+deb13-amd64 #1 SMP PREEMPT_DYNAMIC Debian 6.12.101-1 (2026-08-05) x86_64 GNU/Linux\n")
f:close()

caps.reset()
caps._proc_version_path = tmp_proc
assert(caps.is_wsl() == false, "Debian kernel in /proc/version must not trigger WSL detection")
os.remove(tmp_proc)
caps._proc_version_path = "/proc/version"

-- 4. PowerShell discovery & fallback paths
caps.reset()
caps._executable_finder = function(cmd)
  if cmd == "pwsh.exe" then return 1 end
  return 0
end
assert(caps.get_wsl_powershell_cmd() == "pwsh.exe", "should prefer pwsh.exe when available")

caps.reset()
caps._executable_finder = function(cmd)
  if cmd == "powershell.exe" then return 1 end
  return 0
end
assert(caps.get_wsl_powershell_cmd() == "powershell.exe", "should find powershell.exe in PATH")

caps.reset()
caps._executable_finder = function(cmd)
  if cmd == "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe" then return 1 end
  return 0
end
assert(caps.get_wsl_powershell_cmd() == "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe",
  "should find standard Windows fallback path when appendWindowsPath is disabled")

caps.reset()
caps._executable_finder = function() return 0 end
assert(caps.get_wsl_powershell_cmd() == nil, "should return nil when no PowerShell executable is found")

-- 5. WSL fallback & error preservation (never falsely claim OFF)
caps.reset()
caps._is_wsl_override = true
caps._executable_finder = function() return 0 end
local success = caps.start_wsl_worker()
assert(success == false, "start_wsl_worker must fail when powershell is not found")
assert(_G._heirline_caps_lock_on == nil, "when WSL interop/powershell is unavailable, state must be nil (CAPS ?), NOT false")

-- 6. Zero per-tick process spawning in WSL
caps.reset()
caps._is_wsl_override = true
-- Simulate active running worker
caps._wsl_job_id = 9999
local spawned = 0
caps.start_wsl_worker = function()
  spawned = spawned + 1
  return true
end
-- Multiple refresh ticks while worker is active
caps.refresh()
caps.refresh()
caps.refresh()
assert(spawned == 0, "refresh() must not spawn any job/process while worker is active")

-- 7. Statusline Heirline component rendering
caps.reset()
local heirline_spec = dofile(nvim_root .. "/lua/plugins/heirline.lua")[1]
local statusline_opts = heirline_spec.opts().statusline

local right_info
local function find_right_info(components)
  for _, component in ipairs(components) do
    if type(component) == "table" then
      if #component == 6
        and component[2][2] and component[2][2].on_click and component[2][2].on_click.name == "heirline_fileformat_menu"
        and component[2][3] and component[2][3].on_click and component[2][3].on_click.name == "heirline_encoding_menu"
        and component[3].on_click and component[3].on_click.name == "heirline_lsp_menu"
        and component[4].on_click and component[4].on_click.name == "heirline_nav_menu" then
        right_info = component
        return
      end
      find_right_info(component)
      if right_info then return end
    end
  end
end
find_right_info(statusline_opts)
assert(right_info, "right_info block must be found")

local caps_component = right_info[5]
local mode_component = right_info[6]

-- State: nil -> CAPS ? (accent hl)
caps.set_state(nil)
assert(caps_component[2].provider() == "CAPS ?", "nil state must display 'CAPS ?'")
assert(caps_component.hl() == "FreshStatusLineAccent", "nil state highlight must be accent (not red)")
assert(mode_component.hl({ mode = "n", _pressed = false }) == "FreshStatusLineAccent", "mode segment must be accent when state is nil")

-- State: true -> CAPS ON (red hl)
caps.set_state(true)
assert(caps_component[2].provider() == "CAPS ON", "true state must display 'CAPS ON'")
assert(caps_component.hl() == "FreshStatusLineCaps", "true state highlight must be red (FreshStatusLineCaps)")
assert(mode_component.hl({ mode = "n", _pressed = false }) == "FreshStatusLineCaps", "mode segment must be red when Caps Lock is on")

-- State: false -> CAPS OFF (accent hl)
caps.set_state(false)
assert(caps_component[2].provider() == "CAPS OFF", "false state must display 'CAPS OFF'")
assert(caps_component.hl() == "FreshStatusLineAccent", "false state highlight must be accent (not red)")
assert(mode_component.hl({ mode = "n", _pressed = false }) == "FreshStatusLineAccent", "mode segment must be accent when Caps Lock is off")

caps.reset()
print("caps_lock_spec: OK")
