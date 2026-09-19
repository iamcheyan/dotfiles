local backend_util = require("aerial.backends.util")
local backends = require("aerial.backends")
local config = require("aerial.config")
local util = require("aerial.util")

local M = {}

-- Ensure aerial backend configuration table exists to prevent nil index in change watcher delay
if not config.cobol then
  config.cobol = {
    update_delay = 300,
  }
end

M.is_supported = function(bufnr)
  if not vim.tbl_contains(util.get_filetypes(bufnr), "cobol") then
    return false, "Filetype is not cobol"
  end
  return true, nil
end

local reserved_words = {
  ["EXIT"] = true,
  ["GOBACK"] = true,
  ["CONTINUE"] = true,
  ["STOP"] = true,
  ["IF"] = true,
  ["ELSE"] = true,
  ["PERFORM"] = true,
  ["MOVE"] = true,
  ["DISPLAY"] = true,
  ["ADD"] = true,
  ["SUBTRACT"] = true,
  ["MULTIPLY"] = true,
  ["DIVIDE"] = true,
  ["COMPUTE"] = true,
  ["READ"] = true,
  ["WRITE"] = true,
  ["REWRITE"] = true,
  ["DELETE"] = true,
  ["START"] = true,
  ["OPEN"] = true,
  ["CLOSE"] = true,
  ["CALL"] = true,
  ["CANCEL"] = true,
  ["STRING"] = true,
  ["UNSTRING"] = true,
  ["SEARCH"] = true,
  ["SET"] = true,
  ["INSPECT"] = true,
  ["EVALUATE"] = true,
  ["WHEN"] = true,
  ["INITIALIZE"] = true,
  ["ACCEPT"] = true,
  ["GO"] = true,
  ["ALTER"] = true,
  ["SORT"] = true,
  ["MERGE"] = true,
  ["RELEASE"] = true,
  ["RETURN"] = true,
  ["COMMIT"] = true,
  ["ROLLBACK"] = true,
  ["ENTRY"] = true,
  ["INVOKE"] = true,
  ["EXEC"] = true,
  ["END-EXEC"] = true,
  ["NEXT"] = true,
}

local function is_reserved(word)
  word = word:upper()
  if reserved_words[word] or word:match("^END%-") then
    return true
  end
  return false
end

local function get_line_len(bufnr, lnum)
  if lnum < 1 then
    return 0
  end
  local lines = vim.api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, true)
  if #lines > 0 then
    return vim.api.nvim_strwidth(lines[1])
  end
  return 0
end

local function set_end_range(bufnr, items, last_line)
  if not items or #items == 0 then
    return
  end
  if not last_line then
    last_line = vim.api.nvim_buf_line_count(bufnr)
  end
  local prev = nil
  for _, item in ipairs(items) do
    if prev then
      prev.end_lnum = item.lnum - 1
      prev.end_col = get_line_len(bufnr, prev.end_lnum)
      set_end_range(bufnr, prev.children, prev.end_lnum)
    end
    prev = item
  end
  if prev then
    prev.end_lnum = last_line
    prev.end_col = get_line_len(bufnr, last_line)
    set_end_range(bufnr, prev.children, last_line)
  end
end

local function find_col(raw_line, token)
  local upper_line = raw_line:upper()
  local start_idx = upper_line:find(token:upper(), 1, true)
  if start_idx then
    return start_idx - 1
  end
  return 0
end

M.fetch_symbols_sync = function(bufnr)
  bufnr = bufnr or 0
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, true)
  local items = {}

  local curr_div = nil
  local curr_sec = nil
  local curr_fd = nil
  local in_ident = false
  local in_data = false
  local in_procedure = false

  local function add_item(parent, item)
    if
      config.post_parse_symbol
      and config.post_parse_symbol(bufnr, item, {
          backend_name = "cobol",
          lang = "cobol",
        })
        == false
    then
      return nil
    end

    if parent then
      item.parent = parent
      item.level = (parent.level or 0) + 1
      parent.children = parent.children or {}
      table.insert(parent.children, item)
    else
      item.level = 0
      table.insert(items, item)
    end
    return item
  end

  for lnum, raw_line in ipairs(lines) do
    local is_comment = false
    -- Fixed format indicator in column 7
    if raw_line:len() >= 7 then
      local ind = raw_line:sub(7, 7)
      if ind == "*" or ind == "/" then
        is_comment = true
      end
    end
    -- Free format comment or full-line comment
    if not is_comment and raw_line:match("^%s*%*") then
      is_comment = true
    end

    if not is_comment then
      -- Strip modern inline comment *>
      local line = raw_line:gsub("%*>.*$", "")
      -- Strip fixed format columns 1-6 if sequence number
      if line:match("^%d%d%d%d%d%d[ %*]") then
        line = line:sub(8)
      end

      local upper = line:upper()

      -- 1. DIVISION
      local div_name = upper:match("^%s*([A-Z0-9%-]+%s+DIVISION)")
      if div_name then
        local item = {
          name = div_name,
          kind = "Module",
          lnum = lnum,
          col = find_col(raw_line, div_name),
          children = {},
        }
        curr_div = add_item(nil, item)
        curr_sec = nil
        curr_fd = nil
        in_ident = div_name:find("IDENTIFICATION") ~= nil
        in_data = div_name:find("DATA") ~= nil
        in_procedure = div_name:find("PROCEDURE") ~= nil
      else
        -- 2. PROGRAM-ID (inside IDENTIFICATION DIVISION)
        local prog_id = upper:match("^%s*PROGRAM%-ID%s*%.%s*([A-Z0-9%-]+)")
        if prog_id and in_ident then
          local item = {
            name = "PROGRAM-ID: " .. prog_id,
            kind = "Class",
            lnum = lnum,
            col = find_col(raw_line, prog_id),
          }
          add_item(curr_div, item)
        else
          -- 3. SECTION
          local sec_name = upper:match("^%s*([A-Z0-9%-]+%s+SECTION)%s*[%s%.]")
          if not sec_name then
            sec_name = upper:match("^%s*([A-Z0-9%-]+%s+SECTION)$")
          end
          if sec_name and not sec_name:match("^EXIT%s+") then
            local item = {
              name = sec_name,
              kind = "Interface",
              lnum = lnum,
              col = find_col(raw_line, sec_name),
              children = {},
            }
            curr_sec = add_item(curr_div, item)
            curr_fd = nil
          else
            -- 4. DATA DIVISION: FD / SD and 01 records
            if in_data then
              local fd_name = upper:match("^%s*FD%s+([A-Z0-9%-]+)")
              local sd_name = upper:match("^%s*SD%s+([A-Z0-9%-]+)")
              if fd_name or sd_name then
                local display_name = fd_name and ("FD " .. fd_name) or ("SD " .. sd_name)
                local target_name = fd_name or sd_name
                local item = {
                  name = display_name,
                  kind = "Struct",
                  lnum = lnum,
                  col = find_col(raw_line, target_name),
                  children = {},
                }
                curr_fd = add_item(curr_sec or curr_div, item)
              else
                local rec_01 = upper:match("^%s*01%s+([A-Z0-9%-]+)")
                if rec_01 then
                  local item = {
                    name = "01 " .. rec_01,
                    kind = "Struct",
                    lnum = lnum,
                    col = find_col(raw_line, rec_01),
                  }
                  add_item(curr_fd or curr_sec or curr_div, item)
                end
              end
            end

            -- 5. PROCEDURE DIVISION: Paragraphs
            if in_procedure then
              local para = upper:match("^%s*([A-Z0-9%-]+)%.%s*$")
              if not para then
                local token, rest = upper:match("^%s*([A-Z0-9%-]+)%.%s*(.*)$")
                if token and not is_reserved(token) and (rest == "" or rest:match("^%*")) then
                  para = token
                end
              end
              if para and not is_reserved(para) and not para:match("%s+SECTION$") then
                local item = {
                  name = para,
                  kind = "Function",
                  lnum = lnum,
                  col = find_col(raw_line, para),
                }
                add_item(curr_sec or curr_div, item)
              end
            end
          end
        end
      end
    end
  end

  set_end_range(bufnr, items)
  backends.set_symbols(bufnr, items, { backend_name = "cobol", lang = "cobol" })
end

M.fetch_symbols = M.fetch_symbols_sync

M.attach = function(bufnr)
  backend_util.add_change_watcher(bufnr, "cobol")
end

M.detach = function(bufnr)
  backend_util.remove_change_watcher(bufnr, "cobol")
end

return M
