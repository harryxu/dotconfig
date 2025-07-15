-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local Util = require("lazyvim.util")

local function map(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  -- do not create the keymap if a lazy keys handler exists
  if not keys.active[keys.parse({ lhs, mode = mode }).id] then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      opts.remap = nil
    end
    vim.keymap.set(mode, lhs, rhs, opts)
  end
end

local keymap = vim.keymap

keymap.set('n', '<F2>', ':nohlsearch<CR>')

-- save file
map({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

keymap.set('n', '<D-s>', ':update<CR>')
keymap.set('v', '<D-s>', '<C-C>:update<CR>')
keymap.set('i', '<D-s>', '<C-O>:update<CR>')

-- Commenting
if vim.loop.os_uname().sysname == 'Darwin' then
  keymap.set('v', '<D-/>', 'gc', { remap = true })
  keymap.set('n', '<D-/>', ':norm gcc<CR>')
  keymap.set('i', '<D-/>', '<ESC>:norm gcc<CR>')
end

keymap.set('v', '<C-/>', 'gc', { remap = true })
keymap.set('n', '<C-/>', ':norm gcc<CR>')
keymap.set('i', '<C-/>', '<ESC>:norm gcc<CR>')

-- copy to clip board by ctrl/command c
keymap.set('v', '<C-c>', '"+y')
keymap.set('v', '<D-c>', '"+y')

if Util.has("vim-tmux-navigator") then
  map({'n'}, '<C-H>', ':<C-U>TmuxNavigateLeft<cr>', { silent = true })
  map({'n'}, '<C-J>', ':<C-U>TmuxNavigateDown<cr>', { silent = true })
  map({'n'}, '<C-K>', ':<C-U>TmuxNavigateUp<cr>', { silent = true })
  map({'n'}, '<C-L>', ':<C-U>TmuxNavigateRight<cr>', { silent = true })
end
