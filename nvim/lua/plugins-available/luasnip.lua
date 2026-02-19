return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  -- dependencies = {
  --   "rafamadriz/friendly-snippets",
  --   config = function()
  --     require("luasnip.loaders.from_vscode").lazy_load()
  --   end,
  -- },
  opts = {
    history = true,
    delete_check_events = "TextChanged",
  },
  keys = {
    {
      "<C-L>",
      function()
        require("luasnip").jump(1)
      end,
      silent = true,
      mode = { "i", "s" },
    },
    {
      "<C-H>",
      function()
        require("luasnip").jump(-1)
      end,
      silent = true,
      mode = { "i", "s" },
    },
  },
}
