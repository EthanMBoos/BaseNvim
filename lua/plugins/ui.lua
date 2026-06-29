-- UI stack: OneDark Warmer colorscheme + heirline statusline + bufferline tabs

require('onedark').setup {
  style = 'warmer',
  term_colors = true,
}
require('onedark').load()

-- Use mini.icons everywhere, including plugins that still request the
-- nvim-web-devicons API (Bufferline and GitLab.nvim).
local mini_icons = require 'mini.icons'
mini_icons.setup { style = 'glyph' }
mini_icons.mock_nvim_web_devicons()

local conditions = require 'heirline.conditions'
local palette = require('onedark.palette').warmer

-- Match the previous file tree's darker sidebar instead of blending the
-- Snacks Explorer picker into the main editor background.
for _, group in ipairs { 'SnacksPickerBox', 'SnacksPickerInput', 'SnacksPickerList' } do
  vim.api.nvim_set_hl(0, group, { fg = palette.fg, bg = palette.bg_d })
end

require('heirline').load_colors {
  bg      = palette.bg1,
  fg      = palette.fg,
  blue    = palette.blue,
  green   = palette.green,
  red     = palette.red,
  yellow  = palette.yellow,
  mauve   = palette.purple,
  peach   = palette.orange,
  overlay = palette.light_grey,
  surface = palette.bg2,
}

local Align = { provider = '%=' }
local Space = { provider = ' ' }

local mode_names = {
  n = 'NOR', i = 'INS', v = 'VIS', V = 'V-L', ['\22'] = 'V-B',
  c = 'CMD', R = 'REP', t = 'TRM', s = 'SEL', S = 'S-L',
}
local mode_colors = {
  n = 'blue', i = 'green', v = 'mauve', V = 'mauve', ['\22'] = 'mauve',
  c = 'peach', R = 'red', t = 'green', s = 'mauve', S = 'mauve',
}
local Mode = {
  init = function(self) self.mode = vim.fn.mode(1) end,
  update = {
    'ModeChanged',
    pattern = '*:*',
    callback = vim.schedule_wrap(function() vim.cmd 'redrawstatus' end),
  },
  provider = function(self)
    local mode = self.mode:sub(1, 1)
    return ' ' .. (mode_names[mode] or mode) .. ' '
  end,
  hl = function(self)
    local color = mode_colors[self.mode:sub(1, 1)] or 'blue'
    return { bg = color, fg = 'bg', bold = true }
  end,
}

local Git = {
  condition = conditions.is_git_repo,
  init = function(self) self.status = vim.b.gitsigns_status_dict or {} end,
  update = { 'User', pattern = 'GitSignsUpdate' },
  {
    provider = function(self)
      local head = self.status.head or ''
      return head ~= '' and ('  ' .. head .. ' ') or ''
    end,
    hl = { fg = 'mauve', bold = true },
  },
  {
    provider = function(self)
      local status = ''
      if (self.status.added or 0) > 0 then status = status .. '+' .. self.status.added end
      if (self.status.changed or 0) > 0 then status = status .. '~' .. self.status.changed end
      if (self.status.removed or 0) > 0 then status = status .. '-' .. self.status.removed end
      return status ~= '' and (status .. ' ') or ''
    end,
    hl = { fg = 'overlay' },
  },
}

local FileName = {
  init = function(self) self.filename = vim.api.nvim_buf_get_name(0) end,
  {
    provider = function(self)
      local name = vim.fn.fnamemodify(self.filename, ':.')
      if name == '' then return '[No Name]' end
      if #name > 40 then name = vim.fn.pathshorten(name) end
      return name
    end,
    hl = { fg = 'fg' },
  },
  {
    provider = function() return vim.bo.modified and ' [+]' or '' end,
    hl = { fg = 'yellow' },
  },
  {
    provider = function()
      return (not vim.bo.modifiable or vim.bo.readonly) and ' [-]' or ''
    end,
    hl = { fg = 'red' },
  },
}

local MacroRecording = {
  condition = function() return vim.fn.reg_recording() ~= '' end,
  provider = function() return ' REC @' .. vim.fn.reg_recording() .. ' ' end,
  hl = { fg = 'red', bold = true },
  update = { 'RecordingEnter', 'RecordingLeave' },
}

local Ruler = {
  provider = ' %3l:%-2c %P ',
  hl = { fg = 'overlay' },
}

require('heirline').setup {
  statusline = {
    hl = { bg = 'bg' },
    Mode, Space, Git, FileName, Space,
    Align,
    MacroRecording, Ruler,
  },
}

require('bufferline').setup {
  options = {
    mode = 'buffers',
    separator_style = 'slant',
    always_show_bufferline = false,
    show_buffer_close_icons = false,
    show_close_icon = false,
    offsets = {
      { filetype = 'snacks_picker_list', text = 'Files', highlight = 'Directory', text_align = 'left' },
    },
  },
}
