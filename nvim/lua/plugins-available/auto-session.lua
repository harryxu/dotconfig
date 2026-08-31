return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    suppressed_dirs = { "~/", "~/dev", "~/Downloads" },
  },
  init = function()
    -- Automatically restore neo-tree sidebar whenever a session is loaded
    vim.api.nvim_create_autocmd("SessionLoadPost", {
      group = vim.api.nvim_create_augroup("auto_session_restore_neotree", { clear = true }),
      callback = function()
        vim.schedule(function()
          -- Safely execute only when neo-tree is available
          local ok, neotree_cmd = pcall(require, "neo-tree.command")
          if ok and type(neotree_cmd.execute) == "function" then
            pcall(neotree_cmd.execute, { action = "show", dir = vim.uv.cwd() })
          end
        end)
      end,
    })
  end,
}
