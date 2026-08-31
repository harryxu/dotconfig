return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "MunifTanjim/nui.nvim",
    "nvim-tree/nvim-web-devicons", -- optional, but recommended
  },
  lazy = false, -- neo-tree will lazily load itself
  opts = {
    window = {
      width = 28, -- default width
    },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = { enabled = false },
      hijack_netrw_behavior = "open_default", -- open as default sidebar when launching with a directory
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
      },
    },
  },
}
