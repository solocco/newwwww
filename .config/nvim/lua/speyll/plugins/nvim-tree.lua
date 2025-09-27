-- ~/.config/nvim/lua/speyll/plugins/nvim-tree.lua
return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  lazy = false,
  dependencies = { "nvim-tree/nvim-web-devicons" },

  config = function()
    -- Hindari konflik dengan netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    -- on_attach: panggil mapping default dulu (agar klik mouse bekerja)
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")
      -- ✅ Ini WAJIB agar klik kiri membuka/menutup folder/file
      api.config.mappings.default_on_attach(bufnr)

      -- Tambahan keymap ringan ala NvChad (tidak mengganggu mouse)
      local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, noremap = true, silent = true, nowait = true, desc = desc })
      end
      map("l",     api.node.open.edit,             "Open")
      map("<CR>",  api.node.open.edit,             "Open")
      map("o",     api.node.open.edit,             "Open")
      map("h",     api.node.navigate.parent_close, "Close Dir")
      map("H",     api.tree.collapse_all,          "Collapse All")
      map("v",     api.node.open.vertical,         "Open: VSplit")
      map("s",     api.node.open.horizontal,       "Open: Split")
      map("q",     api.tree.close,                 "Close Tree")
      map("R",     api.tree.reload,                "Refresh")
      map(".",     api.tree.toggle_hidden_filter,  "Toggle Dotfiles")
    end

    require("nvim-tree").setup({
      on_attach = on_attach,

      -- Perilaku
      hijack_cursor = true,
      sync_root_with_cwd = true,
      respect_buf_cwd = true,
      update_focused_file = { enable = true, update_root = true },

      -- Tampilan
      view = {
        side = "left",
        width = 30,
        preserve_window_proportions = true,
      },

      renderer = {
        root_folder_label = false,
        highlight_opened_files = "all",
        indent_markers = { enable = true },
        icons = {
          show = { file = true, folder = true, folder_arrow = true, git = false }, -- git ikon off (clean)
          glyphs = {
            default = "",
            symlink = "",
            folder = {
              default = "", open = "", empty = "", empty_open = "", symlink = "",
            },
          },
        },
      },

      -- Git dimatikan total (sesuai request sebelumnya)
      git = {
        enable = false,
        ignore = true,
        show_on_dirs = false,
        show_on_open_dirs = false,
      },

      filters = {
        dotfiles = false,   -- tekan "." di tree untuk toggle
        git_ignored = true,
      },

      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
          window_picker = { enable = false },
        },
      },
    })

    -- Keymap global
    vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
    vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>",  { desc = "Focus NvimTree" })
  end,
}
