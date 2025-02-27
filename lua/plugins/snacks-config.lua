return {
    dashboard = {
        enabled = true,
        preset = {
            header = require("random-headers"),
        },
        sections = {
            { section = "header", },
            { section = "keys",   gap = 1, padding = 1 },
            { section = "startup" },
        },
    },
    indent = {

    },
    bigfile = {

    },
    scratch = {
        -- ft = function()
        --     if vim.bo.buftype == "" and vim.bo.filetype ~= "" then
        --         return vim.bo.filetype
        --     end
        --     return "markdown"
        -- end
        ft = function()
            return "markdown"
        end
    },
    quickfile = {

    }
}
