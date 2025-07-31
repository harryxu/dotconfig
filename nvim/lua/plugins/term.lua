return {
  -- toggleterm
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    opts = {},
  },

  -- A plugin that leverages Neovim's built-in RPC functionality
  -- to simplify opening files from within Neovim's terminal emulator without nesting sessions.
  -- Working with Git: https://git.new/OGaMSPn
  -- Pass the g:unception_block_while_host_edits=1 in gitconfig
  -- [core]
  --    editor = nvim --cmd 'let g:unception_block_while_host_edits=1'
  {
    "samjwill/nvim-unception",
    init = function()
      -- Optional settings go here!
      -- e.g.) vim.g.unception_open_buffer_in_new_tab = true
    end,
  },
}
