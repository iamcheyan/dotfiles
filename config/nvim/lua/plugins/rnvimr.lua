return {
  "kevinhwang91/rnvimr",
  cmd = "RnvimrToggle",
  keys = {
    { "<leader>E", "<cmd>RnvimrToggle<cr>", desc = "Ranger (cwd)" },
  },
  init = function()
    -- rnvimr variables must be set before the plugin loads.
    vim.g.rnvimr_enable_ex = 1
    vim.g.rnvimr_enable_picker = 1
    vim.g.rnvimr_edit_cmd = "edit"
    vim.g.rnvimr_border_attr = { fg = 14, bg = -1 }
    vim.g.rnvimr_presets = {
      { width = 0.9, height = 0.9, col = 0.05, row = 0.05 },
    }

    vim.api.nvim_create_autocmd("TermEnter", {
      group = vim.api.nvim_create_augroup("RnvimrRedraw", { clear = true }),
      callback = function(args)
        if vim.bo[args.buf].filetype ~= "rnvimr" then
          return
        end

        -- Reusing rnvimr's terminal under zellij can leave curses one row
        -- scrolled. Ranger's redraw key restores the full window.
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(args.buf) then
            local channel = vim.bo[args.buf].channel
            if channel > 0 then
              vim.api.nvim_chan_send(channel, "\x0c")
            end
          end
        end)
      end,
    })
  end,
}
