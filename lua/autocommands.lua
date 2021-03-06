local M = {}

local autoFileTypes = {"cs", "csharp", "python", "py", "javascript", "js", "lua"}

vim.cmd([[autocmd User SessionLoadPost lua require"nvim-tree".toggle(false, true)]])
-- vim.cmd [[autocmd CursorHold * lua DiagAndDocs()]]
-- vim.cmd [[autocmd CursorHoldI * lua vim.lsp.buf.hover()]]
-- vim.cmd [[autocmd CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=true, scope="cursor"})]]


DiagAndDocs = function()
    -- local diagWin = vim.diagnostic.open_float(nil, { focus = false, scope = "cursor" })
    -- if diagWin ~= nil then
    --     return
    -- else
    if vim.api.nvim_buf_get_name(0) == "NvimTree" then
        return
    end
    for i, v in ipairs(autoFileTypes) do 
        if v == vim.bo.filetype then
            vim.lsp.buf.hover()
            return
        end
    end
end

LSPFormat = function()
    if (vim.bo.filetype ~= "lua" and vim.bo.filetype ~= "kotlin") then
        vim.lsp.buf.formatting()
        vim.cmd [[:w]]
    end
end

vim.cmd([[autocmd CursorHold,BufEnter <buffer> lua require('lsp-status').update_current_function()]])
-- vim.cmd [[autocmd CursorHold * lua vim.diagnostic.open_float(nil, {focus=true, scope="cursor"})]]

vim.cmd [[autocmd BufWrite * lua LSPFormat()]]

return M

--first line of code below is to prevent screen tearing
--below comments are to remember stuff - first is call docs on cursor hold, second is echo char under cursor
--autocmd CursorHold *.cs :OmniSharpDocumentation
--autocmd CursorHold *.cs :echo matchstr(getline('.'), '\%' . col('.') . 'c.')
-- vim.cmd([[
--     let g:csDocsToggled = 0
--     let g:cursorWord = ""
--     func CsDocs()
--       let wordsIgnore = ['', ' ', '(', ')', '{', '}', ';', 'public', 'static', 'private', 'void', 'for', 'foreach', 'if', 'else', 'true', 'false', '&&', '[', ']', 'class', 'using']
--       let g:cursorWord = expand("<cword>") "get cursor word, above is a list of words to ignore
--       let char =  matchstr(getline('.'), '\%' . col('.') . 'c.') "get char under cursor
--       let line = matchstr(getline('.'), '^\s*\/') "check if first char of line is a comment (/)
--       if line != ''
--         let g:csDocsToggled = 0
--         return
--       endif
--       for i in wordsIgnore
--         if g:cursorWord == i
--           let g:csDocsToggled = 0
--           return
--         endif
--       endfor
--         if char != '' && char != ' ' && g:csDocsToggled == 0
--           let g:csDocsToggled = 1
--           " echo "csDocsToggledPostIf" . g:csDocsToggled
--           :OmniSharpDocumentation
--         endif
--     endfunc
--
--   func CsDocsOff()
--     let l:currentWord = expand("<cword>")
--     if g:cursorWord == l:currentWord && g:csDocsToggled == 1
--       return
--     else
--       let g:csDocsToggled = 0
--     endif
--
--   endfunc
--
--
--     let testnum = 0
--     func TestLog()
--         g:testnum = g:testnum + 1
--         echo 'test ' . g:testnum
--     endfunc
--
--     autocmd CursorMoved *.cs call CsDocsOff()
--     autocmd CursorHold *.cs call CsDocs()
--     autocmd CursorHold *.java silent! call CocActionAsync('doHover')
--     autocmd BufWrite *.cs :OmniSharpCodeFormat
--     ]])
--     autocmd BufEnter * highlight Normal guibg=0
--need to write CsDocs into a toggle so it doesn't spam refresh b/c it is triggering cursor movement causing cursor hold to spam refresh
--
