return {
  "folke/snacks.nvim",
  opts = {
    dashboard = { enabled = false },
    notifier = {
      enabled = true,
      timeout = 6500, -- default timeout in ms (default: 3000)
      width = { min = 40, max = 0.7 }, -- allow width up to 70% of screen (default: 0.4)
    },
    styles = {
      notification = {
        wo = {
          wrap = true, -- wrap long notification text
          linebreak = true, -- break lines on words
        },
      },
    },
  },
}
