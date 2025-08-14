require("mason").setup()
require("mason-lspconfig").setup()

require("mason-lspconfig").setup({
    ensure_installed = { --[[ "lua-language-server", ]] }
})


-- Add additional capabilities supported by nvim-cmp
-- local capabilities = vim.lsp.protocol.make_client_capabilities()
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- capabilities.textDocument.foldingRange = {
--     dynamicRegistration = false,
--     lineFoldingOnly = true
-- }

local clangCapabilities = capabilities
clangCapabilities.offsetEncoding = { "utf-16" }


local lspconfig = require('lspconfig')

local function custom_attach(client)
    -- require("aerial").on_attach(client)
    -- require('folding').on_attach()
end

require("lspconfig")["ocamllsp"].setup {
    on_attach = custom_attach,
    capabilities = capabilities,
}


-- require("mason-lspconfig").setup_handlers {
--     -- The first entry (without a key) will be the default handler
--     -- and will be called for each installed server that doesn't have
--     -- a dedicated handler.
--     function(server_name) -- default handler (optional)
--         require("lspconfig")[server_name].setup {
--             on_attach = custom_attach,
--             capabilities = capabilities,
--         }
--     end,
--     -- Next, you can provide a dedicated handler for specific servers.
--     -- For example, a handler override for the `rust_analyzer`:
--     ["clangd"] = function()
--         require 'lspconfig'.clangd.setup {
--             -- root_dir = lspconfig.util.root_pattern(
--             --     -- 'meson.build',
--             --     -- '.clangd',
--             --     -- '.clang-tidy',
--             --     'compile_commands.json'
--             --     -- 'compile_flags.txt'
--             --     -- '.clang-format'
--             --     -- 'configure.ac'
--             -- ),
--             capabilities = clangCapabilities,
--             on_attach = custom_attach,
--         }
--     end,
--     ["jdtls"] = function()
--         lspconfig.jdtls.setup {
--             capabilities = capabilities,
--             on_attach = custom_attach,
--             settings = {
--                 java = { signatureHelp = { enabled = true }, contentProvider = { preferred = 'fernflower' } }
--             }
--         }
--     end
-- }

vim.api.nvim_create_autocmd("LspAttach", {
    desc = "Fix startup error by disabling semantic tokens for omnisharp",
    group = vim.api.nvim_create_augroup("OmnisharpHook", {}),
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client.name == "omnisharp" then
            client.server_capabilities.semanticTokensProvider = nil
        end
    end,
})
