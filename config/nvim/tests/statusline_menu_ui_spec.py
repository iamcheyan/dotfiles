import time
from pathlib import Path

import pynvim

root = Path(__file__).resolve().parents[1]
plugin = str(root / "lua/plugins/heirline.lua")
n = pynvim.attach("child", argv=["nvim", "--embed", "--headless", "-u", "NONE"])
try:
    n.ui_attach(100, 30, rgb=True, ext_linegrid=True)
    fitting = n.exec_lua('''
      local path = ...
      package.path = vim.fn.fnamemodify(path, ':h:h:h') .. '/lua/?.lua;' .. package.path
      vim.o.mouse = 'a'
      vim.o.cmdheight = 1
      vim.wo.winbar = '%#WinBar#TOPBAR'
      local spec = dofile(path)[1]
      package.loaded.heirline = { eval_statusline = function() return '' end }
      local opts = spec.opts()
      local callbacks = {}
      local function collect(comp)
        if comp.on_click and comp.on_click.name then callbacks[comp.on_click.name] = comp.on_click.callback end
        for _, child in ipairs(comp) do collect(child) end
      end
      collect(opts.statusline)
      _G.source_win = vim.api.nvim_get_current_win()
      _G.source_buf = vim.api.nvim_get_current_buf()
      callbacks.heirline_mode_menu({}, 0, 0, 'l')
      local win = _G._statusline_menu_win
      return {
        current = vim.api.nvim_get_current_win(), source = source_win,
        buffer = vim.api.nvim_get_current_buf(), source_buffer = source_buf,
        active_style = _G._active_statusline_menu or false,
        height = vim.api.nvim_win_get_height(win),
        lines = vim.api.nvim_buf_line_count(_G._statusline_menu_buf),
        position = vim.api.nvim_win_get_position(win),
        view = vim.api.nvim_win_call(win, vim.fn.winsaveview),
        cursor = vim.api.nvim_win_get_cursor(win),
        source_view = vim.fn.winsaveview(),
        cursorcolumn = vim.wo[win].cursorcolumn,
        signcolumn = vim.wo[win].signcolumn,
        winbar = vim.wo[win].winbar,
      }
    ''', plugin)
    assert fitting["current"] == fitting["source"], fitting
    assert fitting["buffer"] == fitting["source_buffer"], fitting
    assert fitting["active_style"] == "mode", fitting
    assert fitting["lines"] <= fitting["height"], fitting
    assert fitting["cursorcolumn"] is False and fitting["signcolumn"] == "no", fitting
    assert fitting["winbar"] == "", fitting

    row, col = fitting["position"]
    n.api.input_mouse("wheel", "down", "", 0, row + 1, col + 4)
    time.sleep(0.05)
    unchanged = n.exec_lua('''
      local win = _G._statusline_menu_win
      return {view=vim.api.nvim_win_call(win,vim.fn.winsaveview), cursor=vim.api.nvim_win_get_cursor(win), source=vim.fn.winsaveview()}
    ''')
    assert unchanged["cursor"][0] == fitting["cursor"][0] + 1, (fitting, unchanged)
    assert unchanged["source"] == fitting["source_view"], (fitting, unchanged)

    n.api.input_mouse("move", "", "", 0, row + 3, col + 4)
    time.sleep(0.05)
    assert n.exec_lua('return vim.api.nvim_win_get_cursor(_statusline_menu_win)[1]') == 3
    n.input('<Up>')
    time.sleep(0.05)
    assert n.exec_lua('return vim.api.nvim_win_get_cursor(_statusline_menu_win)[1]') == 2
    n.input('<Down>')
    time.sleep(0.05)
    assert n.exec_lua('return vim.api.nvim_win_get_cursor(_statusline_menu_win)[1]') == 3

    # A real click on a menu row closes it while retaining the editor window.
    n.api.input_mouse("left", "press", "", 0, row + 1, col + 4)
    time.sleep(0.05)
    clicked = n.exec_lua('return {menu=_G._statusline_menu_win or false,current=vim.api.nvim_get_current_win(),source=source_win}')
    assert clicked["menu"] is False and clicked["current"] == clicked["source"], clicked

    n.ui_try_resize(100, 10)
    time.sleep(0.1)
    overflowing = n.exec_lua('''
      local path = ...
      local opts = dofile(path)[1].opts()
      local callback
      local function find(comp)
        if comp.on_click and comp.on_click.name == 'heirline_encoding_menu' then callback = comp.on_click.callback end
        for _, child in ipairs(comp) do find(child) end
      end
      find(opts.statusline)
      callback({},0,0,'l')
      local win = _G._statusline_menu_win
      return {
        lines=vim.api.nvim_buf_line_count(_G._statusline_menu_buf),
        height=vim.api.nvim_win_get_height(win),
        position=vim.api.nvim_win_get_position(win),
        view=vim.api.nvim_win_call(win,vim.fn.winsaveview),
        current=vim.api.nvim_get_current_win(), source=source_win,
      }
    ''', plugin)
    assert overflowing["lines"] > overflowing["height"], overflowing
    assert overflowing["current"] == overflowing["source"], overflowing
    row, col = overflowing["position"]
    n.api.input_mouse("wheel", "down", "", 0, row + 1, col + 4)
    time.sleep(0.05)
    scrolled = n.exec_lua('local win=_G._statusline_menu_win; return vim.api.nvim_win_call(win,vim.fn.winsaveview)')
    assert n.exec_lua('return vim.api.nvim_win_get_cursor(_statusline_menu_win)[1]') == 2
    n.exec_lua("vim.api.nvim_win_set_cursor(_statusline_menu_win,{6,0})")
    n.input('<Down>')
    time.sleep(0.05)
    assert n.exec_lua('return vim.api.nvim_win_get_cursor(_statusline_menu_win)[1]') == 8, 'skip separators'

    print("statusline_menu_ui_spec: OK (focus, colors, marker, fit/overflow scrolling, mouse selection)")
finally:
    try:
        n.command("qa!")
    except (EOFError, OSError):
        pass
