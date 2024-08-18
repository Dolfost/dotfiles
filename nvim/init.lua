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

local options = {
	change_detection = {
		enabled = true,
		notify = false, -- get a notification when changes are found
	}
}

--  NOTE: It will source all lua files in /lua/plugins/
--  and /lua/plugins/colorschemes according to `:h Lazy.nvim.txt`

require("lazy").setup({
	{import = "plugins"},
	{import = "plugins.colorschemes"}
}, options)



require'config/visuals'
require'config/keybinds'

require'config/filetypes'

--  TODO: Fix cmd-zsh completion in cmdline after :!
--  TODO: Fix DAP suport (see ./lua/plugins/dapconfig.lua) 

--  DONE: Fix omnnisharp or charp_ls LSP 
--  DONE: Add debugger support (check out https://www.youtube.com/@typecraft_dev)
