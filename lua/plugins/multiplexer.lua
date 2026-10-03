-- Neovim as a terminal multiplexer: detachable, named sessions (nvim >= 0.12).
--
-- Every session is an nvim server reachable through `M.dir/<name>.sock` (the
-- socket itself, or a symlink to a plain nvim's socket). The `nvs` bash
-- function creates/attaches them; inside nvim, <leader>d detaches,
-- <leader>D / :Sessions views them, :SessionRename renames the current one.
--
-- Renaming moves the socket file and leaves the old path as a symlink alias:
-- terminals in the session still have $NVIM set to the old path (flatten.nvim
-- uses it). Aliases (symlinks pointing back into M.dir) are not listed.
local M = {}

M.dir = (vim.env.XDG_RUNTIME_DIR or "/tmp") .. "/nvim-sessions"

local function alive(sock)
    local ok, ch = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
    if not ok or ch == 0 then return false end
    vim.fn.chanclose(ch)
    return true
end

local function realpath(path)
    return vim.uv.fs_realpath(path) or path
end

-- Live sessions, sorted by name. Stale sockets/links are pruned; rename
-- aliases are hidden.
function M.list()
    local sessions = {}
    if vim.fn.isdirectory(M.dir) == 0 then return sessions end
    for file, kind in vim.fs.dir(M.dir) do
        local name = file:match("^(.*)%.sock$")
        if name and (kind == "socket" or kind == "link") then
            local sock = M.dir .. "/" .. file
            if not alive(sock) then
                os.remove(sock)
            elseif not (kind == "link" and vim.startswith(realpath(sock), M.dir .. "/")) then
                table.insert(sessions, { name = name, sock = sock })
            end
        end
    end
    table.sort(sessions, function(a, b) return a.name < b.name end)
    return sessions
end

local function is_current(sock)
    return realpath(sock) == realpath(vim.v.servername)
end

-- The listed session this nvim is, or nil for a plain, never-detached nvim.
local function current_session()
    for _, s in ipairs(M.list()) do
        if is_current(s.sock) then return s end
    end
end

-- This nvim's session name, or nil. Only scans the directory (no RPC), so it
-- is cheap enough to run on every UI attach.
local function own_name()
    if vim.v.servername == "" or vim.fn.isdirectory(M.dir) == 0 then return end
    local me = realpath(vim.v.servername)
    for file, kind in vim.fs.dir(M.dir) do
        local name = file:match("^(.*)%.sock$")
        local sock = name and M.dir .. "/" .. file
        if sock and realpath(sock) == me
            and not (kind == "link" and vim.startswith(me, M.dir .. "/") and sock ~= me) then
            return name
        end
    end
end

-- Terminal (kitty tab) title = session name. Attached UIs write it to their
-- own terminal, so it shows up on the local machine over ssh too. Plain,
-- unnamed nvims leave the title alone.
function M.update_title()
    local name = own_name()
    vim.o.titlestring = name and ("nvs:" .. name) or ""
    vim.o.title = name ~= nil
end

-- Retitle the session at `sock` (it may be another nvim).
local function retitle(sock)
    if is_current(sock) then return M.update_title() end
    local ok, ch = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
    if not ok or ch == 0 then return end
    pcall(vim.rpcrequest, ch, "nvim_exec_lua", "require('plugins/multiplexer').update_title()", {})
    vim.fn.chanclose(ch)
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
    if not current_session() then
        vim.fn.mkdir(M.dir, "p")
        local link = ("%s/%s-%d.sock"):format(M.dir, vim.fs.basename(vim.fn.getcwd()), vim.fn.getpid())
        vim.uv.fs_symlink(vim.v.servername, link)
    end
    vim.cmd.detach()
end

-- Rename session `old` (nil = this nvim) to `new`.
function M.rename(old, new)
    local function fail(msg) vim.notify(msg, vim.log.levels.ERROR, { title = "Sessions" }) end
    if not new or not new:match("^[%w%._-]+$") then
        return fail("invalid session name: " .. tostring(new) .. " (use letters, digits, . _ -)")
    end
    local dst = M.dir .. "/" .. new .. ".sock"
    if vim.uv.fs_lstat(dst) then
        if alive(dst) then return fail("session '" .. new .. "' already exists") end
        os.remove(dst)
    end
    vim.fn.mkdir(M.dir, "p")
    local src
    if old then
        src = M.dir .. "/" .. old .. ".sock"
    else
        local cur = current_session()
        if not cur then
            -- plain nvim that was never detached: give it a name
            vim.uv.fs_symlink(vim.v.servername, dst)
            M.update_title()
            return vim.notify("session named '" .. new .. "'", vim.log.levels.INFO, { title = "Sessions" })
        end
        old, src = cur.name, cur.sock
    end
    if old == new then return end
    local st = vim.uv.fs_lstat(src)
    if not st then return fail("no session named '" .. old .. "'") end
    local ok, err = vim.uv.fs_rename(src, dst)
    if not ok then return fail("rename failed: " .. err) end
    if st.type == "socket" then vim.uv.fs_symlink(dst, src) end -- alias for $NVIM in its terminals
    retitle(dst)
    vim.notify("session '" .. old .. "' renamed to '" .. new .. "'", vim.log.levels.INFO, { title = "Sessions" })
end

-- Runs inside each session to describe it for the viewer.
local describe_lua = [[
local terms, files = {}, {}
for _, b in ipairs(vim.api.nvim_list_bufs()) do
    local name = vim.api.nvim_buf_get_name(b)
    if vim.bo[b].buftype == "terminal" then
        table.insert(terms, vim.b[b].term_title or name)
    elseif vim.bo[b].buflisted and name ~= "" then
        table.insert(files, vim.fn.fnamemodify(name, ":~"))
    end
end
return { cwd = vim.fn.fnamemodify(vim.fn.getcwd(), ":~"), uis = #vim.api.nvim_list_uis(),
    tabs = #vim.api.nvim_list_tabpages(), terms = terms, files = files }
]]

local function describe(sock)
    if not sock or is_current(sock) then return loadstring(describe_lua)() end
    local ok, ch = pcall(vim.fn.sockconnect, "pipe", sock, { rpc = true })
    if not ok or ch == 0 then return {} end
    local ok2, info = pcall(vim.rpcrequest, ch, "nvim_exec_lua", describe_lua, {})
    vim.fn.chanclose(ch)
    return ok2 and info or {}
end

local function new_session()
    vim.ui.input({ prompt = "New session name: " }, function(name)
        if name and name ~= "" then M.open(name) end
    end)
end

-- Session viewer: <CR> attach, <C-e> rename.
function M.pick()
    local items = {}
    local cur = current_session()
    local sessions = M.list()
    if not cur then table.insert(sessions, 1, { unnamed = true }) end
    for _, s in ipairs(sessions) do
        local info = describe(s.sock)
        local current = s.unnamed or is_current(s.sock)
        local lines = {
            "# " .. (s.name or "this nvim (unnamed)"),
            "",
            "cwd:      " .. (info.cwd or "?"),
            "tabs:     " .. (info.tabs or "?"),
            "attached: " .. (current and "this UI" or (info.uis or 0) > 0 and ("yes (" .. info.uis .. " UI)") or "no"),
            "",
            "## terminals",
        }
        for _, t in ipairs(info.terms or {}) do table.insert(lines, "- " .. t) end
        vim.list_extend(lines, { "", "## files" })
        for _, f in ipairs(info.files or {}) do table.insert(lines, "- " .. f) end
        table.insert(items, {
            text = (s.name or "unnamed") .. " " .. (info.cwd or ""),
            name = s.name,
            current = current,
            info = info,
            preview = { text = table.concat(lines, "\n"), ft = "markdown" },
        })
    end
    table.insert(items, { text = "+ new session", new = true, preview = { text = "Start a new session" } })

    Snacks.picker.pick({
        title = "Sessions  <CR> attach · <C-e> rename",
        items = items,
        preview = "preview",
        layout = { preset = "default" },
        format = function(item)
            if item.new then return { { "+ new session", "SnacksPickerSpecial" } } end
            local info = item.info
            return {
                { ("%-20s"):format(item.name or "(unnamed)"), item.current and "SnacksPickerSpecial" or "SnacksPickerFile" },
                { ("%-10s"):format(item.current and "current" or info.uis and info.uis > 0 and "attached" or ""), "SnacksPickerComment" },
                { (" %d term  "):format(#(info.terms or {})), "SnacksPickerComment" },
                { info.cwd or "", "SnacksPickerDir" },
            }
        end,
        confirm = function(picker, item)
            picker:close()
            if not item then return end
            if item.new then return new_session() end
            if item.name then M.open(item.name) end
        end,
        actions = {
            session_rename = function(picker, item)
                if not item or item.new then return end
                picker:close()
                vim.ui.input({ prompt = "Rename session to: ", default = item.name }, function(new)
                    if new and new ~= "" then M.rename(item.name, new) end
                    vim.schedule(M.pick)
                end)
            end,
        },
        win = {
            input = { keys = { ["<c-e>"] = { "session_rename", mode = { "n", "i" } } } },
            list = { keys = { ["<c-e>"] = "session_rename" } },
        },
    })
end

vim.api.nvim_create_user_command("Sessions", function() M.pick() end, { desc = "View/attach sessions" })
vim.api.nvim_create_user_command("SessionRename", function(opts)
    if opts.args ~= "" then return M.rename(nil, opts.args) end
    local cur = current_session()
    vim.ui.input({ prompt = "Rename session to: ", default = cur and cur.name or "" }, function(new)
        if new and new ~= "" then M.rename(nil, new) end
    end)
end, { nargs = "?", desc = "Rename the current session" })

-- Terminal ergonomics
vim.opt.scrollback = 100000
local group = vim.api.nvim_create_augroup("Multiplexer", {})
-- disabled: terminals open in normal mode (press i/a to type)
-- vim.api.nvim_create_autocmd("TermOpen", { group = group, command = "startinsert" })
-- Like `tmux attach -d`: a newly attached UI detaches the others. Nvim sizes
-- the screen to the smallest attached UI, so a forgotten client (e.g. an ssh
-- session left open on another device) would otherwise shrink the session.
-- chan 0 is the builtin TUI, which cannot be detached remotely.
vim.api.nvim_create_autocmd("UIEnter", {
    group = group,
    callback = function()
        local new = vim.v.event.chan
        for _, ui in ipairs(vim.api.nvim_list_uis()) do
            if ui.chan and ui.chan ~= 0 and ui.chan ~= new then pcall(vim.fn.chanclose, ui.chan) end
        end
        M.update_title()
    end,
})
-- vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
--     group = group,
--     pattern = "term://*",
--     command = "startinsert",
-- })
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

-- Terminal titles in the tabline and statusline. Programs set the title with
-- OSC 0/2 (bash's PROMPT_COMMAND from /etc/bash.bashrc sets user@host:cwd at
-- each prompt; htop, ssh, nvim, etc. set their own). Nvim keeps it in
-- b:term_title, which starts out as the term:// buffer name. Nvim redraws the
-- statuslines itself when it changes, but not the tabline (timer below).
local function term_title(buf)
    if vim.bo[buf].buftype ~= "terminal" then return end
    local title = vim.b[buf].term_title
    if title and title ~= "" and title ~= vim.api.nvim_buf_get_name(buf) then return title end
end

local function escape(s) return (s:gsub("%%", "%%%%")) end

-- %{%...%} item replacing the default statusline's %f. While it is evaluated
-- the statusline's window is temporarily current (g:statusline_winid is only
-- set for %! expressions).
function M.statusline_name()
    local title = term_title(vim.api.nvim_get_current_buf())
    return title and escape(title) or "%f"
end

-- The builtin tabline's layout (window count, "+" when modified, shortened
-- path, close button) with terminal titles in place of term:// names.
function M.tabline()
    local tabs = vim.api.nvim_list_tabpages()
    local cur = vim.api.nvim_get_current_tabpage()
    local room = math.max(8, math.floor(vim.o.columns / #tabs) - 4)
    local parts = {}
    for i, tab in ipairs(tabs) do
        local wins, modified = 0, false
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            if vim.api.nvim_win_get_config(win).relative == "" then
                wins = wins + 1
                modified = modified or vim.bo[vim.api.nvim_win_get_buf(win)].modified
            end
        end
        local buf = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
        local label = term_title(buf)
        if not label then
            local name = vim.api.nvim_buf_get_name(buf)
            label = name == "" and "[No Name]" or vim.fn.pathshorten(vim.fn.fnamemodify(name, ":~:."))
        end
        local len = vim.fn.strchars(label)
        if len > room then label = "<" .. vim.fn.strcharpart(label, len - room + 1) end
        local prefix = (wins > 1 and tostring(wins) or "") .. (modified and "+" or "")
        parts[#parts + 1] = ("%%#%s#%%%dT %s%s "):format(
            tab == cur and "TabLineSel" or "TabLine", i, prefix ~= "" and prefix .. " " or "", escape(label))
    end
    parts[#parts + 1] = "%#TabLineFill#%T%="
    if #tabs > 1 then parts[#parts + 1] = "%#TabLine#%999XX" end
    return table.concat(parts)
end

-- luaeval, not v:lua: v:lua.require'...' rejects the "/" in the module name.
vim.o.tabline = [[%!luaeval("require('plugins/multiplexer').tabline()")]]
do
    local default = vim.api.nvim_get_option_info2("statusline", {}).default
    local patched, n = default:gsub("%%f", [[%%{%%luaeval("require('plugins/multiplexer').statusline_name()")%%}]], 1)
    if n == 1 then vim.o.statusline = patched end
end

-- Disabled: crashed nvim (SIGABRT). The watcher runs while nvim is processing
-- terminal output inside its event loop; the Vimscript callback's breakcheck
-- polls that loop again, and nvim abort()s on loop re-entry. It hit after
-- ~1000 title changes (bash retitles at every prompt).
-- -- Coalesces bursts (some programs retitle on every frame) into one redraw.
-- local redraw_pending = false
-- function M.redraw_lines()
--     if redraw_pending then return end
--     redraw_pending = true
--     vim.schedule(function()
--         redraw_pending = false
--         vim.cmd("redrawstatus! | redrawtabline")
--     end)
-- end
-- vim.api.nvim_create_autocmd("TermOpen", {
--     group = group,
--     command = [[call dictwatcheradd(b:, 'term_title', {d, k, c -> luaeval("require('plugins/multiplexer').redraw_lines()")})]],
-- })

-- Instead a timer (runs from the main loop, so it is safe) redraws the tabline
-- when its text changed, which also covers terminals in other tabs.
do
    local last
    if vim.g.multiplexer_tabline_timer then pcall(vim.fn.timer_stop, vim.g.multiplexer_tabline_timer) end
    vim.g.multiplexer_tabline_timer = vim.fn.timer_start(500, function()
        local ok, line = pcall(M.tabline)
        if ok and line ~= last then
            last = line
            vim.cmd.redrawtabline()
        end
    end, { ["repeat"] = -1 })
end

local noremap = { noremap = true }
require("commander").add({
    {
        desc = "Detach session",
        cmd = M.detach,
        keys = { { "n", "<Leader>d", noremap } }
    },
    {
        desc = "View sessions",
        cmd = M.pick,
        keys = { { "n", "<Leader>D", noremap } }
    },
    {
        desc = "Rename session",
        cmd = "<cmd>SessionRename<CR>",
        keys = { { "n", "<Leader>R", noremap } }
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
