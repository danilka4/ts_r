-- Imports separate modules
local term = require("ts_r.term")
local send = require("ts_r.send")

local M = {}

M.open_term = term.open_term()
M.close_term = term.close_term()

M.send_line = send.send_line()
M.send_chunk = send.send_chunk()

return M
