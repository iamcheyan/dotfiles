-- Headless tests for sidebar session detect/restore planning.
-- Run: nvim --headless -u NONE -l config/nvim/tests/sidebar_session_spec.lua

local this_file = debug.getinfo(1, "S").source:sub(2)
vim.opt.runtimepath:prepend(vim.fn.fnamemodify(this_file, ":h:h"))

local session = require("config.sidebar_session")

local failures = 0
local ran = 0

local function eq(actual, expected, msg)
  ran = ran + 1
  if actual ~= expected then
    failures = failures + 1
    io.stderr:write(string.format("FAIL %s\n  expected: %s\n  actual:   %s\n", msg, vim.inspect(expected), vim.inspect(actual)))
  end
end

local function ok(cond, msg)
  ran = ran + 1
  if not cond then
    failures = failures + 1
    io.stderr:write("FAIL " .. msg .. "\n")
  end
end

local function reset_ui()
  vim.cmd("silent! tabonly")
  vim.cmd("silent! only")
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_valid(buf) then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
end

local function make_file(path, lines)
  vim.cmd.edit(path)
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines or { "-- " .. path })
  vim.bo[buf].buflisted = true
  vim.bo[buf].buftype = ""
  vim.bo[buf].swapfile = false
  return vim.api.nvim_get_current_win(), buf
end

local function make_sidebar(ft, opts)
  opts = opts or {}
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = ft
  vim.bo[buf].buftype = "nofile"
  vim.bo[buf].buflisted = false
  local source = opts.source_win or vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_win(source)
  if opts.direction == "right" then
    vim.cmd("rightbelow " .. (opts.width or 30) .. "vsplit")
  else
    vim.cmd("leftabove " .. (opts.width or 30) .. "vsplit")
  end
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  if ft == "aerial" then
    vim.w[win].source_win = source
    vim.w[win].is_aerial_win = true
    vim.w[source].aerial_win = win
  elseif ft == "neo-tree" then
    vim.b[buf].neo_tree_source = opts.source or "filesystem"
    vim.b[buf].neo_tree_position = opts.position or "left"
  end
  if opts.width then
    pcall(vim.api.nvim_win_set_width, win, opts.width)
  end
  return win, buf
end

-- 1. empty layout
reset_ui()
make_file("only.py")
local empty = session.detect()
eq(empty.neotree, nil, "empty: no neo-tree")
eq(#(empty.aerials or {}), 0, "empty: no aerials")

-- 2. neo-tree on the left
reset_ui()
local file_win = make_file("left_tree.py")
make_sidebar("neo-tree", { position = "left", width = 28, source_win = file_win })
local left_tree = session.detect()
eq(left_tree.neotree, "filesystem", "left neo-tree source")
eq(left_tree.neotree_position, "left", "left neo-tree position")
ok(left_tree.neotree_width >= 16, "left neo-tree width recorded")

-- 3. neo-tree on the right
reset_ui()
file_win = make_file("right_tree.py")
make_sidebar("neo-tree", { position = "right", direction = "right", width = 28, source_win = file_win })
local right_tree = session.detect()
eq(right_tree.neotree_position, "right", "right neo-tree position")

-- 4. one aerial to the left of a file
reset_ui()
file_win = make_file("single.py")
make_sidebar("aerial", { direction = "left", width = 30, source_win = file_win })
local one = session.detect()
eq(#one.aerials, 1, "one aerial counted")
eq(one.aerials[1].direction, "left", "one aerial direction")
ok(one.aerials[1].file:match("single%.py$"), "one aerial source file")

-- 5. two file splits, aerial on each (the screenshot layout)
reset_ui()
local left_file_win = make_file("/tmp/sidebar-left.py")
vim.cmd("vsplit")
local right_file_win = make_file("/tmp/sidebar-right.COB")
make_sidebar("aerial", { direction = "left", width = 26, source_win = left_file_win })
vim.api.nvim_set_current_win(right_file_win)
make_sidebar("aerial", { direction = "left", width = 32, source_win = right_file_win })
local both = session.detect()
eq(#both.aerials, 2, "two aerials in a split layout")
local files = {}
for _, a in ipairs(both.aerials) do
  files[vim.fn.fnamemodify(a.file, ":t")] = a
end
ok(files["sidebar-left.py"] ~= nil, "captures aerial for left split")
ok(files["sidebar-right.COB"] ~= nil, "captures aerial for right split")
eq(files["sidebar-left.py"].direction, "left", "left split aerial stays left of its file")
eq(files["sidebar-right.COB"].direction, "left", "right split aerial stays left of its file")

-- 6. aerial opened to the right of a file
reset_ui()
file_win = make_file("right_outline.py")
make_sidebar("aerial", { direction = "right", width = 30, source_win = file_win })
local right_outline = session.detect()
eq(#right_outline.aerials, 1, "right aerial counted")
eq(right_outline.aerials[1].direction, "right", "aerial on the right of its file")

-- 7. crushed width is not persisted as-is
reset_ui()
file_win = make_file("crushed.py")
local nt_win = select(1, make_sidebar("neo-tree", { position = "left", width = 28, source_win = file_win }))
pcall(vim.api.nvim_win_set_width, nt_win, 3)
local crushed = session.detect()
ok(crushed.neotree_width == nil or crushed.neotree_width >= 16, "does not persist icon-only neo-tree width")

-- 8. old JSON still restores one left aerial
local old = session.normalize({ neotree = "filesystem", aerial = true, aerial_width = 30 })
eq(old.neotree, "filesystem", "normalize keeps neo-tree")
eq(old.neotree_position, "left", "normalize defaults neo-tree to left")
eq(#old.aerials, 1, "normalize old aerial=true into one aerial")
eq(old.aerials[1].direction, "left", "normalize old aerial as left")

-- 9. restore plan for two aerials + left neo-tree
local plan = session.restore_plan({
  neotree = "filesystem",
  neotree_position = "left",
  neotree_width = 28,
  aerials = {
    { file = "/tmp/sidebar-left.py", direction = "left", width = 26 },
    { file = "/tmp/sidebar-right.COB", direction = "left", width = 32 },
  },
})
eq(plan[1].kind, "neotree", "plan opens neo-tree first")
eq(plan[1].position, "left", "plan neo-tree on the left")
eq(plan[2].kind, "aerial", "plan then restores first aerial")
eq(plan[3].kind, "aerial", "plan restores second aerial")
eq(plan[3].file:match("sidebar%-right%.COB$") and plan[3].file or plan[2].file, plan[3].file, "second aerial keeps its file")
local aerial_files = {}
for _, step in ipairs(plan) do
  if step.kind == "aerial" then
    aerial_files[vim.fn.fnamemodify(step.file, ":t")] = step.direction
  end
end
eq(aerial_files["sidebar-left.py"], "left", "plan left aerial")
eq(aerial_files["sidebar-right.COB"], "left", "plan right-split aerial")

-- 10. JSON roundtrip keeps both split aerials
local encoded = vim.json.encode(both)
local decoded = session.normalize(vim.json.decode(encoded))
eq(#decoded.aerials, 2, "json roundtrip keeps two aerials")
local round = {}
for _, a in ipairs(decoded.aerials) do
  round[vim.fn.fnamemodify(a.file, ":t")] = a.direction
end
eq(round["sidebar-left.py"], "left", "json left split aerial")
eq(round["sidebar-right.COB"], "left", "json right split aerial")

-- 11. restore plan honors a right-hand outline
local right_plan = session.restore_plan({
  aerials = { { file = "right_outline.py", direction = "right", width = 30 } },
})
eq(#right_plan, 1, "right-only plan has one step")
eq(right_plan[1].direction, "right", "right-only plan opens aerial to the right")

-- 12. tab isolation: aerial in tab 2 is not attributed to tab 1
reset_ui()
make_file("tab1.py")
vim.cmd("tabnew")
local t2 = make_file("tab2.py")
make_sidebar("aerial", { direction = "left", width = 30, source_win = t2 })
local tabs = session.detect()
ok(tabs.tabs and #tabs.tabs >= 1, "detects per-tab sidebar state")
local tab_with_aerial = 0
for _, t in ipairs(tabs.tabs) do
  if t.aerials and #t.aerials > 0 then
    tab_with_aerial = tab_with_aerial + 1
  end
end
eq(tab_with_aerial, 1, "only the tab that has aerial records it")

reset_ui()

if failures > 0 then
  io.stderr:write(string.format("%d/%d failed\n", failures, ran))
  os.exit(1)
end
print(string.format("ok %d checks", ran))
