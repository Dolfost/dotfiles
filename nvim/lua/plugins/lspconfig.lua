return {
	'neovim/nvim-lspconfig',

	dependencies = { 'folke/neodev.nvim', },

	config = function(_, opts)
		require("neodev").setup({
			library = {
				enabled = true, -- when not enabled, neodev will not change any settings to the LSP server
				-- these settings will be used for your Neovim config directory
				runtime = true, -- runtime path
				types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
				plugins = true, -- installed opt or start plugins in packpath
				-- you can also specify the list of plugins to make available as a workspace library
				-- plugins = { "nvim-treesitter", "plenary.nvim", "telescope.nvim" },
			},
			setup_jsonls = true, -- configures jsonls to provide completion for project specific .luarc.json files
			-- for your Neovim config directory, the config.library settings will be used as is
			-- for plugin directories (root_dirs having a /lua directory), config.library.plugins will be disabled
			-- for any other directory, config.library.enabled will be set to false
			override = function(root_dir, options) end,
			-- With lspconfig, Neodev will automatically setup your lua-language-server
			-- If you disable this, then you have to set {before_init=require("neodev.lsp").before_init}
			-- in your lsp start options
			lspconfig = true,
			-- much faster, but needs a recent built of lua-language-server
			-- needs lua-language-server >= 3.6.0
			pathStrict = true,
		})

		local capabilities = require('cmp_nvim_lsp').default_capabilities()
		local lspconfig = require("lspconfig")

		vim.api.nvim_create_autocmd('LspAttach', {
			group = vim.api.nvim_create_augroup('UserLspConfig', {}),
			callback = function(ev)
				-- Enable completion triggered by <c-x><c-o>
				vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

				local wk = require"which-key"
				wk.add{
					{ "<leader>s", buffer = ev.buf,
						group = "Language server",
						icon = {icon = "", color = "purple"},
					},
					{ "<leader>sd", vim.diagnostic.open_float,
						desc = "Line diagnostics",
						icon = {icon = "󱖫", color = "green"},
					},
					{ "<leader>sg", group = "Go to symbol"},
					{ "<leader>sgD", vim.lsp.buf.declaration,
						desc = "Declaration",
						icon = {icon = "󱦹", color = "purple"},
					},
					{ "<leader>sgd", vim.lsp.buf.definition,
						desc = "Definition",
						icon = {icon = "", color = "purple"},
					},
					{ "<leader>sgi", vim.lsp.buf.implementation, desc = "Implementation"},
					{ "<leader>sgt", vim.lsp.buf.type_definition, desc = "Type definition"},
					{ "<leader>sk", vim.lsp.buf.signature_help,
						desc = "Symbol signature help",
						icon = {icon = '󰘥', color = 'purple'},
					},
					{ "<leader>sa", vim.lsp.buf.code_action,
						desc = "Code actions",
						mode = {"n", "v"},
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>sK", vim.lsp.buf.hover,
						desc = "Information about the symbol",
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>sw", group = "Workspace",
						icon = {icon = '', color = 'purple'},
					},
					{ "<leader>sw", vim.lsp.buf.add_workspace_folder,
						desc = "Add folder to the workspace",
						icon = {icon = '', color = 'green'},
					},
					{ "<leader>sw", vim.lsp.buf.remove_workspace_folder,
						desc = "Remove forlder from the workspace",
						icon = {icon = '', color = 'red'},
					},
					{ "<leader>sr", vim.lsp.buf.rename,
						desc = "Rename symbol",
						icon = {icon = '󰏪', color = 'purple'},
					},
					{ "<leader>sf", function()
						vim.lsp.buf.format{async = true}
					end,
						desc = "Format current buffer",
						icon = {icon = '󰉿', color = 'purple'},
					},
					{ "<leader>sl", group = "List", icon = {icon = '', color = 'purple'}},
					{ "<leader>slr", vim.lsp.buf.references, desc = "Current symbol references"},
					{ "<leader>sls", group = "Symbols", icon = {icon = '󰊕', color = 'purple'}},
					{ "<leader>sls", vim.lsp.buf.document_symbol, desc = "From current document"},
					{ "<leader>slw",vim.lsp.buf.workspace_symbol, desc = "From current workspace"},
					{ "<leader>slf",function()
						print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
					end,
						desc = "Workspace folders",
						icon = {icon = '', color = 'purple'},
					},
					{ "<leader>sc", group = "Calls", icon = {icon = '', color = 'purple'}},
					{ "<leader>sco", vim.lsp.buf.outgoing_calls,
						desc = "Symbol outgoing calls",
						icon = {icon = '', color = 'purple'},
					},
					{ "<leader>sci",vim.lsp.buf.incoming_calls,
						desc = "Symbol incoming calls",
						icon = {icon = '', color = 'purple'},
					},
				}
			end,
		})

		vim.lsp.enable({
			'rust_analyzer',
			'lua_ls',
			'clangd',
			'pyright',
			'cmake',
			'bashls',
		})

		vim.lsp.config('lua_ls', {
			capabilities = capabilities,
			settings = {
				Lua = {
					completion = {
						callSnippet = "Replace"
					},
				},
			},
		})

		vim.lsp.config('clangd', {
			capabilities = {
				textDocument = {
					completion = {
						completionItem = {
							commitCharactersSupport = true,
							deprecatedSupport = true,
							insertReplaceSupport = true,
							labelDetailsSupport = true,
							preselectSupport = true,
							resolveSupport = {
								properties = { "documentation", "detail", "additionalTextEdits" }
							},
							snippetSupport = false,
							tagSupport = {
								valueSet = { 1 }
							}
						}
					}
				}
			},
			cmd = {
				"clangd",
				"--header-insertion=iwyu",
				"--enable-config",
			},
			filetypes = { "c", "cpp", "h", "hpp", "inl", "objc", "objcpp", "cuda", "proto" }
		})

		vim.lsp.config('pyright', {
			capabilities = capabilities,
			root_dir = vim.loop.cwd, -- current working directory
		})

		vim.lsp.config('cmake', {
			capabilities = capabilities,
		})

		vim.lsp.config('bashls', {
			capabilities = {
				codeActionProvider = {
					codeActionKinds = { "quickfix" },
					resolveProvider = false,
					workDoneProgress = false
				},
				completionProvider = {
					resolveProvider = true,
					triggerCharacters = { "$", "{" }
				},
				definitionProvider = true,
				documentFormattingProvider = true,
				documentHighlightProvider = true,
				documentSymbolProvider = true,
				hoverProvider = true,
				referencesProvider = true,
				renameProvider = {
					prepareProvider = true
				},
				textDocumentSync = {
					change = 1,
					openClose = true,
					save = {
						includeText = false
					},
					willSave = false,
					willSaveWaitUntil = false
				},
				workspaceSymbolProvider = true
			}
		})
	end,

	--  NOTE: :h LSP says:
	-- 	To learn what capabilities are available you can run the following command in
	-- 	a buffer with a started LSP client:
	-- 		:lua =vim.lsp.get_active_clients()[1].server_capabilities
}
