-- Color highlighter for Neovim
-- https://github.com/catgoose/nvim-colorizer.lua?tab=readme-ov-file#colorizerlua
return {
  "catgoose/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = { -- set to setup table
    filetypes = {
      "css",
      "html",
      "javascript",
      "javascriptreact",
      "typescript",
      "typescriptreact",
      "scss",
      "less",
    },
    user_default_options = { mode = "background" },
  },
}
