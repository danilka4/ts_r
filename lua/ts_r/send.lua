local term = require("ts_r.term")
local ts_utils = require("nvim-treesitter.ts_utils")
local h = require("ts_r.helper")
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
    -- Checks to see if the cursor is hovering over the chunk language type
    --  This is because of some nesting bs within R's syntax tree
    if node:type() == "language" then
        node = node:parent()
    end

    -- This triggers when the cursor is in the fencing part of the chunk (```)
    if node:parent():type() == "fenced_code_block" then
        local nodes = ts_utils.get_named_children(node:parent())
        for _, val in pairs(nodes) do
            if val:type() == "code_fence_content" then
                node = val
            end
        end
    -- This triggers when inside the code chunk itself
    else
        while (node:parent() ~= nil and node:type() ~= "code_fence_content")  do
            node = node:parent()
        end
    end

    -- Highlights and sends to the terminal
    local bufnr = v.api.nvim_get_current_buf()
    ts_utils.update_selection(bufnr, node)
    M.send_selection()
    local _, _, end_row, _ = node:range()
    v.api.nvim_win_set_cursor(0, -- Sets cursor to next line, unless last line in file
    {math.min(end_row + 2, v.api.nvim_buf_line_count(0)), 0})
end

M.send_all = function ()
    local filetype = v.bo.filetype
    if filetype == "r" then
        local cursor = v.api.nvim_win_get_cursor(0)
        v.cmd("norm ggVG")
        M.send_selection()
        v.api.nvim_win_set_cursor(0, cursor)
    elseif filetype == "rmd" then
        print("TODO: Add 'all' functionality to rmd")
    else
        error("Not an R file")
    end
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
