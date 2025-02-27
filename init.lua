require("plugins/lazy")

vim.cmd [[set signcolumn=yes:1]]
vim.cmd [[set relativenumber]]

--Stop the stupid pasting over thingy
vim.api.nvim_set_keymap('x', 'p', 'pgvy', { noremap = true, silent = true })

--set the colorscheme
vim.cmd [[colorscheme nightfox]]

vim.g.cursorhold_updatetime = 800

vim.g.cursorword_highlight = false
vim.g.cursorline_timeout = 0


vim.opt.termguicolors = true
vim.opt.number = true
--autocmd to turn off line numbers in terminal
vim.cmd([[autocmd TermOpen * setlocal nonumber norelativenumber]])

vim.opt.encoding = "UTF-8"


---plugins

require("plugins/treesitter-config")
require("plugins/telescope-config")
require("plugins/mason-config")
require("plugins/cutlass-config")
require("plugins/autopairs-config")
require("plugins/close-buffers")
require("plugins/cmp-config")
require("plugins/toggleterm-config")
require("plugins/ufo-config")
require("plugins/harpoon-config")
require("plugins/lspsaga-config")
require("plugins/colors")
require("plugins/yazi-config")
require("plugins/codecompanion-config")
require("plugins/comment-config")

---end plugins

require("plugins/keymaps")


vim.cmd([[let g:copilot_assume_mapped = v:true]])
vim.cmd("let g:copilot_no_tab_map = v:true")
vim.api.nvim_set_keymap("i", "<C-s>", 'copilot#Accept("<CR>")', { silent = true, expr = true})

--below changes tabs to four spaces
vim.cmd([[set tabstop=4]])
vim.cmd([[set shiftwidth=4]])
vim.cmd([[set expandtab]])

--disables mouse
vim.cmd([[set mouse=]])

vim.g.do_filetype_lua = 1

--folding for TS
vim.o.foldmethod = "expr"
vim.o.foldexpr = 'nvim_treesitter#foldexpr()'

-- require("colors")

--always use system clipboard
vim.opt.clipboard="unnamedplus"
