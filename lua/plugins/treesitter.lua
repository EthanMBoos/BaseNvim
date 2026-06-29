-- nvim-treesitter's rewritten main branch: parser installation is explicit,
-- while highlighting and indentation use Neovim's native FileType APIs.
local treesitter = require 'nvim-treesitter'

local parsers = {
  'bash', 'c', 'cpp', 'diff', 'html', 'lua', 'luadoc',
  'markdown', 'markdown_inline', 'query', 'regex', 'toml', 'vim', 'vimdoc', 'yaml',
}
treesitter.install(parsers)

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('treesitter-enable', { clear = true }),
  pattern = { 'bash', 'sh', 'zsh', 'c', 'cpp', 'diff', 'html', 'lua', 'markdown', 'query', 'toml', 'vim', 'yaml' },
  callback = function()
    vim.treesitter.start()
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

require('treesitter-context').setup {
  max_lines = 2,
  trim_scope = 'outer',
  mode = 'cursor',
}
vim.keymap.set('n', '<leader>ut', '<cmd>TSContext toggle<CR>', {
  desc = '[U]I: Toggle Treesitter con[T]ext',
})

require('render-markdown').setup {
  enabled = true,
  file_types = { 'markdown' },
  heading = {
    sign = false,
    icons = { '# ', '## ', '### ', '#### ', '##### ', '###### ' },
    width = 'block',
  },
  code = {
    sign = false, -- Keep the language icon in the block header, not the gutter too.
  },
  -- Keep YAML/TOML frontmatter, but avoid requiring a separate TeX renderer.
  latex = { enabled = false },
}
vim.keymap.set('n', '<leader>um', function()
  require('render-markdown').buf_toggle()
end, { desc = '[U]I: Toggle rendered [M]arkdown for buffer' })
