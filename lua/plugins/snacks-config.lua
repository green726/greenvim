return {
    dashboard = {
        enabled = true,
        preset = {
            header = require("random-headers"),
            keys = {
                { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                { icon = " ", key = "c", desc = "Config", action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                { icon = "󰍔 ", key = "m", desc = "Markdown Library", action = ":MarkdownLibrary" },
                { icon = "󰒲 ", key = "L", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
                { icon = " ", key = "q", desc = "Quit", action = ":qa" },
            },
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
