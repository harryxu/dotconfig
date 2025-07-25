return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, but recommended
  },
  lazy = false, -- neo-tree will lazily load itself
  config = function(_, opts)
    require("neo-tree").setup({
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = false },
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = false
        }
      }
    })
  end,
  opts = { }
}
