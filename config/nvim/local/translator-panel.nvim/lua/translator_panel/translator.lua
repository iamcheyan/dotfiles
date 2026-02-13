local M = {}

local cache = {}

local function build_lang_arg(cfg)
  if cfg.source_lang and cfg.source_lang ~= "" then
    return string.format("%s:%s", cfg.source_lang, cfg.target_lang)
  end
  return string.format(":%s", cfg.target_lang)
end

local function cache_key(text, cfg)
  return string.format("%s|%s|%s", cfg.source_lang or "", cfg.target_lang or "", text)
end

function M.translate(text, cfg, cb)
  local key = cache_key(text, cfg)
  if cache[key] then
    cb(cache[key], nil)
    return
  end

  if vim.fn.executable(cfg.trans_command) ~= 1 then
    cb(nil, string.format("Command not found: %s", cfg.trans_command))
    return
  end

  local args = {
    build_lang_arg(cfg),
    "-no-ansi",
    "-show-original", "n",
    "-show-original-phonetics", "n",
    "-show-languages", "n",
    "-show-prompt-message", "n",
    "-show-alternatives", "n",
    "-show-dictionary", "n",
    "-show-original-dictionary", "n",
    "-show-translation", "y",
    "-show-translation-phonetics", cfg.show_romaji and "y" or "n",
  }
  table.insert(args, text)
  local output = {}
  local err_output = {}

  local job_id = vim.fn.jobstart({ cfg.trans_command, unpack(args) }, {
    stdout_buffered = true,
    stderr_buffered = true,
    on_stdout = function(_, data)
      if data then
        vim.list_extend(output, data)
      end
    end,
    on_stderr = function(_, data)
      if data then
        vim.list_extend(err_output, data)
      end
    end,
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          local err = table.concat(err_output, "\n")
          if err == "" then
            err = string.format("trans exited with code %d", code)
          end
          cb(nil, err)
          return
        end

        local result = table.concat(output, "\n")
        result = result:gsub("%s+$", "")
        if result == "" then
          cb(nil, "Empty translation result")
          return
        end

        cache[key] = result
        cb(result, nil)
      end)
    end,
  })

  if job_id <= 0 then
    cb(nil, "Failed to start trans job")
  end
end

return M
