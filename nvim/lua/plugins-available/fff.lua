return {
  "dmtrKovalenko/fff.nvim",
  build = function()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  opts = {
    debug = {
      enabled = true,
      show_scores = true,
    },
  },
  lazy = false, -- the plugin lazy-initialises itself
  keys = {
    {
      "<D-p>",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "<A-p>",
      function()
        require("fff").find_files()
      end,
      desc = "FFFind files",
    },
    {
      "<D-F>",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },
    {
      "<A-F>",
      function()
        require("fff").live_grep()
      end,
      desc = "LiFFFe grep",
    },

    {
      "fc",
      function()
        require("fff").live_grep({ query = vim.fn.expand("<cword>") })
      end,
      desc = "Search current word",
    },
  },
}
