local term = require("ts_r.term")
local ts_utils = require("nvim-treesitter.ts_utils")
local locals = require("nvim-treesitter.locals")
local v = vim
local M = {}

local function send_to_term ()
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
    --if (in_function()) then
    --    while (node:parent() ~= nil and node:type() ~= "function_definition")  do
    --        node = node:parent()
    --    end
    --end
    -- (node:parent():type() ~= "binary" and node:parent():type() ~= "equals_assignment" and node:parent():type() ~= "left_assignment")
    --while (node:parent() ~= nil and node:type() ~= "binary" and node:type() ~= "left_assignment" and node:type() ~= "equals_assignment" and node:type() ~= "call") do
    while (node:parent() ~= nil and  node:parent() ~= ts_utils.get_root_for_node(node)) do
        node = node:parent()
    end
    local bufnr = v.api.nvim_get_current_buf()
    local chanid = term.chanid
    ts_utils.update_selection(bufnr, node)
    if chanid == -1 then
        error("Start the terminal please")
    else
        send_to_term()
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
        send_to_term()
    end
end

return M
