return {

  -- Plugin manager
  { "folke/lazy.nvim", version = "*" },

  -- Neovim config for the lazy
  {
    "LazyVim/LazyVim",
    priority = 10000,
    lazy = false,
    config = true,
    cond = true,
    version = "*",
    opts = {
      colorscheme = "nordfox",
    },
  },

  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    opts = {
      cmdline = {
        view = "cmdline_popup",
      },
      views = {
        cmdline_popup = {
          position = {
            row = "38%",
            col = "50%",
          },
          size = {
            width = "60%",
            height = "auto",
          },
        },
      },
    },
  },
}
