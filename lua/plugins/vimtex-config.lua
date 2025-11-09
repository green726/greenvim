vim.g.vimtex_view_method = "zathura"
vim.g.vimtex_quickfix_open_on_warning = 0
vim.g.maplocalleader = ","

-- From: https://github.com/lervag/vimtex/blob/master/doc/vimtex.txt#L4671-L4713
vim.o.foldmethod = "expr"
vim.o.foldexpr="vimtex#fold#level(v:lnum)"
vim.o.foldtext="vimtex#fold#text()"
-- I like to see at least the content of the sections upon opening
vim.o.foldlevel=2
vim.cmd[[
set conceallevel=1
let g:tex_conceal='abdmg'
]]
