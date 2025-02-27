local saga = require('lspsaga')


vim.diagnostic.config({
  severity_sort = true,
})

saga.setup({
    finder = {
        edit = { 'o', '<CR>' },
        vsplit = 's',
        split = 'i',
        tabe = 't',
        quit = { 'q', '<ESC>' },
    },
    code_action = {
        num_shortcut = true,
        keys = {
            -- string |table type
            quit = 'q',
            exec = '<CR>',
        },
    },
    lightbulb = {
        enable = false,
        enable_in_insert = false,
        sign = false,
        sign_priority = 50,
        virtual_text = false,
    },
    rename = {
        quit = '<C-c>',
        exec = '<CR>',
        mark = 'x',
        confirm = '<CR>',
        in_select = true,
        whole_project = true,
    },
    colors = {
        -- --float window normal background color
        -- normal_bg = '#1d1536',
        -- --title background color
        -- title_bg = '#afd700',
        -- red = '#e95678',
        -- magenta = '#b33076',
        -- orange = '#FF8700',
        -- yellow = '#f7bb3b',
        -- green = '#afd700',
        -- cyan = '#36d0e0',
        -- blue = '#61afef',
        -- purple = '#CBA6F7',
        -- white = '#d1d4cf',
        -- black = '#1c1c19',
    },
    ui = {
        code_action = "󰛨"
    }
})

-- saga.init_lsp_saga({
-- code_action_icon = "ﯦ ",
-- code_action_lightbulb = {
--     enable = true,
--     enable_in_insert = true,
--     cache_code_action = false,
--     sign = true,
--     update_time = 0,
--     sign_priority = 20,
--     virtual_text = false,
-- },
-- })
