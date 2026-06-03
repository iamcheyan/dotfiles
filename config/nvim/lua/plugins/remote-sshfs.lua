return {
  {
    "nosduco/remote-sshfs.nvim",
    -- Load after startup so :checkhealth remote-sshfs finds lua/remote-sshfs/health.lua
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "folke/snacks.nvim",
    },
    cmd = {
      "RemoteSSHFSConnect",
      "RemoteSSHFSDisconnect",
      "RemoteSSHFSEdit",
      "RemoteSSHFSFindFiles",
      "RemoteSSHFSLiveGrep",
    },
    keys = {
      { "<leader>rc", "<cmd>RemoteSSHFSConnect<cr>", desc = "Remote: Connect (SSHFS)" },
      { "<leader>rd", "<cmd>RemoteSSHFSDisconnect<cr>", desc = "Remote: Disconnect" },
      { "<leader>re", "<cmd>RemoteSSHFSEdit<cr>", desc = "Remote: Edit SSH config" },
      {
        "<leader>rf",
        function()
          if require("remote-sshfs.connections").is_connected() then
            require("remote-sshfs.api").find_files()
          else
            Snacks.picker.files()
          end
        end,
        desc = "Remote/Loc Find Files",
      },
      {
        "<leader>rg",
        function()
          if require("remote-sshfs.connections").is_connected() then
            require("remote-sshfs.api").live_grep()
          else
            Snacks.picker.grep()
          end
        end,
        desc = "Remote/Loc Live Grep",
      },
    },
    opts = {
      connections = {
        ssh_configs = {
          vim.fn.expand("~/.ssh/config"),
        },
        ssh_known_hosts = vim.fn.expand("~/.ssh/known_hosts"),
        sshfs_args = {
          "-o reconnect",
          "-o ConnectTimeout=10",
          "-o ServerAliveInterval=15",
          "-o ServerAliveCountMax=3",
        },
      },
      mounts = {
        base_dir = vim.fn.expand("~/.sshfs/"),
        unmount_on_exit = true,
      },
      handlers = {
        on_connect = {
          change_dir = true,
        },
        on_disconnect = {
          clean_mount_folders = false,
        },
      },
      ui = {
        picker = "snacks",
        confirm = {
          connect = true,
          change_dir = false,
        },
      },
    },
    config = function(_, opts)
      require("remote-sshfs").setup(opts)
    end,
  },
}