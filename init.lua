require("plugins/lazy")

vim.cmd [[set signcolumn=yes:1]]
vim.cmd [[set relativenumber]]

vim.filetype.add({
  extension = {
    c3 = "c3",
    c3i = "c3",
    c3t = "c3",
  },
})

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



-- LuaSnip disabled (snippets kept in lua/plugins/luasnip/)
-- require("luasnip").config.setup({
--   enable_autosnippets = true,
-- })
-- require("luasnip.loaders.from_lua").load({ paths ="~/.config/nvim/lua/plugins/luasnip/" })
-- require("luasnip.loaders.from_vscode").lazy_load()
require("plugins/treesitter-config")



-- telescope, cmp, ufo, lspsaga, yazi: configured by their lazy specs in plugins/lazy.lua
require("plugins/markdown-library").setup()
require("plugins/cutlass-config")
require("plugins/autopairs-config")
require("plugins/close-buffers")
require("plugins/toggleterm-config")
require("plugins/multiplexer")
require("plugins/harpoon-config")
require("plugins/colors")
-- require("plugins/codecompanion-config")
require("plugins/comment-config")
require("plugins/todo-comments-config")
-- require("plugins/knap-config")
require("plugins/vimtex-config")

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

vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
vim.keymap.set('v', '<leader>c', require('osc52').copy_visual)


--always use system clipboard
vim.opt.clipboard="unnamedplus"
-- The system clipboard is the terminal's, via OSC 52: this machine has no
-- clipboard tool, and it works over ssh and through multiplexer sessions
-- (copies go to whichever terminal is attached). Nvim only auto-enables OSC 52
-- when 'clipboard' is empty, so set it explicitly.
-- Paste returns the last yank instead of asking the terminal: many terminals
-- ignore or prompt on OSC 52 reads, which would stall every `p`. Paste text
-- from other apps with the terminal's own paste key.
do
    local last = { {}, "v" }
    local function copy(reg)
        return function(lines, regtype)
            last = { lines, regtype }
            require("vim.ui.clipboard.osc52").copy(reg)(lines)
        end
    end
    local function paste() return last end
    vim.g.clipboard = {
        name = "OSC 52",
        copy = { ["+"] = copy("+"), ["*"] = copy("*") },
        paste = { ["+"] = paste, ["*"] = paste },
    }
end

vim.api.nvim_create_autocmd('FileType', {
  pattern = { '*' }, -- Applies to every filetype detected
  callback = function() 
      pcall(vim.treesitter.start) -- pcall prevents errors if no parser exists
  end,
})
