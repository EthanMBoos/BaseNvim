local config_init = assert(vim.env.BASENVIM_INIT, 'BASENVIM_INIT is not set')
local ok, err = xpcall(function() dofile(config_init) end, debug.traceback)

if not ok then
  io.stderr:write(err .. '\n')
  vim.cmd('cquit!')
end

vim.api.nvim_create_autocmd('VimEnter', {
  once = true,
  callback = function()
    vim.schedule(function()
      if vim.v.errmsg ~= '' then
        io.stderr:write(vim.v.errmsg .. '\n')
        vim.cmd('cquit!')
      else
        vim.cmd('qa!')
      end
    end)
  end,
})
