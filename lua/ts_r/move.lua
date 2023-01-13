local ts_utils = require("nvim-treesitter.ts_utils")
local h = require("ts_r.helper")
local v = vim
local M = {}

-- dir = "bW" if going back, dir = "W" if going forward
local find_fence = function (flags)
    -- Maybe use setpos and search?
    local node = ts_utils.get_node_at_cursor()
    local jump_pos = 0
    local start_row, end_row = 0, 0
    if node == nil then
        error("Node is null")
    end
    -- If in a chunk, find the root of the chunk
    if h.in_chunk(node) then
        node = h.engulf_chunk(node)
        start_row, _, end_row, _ = node:range()
        -- If going back, set to start of chunk, otherwise set to end
        if string.match(flags, "b") then
            v.api.nvim_win_set_cursor(0, {start_row - 1, 0})
        else
            v.api.nvim_win_set_cursor(0, {end_row + 1, 0})
        end
    end
    jump_pos = v.fn.search("```{", flags)

    -- Positional corrections if at beginning or end
    if jump_pos == 0 and string.match(flags, "b") then
        v.cmd("norm j")
    end
    if jump_pos == 0 and not string.match(flags, "b") then
        v.api.nvim_win_set_cursor(0, {start_row, 0})
    end

    v.cmd("norm j") -- Places user inside chunk

    -- Return if at start/end of the file
    return jump_pos ~= 0
end

M.move_chunk_down = function ()
    return find_fence('Wc')
end

M.move_chunk_up = function ()
    return find_fence('bWc')
end

return M
