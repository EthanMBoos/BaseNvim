-- In-buffer Git actions, full diff review, and GitLab merge requests.

require('diffview').setup()
vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = '[G]it [D]iff against HEAD' })
vim.keymap.set('n', '<leader>gc', '<cmd>DiffviewClose<CR>', { desc = '[G]it diff [C]lose' })
vim.keymap.set('n', '<leader>gh', '<cmd>DiffviewFileHistory %<CR>', { desc = '[G]it [H]istory (current file)' })
vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory<CR>', { desc = '[G]it [H]istory (repo)' })
vim.keymap.set('v', '<leader>gL', ':<C-u>DiffviewFileHistory --follow -L<C-r>=line("\'<")<CR>,<C-r>=line("\'>")<CR>:%<CR>', { desc = '[G]it [L]ine history (selection)' })

-- GitLab's setup builds and starts its Go helper, so proxy its global mappings
-- and initialize the plugin only when a GitLab action is actually requested.
local function gitlab_action(action, opts)
  local gitlab = require 'gitlab'
  gitlab.setup()
  gitlab[action](opts)
end

local gitlab_maps = {
  { 'glaa', 'add_assignee', 'Add MR assignee' },
  { 'glad', 'delete_assignee', 'Delete MR assignee' },
  { 'glla', 'add_label', 'Add MR label' },
  { 'glld', 'delete_label', 'Delete MR label' },
  { 'glra', 'add_reviewer', 'Add MR reviewer' },
  { 'glrd', 'delete_reviewer', 'Delete MR reviewer' },
  { 'glA', 'approve', 'Approve MR' },
  { 'glR', 'revoke', 'Revoke MR approval' },
  { 'glM', 'merge', 'Merge MR' },
  { 'glm', 'merge', 'Set MR to auto-merge', { auto_merge = true } },
  { 'glrr', 'rebase', 'Rebase MR' },
  { 'glrs', 'rebase', 'Rebase MR and skip CI', { skip_ci = true } },
  { 'glrf', 'rebase', 'Force rebase MR', { force = true } },
  { 'glC', 'create_mr', 'Create MR' },
  { 'glc', 'choose_merge_request', 'Choose MR for review' },
  { 'glS', 'review', 'Start MR review' },
  { 'gl<C-R>', 'reload_review', 'Reload MR review' },
  { 'gls', 'summary', 'Show MR summary' },
  { 'glu', 'copy_mr_url', 'Copy MR URL' },
  { 'glo', 'open_in_browser', 'Open MR in browser' },
  { 'gln', 'create_note', 'Create MR note' },
  { 'glp', 'pipeline', 'Show MR pipeline status' },
  { 'gld', 'toggle_discussions', 'Toggle MR discussions' },
  { 'glD', 'toggle_draft_mode', 'Toggle MR draft-comment mode' },
  { 'glP', 'publish_all_drafts', 'Publish all MR comment drafts' },
}
for _, mapping in ipairs(gitlab_maps) do
  local lhs, action, desc, opts = mapping[1], mapping[2], mapping[3], mapping[4]
  vim.keymap.set('n', lhs, function() gitlab_action(action, opts) end, { desc = desc })
end

require('gitsigns').setup {
  signs = {
    add = { text = '▎' },
    change = { text = '▎' },
    delete = { text = '' },
    topdelete = { text = '' },
    changedelete = { text = '▎' },
  },
  on_attach = function(bufnr)
    local gs = require 'gitsigns'
    local function map(mode, keys, func, desc)
      vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = desc })
    end

    map('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gs.nav_hunk('next')
      end
    end, 'Next git hunk')
    map('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gs.nav_hunk('prev')
      end
    end, 'Previous git hunk')
    map('n', '<leader>gp', gs.preview_hunk, '[G]it [P]review hunk')
    map('n', '<leader>gi', gs.preview_hunk_inline, '[G]it preview hunk [I]nline')
    map('n', '<leader>gS', gs.stage_hunk, '[G]it [S]tage hunk')
    map('n', '<leader>gU', gs.undo_stage_hunk, '[G]it [U]ndo stage hunk')
    map('n', '<leader>gR', gs.reset_hunk, '[G]it [R]eset hunk')
    map('n', '<leader>gb', gs.toggle_current_line_blame, '[G]it [B]lame line (toggle)')
    map('n', '<leader>gw', gs.toggle_word_diff, '[G]it [W]ord diff (toggle)')
    map('n', '<leader>gq', function() gs.setqflist(0) end, '[G]it hunks to [Q]uickfix')
    map('n', '<leader>gQ', function() gs.setqflist('all') end, '[G]it repo hunks to [Q]uickfix')
    map({ 'o', 'x' }, 'ih', gs.select_hunk, 'Select git hunk')
  end,
}
