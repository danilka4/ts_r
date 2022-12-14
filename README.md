# R wrapper for nvim treesitter

This is a plugin for integrating the R terminal prompt into vim and quickly sending lines and chunks of code to it.
I was inspired to make something like this initially when trying out the [nvimr](https://github.com/jalvesaq/Nvim-R) plugin and found the overhead too cumbersome.
My initial solution used vimscript and regex and will never see the light of day on account of having too many bugs and edge cases.

# Requirements

The only plugin needed is [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter)

Install using your favorite package manager. I use Vim-Plug:
```vim
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'danilka4/ts_r'
```

# Usage

At present there are the following functions within this plugin:
1. `open_term()`: Opens a terminal with R
2. `close_term()`: Closes the R terminal
3. `send_line()`: Sends the current line to the terminal (if the line is spread across multiple LoC it'll send the whole thing)
4. `send_chunk()`: Specifically for Rmd, sends the whole chunk to the terminal
5. `send_selection()`: Sends the visual selection to the terminal
6. `send_all()`: Sends the entire file to the R terminal. Differentiates between r and rmd
7. `install_package()`: Asks for a package name and installs it
8. `install_git()`: Asks for a git repository and installs it
9. `save_image()`: Saves the image with a given name
10. `move_chunk_down/up`: Moves the user a chunk up or down from their current one (or to the chunk above/below them)


An example configuration for if you don't care if the maps are made regardless of file type.
```lua
local ts_r = require('ts_r')
vim.keymap.set('n', '<leader>r', function() ts_r.open_term() end)
vim.keymap.set('n', '<leader>q', function() ts_r.close_term() end)
vim.keymap.set('n', '<leader>l', function() ts_r.send_line() end)
vim.keymap.set('n', '<leader>c', function() ts_r.send_chunk() end)
vim.keymap.set('n', '<leader>a', function() ts_r.send_all() end)
vim.keymap.set('v', '<leader>s', function() ts_r.send_selection() end)
vim.keymap.set('n', '<leader>ip', function() ts_r.install_package() end)
vim.keymap.set('n', '<leader>ig', function() ts_r.install_git() end)
vim.keymap.set('n', '<leader>is', function() ts_r.save_image() end)
vim.keymap.set('n', '<leader>n', function() ts_r.move_chunk_down() end)
vim.keymap.set('n', '<leader>p', function() ts_r.move_chunk_up() end)
```
To have a terminal open upon entering nvim, add the following:
```lua
vim.api.nvim_create_autocmd({'VimEnter'}, {
    callback = function() ts_r.open_term() end,
})
```

## Recommended setup

I am currently unaware of a method using `vim.keymap.set` that will allow to pick specific file types, so my recommendation is to create a `ftplugin` directory in `~/.config/nvim` and creating `r.lua` and `rmd.lua` files in them that will load the maps only when editing r/r-adjacent files:
```lua
-- ~/.config/nvim/ftplugin/r.lua
local ts_r = require('ts_r')
vim.keymap.set('n', '<leader>r', function() ts_r.open_term() end)
vim.keymap.set('n', '<leader>q', function() ts_r.close_term() end)
vim.keymap.set('n', '<leader>l', function() ts_r.send_line() end)
vim.keymap.set('n', '<leader>a', function() ts_r.send_all() end)
vim.keymap.set('v', '<leader>s', function() ts_r.send_selection() end)
vim.keymap.set('n', '<leader>ip', function() ts_r.install_package() end)
vim.keymap.set('n', '<leader>ig', function() ts_r.install_git() end)
vim.keymap.set('n', '<leader>is', function() ts_r.save_image() end)
vim.api.nvim_create_autocmd({'VimEnter'}, {
    --pattern = {"*.r", "*.rmd"},
    callback = function() ts_r.open_term() end,
})
```
```lua
-- ~/.config/nvim/ftplugin/rmd.lua
local ts_r = require('ts_r')
vim.cmd.source("~/.config/nvim/ftplugin/r.lua") -- Yoinks the above commands for rmd
vim.keymap.set('n', '<leader>c', function() ts_r.send_chunk() end)
vim.keymap.set('n', '<leader>n', function() ts_r.move_chunk_down() end)
vim.keymap.set('n', '<leader>p', function() ts_r.move_chunk_up() end)
```

# Troubleshooting

Let me know if there arises any interesting behavior.

Some things I found:

The `autocmd` did not work with the `pattern` line.
The terminal refused to open under that specific setup, which is why I added it to the ftplugin files.

Sometimes when sending a chunk from the left-most \` in the bottom fence of a chunk, treesitter does not recognize that \` as being a part of the chunk.
I have no idea why it does this.
