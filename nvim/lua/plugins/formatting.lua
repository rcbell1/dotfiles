-- ~/.config/nvim/lua/plugins/formatting.lua
return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      python = { "ruff_format", "ruff_organize_imports" },
    },
  },
}
