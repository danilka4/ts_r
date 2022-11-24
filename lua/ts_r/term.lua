local v = vim
local M = {}

M.winid = -1
M.chanid = -1

function M.open_term()
    if M.winid == -1 then
        v.cmd('split')
        M.chanid = v.fn.termopen("R\n")
        M.winid = v.fn.win_getid()
        v.cmd('norm G')
        v.cmd('0resize +5')
        v.cmd('wincmd k')
    end
end

function M.close_term()
    if M.winid ~= -1 then
        v.api.nvim_win_close(M.winid, 1)
        M.winid = -1
    end
end

return M
