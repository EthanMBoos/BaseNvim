vim.loader.enable()

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Disable netrw so Snacks Explorer is the sole owner of directory buffers.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require('core.options')
require('core.keymaps')
require('core.autocmds')

require('core.pack')
require('plugins.ui')
require('plugins.treesitter')
require('plugins.explorer')
require('plugins.navigation')
require('plugins.git')
require('plugins.editing')
require('plugins.search')

-- vim: ts=2 sts=2 sw=2 et
