-- Fast motions and seamless navigation across Neovim windows and tmux panes.

require('flash').setup()
vim.keymap.set({ 'n', 'x', 'o' }, 's', function() require('flash').jump() end, { desc = 'Flash jump' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() require('flash').treesitter() end, { desc = 'Flash treesitter select' })
vim.keymap.set('o', 'r', function() require('flash').remote() end, { desc = 'Flash remote' })

-- smart-splits must know the multiplexer before its plugin file runs so it can
-- maintain tmux's pane-local @pane-is-vim marker.
if vim.env.TMUX then vim.g.smart_splits_multiplexer_integration = 'tmux' end
local splits = require 'smart-splits'
splits.setup {
  -- Sidebars such as Snacks Explorer are real resize targets in this setup.
  ignored_buftypes = {},
  ignored_filetypes = {},
  default_amount = 5,
  at_edge = 'stop',
  disable_multiplexer_nav_when_zoomed = true,
}

local normal_maps = {
  ['<C-h>'] = { splits.move_cursor_left, 'Navigate left' },
  ['<C-j>'] = { splits.move_cursor_down, 'Navigate down' },
  ['<C-k>'] = { splits.move_cursor_up, 'Navigate up' },
  ['<C-l>'] = { splits.move_cursor_right, 'Navigate right' },
  ['<C-s>h'] = { splits.resize_left, 'Resize left' },
  ['<C-s>j'] = { splits.resize_down, 'Resize down' },
  ['<C-s>k'] = { splits.resize_up, 'Resize up' },
  ['<C-s>l'] = { splits.resize_right, 'Resize right' },
}
for lhs, mapping in pairs(normal_maps) do
  vim.keymap.set('n', lhs, mapping[1], { desc = mapping[2] })
end

local function terminal_map(lhs, action, desc)
  vim.keymap.set('t', lhs, function()
    vim.cmd.stopinsert()
    action()
  end, { desc = desc })
end
terminal_map('<C-h>', splits.move_cursor_left, 'Navigate left')
terminal_map('<C-j>', splits.move_cursor_down, 'Navigate down')
terminal_map('<C-k>', splits.move_cursor_up, 'Navigate up')
terminal_map('<C-l>', splits.move_cursor_right, 'Navigate right')
terminal_map('<C-s>h', splits.resize_left, 'Resize left')
terminal_map('<C-s>j', splits.resize_down, 'Resize down')
terminal_map('<C-s>k', splits.resize_up, 'Resize up')
terminal_map('<C-s>l', splits.resize_right, 'Resize right')
