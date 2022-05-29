require("nvim-lsp-installer").setup({
    ensure_installed = { "omnisharp", "sumneko_lua", "kotlin_language_server" }, -- ensure these servers are always installed
    automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
    ui = {
        icons = {
            server_installed = "✓",
            server_pending = "➜",
            server_uninstalled = "✗"
        }
    }
})
