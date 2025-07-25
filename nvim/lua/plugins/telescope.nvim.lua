return {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = "Telescope",
    version = false, -- telescope did only one release, so use HEAD for now
    keys = {
      { "<leader>,", "<cmd>Telescope buffers show_all_buffers=true<cr>", desc = "Switch Buffer" },
      { "<leader>:", "<cmd>Telescope command_history<cr>",               desc = "Command History" },
      { "<C-p>",     "<cmd>Telescope git_files previewer=false<cr>",     desc = "Find Files (git-files)" },
      { "<D-p>",     "<cmd>Telescope git_files previewer=false<cr>",     desc = "Find Files (git-files)" },

      { "<C-S-p>",    "<cmd>Telescope commands<cr>", desc = "Commands" },
    },
    opts = function()
      return {
        defaults = {
          path_display = {
            "filename_first"
          },
        }
      }
    end

  }
