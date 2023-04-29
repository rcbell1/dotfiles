-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------

local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

-- Move around splits using Ctrl + {h,j,k,l}
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')

-- Change buffers using Tab and Shift-Tab
map('n', '<Tab>', ':bnext<CR>')
map('n', '<S-Tab>', ':bprevious<CR>')
map('n', '<C-g>', ':LazyGit<CR>')

-- Change git copilot code accept key (default Tab)
vim.g.copilot_no_tab_map = true
map("i", "<C-Y>", 'copilot#Accept("<CR>")', { silent = true, expr = true })

vim.api.nvim_command('highlight ColorColumn ctermbg=0 guibg=#3c3836') -- Color for colorcolumn
