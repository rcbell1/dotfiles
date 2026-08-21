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
  keys = {
    {
      "<leader>tp",
      function()
        require("neotest").run.run({ extra_args = { "--plot" } })
      end,
      desc = "Run Nearest with plots",
    },
  },
  config = function()
    require("neotest").setup({
      discovery = {
        enabled = true, -- ensure discovery is enabled
        filter_dir = function(name, rel_path, root)
          -- Exclude "build" and "src" directories
          if
            name == "build"
            or name == "src"
            or name == "docs"
            or name == "containers"
          then
            return false
          end
          return true -- allow all other directories (default behavior if not filtered)
        end,
      },
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
