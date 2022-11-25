# R wrapper for nvim treesitter

This is a plugin for integrating the R terminal prompt into vim and quickly sending lines and chunks of code to it.
I was inspired to make something like this initially when trying out the [nvimr](https://github.com/jalvesaq/Nvim-R) plugin and found the overhead too cumbersome.
My initial solution used vimscript and regex and will never see the light of day on account of having too many bugs and edge cases.

# Requirements

The only plugin needed is [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

Install using your favorite package manager. I use Vim-Plug:
```vim
Plug 'danilka4/ts_r'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
```

# Usage

At present there are four functions within this plugin. They are:
1. `open_term()`: Opens a terminal with R
2. `close_term()`: Closes the R terminal
3. `send_line()`: Sends the current line to the terminal (if the line is spread across multiple LoC it'll send the whole thing)
4. `send_chunk()`: Specifically for Rmd, sends the whole chunk to the terminal
**3 and 4 only work if the terminal is open**

An example configuration for if you don't care if the maps are made regardless of file type.
```nvim
local ts_r = require('ts_r')
vim.keymap.set('n', '<leader>r', function() ts_r.open_term() end)
vim.keymap.set('n', '<leader>q', function() ts_r.close_term() end)
vim.keymap.set('n', '<leader>l', function() ts_r.send_line() end)
vim.keymap.set('n', '<leader>c', function() ts_r.send_chunk() end)
```
To have a terminal open upon entering nvim, add the following:
```nvim
vim.api.nvim_create_autocmd({'VimEnter'}, {
    callback = function() ts_r.open_term() end,
})
```

## Recommended setup

I am currently unaware of a method using `vim.keymap.set` that will allow to pick specific file types, so my recommendation is to create a `ftplugin` directory in `~/.config/nvim` and creating `r.lua` and `rmd.lua` files in them that will load the maps only when editing r/r-adjacent files:
```nvim
-- ~/.config/nvim/ftplugin/r.lua
local ts_r = require('ts_r')
vim.keymap.set('n', '<leader>r', function() ts_r.open_term() end)
vim.keymap.set('n', '<leader>q', function() ts_r.close_term() end)
vim.keymap.set('n', '<leader>l', function() ts_r.send_line() end)
vim.api.nvim_create_autocmd({'VimEnter'}, {
    --pattern = {"*.r", "*.rmd"},
    callback = function() ts_r.open_term() end,
})
```
```nvim
local ts_r = require('ts_r')
vim.cmd.source("~/.config/nvim/ftplugin/r.lua") -- Yoinks the above commands for rmd
vim.keymap.set('n', '<leader>c', function() ts_r.send_chunk() end)
```

# Troubleshooting

Let me know if there arises any interesting behavior.

The only confusing behavior I found was that the `autocmd` did not work with the `pattern` line.
The terminal refused to open under that specific setup, which is why I added it to the ftplugin files.