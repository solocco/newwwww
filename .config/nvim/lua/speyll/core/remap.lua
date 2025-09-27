-- ~/.config/nvim/lua/speyll/keymaps.lua

-- Leader key
vim.g.mapleader = " "

-- File explorer bawaan (Ex)
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Pindah baris ke atas/bawah di visual mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- Join line tetap di posisi cursor
vim.keymap.set("n", "J", "mzJ`z")

-- Scrolling tetap di tengah layar
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Search result tetap di tengah
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Paste tanpa overwrite register
vim.keymap.set("x", "<leader>p", [["_dP]])

-- Copy ke system clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

-- Delete tanpa overwrite register
vim.keymap.set({ "n", "v" }, "<leader>d", [["_d]])

-- Esc alternatif
vim.keymap.set("i", "<C-c>", "<Esc>")

-- Disable Q
vim.keymap.set("n", "Q", "<nop>")

-- Jalankan tmux-sessionizer
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- Format dengan LSP
vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

-- Quickfix navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Search & replace kata di bawah cursor
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Jadikan file executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })

-- Insert snippet error handling (Go)
vim.keymap.set(
  "n",
  "<leader>ee",
  "oif err != nil {<CR>}<Esc>Oreturn err<Esc>"
)

-- Reload config
vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end)

-- =========================
-- Extra: NvimTree
-- =========================
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle NvimTree" })
vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<CR>",  { desc = "Focus NvimTree" })

-- =========================
-- Extra: Bufferline ala NvChad
-- =========================
vim.keymap.set("n", "<TAB>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next buffer" })
vim.keymap.set("n", "<S-TAB>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev buffer" })
vim.keymap.set("n", "<leader>c", "<cmd>bd<CR>", { desc = "Close buffer" })
vim.keymap.set("n", "<leader>0", "<cmd>BufferLinePick<CR>", { desc = "Pick buffer" })

-- =========================
-- Global Ctrl+S untuk Save
-- =========================

-- Pastikan terminal tidak freeze Ctrl+S (sekali saat start)
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    pcall(vim.fn.system, "stty -ixon")
  end,
})

-- Mapping global
vim.keymap.set("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
vim.keymap.set("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
vim.keymap.set("v", "<C-s>", "<Esc><cmd>w<CR>", { desc = "Save file" })
