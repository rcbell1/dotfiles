-- Official tree-sitter-cli linux binaries need GLIBC 2.39. Mason will
-- happily install one that then fails on Ubuntu 22.04. Drop that copy so
-- the cargo-built CLI on PATH is what nvim-treesitter actually runs.
return {
  {
    "mason.nvim",
    opts = function(_, opts)
      local bin = vim.fn.stdpath("data") .. "/mason/bin/tree-sitter"
      if vim.fn.filereadable(bin) == 1 then
        vim.fn.system({ bin, "--version" })
        if vim.v.shell_error ~= 0 then
          vim.fn.delete(bin)
        end
      end
      return opts
    end,
  },
}
