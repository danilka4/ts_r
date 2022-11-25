local term = require("ts_r.term")
local ts_utils = require("nvim-treesitter.ts_utils")
local locals = require("nvim-treesitter.locals")
local v = vim
local M = {}

local function send_to_term ()
    v.cmd("norm \"ry")
    v.fn.chansend(term.chanid, v.fn.getreg('r'))
    v.fn.chansend(term.chanid, {"",""}) -- Hacky way to get the last newline
end

local check_if_function = function()
    print("hi")
end


M.send_line = function()
    check_if_function()
    print("hello")
end

M.send_chunk = function()
    local node = ts_utils.get_node_at_cursor()
    --node = locals.containing_scope(node:parent() or node)
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
