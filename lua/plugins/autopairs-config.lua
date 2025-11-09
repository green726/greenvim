local npairs = require('nvim-autopairs')

require('nvim-autopairs').setup({
    disable_filetype = { "TelescopePrompt", "vim", "JABSWindow", "neo-tree", "aerial" },
    check_ts = false,
-- -add $ autopair in latex-
})


local cond = require('nvim-autopairs.conds')
local Rule = require('nvim-autopairs.rule')

npairs.add_rules({
  Rule("$", "$",{"tex", "latex"})
    -- don't add a pair if the next character is %
    :with_pair(cond.not_after_regex("%%"))
    -- don't add a pair if  the previous character is xxx
    :with_pair(cond.not_before_regex("xxx", 3))
    -- don't move right when repeat character
    :with_move(cond.none())
    -- don't delete if the next character is xx
    :with_del(cond.not_after_regex("xx"))
    -- disable adding a newline when you press <cr>
    :with_cr(cond.none())
  },
  -- disable for .vim files, but it work for another filetypes
  Rule("a","a","-vim")
)
