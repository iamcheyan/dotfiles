local M = {}

local uv = vim.uv or vim.loop

local state = {
  active = false,
  original = nil,
  session_dir = nil,
  tasks = {},
  current = 0,
  correct = 0,
  wrong = 0,
  checked = {},
  words = nil,
}

local defaults = {
  task_count = 10,
  copy_file_count = 10,
  wordlist = "lua/vimquest/data/ogden-850-words.json",
  exclude_dirs = {
    [".git"] = true,
    ["node_modules"] = true,
    ["dist"] = true,
    ["build"] = true,
    ["target"] = true,
  },
  code_extensions = {
    lua = true,
    vim = true,
    js = true,
    jsx = true,
    ts = true,
    tsx = true,
    json = true,
    md = true,
    py = true,
    rb = true,
    go = true,
    rs = true,
    c = true,
    h = true,
    cpp = true,
    hpp = true,
    java = true,
    sh = true,
    zsh = true,
    fish = true,
    css = true,
    scss = true,
    html = true,
    yml = true,
    yaml = true,
    toml = true,
  },
}

local config = vim.deepcopy(defaults)

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "VimQuest.nvim" })
end

local function join(...)
  local path = table.concat({ ... }, "/"):gsub("//+", "/")
  return path
end

local function exists(path)
  return uv.fs_stat(path) ~= nil
end

local function shuffle(items)
  math.randomseed(os.time() + math.floor(uv.hrtime() % 100000))
  for i = #items, 2, -1 do
    local j = math.random(i)
    items[i], items[j] = items[j], items[i]
  end
  return items
end

local function read_json(path)
  local lines = vim.fn.readfile(path)
  local ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok or type(decoded) ~= "table" then
    error("invalid JSON wordlist: " .. path)
  end
  return decoded
end

local function wordlist_path()
  local runtime_paths = vim.api.nvim_get_runtime_file(config.wordlist, false)
  if runtime_paths[1] then
    return runtime_paths[1]
  end
  return join(vim.fn.stdpath("config"), config.wordlist)
end

local function load_words()
  if state.words then
    return state.words
  end
  local path = wordlist_path()
  if not exists(path) then
    error("wordlist not found: " .. path)
  end
  state.words = read_json(path)
  return state.words
end

local function should_skip(path)
  for part in path:gmatch("[^/]+") do
    if config.exclude_dirs[part] then
      return true
    end
  end
  return false
end

local function is_code_file(path)
  local ext = path:match("%.([%w_%-]+)$")
  return ext and config.code_extensions[ext] or false
end

local function scan_project(root)
  local files = {}
  local function walk(dir)
    local handle = uv.fs_scandir(dir)
    if not handle then
      return
    end
    while true do
      local name, typ = uv.fs_scandir_next(handle)
      if not name then
        break
      end
      local path = join(dir, name)
      local rel = path:sub(#root + 2)
      if not should_skip(rel) then
        if typ == "directory" then
          walk(path)
        elseif typ == "file" and is_code_file(path) then
          table.insert(files, rel)
        end
      end
    end
  end
  walk(root)
  return shuffle(files)
end

local function copy_files(root, session_dir, files)
  local copied = {}
  for i = 1, math.min(#files, config.copy_file_count) do
    local rel = files[i]
    local src = join(root, rel)
    local dst = join(session_dir, rel)
    vim.fn.mkdir(vim.fn.fnamemodify(dst, ":h"), "p")
    vim.fn.writefile(vim.fn.readfile(src, "b"), dst, "b")
    table.insert(copied, rel)
  end
  return copied
end

local function sentence_with_word(entry)
  local ex = entry.ex or entry.w
  return ex:gsub("^%s+", ""):gsub("%s+$", "")
end

local function replace_word_once(text, from, to)
  return text:gsub("(%f[%a])" .. vim.pesc(from) .. "(%f[%A])", to, 1)
end

local function blank_word_once(text, word)
  return replace_word_once(text, word:gsub("^%l", string.upper), "____")
    :gsub("(%f[%a])" .. vim.pesc(word) .. "(%f[%A])", "____", 1)
end

local function lower_first(text)
  return text:gsub("^%u", string.lower)
end

local task_builders = {
  function(entry)
    local expected = blank_word_once(sentence_with_word(entry), entry.w)
    return {
      type = "Fill",
      prompt = string.format('补全表示 "%s" 的英文单词。', entry.zh or ""),
      editable = expected,
      expected = sentence_with_word(entry),
      answer = entry.w,
      entry = entry,
    }
  end,
  function(entry)
    local synonyms = entry.s or {}
    if #synonyms == 0 then
      return nil
    end
    local synonym = synonyms[math.random(#synonyms)]
    return {
      type = "Replace",
      prompt = "把近义词替换成核心词。",
      editable = replace_word_once(lower_first(sentence_with_word(entry)), entry.w, synonym),
      expected = lower_first(sentence_with_word(entry)),
      answer = entry.w,
      entry = entry,
    }
  end,
  function(entry)
    local ex = sentence_with_word(entry)
    local word = ex:match("^(%a+)")
    local editable = word and ex:gsub("^" .. vim.pesc(word), word .. " " .. lower_first(word), 1)
      or (entry.w .. " " .. ex)
    return {
      type = "Delete",
      prompt = "删除多余单词。",
      editable = editable,
      expected = ex,
      answer = entry.w,
      entry = entry,
    }
  end,
  function(entry)
    return {
      type = "Meaning",
      prompt = "根据中文核心概念输入对应英文。",
      display = entry.core or entry.zh or "",
      editable = "",
      expected = entry.w,
      answer = entry.w,
      entry = entry,
    }
  end,
  function(entry)
    return {
      type = "Japanese Meaning",
      prompt = "根据日语释义输入英文。",
      display = entry.ja or "",
      editable = "",
      expected = entry.w,
      answer = entry.w,
      entry = entry,
    }
  end,
  function(entry)
    return {
      type = "Example Translation",
      prompt = "根据日语例句翻译猜测核心单词。",
      display = entry.exj or "",
      editable = "",
      expected = entry.w,
      answer = entry.w,
      entry = entry,
    }
  end,
}

local function build_tasks()
  local words = shuffle(vim.deepcopy(load_words()))
  local tasks = {}
  local builder_index = 1
  for _, entry in ipairs(words) do
    local task = task_builders[builder_index](entry)
    builder_index = builder_index % #task_builders + 1
    if task then
      table.insert(tasks, task)
    end
    if #tasks >= config.task_count then
      break
    end
  end
  return tasks
end

local function comment_style(path)
  local ext = path:match("%.([%w_%-]+)$") or ""
  if vim.tbl_contains({ "lua", "vim", "sql" }, ext) then
    return "--", ""
  end
  if vim.tbl_contains({ "py", "rb", "sh", "zsh", "fish", "yml", "yaml", "toml" }, ext) then
    return "#", ""
  end
  if vim.tbl_contains({ "html", "xml", "md" }, ext) then
    return "<!--", "-->"
  end
  if vim.tbl_contains({ "css", "scss" }, ext) then
    return "/*", "*/"
  end
  return "//", ""
end

local function comment_line(path, text)
  local prefix, suffix = comment_style(path)
  if text == "" then
    return prefix .. (suffix ~= "" and " " .. suffix or "")
  end
  return prefix .. " " .. text .. (suffix ~= "" and " " .. suffix or "")
end

local function strip_comment(path, line)
  local prefix, suffix = comment_style(path)
  local text = line or ""
  text = text:gsub("^%s+", "")
  if prefix ~= "" then
    text = text:gsub("^" .. vim.pesc(prefix) .. "%s?", "", 1)
  end
  if suffix ~= "" then
    text = text:gsub("%s?" .. vim.pesc(suffix) .. "%s*$", "")
  end
  return text
end

local function task_block(task, index, total)
  local rel = task.file
  local lines = {
    comment_line(rel, string.rep("=", 58)),
    comment_line(rel, string.format("VIMQUEST TASK %s [%d/%d] %s", task.id, index, total, task.type)),
    comment_line(rel, task.prompt),
  }
  if task.display then
    table.insert(lines, comment_line(rel, "Clue: " .. task.display))
  end
  vim.list_extend(lines, {
    comment_line(rel, "Answer:"),
    comment_line(rel, task.editable),
    comment_line(rel, "Find this task, edit the Answer line, then run :VimQuestCheck."),
    comment_line(rel, string.format("END VIMQUEST TASK %s", task.id)),
    comment_line(rel, string.rep("=", 58)),
  })
  return lines
end

local function insert_tasks_into_files(session_dir, files, tasks)
  local usable = math.min(#files, #tasks)
  for i = 1, usable do
    local task = tasks[i]
    local rel = files[i]
    task.file = rel
    task.id = string.format("Q%02d-%06d", i, math.random(999999))

    local path = join(session_dir, rel)
    local lines = vim.fn.readfile(path)
    local insert_at = #lines > 0 and math.random(1, #lines) or 1
    local block = task_block(task, i, usable)
    for offset, line in ipairs(block) do
      table.insert(lines, insert_at + offset - 1, line)
    end
    vim.fn.writefile(lines, path)
  end

  while #tasks > usable do
    table.remove(tasks)
  end
end

local function ensure_active()
  if not state.active then
    notify("No active VimQuest session. Run :VimQuestStart first.", vim.log.levels.WARN)
    return false
  end
  return true
end

local function open_task(index)
  local task = state.tasks[index]
  if not task then
    return
  end
  local path = join(state.session_dir, task.file)
  vim.cmd.edit(vim.fn.fnameescape(path))
  local found = vim.fn.search("VIMQUEST TASK " .. task.id, "w")
  if found > 0 then
    vim.api.nvim_win_set_cursor(0, { found, 0 })
    vim.cmd.normal({ args = { "zz" }, bang = true })
  end
  notify(string.format("Task %d/%d | %s", index, #state.tasks, task.file))
end

local function normalize(text)
  return (text or ""):gsub("^%s+", ""):gsub("%s+$", ""):gsub("%s+", " "):lower()
end

local function buffer_lines_for(path)
  local bufnr = vim.fn.bufnr(path)
  if bufnr > 0 and vim.api.nvim_buf_is_loaded(bufnr) then
    return vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  end
  return vim.fn.readfile(path)
end

local function answer_for_task(task)
  local path = join(state.session_dir, task.file)
  local lines = buffer_lines_for(path)
  local in_task = false
  local saw_answer = false
  for _, line in ipairs(lines) do
    if line:find("VIMQUEST TASK " .. task.id, 1, true) then
      in_task = true
    elseif in_task and line:find("END VIMQUEST TASK " .. task.id, 1, true) then
      return nil
    elseif in_task and saw_answer then
      return strip_comment(task.file, line)
    elseif in_task and strip_comment(task.file, line):match("^Answer:%s*$") then
      saw_answer = true
    end
  end
  return nil
end

local function task_at_cursor()
  if not state.active then
    return nil
  end
  local current = vim.api.nvim_buf_get_name(0)
  if current == "" then
    return nil
  end
  local rel = vim.fn.fnamemodify(current, ":.")
  local row = vim.api.nvim_win_get_cursor(0)[1]
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  for _, task in ipairs(state.tasks) do
    if task.file == rel then
      local start_line, end_line
      for i, line in ipairs(lines) do
        if line:find("VIMQUEST TASK " .. task.id, 1, true) then
          start_line = i
        elseif line:find("END VIMQUEST TASK " .. task.id, 1, true) then
          end_line = i
          break
        end
      end
      if start_line and end_line and row >= start_line and row <= end_line then
        return task
      end
    end
  end
  return state.tasks[state.current]
end

local function start_session(cwd, original)
  local session_dir = join(
    vim.fn.expand("~/.cache"),
    "vimquest",
    string.format("session-%s-%06d", os.date("%Y%m%d-%H%M%S"), math.floor(uv.hrtime() % 1000000))
  )

  local ok, err = pcall(function()
    vim.fn.mkdir(session_dir, "p")
    local files = scan_project(cwd)
    local copied = copy_files(cwd, session_dir, files)
    if #copied == 0 then
      error("no supported code files found in project")
    end
    local tasks = build_tasks()
    if #tasks == 0 then
      error("no tasks generated from wordlist")
    end
    insert_tasks_into_files(session_dir, copied, tasks)
    state.active = true
    state.original = original
    state.session_dir = session_dir
    state.tasks = tasks
    state.current = 1
    state.correct = 0
    state.wrong = 0
    state.checked = {}
  end)

  if not ok then
    vim.fn.delete(session_dir, "rf")
    notify("Start failed: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  vim.cmd.tcd(vim.fn.fnameescape(session_dir))
  vim.cmd.edit(vim.fn.fnameescape(join(session_dir, state.tasks[1].file)))
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
  notify(string.format("Round started: %d tasks inserted into copied files. Search for VIMQUEST TASK.", #state.tasks))
end

function M.start()
  if state.active then
    notify("VimQuest session is already active.", vim.log.levels.WARN)
    return
  end

  start_session(vim.fn.getcwd(), {
    cwd = vim.fn.getcwd(),
    file = vim.api.nvim_buf_get_name(0),
    cursor = vim.api.nvim_win_get_cursor(0),
  })
end

function M.stop()
  if not ensure_active() then
    return
  end

  local original = state.original
  local session_dir = state.session_dir
  state.active = false
  state.original = nil
  state.session_dir = nil
  state.tasks = {}
  state.current = 0
  state.checked = {}

  if original and original.cwd then
    vim.cmd.tcd(vim.fn.fnameescape(original.cwd))
  end
  if original and original.file and original.file ~= "" and exists(original.file) then
    vim.cmd.edit(vim.fn.fnameescape(original.file))
    pcall(vim.api.nvim_win_set_cursor, 0, original.cursor)
  end
  if session_dir then
    vim.fn.delete(session_dir, "rf")
  end
  notify("VimQuest session stopped. Original project restored.")
end

function M.next()
  if not ensure_active() then
    return
  end
  state.current = state.current % #state.tasks + 1
  open_task(state.current)
end

function M.next_round()
  if not ensure_active() then
    return
  end

  local original = state.original
  local old_session_dir = state.session_dir
  state.active = false
  state.session_dir = nil
  state.tasks = {}
  state.current = 0
  state.correct = 0
  state.wrong = 0
  state.checked = {}

  if old_session_dir then
    vim.fn.delete(old_session_dir, "rf")
  end
  start_session(original.cwd, original)
end

local function show_check_report(results)
  local lines = {
    "VimQuest Round Result",
    "",
    string.format("Progress %d/%d", state.correct + state.wrong, #state.tasks),
    string.format("Correct %d", state.correct),
    string.format("Wrong %d", state.wrong),
    "",
    "Answers:",
  }
  for _, result in ipairs(results) do
    table.insert(
      lines,
      string.format(
        "%s [%s] %s -> %s",
        result.correct and "OK" or "NO",
        result.task.type,
        result.task.file,
        result.task.expected
      )
    )
  end

  local width = math.min(92, math.max(50, vim.o.columns - 8))
  local height = math.min(#lines, math.max(10, vim.o.lines - 6))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    width = width,
    height = height,
    border = "single",
    title = " VimQuest Result ",
    style = "minimal",
  })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true, silent = true })
  return win
end

function M.check()
  if not ensure_active() then
    return
  end

  state.correct = 0
  state.wrong = 0
  state.checked = {}

  local results = {}
  for i, task in ipairs(state.tasks) do
    local actual = answer_for_task(task)
    local correct = actual ~= nil and normalize(actual) == normalize(task.expected)
    if correct then
      state.correct = state.correct + 1
    else
      state.wrong = state.wrong + 1
    end
    state.checked[i] = correct
    table.insert(results, { task = task, actual = actual, correct = correct })
  end

  local report_win = show_check_report(results)
  if #vim.api.nvim_list_uis() == 0 then
    return
  end
  vim.ui.select({ "Start next round", "Stay in this round" }, {
    prompt = "VimQuest: start a new round?",
  }, function(choice)
    if choice == "Start next round" then
      if report_win and vim.api.nvim_win_is_valid(report_win) then
        vim.api.nvim_win_close(report_win, true)
      end
      M.next_round()
    end
  end)
end

function M.hint()
  if not ensure_active() then
    return
  end
  local task = task_at_cursor()
  if not task then
    notify("No VimQuest task found here.", vim.log.levels.WARN)
    return
  end
  local entry = task.entry
  local lines = {
    "Word:",
    entry.w or "",
    "",
    "Chinese:",
    entry.zh or "",
    "",
    "Japanese:",
    entry.ja or "",
    "",
    "English Definition:",
    entry.en or "",
    "",
    "Example:",
    entry.ex or "",
    "",
    "Chinese Example:",
    entry.exz or "",
    "",
    "Japanese Example:",
    entry.exj or "",
    "",
    "Core Meaning:",
    entry.core or "",
  }

  local width = math.min(72, math.max(40, vim.o.columns - 8))
  local height = math.min(#lines, math.max(10, vim.o.lines - 6))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "markdown"
  vim.api.nvim_open_win(buf, true, {
    relative = "cursor",
    row = 1,
    col = 1,
    width = width,
    height = height,
    border = "single",
    title = " VimQuest Hint ",
    style = "minimal",
  })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, nowait = true, silent = true })
end

function M.stats()
  if not ensure_active() then
    return
  end
  local done = state.correct + state.wrong
  local rate = done > 0 and math.floor((state.correct / done) * 100 + 0.5) or 0
  notify(string.format("Progress %d/%d\nCorrect %d\nWrong %d\nAccuracy %d%%", done, #state.tasks, state.correct, state.wrong, rate))
end

function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})

  vim.api.nvim_create_user_command("VimQuestStart", M.start, { force = true })
  vim.api.nvim_create_user_command("VimQuestStop", M.stop, { force = true })
  vim.api.nvim_create_user_command("VimQuestNext", M.next, { force = true })
  vim.api.nvim_create_user_command("VimQuestCheck", M.check, { force = true })
  vim.api.nvim_create_user_command("VimQuestHint", M.hint, { force = true })
  vim.api.nvim_create_user_command("VimQuestStats", M.stats, { force = true })

  vim.keymap.set("n", "<leader>qs", M.start, { desc = "VimQuest start" })
  vim.keymap.set("n", "<leader>qx", M.stop, { desc = "VimQuest stop" })
  vim.keymap.set("n", "<leader>qn", M.next, { desc = "VimQuest next" })
  vim.keymap.set("n", "<leader>qc", M.check, { desc = "VimQuest check" })
  vim.keymap.set("n", "<leader>qh", M.hint, { desc = "VimQuest hint" })
  vim.keymap.set("n", "<leader>qt", M.stats, { desc = "VimQuest stats" })
  vim.keymap.set("n", "K", function()
    if state.active then
      M.hint()
    else
      vim.lsp.buf.hover()
    end
  end, { desc = "Hover or VimQuest hint" })
end

return M
