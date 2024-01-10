-- the MAIN lua config file that specifies
-- the import order for plugins

require'config/options'



-- lazy.nvim bootstrap --
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
-- lazy.nvim bootstrap -- 

local options = {}

--  NOTE: It will source all lua files in /lua/plugins/ according to `:h Lazy.nvim.txt`

require("lazy").setup("plugins", options)



require'config/visuals'
require'config/keybinds'


--  TODO: Fix oil.nvim or neo-tree.nvim loading on FileExplorer event
--  TODO: Add debugger support (check out https://www.youtube.com/@typecraft_dev)
--  BUG: Fix omnnisharp or charp_ls LSP 
