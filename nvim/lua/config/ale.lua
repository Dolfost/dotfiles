vim.keymap.set('n', '<Leader>l', ':ALELint<CR>')
vim.g.ale_use_neovim_diagnostics_api = 1
vim.g.ale_enabled = 1
vim.g.ale_lint_delay = 3000 -- def: 200 ms
vim.g.ale_sign_error = '>>'
vim.g.ale_sign_warning = '->'
vim.g.ale_sign_column_always = 0
vim.g.ale_lint_on_text_changed = 'never' -- always, normal, insert, never
vim.g.ale_lint_on_insert_leave = 0
vim.g.ale_lint_on_enter = 0
vim.g.ale_lint_on_save = 1
