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
    -- Checks to see if the terminal is running
    if term.winid == -1 then
        error("Start the terminal please")
    end
    -- Yanks to r register
    v.cmd('norm "ry')
    send_to_terminal(v.fn.getreg('r'))
end

M.send_line = function()
    if term.winid == -1 then
        error("Start the terminal please")
    else
    local node = ts_utils.get_node_at_cursor()
    -- Checks to see if the node is valid and inside the chunk
    if node == nil then
        error("Node is null")
    end
    if not h.in_chunk(node) then
        error("Not inside a chunk")
    end
    while (node:parent() ~= nil and  node:parent() ~= ts_utils.get_root_for_node(node) and node:type() ~= "code_fence_content") do
        node = node:parent()
    end
    local bufnr = v.api.nvim_get_current_buf()
    ts_utils.update_selection(bufnr, node)
        M.send_selection()
        local _, _, end_row, _ = node:range()
        v.api.nvim_win_set_cursor(0, -- Sets cursor to next line, unless last line in file
        {math.min(end_row + 2, v.api.nvim_buf_line_count(0)), 0})
    end
end

-- Highlights and sends a chunk of code
M.send_chunk = function()
    -- Checks to see if the terminal is running
    if term.winid == -1 then
        error("Start the terminal please")
    end

    local node = ts_utils.get_node_at_cursor()
    local cursor = v.api.nvim_win_get_cursor(0)

    -- Checks to see if the node is valid and inside the chunk
    if node == nil then
        error("Node is null")
    end
    if not h.in_chunk(node) then
        error("Not inside a chunk")
    end


    node = h.engulf_chunk(node)

    -- Highlights and sends to the terminal
    local bufnr = v.api.nvim_get_current_buf()
    ts_utils.update_selection(bufnr, node)
    M.send_selection()
    v.api.nvim_win_set_cursor(0, cursor)
    --local _, _, end_row, _ = node:range()
    --v.api.nvim_win_set_cursor(0, -- Sets cursor to next line, unless last line in file
    --{math.min(end_row, v.api.nvim_buf_line_count(0)), 0})
end

-- Sends all R code/code chunks to the terminal
M.send_all = function ()
    -- Checks to see if the terminal is running
    if term.winid == -1 then
        error("Start the terminal please")
    end
    local filetype = v.bo.filetype
    local cursor = v.api.nvim_win_get_cursor(0)
    if filetype == "r" then
        v.cmd("norm ggVG")
        M.send_selection()
    elseif filetype == "rmd" then
        local fence_content = "((code_fence_content) @code_fence_content)"
        local parser = require("nvim-treesitter.parsers").get_parser()
        local query = v.treesitter.query.parse_query(parser:lang(), fence_content)
        local tree = parser:parse()[1]
        local text = ""
        for _, n in query:iter_captures(tree:root(), 0) do
            local line = v.treesitter.query.get_node_text(n, 0)
            text = text .. line .. "\n"
        end
        v.fn.chansend(term.chanid, text)
    else
        error("Not an R file")
    end
    v.api.nvim_win_set_cursor(0, cursor)
end

-- Opens a man page for the highlighted word
M.man_entry = function ()
    if term.winid == -1 then
        error("Start the terminal please")
    end
    -- Sends "?<cmd>" to the terminal, which is R speak
    --  for opening up the man page for "<cmd>"
    v.cmd("norm viw")
    v.fn.chansend(term.chanid, "?")
    M.send_selection()

    -- Switches into the terminal so user can navigate
    --  the man page
    v.cmd("wincmd" .. term.chanid .. " w")
    v.cmd("normal i")
end

-- Installs an R package from the cran library
M.install_package = function ()
    if term.winid == -1 then
        error("Start the terminal please")
    end
    local package = v.fn.input("Name of Package: ")
    send_to_terminal('install.packages("' .. package .. '", repos="https://cran.us.r-project.org")')
end

-- Installs an R package from a github repo
M.install_git = function ()
    if term.winid == -1 then
        error("Start the terminal please")
    end
    local rep = v.fn.input("Name of Repository: ")
    send_to_terminal('devtools::install_github("' .. rep .. '")')
end

-- Saves the current plot on a white background
M.save_image = function ()
    if term.winid == -1 then
        error("Start the terminal please")
    end
    local name = v.fn.input("Name of Image: ")
    send_to_terminal('ggplot2::ggsave("' .. name .. '.png", bg = "white")')
end

return M
