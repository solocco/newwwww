local M = {}

function M.setup()
  package.loaded["theme.colors"] = nil
  local c = require("theme.colors")

  vim.o.background = "dark"
  vim.g.colors_name = "flavours"

  local hl = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hl("Normal", { fg = c.base05, bg = c.base00 })
  hl("NormalFloat", { fg = c.base05, bg = c.base01 })
  hl("FloatBorder", { fg = c.base03, bg = c.base01 })
  hl("Cursor", { fg = c.base00, bg = c.base05 })
  hl("CursorLine", { bg = c.base01 })
  hl("CursorLineNr", { fg = c.base0D, bold = true })
  hl("LineNr", { fg = c.base03 })
  hl("SignColumn", { fg = c.base03, bg = c.base00 })
  hl("Visual", { bg = c.base02 })
  hl("Search", { fg = c.base00, bg = c.base0A })
  hl("IncSearch", { fg = c.base00, bg = c.base09 })
  hl("Pmenu", { fg = c.base05, bg = c.base01 })
  hl("PmenuSel", { fg = c.base00, bg = c.base0D })
  hl("StatusLine", { fg = c.base05, bg = c.base01 })
  hl("VertSplit", { fg = c.base02 })
  hl("WinSeparator", { fg = c.base02 })
  hl("ColorColumn", { bg = c.base01 })
  hl("MatchParen", { fg = c.base0A, bold = true })

  hl("Comment", { fg = c.base03, italic = true })
  hl("Constant", { fg = c.base09 })
  hl("String", { fg = c.base0B })
  hl("Character", { fg = c.base0B })
  hl("Number", { fg = c.base09 })
  hl("Boolean", { fg = c.base09 })
  hl("Identifier", { fg = c.base08 })
  hl("Function", { fg = c.base0D })
  hl("Statement", { fg = c.base0E })
  hl("Conditional", { fg = c.base0E })
  hl("Repeat", { fg = c.base0E })
  hl("Keyword", { fg = c.base0E })
  hl("Operator", { fg = c.base05 })
  hl("PreProc", { fg = c.base0A })
  hl("Type", { fg = c.base0A })
  hl("Structure", { fg = c.base0A })
  hl("Special", { fg = c.base0C })
  hl("Underlined", { fg = c.base0D, underline = true })
  hl("Error", { fg = c.base08 })
  hl("Todo", { fg = c.base0A, bold = true })

  hl("@variable", { fg = c.base05 })
  hl("@variable.builtin", { fg = c.base08 })
  hl("@parameter", { fg = c.base08, italic = true })
  hl("@field", { fg = c.base08 })
  hl("@property", { fg = c.base08 })
  hl("@function", { fg = c.base0D })
  hl("@function.builtin", { fg = c.base0D })
  hl("@method", { fg = c.base0D })
  hl("@constructor", { fg = c.base0A })
  hl("@keyword", { fg = c.base0E })
  hl("@keyword.function", { fg = c.base0E })
  hl("@keyword.return", { fg = c.base0E })
  hl("@conditional", { fg = c.base0E })
  hl("@string", { fg = c.base0B })
  hl("@number", { fg = c.base09 })
  hl("@boolean", { fg = c.base09 })
  hl("@type", { fg = c.base0A })
  hl("@type.builtin", { fg = c.base0A })
  hl("@comment", { fg = c.base03, italic = true })
  hl("@punctuation.bracket", { fg = c.base05 })
  hl("@punctuation.delimiter", { fg = c.base05 })
  hl("@tag", { fg = c.base08 })
  hl("@tag.attribute", { fg = c.base09 })

  hl("DiagnosticError", { fg = c.base08 })
  hl("DiagnosticWarn", { fg = c.base0A })
  hl("DiagnosticInfo", { fg = c.base0D })
  hl("DiagnosticHint", { fg = c.base0C })
  hl("DiagnosticUnderlineError", { undercurl = true, sp = c.base08 })
  hl("DiagnosticUnderlineWarn", { undercurl = true, sp = c.base0A })

  hl("DiffAdd", { fg = c.base0B, bg = c.base01 })
  hl("DiffChange", { fg = c.base0A, bg = c.base01 })
  hl("DiffDelete", { fg = c.base08, bg = c.base01 })
  hl("GitSignsAdd", { fg = c.base0B })
  hl("GitSignsChange", { fg = c.base0A })
  hl("GitSignsDelete", { fg = c.base08 })

  hl("TelescopeBorder", { fg = c.base02 })
  hl("TelescopeSelection", { bg = c.base01 })
  hl("TelescopePromptBorder", { fg = c.base0D })

  hl("CmpItemAbbrMatch", { fg = c.base0D, bold = true })
  hl("CmpItemKindFunction", { fg = c.base0D })
  hl("CmpItemKindVariable", { fg = c.base08 })
  hl("CmpItemKindKeyword", { fg = c.base0E })

  local ok, lualine = pcall(require, "lualine")
  if ok then
    package.loaded["theme.lualine"] = nil
    lualine.setup({
      options = {
        theme = require("theme.lualine").build(),
        component_separators = "|",
        section_separators = "",
      },
    })
  end
end

return M
