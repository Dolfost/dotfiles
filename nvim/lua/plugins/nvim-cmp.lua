local has_words_before = function()
	unpack = unpack or table.unpack
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
	'hrsh7th/nvim-cmp',

	dependencies = {
		'onsails/lspkind.nvim',

		'hrsh7th/cmp-cmdline',
		'FelipeLema/cmp-async-path',
		'hrsh7th/cmp-buffer',
		'hrsh7th/cmp-nvim-lsp',
		'saadparwaiz1/cmp_luasnip',
		'tamago324/cmp-zsh',
		'petertriho/cmp-git',
		{ 'micangl/cmp-vimtex', ft = 'tex' },
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

			-- window = {
			-- 	completion = cmp.config.window.bordered(),
			-- 	documentation = cmp.config.window.bordered(),
			-- },

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
				fields = { 'kind', 'abbr', 'menu' },
				format = lspkind.cmp_format({
					mode = 'symbol',
					menu = {
						buffer = 'buf',
						nvim_lsp = '',
						luasnip = 'snip',
						nvim_lua = 'nlua',
						latex_symbols = 'latex',
						vimtex = 'vimtex',
					},
					show_labelDetails = true,
					ellipsis_char = '…',
					-- maxwidth = {
					-- 	menu = 20,
					-- 	abbr = 20,
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
