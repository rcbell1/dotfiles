return {
  {
    "gmr458/vscode_modern_theme.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("vscode_modern").setup({
        cursorline = true,
        transparent_background = false,
        nvim_tree_darker = true,
      })
      vim.cmd.colorscheme("vscode_modern")
    end,
  },
  {
    "EdenEast/nightfox.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("nightfox").setup({
        options = {
          transparent = false, -- Disable setting background
          terminal_colors = true, -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
          dim_inactive = false, -- Non focused panes set to alternative background
          module_default = true, -- Default enable value for modules
          colorblind = {
            enable = true, -- Enable colorblind support
            simulate_only = false, -- Only show simulated colorblind colors and not diff shifted
            severity = {
              protan = 1, -- Severity [0,1] for protan (red)
              deutan = 0, -- Severity [0,1] for deutan (green)
              tritan = 0, -- Severity [0,1] for tritan (blue)
            },
          },
          styles = { -- Style to be applied to different syntax groups
            comments = "NONE", -- Value is any valid attr-list value `:help attr-list`
            conditionals = "NONE",
            constants = "NONE",
            functions = "NONE",
            keywords = "NONE",
            numbers = "NONE",
            operators = "NONE",
            strings = "NONE",
            types = "NONE",
            variables = "NONE",
          },
          inverse = { -- Inverse highlight for different types
            match_paren = false,
            visual = false,
            search = false,
          },
          modules = { -- List of various plugins and additional options
            -- ...
          },
        },
        palettes = {},
        specs = {},
        groups = {},
      })

      -- setup must be called before loading
      vim.cmd.colorscheme("carbonfox")
    end,
  },
  {
    "Mofiqul/dracula.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      require("dracula").setup({
        shades = {
          "dark", -- Darkest shade
        },
        background = {
          -- dark = "#282a36", -- Default background color
          dark = "#080c10",
        },

        -- Options for setting contrast
        contrast = {
          dark = "hard", -- Default contrast
        },
      })
      vim.cmd.colorscheme("dracula")
    end,
  },
  {
    "dasupradyumna/midnight.nvim",
    lazy = true,
    priority = 1000,
    config = function()
      local function apply_snacks_git_hl()
        local set = vim.api.nvim_set_hl
        set(0, "SnacksPickerGitStatusUntracked", { fg = "#e5c07b", bold = true })
        set(0, "SnacksPickerGitStatusModified", { fg = "#61afef", bold = true })
        set(0, "SnacksPickerGitStatusAdded", { fg = "#98c379", bold = true })
        set(0, "SnacksPickerGitStatusDeleted", { fg = "#e06c75", bold = true })
        set(0, "SnacksPickerGitStatusIgnored", { fg = "#6c7086" })
      end

      -- When the colorscheme (Midnight) loads
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "midnight",
        callback = apply_snacks_git_hl,
      })

      -- When Snacks Explorer/Picker buffers open (covers late links)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "snacks_explorer", "snacks_picker_list" },
        callback = apply_snacks_git_hl,
      })

      -- If Midnight is already active, apply immediately
      if vim.g.colors_name == "midnight" then
        apply_snacks_git_hl()
      end
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },
}
