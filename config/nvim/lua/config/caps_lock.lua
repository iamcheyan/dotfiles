local M = {}

-- Global Caps Lock state used by Heirline statusline:
--   true  -> Caps Lock is ON  (displays "CAPS ON", red highlight)
--   false -> Caps Lock is OFF (displays "CAPS OFF", accent highlight)
--   nil   -> Unknown / unavailable / error (displays "CAPS ?", accent highlight)

M._wsl_job_id = nil
M._wsl_job_failed_at = 0
M._linux_job_in_flight = false
M._timer = nil
M._is_wsl_cached = nil

-- Test hooks:
M._proc_version_path = "/proc/version"
M._is_wsl_override = nil
M._executable_finder = nil

local function is_executable(cmd)
  if M._executable_finder then
    return M._executable_finder(cmd)
  end
  return vim.fn.executable(cmd)
end

--- Detect whether Neovim is running inside WSL (Windows Subsystem for Linux).
--- Evaluates has("wsl"), WSL environment variables, and /proc/version.
---@return boolean
function M.is_wsl()
  if M._is_wsl_override ~= nil then
    return M._is_wsl_override
  end
  if M._is_wsl_cached ~= nil then
    return M._is_wsl_cached
  end

  local result = false
  if vim.fn.has("wsl") == 1 then
    result = true
  elseif vim.env.WSL_DISTRO_NAME and vim.env.WSL_DISTRO_NAME ~= "" then
    result = true
  elseif vim.env.WSL_INTEROP and vim.env.WSL_INTEROP ~= "" then
    result = true
  else
    local f = io.open(M._proc_version_path, "r")
    if f then
      local content = f:read("*a")
      f:close()
      if content and (content:find("[Mm]icrosoft") or content:find("WSL")) then
        result = true
      end
    end
  end

  M._is_wsl_cached = result
  return result
end

--- Find a usable Windows PowerShell executable when running in WSL.
--- Resolves pwsh.exe / powershell.exe from PATH, or standard Windows mount paths
--- if appendWindowsPath is disabled in /etc/wsl.conf.
---@return string|nil
function M.get_wsl_powershell_cmd()
  if is_executable("pwsh.exe") == 1 then
    return "pwsh.exe"
  end
  if is_executable("powershell.exe") == 1 then
    return "powershell.exe"
  end

  local standard_paths = {
    "/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe",
    "/mnt/c/Program Files/PowerShell/7/pwsh.exe",
  }
  for _, path in ipairs(standard_paths) do
    if is_executable(path) == 1 then
      return path
    end
  end

  return nil
end

--- Update global Caps Lock state and request statusline redraw if changed.
--- Preserves unknown/error state as nil ("CAPS ?") rather than falsely reporting OFF.
---@param state boolean|string|nil
function M.set_state(state)
  local locked = nil
  if type(state) == "boolean" then
    locked = state
  elseif type(state) == "string" then
    local lower = state:lower()
    if lower == "yes" or lower == "1" or lower == "on" or lower == "true" then
      locked = true
    elseif lower == "no" or lower == "0" or lower == "off" or lower == "false" then
      locked = false
    else
      locked = nil
    end
  else
    locked = nil
  end

  if _G._heirline_caps_lock_on ~= locked then
    _G._heirline_caps_lock_on = locked
    pcall(vim.cmd, "redrawstatus")
  end
end

--- Return current Caps Lock state: true (ON), false (OFF), or nil (unknown).
---@return boolean|nil
function M.get_state()
  return _G._heirline_caps_lock_on
end

--- Parse output line from PowerShell change-detection loop.
---@param line string
function M.parse_powershell_output(line)
  local trimmed = vim.trim(line)
  if trimmed == "" then
    return
  end
  local lower = trimmed:lower()
  if lower == "true" then
    M.set_state(true)
  elseif lower == "false" then
    M.set_state(false)
  end
end

--- Start persistent background PowerShell worker for WSL/Windows.
--- Uses an in-process change-detection loop to avoid expensive per-tick
--- process spawning across the WSL interop boundary.
---@return boolean success
function M.start_wsl_worker()
  if M._wsl_job_id and M._wsl_job_id > 0 then
    return true
  end

  local now = vim.uv.now()
  if now - M._wsl_job_failed_at < 5000 then
    return false
  end

  local ps_cmd = M.get_wsl_powershell_cmd()
  if not ps_cmd then
    -- Detection unavailable (WSL interop disabled or powershell.exe missing):
    -- preserve unknown state ("CAPS ?") rather than falsely reporting OFF.
    M.set_state(nil)
    return false
  end

  -- Query [Console]::CapsLock in a low-overhead loop; write only on state changes.
  local script = "$last=$null; while($true){ try{ $c=[Console]::CapsLock; if($c -ne $last){ $last=$c; [Console]::Out.WriteLine($c); [Console]::Out.Flush() } }catch{ break }; Start-Sleep -Milliseconds 250 }"

  local job = vim.fn.jobstart({
    ps_cmd,
    "-NoProfile",
    "-NonInteractive",
    "-Command",
    script,
  }, {
    stdout_buffered = false,
    on_stdout = function(_, data)
      if not data then return end
      for _, line in ipairs(data) do
        M.parse_powershell_output(line)
      end
    end,
    on_stderr = function(_, _) end,
    on_exit = function(_, code)
      M._wsl_job_id = nil
      if code ~= 0 then
        M._wsl_job_failed_at = vim.uv.now()
        M.set_state(nil)
      end
    end,
  })

  if job <= 0 then
    M._wsl_job_id = nil
    M._wsl_job_failed_at = now
    M.set_state(nil)
    return false
  end

  M._wsl_job_id = job
  return true
end

--- Stop persistent background worker.
function M.stop_wsl_worker()
  if M._wsl_job_id and M._wsl_job_id > 0 then
    pcall(vim.fn.jobstop, M._wsl_job_id)
    M._wsl_job_id = nil
  end
end

--- Query Caps Lock on macOS asynchronously via ioreg.
function M.refresh_macos()
  if vim.g.heirline_caps_job then return end
  vim.g.heirline_caps_job = true
  local result = {}
  local job = vim.fn.jobstart({
    "sh", "-c",
    [=[ioreg -l -w 0 -c IOHIDKeyboard | sed -n 's/.*"HIDCapsLockState"[[:space:]]*=[[:space:]]*\([^,}]*\).*/\1/p']=],
  }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      result = data or {}
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        vim.g.heirline_caps_job = false
        if code == 0 then
          local saw_state, locked = false, false
          for _, value in ipairs(result) do
            local state = value:lower()
            if state == "yes" or state == "1" then
              saw_state, locked = true, true
            elseif state == "no" or state == "0" then
              saw_state = true
            end
          end
          if saw_state then
            M.set_state(locked and "on" or "off")
          else
            M.set_state(nil)
          end
        else
          M.set_state(nil)
        end
      end)
    end,
  })
  if job <= 0 then
    vim.g.heirline_caps_job = false
    M.set_state(nil)
  end
end

--- Query Caps Lock on native Linux (X11 / XWayland) asynchronously via xset.
function M.refresh_linux_x11()
  if M._linux_job_in_flight then return end

  if is_executable("xset") ~= 1 or not vim.env.DISPLAY or vim.env.DISPLAY == "" then
    M.set_state(nil)
    return
  end

  M._linux_job_in_flight = true
  local result = {}
  local job = vim.fn.jobstart({ "xset", "-q" }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      result = data or {}
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        M._linux_job_in_flight = false
        if code == 0 then
          local output = table.concat(result, "\n")
          local state = output:match("Caps Lock:%s*(%a+)")
          if state then
            M.set_state(state:lower())
          else
            M.set_state(nil)
          end
        else
          M.set_state(nil)
        end
      end)
    end,
  })
  if job <= 0 then
    M._linux_job_in_flight = false
    M.set_state(nil)
  end
end

--- Platform-aware refresh dispatcher.
function M.refresh()
  if vim.fn.has("mac") == 1 then
    M.refresh_macos()
  elseif M.is_wsl() or vim.fn.has("win32") == 1 or vim.fn.has("win64") == 1 then
    -- In WSL and Windows:
    -- If persistent worker is running, no new process is spawned.
    if not M._wsl_job_id or M._wsl_job_id <= 0 then
      M.start_wsl_worker()
    end
  else
    M.refresh_linux_x11()
  end
end

--- Stop polling timer, worker, and cleanup hooks.
function M.stop()
  M.stop_wsl_worker()
  if M._timer then
    pcall(M._timer.stop, M._timer)
    pcall(M._timer.close, M._timer)
    M._timer = nil
  end
end

--- Reset internal state (primarily for tests).
function M.reset()
  M.stop()
  M._is_wsl_cached = nil
  M._is_wsl_override = nil
  M._executable_finder = nil
  M._wsl_job_failed_at = 0
  M._linux_job_in_flight = false
  _G._heirline_caps_lock_on = nil
end

--- Initialize Caps Lock monitoring.
function M.start()
  M.refresh()
  if not M._timer then
    local timer = vim.uv.new_timer()
    if timer then
      M._timer = timer
      timer:start(750, 750, vim.schedule_wrap(M.refresh))
    end
  end

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("HeirlineCapsLockCleanup", { clear = true }),
    callback = function()
      M.stop()
    end,
  })
end

return M
