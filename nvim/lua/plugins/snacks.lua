return {
  "folke/snacks.nvim",

  -- The 'opts' table is the standard LazyVim way to configure a plugin.
  -- All configuration is now correctly nested according to the plugin's API.
  opts = {
    -- We are configuring the 'picker' snack, which is the file explorer.
    picker = {
      -- This section controls the visual theme of the picker.
      theme = {
        filename = {
          -- This sets the color for hidden files (e.g., .gitignore, .git).
          -- You can change the 'fg' color to any hex code you like.
          hidden = { fg = "#888888", italic = true },
        },
      },

      -- This section defines custom keymaps that are only active
      -- when the picker window is open.
      keys = {
        -- This is the robust solution to your navigation problem.
        -- Each keymap now calls a function that first closes the snacks
        -- picker, and then executes the standard Neovim window navigation
        -- command, allowing you to seamlessly move out of the picker.
        ["<C-h>"] = function()
          require("snacks").close()
          vim.cmd.wincmd("h")
        end,
        ["<C-j>"] = function()
          require("snacks").close()
          vim.cmd.wincmd("j")
        end,
        ["<C-k>"] = function()
          require("snacks").close()
          vim.cmd.wincmd("k")
        end,
        ["<C-l>"] = function()
          require("snacks").close()
          vim.cmd.wincmd("l")
        end,
      },
    },
  },
}

-- return {
--   "folke/snacks.nvim",
--   opts = {
--     highlight_hidden = "SnacksHiddenCustom",
--   },
--
--   config = function(_, opts)
--     vim.api.nvim_set_hl(0, "SnacksHiddenCustom", { fg = "#777777", italic = true })
--     require("snacks").setup(opts)
--
--     -- Create a rule that runs whenever a "snacks_picker_list" filetype is detected
--     vim.api.nvim_create_autocmd("FileType", {
--       pattern = "snacks_picker_list",
--       callback = function(args)
--         -- A list of all the keymaps we want to make sure are gone
--         -- local buffer = args.buf
--         local keys_to_del = { "<C-h>", "<C-j>", "<C-k>", "<C-l>" }
--
--         for _, key in ipairs(keys_to_del) do
--           -- pcall safely attempts to run the function. If it fails
--           -- (because there's "No such mapping"), it simply continues
--           -- without throwing an error.
--           pcall(vim.keymap.del, "n", key, { buffer = args.buf })
--         end
--       end,
--     })
--   end,
-- }
