-- This is a global keybinds file. The plugin-specific keybinds live in lua/plugin.lua or ftplugin/

-- NO ARROW KEYS, U MFCKER! heheheha!!1!
vim.keymap.set('n', '<Up>', '<Nop>')
vim.keymap.set('n', '<Down>', '<Nop>')
vim.keymap.set('n', '<Left>', '<Nop>')
vim.keymap.set('n', '<Right>', '<Nop>')

-- Regenerate ctags file with F5
vim.keymap.set('n', '<f5>', ':!ctags -R<CR>')

-- Telescope keybinds
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
