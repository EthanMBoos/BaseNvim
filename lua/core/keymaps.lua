vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Buffer cycling
vim.keymap.set('n', '<Tab>',     '<cmd>BufferLineCycleNext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<S-Tab>',   '<cmd>BufferLineCyclePrev<CR>', { desc = 'Prev buffer' })
vim.keymap.set('n', '<leader>x', function()
  Snacks.bufdelete()
end, { desc = 'Close buffer' })

-- Toggle soft-wrap for the current window (handy for wide code, tables, logs)
vim.keymap.set('n', '<leader>uw', function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify('wrap ' .. (vim.wo.wrap and 'on' or 'off'))
end, { desc = '[U]I: Toggle line [W]rap' })

-- Escape stays a Neovim thing everywhere, including terminal buffers: a single <Esc>
-- drops straight to normal mode with no delay. Trade-off: terminal programs (Claude Code,
-- less, etc.) never receive <Esc> — interrupt/stop Claude with <C-c> from insert mode.
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Ctrl+h/j/k/l navigation and Ctrl+s + h/j/k/l resizing are provided by
-- smart-splits.nvim so both operations cross Neovim/tmux boundaries.

-- Neovim window splits
vim.keymap.set('n', '<leader>\\', '<cmd>vsp<CR>',   { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>-',  '<cmd>sp<CR>',    { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>w',  '<cmd>close<CR>', { desc = 'Close current [W]indow' })
