return {
	{
		'tpope/vim-fugitive',
	},

	{
		'lewis6991/gitsigns.nvim',

		lazy = false,

		init = function ()
			local wk = require"which-key"

			wk.register({
				name = "Git",
				s = {
					name = "Signs",
					B = { "<cmd>Gitsigns blame_line full=true<cr>", "Blame current line" },
					b = { "<cmd>Gitsigns toggle_current_line_blame<cr>", "Toggle line blaming"},
					p = { "<cmd>Gitsigns preview_hunk<cr>", "Preview hunk"},
					d = { "<cmd>Gitsigns toggle_word_diff<cr>", "Toggle word diff"},
					s = { "<cmd>Gitsigns toggle_signs<cr>", "Toggle signs"},
				},
			}, {prefix = "<leader>g"})

		end,


		config = function()
			local gitsigns = require("gitsigns")

			local opts = {
				signs = {
					add          = { text = '┆' },
					change       = { text = '' },
					delete       = { text = '󰆴' },
					topdelete    = { text = '󰠙' },
					changedelete = { text = '󰛌' },
					untracked    = { text = '' },
				},
				signcolumn = true,  -- Toggle with `:Gitsigns toggle_signs`
				numhl      = true, -- Toggle with `:Gitsigns toggle_numhl`
				linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
				word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
				watch_gitdir = {
					follow_files = true
				},
				auto_attach = true,
				attach_to_untracked = false,
				current_line_blame = true, -- Toggle with `:Gitsigns toggle_current_line_blame`
				current_line_blame_opts = {
					virt_text = true,
					virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
					delay = 200,
					ignore_whitespace = false,
					virt_text_priority = 100,
				},
				current_line_blame_formatter = '<author>, <author_time:%R> - <summary>',
				sign_priority = 6,
				update_debounce = 100,
				status_formatter = nil, -- Use default
				max_file_length = 80000, -- Disable if file is longer than this (in lines)
				preview_config = {
					-- Options passed to nvim_open_win
					border = 'single',
					style = 'minimal',
					relative = 'cursor',
					row = 0,
					col = 1
				},
			}

			gitsigns.setup(opts)
		end,
	},
}
