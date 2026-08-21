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
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
    },
    config = function()
      local dap = require("dap")
      local dap_python = require("dap-python")

      -- Use the Python from your active environment (uv / venv)
      -- If you want to be explicit, replace "python" with:
      -- vim.fn.getcwd() .. "/.venv/bin/python"
      -- dap_python.setup("python")
      local debugpy_path = vim.fn.stdpath("data")
        .. "/mason/packages/debugpy/venv/bin/python"

      -- 2. Setup dap-python with that path
      dap_python.setup(debugpy_path)

      -- 🔑 Disable justMyCode for ALL Python configurations
      for _, cfg in ipairs(dap.configurations.python) do
        cfg.justMyCode = false
      end
    end,
  },
}
