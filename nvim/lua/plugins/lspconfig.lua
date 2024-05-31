local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- search for avr-gcc for clangd
local handle = io.popen("command -v avr-gcc")
local avr_gcc
if handle then
	avr_gcc = handle:read("*a"):sub(1, -2)
	handle:close()
else
	avr_gcc = nil;
end


return {
	{
		'williamboman/mason-lspconfig.nvim',

		dependencies = {
			{ "williamboman/mason.nvim", config = true, },
		},

		opts = {
			ensure_installed = {
				'lua_ls',
				'bashls',
				'marksman',
				'matlab_ls',
				'clangd',
				'omnisharp',
				'pyright',
				'neocmake',
				'ast_grep',
			},
		},
	},

	{
		"folke/neodev.nvim", -- setup in lspconfig
	},

	{
		'neovim/nvim-lspconfig',

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

       vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
         vim.lsp.handlers.hover, {
           border = "rounded",
           title = "Symbol info"
         }
       )

       vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
         vim.lsp.handlers.signature_help, {
           border = "rounded",
					 title = "Signature help",
         }
       )

			vim.api.nvim_create_autocmd('LspAttach', {
				group = vim.api.nvim_create_augroup('UserLspConfig', {}),
				callback = function(ev)
					-- Enable completion triggered by <c-x><c-o>
					vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

					local wk = require"which-key"
					wk.register({
						name = "Language server",
						g = {
							name = "Go to",
							D = {vim.lsp.buf.declaration, "symbol declaration"},
							d = {vim.lsp.buf.definition, "symbol definition"},
							i = {vim.lsp.buf.implementation, "symbol implementation"},
							t = {vim.lsp.buf.type_definition, "symbol type definition"},
						},
						k = {vim.lsp.buf.signature_help, "Display symbol signature help"},
						K = {vim.lsp.buf.hover, "Display information about the symbol"},
						w = {
							name = "Workspace",
							a = {vim.lsp.buf.add_workspace_folder, "Add folder to the workspace"},
							r = {vim.lsp.buf.remove_workspace_folder, "Remove forlder from the workspace"},
						},
						r = {vim.lsp.buf.rename, "Rename symbol"},
						f = {function()
							vim.lsp.buf.format{async = true}
						end, "Format current buffer"},
						l = {
							name = "List",
							r = {vim.lsp.buf.references, "current symbol references"},
							s = {
								name = "Symbols",
								d = {vim.lsp.buf.document_symbol, "from current document"},
								w = {vim.lsp.buf.workspace_symbol, "from current workspace"},
							},
							f = {function()
								print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
							end , "List workspace folders"},
							c = {
								name = "Calls",
								o = {vim.lsp.buf.outgoing_calls, "symbol outgoing calls"},
								i = {vim.lsp.buf.incoming_calls, "symbol incoming calls"},
							},
						},
					}, {prefix = "<leader>s", buffer = ev.buf})

					wk.register({
						a = {vim.lsp.buf.code_action, "Code actions"},
					}, {prefix = "<leader>s", mode = {"n", "v"}, buffer = ev.buf})
				end,
			})

			lspconfig.lua_ls.setup {
				capabilities = capabilities,
				settings = {
					Lua = {
						completion = {
							callSnippet = "Replace"
						},
					},
				},
			}

			lspconfig.clangd.setup {
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
					vim.fn.stdpath("data") .. "/mason/bin/clangd", avr_gcc and "--query-driver=" .. avr_gcc,
					"--header-insertion=iwyu",
					"--enable-config",
				},
				filetypes = { "c", "cpp", "h", "hpp", "inl", "objc", "objcpp", "cuda", "proto" }
			}

			lspconfig.omnisharp.setup {
				capabilities = capabilities,
				cmd = { "dotnet", vim.fn.stdpath "data" .. "/mason/packages/omnisharp/libexec/OmniSharp.dll" },
				enable_import_completion = true,
				organize_imports_on_format = true,
				enable_roslyn_analyzers = true,
				root_dir = vim.loop.cwd, -- current working directory
			}

			lspconfig.pyright.setup {
				capabilities = capabilities,
			}
			
			lspconfig.neocmake.setup {
				capabilities = capabilities,
			}

			lspconfig.bashls.setup{
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
			}
		end,

	--  NOTE: :h LSP says:
	-- 	To learn what capabilities are available you can run the following command in
	-- 	a buffer with a started LSP client:
	-- 		:lua =vim.lsp.get_active_clients()[1].server_capabilities
	},

	{
		'L3MON4D3/LuaSnip',

		-- follow latest release.
		version = 'v2.*', -- Replace <CurrentMajor> by the latest released major (first number of latest release)
		-- install jsregexp (optional!).
		build = 'make install_jsregexp',
		-- dependencies = { 'rafamadriz/friendly-snippets' },

		config = function()
			local ls = require 'luasnip'
			ls.setup {
				snip_env = {
					bruh = "sus",
				},
			}

			ls.filetype_extend("cpp", {"c"})
			require('luasnip.loaders.from_lua').load{ 
				paths = {
					'~/.config/nvim/lua/snippets'
				} 
			}
		end,
	},

	{
		'hrsh7th/nvim-cmp',

		dependencies = {
			'neovim/nvim-lspconfig',
			{ "williamboman/mason.nvim", config = true, },
			'williamboman/mason-lspconfig.nvim',
			'onsails/lspkind.nvim',

			'hrsh7th/cmp-cmdline',
			'FelipeLema/cmp-async-path',
			'hrsh7th/cmp-buffer',
			'hrsh7th/cmp-nvim-lsp',
			'saadparwaiz1/cmp_luasnip',
			'tamago324/cmp-zsh',
			'petertriho/cmp-git',
			{ 'micangl/cmp-vimtex',      ft = 'tex' },
		},


		config = function()
			local cmp = require 'cmp'
			local ls = require 'luasnip'
			local lspkind = require 'lspkind'

			cmp.setup({
				snippet = {
					-- REQUIRED - you must specify a snippet engine
					expand = function(args)
						require('luasnip').lsp_expand(args.body)
					end,
				},

				window = {
					completion = cmp.config.window.bordered(),
					documentation = cmp.config.window.bordered(),
				},

				experimental = {
					ghost_text = true
				},

				mapping = cmp.mapping.preset.insert({
					['<C-b>'] = cmp.mapping.scroll_docs(-4),
					['<C-f>'] = cmp.mapping.scroll_docs(4),
					['<C-Space>'] = cmp.mapping.complete(),
					['<C-e>'] = cmp.mapping.abort(),
					['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

					-- LuaSnip support
					['<Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_next_item()
							-- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
							-- that way you will only jump inside the snippet region
						elseif ls.expand_or_jumpable() then
							ls.expand_or_jump()
						elseif has_words_before() then
							cmp.complete()
						else
							fallback()
						end
					end, { 'i', 's' }),
					['<S-Tab>'] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						elseif ls.jumpable(-1) then
							ls.jump(-1)
						else
							fallback()
						end
					end, { 'i', 's' }),
				}),

				formatting = {
					fields = { 'abbr', 'kind', 'menu' },
					format = lspkind.cmp_format({
						mode = 'text_symbol',
						-- menu = {
						-- 	buffer = '[Buf]',
						-- 	nvim_lsp = '[LSP]',
						-- 	luasnip = '[lSnip]',
						-- 	nvim_lua = '[Lua]',
						-- 	latex_symbols = '[tex]',
						-- 	vimtex = '[vimtex]',
						-- },
					}),
				},

				sources = cmp.config.sources({
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'async_path' },
					{ name = 'buffer' },
				}),
			})

			cmp.setup.filetype('gitcommit', {
				sources = cmp.config.sources({
					{ name = 'git',        group_index = 1 },
					{ name = 'buffer',     group_index = 2 },
					{ name = 'async_path', group_index = 2 },
				}),
			})

			cmp.setup.filetype("tex", {
				sources = {
					{ name = 'vimtex' },
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'async_path' },
					{ name = 'buffer' },
				},
			})

			cmp.setup.filetype("lua", {
				sources = {
					{ name = 'nvim_lsp' },
					{ name = 'luasnip' },
					{ name = 'async_path' },
					{ name = 'buffer' },
				},
			})

			cmp.setup.cmdline({ '/', '?' }, {
				mapping = cmp.mapping.preset.cmdline(),
				sources = {
					{ name = 'buffer' }
				}
			})

			cmp.setup.cmdline(':', {
				mapping = cmp.mapping.preset.cmdline(),
				sources = cmp.config.sources({
					-- { name = 'path' },
					{
						name = 'cmdline',
						group_index = 1,
						option = {
							ignore_cmds = { 'Man', '!' }
						},
					},
					{
						name = 'zsh',
						group_index = 2,
					},
				})
			})
		end,
	}
}
