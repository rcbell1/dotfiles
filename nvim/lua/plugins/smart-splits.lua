return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = {
    ignored_filetypes = {
      "quickfix",
      "prompt",
      "NvimTree",
      "neo-tree",
      "Trouble",
      "lazy",
      "mason",
      "toggleterm",
      "TelescopePrompt",
    },
    ignored_buftypes = {},
    tmux = { enable = true }, -- talk to tmux when needed
  },
  keys = {
    {
      "<C-h>",
      function()
        if vim.bo.filetype == "snacks_picker_list" then
          vim.cmd.wincmd("h")
        else
          require("smart-splits").move_cursor_left()
        end
      end,
      desc = "Go left split/tmux",
    },
    {
      "<C-j>",
      function()
        if vim.bo.filetype == "snacks_picker_list" then
          vim.cmd.wincmd("j")
        else
          require("smart-splits").move_cursor_down()
        end
      end,
      desc = "Go down split/tmux",
    },
    {
      "<C-k>",
      function()
        if vim.bo.filetype == "snacks_picker_list" then
          vim.cmd.wincmd("k")
        else
          require("smart-splits").move_cursor_up()
        end
      end,
      desc = "Go up split/tmux",
    },
    {
      "<C-l>",
      function()
        if vim.bo.filetype == "snacks_picker_list" then
          vim.cmd.wincmd("l")
        else
          require("smart-splits").move_cursor_right()
        end
      end,
      desc = "Go right split/tmux",
    },
  },
}
