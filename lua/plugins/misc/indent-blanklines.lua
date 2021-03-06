-- indent-blankline character.

-- vim.cmd("highlight IndentBlanklineContextChar guifg=#000000 gui=nocombine")
-- vim.cmd("highlight IndentBlanklineContextStart guisp=#000000 gui=underline")

local indent_blankline_styles = {
    "▕",
    "│",
	"▏",
	"¦",
	"┆",
	"│",
	"⎸",
	"|",
}

vim.g.indent_blankline_char = indent_blankline_styles[6]

-- Disable indent-blankline on these pages.
vim.g.indent_blankline_filetype_exclude = {
	"help",
	"terminal",
	"dashboard",
	"paq",
	"lsp-installer",
	"lspinfo",
	"vista_kind",
	"alpha",
    "nvim-tree",
}

vim.g.indent_blankline_buftype_exclude = { "terminal" }
vim.opt.list = true
vim.opt.listchars:append("space:⋅")

require("indent_blankline").setup {
    space_char_blankline = " ",
    -- show_current_context = true,
}
