-- Neovim as a terminal multiplexer: detachable, named sessions (nvim >= 0.12).
--
-- Every session is an nvim server whose socket lives in `M.dir`. The `nvs`
-- bash function creates/attaches them; inside nvim, <leader>d detaches and
-- <leader>D switches sessions (like tmux choose-session).
local M = {}

M.dir = (vim.env.XDG_RUNTIME_DIR or "/tmp") .. "/nvim-sessions"

local function alive(sock)
    local ok, ch = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
    if not ok or ch == 0 then return false end
    vim.fn.chanclose(ch)
    return true
end

-- Live sessions, sorted by name. Stale sockets/links are pruned.
function M.list()
    local sessions = {}
    if vim.fn.isdirectory(M.dir) == 0 then return sessions end
    for file, kind in vim.fs.dir(M.dir) do
        local name = file:match("^(.*)%.sock$")
        if name and (kind == "socket" or kind == "link") then
            local sock = M.dir .. "/" .. file
            if alive(sock) then
                table.insert(sessions, { name = name, sock = sock })
            else
                os.remove(sock)
            end
        end
    end
    table.sort(sessions, function(a, b) return a.name < b.name end)
    return sessions
end

local function is_current(sock)
    return sock == vim.v.servername or vim.uv.fs_realpath(sock) == vim.v.servername
end

-- Attach this UI to session `name`, starting it (in a terminal) if needed.
function M.open(name)
    local sock = M.dir .. "/" .. name .. ".sock"
    if is_current(sock) then return end
    if not alive(sock) then
        os.remove(sock)
        vim.fn.mkdir(M.dir, "p")
        -- env -u NVIM: otherwise flatten.nvim treats the new server as a nested guest
        vim.fn.jobstart({ "env", "-u", "NVIM", "nvim", "--headless", "--listen", sock, "+terminal" },
            { detach = true, cwd = vim.fn.getcwd() })
        if not vim.wait(3000, function() return alive(sock) end, 20) then
            vim.notify("session '" .. name .. "' failed to start", vim.log.levels.ERROR)
            return
        end
    end
    vim.cmd.connect(sock)
end

-- Detach the UI; the server (and its terminals) keeps running.
-- Sessions started with plain `nvim` get a symlink so `nvs` can find them.
function M.detach()
    if not vim.startswith(vim.v.servername, M.dir .. "/") then
        vim.fn.mkdir(M.dir, "p")
        local link = ("%s/%s-%d.sock"):format(M.dir, vim.fs.basename(vim.fn.getcwd()), vim.fn.getpid())
        vim.uv.fs_symlink(vim.v.servername, link)
    end
    vim.cmd.detach()
end

function M.pick()
    local items = M.list()
    table.insert(items, { name = "+ new session" })
    vim.ui.select(items, {
        prompt = "Sessions",
        format_item = function(s)
            return s.sock and is_current(s.sock) and s.name .. " (current)" or s.name
        end,
    }, function(choice)
        if not choice then return end
        if choice.sock then return M.open(choice.name) end
        vim.ui.input({ prompt = "New session name: " }, function(name)
            if name and name ~= "" then M.open(name) end
        end)
    end)
end

-- Terminal ergonomics
vim.opt.scrollback = 100000
local group = vim.api.nvim_create_augroup("Multiplexer", {})
vim.api.nvim_create_autocmd("TermOpen", { group = group, command = "startinsert" })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
    group = group,
    pattern = "term://*",
    command = "startinsert",
})
-- `nvs name` inside a :terminal prints OSC 1337;nvs=<name>. It is handled
-- in-process because :connect targets the last UI to talk to the server, and a
-- `nvim --remote-send` client would claim that role and break it.
vim.api.nvim_create_autocmd("TermRequest", {
    group = group,
    callback = function(args)
        local seq = type(args.data) == "table" and args.data.sequence or args.data
        local name = seq:match("^\027%]1337;nvs=([%w%._-]+)")
        if name then vim.schedule(function() M.open(name) end) end
    end,
})

local noremap = { noremap = true }
require("commander").add({
    {
        desc = "Detach session",
        cmd = M.detach,
        keys = { { "n", "<Leader>d", noremap } }
    },
    {
        desc = "Switch session",
        cmd = M.pick,
        keys = { { "n", "<Leader>D", noremap } }
    },
    {
        desc = "Window left",
        cmd = "<cmd>wincmd h<CR>",
        keys = { { { "n", "t" }, "<A-h>", noremap } }
    },
    {
        desc = "Window down",
        cmd = "<cmd>wincmd j<CR>",
        keys = { { { "n", "t" }, "<A-j>", noremap } }
    },
    {
        desc = "Window up",
        cmd = "<cmd>wincmd k<CR>",
        keys = { { { "n", "t" }, "<A-k>", noremap } }
    },
    {
        desc = "Window right",
        cmd = "<cmd>wincmd l<CR>",
        keys = { { { "n", "t" }, "<A-l>", noremap } }
    },
})

return M
