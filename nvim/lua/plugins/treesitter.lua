-- nvim-treesitter main branch. On NixOS the plugin comes pre-built from
-- nixpkgs (all grammars + queries, linked by home-manager — see
-- nix/modules/user/shell); elsewhere lazy clones it and :TSUpdate compiles
-- parsers, which needs the tree-sitter CLI and a C compiler.
local nix_pack = vim.fn.stdpath("data") .. "/nix/nvim-treesitter"
local from_nix = vim.uv.fs_stat(nix_pack) ~= nil

return {
	{
		'nvim-treesitter/nvim-treesitter',
		branch = 'main',
		lazy = false,
		dir = from_nix and nix_pack or nil,
		build = from_nix and nil or ':TSUpdate',

		config = function()
			local disabled = {
				markdown = true, markdown_inline = true,
				latex = true, bibtex = true,
			}

			vim.api.nvim_create_autocmd('FileType', {
				group = vim.api.nvim_create_augroup('treesitter_highlight', {}),
				callback = function(args)
					local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
					if not lang or disabled[lang] then
						return
					end
					if pcall(vim.treesitter.start, args.buf, lang) then
						-- keep regex highlighting alongside treesitter (was
						-- additional_vim_regex_highlighting = true)
						vim.bo[args.buf].syntax = 'on'
					end
				end,
			})
		end,
	},
}
