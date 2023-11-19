-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- To delete existing keymaps, use the following syntax:
-- vim.keymap.delete("n", "<C-p>")

-- After deleting the keymap you want to override, you can add your own:
vim.keymap.set("n", "<C-p>", ":MarkdownPreviewToggle<CR>", { noremap = true, silent = true })
