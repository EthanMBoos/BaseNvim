-- fzf-lua search over hidden and ignored source trees, with noisy outputs excluded.

local rg_globs = table.concat({
  [[--glob '!**/.git']],
  [[--glob '!**/.git/**']],
  [[--glob '!**/build*/**']],
  [[--glob '!**/node_modules/**']],
}, ' ')
local rg_files = 'rg --files --hidden --no-ignore ' .. rg_globs
local rg_grep = '--column --line-number --no-heading --color=always --smart-case --hidden --no-ignore '
  .. rg_globs .. ' -e'
local rg_word = '--column --line-number --no-heading --color=always --smart-case --hidden --no-ignore --word-regexp '
  .. rg_globs .. ' -e'

local fzf = require 'fzf-lua'
fzf.setup {
  winopts = {
    width = 0.90,
    height = 0.85,
    preview = {
      layout = 'flex',
      flip_columns = 120,
      horizontal = 'right:50%',
      vertical = 'down:45%',
      wrap = true,
    },
  },
  fzf_opts = { ['--layout'] = 'reverse-list' },
  files = {
    cmd = rg_files,
    formatter = 'path.filename_first',
    path_shorten = 1,
  },
  grep = {
    rg_opts = rg_grep,
    formatter = 'path.filename_first',
    path_shorten = 1,
  },
}
fzf.register_ui_select()

vim.keymap.set('n', '<leader>sh', fzf.helptags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>ff', fzf.files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fw', fzf.live_grep, { desc = '[F]ind by [W]ord (grep)' })
vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect picker' })
vim.keymap.set({ 'n', 'v' }, '<leader>fc', function()
  if vim.fn.mode():match('[vV\22]') then
    fzf.grep_visual({ rg_opts = rg_grep })
  else
    fzf.grep_cword({ rg_opts = rg_word })
  end
end, { desc = '[F]ind word under [C]ursor or selection' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', function()
  if vim.fn.mode():match('[vV\22]') then
    fzf.grep_visual({ rg_opts = rg_grep })
  else
    fzf.grep_cword({ rg_opts = rg_word })
  end
end, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sr', fzf.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', fzf.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', fzf.blines, { desc = '[/] Fuzzily search in current buffer' })
vim.keymap.set('n', '<leader>s/', fzf.lines, { desc = '[S]earch [/] in Open Buffers' })
vim.keymap.set('n', '<leader>sn', function()
  fzf.files { cwd = vim.fn.stdpath('config'), follow = true }
end, { desc = '[S]earch [N]eovim files' })
