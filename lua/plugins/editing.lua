-- Focused editing helpers; intentionally no completion, correction, LSP, or AI.

require('log-highlight').setup {}
require('grug-far').setup()
vim.keymap.set('n', '<leader>fr', '<cmd>GrugFar<CR>', { desc = '[F]ind and [R]eplace (grug-far)' })

require('guess-indent').setup()

require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>f', group = '[F]ind/[F]iles' },
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>u', group = '[U]I' },
    { '<leader>g', group = '[G]it' },
  },
}

require('todo-comments').setup { signs = false }
require('mini.ai').setup {
  mappings = { around_next = 'aa', inside_next = 'ii' },
  n_lines = 500,
}
require('mini.surround').setup()

-- Snacks visualizes Neovim's native persistent undo tree; selecting an entry
-- previews its diff and Enter restores that historical buffer state.
vim.keymap.set('n', '<leader>uu', function() Snacks.picker.undo { focus = 'list' } end, {
  desc = '[U]I: Visual [U]ndo history',
})

local quicker = require 'quicker'
quicker.setup {
  keys = {
    {
      '>',
      function() quicker.expand { before = 2, after = 2, add_to_existing = true } end,
      desc = 'Expand quickfix context',
    },
    {
      '<',
      function() quicker.collapse() end,
      desc = 'Collapse quickfix context',
    },
  },
}
vim.keymap.set('n', '<leader>q', function() quicker.toggle() end, { desc = 'Toggle [Q]uickfix' })
