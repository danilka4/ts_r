local term = require("ts_r.term")
local ts_utils = require("nvim-treesitter.ts_utils")
local h = require("ts_r.helper")
local move = require("ts_r.move")
local v = vim
local M = {}

-- Sends text to the terminal started in ts_r.term
local send_to_terminal = function (content_to_send)
    v.fn.chansend(term.chanid, content_to_send)
    -- Hacky way to get the last newline
    v.fn.chansend(term.chanid, {"",""})
end

-- Yanks to the r register and sends that register to the terminal
M.send_selection = function()
    -- Yanks to r register
    v.cmd('norm "ry')
    send_to_terminal(v.fn.getreg('r'))
end

M.send_line = function()
    local node = ts_utils.get_node_at_cursor()
    -- Checks to see if the node is valid and inside the chunk
    if node == nil then
        error("Node is null")
    end
    if not h.in_chunk(node) then
        error("Not inside a chunk")
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

-- Highlights and sends a chunk of code
M.send_chunk = function()
    local node = ts_utils.get_node_at_cursor()

    -- Checks to see if the node is valid and inside the chunk
    if node == nil then
        error("Node is null")
    end
    if not h.in_chunk(node) then
        error("Not inside a chunk")
    end

    -- Checks to see if the terminal is running
    if term.chanid == -1 then
        error("Start the terminal please")
    end

    node = h.engulf_chunk(node)

    -- Highlights and sends to the terminal
    local bufnr = v.api.nvim_get_current_buf()
    ts_utils.update_selection(bufnr, node)
    M.send_selection()
    local _, _, end_row, _ = node:range()
    v.api.nvim_win_set_cursor(0, -- Sets cursor to next line, unless last line in file
    {math.min(end_row, v.api.nvim_buf_line_count(0)), 0})
end

M.send_all = function ()
    local filetype = v.bo.filetype
    local cursor = v.api.nvim_win_get_cursor(0)
    if filetype == "r" then
        v.cmd("norm ggVG")
        M.send_selection()
    elseif filetype == "rmd" then
        v.cmd("norm gg")
        while move.move_chunk_down() do
            M.send_chunk()
        end
    else
        error("Not an R file")
    end
    v.api.nvim_win_set_cursor(0, cursor)
end

M.install_package = function ()
    if term.chanid == -1 then
        error("Start the terminal please")
    else
        local package = v.fn.input("Name of Package: ")
        send_to_terminal('install.packages("' .. package .. '", repos="https://cran.us.r-project.org")')
    end
end

M.install_git = function ()
    if term.chanid == -1 then
        error("Start the terminal please")
    else
        local rep = v.fn.input("Name of Repository: ")
        send_to_terminal('devtools::install_github("' .. rep .. '")')
    end
end

M.save_image = function ()
    if term.chanid == -1 then
        error("Start the terminal please")
    else
        local name = v.fn.input("Name of Image: ")
        send_to_terminal('ggplot2::ggsave("' .. name .. '.png", bg = "white")')
    end
end

return M
