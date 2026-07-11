return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  build = ":TSUpdate",
  config = function()
    require("nvim-treesitter").install({
      "lua", "vim", "vimdoc", "bash", "rust", "toml", "json", "yaml",
      "markdown", "markdown_inline", "python", "css", "html",
      "javascript", "typescript", "tsx", "query",
    })

    vim.api.nvim_create_autocmd("FileType", {
      callback = function(args)
        local ok = pcall(vim.treesitter.start, args.buf)
        if ok then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end,
}
