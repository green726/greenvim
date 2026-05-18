local M = {}

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")

M.root = vim.fs.normalize(vim.fn.expand("~/opt32"))

local repo_cache = {}
local metadata_cache = {}

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Markdown Library" })
end

local function normalize(path)
    return vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
end

local function exists(path)
    return vim.uv.fs_stat(path) ~= nil
end

local function is_markdown_path(path)
    local lower = path:lower()
    return lower:match("%.md$") ~= nil
        or lower:match("%.markdown$") ~= nil
        or lower:match("%.mdx$") ~= nil
end

local function is_under_root(path)
    local normalized = normalize(path)
    return normalized == M.root or vim.startswith(normalized, M.root .. "/")
end

local function relative_to(base, path)
    return vim.fs.relpath(base, path) or path
end

local function repo_root_for(path)
    local dir = vim.fs.dirname(path)
    if repo_cache[dir] ~= nil then
        return repo_cache[dir] or nil
    end

    local git_dir = vim.fs.find(".git", {
        path = dir,
        upward = true,
        stop = M.root,
        type = "directory",
    })[1]

    if not git_dir then
        git_dir = vim.fs.find(".git", {
            path = dir,
            upward = true,
            stop = M.root,
            type = "file",
        })[1]
    end

    local repo_root = git_dir and vim.fs.dirname(git_dir) or false
    repo_cache[dir] = repo_root
    return repo_root or nil
end

local function metadata_for(path)
    local normalized = normalize(path)
    if metadata_cache[normalized] then
        return metadata_cache[normalized]
    end

    local repo_root = repo_root_for(normalized)
    local metadata = {
        path = normalized,
        repo_root = repo_root,
        repo_name = repo_root and vim.fs.basename(repo_root) or "-",
        root_relative = relative_to(M.root, normalized),
        repo_relative = repo_root and relative_to(repo_root, normalized) or relative_to(M.root, normalized),
    }

    metadata_cache[normalized] = metadata
    return metadata
end

local function current_markdown_path()
    local path = vim.api.nvim_buf_get_name(0)
    if path == "" then
        return nil
    end

    local normalized = normalize(path)
    if not is_under_root(normalized) or not is_markdown_path(normalized) then
        return nil
    end

    return normalized
end

local function detach_lsp_clients(bufnr)
    for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
        pcall(vim.lsp.buf_detach_client, bufnr, client.id)
    end
end

local function mark_buffer(bufnr, metadata, mode)
    vim.b[bufnr].markdown_library_managed = true
    vim.b[bufnr].markdown_library_disable_lsp = true
    vim.b[bufnr].markdown_library_mode = mode
    vim.b[bufnr].markdown_library_source_path = metadata.path
    vim.b[bufnr].markdown_library_repo_name = metadata.repo_name
    vim.b[bufnr].markdown_library_repo_root = metadata.repo_root
    vim.b[bufnr].markdown_library_root_relative = metadata.root_relative
end

local function enable_render_markdown(bufnr)
    local ok, render_markdown = pcall(require, "render-markdown")
    if not ok then
        return
    end

    render_markdown.buf_enable()
    render_markdown.render({ buf = bufnr })
end

local function prepare_target_window()
    local bufnr = vim.api.nvim_get_current_buf()
    if vim.bo[bufnr].modified then
        vim.cmd("tabnew")
    end
end

local function configure_edit_buffer(metadata)
    local bufnr = vim.api.nvim_get_current_buf()
    mark_buffer(bufnr, metadata, "edit")
    vim.bo[bufnr].readonly = false
    vim.bo[bufnr].modifiable = true
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    detach_lsp_clients(bufnr)
    enable_render_markdown(bufnr)
end

local function viewer_keymaps(bufnr)
    vim.keymap.set("n", "q", "<cmd>bd!<CR>", {
        buffer = bufnr,
        noremap = true,
        silent = true,
        desc = "Close markdown viewer",
    })

    vim.keymap.set("n", "e", function()
        M.open_file(vim.b[bufnr].markdown_library_source_path)
    end, {
        buffer = bufnr,
        noremap = true,
        silent = true,
        desc = "Edit markdown source",
    })
end

local function create_viewer_buffer(metadata)
    prepare_target_window()

    local lines = vim.fn.readfile(metadata.path)
    if #lines == 0 then
        lines = { "" }
    end

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_win_set_buf(0, bufnr)
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)

    vim.bo[bufnr].buftype = "nofile"
    vim.bo[bufnr].bufhidden = "wipe"
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].filetype = "markdown"
    vim.bo[bufnr].modifiable = false
    vim.bo[bufnr].readonly = true

    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.opt_local.conceallevel = 2

    mark_buffer(bufnr, metadata, "view")
    detach_lsp_clients(bufnr)
    viewer_keymaps(bufnr)
    enable_render_markdown(bufnr)

    notify(("Viewing [%s] %s"):format(metadata.repo_name, metadata.root_relative))
end

local function markdown_files()
    if not exists(M.root) then
        notify(("Markdown root does not exist: %s"):format(M.root), vim.log.levels.ERROR)
        return {}
    end

    if vim.fn.executable("rg") ~= 1 then
        notify("ripgrep is required for the markdown library picker", vim.log.levels.ERROR)
        return {}
    end

    local result = vim.system({
        "rg",
        "--files",
        "-g",
        "*.md",
        "-g",
        "*.markdown",
        "-g",
        "*.mdx",
    }, {
        cwd = M.root,
        text = true,
    }):wait()

    if result.code ~= 0 then
        notify(result.stderr ~= "" and result.stderr or "failed to scan markdown files", vim.log.levels.ERROR)
        return {}
    end

    local files = {}
    for _, relative_path in ipairs(vim.split(result.stdout, "\n", { trimempty = true })) do
        files[#files + 1] = metadata_for(M.root .. "/" .. relative_path)
    end

    table.sort(files, function(left, right)
        return left.root_relative < right.root_relative
    end)

    return files
end

local function picker_entry_maker(metadata)
    local displayer = entry_display.create({
        separator = " ",
        items = {
            { width = 18 },
            { remaining = true },
        },
    })

    return {
        value = metadata,
        ordinal = table.concat({
            metadata.repo_name,
            metadata.root_relative,
            metadata.repo_relative,
        }, " "),
        display = function(entry)
            return displayer({
                { entry.value.repo_name, "TelescopeResultsIdentifier" },
                entry.value.root_relative,
            })
        end,
        filename = metadata.path,
        path = metadata.path,
    }
end

local function with_selection(prompt_bufnr, callback)
    local entry = action_state.get_selected_entry()
    actions.close(prompt_bufnr)
    if entry and entry.value then
        callback(entry.value)
    end
end

function M.open_picker()
    local files = markdown_files()
    if #files == 0 then
        notify(("No markdown files found under %s"):format(M.root))
        return
    end

    pickers.new({}, {
        prompt_title = ("Markdown Library: %s"):format(M.root),
        finder = finders.new_table({
            results = files,
            entry_maker = picker_entry_maker,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                with_selection(prompt_bufnr, M.open_viewer)
            end)

            map({ "i", "n" }, "<C-e>", function()
                with_selection(prompt_bufnr, M.open_file)
            end)

            return true
        end,
    }):find()
end

function M.open_viewer(item)
    local metadata = type(item) == "table" and item.path and item or metadata_for(item)
    create_viewer_buffer(metadata)
end

function M.open_file(item)
    local metadata = type(item) == "table" and item.path and item or metadata_for(item)
    prepare_target_window()
    vim.cmd.edit(vim.fn.fnameescape(metadata.path))
    configure_edit_buffer(metadata)
end

function M.view_current()
    local source_path = vim.b.markdown_library_source_path
    if source_path and exists(source_path) then
        M.open_viewer(source_path)
        return
    end

    local path = current_markdown_path()
    if not path then
        notify(("Current buffer is not a markdown file under %s"):format(M.root), vim.log.levels.WARN)
        return
    end

    M.open_viewer(path)
end

function M.edit_current()
    local source_path = vim.b.markdown_library_source_path
    if source_path and exists(source_path) then
        M.open_file(source_path)
        return
    end

    local path = current_markdown_path()
    if not path then
        notify(("Current buffer is not a markdown file under %s"):format(M.root), vim.log.levels.WARN)
        return
    end

    configure_edit_buffer(metadata_for(path))
end

function M.setup()
    if M._setup_complete then
        return
    end

    local map_opts = { noremap = true, silent = true, nowait = true }
    local function set_maps()
        vim.keymap.set("n", "tm", M.open_picker, vim.tbl_extend("force", map_opts, {
            desc = "Open markdown library",
        }))
        vim.keymap.set("n", "tv", M.view_current, vim.tbl_extend("force", map_opts, {
            desc = "View current markdown file",
        }))
        vim.keymap.set("n", "te", M.edit_current, vim.tbl_extend("force", map_opts, {
            desc = "Edit current markdown file without LSP",
        }))
        vim.keymap.set("n", "<leader>tm", M.open_picker, vim.tbl_extend("force", map_opts, {
            desc = "Open markdown library",
        }))
        vim.keymap.set("n", "<leader>tv", M.view_current, vim.tbl_extend("force", map_opts, {
            desc = "View current markdown file",
        }))
        vim.keymap.set("n", "<leader>te", M.edit_current, vim.tbl_extend("force", map_opts, {
            desc = "Edit current markdown file without LSP",
        }))
    end

    vim.api.nvim_create_user_command("MarkdownLibrary", function()
        M.open_picker()
    end, { desc = "Browse markdown files under ~/opt32" })

    vim.api.nvim_create_user_command("MarkdownView", function()
        M.view_current()
    end, { desc = "Open markdown viewer for current file" })

    vim.api.nvim_create_user_command("MarkdownEdit", function()
        M.edit_current()
    end, { desc = "Edit current markdown file with LSP disabled" })

    if vim.v.vim_did_enter == 1 then
        set_maps()
    else
        vim.api.nvim_create_autocmd("VimEnter", {
            group = vim.api.nvim_create_augroup("MarkdownLibraryMappings", { clear = true }),
            once = true,
            callback = set_maps,
        })
    end

    M._setup_complete = true
end

return M
