-----------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

-- Default options are not included
-- See: https://neovim.io/doc/user/vim_diff.html
-- [2] Defaults - *nvim-defaults*

local g = vim.g       -- Global variables
local opt = vim.opt   -- Set options (global/buffer/windows-scoped)
local api = vim.api

-----------------------------------------------------------
-- General
-----------------------------------------------------------
g.mapleader = ';'                 -- Map leader to combination
opt.mouse = 'a'                       -- Enable mouse support
opt.clipboard = 'unnamedplus'         -- Copy/paste to system clipboard
opt.swapfile = false                  -- Don't use swapfile
opt.completeopt = 'menuone,noinsert,noselect'  -- Autocomplete options

-----------------------------------------------------------
-- Neovim UI
-----------------------------------------------------------
opt.number = true           -- Show line number
opt.relativenumber = true   -- Show relative line numbers from current line
opt.showmatch = true        -- Highlight matching parenthesis
opt.foldmethod = 'marker'   -- Enable folding (default 'foldmarker')
opt.colorcolumn = '88'      -- Line lenght marker at 88 columns
api.nvim_command('highlight ColorColumn ctermbg=0 guibg=#3c3836') -- Color for colorcolumn
opt.splitright = true       -- Vertical split to the right
opt.splitbelow = true       -- Horizontal split to the bottom
opt.ignorecase = true       -- Ignore case letters when search
opt.smartcase = true        -- Ignore lowercase for the whole pattern
opt.linebreak = true        -- Wrap on word boundary
opt.termguicolors = true    -- Enable 24-bit RGB colors
opt.laststatus=3            -- Set global statusline
opt.showtabline=2           -- Always show tabs
api.nvim_set_option('textwidth', 88) -- Wrap text at this character width

-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
opt.expandtab = true        -- Use spaces instead of tabs
opt.shiftwidth = 4          -- Shift 2 spaces when tab
opt.tabstop = 4             -- 1 tab == 2 spaces
opt.smartindent = true      -- Autoindent new lines

-----------------------------------------------------------
-- Whitespace, characters
-----------------------------------------------------------
opt.list = true             -- Enable display of whitespace characters
opt.listchars = {           -- Define the listchars
    tab = '» ',
    trail = '·',
    nbsp = '·',
    -- eol = '¬',
    extends = '…',
    precedes = '…',
}

-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
opt.hidden = true           -- Enable background buffers
opt.history = 100           -- Remember N lines in history
opt.lazyredraw = true       -- Faster scrolling
opt.synmaxcol = 240         -- Max column for syntax highlight
opt.updatetime = 250        -- ms to wait for trigger an event

-----------------------------------------------------------
-- Rust Lang
-----------------------------------------------------------
vim.g.rustfmt_autosave = 1
-- vim.api.nvim_set_var("rustfmt_autosave", 1)

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- Disable nvim intro
opt.shortmess:append "sI"

-- Disable builtin plugins for speed
local disabled_built_ins = {
   "2html_plugin",
   "getscript",
   "getscriptPlugin",
   "gzip",
   "logipat",
   "netrw",
   "netrwPlugin",
   "netrwSettings",
   "netrwFileHandlers",
   "matchit",
   "tar",
   "tarPlugin",
   "rrhelper",
   "spellfile_plugin",
   "vimball",
   "vimballPlugin",
   "zip",
   "zipPlugin",
   "tutor",
   "rplugin",
   "synmenu",
   "optwin",
   "compiler",
   "bugreport",
   "ftplugin",
}

for _, plugin in pairs(disabled_built_ins) do
   g["loaded_" .. plugin] = 1
end
