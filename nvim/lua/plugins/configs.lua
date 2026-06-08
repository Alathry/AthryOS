return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "python", "go", "bash", "markdown" },
      highlight = { enable = true },
    },
    config = function(_, opts)
      local ok, ts_configs = pcall(require, "nvim-treesitter.configs")
      if ok then
        ts_configs.setup(opts)
      else
        local ok_main, ts = pcall(require, "nvim-treesitter")
        if ok_main and ts.setup then
          ts.setup(opts)
        end
      end
    end,
  },

  {
    "williamboman/mason.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin:" .. vim.env.PATH

      require("mason").setup()
      require("mason-lspconfig").setup({
        ensure_installed = { "lua_ls", "gopls", "pyright" }
      })

      local servers = { "lua_ls", "gopls", "pyright" }
      for _, server in ipairs(servers) do
        pcall(function()
          vim.lsp.enable(server)
        end)
      end
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local matugen_colors = {
        primary = "#a8c7fa", on_primary = "#062e6f",
        secondary = "#7fcfff", on_secondary = "#003355",
        tertiary = "#c5bfff", on_tertiary = "#2d2565",
        background = "#111318", on_background = "#e2e2e9",
        surface_container_high = "#22242a", on_surface = "#e2e2e9"
      }
      
      local ok, theme = pcall(require, "theme.matugen")
      if ok and theme.parse_matugen then
        matugen_colors = theme.parse_matugen()
      end

      local custom_theme = {
        normal = {
          a = { bg = matugen_colors.primary, fg = matugen_colors.on_primary, bold = true },
          b = { bg = matugen_colors.surface_container_high, fg = matugen_colors.on_surface },
          c = { bg = matugen_colors.background, fg = matugen_colors.on_background },
        },
        insert = {
          a = { bg = matugen_colors.secondary, fg = matugen_colors.on_secondary, bold = true },
        },
        visual = {
          a = { bg = matugen_colors.tertiary, fg = matugen_colors.on_tertiary, bold = true },
        },
      }

      require("lualine").setup({
        options = {
          theme = custom_theme,
          component_separators = "",
          section_separators = { left = "", right = "" },
        },
        sections = {
          lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
          lualine_b = { "filename", "branch" },
          lualine_c = { "diagnostics" },
          lualine_x = { "encoding", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
        },
      })
    end,
  }
}
