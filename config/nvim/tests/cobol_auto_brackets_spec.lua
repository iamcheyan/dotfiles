local this_file = debug.getinfo(1, "S").source:sub(2)
local nvim_root = vim.fn.fnamemodify(this_file, ":h:h")
vim.opt.runtimepath:prepend(nvim_root)
package.path = nvim_root .. "/lua/?.lua;" .. nvim_root .. "/lua/?/init.lua;" .. package.path

local blink = dofile(nvim_root .. "/lua/plugins/blink.lua")[1]
local auto_brackets = blink.opts.completion.accept.auto_brackets
assert(auto_brackets.enabled == true, "auto brackets should remain enabled globally")
assert(auto_brackets.default_brackets == nil
  or (auto_brackets.default_brackets[1] == "(" and auto_brackets.default_brackets[2] == ")"),
  "other languages should retain Blink's normal function-call brackets")

local blocked = {}
for _, filetype in ipairs(auto_brackets.blocked_filetypes or {}) do
  blocked[filetype] = true
end
for _, filetype in ipairs({ "cobol", "cbl", "cob" }) do
  assert(blocked[filetype], filetype .. " should not auto-insert function-call brackets")
end
for _, filetype in ipairs({ "python", "lua", "javascript" }) do
  assert(not blocked[filetype], filetype .. " should retain function-call auto brackets")
end

local blink_root = vim.fn.stdpath("data") .. "/lazy/blink.cmp"
if vim.fn.isdirectory(blink_root) == 1 then
  vim.opt.runtimepath:prepend(blink_root)
  local blink_config = require("blink.cmp.config")
  blink_config.merge_with({ completion = blink.opts.completion })
  local brackets = require("blink.cmp.completion.brackets.utils")
  local context = { mode = "default", line = "PERFORM WRITE-DB-ONLY", cursor = { 0, 8 } }
  for _, filetype in ipairs({ "cobol", "cbl", "cob" }) do
    assert(not brackets.should_run_resolution(context, filetype, "kind"),
      filetype .. " kind resolution must not add function brackets")
    assert(not brackets.should_run_resolution(context, filetype, "semantic_token"),
      filetype .. " semantic resolution must not add function brackets")
  end
  for _, filetype in ipairs({ "python", "lua", "javascript" }) do
    assert(brackets.should_run_resolution(context, filetype, "kind"),
      filetype .. " kind resolution should retain auto brackets")
  end
  local kind = require("blink.cmp.completion.brackets.kind")
  local status, text_edit = kind(context, "cobol", {
    kind = require("blink.cmp.types").CompletionItemKind.Function,
    textEdit = {
      range = { start = { line = 0, character = 0 }, ["end"] = { line = 0, character = 15 } },
      newText = "WRITE-DB-ONLY",
    },
  })
  assert(status == "check_semantic_token" and text_edit.newText == "WRITE-DB-ONLY",
    "accepting a COBOL paragraph completion must not append parentheses")
  print("Blink runtime bracket policy: OK")
end

print("cobol_auto_brackets_spec: OK")
