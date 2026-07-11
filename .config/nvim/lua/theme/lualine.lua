local M = {}

function M.build()
  local c = require("theme.colors")
  return {
    normal = {
      a = { fg = c.base00, bg = c.base0D, gui = "bold" },
      b = { fg = c.base05, bg = c.base02 },
      c = { fg = c.base05, bg = c.base01 },
    },
    insert = {
      a = { fg = c.base00, bg = c.base0B, gui = "bold" },
    },
    visual = {
      a = { fg = c.base00, bg = c.base0E, gui = "bold" },
    },
    replace = {
      a = { fg = c.base00, bg = c.base08, gui = "bold" },
    },
    command = {
      a = { fg = c.base00, bg = c.base0A, gui = "bold" },
    },
    inactive = {
      a = { fg = c.base03, bg = c.base01 },
      b = { fg = c.base03, bg = c.base01 },
      c = { fg = c.base03, bg = c.base01 },
    },
  }
end

return M
