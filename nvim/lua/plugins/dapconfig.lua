return {
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
		'mfussenegger/nvim-dap',

		enabled = true,
		dependencies = {
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

			wk.register({
				name = "Debugger",
				c = {function() dap.continue() end, "Continue"},
				s = {
					name = "Make steps",
					v = {dap.step_over(), "Step over"},
					i = {dap.step_into(), "Step into"},
					o = {dap.step_out(), "Step out"},
				},
				b = {function() dap.toggle_breakpoint() end, "Toggle breakpoint"},
				B = {
					function()
						require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
					end, "Set breakpoint with log"
				},
				r = {function() dap.repl.open() end, "Open REPL"},
				l = {function() dap.run_last() end, "Run last"},
				f = {
					name = "Floats",
					f = {
						function()
							local widgets = dap.ui.widgets
							widgets.centered_float(widgets.frames)
						end,
						"Frames"
					},
					s = {
						function()
							local widgets = dap.ui.widgets
							widgets.centered_float(widgets.scopes)
						end,
						"Scopes"
					},
				},
			}, { prefix = "<leader>d", mode = {"n"} })

			wk.register({
				h = {function() dap.ui.widgets.hover() end, "Hover"},
				p = {function() require('dap.ui.widgets').hover() end, "Preview"},
			}, { prefix = "<leader>d", mode = {"n", "v"} })

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

					-- if you change `runInTerminal` to true, you might need to change the yama/ptrace_scope setting:
					--
					--    echo 0 | sudo tee /proc/sys/kernel/yama/ptrace_scope
					--
					-- Otherwise you might get the following error:
					--
					--    Error on launch: Failed to attach to the target process
					--
					-- But you should be aware of the implications:
					-- https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
					-- runInTerminal = false,
				},
			}
		end
	},
}
