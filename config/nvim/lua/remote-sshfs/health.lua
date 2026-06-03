-- User config health (always on rtp). Checks sshfs even when plugin is lazy-loaded.
local M = {}

function M.check()
  vim.health.start("remote-sshfs")

  if vim.fn.executable("ssh") ~= 1 then
    vim.health.error("ssh not found in PATH")
  else
    vim.health.ok("ssh found: " .. vim.fn.exepath("ssh"))
  end

  if vim.fn.executable("sshfs") ~= 1 then
    vim.health.error(
      "sshfs not found. Install on macOS:\n"
        .. "  brew install --cask macfuse\n"
        .. "  brew install gromgit/fuse/sshfs-mac\n"
        .. "Then log out/in and run: which sshfs"
    )
  else
    vim.health.ok("sshfs found: " .. vim.fn.exepath("sshfs"))
  end

  local unmount = vim.fn.executable("fusermount") == 1 and "fusermount"
    or vim.fn.executable("umount") == 1 and "umount"
    or nil
  if unmount then
    vim.health.ok("unmount tool: " .. unmount)
  else
    vim.health.warn("no fusermount/umount; disconnect may fail")
  end

  local ok, connections = pcall(require, "remote-sshfs.connections")
  if ok and connections.is_connected() then
    vim.health.ok(
      "connected: "
        .. (connections.get_current_host() or "?")
        .. " @ "
        .. (connections.get_current_mount_point() or "?")
    )
  else
    vim.health.info("not connected — use <leader>rc or :RemoteSSHFSConnect")
  end
end

return M