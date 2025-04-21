return {
	{
		'tpope/vim-fugitive',
	},

	{
		'lewis6991/gitsigns.nvim',

		lazy = false,

		init = function ()
			local wk = require"which-key"

			wk.add{
				{ "<leader>g", group = "Git" };
				{ "<leader>gs", group = "Signs" };
				{ "<leader>gsB", "<cmd>Gitsigns blame_line full=true<cr>", desc = "Blame current line" },
				{ "<leader>gsb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle line blaming"},
				{ "<leader>gsp", "<cmd>Gitsigns preview_hunk<cr>", desc = "Preview hunk"},
				{ "<leader>gsd", "<cmd>Gitsigns toggle_word_diff<cr>", desc = "Toggle word diff"},
				{ "<leader>gss", "<cmd>Gitsigns toggle_signs<cr>", desc = "Toggle signs"},
			}

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
				signcolumn = false,  -- Toggle with `:Gitsigns toggle_signs`
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
