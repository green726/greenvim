-- addons
local lspkind = require('lspkind')

local cmp_autopairs = require('nvim-autopairs.completion.cmp')


local function filter_annoying_backslash(item, context)
    -- Get the two characters before the cursor
    local two_chars_before = string.sub(context.cursor_before_line, -2)

    -- If the user just typed '\\' and the completion item's label is '\',
    -- then return 'false' to filter it out.
    if two_chars_before == '\\\\' and item.label == '\\' then
        return false
    end

    -- Otherwise, keep the completion item
    return true
end



-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
    mapping = cmp.mapping.preset.insert({
        ['<C-d>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<CR>'] = cmp.mapping.confirm {
            behavior = cmp.ConfirmBehavior.Replace,
            select = true,
        },
        ['<C-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            else
                fallback()
            end
        end, { 'i', 's' }),
        ['<C-e>'] = cmp.mapping.abort(),
    }),
    sources = {
        { name = 'nvim_lsp', max_item_count = 5 },
        { name = 'path',     max_item_count = 3 },
        { name = 'luasnip', max_item_count = 5, option = {
            filter = filter_annoying_backslash,
        } },
        -- { name = 'buffer',   max_item_count = 5 },
        -- { name = 'cmp_tabnine', max_item_count = 20 }
    },
    enabled = function()
        -- disable completion in comments
        local context = require 'cmp.config.context'
        -- keep command mode completion enabled when cursor is in a comment
        if vim.api.nvim_get_mode().mode == 'c' then
            return true
        else
            if vim.bo.filetype == "TelescopePrompt" then return end
            return not context.in_treesitter_capture("comment")
                and not context.in_syntax_group("Comment")
        end
    end,
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol_text', -- show only symbol annotations
            maxwidth = 50,        -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            menu = {
                buffer = "[Buffer]",
                nvim_lsp = "[LSP]",
                nvim_lua = "[Lua]",
            },
        })
    },

}

-- cmp.setup.filetype('tex', {
--   sources = cmp.config.sources({
--     { name = 'nvim_lsp',
--       -- This disables the trigger characters for the LSP source in tex files
--       option = { trigger_characters = false }
--     },
--     { name = 'buffer' },
--     { name = 'luasnip' }
--   })
-- })

-- autopairs
cmp.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done()
)

-- `/` cmdline setup.
cmp.setup.cmdline('/', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})


-- Use cmdline & path source for ':'
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.insert(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        {
            name = 'cmdline',
            option = {
                ignore_cmds = { 'Man', '!' }
            }
        }
    })
})
