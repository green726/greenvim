-- harpoon/telescope load on first keypress (lazy spec runs harpoon:setup)
local noremap = { noremap = true }
local function harpoon() return require('harpoon') end


local function toggle_telescope(harpoon_files)
    local conf = require("telescope.config").values
    local finder = function()
        local paths = {}
        for _, item in ipairs(harpoon_files.items) do
            table.insert(paths, item.value)
        end

        return require("telescope.finders").new_table({
            results = paths,
        })
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = finder(),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_bufnr, map)
            map("i", "<C-d>", function()
                local state = require("telescope.actions.state")
                local selected_entry = state.get_selected_entry()
                local current_picker = state.get_current_picker(prompt_bufnr)

                table.remove(harpoon_files.items, selected_entry.index)
                current_picker:refresh(finder())
            end)
            return true
        end,
    }):find()
end


local com_cent = require("commander")
com_cent.add({
    {
        "Add harpoon mark",
        cmd = function() harpoon():list():add() end,
        keys = { { "n", "<Leader>a", noremap } }
    },

    {
        desc = "Open harpoon telescope",
        cmd = function() toggle_telescope(harpoon():list()) end,
        keys = { { "n", "<S-Tab>", noremap } }
    },
    {
        desc = "Harpoon next",
        cmd = function() harpoon():list():next() end,
        keys = { { "n", "<C-p>", noremap } }
    },
    {
        desc = "Harpoon prev",
        cmd = function() harpoon():list():prev() end,
        keys = { { "n", "<C-n>", noremap } }
    }
})
