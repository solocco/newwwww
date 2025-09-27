return {
    'RRethy/nvim-base16',
    config = function()
        require('base16-colorscheme').setup({
            -- Start flavours
            base00 = "none", base01 = "#343f44", base02 = "#3d484d", base03 = "#475258",
            base04 = "#9da9a0", base05 = "#d3c6aa", base06 = "#e4e1cd", base07 = "#fdf6e3",
            base08 = "#e67e80", base09 = "#e69875", base0A = "#dbbc7f", base0B = "#a7c080",
            base0C = "#83c092", base0D = "#7fbbb3", base0E = "#d699b6", base0F = "#d3c6aa"
            -- End flavours
        })
        -- Ensure that Normal background is set to transparent
        vim.cmd("highlight Normal guibg=none")
    end
}
