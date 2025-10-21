return {
  {
    "theHamsta/nvim-dap-virtual-text",
    opts = {
      commented = false,
      virt_text_pos = "eol",
      virt_text_win_col = 60,
      only_first_definition = false,
      all_references = false,
      highlight_changed_variables = true,
      highlight_new_as_changed = true,

      -- virt_lines = true,
    },
    keys = {
      {
        "<leader>dv",
        function()
          require("nvim-dap-virtual-text").toggle()
        end,
        desc = "Toggle DAP Virtual Text",
      },
    },
    config = function(_, opts)
      require("nvim-dap-virtual-text").setup(opts)
      -- custom highlights
      vim.api.nvim_set_hl(0, "NvimDapVirtualText", { fg = "#A3B7B8" })
      vim.api.nvim_set_hl(0, "NvimDapVirtualTextChanged", { fg = "#FFEDED" })
      vim.api.nvim_set_hl(0, "NvimDapVirtualTextError", { fg = "#f7768e" })
    end,
  },
}
