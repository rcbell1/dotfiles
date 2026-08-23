-- Extra Mason packages that LazyVim extras do not already install.
-- LSP servers, formatters, and debuggers that come with enabled extras
-- (and with LazyVim itself: lua-language-server, stylua, shfmt) are not
-- listed here. tree-sitter-cli is also omitted; setup.sh builds that one.

return {
  {
    "mason.nvim",
    opts = {
      ensure_installed = {
        "clang-format",
        "cpptools",
        "debugpy",
        "tombi",
      },
    },
  },
}
