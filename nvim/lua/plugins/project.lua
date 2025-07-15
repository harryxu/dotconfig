return {
  {
    "ahmedkhalf/project.nvim",
    opts = {},
    event = "VeryLazy",
    config = function(_, opts)
      require("project_nvim").setup(opts)
      require("telescope").load_extension("projects")
    end,
    keys = {
      { "<leader>fp", "<Cmd>Telescope projects<CR>", desc = "Projects" },
    },
  },

  -- nvim tree
  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function(_, opts)
      vim.keymap.set({ 'n', 'i', 'v' }, '<F3>', '<ESC>:Neotree toggle<CR>')
      require("neo-tree").setup({
        filesystem = {
          filtered_items = {
            hide_dotfiles = false,
            hide_gitignored = false
          }
        }
      })
    end,
    opts = { }
  },

}
