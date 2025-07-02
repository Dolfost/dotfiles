local augroup = vim.api.nvim_create_augroup('my.peek', {})

return {
	"toppair/peek.nvim",
	event = { "VeryLazy" },
	build = "deno task --quiet build:fast",

	opts = {
		auto_load = true,         -- whether to automatically load preview when
		-- entering another markdown buffer
		close_on_bdelete = true,  -- close preview window on buffer delete

		syntax = false,            -- enable syntax highlighting, affects performance

		theme = 'dark',           -- 'dark' or 'light'

		update_on_change = true,

		app = 'browser',          -- 'webview', 'browser', string or a table of strings
		-- explained below

		filetype = { 'markdown' },-- list of filetypes to recognize as markdown

		-- relevant if update_on_change is true
		throttle_at = 200000,     -- start throttling when file exceeds this
		-- amount of bytes in size
		throttle_time = 'auto',   -- minimum amount of time in milliseconds
		-- that has to pass before starting new render
	},

	init = function()
		vim.api.nvim_create_autocmd('FileType', {
			pattern = { 'markdown' },
			group = augroup,
			callback = function(ev)
				local wk = require 'which-key'
				local peek = require'peek'
				wk.add{
					buffer = ev.buf,
					{ '<leader>m', function()
						if peek.is_open() then
							peek.close()
						else
							peek.open()
						end
					end, desc = 'Toggle markdown preview', icon = { icon = '' } },
				}
			end
		})
	end,
}
