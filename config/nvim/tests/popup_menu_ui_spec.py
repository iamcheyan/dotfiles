import time
from pathlib import Path
import pynvim
n = pynvim.attach('child', argv=['nvim', '--embed', '--headless', '-u', 'NONE'])
try:
    n.ui_attach(100, 30, rgb=True, ext_linegrid=True)
    n.exec_lua('''
      vim.opt.rtp:prepend(...)
      vim.cmd('colorscheme blue')
      require('config.ui_highlights').apply()
      require('config.float_style').setup()
      vim.o.mouse='a'
      _G.source = vim.api.nvim_get_current_win()
      require('config.popup_menu').open({{'First','first'},{separator=true},{'Last','last'}},
        function(entry) _G.executed = entry[2] end)
    ''', str(Path(__file__).resolve().parents[1]))
    assert len(n.api.list_wins()) == 2, "opening a menu must not create a backdrop"
    win, pos = n.exec_lua('local w=require("config.popup_menu").win; return {w,vim.api.nvim_win_get_position(w)}')
    row, col = pos
    n.api.input_mouse('move', '', '', 0, row + 2, col + 4)
    time.sleep(.05)
    assert n.api.win_get_cursor(win)[0] == 1, 'separator must never become selected'
    n.api.input_mouse('wheel', 'down', '', 0, row + 1, col + 4)
    time.sleep(.05)
    assert n.api.win_get_cursor(win)[0] == 3, 'wheel must skip divider'
    n.input('<Up>')
    time.sleep(.05)
    assert n.api.win_get_cursor(win)[0] == 1
    n.api.input_mouse('move', '', '', 0, row + 3, col + 4)
    time.sleep(.05)
    assert n.api.win_get_cursor(win)[0] == 3
    assert n.api.buf_get_lines(n.api.win_get_buf(win), 1, 2, False)[0].strip().startswith('─')
    n.input('<CR>')
    time.sleep(.05)
    assert n.exec_lua('return executed') == 'last'
    assert n.api.get_current_win().handle == n.exec_lua('return source')
    assert n.exec_lua('return vim.o.mousemoveevent') is False
    n.exec_lua('''
      local normal=vim.api.nvim_get_hl(0,{name='Normal',link=false})
      assert(vim.api.nvim_get_hl(0,{name='NormalFloat',link=false}).bg==normal.bg)
      assert(vim.api.nvim_get_hl(0,{name='FloatBorder',link=false}).fg==0xffffff)
      assert(#vim.api.nvim_list_wins()==1,'only the editor should remain after closing the menu')
    ''')
    print('popup_menu_ui_spec: OK')
finally:
    try: n.command('qa!')
    except (EOFError, OSError): pass
