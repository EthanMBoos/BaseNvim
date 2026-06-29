-- Snacks Explorer, images, input UI, and conservative performance helpers.

local function compact_explorer_format(item, picker)
  local formatted = Snacks.picker.format.file(item, picker)
  local depth, node, ignored = 0, item, false
  while node do
    ignored = ignored or node.ignored == true
    if not node.parent then break end
    depth, node = depth + 1, node.parent
  end
  for _, part in ipairs(formatted) do
    if part[2] == 'SnacksPickerTree' then
      part[1] = string.rep(' ', depth) -- One column per level for deep repositories.
      break
    end
  end
  if ignored then
    for index = #formatted, 1, -1 do
      if formatted[index].virtual then
        formatted[index][2] = 'SnacksPickerPathIgnored' -- Gray the icon with its ignored path.
        break
      end
    end
  end
  return formatted
end

-- Desired visibility policy lives here: Explorer always shows hidden, ignored,
-- build*, and submodule content; grep/files show everything except .git,
-- build*/, and node_modules.
require('snacks').setup {
  bigfile = { enabled = true },
  explorer = {
    enabled = true,
    replace_netrw = true,
  },
  input = { enabled = true },
  quickfile = { enabled = true },
  -- Show image buffers and document links inside supported terminals; keep
  -- LaTeX rendering off so image preview only needs ImageMagick.
  image = {
    enabled = true,
    math = { enabled = false },
  },
  picker = {
    enabled = true,
    ui_select = false,
    sources = {
      explorer = {
        hidden = true,
        ignored = true,
        follow = true,
        follow_file = true,
        watch = true,
        format = compact_explorer_format,
        icons = {
          tree = {
            vertical = '  ',
            middle = '  ',
            last = '  ',
          },
          git = {
            added = '',
            modified = '',
            deleted = '',
          },
        },
        -- Keep a clean tree by default; / reveals the path filter on demand.
        layout = {
          preset = 'sidebar',
          preview = false,
          auto_hide = { 'input' },
        },
      },
    },
  },
}

-- Staged files are additions to the index; show their marker and name in green.
Snacks.util.set_hl { SnacksPickerGitStatusStaged = 'Added' }

vim.keymap.set('n', '<leader>e', function() Snacks.explorer() end, { desc = 'Toggle file [E]xplorer' })
vim.keymap.set('n', '<leader>ui', function() Snacks.image.hover() end, { desc = 'Preview [I]mage under cursor' })

local explorer_workspace = vim.fn.stdpath('cache') .. '/snacks-explorer-workspace'
local function replace_explorer(cwd)
  local current = Snacks.picker.get({ source = 'explorer' })[1]
  if current then current:close() end
  vim.schedule(function() Snacks.explorer({ cwd = cwd }) end)
end

vim.keymap.set('n', '<leader>E', function()
  vim.fn.mkdir(explorer_workspace, 'p')

  local function link(path)
    path = vim.fn.fnamemodify(vim.fn.expand(path), ':p'):gsub('/$', '')
    if not vim.uv.fs_stat(path) then
      vim.notify('Folder not found: ' .. path, vim.log.levels.ERROR)
      return false
    end

    local link_path = explorer_workspace .. '/' .. vim.fn.fnamemodify(path, ':t')
    if vim.fn.getftype(link_path) == '' then
      local ok, err = vim.uv.fs_symlink(path, link_path)
      if not ok then
        vim.notify('Failed to add folder to tree: ' .. err, vim.log.levels.ERROR)
        return false
      end
    end
    return true
  end

  if not link(vim.fn.getcwd()) then return end
  local default = vim.fn.fnamemodify(vim.fn.getcwd(), ':h') .. '/'
  local path = vim.fn.input({ prompt = 'Add folder to tree: ', default = default, completion = 'dir' })
  if path == '' or not link(path) then return end
  replace_explorer(explorer_workspace)
end, { desc = 'Add folder to explorer tree' })

vim.keymap.set('n', '<leader>C', function()
  if vim.fn.delete(explorer_workspace, 'rf') ~= 0 then
    vim.notify('Failed to clear explorer workspace: ' .. explorer_workspace, vim.log.levels.ERROR)
    return
  end
  replace_explorer(vim.fn.getcwd())
end, { desc = 'Clear explorer workspace symlinks' })
