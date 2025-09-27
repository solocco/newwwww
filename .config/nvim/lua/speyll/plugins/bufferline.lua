return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    -- Ambil warna dari flavours (base16-colorscheme)
    local ok, palette = pcall(require, "base16-colorscheme")
    local colors = ok and palette or {
      base00 = "#1d2021", -- fallback gruvbox
      base01 = "#282828",
      base02 = "#3c3836",
      base03 = "#504945",
      base04 = "#bdae93",
      base05 = "#d5c4a1",
      base06 = "#ebdbb2",
      base07 = "#fbf1c7",
      base08 = "#fb4934",
      base09 = "#fe8019",
      base0A = "#fabd2f",
      base0B = "#b8bb26",
      base0C = "#8ec07c",
      base0D = "#83a598",
      base0E = "#d3869b",
      base0F = "#d65d0e",
    }

    require("bufferline").setup({
      options = {
        mode = "buffers",
        numbers = "none",
        diagnostics = "nvim_lsp",
        separator_style = "slant", -- gaya NvChad
        always_show_bufferline = true,
        show_buffer_close_icons = true,
        show_close_icon = false,
        color_icons = true,
        hover = {
          enabled = true,
          delay = 200,
          reveal = { "close" },
        },
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
            separator = true,
          },
        },
      },
      highlights = {
        fill = { bg = colors.base00 },
        background = { fg = colors.base04, bg = colors.base00 },

        buffer_visible = { fg = colors.base04, bg = colors.base00 },
        buffer_selected = {
          fg = colors.base06,
          bg = colors.base02,
          bold = true,
          italic = false,
        },

        separator = { fg = colors.base00, bg = colors.base00 },
        separator_selected = { fg = colors.base02, bg = colors.base02 },
        separator_visible = { fg = colors.base00, bg = colors.base00 },

        modified = { fg = colors.base09, bg = colors.base00 },
        modified_visible = { fg = colors.base09, bg = colors.base00 },
        modified_selected = { fg = colors.base09, bg = colors.base02 },

        duplicate_selected = { fg = colors.base05, bg = colors.base02, italic = true },
        duplicate_visible  = { fg = colors.base04, bg = colors.base00, italic = true },
        duplicate          = { fg = colors.base04, bg = colors.base00, italic = true },
      },
    })

    -- Keymaps ala NvChad
    local keymap = vim.keymap.set
    keymap("n", "<TAB>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
    keymap("n", "<S-TAB>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
    keymap("n", "<leader>c", "<cmd>bd<CR>", { desc = "Close buffer" })
    keymap("n", "<leader>0", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })
  end,
}
