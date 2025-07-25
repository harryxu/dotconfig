-- auto completion
return {
    'hrsh7th/nvim-cmp',
    version = false, -- last release is way too old
    event = 'InsertEnter',
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'saadparwaiz1/cmp_luasnip',
      'octaltree/cmp-look',
      'brenoprata10/nvim-highlight-colors',
    },
    opts = function()
      -- vim.api.nvim_set_hl(0, 'CmpGhostText', { link = 'Comment', default = true })
      local cmp = require('cmp')
      local defaults = require('cmp.config.default')()

      local function get_icon_provider()
        local _, mini_icons = pcall(require, "mini.icons")
        return function(kind) return mini_icons.get("lsp", kind or "") end
      end
      local icon_provider = get_icon_provider()

      local function format(entry, item)
        local highlight_colors_avail, highlight_colors = pcall(require, "nvim-highlight-colors")
        local color_item = highlight_colors_avail and highlight_colors.format(entry, { kind = item.kind })
        -- item.menu = item.kind
        item.menu = entry.source.name
        if icon_provider then
          local icon = icon_provider(item.kind)
          if icon then
            item.kind = ' ' .. icon .. ' '
          end
        end
        if color_item and color_item.abbr and color_item.abbr_hl_group then
          item.kind, item.kind_hl_group = color_item.abbr, color_item.abbr_hl_group
        end
        return item
      end

      return {
        completion = {
          completeopt = 'menu,menuone,noinsert',
        },
        window = {
          completion = cmp.config.window.bordered {
            col_offset = -2,
            side_padding = 0,
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
          documentation = cmp.config.window.bordered {
            border = "rounded",
            winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
          },
        },
        snippet = {
          expand = function(args)
            require('luasnip').lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-n>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-p>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ['<S-CR>'] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
          {
            name = 'look',
            keyword_length = 3,
            option = {
              convert_case = true,
              loud = true
            }
          }
        }),
        sorting = defaults.sorting,
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = format,
        },
      }
    end,
  }
