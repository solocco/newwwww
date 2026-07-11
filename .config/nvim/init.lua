vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("core.lazy")
require("core.options")
require("core.keymaps")
require("core.autocmds")

require("theme.init").setup()

vim.api.nvim_create_user_command("Flavours", function()
  package.loaded["theme.colors"] = nil
  require("theme.init").setup()
end, {})
