local alpha = require('alpha')
local dashboard = require('alpha.themes.dashboard')

dashboard.section.header.val = {
    [[  _____                      ___________   ____ ]],
    [[ |  __ \                    |___  / __  \ / ___| ]],
    [[ | |  \/_ __ ___  ___ _ __     / /`' / /'/ /___  ]],
    [[ | | __| '__/ _ \/ _ \ '_ \   / /   / /  | ___ \ ]],
    [[ | |_\ \ | |  __/  __/ | | |./ /  ./ /___| \_/ | ]],
    [[  \____/_|  \___|\___|_| |_|\_/   \_____/\_____/ ]]
}

dashboard.section.buttons.val = {
    dashboard.button( "o", "  Open File Tree", ":e . <CR>"),
    dashboard.button( "e", "  New file" , ":ene <BAR> startinsert <CR>"),
    dashboard.button( "q", "  Quit NVIM" , ":q!<CR>")
}

dashboard.config.opts.noautocmd = true

vim.cmd[[autocmd User AlphaReady echo 'Hello there!']]

alpha.setup(dashboard.config)