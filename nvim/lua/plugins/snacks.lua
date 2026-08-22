-- LazyVim's snacks terminal maps Ctrl-h/j/k/l to wincmd only. That leaves
-- you stuck in the bottom terminal instead of handing off to a tmux pane.
local function term_nav(dir)
  return function(self)
    if self:is_floating() then
      return "<c-" .. dir .. ">"
    end
    local move = ({
      h = "move_cursor_left",
      j = "move_cursor_down",
      k = "move_cursor_up",
      l = "move_cursor_right",
    })[dir]
    vim.schedule(function()
      require("smart-splits")[move]()
    end)
  end
end

return {
  "folke/snacks.nvim",

  -- The 'opts' table is the standard LazyVim way to configure a plugin.
  -- All configuration is now correctly nested according to the plugin's API.
  opts = {
    terminal = {
      win = {
        keys = {
          nav_h = { "<C-h>", term_nav("h"), desc = "Go left split/tmux", expr = true, mode = "t" },
          nav_j = { "<C-j>", term_nav("j"), desc = "Go down split/tmux", expr = true, mode = "t" },
          nav_k = { "<C-k>", term_nav("k"), desc = "Go up split/tmux", expr = true, mode = "t" },
          nav_l = { "<C-l>", term_nav("l"), desc = "Go right split/tmux", expr = true, mode = "t" },
        },
      },
    },
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
