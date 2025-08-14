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
        { "nvim-treesitter/nvim-treesitter" },
        --file finder
        { "nvim-telescope/telescope.nvim",  lazy = false },
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
        --nvim lsp-config
        { "neovim/nvim-lspconfig" },
        --INSTALLER FOR EVERYTHING
        { "williamboman/mason.nvim" },
        --plugin for mason for nvim-config
        { 'williamboman/mason-lspconfig.nvim' },
        --auto complete
        {
            'hrsh7th/nvim-cmp',
            lazy = true
        },
        --lsp source for nvim-cmp
        { 'hrsh7th/cmp-nvim-lsp' },
        --file path completion for nvim-cmp
        { 'hrsh7th/cmp-path' },
        --better search highlighting
        { 'kevinhwang91/nvim-hlslens' },
        --lsp function signature help
        { 'ray-x/lsp_signature.nvim' },
        --movements/motions stuff
        -- { 'phaazon/hop.nvim' },
        --lsp signs stuff
        { "onsails/lspkind.nvim" },
        -- various lsp extensions (pretty much all the above commented out stuff for lsp)
        { 'glepnir/lspsaga.nvim' },
        --better buffer deletion
        { 'kazhala/close-buffers.nvim' },
        --cut and delete seperate
        { 'gbprod/cutlass.nvim' },
        --folds
        { 'kevinhwang91/nvim-ufo',                       lazy = true },
        --jdtls
        { "mfussenegger/nvim-jdtls",                     lazy = true },
        --keymaps stuff
        { "FeiyouG/command_center.nvim" },
        { "nvim-telescope/telescope-live-grep-args.nvim" },
        {
            "ThePrimeagen/harpoon",
            branch = "harpoon2",
        },
        {
            "folke/flash.nvim",
            lazy = true,
        },
        { 'folke/which-key.nvim' },
        {
            "mikavilpas/yazi.nvim",
            event = "VeryLazy",
        },
        --a necessary plugin to make treesitter work
        { 'reasonml-editor/vim-reason-plus' },
        {
            'github/copilot.vim'
        },
        --copy over ssh
        {
        'ojroques/nvim-osc52'
        },
        --AIIII
        {
            "olimorris/codecompanion.nvim",
            dependencies = {
                "nvim-lua/plenary.nvim",
                "nvim-treesitter/nvim-treesitter",
            },
            config = true
        },
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
