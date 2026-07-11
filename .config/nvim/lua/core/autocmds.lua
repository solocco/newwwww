vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ timeout = 150 })
  end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = vim.fn.stdpath("config") .. "/lua/theme/colors.lua",
  callback = function()
    package.loaded["theme.colors"] = nil
    require("theme.init").setup()
  end,
})

-- Buka socket tetap biar Flavours bisa kirim perintah reload tema
-- ke instance nvim yang lagi jalan, tanpa perlu spawn instance baru
if vim.fn.filereadable("/tmp/nvim-server") == 0 and #vim.fn.serverlist() == 0 then
  pcall(vim.fn.serverstart, "/tmp/nvim-server")
end
