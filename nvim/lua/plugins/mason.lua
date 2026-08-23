-- Mason package names only. No versions: Mason always fetches the latest
-- registry release. tree-sitter-cli is intentionally absent; official linux
-- builds need GLIBC 2.39 and setup.sh installs a cargo-built CLI instead.
--
-- LazyVim extras already request some of these. Listing them here makes a
-- fresh machine converge even if extras change, and setup.sh waits on this
-- same list via lua/config/mason-sync.lua.

return {
  {
    "mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP
        "bash-language-server",
        "biome",
        "clangd",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "ember-language-server",
        "json-lsp",
        "lua-language-server",
        "marksman",
        "neocmakelsp",
        "pyright",
        "taplo",
        "tombi",
        "yaml-language-server",
        -- DAP
        "codelldb",
        "cpptools",
        "debugpy",
        -- formatters / linters
        "clang-format",
        "cmakelang",
        "cmakelint",
        "hadolint",
        "markdown-toc",
        "markdownlint-cli2",
        "ruff",
        "shellcheck",
        "shfmt",
        "stylua",
      },
    },
  },
}
