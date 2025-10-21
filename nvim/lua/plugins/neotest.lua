-- ~/.config/nvim/lua/plugins/neotest.lua
return {
  "nvim-neotest/neotest",
  dependencies = {
    "nvim-neotest/neotest-python",
    "nvim-lua/plenary.nvim",
    "antoinemadec/FixCursorHold.nvim",
    "nvim-treesitter/nvim-treesitter",
    "mfussenegger/nvim-dap", -- For debugging
  },
  config = function()
    require("neotest").setup({
      -- This is the crucial part: loading the adapter
      adapters = {
        require("neotest-python")({
          -- Tell the adapter to use pytest as the test runner
          runner = "pytest",
          -- This is a key setting for debugging. It prevents the debugger
          -- from skipping over code in your installed packages.
          dap = { justMyCode = false },
          python = ".venv/bin/python",
          args = { "--log-level", "DEBUG" },
        }),
      },
    })
  end,
}
