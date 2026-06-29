vim.o.number = false
vim.o.mouse = 'a'
vim.o.showmode = false

-- This is a text editor, not a suggestion engine: never open completion as text is typed.
vim.o.autocomplete = false

-- Schedule clipboard sync after UiEnter to avoid slowing startup
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)

-- True 24-bit color so themes render correctly (auto-detected locally, but pin
-- it on so colors don't degrade over SSH/tmux).
vim.o.termguicolors = true

-- Soft-wrap long lines readably: keep wrapped rows indented (breakindent),
-- break at word boundaries instead of mid-word (linebreak), and mark wrapped
-- rows with a ↪ so a wrap is visually distinct from a real new line.
vim.o.breakindent = true
vim.o.linebreak = true
vim.o.showbreak = '↪ '
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 250
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 10
vim.o.confirm = true
vim.o.laststatus = 3

-- Make Diffview and native diff mode align nearby lines and emphasize changed words.
vim.opt.diffopt:append { 'linematch:60', 'inline:word' }
