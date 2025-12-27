local is_ok, toggleterm = pcall(require, 'toggleterm')
if not is_ok then
    return
end

toggleterm.setup({
    size = 20,
    open_mapping = [[<C-\>]], --  How to open a new terminal
    hide_numbers = true, -- hide the number column in toggleterm buffers
    direction = 'float',
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    shade_filetypes = {},
    float_opts = {
        -- The border key is *almost* the same as 'nvim_open_win'
        -- see :h nvim_open_win for details on borders however
        -- the 'curved' border is a custom border type
        -- not natively supported but implemented in this plugin.
        border = 'single',
        winblend = 0,
    },
})


-- define key mappints
--  t: terminal mode
function _G.set_terminal_keymaps()
    local opts = { noremap = true, buffer = 0 }
    -- Use <C-\> to toggle terminals when direction='float'
    vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
    vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
    -- We can use <C-h/j/k/l> to move cursor among windows(including terminal window)
    -- If we set direction='float', these key mappings wont' helpful
    vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
    vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
    vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
    vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
end

-- if you only want these mappings for toggle term use term://*toggleterm#* instead
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')


-- Toggleterm also exposes the `Terminal` class so that this can be used to create
-- custom terminals for showing terminal UIs like `lazygit`, `htop` etc.
local Terminal = require('toggleterm.terminal').Terminal

-- cmd = string -- command to execute when creating the terminal e.g. 'top'
local htop = Terminal:new({ cmd = 'htop', hidden = true })

function _HTOP_TOGGLE()
    htop:toggle()
end







