return {
	'tpope/vim-unimpaired',
	'tpope/vim-commentary',
	'tpope/vim-obsession',
	'tpope/vim-surround',
	'tpope/vim-fugitive',
	'tpope/vim-dispatch',

	'godlygeek/tabular',
	'ludovicchabant/vim-gutentags',

	{
		"christoomey/vim-tmux-navigator",

		cmd = {
			"TmuxNavigateLeft",
			"TmuxNavigateDown",
			"TmuxNavigateUp",
			"TmuxNavigateRight",
			"TmuxNavigatePrevious",
		},
		keys = {
			{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>" },
			{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>" },
			{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>" },
			{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>" },
			{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
		},
	},
}
