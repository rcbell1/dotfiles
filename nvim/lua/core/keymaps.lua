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

-- function ToggleColorColumn()
--   if (vim.opt.colorcolumn == nil or vim.opt.colorcolumn == '') then
--     vim.opt.colorcolumn = "88"  -- Enable the colorcolumn
--   else
--     vim.opt.colorcolumn = ''    -- Disable the colorcolumn
--   end
-- end
--
-- -- Toggle the 'colorcolumn' setting on and off with <F3>
-- vim.api.nvim_set_keymap('n', '<Leader>c', ':lua ToggleColorColumn()<CR>', { noremap = true })

vim.keymap.set('n', '<Leader>cs', ':lua vim.opt.colorcolumn = "88"<CR>')
vim.keymap.set('n', '<Leader>cu', ':lua vim.opt.colorcolumn = ""<CR>')

-- Move around splits using Ctrl + {h,j,k,l}
-- map('n', '<C-h>', '<Leader>h')
-- map('n', '<C-j>', '<Leader>j')
-- map('n', '<C-k>', '<Leader>k')
-- map('n', '<C-l>', '<Leader>l')

-------------------------------------------------------------------------------
------------------------------ Lazy Git --------------------------------------
-------------------------------------------------------------------------------
map('n', '<Tab>', ':bnext<CR>')
map('n', '<S-Tab>', ':bprevious<CR>')
map('n', '<Leader>lg', ':LazyGit<CR>')


-------------------------------------------------------------------------------
------------------------------ Git-Blame --------------------------------------
-------------------------------------------------------------------------------
map('n', '<Leader>gb', ':GitBlameToggle<CR>', { noremap = true, silent = true })


-------------------------------------------------------------------------------
------------------------------ Copilot -------------------------------------
-------------------------------------------------------------------------------
-- Change git copilot code accept key (default Tab)
vim.g.copilot_no_tab_map = true
map("i", "<C-Y>", 'copilot#Accept("<CR>")', { silent = true, expr = true })


-------------------------------------------------------------------------------
------------------------------ LSP Config -------------------------------------
-------------------------------------------------------------------------------
-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<Leader>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<Leader>q', vim.diagnostic.setloclist)
vim.o.updatetime = 250


-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <C-x><C-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<Leader>k', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<Leader>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<Leader>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<Leader>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<Leader>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<Leader>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<Leader>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    -- vim.keymap.set('n', '<Leader>f', function()
      -- vim.lsp.buf.format { async = true }
    -- end, opts)
  end,
})

-------------------------------------------------------------------------------
------------------------------ Telescope --------------------------------------
-------------------------------------------------------------------------------
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<Leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<Leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<Leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<Leader>fh', builtin.help_tags, {})
vim.keymap.set('n', '<Leader>fo', builtin.oldfiles, {})
vim.keymap.set('n', '<Leader>fc', builtin.commands, {})
vim.keymap.set('n', '<Leader>ft', builtin.treesitter, {})
vim.keymap.set('n', '<Leader>fk', builtin.keymaps, {})

-- vim.cmd([[
--   autocmd BufWritePre *.rs :silent execute '!rustfmt' | edit!
-- ]])

-------------------------------------------------------------------------------
------------------------------ Rust Tools -------------------------------------
-------------------------------------------------------------------------------
vim.keymap.set('n', '<Leader>rs', ':RustEnableInlayHints<CR>')
vim.keymap.set('n', '<Leader>ru', ':RustDisableInlayHints<CR>')

-------------------------------------------------------------------------------
------------------------------ DAP --------------------------------------------
-------------------------------------------------------------------------------
vim.keymap.set("n", "<Leader>b", ':DapToggleBreakpoint<CR>')
vim.keymap.set("n", "<Leader>dx", ':DapTerminate<CR>')
vim.keymap.set("n", "<Leader>do", ':DapStepOver<CR>')

