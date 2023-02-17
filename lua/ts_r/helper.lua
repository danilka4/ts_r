local ts_utils = require("nvim-treesitter.ts_utils")
M = {}

-- Checks to see whether the cursor is currently inside a chunk
M.in_chunk = function (node)
    while node ~= nil do
        if node:type() == "fenced_code_block" or node:type() == "code_fence_content" or node:type() == "left_assignment" or node:type() == "equals_assignment" or node:type() == "call" or node:type() == "comment" or node:type() == "subset" then
            return true
        else
            node = node:parent()
        end
    end
    return false
end

-- Takes a node inside a chunk and makes it the size of the chunk
M.engulf_chunk = function(node)
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
    return node
end

return M
