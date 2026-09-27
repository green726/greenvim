-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
        --bunch of stuff requires this
        { "nvim-lua/plenary.nvim" },
        { 'kevinhwang91/promise-async' },
        { 'MunifTanjim/nui.nvim' },
        --theme
        { "EdenEast/nightfox.nvim" },
        --syntax highlighting
        { "nvim-treesitter/nvim-treesitter", lazy=false },
        --file finder
        {
            "nvim-telescope/telescope.nvim",
            cmd = "Telescope", -- also loads on require("telescope...")
            config = function() require("plugins/telescope-config") end,
        },
        --icons
        { "kyazdani42/nvim-web-devicons" },
        {
            "folke/snacks.nvim",
            priority = 1000,
            lazy = false,
            opts = require("plugins/snacks-config")
        },
        --auto pairs
        { "windwp/nvim-autopairs" },
        --terminal
        { "akinsho/toggleterm.nvim" },
        --better comments
        { "folke/todo-comments.nvim" },
        --toggle comments
        { "numToStr/Comment.nvim" },
        --better cursorhold
        { "antoinemadec/FixCursorHold.nvim" },
        --nvim lsp-config (lsp/*.lua server configs; loaded by mason-lspconfig)
        { "neovim/nvim-lspconfig", lazy = true },
        --INSTALLER FOR EVERYTHING
        {
            "williamboman/mason.nvim",
            cmd = { "Mason", "MasonInstall", "MasonUninstall", "MasonUpdate", "MasonLog" },
            opts = {},
        },
        --plugin for mason for nvim-config; enables installed servers on first file open
        {
            'williamboman/mason-lspconfig.nvim',
            event = { "BufReadPre", "BufNewFile" },
            dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
            config = function() require("plugins/mason-config") end,
        },
        --auto complete
        {
            'hrsh7th/nvim-cmp',
            event = { "InsertEnter", "CmdlineEnter" },
            dependencies = { 'hrsh7th/cmp-nvim-lsp', 'hrsh7th/cmp-path', 'onsails/lspkind.nvim' },
            config = function() require("plugins/cmp-config") end,
        },
        --lsp source for nvim-cmp
        { 'hrsh7th/cmp-nvim-lsp',                        lazy = true },
        --file path completion for nvim-cmp
        { 'hrsh7th/cmp-path',                            lazy = true },
        --better search highlighting
        { 'kevinhwang91/nvim-hlslens' },
        --lsp function signature help
        { 'ray-x/lsp_signature.nvim' },
        --movements/motions stuff
        -- { 'phaazon/hop.nvim' },
        --lsp signs stuff
        { "onsails/lspkind.nvim",                        lazy = true },
        -- various lsp extensions (pretty much all the above commented out stuff for lsp)
        {
            'glepnir/lspsaga.nvim',
            event = "LspAttach",
            cmd = "Lspsaga",
            config = function() require("plugins/lspsaga-config") end,
        },
        --better buffer deletion
        { 'kazhala/close-buffers.nvim' },
        --cut and delete seperate
        { 'gbprod/cutlass.nvim' },
        --folds
        {
            'kevinhwang91/nvim-ufo',
            event = { "BufReadPre", "BufNewFile" },
            dependencies = { 'kevinhwang91/promise-async' },
            config = function() require("plugins/ufo-config") end,
        },
        --jdtls
        { "mfussenegger/nvim-jdtls",                     lazy = true },
        --keymaps stuff
        { "FeiyouG/command_center.nvim" },
        { "nvim-telescope/telescope-live-grep-args.nvim" },
        {
            "ThePrimeagen/harpoon",
            branch = "harpoon2",
            lazy = true, -- loaded by the keymaps in harpoon-config.lua
            config = function() require("harpoon"):setup({}) end,
        },
        {
            "folke/flash.nvim",
            lazy = true,
        },
        { 'folke/which-key.nvim' },
        {
            "mikavilpas/yazi.nvim",
            event = "VeryLazy",
            -- open_for_directories replaces netrw; disable it before VeryLazy
            init = function() vim.g.loaded_netrwPlugin = 1 end,
            config = function() require("plugins/yazi-config") end,
        },
        {
            "MeanderingProgrammer/render-markdown.nvim",
            ft = { "markdown", "codecompanion" }
        },
        --a necessary plugin to make treesitter work
        { 'reasonml-editor/vim-reason-plus' },
        {
            'github/copilot.vim',
            event = "InsertEnter",
        },
        --copy over ssh
        {
            'ojroques/nvim-osc52'
        },
        --latex
        {
            'frabjous/knap',
        },
        {
            "lervag/vimtex",
        },
        -- {
        --     "L3MON4D3/LuaSnip", build = "make install_jsregexp"
        -- },
        {
            "pwntester/octo.nvim",
            cmd = "Octo",
            opts = {
                picker = "telescope",
                enable_builtin = true,
            },
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-telescope/telescope.nvim",
                "nvim-tree/nvim-web-devicons",
            },
        },
        { "tpope/vim-fugitive" },
        -- {
        --     "saadparwaiz1/cmp_luasnip",
        -- },
        --sessions (restore files/layout per cwd; :lua require("persistence").load())
        {
            "folke/persistence.nvim",
            event = "BufReadPre",
            opts = {},
        },
        --nvim launched inside a :terminal (git commit, `nvim file`) opens in this nvim
        {
            "willothy/flatten.nvim",
            lazy = false,
            priority = 1001,
            opts = {
                hooks = {
                    -- git commit/rebase/tag etc. must wait until the buffer is closed
                    should_block = function(argv)
                        for _, arg in ipairs(argv) do
                            if arg:match("_EDITMSG$") or arg:match("MERGE_MSG$")
                                or arg:match("git%-rebase%-todo$") or arg:match("%.diff$") then
                                return true
                            end
                        end
                        return false
                    end,
                },
            },
        },
        {"tpope/vim-abolish"},
        -- {
        --     "evesdropper/luasnip-latex-snippets.nvim",
        -- }
        --AIIII
        -- {
        --     "olimorris/codecompanion.nvim",
        --     dependencies = {
        --         "nvim-lua/plenary.nvim",
        --         "nvim-treesitter/nvim-treesitter",
        --     },
        --     config = true
        -- },
    },
    {
        defaults = {
            lazy = false
        },
        install = {
            -- install missing plugins on startup. This doesn't increase startup time.
            missing = false,
        },

    })
