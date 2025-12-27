-- define common options
local opts = {
    noremap = true, -- non-recursive
    silent = true, -- do not show message
}

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set('n', '<C-Up>', ':resize -2<CR>', opts)
vim.keymap.set('n', '<C-Down>', ':resize +2<CR>', opts)
vim.keymap.set('n', '<C-Left>', ':vertical resize -2<CR>', opts)
vim.keymap.set('n', '<C-Right>', ':vertical resize +2<CR>', opts)

-- for nvim-tree
-- default leader key: \
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', opts)

-----------------
-- Visual mode --
-----------------

-- Hint: start visual mode with the same area as the previous area and the same mode
vim.api.nvim_set_keymap('v', '<', '<gv', opts)
vim.api.nvim_set_keymap('v', '>', '>gv', opts)

-- 撤销
vim.api.nvim_set_keymap('n', '<C-z>', 'u', { silent = true })

-- 恢复撤销
vim.api.nvim_set_keymap('n', '<C-y>', '<C-r>', { silent = true })

-- 保存
vim.api.nvim_set_keymap('n', '<C-s>', ':w<CR>', { silent = true })

-- 直接退出
vim.api.nvim_set_keymap('n', '<C-q>', ':q!<CR>', { silent = true })

-- 复制、剪切、粘贴
vim.api.nvim_set_keymap('v', '<C-c>', '"+y', { silent = true })
vim.api.nvim_set_keymap('v', '<C-x>', '"+d', { silent = true })
vim.api.nvim_set_keymap('n', '<C-v>', '"+p', { silent = true })

-- 打开文件
vim.api.nvim_set_keymap('n', '<C-o>', ':e<CR>', { silent = true })

-- 新建文件
vim.api.nvim_set_keymap('n', '<C-n>', ':enew<CR>', { silent = true })

-- 关闭当前窗口
vim.api.nvim_set_keymap('n', '<C-w>', ':q<CR>', { silent = true })

-- 在新标签页中打开文件
vim.api.nvim_set_keymap('n', '<C-t>', ':tabnew<CR>', { silent = true })

-- 下一个缓冲区
vim.api.nvim_set_keymap('n', '<C-f>', ':bnext<CR>', { silent = true })

-- 上一个缓冲区
vim.api.nvim_set_keymap('n', '<C-b>', ':bprevious<CR>', { silent = true })

-- 注释/取消注释当前行或选中的多行
vim.api.nvim_set_keymap('n', '<C-/>', ':CommentToggle<CR>', { silent = true })