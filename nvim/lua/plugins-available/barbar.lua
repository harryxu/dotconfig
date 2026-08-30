-- The neovim tabline plugin
return {
  "romgrk/barbar.nvim",
  event = "VeryLazy",
  opts = {
    auto_hide = 1,
  },
  dependencies = {
    "lewis6991/gitsigns.nvim", -- OPTIONAL: for git status
    "nvim-tree/nvim-web-devicons", -- OPTIONAL: for file icons
  },
  -- init = function() vim.g.barbar_auto_setup = false end,
}
