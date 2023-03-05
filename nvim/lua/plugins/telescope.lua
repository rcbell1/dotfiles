local builtin = require('telescope.builtin')
local actions = require('telescope.actions')
-- Global remapping
------------------------------
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        -- To disable a keymap, put [map] = false
        -- So, to not map "<C-n>", just put
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
      },
    },
  }
}

vim.keymap.set('n', '<C-f>', builtin.find_files, {})
vim.keymap.set('n', '<C-w>fg', builtin.live_grep, {})
vim.keymap.set('n', '<C-w>fb', builtin.buffers, {})
vim.keymap.set('n', '<C-w>fh', builtin.help_tags, {})
vim.keymap.set('n', '<C-w>fo', builtin.oldfiles, {})
vim.keymap.set('n', '<C-w>fc', builtin.commands, {})
vim.keymap.set('n', '<C-w>ft', builtin.treesitter, {})
