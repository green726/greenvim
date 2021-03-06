--!!! very important, cant have spaces in file/folder names for the unity open in greenvim to work
--my favorite terminal for use here is alacritty - windows command prompt is fine but will not work properly with any font
--execpt for agave NF (which i dont like)
--for this reason (+ config for alacritty and performance) I prefer alacritty
--I use the Anonymice Mono NF

-- if vim.g.nvui then
--   -- Configure through vim commands
--   vim.cmd [[NvuiCmdFontFamily SpaceMono Nerd Font]]
-- end

vim.g.cursorhold_updatetime = 800

-- vim.o.guifont = "SpaceMono Nerd Font"
-- vim.g.neovide_cursor_vfx_mode = "railgun"

vim.g.cursorword_highlight = false
vim.g.cursorline_timeout = 0


vim.opt.termguicolors = true
vim.opt.number = true
--autocmd to turn off line numbers in terminal
vim.cmd([[autocmd TermOpen * setlocal nonumber norelativenumber]])
--autocmd to close neovim if nvim-tree is last thing open
-- vim.cmd([[autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif]])

vim.opt.encoding = "UTF-8"

require("plugins/paq")


require("colors")
require("plugins/language/treesitter")
require("plugins/language/lsp/lsp-install-config")
require("plugins/language/lsp/lsp-config")
require("plugins/language/lsp/lsp-status-config")
require("plugins/language/lsp/lsp-signature-config")
require("plugins/language/lsp/lsp-lightbulb-config")
require("plugins/language/lsp/lsp-actions-config")
require("plugins/language/trouble-config")
require("plugins/misc/indent-blanklines")
require("plugins/util/git-signs")
require("plugins/ui/alpha")
require("plugins/util/web-devicons")
require("plugins/misc/telescope")
require("plugins/misc/toggleTermConfig")
require("plugins/misc/todo-comments")
require("plugins/language/comment-nvim")
require("plugins/ui/nvim-treeConfig")
require("plugins/language/treesitter-context")
require("plugins/ui/twilight-config")
require("plugins/misc/dim-config")
require("plugins/language/nvim-cmp")
--require("plugins/conmenuConfig")
require("plugins/misc/winshift-config")
require("plugins/language/dap-ui-config")
require("plugins/language/dap-config")
require("plugins/misc/goMove")
require("plugins/ui/feline/feline-init")
require("plugins/ui/nightfoxConfig")
require("plugins/ui/scrollbar-config")
require("plugins/ui/aerial-config")
require("plugins/misc/whichkey-config")
require("plugins/ui/cokeline-config")
-- require("plugins/ui/bufferline")
require("plugins/misc/hop-config")
-- require("plugins/util/startuptime-config")
require("plugins/language/prettyfold-config")
require("plugins/language/lsp/lsp-lines-config")

require("keymaps")
require("autocommands")
require("commands")

vim.cmd[[set relativenumber]]

--setup for instant collab
vim.g.instant_username = "green726"

vim.cmd[[colorscheme nightfox]]

--set the colorscheme
vim.g.vscode_style = "dark"
vim.g.vscode_italic_comment = 1
-- vim.cmd([[colorscheme vscode]])

--vim.cmd[[colorscheme tokyonight]]

--below changes tabs to four spaces
vim.cmd([[set tabstop=4]])
vim.cmd([[set shiftwidth=4]])
vim.cmd([[set expandtab]])

--enables mouse
vim.cmd([[set mouse=a]])

--i use the below guide for unity
--https://chrislabarge.com/posts/neovim-unity-engine/
--https://www.youtube.com/watch?v=FlhNSNMNYOo
--https://rudism.com/coding-csharp-in-neovim/


