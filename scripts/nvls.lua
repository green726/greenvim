-- Fast session listing for `nvls` (see ~/.bashrc and MULTIPLEXER.md).
-- Run as: nvim --clean --headless -l nvls.lua <session dir>
-- A session is alive if its socket accepts a connection. The kernel accepts
-- connections even while nvim is busy, so a slow or blocked session doesn't
-- hold up the listing (unlike an RPC call such as --remote-expr).
-- Dead sockets are removed. Rename aliases (symlinks back into the dir, see
-- multiplexer.lua) are hidden.
local dir = assert(arg[1], "usage: nvls.lua <dir>")
local real_dir = vim.uv.fs_realpath(dir) or dir
local names = {}
for file, kind in vim.fs.dir(dir) do
    local name = file:match("^(.*)%.sock$")
    if name then
        local path = dir .. "/" .. file
        local real = vim.uv.fs_realpath(path)
        local ok, ch = pcall(vim.fn.sockconnect, "pipe", path)
        if not real or not ok or ch == 0 then
            os.remove(path)
        else
            vim.fn.chanclose(ch)
            if kind ~= "link" or not vim.startswith(real, real_dir .. "/") then
                names[#names + 1] = name
            end
        end
    end
end
table.sort(names)
if #names > 0 then io.stdout:write(table.concat(names, "\n"), "\n") end
