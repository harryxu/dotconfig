-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Disable all animations with
vim.g.snacks_animate = false

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true

vim.scriptencoding = "utf-8"
vim.opt.encoding = "utf-8"
vim.opt.relativenumber = false
vim.opt.title = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.hlsearch = true

-- disable backup and swap
vim.opt.backup = false
vim.opt.swapfile = false

vim.opt.autoread = true
vim.opt.showcmd = true -- show incomplete cmds down the bottom
vim.opt.showmode = true -- show current mode down the bottom
vim.opt.number = true

-- Do Not mess up the system clipboard! I realy don't like LazyVim's default setting (unnamedplus) for this.
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua#L22
vim.opt.clipboard = ""

vim.opt.ignorecase = true
vim.opt.incsearch = true -- find the next match as we type the search
vim.opt.hlsearch = true -- hilight searches by default
vim.opt.smartcase = true
--vim.opt.autochdir = true -- switch to the directory of the open buffer

-- fold settings
vim.o.foldcolumn = "1" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]

vim.opt.wildmenu = true
vim.opt.completeopt = "longest,menuone"
vim.opt.splitbelow = true
vim.opt.pumblend = 0

vim.o.guifont = "Iosevka NFM:h21"
