vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local whitespace_sensitive = {
  diff = true,
  gitcommit = true,
  mail = true,
  markdown = true,
}

vim.api.nvim_create_autocmd('BufWritePre', {
  desc = 'Trim trailing whitespace when the file format does not preserve it',
  group = vim.api.nvim_create_augroup('trim-whitespace', { clear = true }),
  callback = function(args)
    local bo = vim.bo[args.buf]
    if bo.buftype ~= '' or bo.binary or not bo.modifiable or bo.readonly then return end
    if whitespace_sensitive[bo.filetype] then return end

    -- An explicit project policy wins; Neovim's built-in EditorConfig plugin
    -- performs the trim itself when trim_trailing_whitespace is true.
    local editorconfig = vim.b[args.buf].editorconfig
    if type(editorconfig) == 'table' and editorconfig.trim_trailing_whitespace ~= nil then return end

    local views = {}
    for _, win in ipairs(vim.fn.win_findbuf(args.buf)) do
      views[win] = vim.api.nvim_win_call(win, vim.fn.winsaveview)
    end

    vim.api.nvim_buf_call(args.buf, function()
      vim.cmd [[silent keepjumps keeppatterns %s/\s\+$//e]]
    end)

    for win, view in pairs(views) do
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_call(win, function() vim.fn.winrestview(view) end)
      end
    end
  end,
})

vim.filetype.add {
  extension = { launch = 'xml' },
  pattern = { ['.*/CMakeLists%-[^/]*%.txt'] = 'cmake' },
}

-- Auto-reload buffers when the file changes on disk (e.g. edited by another tool).
-- autoread only reloads when Neovim re-checks the timestamp, so nudge it on these events.
local reload = vim.api.nvim_create_augroup('auto-reload-file', { clear = true })
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  group = reload,
  callback = function()
    -- Skip command-line window and unnamed/special buffers where checktime errors
    if vim.fn.getcmdwintype() == '' and vim.bo.buftype == '' then
      vim.cmd('checktime')
    end
  end,
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  group = reload,
  callback = function()
    vim.notify('File changed on disk — buffer reloaded', vim.log.levels.INFO)
  end,
})

-- Terminal buffers (e.g. the Claude Code window) start typing immediately instead of
-- landing in terminal-normal mode — so you can answer prompts without first pressing `i`.
-- Press <Esc> to drop to normal mode (to scroll); re-focusing the window resumes insert.
vim.api.nvim_create_autocmd({ 'TermOpen', 'WinEnter' }, {
  group = vim.api.nvim_create_augroup('term-auto-insert', { clear = true }),
  callback = function()
    if vim.bo.buftype == 'terminal' then
      vim.cmd.startinsert()
    end
  end,
})
