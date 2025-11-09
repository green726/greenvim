local com_cent       = require("commander")
local noremap        = { noremap = true }
local noremap_silent = { noremap = true, silent = true }
local ls = require("luasnip")
-- Define the terminal object ONCE
local Terminal = require('toggleterm.terminal').Terminal
local gemini = Terminal:new({
    cmd = "gemini",
    display_name = "Gemini",
    direction = "vertical",
    -- Use a function for size to make it responsive to window resizes
    -- size = function(term)
    --     return math.floor(vim.o.columns / 3) 
    -- end,
    -- This is important, it prevents the terminal from opening on startup
    hidden = true,
})

-- A dedicated function to toggle this specific terminal
function _G.toggle_gemini(size)
    gemini:toggle(size)
end


com_cent.add({
    -- {
    --     desc = "Telescope code companion",
    --     cmd =
    --         function()
    --             local opts = {
    --                 layout_strategy = "vertical",
    --                 previewer = false,
    --                 layout_config = {
    --                     vertical = {
    --                         width = 0.5,
    --                         height = 0.7,
    --                     },
    --                 },
    --             }
    --             require("telescope").extensions.codecompanion.codecompanion(opts)
    --         end,
    --     keys = { { "n", "tc", noremap } }
    -- },
    {
        desc = "Expand snippet",
        cmd = function() ls.expand() end,
        keys = { { "i", "<C-g>", noremap } }
    },
    -- {
    --     desc = "Jump to next snippet placeholder",
    --     cmd = function() ls.jump(1) end,
    --     keys = { { "i", "<C-g>", noremap }, { "s", "<C-k>", noremap } }
    -- },
    -- {
    --     desc = "Jump to previous snippet placeholder",
    --     cmd = function() ls.jump(-1) end,
    --     keys = { { "i", "<C-f>", noremap }, { "s", "<C-l>", noremap } }
    -- },
    {
        desc = "Flash jump search",
        cmd = function() require("flash").jump() end,
        keys = { { "n", "<C-h>", noremap } }
    },
    {
        desc = "Flash jump word under cursor",
        cmd = function()
            require("flash").jump({
                pattern = vim.fn.expand("<cword>"),
            })
        end,
        keys = { { "n", "<C-b>", noremap } }
    },
    {
        desc = "Toggle Scratch Buffer",
        cmd = function() Snacks.scratch() end,
        keys = { { "n", "<Leader>s", noremap } }
    },
    {
        desc = "Flash treesitter",
        cmd = function() require("flash").treesitter() end,
        keys = { { "n", "<C-l>", noremap } }
    },
    {
        desc = "Open Telescope Diagnostics",
        cmd = "<cmd>Telescope diagnostics<CR>",
        keys = { { "n", "td", noremap } }
    },
    {
        desc = "Toggle Term Open Vert Gemini",
        -- cmd = _G.toggle_gemini,
        cmd = function()
            local term_size = math.floor(vim.o.columns / 3)
            _G.toggle_gemini(term_size)
            -- vim.cmd("ToggleTerm direction=vertical size=" .. term_size)
        end,
        keys = { { "n", "tc", noremap } }
    },
    {
        desc = "Open term in tab",
        cmd = "<cmd>tabnew | term<CR>",
        keys = { { "n", "th", noremap } }
    },
    -- {
    --     desc = "Toggle Term Open Tab",
    --     cmd = "<cmd>ToggleTerm direction=tab<CR>",
    --     keys = { { "n", "tc", noremap } }
    -- },
    {
        desc = "Toggle Term Open Float",
        cmd = "<cmd>ToggleTerm direction=float<CR>",
        keys = { { "n", "tt", noremap } }
    },
    -- {
    --     desc = "Activate WinShift",
    --     cmd = "<cmd>WinShift<CR>",
    --     keys = { { "n", "<leader>ws", noremap } }
    -- },
    {
        desc = "LSPSaga Finder",
        cmd = "<cmd>Lspsaga finder<CR>",
        keys = { { "n", "<leader>lf", noremap } }
    },
    {
        desc = "Open Commander",
        cmd = "<cmd>Telescope commander (keymaps)<CR>",
        keys = { { "n", "tk", noremap } }
    },
    {
        desc = "Open Telescope",
        cmd = "<cmd>Telescope builtin include_extensions=true<CR>",
        --cmd = "<cmd>Telescope<CR>",
        keys = { { "n", "to", noremap } }
    },
    {
        desc = "Open Telescope Find Files",
        cmd = "<cmd>Telescope find_files<CR>",
        keys = { { "n", "tf", noremap } }
    },
    {
        desc = "Open Telescope Live Grep",
        cmd = "<cmd>Telescope live_grep<CR>",
        keys = { { "n", "ts", noremap } }
    },
    -- {
    --     desc = "Open Telescope Aerial",
    --     cmd = "<cmd>Telescope aerial<CR>",
    --     keys = { { "n", "ta", noremap } }
    -- },
    {
        desc = "Open Yazi",
        cmd = "<cmd>Yazi<CR>",
        keys = { { "n", "<C-t>", noremap } }
    },
    -- {
    --     desc = "Open Telescope File Tree",
    --     cmd = "<cmd>Telescope file_browser path=%:p:h select_buffer=true<CR>",
    --     keys = { { "n", "<C-t>", noremap } }
    -- },
    {
        desc = "Open Telescope Buffer",
        cmd = "<cmd>Telescope buffers<CR>",
        keys = { { "n", "tb", noremap } }
    },
    -- {
    --     desc = "Toggle codecompanion chat",
    --     cmd = "<cmd>CodeCompanionChat Toggle<CR>",
    --     keys = { { "n", "<Leader>cc", noremap } }
    -- },
    -- {
    --     desc = "Hop Words",
    --     cmd = "<cmd>lua require'hop'.hint_words()<cr>",
    --     keys = { { "n", "<C-h>", noremap }, { "v", "<C-h>", noremap } }
    -- },
    -- {
    --     desc = "Hop Lines",
    --     cmd = "<cmd>lua require'hop'.hint_lines_skip_whitespace()<cr>",
    --     keys = { { "n", "<Leader>hl", noremap }, { "v", "<Leader>hl", noremap } }
    -- },
    {
        desc = "Go to declaration",
        cmd = "<cmd>lua vim.lsp.buf.declaration()<CR>",
        keys = { { "n", "gd", noremap } }
    },
    {
        desc = "Go to definition",
        cmd = "<cmd>lua vim.lsp.buf.definition()<CR>",
        keys = { { "n", "gD", noremap } }
    },
    {
        desc = "Go to implementation",
        cmd = "<cmd>lua vim.lsp.buf.implementation()<CR>",
        keys = { { "n", "gi", noremap } }
    },
    {
        desc = "Signature Help",
        cmd = "<cmd>lua vim.lsp.buf.signature_help()<CR>",
        keys = { { "n", "<C-k>", noremap }, { "i", "<C-k>", noremap } }
    },
    {
        desc = "List References",
        cmd = "<cmd>lua vim.lsp.buf.references()<CR>",
        keys = { { "n", "gr", noremap } }
    },
    {
        desc = "Format",
        cmd = "<cmd>lua vim.lsp.buf.format { async = true }<CR>",
        keys = { { "n", "<space>f", noremap } }
    },
    {
        desc = "Code Action",
        cmd = "<cmd>Lspsaga code_action<CR>",
        keys = { { "n", "<space>ca", noremap } }
    },
    {
        desc = "Rename",
        cmd = "<cmd>Lspsaga rename<CR>",
        keys = { { "n", "<space>rn", noremap } }
    },
    {
        desc = "Peek Definition",
        cmd = "<cmd>Lspsaga peek_definition<CR>",
        keys = { { "n", "gp", noremap } }
    },
    {
        desc = "Show Line Diagnostics",
        cmd = "<cmd>Lspsaga show_line_diagnostics<CR>",
        keys = { { "n", "<space>ld", noremap } }
    },
    {
        desc = "Show Workspace Diagnostics",
        cmd = "<cmd>Lspsaga show_workspace_diagnostics ++normal<CR>",
        keys = { { "n", "<space>wd", noremap } }
    },
    {
        desc = "Show Buffer Diagnostics",
        cmd = "<cmd>Lspsaga show_buf_diagnostics ++normal<CR>",
        keys = { { "n", "<space>wd", noremap } }
    },
    {
        desc = "Show Cursor Diagnostics",
        cmd = "<cmd>Lspsaga show_cursor_diagnostics<CR>",
        -- cmd = function()
        --         vim.diagnostic.open_float()
        -- end,
        keys = { { "n", "<space>e", noremap } }
    },
    {
        desc = "Lspsaga Hover Doc",
        cmd = "<cmd>Lspsaga hover_doc<CR>",
        keys = { { "n", "K", noremap } }
    },
    {
        desc = "Hlsens Forward",
        cmd = "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>",
        keys = { { "n", "n", noremap_silent } }
    },
    {
        desc = "Hlsens Back",
        cmd = "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>",
        keys = { { "n", "N", noremap_silent } }
    },
    {
        desc = "No highlight",
        cmd = "<cmd>noh<CR>",
        keys = { { "n", "<space>h", noremap } }
    },
    {
        desc = "Fold Preview",
        cmd = "<cmd>lua require('fold-preview').open_fold()<CR>",
        keys = { { "n", "<space>fp", noremap } }
    },
    {
        desc = "Jump to prev diagnostic",
        cmd = "<cmd>Lspsaga diagnostic_jump_prev<CR>",
        keys = { { "n", "[e", noremap_silent } }
    },
    {
        desc = "Jump to next diagnostic",
        cmd = "<cmd>Lspsaga diagnostic_jump_next<CR>",
        keys = { { "n", "]e", noremap_silent } }
    },
}
)
