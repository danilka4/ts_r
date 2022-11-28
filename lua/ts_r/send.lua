local term = require("ts_r.term")
local ts_utils = require("nvim-treesitter.ts_utils")
local locals = require("nvim-treesitter.locals")
local v = vim
local M = {}

M.send_selection = function()
    -- Yanks to r register
    v.cmd('norm "ry')
    -- Sends contents of r register to the terminal
    v.fn.chansend(term.chanid, v.fn.getreg('r'))
    -- Hacky way to get the last newline
    v.fn.chansend(term.chanid, {"",""})
end

-- For some reason r syntax trees have = and <- as separate
--  So both are treated here
local is_equal = function (node)
    return (node:type() ~= nil and (node:type() == "left_assignment" or node:type() == "equals_assignment"))
end

-- Checks if the line is inside a function
local in_function = function()
    local node = ts_utils.get_node_at_cursor()
    if (node == nil) then
        return false
    end
    while (node:parent() ~= nil)  do
        if ((node:type() ~= nil and node:type() == "function_definition")) then
            return true
        end
        node = node:parent()
    end
    return false
end


M.send_line = function()
    local node = ts_utils.get_node_at_cursor()
    if node == nil then
        error("Select inside chunk please")
    end
    while (node:parent() ~= nil and  node:parent() ~= ts_utils.get_root_for_node(node)) do
        node = node:parent()
    end
    local bufnr = v.api.nvim_get_current_buf()
    local chanid = term.chanid
    ts_utils.update_selection(bufnr, node)
    if chanid == -1 then
        error("Start the terminal please")
    else
        M.send_selection()
        local _, _, end_row, _ = node:range()
        v.api.nvim_win_set_cursor(0, -- Sets cursor to next line, unless last line in file
        {math.min(end_row + 2, vim.api.nvim_buf_line_count(0)), 0})
    end
end

M.send_chunk = function()
    local node = ts_utils.get_node_at_cursor()
    if node == nil then
        error("Select inside chunk please")
    end
    while (node:parent() ~= nil)  do
        node = node:parent()
    end
    local bufnr = v.api.nvim_get_current_buf()
    local chanid = term.chanid
    ts_utils.update_selection(bufnr, node)
    if chanid == -1 then
        error("Start the terminal please")
    else
        M.send_selection()
    end
end

return M
