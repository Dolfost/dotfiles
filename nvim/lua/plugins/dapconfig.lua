return {
	-- NOTE: could be that mason-nvim-dap 
	-- should be moved from nvim-dap dependencies
	-- to first element in this reuturn table

	{
		'mfussenegger/nvim-dap',

		enabled = true,
		lazy = true,

		dependencies = {
			{
				"jay-babu/mason-nvim-dap.nvim",
				enabled = true,
				dependencies = {
					{ "williamboman/mason.nvim", config = true, },
				},
				opts = {
					ensure_installed = {
						'python',
						'codelldb',
						'bash',
					},

					handlers = {
						function(config)
							-- all sources with no handler get passed here
							-- Keep original functionality
							require('mason-nvim-dap').default_setup(config)
						end,
						-- codelldb = function(config)
						-- 	config.adapters = {
						-- 		type = "executable",
						-- 		command = "/usr/bin/python3",
						-- 		args = {
						-- 			"-m",
						-- 			"debugpy.adapter",
						-- 		},
						-- 	}
						-- 	require('mason-nvim-dap').default_setup(config) -- don't forget this!
						-- end,
					},
				},
			},

			{
				'rcarriga/nvim-dap-ui',

				opts = {
					controls = {
						element = "repl",
						enabled = true,
						icons = {
							disconnect = "",
							pause = "",
							play = "",
							run_last = "",
							step_back = "",
							step_into = "",
							step_out = "",
							step_over = "",
							terminate = ""
						}
					},
					element_mappings = {},
					expand_lines = true,
					floating = {
						border = "single",
						mappings = {
							close = { "q", "<Esc>" }
						}
					},
					force_buffers = true,
					icons = {
						collapsed = "",
						current_frame = "",
						expanded = ""
					},
					layouts = { {
						elements = { {
							id = "scopes",
							size = 0.25
						}, {
								id = "breakpoints",
								size = 0.25
							}, {
								id = "stacks",
								size = 0.25
							}, {
								id = "watches",
								size = 0.25
							} },
						position = "left",
						size = 40
					}, {
							elements = { {
								id = "repl",
								size = 0.5
							}, {
									id = "console",
									size = 0.5
								} },
							position = "bottom",
							size = 10
						} },
					mappings = {
						edit = "e",
						expand = { "<CR>", "<2-LeftMouse>" },
						open = "o",
						remove = "d",
						repl = "r",
						toggle = "t"
					},
					render = {
						indent = 1,
						max_value_lines = 100
					}
				},
				dependencies = {
					'nvim-neotest/nvim-nio',
				},
			},
		},

		keys = {
			{ "<leader>dc", function()
				if vim.fn.filereadable(".vscode/launch.json") then
					require"dap.ext.vscode".load_launchjs(nil, { codelldb = { "c", "cpp", "rust" } })
				end
				require"dap".continue()
			end, desc = "Continue/Stop" },
			{ "<leader>db", function()
				require"dap".toggle_breakpoint()
			end, desc = "Toggle breakpoint" },
			{ "<leader>dB", function()
				require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
			end, desc = "Set breakpoint with log"},
		},

		init = function ()
			local wk = require("which-key")

			wk.add{
				{ "<leader>d", group = "Debugger" },
			}
		end,

		config = function(_, opts)
			local dap, dapui = require("dap"), require("dapui")

			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end

			local wk = require("which-key")

			wk.add{
				-- { "<leader>d", group = "Debugger" },
				{ "<leader>dr", function() dap.repl.open() end, desc = "Open REPL"},
				{ "<leader>dl", function() dap.run_last() end, desc = "Run last"},
				{ "<leader>dh", function() require"dap.ui.widgets".hover() end, desc = "Hover", mode = {"n", "v"}},
				{ "<leader>dp", function() require'dap.ui.widgets'.preview() end, desc = "Preview", mode = {"n", "v"}},
				{ "<leader>ds", group = "Make steps" },
				{ "<leader>dsv", dap.step_over(), desc = "Step over"},
				{ "<leader>dsi", dap.step_into(), desc = "Step into"},
				{ "<leader>dso", dap.step_out(), desc = "Step out"},
				{ "<leader>df", group = "Floats" },
				{ "<leader>dff", function()
					local widgets = dap.ui.widgets
					widgets.centered_float(widgets.frames)
				end,
					desc = "Frames",
				},
				{ "<leader>dfs", function()
					local widgets = dap.ui.widgets
					widgets.centered_float(widgets.scopes)
				end,
					desc = "Scopes"
				},
			}

			dap.configurations.cpp = {
				{
					name = 'Launch cpp with codelldb',
					type = 'codelldb',
					request = 'launch',
					program = function()
						return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
					end,
					cwd = '${workspaceFolder}',
					stopOnEntry = false,
					args = {},
				},
			}
		end
	},
}
