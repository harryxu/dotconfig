return {
  "rebelot/heirline.nvim",
  event = "UiEnter",
  dependencies = {
    "nvim-tree/nvim-web-devicons", -- optional, but recommended
  },
  config = function()
    require("heirline").setup({
      statusline = require("plugins.heirline.statusline").statusline,
      opts = {
        colors = require("plugins.heirline.common").setup_colors,
      },
    })
  end,
}
