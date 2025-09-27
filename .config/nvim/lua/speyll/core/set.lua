-- ~/.config/nvim/lua/speyll/options.lua
local opt = vim.opt

-- Cursor & garis
opt.guicursor = ""
opt.cursorline = false

-- Number
opt.number = true
opt.relativenumber = true

-- Indent & Tab
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

-- Wrap
opt.wrap = true

-- File & Undo
opt.swapfile = false
opt.backup = false
opt.undodir = os.getenv("HOME") .. "/.cache/nvim/undodir"
opt.undofile = true

-- Search
opt.hlsearch = false
opt.incsearch = true

-- Warna & kolom panduan
opt.termguicolors = true
opt.colorcolumn = "80"

-- UI / Layout
opt.scrolloff = 8
opt.signcolumn = "yes"
opt.isfname:append("@-@")

-- Timing
opt.updatetime = 50

-- ✅ Mouse fix penting untuk NvimTree
opt.mouse = "a"          -- aktifkan mouse global
opt.mousemodel = "popup" -- klik kiri = aksi (bukan Visual), klik kanan = menu

-- Split behavior nyaman
opt.splitbelow = true
opt.splitright = true

-- Clipboard OS
opt.clipboard = "unnamedplus"
