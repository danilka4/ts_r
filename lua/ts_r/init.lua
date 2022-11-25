-- Imports separate modules
local term = require("ts_r.term")
local send = require"ts_r.send"

local M = {}

-- Functions that deal with terminal manipulation
M.open_term = term.open_term
M.close_term = term.close_term

-- Functions that deal with sending to terminal
M.send_line = send.send_line
M.send_chunk = send.send_chunk

--vim.keymap.set("n", "<leader>r", M.open_term())

return M
