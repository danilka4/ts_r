local v = vim
local M = {}

M.winid = -1
M.chanid = -1

-- Opens up an R terminal if one wasn't already open
M.open_term = function()
    if M.winid == -1 then
        v.cmd('new')
        M.chanid = v.fn.termopen("R\n")
        M.winid = v.fn.win_getid()
        v.cmd('norm G')
        v.cmd('0resize +5')
        v.cmd('wincmd k')
    end
end

-- If there is an R terminal, close it
M.close_term = function()
    if M.winid ~= -1 then
        v.api.nvim_win_close(M.winid, 1)
        M.winid = -1
    end
end

return M
