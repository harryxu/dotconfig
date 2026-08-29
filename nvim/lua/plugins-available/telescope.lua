return {
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  cmd = "Telescope",
  version = false, -- telescope did only one release, so use HEAD for now
  keys = {
    { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
    { "<leader>:", "<cmd>Telescope command_history<cr>", desc = "Command History" },
    { "<leader><space>", LazyVim.pick("find_files"), desc = "Find Files (Root Dir)" },
    { "<leader>ff", LazyVim.pick("find_files"), desc = "Find Files (Root Dir)" },
    { "<leader>fF", LazyVim.pick("find_files", { root = false }), desc = "Find Files (cwd)" },
    -- { "<C-p>", "<cmd>Telescope git_files previewer=false<cr>", desc = "Find Files (git-files)" },
    -- { "<D-p>", "<cmd>Telescope git_files previewer=false<cr>", desc = "Find Files (git-files)" },
  },

  opts = function(_, opts)
    local ignored_dirs = {
      ".git",
      "node_modules",
      "dist",
      "build",
      "coverage",
      ".next",
      ".nuxt",
      ".turbo",
      ".cache",
      ".venv",
      "target",
    }

    local ignore_globs = {}
    local file_ignore_patterns = {}
    for _, dir in ipairs(ignored_dirs) do
      table.insert(ignore_globs, "--glob")
      table.insert(ignore_globs, "!**/" .. dir .. "/**")
      table.insert(file_ignore_patterns, "/" .. vim.pesc(dir) .. "/")
    end

    local vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
      "--hidden",
      "--no-ignore",
    }
    vim.list_extend(vimgrep_arguments, ignore_globs)

    opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
      path_display = {
        "filename_first",
      },
      file_ignore_patterns = file_ignore_patterns,
      vimgrep_arguments = vimgrep_arguments,
    })

    opts.pickers = vim.tbl_deep_extend("force", opts.pickers or {}, {
      find_files = {
        hidden = true,
        no_ignore = true,
        find_command = vim.list_extend({
          "rg",
          "--files",
          "--color=never",
          "--hidden",
          "--no-ignore",
        }, ignore_globs),
      },
    })

    return opts
  end,
}
