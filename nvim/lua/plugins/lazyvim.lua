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
}
