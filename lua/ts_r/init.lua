-- Imports separate modules
local term = require"ts_r.term"
local send = require"ts_r.send"

local M = {}

-- Functions that deal with terminal manipulation
M.open_term = term.open_term
M.close_term = term.close_term

-- Functions that deal with sending to terminal
M.send_line = send.send_line
M.send_chunk = send.send_chunk
M.send_selection = send.send_selection
M.send_all = send.send_all
M.install_package = send.install_package
M.install_git = send.install_git
M.save_image = send.save_image

--vim.keymap.set("n", "<leader>r", M.open_term())

return M
