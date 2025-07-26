return {
  "neovim/nvim-lspconfig",
  opts = {
    diagnostics = {
      virtual_text = false,
      float = {
        source = "always",
        border = "rounded",
      },
    },
  },
}
