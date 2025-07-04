return {
	{
		'aserowy/tmux.nvim',
		opts = {
			copy_sync = {
				-- enables copy sync. by default, all registers are synchronized.
				-- to control which registers are synced, see the `sync_*` options.
				enable = false,

				-- ignore specific tmux buffers e.g. buffer0 = true to ignore the
				-- first buffer or named_buffer_name = true to ignore a named tmux
				-- buffer with name named_buffer_name :)
				ignore_buffers = { empty = false },

				-- TMUX >= 3.2: all yanks (and deletes) will get redirected to system
				-- clipboard by tmux
				redirect_to_clipboard = false,

				-- offset controls where register sync starts
				-- e.g. offset 2 lets registers 0 and 1 untouched
				register_offset = 0,

				-- overwrites vim.g.clipboard to redirect * and + to the system
				-- clipboard using tmux. If you sync your system clipboard without tmux,
				-- disable this option!
				sync_clipboard = false,

				-- synchronizes registers *, +, unnamed, and 0 till 9 with tmux buffers.
				sync_registers = true,

				-- syncs deletes with tmux clipboard as well, it is adviced to
				-- do so. Nvim does not allow syncing registers 0 and 1 without
				-- overwriting the unnamed register. Thus, ddp would not be possible.
				sync_deletes = true,

				-- syncs the unnamed register with the first buffer entry from tmux.
				sync_unnamed = true,
			},
			navigation = {
				-- cycles to opposite pane while navigating into the border
				cycle_navigation = true,

				-- enables default keybindings (C-hjkl) for normal mode
				enable_default_keybindings = false,

				-- prevents unzoom tmux when navigating beyond vim border
				persist_zoom = false,
			},
			resize = {
				-- enables default keybindings (A-hjkl) for normal mode
				enable_default_keybindings = false,

				-- sets resize steps for x axis
				resize_step_x = 1,

				-- sets resize steps for y axis
				resize_step_y = 1,
			}
		},
		config = function(_, opts)
			local tmux = require"tmux"
			local wk = require"which-key"

			wk.add{
				{ "<C-h>", tmux.move_left,
					desc = "Tmux move left",
					icon = {icon = '', color = "azure"},
				},
				{ "<C-j>", tmux.move_bottom,
					desc = "Tmux move down",
					icon = {icon = '', color = "azure"},
				},
				{ "<C-k>", tmux.move_top,
					desc = "Tmux move up",
					icon = {icon = '', color = "azure"},
				},
				{ "<C-l>", tmux.move_right,
					desc = "Tmux move right",
					icon = {icon = '', color = "azure"},
				},
				{ "<M-h>", tmux.resize_left,
					desc = "Tmux resize left",
					icon = {icon = '', color = "azure"},
				},
				{ "<M-j>", tmux.resize_bottom,
					desc = "Tmux resize down",
					icon = {icon = '', color = "azure"},
				},
				{ "<M-k>", tmux.resize_top,
					desc = "Tmux resize up",
					icon = {icon = '', color = "azure"},
				},
				{ "<M-l>", tmux.resize_right,
					desc = "Tmux resize right",
					icon = {icon = '', color = "azure"},
				},
				{ "<MC-h>", tmux.swap_left,
					desc = "Tmux swap left",
					icon = {icon = '', color = "azure"},
				},
				{ "<MC-j>", tmux.swap_bottom,
					desc = "Tmux swap down",
					icon = {icon = '', color = "azure"},
				},
				{ "<MC-k>", tmux.swap_top,
					desc = "Tmux swap up",
					icon = {icon = '', color = "azure"},
				},
				{ "<MC-l>", tmux.swap_right,
					desc = "Tmux swap right",
					icon = {icon = '', color = "azure"},
				},
			}

			tmux.setup(opts)
		end
	},
}
