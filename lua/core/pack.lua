local function gh(repo)
  return 'https://github.com/' .. repo
end

-- Hooks must exist before the first vim.pack call so they also run while
-- restoring a fresh machine from nvim-pack-lock.json.
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('native-package-hooks', { clear = true }),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind
    if kind ~= 'install' and kind ~= 'update' then return end

    if name == 'nvim-treesitter' and kind == 'update' then
      vim.cmd.packadd('nvim-treesitter')
      vim.cmd('TSUpdate')
    end
  end,
})

-- Dependencies precede their consumers. Default branches are intentional;
-- exact working revisions are recorded in the committed native lockfile.
vim.pack.add({
  gh('nvim-lua/plenary.nvim'),
  gh('MunifTanjim/nui.nvim'),
  gh('nvim-mini/mini.nvim'),

  gh('navarasu/onedark.nvim'),
  gh('rebelot/heirline.nvim'),
  gh('akinsho/bufferline.nvim'),
  gh('folke/snacks.nvim'),
  gh('folke/flash.nvim'),
  gh('mrjones2014/smart-splits.nvim'),
  gh('fei6409/log-highlight.nvim'),
  gh('MagicDuck/grug-far.nvim'),
  gh('NMAC427/guess-indent.nvim'),
  gh('dlyongemallo/diffview.nvim'),
  gh('harrisoncramer/gitlab.nvim'),
  gh('lewis6991/gitsigns.nvim'),
  gh('folke/which-key.nvim'),
  gh('folke/todo-comments.nvim'),
  gh('ibhagwan/fzf-lua'),
  gh('stevearc/quicker.nvim'),
  {
    src = gh('nvim-treesitter/nvim-treesitter'),
    version = 'main',
  },
  gh('nvim-treesitter/nvim-treesitter-context'),
  gh('MeanderingProgrammer/render-markdown.nvim'),
}, {
  -- Preserve the native confirmation by default. Tests and intentional
  -- unattended bootstraps can opt in with NVIM_PACK_AUTO_INSTALL=1.
  confirm = vim.env.NVIM_PACK_AUTO_INSTALL ~= '1',
})

-- Neovim 0.12 exposes the native update workflow through Lua but does not yet
-- provide an Ex command for it.
vim.api.nvim_create_user_command('PackUpdate', function(opts)
  vim.pack.update(#opts.fargs > 0 and opts.fargs or nil)
end, {
  nargs = '*',
  desc = 'Review and update native vim.pack plugins',
})
