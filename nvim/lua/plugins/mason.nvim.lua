return {
  "mason-org/mason.nvim",
  opts_extend = { "ensure_installed" },
  opts = {
    ensure_installed = {
      -- LSP
      "typescript-language-server",
      "intelephense", -- PHP
      "lua-language-server",

      -- Formatters
      "stylua",
      "prettier",
      "black",
      "isort",
    },
  },
}
