-- A blazing fast and easy to configure neovim statusline plugin written in pure lua.
-- DOC: https://github.com/nvim-lualine/lualine.nvim/blob/master/doc/lualine.txt
return {
  'nvim-lualine/lualine.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('lualine').setup({
      options = {
        theme = 'auto',
        component_separators = { left = '⎮', right = '⎮'},
        section_separators = { left = '', right = ''},
      },
      sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename', 'searchcount', 'selectioncount'},
        lualine_x = {'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'},
      },
    })
  end
}
