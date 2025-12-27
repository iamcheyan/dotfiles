local is_ok, configs = pcall(require, 'nvim-treesitter.configs')
if not is_ok then
    return
end

configs.setup({
    -- A list of parser names, or "all" (the four listed parsers should always be installed)
    ensure_installed = {
        'c', 'lua', 'vim', 'help',
        'yaml', 'toml', 'scheme', 'scala',
        'rust', 'python', 'ocaml', 'make',
        'json', 'llvm', 'dockerfile',
        'git_rebase', 'gitcommit', 'gitattributes', 'gitignore',
        'gomod', 'go',
        'comment', -- for tags like TODO:, FIXME(user)
        'diff', -- git diff
    },
    -- ensure_installed = { 'all' },
    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,
    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    -- 如果遇到 GLIBC 版本问题，可以设置为 false，然后手动安装解析器
    auto_install = false, -- 暂时禁用自动安装，避免 GLIBC 版本问题
    -- List of parsers to ignore installing (for "all")
    ignore_install = { "javascript" },
    ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
    -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

    highlight = {
        -- When `enable` is `true` this will enable the module for all supported languages,
        -- `false` will disable the whole extension
        enable = true,

        -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
        -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
        -- the name of the parser)
        -- if you want to disable the module for some languages you can pass a list to the `disable` option.
        disable = { "c", "rust" },
        -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
        -- disable = function(lang, buf)
        --     local max_filesize = 100 * 1024 -- 100 KB
        --     local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        --     if ok and stats and stats.size > max_filesize then
        --         return true
        --     end
        -- end,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },
    -- Indentation based on treesitter for the = operator. NOTE: This is an experimental feature.
    -- indent = {
    --     enable = true
    -- },
    incremental_selection = {
        enable = true,
        -- init_selection: in normal mode, start incremental selection.
        -- node_incremental: in visual mode, increment to the upper named parent.
        -- scope_incremental: in visual mode, increment to the upper scope
        -- node_decremental: in visual mode, decrement to the previous named node.
        keymaps = {
            init_selection = "gnn",
            node_incremental = "grn",
            scope_incremental = "grc",
            node_decremental = "grm",
        },
    },
})

-- Hints:
--   A uppercase letter followed `z` means recursive
--   zo: open one fold under the cursor
--   zc: close one fold under the cursor
--   za: toggle the folding
--   zv: open just enough folds to make the line in which the cursor is located not folded
--   zM: Close all foldings
--   zR: Open all foldings
-- source: https://github.com/nvim-treesitter/nvim-treesitter/wiki/Installation
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufAdd', 'BufNew', 'BufNewFile', 'BufWinEnter' }, {
    group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
    callback = function()
        vim.opt.foldmethod = 'expr'
        vim.opt.foldexpr   = 'nvim_treesitter#foldexpr()'
    end
})
