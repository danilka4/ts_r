local term = require("ts_r.term")
local ts_utils = require("nvim-treesitter.ts_utils")
local locals = require("nvim-treesitter.locals")
local v = vim
local M = {}

local send_to_terminal = function (content_to_send)
    v.fn.chansend(term.chanid, content_to_send)
    -- Hacky way to get the last newline
    v.fn.chansend(term.chanid, {"",""})
end

M.send_selection = function()
    -- Yanks to r register
    v.cmd('norm "ry')
    send_to_terminal(v.fn.getreg('r'))
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
        {math.min(end_row + 2, v.api.nvim_buf_line_count(0)), 0})
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

M.install_package = function ()
    if term.chanid == -1 then
        error("Start the terminal please")
    end
    local package = v.fn.input("Name of Package: ")
    send_to_terminal('install.packages("' .. package .. '", repos="https://cran.us.r-project.org")')
end

M.install_git = function ()
    if term.chanid == -1 then
        error("Start the terminal please")
    end
    local rep = v.fn.input("Name of Repository: ")
    send_to_terminal('devtools::install_github("' .. rep .. '")')
end

M.save_image = function ()
    if term.chanid == -1 then
        error("Start the terminal please")
    end
    local name = v.fn.input("Name of Image: ")
    send_to_terminal('ggplot2::ggsave("' .. name .. '.png", bg = "white")')
end

return M
